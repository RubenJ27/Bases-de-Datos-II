USE RRHH_DW;

-- =========================================================================
-- SCRIPT: 10_Consultas_Analiticas.sql
-- OBJETIVO: 15 Consultas Analíticas de Negocio sobre el Data Warehouse
-- =========================================================================

-- -------------------------------------------------------------------------
-- ANÁLISIS DE NÓMINA Y SALARIOS
-- -------------------------------------------------------------------------

-- 1. Gasto total de nómina mensual por Departamento (Salario Neto)
SELECT 
    d.NombreDepartamento, 
    SUM(f.SalarioNeto) AS GastoTotalNomina,
    COUNT(f.EmpleadoKey) AS CantidadEmpleados
FROM FactSalarios f
JOIN DimDepartamento d ON f.DepartamentoKey = d.DepartamentoKey
GROUP BY d.NombreDepartamento
ORDER BY GastoTotalNomina DESC;

-- 2. Brecha Salarial: Promedio de Salario Base por Género
SELECT 
    e.Genero, 
    ROUND(AVG(f.SalarioBase), 2) AS SalarioPromedio,
    COUNT(e.EmpleadoKey) AS TotalEmpleados
FROM FactSalarios f
JOIN DimEmpleado e ON f.EmpleadoKey = e.EmpleadoKey
GROUP BY e.Genero;

-- 3. Top 5 Puestos mejor pagados de la empresa
SELECT 
    p.NombrePuesto, 
    p.NivelSalarial,
    ROUND(AVG(f.SalarioNeto), 2) AS SalarioPromedioNeto
FROM FactSalarios f
JOIN DimPuesto p ON f.PuestoKey = p.PuestoKey
GROUP BY p.NombrePuesto, p.NivelSalarial
ORDER BY SalarioPromedioNeto DESC
LIMIT 5;

-- -------------------------------------------------------------------------
-- ANÁLISIS DE AUSENTISMO
-- -------------------------------------------------------------------------

-- 4. Tasa de ausentismo: Total de días perdidos por Oficina
SELECT 
    o.Ciudad, 
    o.Pais, 
    SUM(fa.DiasAusencia) AS TotalDiasPerdidos,
    COUNT(fa.EmpleadoKey) AS CantidadEventosAusencia
FROM FactAusencias fa
JOIN DimOficina o ON fa.OficinaKey = o.OficinaKey
GROUP BY o.Ciudad, o.Pais
ORDER BY TotalDiasPerdidos DESC;

-- 5. Tipos de ausencia más comunes (Impacto en la empresa)
SELECT 
    TipoAusencia, 
    COUNT(*) AS Frecuencia, 
    SUM(DiasAusencia) AS TotalDias
FROM FactAusencias
GROUP BY TipoAusencia
ORDER BY TotalDias DESC;

-- 6. Empleados críticos: Top 5 empleados con más días de ausencia
SELECT 
    e.NombreCompleto, 
    d.NombreDepartamento,
    SUM(fa.DiasAusencia) AS TotalDiasAusente
FROM FactAusencias fa
JOIN DimEmpleado e ON fa.EmpleadoKey = e.EmpleadoKey
JOIN DimDepartamento d ON fa.DepartamentoKey = d.DepartamentoKey
GROUP BY e.NombreCompleto, d.NombreDepartamento
ORDER BY TotalDiasAusente DESC
LIMIT 5;

-- 7. Porcentaje de ausencias injustificadas
SELECT 
    JustificadaFlag, 
    COUNT(*) AS Cantidad,
    SUM(DiasAusencia) AS DiasAcumulados
FROM FactAusencias
GROUP BY JustificadaFlag;

-- -------------------------------------------------------------------------
-- ANÁLISIS DE EVALUACIONES DE DESEMPEÑO
-- -------------------------------------------------------------------------

-- 8. Calificación promedio de desempeño por Departamento
SELECT 
    d.NombreDepartamento, 
    ROUND(AVG(fe.Calificacion), 2) AS PromedioDesempeno
FROM FactEvaluaciones fe
JOIN DimDepartamento d ON fe.DepartamentoKey = d.DepartamentoKey
GROUP BY d.NombreDepartamento
ORDER BY PromedioDesempeno DESC;

-- 9. Desempeño por Rango de Antigüedad
SELECT 
    CASE 
        WHEN e.AntiguedadAnios < 1 THEN 'Menos de 1 año'
        WHEN e.AntiguedadAnios BETWEEN 1 AND 3 THEN '1 a 3 años'
        WHEN e.AntiguedadAnios BETWEEN 4 AND 7 THEN '4 a 7 años'
        ELSE 'Más de 7 años'
    END AS RangoAntiguedad,
    ROUND(AVG(fe.Calificacion), 2) AS CalificacionPromedio
FROM FactEvaluaciones fe
JOIN DimEmpleado e ON fe.EmpleadoKey = e.EmpleadoKey
GROUP BY RangoAntiguedad
ORDER BY CalificacionPromedio DESC;

-- 10. Listado de Empleados en Riesgo (Calificación menor a 3.0)
SELECT 
    e.NombreCompleto, 
    e.AntiguedadAnios,
    p.NombrePuesto,
    fe.Calificacion
FROM FactEvaluaciones fe
JOIN DimEmpleado e ON fe.EmpleadoKey = e.EmpleadoKey
JOIN DimPuesto p ON fe.PuestoKey = p.PuestoKey
WHERE fe.Calificacion < 3.0
ORDER BY fe.Calificacion ASC;

-- -------------------------------------------------------------------------
-- ANÁLISIS DE CAPACITACIONES (ROI y Esfuerzo)
-- -------------------------------------------------------------------------

-- 11. Inversión total en capacitaciones por Oficina
SELECT 
    o.Ciudad, 
    SUM(fc.CostoCapacitacion) AS InversionTotal
FROM FactCapacitaciones fc
JOIN DimOficina o ON fc.OficinaKey = o.OficinaKey
GROUP BY o.Ciudad
ORDER BY InversionTotal DESC;

-- 12. Cursos más tomados y su índice de aprobación (Calificación Promedio)
SELECT 
    NombreCapacitacion, 
    COUNT(EmpleadoKey) AS Asistentes,
    ROUND(AVG(CalificacionObtenida), 2) AS CalificacionPromedio
FROM FactCapacitaciones
WHERE Estado = 'Completada'
GROUP BY NombreCapacitacion
ORDER BY Asistentes DESC;

-- 13. Comparativa: Inversión en Capacitación vs Promedio de Desempeño por Depto
SELECT 
    d.NombreDepartamento, 
    COALESCE(SUM(fc.CostoCapacitacion), 0) AS PresupuestoGastado,
    ROUND(AVG(fe.Calificacion), 2) AS CalificacionPromedio
FROM DimDepartamento d
LEFT JOIN FactCapacitaciones fc ON d.DepartamentoKey = fc.DepartamentoKey
LEFT JOIN FactEvaluaciones fe ON d.DepartamentoKey = fe.DepartamentoKey
GROUP BY d.NombreDepartamento
ORDER BY CalificacionPromedio DESC;

-- -------------------------------------------------------------------------
-- DEMOGRAFÍA Y ESTRUCTURA ORGANIZACIONAL
-- -------------------------------------------------------------------------

-- 14. Distribución generacional (Edades) en la empresa
SELECT 
    CASE 
        WHEN e.Edad < 25 THEN 'Generación Z (<25)'
        WHEN e.Edad BETWEEN 25 AND 40 THEN 'Millennials (25-40)'
        WHEN e.Edad BETWEEN 41 AND 55 THEN 'Generación X (41-55)'
        ELSE 'Boomers (>55)'
    END AS Generacion,
    COUNT(e.EmpleadoKey) AS TotalEmpleados
FROM DimEmpleado e
WHERE e.Activo = 1
GROUP BY Generacion
ORDER BY TotalEmpleados DESC;

-- 15. Cantidad de Empleados por Estado Civil y Género
SELECT 
    e.EstadoCivil, 
    e.Genero, 
    COUNT(e.EmpleadoKey) AS CantidadEmpleados
FROM DimEmpleado e
WHERE e.Activo = 1
GROUP BY e.EstadoCivil, e.Genero
ORDER BY e.EstadoCivil, CantidadEmpleados DESC;r