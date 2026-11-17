USE master;
GO

ALTER DATABASE HospitalDB SET RECOVERY FULL;
GO

EXEC master.dbo.xp_create_subdir N'/var/opt/mssql/backup/HospitalDB/';
EXEC master.dbo.xp_create_subdir N'/var/opt/mssql/backup/Sistema/';
GO

USE HospitalDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_BackupHospitalDB
    @Tipo VARCHAR(4),
    @Ruta NVARCHAR(260) = N'/var/opt/mssql/backup/HospitalDB/'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Marca NVARCHAR(15) = FORMAT(SYSDATETIME(), 'yyyyMMdd_HHmmss');
    DECLARE @Archivo NVARCHAR(400);

    IF @Tipo NOT IN ('FULL', 'DIFF', 'LOG')
        THROW 50001, N'Tipo de backup no valido. Use FULL, DIFF o LOG.', 1;

    IF @Tipo = 'FULL'
    BEGIN
        SET @Archivo = CONCAT(@Ruta, N'HospitalDB_FULL_', @Marca, N'.bak');

        BACKUP DATABASE HospitalDB
        TO DISK = @Archivo
        WITH CHECKSUM, COMPRESSION, INIT, NAME = N'HospitalDB-Full';
    END
    ELSE IF @Tipo = 'DIFF'
    BEGIN
        SET @Archivo = CONCAT(@Ruta, N'HospitalDB_DIFF_', @Marca, N'.bak');

        BACKUP DATABASE HospitalDB
        TO DISK = @Archivo
        WITH DIFFERENTIAL, CHECKSUM, COMPRESSION, INIT, NAME = N'HospitalDB-Diferencial';
    END
    ELSE
    BEGIN
        SET @Archivo = CONCAT(@Ruta, N'HospitalDB_LOG_', @Marca, N'.trn');

        BACKUP LOG HospitalDB
        TO DISK = @Archivo
        WITH CHECKSUM, COMPRESSION, INIT, NAME = N'HospitalDB-Log';
    END;

    RESTORE VERIFYONLY FROM DISK = @Archivo WITH CHECKSUM;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_VerificarBackups
    @MinutosMaxLog INT = 30,
    @DiasMaxFull INT = 8
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UltimoFull DATETIME;
    DECLARE @UltimoLog DATETIME;
    DECLARE @Danados INT;
    DECLARE @Mensaje NVARCHAR(500);

    SELECT
        @UltimoFull = MAX(CASE WHEN type = 'D' THEN backup_finish_date END),
        @UltimoLog = MAX(CASE WHEN type = 'L' THEN backup_finish_date END),
        @Danados = ISNULL(SUM(CASE WHEN is_damaged = 1 THEN 1 ELSE 0 END), 0)
    FROM msdb.dbo.backupset
    WHERE database_name = N'HospitalDB'
      AND backup_start_date >= DATEADD(DAY, -@DiasMaxFull, GETDATE());

    IF @UltimoFull IS NULL
    BEGIN
        SET @Mensaje = CONCAT(N'No hay backup Full de HospitalDB en los ultimos ', @DiasMaxFull, N' dias.');
        THROW 50010, @Mensaje, 1;
    END;

    IF @UltimoLog IS NULL OR @UltimoLog < DATEADD(MINUTE, -@MinutosMaxLog, GETDATE())
    BEGIN
        SET @Mensaje = CONCAT(N'No hay backup de log de HospitalDB en los ultimos ', @MinutosMaxLog, N' minutos.');
        THROW 50011, @Mensaje, 1;
    END;

    IF @Danados > 0
    BEGIN
        SET @Mensaje = CONCAT(N'Se detectaron ', @Danados, N' backups marcados como danados en msdb.');
        THROW 50012, @Mensaje, 1;
    END;

    SELECT @UltimoFull AS UltimoFull, @UltimoLog AS UltimoLog, N'Correcto' AS Estado;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_BackupSistema
    @Ruta NVARCHAR(260) = N'/var/opt/mssql/backup/Sistema/'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Marca NVARCHAR(15) = FORMAT(SYSDATETIME(), 'yyyyMMdd_HHmmss');
    DECLARE @Archivo NVARCHAR(400);

    SET @Archivo = CONCAT(@Ruta, N'master_FULL_', @Marca, N'.bak');

    BACKUP DATABASE master
    TO DISK = @Archivo
    WITH CHECKSUM, COMPRESSION, INIT, NAME = N'master-Full';

    RESTORE VERIFYONLY FROM DISK = @Archivo WITH CHECKSUM;

    SET @Archivo = CONCAT(@Ruta, N'msdb_FULL_', @Marca, N'.bak');

    BACKUP DATABASE msdb
    TO DISK = @Archivo
    WITH CHECKSUM, COMPRESSION, INIT, NAME = N'msdb-Full';

    RESTORE VERIFYONLY FROM DISK = @Archivo WITH CHECKSUM;
END;
GO

EXEC dbo.usp_BackupHospitalDB @Tipo = 'FULL';
GO

EXEC dbo.usp_BackupSistema;
GO