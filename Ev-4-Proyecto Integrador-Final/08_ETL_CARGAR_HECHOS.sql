USE RRHH_DW;

DELIMITER //

-- =========================================================================
-- 1. Cargar FactSalarios 
-- =========================================================================
DROP PROCEDURE IF EXISTS CargarFactSalarios //
CREATE PROCEDURE CargarFactSalarios()
BEGIN
    TRUNCATE TABLE FactSalarios;

    INSERT INTO FactSalarios (
        FechaKey, EmpleadoKey, DepartamentoKey, PuestoKey,  
        SalarioBase, Bonificaciones, Deducciones, SalarioNeto, CantidadPagos
    ) 
    SELECT  
        CAST(DATE_FORMAT(e.FechaContratacion, '%Y%m%d') AS UNSIGNED) AS FechaKey,  
        de.EmpleadoKey, 
        dd.DepartamentoKey, 
        dp.PuestoKey, 
        e.SalarioActual AS SalarioBase, 
        0 AS Bonificaciones, 
        0 AS Deducciones, 
        e.SalarioActual AS SalarioNeto, 
        1 AS CantidadPagos 
    FROM rrhh_oltp.Empleados e 
    JOIN DimEmpleado de ON e.EmpleadoID = de.EmpleadoID_OLTP 
    JOIN DimDepartamento dd ON e.DepartamentoID = dd.DepartamentoID_OLTP 
    JOIN DimPuesto dp ON e.PuestoID = dp.PuestoID_OLTP;
END //

-- =========================================================================
-- 2. Cargar FactAusencias
-- =========================================================================
DROP PROCEDURE IF EXISTS CargarFactAusencias //
CREATE PROCEDURE CargarFactAusencias()
BEGIN
    TRUNCATE TABLE FactAusencias;

    INSERT INTO FactAusencias (
        FechaKey, EmpleadoKey, OficinaKey, DepartamentoKey, 
        TipoAusencia, CantidadAusencias, DiasAusencia, JustificadaFlag
    )
    SELECT 
        CAST(DATE_FORMAT(a.FechaInicio, '%Y%m%d') AS UNSIGNED) AS FechaKey,
        de.EmpleadoKey,
        dof.OficinaKey,          -- Obtenido del JOIN de abajo
        dd.DepartamentoKey,      -- Obtenido del JOIN de abajo
        a.TipoAusencia,         
        1 AS CantidadAusencias, 
        a.DiasTotales AS DiasAusencia, 
        a.Justificada AS JustificadaFlag 
    FROM rrhh_oltp.Ausencias a
    JOIN DimEmpleado de ON a.EmpleadoID = de.EmpleadoID_OLTP
    JOIN DimOficina dof ON de.OficinaID_OLTP = dof.OficinaID_OLTP
    JOIN DimDepartamento dd ON de.DepartamentoID_OLTP = dd.DepartamentoID_OLTP;
END //

-- =========================================================================
-- 3. Cargar FactEvaluaciones
-- =========================================================================
DROP PROCEDURE IF EXISTS CargarFactEvaluaciones //
CREATE PROCEDURE CargarFactEvaluaciones()
BEGIN
    TRUNCATE TABLE FactEvaluaciones;

    INSERT INTO FactEvaluaciones (
        FechaKey, EmpleadoKey, EvaluadorEmpleadoKey, OficinaKey, 
        DepartamentoKey, PuestoKey, Calificacion, CantidadEvaluaciones
    )
    SELECT 
        CAST(DATE_FORMAT(ev.FechaEvaluacion, '%Y%m%d') AS UNSIGNED) AS FechaKey,
        de.EmpleadoKey,
        COALESCE(de_eval.EmpleadoKey, de.EmpleadoKey) AS EvaluadorEmpleadoKey,
        dof.OficinaKey,
        dd.DepartamentoKey,
        dp.PuestoKey,
        ev.Calificacion, 
        1 AS CantidadEvaluaciones
    FROM rrhh_oltp.EvaluacionesDesempeno ev 
    JOIN DimEmpleado de ON ev.EmpleadoEvaluadoID = de.EmpleadoID_OLTP 
    LEFT JOIN DimEmpleado de_eval ON ev.EvaluadorID = de_eval.EmpleadoID_OLTP
    JOIN DimOficina dof ON de.OficinaID_OLTP = dof.OficinaID_OLTP
    JOIN DimDepartamento dd ON de.DepartamentoID_OLTP = dd.DepartamentoID_OLTP
    JOIN DimPuesto dp ON de.PuestoID_OLTP = dp.PuestoID_OLTP;
END //

-- =========================================================================
-- 4. Cargar FactCapacitaciones
-- =========================================================================
DROP PROCEDURE IF EXISTS CargarFactCapacitaciones //
CREATE PROCEDURE CargarFactCapacitaciones()
BEGIN
    TRUNCATE TABLE FactCapacitaciones;

    INSERT INTO FactCapacitaciones (
        FechaKey, EmpleadoKey, OficinaKey, DepartamentoKey, PuestoKey, 
        NombreCapacitacion, Estado, CalificacionObtenida, CantidadAsignaciones, CostoCapacitacion
    )
    SELECT 
        CAST(DATE_FORMAT(c.FechaInicio, '%Y%m%d') AS UNSIGNED) AS FechaKey,
        de.EmpleadoKey,
        dof.OficinaKey,
        dd.DepartamentoKey,
        dp.PuestoKey,
        c.NombreCapacitacion, 
        ec.Estado,             
        ec.CalificacionObtenida, 
        1 AS CantidadAsignaciones,
        c.Costo AS CostoCapacitacion 
    FROM rrhh_oltp.Capacitaciones c
    JOIN rrhh_oltp.EmpleadosCapacitaciones ec ON c.CapacitacionID = ec.CapacitacionID 
    JOIN DimEmpleado de ON ec.EmpleadoID = de.EmpleadoID_OLTP
    JOIN DimOficina dof ON de.OficinaID_OLTP = dof.OficinaID_OLTP
    JOIN DimDepartamento dd ON de.DepartamentoID_OLTP = dd.DepartamentoID_OLTP
    JOIN DimPuesto dp ON de.PuestoID_OLTP = dp.PuestoID_OLTP;
END //

DELIMITER ;

-- =========================================================================
-- EJECUCIÓN DE TODOS LOS PROCEDIMIENTOS
-- =========================================================================
CALL CargarFactSalarios();
CALL CargarFactAusencias();
CALL CargarFactEvaluaciones();
CALL CargarFactCapacitaciones();