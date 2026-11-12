USE master;
GO

SELECT name AS BaseDeDatos, state_desc AS Estado
FROM sys.databases
WHERE name IN (N'HospitalDB', N'HospitalDB_Restore');
GO

DBCC CHECKDB (HospitalDB_Restore) WITH NO_INFOMSGS;
GO

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

SELECT PacienteID, Nombre, Apellido
FROM HospitalDB_Restore.clinico.Pacientes
WHERE Nombre = N'Prueba'
ORDER BY PacienteID;
GO