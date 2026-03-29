CREATE DATABASE IF NOT EXISTS RRHH_DW;
USE RRHH_DW;

-- =========================================================================
-- SCRIPT: Crear_Dimensiones.sql
-- OBJETIVO: Implementación de 5 dimensiones estrictas
-- =========================================================================

-- 1. Dimensión Fecha
CREATE TABLE IF NOT EXISTS DimFecha (
    FechaKey INT PRIMARY KEY,
    FechaCompleta DATE,
    Anio INT,
    Semestre INT,
    Trimestre INT,
    Mes INT,
    NombreMes VARCHAR(20),
    Dia INT,
    NombreDiaSemana VARCHAR(20)
);

-- 2. Dimensión Oficina
CREATE TABLE IF NOT EXISTS DimOficina (
    OficinaKey INT AUTO_INCREMENT PRIMARY KEY,
    OficinaID_OLTP INT,
    CodigoOficina VARCHAR(20),
    Ciudad VARCHAR(50),
    Pais VARCHAR(50),
    Region VARCHAR(50),
    CodigoPostal VARCHAR(20)
);

-- 3. Dimensión Departamento
CREATE TABLE IF NOT EXISTS DimDepartamento (
    DepartamentoKey INT AUTO_INCREMENT PRIMARY KEY,
    DepartamentoID_OLTP INT,
    NombreDepartamento VARCHAR(100),
    Descripcion VARCHAR(255)
);

-- 4. Dimensión Puesto
CREATE TABLE IF NOT EXISTS DimPuesto (
    PuestoKey INT AUTO_INCREMENT PRIMARY KEY,
    PuestoID_OLTP INT,
    NombrePuesto VARCHAR(100),
    NivelSalarial VARCHAR(50),
    SalarioMinimo DECIMAL(10,2),
    SalarioMaximo DECIMAL(10,2)
);

-- 5. Dimensión Empleado
CREATE TABLE IF NOT EXISTS DimEmpleado (
    EmpleadoKey INT AUTO_INCREMENT PRIMARY KEY,
    EmpleadoID_OLTP INT,
    Identificacion VARCHAR(50),
    NombreCompleto VARCHAR(150),
    Genero VARCHAR(20),
    EstadoCivil VARCHAR(20),
    Edad INT,
    FechaContratacion DATE,
    AntiguedadAnios INT,
    Activo TINYINT,
    DepartamentoID_OLTP INT,
    PuestoID_OLTP INT,
    OficinaID_OLTP INT,
    JefeID_OLTP INT
);