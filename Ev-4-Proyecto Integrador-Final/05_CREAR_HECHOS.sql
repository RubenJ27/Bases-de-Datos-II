USE RRHH_DW;

-- =========================================================================
-- SCRIPT: Crear_Hechos.sql
-- OBJETIVO: Implementación de 4 tablas de hechos enlazadas a 5 dimensiones
-- =========================================================================

-- 1. Tabla de Hechos: Ausencias 
-- (El Tipo de Ausencia se guarda como texto directo para no usar una dimensión extra)
CREATE TABLE IF NOT EXISTS FactAusencias (
    FechaKey INT,
    EmpleadoKey INT,
    OficinaKey INT,
    DepartamentoKey INT,
    TipoAusencia VARCHAR(100), 
    CantidadAusencias INT,
    DiasAusencia INT,
    JustificadaFlag TINYINT,
    FOREIGN KEY (FechaKey) REFERENCES DimFecha(FechaKey),
    FOREIGN KEY (EmpleadoKey) REFERENCES DimEmpleado(EmpleadoKey),
    FOREIGN KEY (OficinaKey) REFERENCES DimOficina(OficinaKey),
    FOREIGN KEY (DepartamentoKey) REFERENCES DimDepartamento(DepartamentoKey)
);

-- 2. Tabla de Hechos: Evaluaciones de Desempeño
CREATE TABLE IF NOT EXISTS FactEvaluaciones (
    FechaKey INT,
    EmpleadoKey INT,
    EvaluadorEmpleadoKey INT,
    OficinaKey INT,
    DepartamentoKey INT,
    PuestoKey INT,
    Calificacion DECIMAL(5,2),
    CantidadEvaluaciones INT,
    FOREIGN KEY (FechaKey) REFERENCES DimFecha(FechaKey),
    FOREIGN KEY (EmpleadoKey) REFERENCES DimEmpleado(EmpleadoKey),
    FOREIGN KEY (EvaluadorEmpleadoKey) REFERENCES DimEmpleado(EmpleadoKey),
    FOREIGN KEY (OficinaKey) REFERENCES DimOficina(OficinaKey),
    FOREIGN KEY (DepartamentoKey) REFERENCES DimDepartamento(DepartamentoKey),
    FOREIGN KEY (PuestoKey) REFERENCES DimPuesto(PuestoKey)
);

-- 3. Tabla de Hechos: Capacitaciones 
-- (El Nombre de la capacitación va directo en la tabla para no usar otra dimensión)
CREATE TABLE IF NOT EXISTS FactCapacitaciones (
    FechaKey INT,
    EmpleadoKey INT,
    OficinaKey INT,
    DepartamentoKey INT,
    PuestoKey INT,
    NombreCapacitacion VARCHAR(150), 
    Estado VARCHAR(50),
    CalificacionObtenida DECIMAL(5,2),
    CantidadAsignaciones INT,
    CostoCapacitacion DECIMAL(10,2),
    FOREIGN KEY (FechaKey) REFERENCES DimFecha(FechaKey),
    FOREIGN KEY (EmpleadoKey) REFERENCES DimEmpleado(EmpleadoKey),
    FOREIGN KEY (OficinaKey) REFERENCES DimOficina(OficinaKey),
    FOREIGN KEY (DepartamentoKey) REFERENCES DimDepartamento(DepartamentoKey),
    FOREIGN KEY (PuestoKey) REFERENCES DimPuesto(PuestoKey)
);

-- 4. Tabla de Hechos: Salarios / Nómina
CREATE TABLE IF NOT EXISTS FactSalarios (
    FechaKey INT,
    EmpleadoKey INT,
    DepartamentoKey INT,
    PuestoKey INT,
    SalarioBase DECIMAL(10,2),
    Bonificaciones DECIMAL(10,2),
    Deducciones DECIMAL(10,2),
    SalarioNeto DECIMAL(10,2),
    CantidadPagos INT,
    FOREIGN KEY (FechaKey) REFERENCES DimFecha(FechaKey),
    FOREIGN KEY (EmpleadoKey) REFERENCES DimEmpleado(EmpleadoKey),
    FOREIGN KEY (DepartamentoKey) REFERENCES DimDepartamento(DepartamentoKey),
    FOREIGN KEY (PuestoKey) REFERENCES DimPuesto(PuestoKey)
);