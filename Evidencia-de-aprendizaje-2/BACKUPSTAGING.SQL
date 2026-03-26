USE staging;

-- ============================================================
-- RECREACIÓN DE VISTAS DE MONITOREO (SEGURAS)
-- ============================================================

-- Vista 1: Resumen de Staging
CREATE OR REPLACE VIEW v_ResumenStaging AS
SELECT 'STG_Oficina' as Tabla, COUNT(*) as Registros, MAX(FechaCarga) as UltimaCarga, 'Dimensión Geográfica' as TipoTabla FROM STG_Oficina
UNION ALL SELECT 'STG_Empleado', COUNT(*), MAX(FechaCarga), 'Dimensión Organizacional' FROM STG_Empleado
UNION ALL SELECT 'STG_Categoria', COUNT(*), MAX(FechaCarga), 'Dimensión Producto' FROM STG_Categoria
UNION ALL SELECT 'STG_Cliente', COUNT(*), MAX(FechaCarga), 'Dimensión Cliente' FROM STG_Cliente
UNION ALL SELECT 'STG_Producto', COUNT(*), MAX(FechaCarga), 'Dimensión Producto' FROM STG_Producto
UNION ALL SELECT 'STG_Pedido', COUNT(*), MAX(FechaCarga), 'Hecho Transaccional' FROM STG_Pedido
UNION ALL SELECT 'STG_DetallePedido', COUNT(*), MAX(FechaCarga), 'Hecho Detallado' FROM STG_DetallePedido
UNION ALL SELECT 'STG_Pago', COUNT(*), MAX(FechaCarga), 'Hecho Financiero' FROM STG_Pago;

-- Vista 2: Validación de Integridad
CREATE OR REPLACE VIEW v_ValidacionIntegridad AS
SELECT 'Empleados con oficina inexistente' as Validacion, COUNT(*) as CantidadErrores, 'Error' as Severidad
FROM STG_Empleado e WHERE NOT EXISTS (SELECT 1 FROM STG_Oficina o WHERE o.ID_oficina = e.ID_oficina)
UNION ALL
SELECT 'Productos con categoría inexistente', COUNT(*), 'Critical'
FROM STG_Producto p WHERE NOT EXISTS (SELECT 1 FROM STG_Categoria c WHERE c.Id_Categoria = p.Categoria)
UNION ALL
SELECT 'Detalle con producto inexistente', COUNT(*), 'Critical'
FROM STG_DetallePedido dp WHERE NOT EXISTS (SELECT 1 FROM STG_Producto p WHERE p.ID_producto = dp.ID_producto);

-- Vista 3: Estadísticas de Negocio
CREATE OR REPLACE VIEW v_EstadisticasNegocio AS
SELECT 'Total Oficinas' as Metrica, COUNT(*) as Valor, 'Geográfica' as Categoria FROM STG_Oficina
UNION ALL SELECT 'Total Empleados', COUNT(*), 'Recursos Humanos' FROM STG_Empleado
UNION ALL SELECT 'Total Clientes', COUNT(*), 'CRM' FROM STG_Cliente
UNION ALL SELECT 'Total Productos', COUNT(*), 'Inventario' FROM STG_Producto
UNION ALL SELECT 'Total Pedidos', COUNT(*), 'Ventas' FROM STG_Pedido
UNION ALL SELECT 'Pedidos Entregados', COUNT(*), 'Ventas' FROM STG_Pedido WHERE estado = 'Entregado'
UNION ALL SELECT 'Total Pagos', COUNT(*), 'Finanzas' FROM STG_Pago;