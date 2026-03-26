USE bd_2_evidencia_de_aprendizaje_1_jardineria;

-- D) Llenar la Tabla de Hechos (Fact_Ventas)
INSERT INTO Fact_Ventas (Producto_Key, Tiempo_Key, Cliente_Key, Cantidad_Vendida, Precio_Unidad)
SELECT 
    dp.ID_producto AS Producto_Key,
    CAST(CONVERT(VARCHAR(8), p.fecha_pedido, 112) AS INT) AS Tiempo_Key,
    p.ID_cliente AS Cliente_Key,
    dp.cantidad AS Cantidad_Vendida,
    dp.precio_unidad AS Precio_Unidad
FROM detalle_pedido dp
INNER JOIN pedido p ON dp.ID_pedido = p.ID_pedido;

