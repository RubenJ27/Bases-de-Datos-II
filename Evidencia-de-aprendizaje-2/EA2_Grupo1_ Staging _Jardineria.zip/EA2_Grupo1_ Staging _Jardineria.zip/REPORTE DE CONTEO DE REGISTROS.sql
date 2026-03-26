-- Asegurarnos de estar en la base de datos de staging
USE staging;

-- ---------------------------------------------------------------------
-- 1. REPORTE DE CONTEO DE REGISTROS (ORIGEN VS STAGING)
-- ---------------------------------------------------------------------
-- Esta consulta te mostrará una tabla con el nombre de la tabla, 
-- cuántos registros hay en 'jardineria', cuántos hay en 'staging', 
-- y la diferencia (que debería ser siempre 0).

SELECT 'oficina' AS Tabla_Validada, 
       (SELECT COUNT(*) FROM jardineria.oficina) AS Registros_Origen, 
       (SELECT COUNT(*) FROM staging.stg_oficina) AS Registros_Staging,
       (SELECT COUNT(*) FROM jardineria.oficina) - (SELECT COUNT(*) FROM staging.stg_oficina) AS Diferencia
UNION ALL
SELECT 'empleado', 
       (SELECT COUNT(*) FROM jardineria.empleado), 
       (SELECT COUNT(*) FROM staging.stg_empleado),
       (SELECT COUNT(*) FROM jardineria.empleado) - (SELECT COUNT(*) FROM staging.stg_empleado)
UNION ALL
SELECT 'cliente', 
       (SELECT COUNT(*) FROM jardineria.cliente), 
       (SELECT COUNT(*) FROM staging.stg_cliente),
       (SELECT COUNT(*) FROM jardineria.cliente) - (SELECT COUNT(*) FROM staging.stg_cliente)
UNION ALL
SELECT 'categoria_producto', 
       (SELECT COUNT(*) FROM jardineria.categoria_producto), 
       (SELECT COUNT(*) FROM staging.stg_categoria_producto),
       (SELECT COUNT(*) FROM jardineria.categoria_producto) - (SELECT COUNT(*) FROM staging.stg_categoria_producto)
UNION ALL
SELECT 'producto', 
       (SELECT COUNT(*) FROM jardineria.producto), 
       (SELECT COUNT(*) FROM staging.stg_producto),
       (SELECT COUNT(*) FROM jardineria.producto) - (SELECT COUNT(*) FROM staging.stg_producto)
UNION ALL
SELECT 'pedido', 
       (SELECT COUNT(*) FROM jardineria.pedido), 
       (SELECT COUNT(*) FROM staging.stg_pedido),
       (SELECT COUNT(*) FROM jardineria.pedido) - (SELECT COUNT(*) FROM staging.stg_pedido)
UNION ALL
SELECT 'detalle_pedido', 
       (SELECT COUNT(*) FROM jardineria.detalle_pedido), 
       (SELECT COUNT(*) FROM staging.stg_detalle_pedido),
       (SELECT COUNT(*) FROM jardineria.detalle_pedido) - (SELECT COUNT(*) FROM staging.stg_detalle_pedido)
UNION ALL
SELECT 'pago', 
       (SELECT COUNT(*) FROM jardineria.pago), 
       (SELECT COUNT(*) FROM staging.stg_pago),
       (SELECT COUNT(*) FROM jardineria.pago) - (SELECT COUNT(*) FROM staging.stg_pago);


-- ---------------------------------------------------------------------
-- 2. MUESTREO VISUAL DE DATOS (OPCIONAL)
-- ---------------------------------------------------------------------
-- Ejecuta estas consultas de a una para ver los primeros 5 registros 
-- de las tablas más importantes y confirmar que los acentos, fechas 
-- y números se copiaron bien.

SELECT * FROM staging.stg_cliente LIMIT 5;
SELECT * FROM staging.stg_producto LIMIT 5;
SELECT * FROM staging.stg_pedido LIMIT 5;
SELECT * FROM staging.stg_pago LIMIT 5;
    