USE master;
GO

SET NOCOUNT ON;

DECLARE @BD SYSNAME = N'HospitalDB';
DECLARE @BDDestino SYSNAME = N'HospitalDB_Restore';
DECLARE @RutaBackup NVARCHAR(260) = N'/var/opt/mssql/backup/HospitalDB/';
DECLARE @Inicio DATETIME2 = SYSDATETIME();
DECLARE @ArchivoTail NVARCHAR(400) = CONCAT(@RutaBackup, N'HospitalDB_TAIL_', FORMAT(SYSDATETIME(), 'yyyyMMdd_HHmmss'), N'.trn');
DECLARE @FullId INT;
DECLARE @DiffId INT;
DECLARE @BaseLsn NUMERIC(25, 0);
DECLARE @Mover NVARCHAR(MAX);
DECLARE @Sentencia NVARCHAR(MAX);
DECLARE @i INT = 1;
DECLARE @n INT;

IF @BD = @BDDestino
    THROW 50020, N'La base destino no puede ser la base original.', 1;

BACKUP LOG @BD
TO DISK = @ArchivoTail
WITH NO_TRUNCATE, CHECKSUM, COMPRESSION, INIT, NAME = N'HospitalDB-Tail';

SELECT TOP (1) @FullId = backup_set_id, @BaseLsn = last_lsn
FROM msdb.dbo.backupset
WHERE database_name = @BD AND type = 'D' AND is_copy_only = 0 AND is_damaged = 0
ORDER BY backup_finish_date DESC;

IF @FullId IS NULL
    THROW 50021, N'No existe un backup Full registrado para la base de datos.', 1;

SELECT TOP (1) @DiffId = d.backup_set_id, @BaseLsn = d.last_lsn
FROM msdb.dbo.backupset AS d
JOIN msdb.dbo.backupset AS f ON d.differential_base_guid = f.backup_set_uuid
WHERE f.backup_set_id = @FullId AND d.type = 'I' AND d.is_damaged = 0
ORDER BY d.backup_finish_date DESC;

SELECT @Mover = STRING_AGG(
    CONCAT(
        N'MOVE N''', name, N''' TO N''',
        LEFT(physical_name, LEN(physical_name) - CHARINDEX(N'/', REVERSE(REPLACE(physical_name, N'\', N'/'))) + 1),
        @BDDestino, N'_', name,
        CASE type WHEN 1 THEN N'.ldf' ELSE N'.mdf' END,
        N''''
    ), N', ')
FROM sys.master_files
WHERE database_id = DB_ID(@BD);

CREATE TABLE #Pasos (
    Orden INT IDENTITY(1, 1) PRIMARY KEY,
    Sentencia NVARCHAR(MAX) NOT NULL
);

INSERT #Pasos (Sentencia)
SELECT CONCAT(N'RESTORE DATABASE ', QUOTENAME(@BDDestino), N' FROM DISK = N''', mf.physical_device_name,
              N''' WITH ', @Mover, N', NORECOVERY, REPLACE, CHECKSUM;')
FROM msdb.dbo.backupset AS bs
JOIN msdb.dbo.backupmediafamily AS mf ON mf.media_set_id = bs.media_set_id
WHERE bs.backup_set_id = @FullId;

IF @DiffId IS NOT NULL
    INSERT #Pasos (Sentencia)
    SELECT CONCAT(N'RESTORE DATABASE ', QUOTENAME(@BDDestino), N' FROM DISK = N''', mf.physical_device_name,
                  N''' WITH NORECOVERY, CHECKSUM;')
    FROM msdb.dbo.backupset AS bs
    JOIN msdb.dbo.backupmediafamily AS mf ON mf.media_set_id = bs.media_set_id
    WHERE bs.backup_set_id = @DiffId;

INSERT #Pasos (Sentencia)
SELECT CONCAT(N'RESTORE LOG ', QUOTENAME(@BDDestino), N' FROM DISK = N''', mf.physical_device_name,
              N''' WITH NORECOVERY, CHECKSUM;')
FROM msdb.dbo.backupset AS bs
JOIN msdb.dbo.backupmediafamily AS mf ON mf.media_set_id = bs.media_set_id
WHERE bs.database_name = @BD AND bs.type = 'L' AND bs.last_lsn > @BaseLsn AND bs.is_damaged = 0
ORDER BY bs.first_lsn;

INSERT #Pasos (Sentencia)
VALUES (CONCAT(N'RESTORE DATABASE ', QUOTENAME(@BDDestino), N' WITH RECOVERY;'));

SELECT @n = COUNT(*) FROM #Pasos;

WHILE @i <= @n
BEGIN
    SELECT @Sentencia = Sentencia FROM #Pasos WHERE Orden = @i;
    EXEC sys.sp_executesql @Sentencia;
    SET @i += 1;
END;

SELECT Orden, Sentencia FROM #Pasos ORDER BY Orden;

SELECT DATEDIFF(SECOND, @Inicio, SYSDATETIME()) AS SegundosTailMasRestauracion;

DROP TABLE #Pasos;
GO

DBCC CHECKDB (HospitalDB_Restore) WITH NO_INFOMSGS;
GO

SELECT name AS BaseDeDatos, state_desc AS Estado, recovery_model_desc AS ModeloRecuperacion
FROM sys.databases
WHERE name IN (N'HospitalDB', N'HospitalDB_Restore');

SELECT N'clinico.Pacientes' AS Tabla,
       (SELECT COUNT(*) FROM HospitalDB.clinico.Pacientes) AS Original,
       (SELECT COUNT(*) FROM HospitalDB_Restore.clinico.Pacientes) AS Restaurada
UNION ALL
SELECT N'clinico.Medicos',
       (SELECT COUNT(*) FROM HospitalDB.clinico.Medicos),
       (SELECT COUNT(*) FROM HospitalDB_Restore.clinico.Medicos)
UNION ALL
SELECT N'clinico.Citas',
       (SELECT COUNT(*) FROM HospitalDB.clinico.Citas),
       (SELECT COUNT(*) FROM HospitalDB_Restore.clinico.Citas)
UNION ALL
SELECT N'clinico.Tratamientos',
       (SELECT COUNT(*) FROM HospitalDB.clinico.Tratamientos),
       (SELECT COUNT(*) FROM HospitalDB_Restore.clinico.Tratamientos)
UNION ALL
SELECT N'facturacion.Facturacion',
       (SELECT COUNT(*) FROM HospitalDB.facturacion.Facturacion),
       (SELECT COUNT(*) FROM HospitalDB_Restore.facturacion.Facturacion);
GO