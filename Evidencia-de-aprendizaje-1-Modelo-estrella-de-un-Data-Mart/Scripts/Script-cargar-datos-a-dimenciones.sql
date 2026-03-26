USE bd_2_evidencia_de_aprendizaje_1_jardineria;

-- ==========================================
-- PASO 2: CARGA DE DATOS AL MODELO ESTRELLA
-- ==========================================

-- A) Llenar la Dimensión Cliente
INSERT INTO Dim_Cliente (Cliente_Key, Nombre_Cliente, Ciudad, Pais)
SELECT 
    ID_cliente, 
    nombre_cliente, 
    ciudad, 
    pais
FROM cliente;

-- B) Llenar la Dimensión Producto
INSERT INTO Dim_Producto (Producto_Key, Codigo_Producto, Nombre_Producto, Categoria)
SELECT 
    p.ID_producto, 
    p.CodigoProducto, 
    p.nombre, 
    c.Desc_Categoria
FROM producto p
INNER JOIN Categoria_producto c ON p.Categoria = c.Id_Categoria;

-- C) Llenar la Dimensión Tiempo (Con la corrección matemática)
INSERT INTO Dim_Tiempo (Tiempo_Key, Fecha, Anio, Mes, Trimestre)
SELECT DISTINCT
    CAST(CONVERT(VARCHAR(8), fecha_pedido, 112) AS INT) AS Tiempo_Key,
    fecha_pedido AS Fecha,
    YEAR(fecha_pedido) AS Anio,
    MONTH(fecha_pedido) AS Mes,
    ((MONTH(fecha_pedido) - 1) / 3) + 1 AS Trimestre
FROM pedido
WHERE fecha_pedido IS NOT NULL;

