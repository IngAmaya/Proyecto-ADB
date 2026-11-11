USE HospitalDB;
GO

-- =========================================================
-- Índice 1: Optimización de la Consulta 1 (Citas por Estado y Médico)
-- =========================================================
CREATE NONCLUSTERED INDEX IX_Citas_Estado_MedicoID
ON clinico.Citas (Estado, MedicoID)
INCLUDE (CitaID);

-- =========================================================
-- Índice 2: Optimización de la Consulta 2 (Running Total en Facturación)
-- =========================================================
CREATE NONCLUSTERED INDEX IX_Facturacion_RunningTotal
ON facturacion.Facturacion (PacienteID, FechaEmision, EstadoPago)
INCLUDE (MontoTotal);

-- =========================================================
-- Índice 3: Optimización de la Consulta 3 (Frecuencia de Citas por Motivo)
-- =========================================================
CREATE NONCLUSTERED INDEX IX_Citas_Motivo_PacienteID
ON clinico.Citas (Motivo)
INCLUDE (PacienteID);

-- =========================================================
-- Índice adicional: Optimización de búsqueda de Médicos por Especialidad
-- =========================================================
CREATE NONCLUSTERED INDEX IX_Medicos_Especialidad
ON clinico.Medicos (Especialidad)
INCLUDE (MedicoID, Nombre, Apellido);