/* =========================================================
   01_OLTP_RRHH.sql
   Base de datos OLTP RRHH - SQL Server
   ========================================================= */
   
-- Crear base de datos
IF DB_ID('RRHH_OLTP') IS NOT NULL
BEGIN
    ALTER DATABASE RRHH_OLTP SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RRHH_OLTP;
END;
GO

CREATE DATABASE RRHH_OLTP;
GO

USE RRHH_OLTP;
GO

/* =========================================================
   TABLAS MAESTRAS
   ========================================================= */

CREATE TABLE Oficinas (
    OficinaID           INT IDENTITY(1,1) PRIMARY KEY,
    CodigoOficina       VARCHAR(20) NOT NULL UNIQUE,
    Ciudad              VARCHAR(100) NOT NULL,
    Pais                VARCHAR(100) NOT NULL,
    Region              VARCHAR(100) NOT NULL,
    CodigoPostal        VARCHAR(20) NULL,
    Telefono            VARCHAR(30) NULL,
    Direccion           VARCHAR(200) NOT NULL,
    FechaCreacion       DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
PRINT 'Tabla Oficinas creada exitosamente.';
GO

CREATE TABLE Departamentos (
    DepartamentoID      INT IDENTITY(1,1) PRIMARY KEY,
    NombreDepartamento  VARCHAR(100) NOT NULL UNIQUE,
    Descripcion         VARCHAR(250) NULL,
    OficinaID           INT NOT NULL,
    FechaCreacion       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Departamentos_Oficinas
        FOREIGN KEY (OficinaID) REFERENCES dbo.Oficinas(OficinaID)
);
PRINT 'Tabla Departamentos creada exitosamente.';
GO

CREATE TABLE Puestos (
    PuestoID            INT IDENTITY(1,1) PRIMARY KEY,
    NombrePuesto        VARCHAR(120) NOT NULL,
    NivelSalarial       VARCHAR(20) NOT NULL,
    SalarioMinimo       DECIMAL(12,2) NOT NULL,
    SalarioMaximo       DECIMAL(12,2) NOT NULL,
    FechaCreacion       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Puestos_NivelSalarial
        CHECK (NivelSalarial IN ('Junior','Mid-Level','Senior')),
    CONSTRAINT CK_Puestos_RangoSalario
        CHECK (SalarioMinimo > 0 AND SalarioMaximo >= SalarioMinimo)
);
PRINT 'Tabla Puestos creada exitosamente.';
GO

/* =========================================================
                          EMPLEADOS
   ========================================================= */

CREATE TABLE Empleados (
    EmpleadoID              INT IDENTITY(1,1) PRIMARY KEY,
    Identificacion          VARCHAR(30) NOT NULL UNIQUE,
    Nombre                  VARCHAR(80) NOT NULL,
    Apellidos               VARCHAR(120) NOT NULL,
    FechaNacimiento         DATE NOT NULL,
    Genero                  VARCHAR(20) NOT NULL,
    EstadoCivil             VARCHAR(30) NOT NULL,
    Email                   VARCHAR(150) NOT NULL UNIQUE,
    Telefono                VARCHAR(30) NULL,
    FechaContratacion       DATE NOT NULL,
    DepartamentoID          INT NOT NULL,
    PuestoID                INT NOT NULL,
    SalarioActual           DECIMAL(12,2) NOT NULL,
    JefeID                  INT NULL,
    OficinaID               INT NOT NULL,
    Activo                  BIT NOT NULL DEFAULT 1,
    FechaCreacion           DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Empleados_Departamentos
        FOREIGN KEY (DepartamentoID) REFERENCES dbo.Departamentos(DepartamentoID),
    CONSTRAINT FK_Empleados_Puestos
        FOREIGN KEY (PuestoID) REFERENCES dbo.Puestos(PuestoID),
    CONSTRAINT FK_Empleados_Oficinas
        FOREIGN KEY (OficinaID) REFERENCES dbo.Oficinas(OficinaID),
    CONSTRAINT FK_Empleados_Jefe
        FOREIGN KEY (JefeID) REFERENCES dbo.Empleados(EmpleadoID),
    CONSTRAINT CK_Empleados_Genero
        CHECK (Genero IN ('Masculino','Femenino','No Binario','Otro')),
    CONSTRAINT CK_Empleados_Salario
        CHECK (SalarioActual > 0)
);
PRINT 'Tabla Empleados creada exitosamente.';
GO

/* =========================================================
                     TABLA AUSENCIAS
   ========================================================= */

CREATE TABLE Ausencias (
    AusenciaID               INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoID               INT NOT NULL,
    TipoAusencia             VARCHAR(30) NOT NULL,
    FechaInicio              DATE NOT NULL,
    FechaFin                 DATE NOT NULL,
    DiasTotales              AS (DATEDIFF(DAY, FechaInicio, FechaFin) + 1) PERSISTED,
    Justificada              BIT NOT NULL,
    Comentarios              VARCHAR(300) NULL,
    FechaRegistro            DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Ausencias_Empleados
        FOREIGN KEY (EmpleadoID) REFERENCES dbo.Empleados(EmpleadoID),
    CONSTRAINT CK_Ausencias_Tipo
        CHECK (TipoAusencia IN ('Vacaciones','Enfermedad','Permiso Personal','Licencia Médica')),
    CONSTRAINT CK_Ausencias_Fechas
        CHECK (FechaFin >= FechaInicio)
);
PRINT 'Tabla Ausencias creada exitosamente.';
GO

/* =========================================================
                         TABLA EVALUACIONES
   ========================================================= */

CREATE TABLE EvaluacionesDesempeno (
    EvaluacionID             INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoEvaluadoID       INT NOT NULL,
    FechaEvaluacion          DATE NOT NULL,
    Calificacion             DECIMAL(3,1) NOT NULL,
    EvaluadorID              INT NOT NULL,
    Comentarios              VARCHAR(500) NULL,
    FechaRegistro            DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Evaluaciones_EmpleadoEvaluado
        FOREIGN KEY (EmpleadoEvaluadoID) REFERENCES dbo.Empleados(EmpleadoID),
    CONSTRAINT FK_Evaluaciones_Evaluador
        FOREIGN KEY (EvaluadorID) REFERENCES dbo.Empleados(EmpleadoID),
    CONSTRAINT CK_Evaluaciones_Calificacion
        CHECK (Calificacion BETWEEN 1.0 AND 5.0)
);
PRINT 'Tabla EvaluacionesDesempeno creada exitosamente.';
GO

/* =========================================================
                     TABLA CAPACITACIONES
   ========================================================= */

CREATE TABLE Capacitaciones (
    CapacitacionID           INT IDENTITY(1,1) PRIMARY KEY,
    NombreCapacitacion       VARCHAR(150) NOT NULL,
    Descripcion              VARCHAR(300) NULL,
    Proveedor                VARCHAR(150) NOT NULL,
    Costo                    DECIMAL(12,2) NOT NULL,
    FechaInicio              DATE NOT NULL,
    FechaFin                 DATE NOT NULL,
    DuracionDias             AS (DATEDIFF(DAY, FechaInicio, FechaFin) + 1) PERSISTED,
    FechaCreacion            DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Capacitaciones_Costo
        CHECK (Costo >= 0),
    CONSTRAINT CK_Capacitaciones_Fechas
        CHECK (FechaFin >= FechaInicio)
);
PRINT 'Tabla Capacitaciones creada exitosamente.';
GO

/* =========================================================
                     TABLA EMPLEADOS_CAPACITACIONES
   ========================================================= */
CREATE TABLE EmpleadosCapacitaciones (
    EmpleadoCapacitacionID   INT IDENTITY(1,1) PRIMARY KEY,
    EmpleadoID               INT NOT NULL,
    CapacitacionID           INT NOT NULL,
    CalificacionObtenida     DECIMAL(5,2) NULL,
    FechaCompletado          DATE NULL,
    Estado                   VARCHAR(20) NOT NULL,
    Comentarios              VARCHAR(300) NULL,
    FechaRegistro            DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_EmpleadoCap_Empleados
        FOREIGN KEY (EmpleadoID) REFERENCES dbo.Empleados(EmpleadoID),
    CONSTRAINT FK_EmpleadoCap_Capacitaciones
        FOREIGN KEY (CapacitacionID) REFERENCES dbo.Capacitaciones(CapacitacionID),
    CONSTRAINT CK_EmpleadoCap_Estado
        CHECK (Estado IN ('Completada','En Curso')),
    CONSTRAINT CK_EmpleadoCap_Calificacion
        CHECK (CalificacionObtenida IS NULL OR CalificacionObtenida BETWEEN 0 AND 100),
    CONSTRAINT UQ_EmpleadoCap UNIQUE (EmpleadoID, CapacitacionID)
);
PRINT 'Tabla EmpleadosCapacitaciones creada exitosamente.';
GO

/* =========================================================
                         CREANDO ÍNDICES
   ========================================================= */

CREATE INDEX IX_Empleados_DepartamentoID ON dbo.Empleados(DepartamentoID);
CREATE INDEX IX_Empleados_PuestoID ON dbo.Empleados(PuestoID);
CREATE INDEX IX_Empleados_OficinaID ON dbo.Empleados(OficinaID);
CREATE INDEX IX_Empleados_JefeID ON dbo.Empleados(JefeID);

CREATE INDEX IX_Ausencias_EmpleadoID_FechaInicio ON dbo.Ausencias(EmpleadoID, FechaInicio);
CREATE INDEX IX_Evaluaciones_EmpleadoEvaluadoID_FechaEvaluacion ON dbo.EvaluacionesDesempeno(EmpleadoEvaluadoID, FechaEvaluacion);
CREATE INDEX IX_EmpleadoCap_EmpleadoID ON dbo.EmpleadosCapacitaciones(EmpleadoID);
GO
PRINT 'Índices creados exitosamente.';
PRINT 'Base de datos RRHH_OLTP creada y poblada con tablas maestras exitosamente.';