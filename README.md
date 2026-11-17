# Proyecto ADB — HospitalDB

Repositorio del proyecto de Administración de Bases de Datos (**ADB**), centrado en el diseño, implementación, optimización, seguridad, auditoría, respaldos/restauración y visualización de datos para la base de datos **`HospitalDB`** en **SQL Server** y **Power BI**.

---

## Información general del proyecto

- **Base de datos:** `HospitalDB`
- **Motor:** Microsoft SQL Server (T-SQL, `COMPATIBILITY_LEVEL = 170`, modelo de recuperación `FULL`, `QUERY_STORE = ON`)
- **Esquemas:**
  - `clinico`: `Pacientes`, `Medicos`, `Citas`, `Tratamientos`
  - `facturacion`: `Facturacion`
- **Seguridad (Mínimo Privilegio):**
  - Roles operativos: `rol_recepcion`, `rol_medico`, `rol_facturacion`, `rol_auditor`, `rol_consulta` (para Power BI).
  - Roles administrativos / equipo (`db_owner` y `rol_admin_hospital`): `Pablo`, `Moises`, `Jorge`, `Flavio`, `Diego`, `Cesar`.
- **Visualización:** 2 tableros en Power BI Desktop (`.pbix`).

---

## Estructura del repositorio

El proyecto está organizado en cuatro carpetas principales, con scripts SQL numerados secuencialmente (`01` al `11`) para facilitar su ejecución y revisión:

```text
Proyecto ADB/
├── Configuración inicial/
│   ├── 01_HospitalDB_Schema.sql
│   └── 02_HospitalDB_Data.sql
├── Consultas e índices/
│   ├── 03_HospitalDB_Queries.sql
│   └── 04_HospitalDB_Indexes.sql
├── Esquemas, seguridad y auditoría/
│   ├── 05_seguridad_esquemas.sql
│   ├── 06_auditoria.sql
│   ├── 07_HospitalDB_Backup.sql
│   ├── 08_HospitalDB_AgentJobs.sql
│   ├── 09_HospitalDB_Restore.sql
│   ├── 10_HospitalDB_BackupEvidence.sql
│   └── 11_HospitalDB_restorecheck.sql
├── Dashboards/
│   ├── Dashboard-Hospital.pbix
│   └── Dashboard de consultas.pbix
└── .gitattributes
```

### 1. `Configuración inicial/`
Contiene la definición estructural y los datos iniciales de la base de datos:
- **`01_HospitalDB_Schema.sql`**: Crea la base de datos `HospitalDB` (con rutas de archivos en `/var/opt/mssql/data/`), los *logins* a nivel de servidor, usuarios y roles de base de datos, los esquemas `clinico` y `facturacion`, las 5 tablas con sus llaves primarias, foráneas y restricciones (`CHECK`, `UNIQUE`, `DEFAULT`), índices iniciales y los permisos por rol.
- **`02_HospitalDB_Data.sql`**: Inserta los registros de prueba en `clinico.Pacientes`, `clinico.Medicos`, `clinico.Citas`, `facturacion.Facturacion` y `clinico.Tratamientos`.

### 2. `Consultas e índices/`
Contiene las consultas analíticas y su estrategia de indexación:
- **`03_HospitalDB_Queries.sql`**: Incluye 3 consultas analíticas con funciones de ventana (`RANK()`, `SUM() OVER (...)`, `DENSE_RANK()`, `COUNT(*) OVER ()`) y medición de rendimiento (`SET STATISTICS TIME ON` y `SET STATISTICS IO ON`):
  1. Ranking de médicos por citas completadas por especialidad.
  2. Acumulado mensual de facturación por paciente (*Running Total*).
  3. Análisis de frecuencia de citas por motivo de consulta (impacto porcentual y porcentaje acumulado tipo Pareto).
  *(También crea de forma idempotente el índice `IX_Citas_Motivo_PacienteID` si aún no existe).*
- **`04_HospitalDB_Indexes.sql`**: Script dedicado con la definición de los 4 índices `NONCLUSTERED` (`IX_Citas_Estado_MedicoID`, `IX_Facturacion_RunningTotal`, `IX_Citas_Motivo_PacienteID` y `IX_Medicos_Especialidad`) utilizados para optimizar las consultas.

### 3. `Esquemas, seguridad y auditoría/`
Agrupa la administración avanzada de la base de datos (seguridad, auditoría, respaldos automatizados y pruebas de recuperación):
- **`05_seguridad_esquemas.sql`**: Script idempotente para crear los esquemas `clinico` y `facturacion`, transferir tablas desde `dbo` si es necesario, crear *logins*, usuarios y roles, y aplicar permisos con `GRANT` y `DENY` explícitos bajo el principio de mínimo privilegio.
- **`06_auditoria.sql`**: Configura la auditoría a nivel de servidor (`Auditoria_Hospital`, almacenando archivos `.sqlaudit` en `/var/opt/mssql/audit/`) y la especificación de auditoría de base de datos (`Auditoria_TablasSensibles`) sobre `clinico.Pacientes`, `clinico.Tratamientos` y `facturacion.Facturacion`, además de la consulta de lectura con `sys.fn_get_audit_file`.
- **`07_HospitalDB_Backup.sql`**: Activa el modelo `RECOVERY FULL`, crea las carpetas `/var/opt/mssql/backup/HospitalDB/` y `/var/opt/mssql/backup/Sistema/`, y define los procedimientos almacenados `dbo.usp_BackupHospitalDB` (respaldos `FULL`, `DIFF` y `LOG` con `CHECKSUM`, `COMPRESSION` y `RESTORE VERIFYONLY`), `dbo.usp_VerificarBackups` y `dbo.usp_BackupSistema` (respaldo de `master` y `msdb`). Al final ejecuta un respaldo inicial completo y de sistema.
- **`08_HospitalDB_AgentJobs.sql`**: Registra en `msdb` 5 *jobs* de SQL Server Agent:
  - `Backup_Full` (semanal, domingos 01:00)
  - `Backup_Diff` (lunes a sábado 01:00)
  - `Backup_Log` (cada 15 minutos)
  - `Backup_Monitor` (cada 30 minutos desde las 00:05)
  - `Backup_Sistema` (domingos 02:00)
  Además inicia manualmente `Backup_Full` y `Backup_Sistema`.
- **`09_HospitalDB_Restore.sql`**: Realiza un respaldo de *tail-log* (`WITH NO_TRUNCATE`), arma dinámicamente la secuencia de restauración (`FULL` + `DIFF` + `LOG`s) hacia la base de prueba `HospitalDB_Restore`, mide el tiempo total de restauración, ejecuta `DBCC CHECKDB (HospitalDB_Restore)` y compara el conteo de registros entre `HospitalDB` y `HospitalDB_Restore`.
- **`10_HospitalDB_BackupEvidence.sql`**: Consultas de auditoría y evidencia sobre `msdb` y `HospitalDB` (modelo de recuperación, horarios e historial de *jobs*, tamaño y estado de respaldos, historial de restauraciones, respaldos de `master`/`msdb` y ejecución de `dbo.usp_VerificarBackups`).
- **`11_HospitalDB_restorecheck.sql`**: Script de verificación posterior a la restauración (estado de bases de datos, `DBCC CHECKDB`, comparación de conteos por tabla y validación de registro de prueba).

### 4. `Dashboards/`
Contiene los reportes visuales desarrollados en Power BI:
- **`Dashboard-Hospital.pbix`**: Tablero general de indicadores del hospital.
- **`Dashboard de consultas.pbix`**: Tablero enfocado en el análisis de consultas médicas.

---

## Cómo utilizar el repositorio

### Requisitos previos
1. **Microsoft SQL Server** (los scripts utilizan rutas de Linux/Docker como `/var/opt/mssql/...` y `COMPATIBILITY_LEVEL = 170`; si se ejecuta en Windows o en una versión anterior de SQL Server, se deben ajustar las rutas de archivos y el nivel de compatibilidad).
2. **SQL Server Agent** habilitado (necesario para el script `08_HospitalDB_AgentJobs.sql`).
3. **Power BI Desktop** para abrir y visualizar los archivos `.pbix` de la carpeta `Dashboards/`.

### Orden de ejecución recomendado
Ejecutar los scripts `.sql` en SQL Server Management Studio (SSMS) siguiendo la numeración:

1. `Configuración inicial/01_HospitalDB_Schema.sql`
2. `Configuración inicial/02_HospitalDB_Data.sql`
3. `Consultas e índices/03_HospitalDB_Queries.sql` *(Nota: los índices de `04_HospitalDB_Indexes.sql` ya están incluidos entre `01_HospitalDB_Schema.sql` y `03_HospitalDB_Queries.sql`; usar `04_HospitalDB_Indexes.sql` si se parte de un esquema sin índices).*
4. `Esquemas, seguridad y auditoría/05_seguridad_esquemas.sql`
5. `Esquemas, seguridad y auditoría/06_auditoria.sql`
6. `Esquemas, seguridad y auditoría/07_HospitalDB_Backup.sql`
7. `Esquemas, seguridad y auditoría/08_HospitalDB_AgentJobs.sql`
8. `Esquemas, seguridad y auditoría/09_HospitalDB_Restore.sql`
9. `Esquemas, seguridad y auditoría/10_HospitalDB_BackupEvidence.sql`
10. `Esquemas, seguridad y auditoría/11_HospitalDB_restorecheck.sql`

Para revisar los tableros, abrir los archivos dentro de `Dashboards/` con **Power BI Desktop** (para conexión a datos, el usuario `powerbi` cuenta con permisos de solo lectura mediante `rol_consulta`).
