USE RRHH_DW;

-- =========================================================================
-- SCRIPT: Validaciones_DWH.sql
-- OBJETIVO: 10+ Validaciones de Calidad de Datos (Modelo 5 Dimensiones)
-- =========================================================================

-- 1. Validación de Volumetría: Cantidad de registros por cada tabla de hechos
SELECT 'FactAusencias' AS Tabla, COUNT(*) AS TotalRegistros FROM FactAusencias
UNION ALL
SELECT 'FactEvaluaciones', COUNT(*) FROM FactEvaluaciones
UNION ALL
SELECT 'FactCapacitaciones', COUNT(*) FROM FactCapacitaciones
UNION ALL
SELECT 'FactSalarios', COUNT(*) FROM FactSalarios;

-- 2. Validación de Nulos en Claves Foráneas Críticas (FactAusencias)
SELECT COUNT(*) AS Faltan_Claves_Ausencias 
FROM FactAusencias 
WHERE EmpleadoKey IS NULL OR FechaKey IS NULL;

-- 3. Validación de Integridad Referencial (Huérfanos en FactEvaluaciones)
-- Revisa si hay evaluaciones asignadas a un empleado que no existe en DimEmpleado
SELECT COUNT(*) AS Evaluaciones_Sin_Empleado_Valido
FROM FactEvaluaciones f
LEFT JOIN DimEmpleado d ON f.EmpleadoKey = d.EmpleadoKey
WHERE d.EmpleadoKey IS NULL;

-- 4. Validación de Calidad en Dimensión Degenerada (TipoAusencia en blanco o nulo)
SELECT COUNT(*) AS Ausencias_Sin_Tipo
FROM FactAusencias
WHERE TipoAusencia IS NULL OR TipoAusencia = '';

-- 5. Validación de Calidad en Dimensión Degenerada (NombreCapacitacion en blanco)
SELECT COUNT(*) AS Capacitaciones_Sin_Nombre
FROM FactCapacitaciones
WHERE NombreCapacitacion IS NULL OR NombreCapacitacion = '';

-- 6. Validación de Duplicados en DimEmpleado (Identificaciones repetidas)
SELECT Identificacion, COUNT(*) AS Repeticiones
FROM DimEmpleado
GROUP BY Identificacion
HAVING COUNT(*) > 1;

-- 7. Validación de Reglas de Negocio: Edades ilógicas (menores de 18 o mayores de 100)
SELECT COUNT(*) AS Empleados_Con_Edad_Invalida
FROM DimEmpleado
WHERE Edad < 18 OR Edad > 100;

-- 8. Validación de Reglas de Negocio: Costos de capacitación negativos
SELECT COUNT(*) AS Costos_Negativos
FROM FactCapacitaciones
WHERE CostoCapacitacion < 0;

-- 9. Validación de Reglas de Negocio: Días de ausencia en cero o negativos
SELECT COUNT(*) AS Dias_Ausencia_Invalidos
FROM FactAusencias
WHERE DiasAusencia <= 0;

-- 10. Validación de Reglas de Negocio: Salarios Netos negativos en FactSalarios
SELECT COUNT(*) AS Salarios_Negativos
FROM FactSalarios
WHERE SalarioNeto < 0;

-- 11. Validación de Fechas Futuras (Eventos que supuestamente pasaron en el futuro)
SELECT COUNT(*) AS Fechas_Futuras_Incoherentes
FROM FactEvaluaciones f
JOIN DimFecha d ON f.FechaKey = d.FechaKey
WHERE d.FechaCompleta > CURDATE();

-- 12. Validación de Nulos en campos descriptivos críticos (Nombre del Empleado)
SELECT COUNT(*) AS Empleados_Sin_Nombre
FROM DimEmpleado
WHERE NombreCompleto IS NULL OR NombreCompleto = '';



