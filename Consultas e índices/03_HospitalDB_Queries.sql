USE [HospitalDB]
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

/* ==========================================================================================
   ÍNDICE ADICIONAL DOCUMENTADO EN EL INFORME PARA LA CONSULTA 3
   (Se crea de forma idempotente en caso de no existir aún en la base de datos)
   ========================================================================================== */
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = N'IX_Citas_Motivo_PacienteID' 
      AND object_id = OBJECT_ID(N'[clinico].[Citas]')
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Citas_Motivo_PacienteID]
    ON [clinico].[Citas] ([Motivo] ASC)
    INCLUDE ([PacienteID]);
END
GO

/* ==========================================================================================
   Consulta 1 — Ranking de médicos por citas completadas por especialidad
   ------------------------------------------------------------------------------------------
   Objetivo: Identificar y clasificar a los médicos según su carga de trabajo dentro de cada
   especialidad, determinando cuál tiene mayor número de citas completadas.
   Tablas involucradas: clinico.Medicos, clinico.Citas
   Función de ventana utilizada: RANK() OVER (PARTITION BY ... ORDER BY ...)
   Índices utilizados: IX_Citas_Estado_MedicoID, IX_Medicos_Especialidad
   ========================================================================================== */
SELECT
    M.MedicoID,
    M.Nombre + ' ' + M.Apellido AS NombreMedico,
    M.Especialidad,
    COUNT(C.CitaID)             AS TotalCitas,
    RANK() OVER (
        PARTITION BY M.Especialidad
        ORDER BY COUNT(C.CitaID) DESC
    )                           AS RankingPorEspecialidad
FROM clinico.Medicos M
JOIN clinico.Citas C ON M.MedicoID = C.MedicoID
WHERE C.Estado = 'Completada'
GROUP BY M.MedicoID, M.Nombre, M.Apellido, M.Especialidad;
GO

/* ==========================================================================================
   Consulta 2 — Acumulado mensual de facturación por paciente (Running Total)
   ------------------------------------------------------------------------------------------
   Objetivo: Calcular el total acumulado de pagos realizados por cada paciente a lo largo del
   tiempo, filtrando únicamente las facturas con estado 'Pagado'.
   Tablas involucradas: facturacion.Facturacion, clinico.Pacientes
   Función de ventana utilizada: SUM() OVER (PARTITION BY ... ORDER BY ... ROWS BETWEEN ...)
   Índices utilizados: IX_Facturacion_RunningTotal / IX_Facturacion_PacienteID_Fecha
   ========================================================================================== */
SELECT
    P.PacienteID,
    P.Nombre + ' ' + P.Apellido          AS NombrePaciente,
    FORMAT(F.FechaEmision, 'yyyy-MM')    AS Mes,
    F.MontoTotal,
    SUM(F.MontoTotal) OVER (
        PARTITION BY F.PacienteID
        ORDER BY F.FechaEmision
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                    AS MontoAcumulado
FROM facturacion.Facturacion F
JOIN clinico.Pacientes P ON F.PacienteID = P.PacienteID
WHERE F.EstadoPago = 'Pagado'
ORDER BY F.PacienteID, F.FechaEmision;
GO

/* ==========================================================================================
   Consulta 3 — Análisis de frecuencia de citas por motivo de consulta
   ------------------------------------------------------------------------------------------
   Objetivo: Determinar cuáles son los motivos de consulta más recurrentes en el hospital
   para identificar patrones de morbilidad o demanda de atención, calculando simultáneamente
   el impacto porcentual de cada motivo y su porcentaje acumulado (análisis tipo Pareto).
   Tablas involucradas: clinico.Citas
   Funciones de ventana utilizadas:
     - COUNT(*) OVER ()
     - DENSE_RANK() OVER (ORDER BY COUNT(*) DESC)
     - SUM(COUNT(*)) OVER (ORDER BY COUNT(*) DESC, C.Motivo ROWS UNBOUNDED PRECEDING)
   Índice utilizado: IX_Citas_Motivo_PacienteID
   ========================================================================================== */
SELECT
    C.Motivo AS MotivoConsulta,
    COUNT(*) AS TotalCitas,
    COUNT(DISTINCT C.PacienteID) AS PacientesAfectados,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS RankingFrecuencia,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS PorcentajeDelTotal,
    CAST(100.0 * SUM(COUNT(*)) OVER (
        ORDER BY COUNT(*) DESC, C.Motivo
        ROWS UNBOUNDED PRECEDING
    ) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS PorcentajeAcumulado
FROM clinico.Citas C
GROUP BY C.Motivo
ORDER BY RankingFrecuencia, C.Motivo;
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO
