USE RRHH_DW;

-- Cambiamos el delimitador para crear los procedimientos
DELIMITER //

-- =========================================================================
-- 1. Procedimiento para cargar DimOficina
-- =========================================================================
DROP PROCEDURE IF EXISTS CargarDimOficina //
CREATE PROCEDURE CargarDimOficina()
BEGIN
    INSERT INTO DimOficina (OficinaID_OLTP, CodigoOficina, Ciudad, Pais, Region, CodigoPostal)
    SELECT 
        o.OficinaID, 
        o.CodigoOficina, 
        o.Ciudad, 
        o.Pais, 
        o.Region, 
        o.CodigoPostal
    FROM rrhh_oltp.oficinas o
    WHERE NOT EXISTS (
        SELECT 1 FROM RRHH_DW.DimOficina dw WHERE dw.OficinaID_OLTP = o.OficinaID
    );
END //

-- =========================================================================
-- 2. Procedimiento para cargar DimDepartamento
-- =========================================================================
DROP PROCEDURE IF EXISTS CargarDimDepartamento //
CREATE PROCEDURE CargarDimDepartamento()
BEGIN
    INSERT INTO DimDepartamento (DepartamentoID_OLTP, NombreDepartamento, Descripcion)
    SELECT 
        d.DepartamentoID, 
        d.NombreDepartamento, 
        d.Descripcion
    FROM rrhh_oltp.departamentos d
    WHERE NOT EXISTS (
        SELECT 1 FROM RRHH_DW.DimDepartamento dw WHERE dw.DepartamentoID_OLTP = d.DepartamentoID
    );
END //

-- =========================================================================
-- 3. Procedimiento para cargar DimPuesto
-- =========================================================================
DROP PROCEDURE IF EXISTS CargarDimPuesto //
CREATE PROCEDURE CargarDimPuesto()
BEGIN
    INSERT INTO DimPuesto (PuestoID_OLTP, NombrePuesto, NivelSalarial, SalarioMinimo, SalarioMaximo)
    SELECT 
        p.PuestoID, 
        p.NombrePuesto, 
        p.NivelSalarial, 
        p.SalarioMinimo, 
        p.SalarioMaximo
    FROM rrhh_oltp.puestos p
    WHERE NOT EXISTS (
        SELECT 1 FROM RRHH_DW.DimPuesto dw WHERE dw.PuestoID_OLTP = p.PuestoID
    );
END //

-- =========================================================================
-- 4. Procedimiento para cargar DimEmpleado (Con corrección de 'Apellidos')
-- =========================================================================
DROP PROCEDURE IF EXISTS CargarDimEmpleado //
CREATE PROCEDURE CargarDimEmpleado()
BEGIN
    INSERT INTO DimEmpleado (
        EmpleadoID_OLTP, Identificacion, NombreCompleto, Genero, 
        EstadoCivil, Edad, FechaContratacion, AntiguedadAnios, 
        Activo, DepartamentoID_OLTP, PuestoID_OLTP, OficinaID_OLTP, JefeID_OLTP
    )
    SELECT 
        e.EmpleadoID, 
        e.Identificacion, 
        CONCAT(e.Nombre, ' ', e.Apellidos) AS NombreCompleto, 
        e.Genero, 
        e.EstadoCivil, 
        TIMESTAMPDIFF(YEAR, e.FechaNacimiento, CURDATE()) AS Edad, 
        e.FechaContratacion, 
        TIMESTAMPDIFF(YEAR, e.FechaContratacion, CURDATE()) AS AntiguedadAnios, 
        e.Activo, 
        e.DepartamentoID, 
        e.PuestoID, 
        e.OficinaID, 
        e.JefeID
    FROM rrhh_oltp.empleados e
    WHERE NOT EXISTS (
        SELECT 1 FROM RRHH_DW.DimEmpleado dw WHERE dw.EmpleadoID_OLTP = e.EmpleadoID
    );
END //

-- Restauramos el delimitador
DELIMITER ;

-- =========================================================================
-- EJECUCIÓN DE TODOS LOS PROCEDIMIENTOS (Carga de datos)
-- =========================================================================
CALL CargarDimOficina();
CALL CargarDimDepartamento();
CALL CargarDimPuesto();
CALL CargarDimEmpleado();