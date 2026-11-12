USE msdb;
GO

IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = N'Backup_Full')
    EXEC dbo.sp_delete_job @job_name = N'Backup_Full', @delete_unused_schedule = 1;
GO

EXEC dbo.sp_add_job
    @job_name = N'Backup_Full',
    @enabled = 1,
    @description = N'Backup completo semanal de HospitalDB',
    @category_name = N'Database Maintenance',
    @notify_level_eventlog = 2;

EXEC dbo.sp_add_jobstep
    @job_name = N'Backup_Full',
    @step_name = N'Ejecutar backup completo',
    @subsystem = N'TSQL',
    @database_name = N'HospitalDB',
    @command = N'EXEC dbo.usp_BackupHospitalDB @Tipo = ''FULL'';',
    @on_success_action = 1,
    @on_fail_action = 2;

EXEC dbo.sp_add_jobschedule
    @job_name = N'Backup_Full',
    @name = N'Domingo 01:00',
    @enabled = 1,
    @freq_type = 8,
    @freq_interval = 1,
    @freq_recurrence_factor = 1,
    @active_start_time = 10000;

EXEC dbo.sp_add_jobserver @job_name = N'Backup_Full', @server_name = N'(LOCAL)';
GO

IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = N'Backup_Diff')
    EXEC dbo.sp_delete_job @job_name = N'Backup_Diff', @delete_unused_schedule = 1;
GO

EXEC dbo.sp_add_job
    @job_name = N'Backup_Diff',
    @enabled = 1,
    @description = N'Backup diferencial diario de HospitalDB (lunes a sabado)',
    @category_name = N'Database Maintenance',
    @notify_level_eventlog = 2;

EXEC dbo.sp_add_jobstep
    @job_name = N'Backup_Diff',
    @step_name = N'Ejecutar backup diferencial',
    @subsystem = N'TSQL',
    @database_name = N'HospitalDB',
    @command = N'EXEC dbo.usp_BackupHospitalDB @Tipo = ''DIFF'';',
    @on_success_action = 1,
    @on_fail_action = 2;

EXEC dbo.sp_add_jobschedule
    @job_name = N'Backup_Diff',
    @name = N'Lunes a sabado 01:00',
    @enabled = 1,
    @freq_type = 8,
    @freq_interval = 126,
    @freq_recurrence_factor = 1,
    @active_start_time = 10000;

EXEC dbo.sp_add_jobserver @job_name = N'Backup_Diff', @server_name = N'(LOCAL)';
GO

IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = N'Backup_Log')
    EXEC dbo.sp_delete_job @job_name = N'Backup_Log', @delete_unused_schedule = 1;
GO

EXEC dbo.sp_add_job
    @job_name = N'Backup_Log',
    @enabled = 1,
    @description = N'Backup del log de transacciones de HospitalDB cada 15 minutos',
    @category_name = N'Database Maintenance',
    @notify_level_eventlog = 2;

EXEC dbo.sp_add_jobstep
    @job_name = N'Backup_Log',
    @step_name = N'Ejecutar backup de log',
    @subsystem = N'TSQL',
    @database_name = N'HospitalDB',
    @command = N'EXEC dbo.usp_BackupHospitalDB @Tipo = ''LOG'';',
    @on_success_action = 1,
    @on_fail_action = 2;

EXEC dbo.sp_add_jobschedule
    @job_name = N'Backup_Log',
    @name = N'Cada 15 minutos',
    @enabled = 1,
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 4,
    @freq_subday_interval = 15,
    @active_start_time = 0;

EXEC dbo.sp_add_jobserver @job_name = N'Backup_Log', @server_name = N'(LOCAL)';
GO

IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = N'Backup_Monitor')
    EXEC dbo.sp_delete_job @job_name = N'Backup_Monitor', @delete_unused_schedule = 1;
GO

EXEC dbo.sp_add_job
    @job_name = N'Backup_Monitor',
    @enabled = 1,
    @description = N'Verifica que los backups de HospitalDB existan, sean recientes y no esten danados',
    @category_name = N'Database Maintenance',
    @notify_level_eventlog = 2;

EXEC dbo.sp_add_jobstep
    @job_name = N'Backup_Monitor',
    @step_name = N'Verificar backups en msdb',
    @subsystem = N'TSQL',
    @database_name = N'HospitalDB',
    @command = N'EXEC dbo.usp_VerificarBackups @MinutosMaxLog = 30, @DiasMaxFull = 8;',
    @on_success_action = 1,
    @on_fail_action = 2;

EXEC dbo.sp_add_jobschedule
    @job_name = N'Backup_Monitor',
    @name = N'Cada 30 minutos desde 00:05',
    @enabled = 1,
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 4,
    @freq_subday_interval = 30,
    @active_start_time = 500;

EXEC dbo.sp_add_jobserver @job_name = N'Backup_Monitor', @server_name = N'(LOCAL)';
GO

IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = N'Backup_Sistema')
    EXEC dbo.sp_delete_job @job_name = N'Backup_Sistema', @delete_unused_schedule = 1;
GO

EXEC dbo.sp_add_job
    @job_name = N'Backup_Sistema',
    @enabled = 1,
    @description = N'Backup completo semanal de master y msdb',
    @category_name = N'Database Maintenance',
    @notify_level_eventlog = 2;

EXEC dbo.sp_add_jobstep
    @job_name = N'Backup_Sistema',
    @step_name = N'Backup de master y msdb',
    @subsystem = N'TSQL',
    @database_name = N'HospitalDB',
    @command = N'EXEC dbo.usp_BackupSistema;',
    @on_success_action = 1,
    @on_fail_action = 2;

EXEC dbo.sp_add_jobschedule
    @job_name = N'Backup_Sistema',
    @name = N'Domingo 02:00',
    @enabled = 1,
    @freq_type = 8,
    @freq_interval = 1,
    @freq_recurrence_factor = 1,
    @active_start_time = 20000;

EXEC dbo.sp_add_jobserver @job_name = N'Backup_Sistema', @server_name = N'(LOCAL)';
GO

EXEC dbo.sp_start_job @job_name = N'Backup_Full';
GO

EXEC dbo.sp_start_job @job_name = N'Backup_Sistema';
GO