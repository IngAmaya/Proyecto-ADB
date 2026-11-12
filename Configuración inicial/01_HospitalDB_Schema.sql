USE [master]
GO
/****** Objeto: Database [HospitalDB] Fecha de script: 11/10/2026 2:29:42 PM ******/
CREATE DATABASE [HospitalDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'HospitalDB_dat', FILENAME = N'/var/opt/mssql/data/HospitalDB.mdf' , SIZE = 204800KB , MAXSIZE = UNLIMITED, FILEGROWTH = 102400KB )
 LOG ON 
( NAME = N'HospitalDB_log', FILENAME = N'/var/opt/mssql/data/HospitalDB.ldf' , SIZE = 102400KB , MAXSIZE = 2048GB , FILEGROWTH = 51200KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [HospitalDB] SET COMPATIBILITY_LEVEL = 170
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [HospitalDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [HospitalDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [HospitalDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [HospitalDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [HospitalDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [HospitalDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [HospitalDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [HospitalDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [HospitalDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [HospitalDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [HospitalDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [HospitalDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [HospitalDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [HospitalDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [HospitalDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [HospitalDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [HospitalDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [HospitalDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [HospitalDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [HospitalDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [HospitalDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [HospitalDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [HospitalDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [HospitalDB] SET RECOVERY FULL 
GO
ALTER DATABASE [HospitalDB] SET  MULTI_USER 
GO
ALTER DATABASE [HospitalDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [HospitalDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [HospitalDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [HospitalDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [HospitalDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [HospitalDB] SET OPTIMIZED_LOCKING = OFF 
GO
ALTER DATABASE [HospitalDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'HospitalDB', N'ON'
GO
ALTER DATABASE [HospitalDB] SET QUERY_STORE = ON
GO
ALTER DATABASE [HospitalDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [master]
GO
/****** Creación de Inicios de Sesión (Logins) para Contenedor Limpio ******/
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_recepcion1')
    CREATE LOGIN [login_recepcion1] WITH PASSWORD = N'Hospital2025!', CHECK_POLICY = OFF
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_medico1')
    CREATE LOGIN [login_medico1] WITH PASSWORD = N'Hospital2025!', CHECK_POLICY = OFF
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_facturacion1')
    CREATE LOGIN [login_facturacion1] WITH PASSWORD = N'Hospital2025!', CHECK_POLICY = OFF
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_auditor1')
    CREATE LOGIN [login_auditor1] WITH PASSWORD = N'Hospital2025!', CHECK_POLICY = OFF
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'powerbi')
    CREATE LOGIN [powerbi] WITH PASSWORD = N'Hospital2025!', CHECK_POLICY = OFF
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'Pablo')
    CREATE LOGIN [Pablo] WITH PASSWORD = N'Hospital2025!', CHECK_POLICY = OFF
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'Moises')
    CREATE LOGIN [Moises] WITH PASSWORD = N'Hospital2025!', CHECK_POLICY = OFF
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'Jorge')
    CREATE LOGIN [Jorge] WITH PASSWORD = N'Hospital2025!', CHECK_POLICY = OFF
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'Flavio')
    CREATE LOGIN [Flavio] WITH PASSWORD = N'Hospital2025!', CHECK_POLICY = OFF
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'Diego')
    CREATE LOGIN [Diego] WITH PASSWORD = N'Hospital2025!', CHECK_POLICY = OFF
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'Cesar')
    CREATE LOGIN [Cesar] WITH PASSWORD = N'Hospital2025!', CHECK_POLICY = OFF
GO
USE [HospitalDB]
GO
/****** Objeto: User [usr_recepcion1] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE USER [usr_recepcion1] FOR LOGIN [login_recepcion1] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Objeto: User [usr_medico1] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE USER [usr_medico1] FOR LOGIN [login_medico1] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Objeto: User [usr_facturacion1] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE USER [usr_facturacion1] FOR LOGIN [login_facturacion1] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Objeto: User [usr_auditor1] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE USER [usr_auditor1] FOR LOGIN [login_auditor1] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Objeto: User [powerbi] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE USER [powerbi] FOR LOGIN [powerbi] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Objeto: User [Pablo] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE USER [Pablo] FOR LOGIN [Pablo] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Objeto: User [Moises] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE USER [Moises] FOR LOGIN [Moises] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Objeto: User [Jorge] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE USER [Jorge] FOR LOGIN [Jorge] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Objeto: User [Flavio] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE USER [Flavio] FOR LOGIN [Flavio] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Objeto: User [Diego] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE USER [Diego] FOR LOGIN [Diego] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Objeto: User [Cesar] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE USER [Cesar] FOR LOGIN [Cesar] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Objeto: DatabaseRole [rol_recepcion] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE ROLE [rol_recepcion]
GO
/****** Objeto: DatabaseRole [rol_medico] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE ROLE [rol_medico]
GO
/****** Objeto: DatabaseRole [rol_facturacion] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE ROLE [rol_facturacion]
GO
/****** Objeto: DatabaseRole [rol_equipo] Fecha de script: 11/10/2026 2:29:44 PM ******/
CREATE ROLE [rol_equipo]
GO
/****** Objeto: DatabaseRole [rol_consulta] Fecha de script: 11/10/2026 2:29:45 PM ******/
CREATE ROLE [rol_consulta]
GO
/****** Objeto: DatabaseRole [rol_auditor] Fecha de script: 11/10/2026 2:29:45 PM ******/
CREATE ROLE [rol_auditor]
GO
/****** Objeto: DatabaseRole [rol_admin_hospital] Fecha de script: 11/10/2026 2:29:45 PM ******/
CREATE ROLE [rol_admin_hospital]
GO
ALTER ROLE [rol_recepcion] ADD MEMBER [usr_recepcion1]
GO
ALTER ROLE [rol_medico] ADD MEMBER [usr_medico1]
GO
ALTER ROLE [rol_facturacion] ADD MEMBER [usr_facturacion1]
GO
ALTER ROLE [rol_auditor] ADD MEMBER [usr_auditor1]
GO
ALTER ROLE [rol_consulta] ADD MEMBER [powerbi]
GO
ALTER ROLE [rol_equipo] ADD MEMBER [Pablo]
GO
ALTER ROLE [rol_admin_hospital] ADD MEMBER [Pablo]
GO
ALTER ROLE [db_owner] ADD MEMBER [Pablo]
GO
ALTER ROLE [rol_equipo] ADD MEMBER [Moises]
GO
ALTER ROLE [rol_admin_hospital] ADD MEMBER [Moises]
GO
ALTER ROLE [db_owner] ADD MEMBER [Moises]
GO
ALTER ROLE [rol_equipo] ADD MEMBER [Jorge]
GO
ALTER ROLE [rol_admin_hospital] ADD MEMBER [Jorge]
GO
ALTER ROLE [db_owner] ADD MEMBER [Jorge]
GO
ALTER ROLE [rol_equipo] ADD MEMBER [Flavio]
GO
ALTER ROLE [rol_admin_hospital] ADD MEMBER [Flavio]
GO
ALTER ROLE [db_owner] ADD MEMBER [Flavio]
GO
ALTER ROLE [rol_equipo] ADD MEMBER [Diego]
GO
ALTER ROLE [rol_admin_hospital] ADD MEMBER [Diego]
GO
ALTER ROLE [db_owner] ADD MEMBER [Diego]
GO
ALTER ROLE [rol_equipo] ADD MEMBER [Cesar]
GO
ALTER ROLE [rol_admin_hospital] ADD MEMBER [Cesar]
GO
ALTER ROLE [db_owner] ADD MEMBER [Cesar]
GO
ALTER ROLE [db_owner] ADD MEMBER [rol_admin_hospital]
GO
/****** Objeto: Schema [clinico] Fecha de script: 11/10/2026 2:29:47 PM ******/
CREATE SCHEMA [clinico]
GO
/****** Objeto: Schema [facturacion] Fecha de script: 11/10/2026 2:29:47 PM ******/
CREATE SCHEMA [facturacion]
GO
/****** Objeto: Table [clinico].[Citas] Fecha de script: 11/10/2026 2:29:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clinico].[Citas](
	[CitaID] [int] IDENTITY(1,1) NOT NULL,
	[PacienteID] [int] NOT NULL,
	[MedicoID] [int] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
	[Motivo] [varchar](255) NULL,
	[Estado] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CitaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [clinico].[Medicos] Fecha de script: 11/10/2026 2:29:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clinico].[Medicos](
	[MedicoID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Apellido] [varchar](50) NOT NULL,
	[Especialidad] [varchar](100) NOT NULL,
	[NumeroColegiado] [varchar](20) NOT NULL,
	[Telefono] [varchar](15) NULL,
	[Email] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[MedicoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[NumeroColegiado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [clinico].[Pacientes] Fecha de script: 11/10/2026 2:29:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clinico].[Pacientes](
	[PacienteID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Apellido] [varchar](50) NOT NULL,
	[FechaNacimiento] [date] NOT NULL,
	[Genero] [char](1) NULL,
	[Telefono] [varchar](15) NULL,
	[Email] [varchar](100) NULL,
	[Direccion] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[PacienteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [clinico].[Tratamientos] Fecha de script: 11/10/2026 2:29:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [clinico].[Tratamientos](
	[TratamientoID] [int] IDENTITY(1,1) NOT NULL,
	[CitaID] [int] NOT NULL,
	[Descripcion] [varchar](255) NOT NULL,
	[Dosis] [varchar](100) NULL,
	[Instrucciones] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[TratamientoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Objeto: Table [facturacion].[Facturacion] Fecha de script: 11/10/2026 2:29:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [facturacion].[Facturacion](
	[FacturaID] [int] IDENTITY(1,1) NOT NULL,
	[PacienteID] [int] NOT NULL,
	[FechaEmision] [datetime] NOT NULL,
	[MontoTotal] [decimal](10, 2) NOT NULL,
	[EstadoPago] [varchar](20) NOT NULL,
	[MetodoPago] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[FacturaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Objeto: Index [IX_Citas_Estado_MedicoID] Fecha de script: 11/10/2026 2:29:47 PM ******/
CREATE NONCLUSTERED INDEX [IX_Citas_Estado_MedicoID] ON [clinico].[Citas]
(
	[Estado] ASC,
	[MedicoID] ASC
)
INCLUDE([CitaID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Objeto: Index [IX_Medicos_Especialidad] Fecha de script: 11/10/2026 2:29:47 PM ******/
CREATE NONCLUSTERED INDEX [IX_Medicos_Especialidad] ON [clinico].[Medicos]
(
	[Especialidad] ASC
)
INCLUDE([MedicoID],[Nombre],[Apellido]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [IX_Facturacion_PacienteID_Fecha] Fecha de script: 11/10/2026 2:29:47 PM ******/
CREATE NONCLUSTERED INDEX [IX_Facturacion_PacienteID_Fecha] ON [facturacion].[Facturacion]
(
	[PacienteID] ASC,
	[FechaEmision] ASC
)
INCLUDE([MontoTotal],[EstadoPago]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Objeto: Index [IX_Facturacion_RunningTotal] Fecha de script: 11/10/2026 2:29:47 PM ******/
CREATE NONCLUSTERED INDEX [IX_Facturacion_RunningTotal] ON [facturacion].[Facturacion]
(
	[PacienteID] ASC,
	[FechaEmision] ASC,
	[EstadoPago] ASC
)
INCLUDE([MontoTotal]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [clinico].[Citas] ADD  DEFAULT ('Pendiente') FOR [Estado]
GO
ALTER TABLE [facturacion].[Facturacion] ADD  DEFAULT (getdate()) FOR [FechaEmision]
GO
ALTER TABLE [facturacion].[Facturacion] ADD  DEFAULT ('Pendiente') FOR [EstadoPago]
GO
ALTER TABLE [clinico].[Citas]  WITH CHECK ADD FOREIGN KEY([MedicoID])
REFERENCES [clinico].[Medicos] ([MedicoID])
GO
ALTER TABLE [clinico].[Citas]  WITH CHECK ADD FOREIGN KEY([PacienteID])
REFERENCES [clinico].[Pacientes] ([PacienteID])
GO
ALTER TABLE [clinico].[Tratamientos]  WITH CHECK ADD FOREIGN KEY([CitaID])
REFERENCES [clinico].[Citas] ([CitaID])
GO
ALTER TABLE [facturacion].[Facturacion]  WITH CHECK ADD FOREIGN KEY([PacienteID])
REFERENCES [clinico].[Pacientes] ([PacienteID])
GO
ALTER TABLE [clinico].[Citas]  WITH CHECK ADD CHECK  (([Estado]='Cancelada' OR [Estado]='Completada' OR [Estado]='Pendiente'))
GO
ALTER TABLE [clinico].[Pacientes]  WITH CHECK ADD CHECK  (([Genero]='F' OR [Genero]='M'))
GO
ALTER TABLE [facturacion].[Facturacion]  WITH CHECK ADD CHECK  (([EstadoPago]='Anulado' OR [EstadoPago]='Pagado' OR [EstadoPago]='Pendiente'))
GO
/****** Permisos Explícitos por Rol (Principio de Mínimo Privilegio) ******/
-- rol_recepcion: SELECT, INSERT, UPDATE en clinico.Pacientes y clinico.Citas; SELECT en clinico.Medicos
GRANT SELECT, INSERT, UPDATE ON [clinico].[Pacientes] TO [rol_recepcion]
GO
GRANT SELECT, INSERT, UPDATE ON [clinico].[Citas] TO [rol_recepcion]
GO
GRANT SELECT ON [clinico].[Medicos] TO [rol_recepcion]
GO
-- rol_medico: SELECT en clinico.Pacientes; SELECT, UPDATE en clinico.Citas; SELECT, INSERT, UPDATE en clinico.Tratamientos
GRANT SELECT ON [clinico].[Pacientes] TO [rol_medico]
GO
GRANT SELECT, UPDATE ON [clinico].[Citas] TO [rol_medico]
GO
GRANT SELECT, INSERT, UPDATE ON [clinico].[Tratamientos] TO [rol_medico]
GO
-- rol_facturacion: SELECT en clinico.Pacientes; SELECT, INSERT, UPDATE en todo el esquema facturacion
GRANT SELECT ON [clinico].[Pacientes] TO [rol_facturacion]
GO
GRANT SELECT, INSERT, UPDATE ON SCHEMA::[facturacion] TO [rol_facturacion]
GO
-- rol_consulta y rol_auditor: SELECT en los esquemas clinico y facturacion
GRANT SELECT ON SCHEMA::[clinico] TO [rol_consulta]
GO
GRANT SELECT ON SCHEMA::[facturacion] TO [rol_consulta]
GO
GRANT SELECT ON SCHEMA::[clinico] TO [rol_auditor]
GO
GRANT SELECT ON SCHEMA::[facturacion] TO [rol_auditor]
GO
USE [master]
GO
ALTER DATABASE [HospitalDB] SET  READ_WRITE 
GO
