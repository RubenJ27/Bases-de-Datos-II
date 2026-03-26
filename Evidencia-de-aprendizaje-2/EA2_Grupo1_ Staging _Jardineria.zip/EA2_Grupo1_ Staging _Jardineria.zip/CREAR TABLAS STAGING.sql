-- ============================================================
-- SCRIPT 02: CREAR TABLAS STAGING - MySQL (VERSIÓN DEFINITIVA)
-- ============================================================

USE Staging;

-- ============================================================
-- 0) LIMPIEZA PREVIA (Crucial para evitar el Error 1356)
-- Borramos las vistas ANTES de borrar las tablas
-- ============================================================
DROP VIEW IF EXISTS v_ResumenStaging;
DROP VIEW IF EXISTS v_ValidacionIntegridad;
DROP VIEW IF EXISTS v_EstadisticasNegocio;

-- ============================================================
-- 1) CREACIÓN DE TABLAS STG_* (Staging)
-- ============================================================

-- 1) STG_Oficina
DROP TABLE IF EXISTS STG_Oficina;
CREATE TABLE STG_Oficina (
    ID_oficina INT NOT NULL,
    Descripcion VARCHAR(10) NOT NULL,
    ciudad VARCHAR(30) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    region VARCHAR(50) NULL,
    codigo_postal VARCHAR(10) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    linea_direccion1 VARCHAR(50) NOT NULL,
    linea_direccion2 VARCHAR(50) NULL,
    FechaCarga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UsuarioCarga VARCHAR(100) NULL,
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria',
    PRIMARY KEY (ID_oficina),
    INDEX idx_pais (pais),
    INDEX idx_ciudad (ciudad),
    INDEX idx_fecha_carga (FechaCarga DESC)
) COMMENT='Staging - Oficinas de la empresa';

-- 2) STG_Empleado
DROP TABLE IF EXISTS STG_Empleado;
CREATE TABLE STG_Empleado (
    ID_empleado INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido1 VARCHAR(50) NOT NULL,
    apellido2 VARCHAR(50) NULL,
    extension VARCHAR(10) NOT NULL,
    email VARCHAR(100) NOT NULL,
    ID_oficina INT NOT NULL,
    ID_jefe INT NULL,
    puesto VARCHAR(50) NULL,
    FechaCarga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UsuarioCarga VARCHAR(100) NULL,
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria',
    PRIMARY KEY (ID_empleado),
    INDEX idx_oficina (ID_oficina),
    INDEX idx_jefe (ID_jefe),
    INDEX idx_puesto (puesto),
    INDEX idx_email (email),
    INDEX idx_fecha_carga (FechaCarga DESC)
) COMMENT='Staging - Empleados y estructura organizacional';

-- 3) STG_Categoria
DROP TABLE IF EXISTS STG_Categoria;
CREATE TABLE STG_Categoria (
    Id_Categoria INT NOT NULL,
    Desc_Categoria VARCHAR(50) NOT NULL,
    descripcion_texto TEXT NULL,
    descripcion_html TEXT NULL,
    imagen VARCHAR(256) NULL,
    FechaCarga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UsuarioCarga VARCHAR(100) NULL,
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria',
    PRIMARY KEY (Id_Categoria),
    INDEX idx_descripcion (Desc_Categoria),
    INDEX idx_fecha_carga (FechaCarga DESC)
)  COMMENT='Staging - Categorías de productos';

-- 4) STG_Cliente
DROP TABLE IF EXISTS STG_Cliente;
CREATE TABLE STG_Cliente (
    ID_cliente INT NOT NULL,
    nombre_cliente VARCHAR(50) NOT NULL,
    nombre_contacto VARCHAR(30) NULL,
    apellido_contacto VARCHAR(30) NULL,
    telefono VARCHAR(15) NOT NULL,
    fax VARCHAR(15) NOT NULL,
    linea_direccion1 VARCHAR(50) NOT NULL,
    linea_direccion2 VARCHAR(50) NULL,
    ciudad VARCHAR(50) NOT NULL,
    region VARCHAR(50) NULL,
    pais VARCHAR(50) NULL,
    codigo_postal VARCHAR(10) NULL,
    ID_empleado_rep_ventas INT NULL,
    limite_credito DECIMAL(15,2) NULL,
    FechaCarga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UsuarioCarga VARCHAR(100) NULL,
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria',
    PRIMARY KEY (ID_cliente),
    INDEX idx_pais (pais),
    INDEX idx_ciudad (ciudad),
    INDEX idx_empleado (ID_empleado_rep_ventas),
    INDEX idx_nombre (nombre_cliente),
    INDEX idx_fecha_carga (FechaCarga DESC)
)  COMMENT='Staging - Clientes de la empresa';

-- 5) STG_Producto
DROP TABLE IF EXISTS STG_Producto;
CREATE TABLE STG_Producto (
    ID_producto VARCHAR(15) NOT NULL,
    nombre VARCHAR(70) NOT NULL,
    Categoria INT NOT NULL,
    dimensiones VARCHAR(25) NULL,
    proveedor VARCHAR(50) NULL,
    descripcion TEXT NULL,
    cantidad_en_stock SMALLINT NOT NULL,
    precio_venta DECIMAL(15,2) NOT NULL,
    precio_proveedor DECIMAL(15,2) NULL,
    margen_beneficio DECIMAL(15,2) AS (precio_venta - precio_proveedor) STORED,
    porcentaje_margen DECIMAL(5,2) AS (
        CASE 
            WHEN precio_proveedor > 0 THEN ((precio_venta - precio_proveedor) / precio_proveedor * 100)
            ELSE 0
        END
    ) STORED,
    FechaCarga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UsuarioCarga VARCHAR(100) NULL,
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria',
    PRIMARY KEY (ID_producto),
    INDEX idx_categoria (Categoria),
    INDEX idx_proveedor (proveedor),
    INDEX idx_stock (cantidad_en_stock),
    INDEX idx_precio (precio_venta),
    INDEX idx_nombre (nombre),
    INDEX idx_fecha_carga (FechaCarga DESC)
)  COMMENT='Staging - Productos con márgenes calculados';

-- 6) STG_Pedido
DROP TABLE IF EXISTS STG_Pedido;
CREATE TABLE STG_Pedido (
    ID_pedido INT NOT NULL,
    fecha_pedido DATE NOT NULL,
    fecha_esperada DATE NOT NULL,
    fecha_entrega DATE NULL,
    estado VARCHAR(15) NOT NULL,
    comentarios TEXT NULL,
    ID_cliente INT NOT NULL,
    dias_retraso INT AS (
        CASE 
            WHEN fecha_entrega IS NOT NULL AND fecha_entrega > fecha_esperada 
            THEN DATEDIFF(fecha_entrega, fecha_esperada)
            ELSE 0
        END
    ) STORED,
    pedido_entregado BOOLEAN AS (estado = 'Entregado') STORED,
    FechaCarga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UsuarioCarga VARCHAR(100) NULL,
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria',
    PRIMARY KEY (ID_pedido),
    INDEX idx_cliente (ID_cliente),
    INDEX idx_fecha_pedido (fecha_pedido),
    INDEX idx_estado (estado),
    INDEX idx_fecha_entrega (fecha_entrega),
    INDEX idx_entregado (pedido_entregado),
    INDEX idx_fecha_carga (FechaCarga DESC)
) COMMENT='Staging - Pedidos con indicadores de cumplimiento';

-- 7) STG_DetallePedido
DROP TABLE IF EXISTS STG_DetallePedido;
CREATE TABLE STG_DetallePedido (
    ID_pedido INT NOT NULL,
    ID_producto VARCHAR(15) NOT NULL,
    cantidad INT NOT NULL,
    precio_unidad DECIMAL(15,2) NOT NULL,
    numero_linea SMALLINT NOT NULL,
    Importe DECIMAL(15,2) AS (cantidad * precio_unidad) STORED,
    FechaCarga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UsuarioCarga VARCHAR(100) NULL,
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria',
    PRIMARY KEY (ID_pedido, ID_producto),
    INDEX idx_pedido (ID_pedido),
    INDEX idx_producto (ID_producto),
    INDEX idx_importe (Importe DESC),
    INDEX idx_cantidad (cantidad),
    INDEX idx_fecha_carga (FechaCarga DESC)
)  COMMENT='Staging - Líneas de detalle de pedidos';

-- 8) STG_Pago
DROP TABLE IF EXISTS STG_Pago;
CREATE TABLE STG_Pago (
    ID_cliente INT NOT NULL,
    forma_pago VARCHAR(40) NOT NULL,
    id_transaccion VARCHAR(50) NOT NULL,
    fecha_pago DATE NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    FechaCarga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UsuarioCarga VARCHAR(100) NULL,
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria',
    PRIMARY KEY (ID_cliente, id_transaccion),
    INDEX idx_cliente (ID_cliente),
    INDEX idx_fecha_pago (fecha_pago),
    INDEX idx_forma_pago (forma_pago),
    INDEX idx_total (total DESC),
    INDEX idx_transaccion (id_transaccion),
    INDEX idx_fecha_carga (FechaCarga DESC)
) COMMENT='Staging - Pagos de clientes';

-- ============================================================
-- 2) TRIGGERS PARA AUTO-LLENAR UsuarioCarga
-- ============================================================

DELIMITER //
CREATE TRIGGER trg_STG_Oficina_Usuario BEFORE INSERT ON STG_Oficina
FOR EACH ROW BEGIN 
    IF NEW.UsuarioCarga IS NULL THEN 
        SET NEW.UsuarioCarga = USER(); 
    END IF; 
END//

CREATE TRIGGER trg_STG_Empleado_Usuario BEFORE INSERT ON STG_Empleado
FOR EACH ROW BEGIN 
    IF NEW.UsuarioCarga IS NULL THEN 
        SET NEW.UsuarioCarga = USER(); 
    END IF; 
END//

CREATE TRIGGER trg_STG_Categoria_Usuario BEFORE INSERT ON STG_Categoria
FOR EACH ROW BEGIN 
    IF NEW.UsuarioCarga IS NULL THEN 
        SET NEW.UsuarioCarga = USER(); 
    END IF; 
END//

CREATE TRIGGER trg_STG_Cliente_Usuario BEFORE INSERT ON STG_Cliente
FOR EACH ROW BEGIN 
    IF NEW.UsuarioCarga IS NULL THEN 
        SET NEW.UsuarioCarga = USER(); 
    END IF; 
END//

CREATE TRIGGER trg_STG_Producto_Usuario BEFORE INSERT ON STG_Producto
FOR EACH ROW BEGIN 
    IF NEW.UsuarioCarga IS NULL THEN 
        SET NEW.UsuarioCarga = USER(); 
    END IF; 
END//

CREATE TRIGGER trg_STG_Pedido_Usuario BEFORE INSERT ON STG_Pedido
FOR EACH ROW BEGIN 
    IF NEW.UsuarioCarga IS NULL THEN 
        SET NEW.UsuarioCarga = USER(); 
    END IF; 
END//

CREATE TRIGGER trg_STG_DetallePedido_Usuario BEFORE INSERT ON STG_DetallePedido
FOR EACH ROW BEGIN 
    IF NEW.UsuarioCarga IS NULL THEN 
        SET NEW.UsuarioCarga = USER(); 
    END IF; 
END//

CREATE TRIGGER trg_STG_Pago_Usuario BEFORE INSERT ON STG_Pago
FOR EACH ROW BEGIN 
    IF NEW.UsuarioCarga IS NULL THEN 
        SET NEW.UsuarioCarga = USER(); 
    END IF; 
END//

DELIMITER ;

-- ============================================================
-- 3) CREACIÓN DE VISTAS DE MONITOREO
-- (Usamos CREATE OR REPLACE para mayor seguridad)
-- ============================================================

-- Vista: Resumen de Staging
CREATE OR REPLACE VIEW v_ResumenStaging AS
SELECT 'STG_Oficina' as Tabla, COUNT(*) as Registros, MAX(FechaCarga) as UltimaCarga, 'Dimensión Geográfica' as TipoTabla FROM STG_Oficina
UNION ALL SELECT 'STG_Empleado', COUNT(*), MAX(FechaCarga), 'Dimensión Organizacional' FROM STG_Empleado
UNION ALL SELECT 'STG_Categoria', COUNT(*), MAX(FechaCarga), 'Dimensión Producto' FROM STG_Categoria
UNION ALL SELECT 'STG_Cliente', COUNT(*), MAX(FechaCarga), 'Dimensión Cliente' FROM STG_Cliente
UNION ALL SELECT 'STG_Producto', COUNT(*), MAX(FechaCarga), 'Dimensión Producto' FROM STG_Producto
UNION ALL SELECT 'STG_Pedido', COUNT(*), MAX(FechaCarga), 'Hecho Transaccional' FROM STG_Pedido
UNION ALL SELECT 'STG_DetallePedido', COUNT(*), MAX(FechaCarga), 'Hecho Detallado' FROM STG_DetallePedido
UNION ALL SELECT 'STG_Pago', COUNT(*), MAX(FechaCarga), 'Hecho Financiero' FROM STG_Pago;

-- Vista: Validación de Integridad
CREATE OR REPLACE VIEW v_ValidacionIntegridad AS
SELECT 'Empleados con oficina inexistente' as Validacion, COUNT(*) as CantidadErrores, 'Error' as Severidad
FROM STG_Empleado e WHERE NOT EXISTS (SELECT 1 FROM STG_Oficina o WHERE o.ID_oficina = e.ID_oficina)
UNION ALL
SELECT 'Productos con categoría inexistente', COUNT(*), 'Critical'
FROM STG_Producto p WHERE NOT EXISTS (SELECT 1 FROM STG_Categoria c WHERE c.Id_Categoria = p.Categoria)
UNION ALL
SELECT 'Detalle con producto inexistente', COUNT(*), 'Critical'
FROM STG_DetallePedido dp WHERE NOT EXISTS (SELECT 1 FROM STG_Producto p WHERE p.ID_producto = dp.ID_producto);

-- Vista: Estadísticas de Negocio
CREATE OR REPLACE VIEW v_EstadisticasNegocio AS
SELECT 'Total Oficinas' as Metrica, COUNT(*) as Valor, 'Geográfica' as Categoria FROM STG_Oficina
UNION ALL SELECT 'Total Empleados', COUNT(*), 'Recursos Humanos' FROM STG_Empleado
UNION ALL SELECT 'Total Clientes', COUNT(*), 'CRM' FROM STG_Cliente
UNION ALL SELECT 'Total Productos', COUNT(*), 'Inventario' FROM STG_Producto
UNION ALL SELECT 'Total Pedidos', COUNT(*), 'Ventas' FROM STG_Pedido
UNION ALL SELECT 'Pedidos Entregados', COUNT(*), 'Ventas' FROM STG_Pedido WHERE estado = 'Entregado'
UNION ALL SELECT 'Total Pagos', COUNT(*), 'Finanzas' FROM STG_Pago;

-- ============================================================
-- 4) RESUMEN FINAL
-- ============================================================

SELECT '============================================================' as '';
SELECT '          TABLAS Y VISTAS STAGING CREADAS EXITOSAMENTE' as Mensaje;
SELECT '============================================================' as '';
SELECT '' as '';
SELECT 'RESUMEN:' as '';
SELECT '  • 8 tablas STG_* creadas' as Item;
SELECT '  • 8 triggers automáticos creados' as Item;
SELECT '  • 3 vistas de monitoreo creadas y enlazadas' as Item;
SELECT '  • 40+ índices de optimización' as Item;
SELECT '  • Campos calculados en tablas clave' as Item;
SELECT '' as '';
SELECT ' Siguiente paso: 03_Cargar_Staging_MySQL.sql' as '';
SELECT '============================================================' as '';