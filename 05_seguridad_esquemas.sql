-- =========================================================
-- 1. AUDITORIA A NIVEL DE SERVIDOR
-- =========================================================
USE master;
GO
CREATE SERVER AUDIT Auditoria_Hospital
TO FILE (FILEPATH = '/var/opt/mssql/audit/')
WITH (ON_FAILURE = CONTINUE);
GO
ALTER SERVER AUDIT Auditoria_Hospital WITH (STATE = ON);
GO

-- =========================================================
-- 2. ESPECIFICACION DE AUDITORIA DE BASE DE DATOS
-- =========================================================
USE HospitalDB;
GO
CREATE DATABASE AUDIT SPECIFICATION Auditoria_TablasSensibles
FOR SERVER AUDIT Auditoria_Hospital
    ADD (SELECT, INSERT, UPDATE, DELETE ON clinico.Pacientes       BY public),
    ADD (SELECT, INSERT, UPDATE, DELETE ON clinico.Tratamientos    BY public),
    ADD (SELECT, INSERT, UPDATE, DELETE ON facturacion.Facturacion BY public)
WITH (STATE = ON);
GO

-- =========================================================
-- 3. CONSULTA PARA REVISAR EL LOG GENERADO (evidencia)
-- =========================================================
    SELECT event_time, server_principal_name, database_name,
           schema_name, object_name, statement, succeeded
    FROM sys.fn_get_audit_file('/var/opt/mssql/audit/*.sqlaudit', DEFAULT, DEFAULT)
    ORDER BY event_time DESC;