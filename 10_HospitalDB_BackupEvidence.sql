USE msdb;
GO

SELECT name AS BaseDeDatos, recovery_model_desc AS ModeloRecuperacion, state_desc AS Estado
FROM sys.databases
WHERE name = N'HospitalDB';
GO

SELECT
    j.name AS Job,
    j.enabled AS Habilitado,
    s.name AS Horario,
    CASE s.freq_type WHEN 4 THEN N'Diario' WHEN 8 THEN N'Semanal' ELSE N'Otro' END AS Frecuencia,
    s.freq_interval AS Intervalo,
    CASE s.freq_subday_type WHEN 1 THEN N'Hora fija' WHEN 4 THEN N'Cada N minutos' ELSE N'Otro' END AS TipoRepeticionDiaria,
    s.freq_subday_interval AS CadaNMinutos,
    STUFF(STUFF(RIGHT('000000' + CAST(s.active_start_time AS VARCHAR(6)), 6), 5, 0, ':'), 3, 0, ':') AS HoraInicio,
    msdb.dbo.agent_datetime(NULLIF(js.next_run_date, 0), js.next_run_time) AS ProximaEjecucion
FROM dbo.sysjobs AS j
JOIN dbo.sysjobschedules AS js ON js.job_id = j.job_id
JOIN dbo.sysschedules AS s ON s.schedule_id = js.schedule_id
WHERE j.name LIKE N'Backup%'
ORDER BY j.name;
GO

SELECT
    j.name AS Job,
    msdb.dbo.agent_datetime(h.run_date, h.run_time) AS Ejecucion,
    STUFF(STUFF(RIGHT('000000' + CAST(h.run_duration AS VARCHAR(6)), 6), 5, 0, ':'), 3, 0, ':') AS Duracion,
    CASE h.run_status WHEN 0 THEN N'Fallido' WHEN 1 THEN N'Correcto' WHEN 2 THEN N'Reintento' WHEN 3 THEN N'Cancelado' END AS Estado,
    h.message AS Mensaje
FROM dbo.sysjobhistory AS h
JOIN dbo.sysjobs AS j ON j.job_id = h.job_id
WHERE j.name LIKE N'Backup%' AND h.step_id = 0
ORDER BY Ejecucion DESC;
GO

SELECT
    CASE bs.type WHEN 'D' THEN N'Full' WHEN 'I' THEN N'Diferencial' WHEN 'L' THEN N'Log' END AS Tipo,
    bs.backup_start_date AS Inicio,
    DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) AS Segundos,
    CAST(bs.backup_size / 1048576.0 AS DECIMAL(12, 2)) AS TamanoMB,
    CAST(bs.compressed_backup_size / 1048576.0 AS DECIMAL(12, 2)) AS ComprimidoMB,
    bs.has_backup_checksums AS ConChecksum,
    bs.is_damaged AS Danado,
    mf.physical_device_name AS Archivo
FROM dbo.backupset AS bs
JOIN dbo.backupmediafamily AS mf ON mf.media_set_id = bs.media_set_id
WHERE bs.database_name = N'HospitalDB'
ORDER BY bs.backup_start_date DESC;
GO

SELECT
    CASE type WHEN 'D' THEN N'Full' WHEN 'I' THEN N'Diferencial' WHEN 'L' THEN N'Log' END AS Tipo,
    COUNT(*) AS Cantidad,
    CAST(AVG(compressed_backup_size) / 1048576.0 AS DECIMAL(12, 3)) AS PromedioComprimidoMB,
    CAST(SUM(compressed_backup_size) / 1048576.0 AS DECIMAL(12, 3)) AS TotalComprimidoMB
FROM dbo.backupset
WHERE database_name = N'HospitalDB'
GROUP BY type
ORDER BY Tipo;
GO

SELECT
    rh.restore_date AS FechaRestauracion,
    rh.destination_database_name AS BaseDestino,
    CASE rh.restore_type WHEN 'D' THEN N'Full' WHEN 'I' THEN N'Diferencial' WHEN 'L' THEN N'Log' ELSE rh.restore_type END AS Tipo,
    bs.backup_start_date AS BackupOrigen
FROM dbo.restorehistory AS rh
JOIN dbo.backupset AS bs ON bs.backup_set_id = rh.backup_set_id
WHERE rh.destination_database_name = N'HospitalDB_Restore'
ORDER BY rh.restore_history_id DESC;
GO

SELECT
    bs.database_name AS BaseDeDatos,
    bs.backup_start_date AS Inicio,
    CAST(bs.compressed_backup_size / 1048576.0 AS DECIMAL(12, 2)) AS ComprimidoMB,
    bs.has_backup_checksums AS ConChecksum,
    bs.is_damaged AS Danado,
    mf.physical_device_name AS Archivo
FROM dbo.backupset AS bs
JOIN dbo.backupmediafamily AS mf ON mf.media_set_id = bs.media_set_id
WHERE bs.database_name IN (N'master', N'msdb') AND bs.type = 'D'
ORDER BY bs.backup_start_date DESC;
GO

USE HospitalDB;
GO

EXEC dbo.usp_VerificarBackups @MinutosMaxLog = 30, @DiasMaxFull = 8;
GO