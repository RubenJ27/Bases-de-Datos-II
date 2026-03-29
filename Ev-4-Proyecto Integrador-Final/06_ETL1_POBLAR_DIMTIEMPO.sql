USE RRHH_DW;

-- Cambiamos el delimitador temporalmente para crear el procedimiento
DELIMITER //

DROP PROCEDURE IF EXISTS PoblarDimTiempo //

CREATE PROCEDURE PoblarDimTiempo(IN fecha_inicio DATE, IN fecha_fin DATE)
BEGIN
    DECLARE v_fecha DATE;
    SET v_fecha = fecha_inicio;

    -- Ciclo que recorrerá día por día desde la fecha de inicio hasta la fecha fin
    WHILE v_fecha <= fecha_fin DO
        -- Usamos INSERT IGNORE por si ya existen fechas previas, no detenga el proceso
        INSERT IGNORE INTO DimFecha (
            FechaKey,
            FechaCompleta,
            Anio,
            Semestre,
            Trimestre,
            Mes,
            NombreMes,
            Dia,
            NombreDiaSemana
        ) VALUES (
            CAST(DATE_FORMAT(v_fecha, '%Y%m%d') AS UNSIGNED), -- Ejemplo: 20150101
            v_fecha,                                          -- 2015-01-01
            YEAR(v_fecha),                                    -- 2015
            IF(MONTH(v_fecha) <= 6, 1, 2),                    -- Semestre 1 o 2
            QUARTER(v_fecha),                                 -- Trimestre 1 al 4
            MONTH(v_fecha),                                   -- 1 al 12
            CASE MONTH(v_fecha)                               -- Nombre del mes
                WHEN 1 THEN 'Enero' WHEN 2 THEN 'Febrero' WHEN 3 THEN 'Marzo'
                WHEN 4 THEN 'Abril' WHEN 5 THEN 'Mayo' WHEN 6 THEN 'Junio'
                WHEN 7 THEN 'Julio' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Septiembre'
                WHEN 10 THEN 'Octubre' WHEN 11 THEN 'Noviembre' WHEN 12 THEN 'Diciembre'
            END,
            DAY(v_fecha),                                     -- Día del mes (1-31)
            CASE DAYOFWEEK(v_fecha)                           -- Nombre del día
                WHEN 1 THEN 'Domingo' WHEN 2 THEN 'Lunes' WHEN 3 THEN 'Martes'
                WHEN 4 THEN 'Miércoles' WHEN 5 THEN 'Jueves' WHEN 6 THEN 'Viernes'
                WHEN 7 THEN 'Sábado'
            END
        );
        
        -- Sumamos 1 día a la variable para pasar al siguiente
        SET v_fecha = DATE_ADD(v_fecha, INTERVAL 1 DAY);
    END WHILE;
END //

-- Restauramos el delimitador a su estado normal
DELIMITER ;

-- =========================================================================
-- EJECUCIÓN DEL PROCEDIMIENTO
-- Generamos todos los días desde el 2015 hasta el 2030
-- =========================================================================
CALL PoblarDimTiempo('2015-01-01', '2030-12-31');