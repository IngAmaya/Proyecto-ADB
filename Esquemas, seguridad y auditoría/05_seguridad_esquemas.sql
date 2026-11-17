USE HospitalDB;
GO

-- =========================================================
-- 1. ESQUEMAS (seguro de volver a ejecutar)
-- =========================================================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'clinico')
    EXEC('CREATE SCHEMA clinico AUTHORIZATION dbo');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'facturacion')
    EXEC('CREATE SCHEMA facturacion AUTHORIZATION dbo');
GO

-- Solo mueve la tabla si todavía está en dbo (si ya se movió, no hace nada)
IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'dbo' AND t.name = 'Pacientes')
    EXEC('ALTER SCHEMA clinico TRANSFER dbo.Pacientes');
IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'dbo' AND t.name = 'Medicos')
    EXEC('ALTER SCHEMA clinico TRANSFER dbo.Medicos');
IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'dbo' AND t.name = 'Citas')
    EXEC('ALTER SCHEMA clinico TRANSFER dbo.Citas');
IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'dbo' AND t.name = 'Tratamientos')
    EXEC('ALTER SCHEMA clinico TRANSFER dbo.Tratamientos');
IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'dbo' AND t.name = 'Facturacion')
    EXEC('ALTER SCHEMA facturacion TRANSFER dbo.Facturacion');
GO

-- =========================================================
-- 2. LOGINS (nivel servidor, seguro de volver a ejecutar)
-- =========================================================
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_medico1')
    CREATE LOGIN login_medico1 WITH PASSWORD = 'Cambiar#2026!';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_recepcion1')
    CREATE LOGIN login_recepcion1 WITH PASSWORD = 'Cambiar#2026!';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_facturacion1')
    CREATE LOGIN login_facturacion1 WITH PASSWORD = 'Cambiar#2026!';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_auditor1')
    CREATE LOGIN login_auditor1 WITH PASSWORD = 'Cambiar#2026!';
GO

-- =========================================================
-- 3. USUARIOS (nivel base de datos, seguro de volver a ejecutar)
-- =========================================================
USE HospitalDB;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_medico1')
    CREATE USER usr_medico1 FOR LOGIN login_medico1;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_recepcion1')
    CREATE USER usr_recepcion1 FOR LOGIN login_recepcion1;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_facturacion1')
    CREATE USER usr_facturacion1 FOR LOGIN login_facturacion1;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_auditor1')
    CREATE USER usr_auditor1 FOR LOGIN login_auditor1;
GO

-- =========================================================
-- 4. ROLES (seguro de volver a ejecutar)
-- =========================================================
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_medico')
    CREATE ROLE rol_medico;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_recepcion')
    CREATE ROLE rol_recepcion;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_facturacion')
    CREATE ROLE rol_facturacion;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_auditor')
    CREATE ROLE rol_auditor;
GO

-- =========================================================
-- 5. PERMISOS (minimo privilegio, DENY explicito)
-- GRANT/DENY son idempotentes: se pueden repetir sin error.
-- =========================================================
-- Medico: lectura/escritura clinica, nada de facturacion
GRANT SELECT, INSERT, UPDATE ON SCHEMA::clinico TO rol_medico;
DENY  SELECT, INSERT, UPDATE, DELETE ON SCHEMA::facturacion TO rol_medico;

-- Recepcion: solo agenda, nada de tratamientos ni facturacion
GRANT SELECT, INSERT, UPDATE ON OBJECT::clinico.Citas     TO rol_recepcion;
GRANT SELECT                 ON OBJECT::clinico.Pacientes TO rol_recepcion;
GRANT SELECT                 ON OBJECT::clinico.Medicos   TO rol_recepcion;
DENY  SELECT ON OBJECT::clinico.Tratamientos TO rol_recepcion;
DENY  SELECT, INSERT, UPDATE, DELETE ON SCHEMA::facturacion TO rol_recepcion;

-- Facturacion: lectura/escritura en facturacion, lectura minima de pacientes
GRANT SELECT, INSERT, UPDATE ON SCHEMA::facturacion TO rol_facturacion;
GRANT SELECT ON OBJECT::clinico.Pacientes TO rol_facturacion;
DENY  SELECT ON OBJECT::clinico.Tratamientos TO rol_facturacion;

-- Auditor: solo lectura, todo
GRANT SELECT ON SCHEMA::clinico     TO rol_auditor;
GRANT SELECT ON SCHEMA::facturacion TO rol_auditor;
GO

-- =========================================================
-- 6. ASIGNACION DE USUARIOS A ROLES (seguro de volver a ejecutar)
-- =========================================================
IF IS_ROLEMEMBER('rol_medico', 'usr_medico1') = 0
    ALTER ROLE rol_medico ADD MEMBER usr_medico1;
IF IS_ROLEMEMBER('rol_recepcion', 'usr_recepcion1') = 0
    ALTER ROLE rol_recepcion ADD MEMBER usr_recepcion1;
IF IS_ROLEMEMBER('rol_facturacion', 'usr_facturacion1') = 0
    ALTER ROLE rol_facturacion ADD MEMBER usr_facturacion1;
IF IS_ROLEMEMBER('rol_auditor', 'usr_auditor1') = 0
    ALTER ROLE rol_auditor ADD MEMBER usr_auditor1;
GO