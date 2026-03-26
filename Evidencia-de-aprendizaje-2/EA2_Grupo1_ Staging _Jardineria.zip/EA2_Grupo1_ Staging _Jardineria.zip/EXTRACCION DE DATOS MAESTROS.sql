-- 1. Nos aseguramos de estar usando la base de datos de Staging
CREATE DATABASE IF NOT EXISTS staging;
USE staging;

-- ---------------------------------------------------------------------
-- EXTRACCIÓN DE DATOS MAESTROS
-- ---------------------------------------------------------------------

-- Tabla: Oficinas
DROP TABLE IF EXISTS stg_oficina;
CREATE TABLE stg_oficina AS 
SELECT * FROM jardineria.oficina;

-- Tabla: Empleados
DROP TABLE IF EXISTS stg_empleado;
CREATE TABLE stg_empleado AS 
SELECT * FROM jardineria.empleado;

-- Tabla: Clientes
DROP TABLE IF EXISTS stg_cliente;
CREATE TABLE stg_cliente AS 
SELECT * FROM jardineria.cliente;

-- Tabla: Categorías de Producto
DROP TABLE IF EXISTS stg_categoria_producto;
CREATE TABLE stg_categoria_producto AS 
SELECT * FROM jardineria.categoria_producto;

-- Tabla: Productos
DROP TABLE IF EXISTS stg_producto;
CREATE TABLE stg_producto AS 
SELECT * FROM jardineria.producto;

-- ---------------------------------------------------------------------
-- EXTRACCIÓN DE DATOS TRANSACCIONALES
-- ---------------------------------------------------------------------

-- Tabla: Pedidos
DROP TABLE IF EXISTS stg_pedido;
CREATE TABLE stg_pedido AS 
SELECT * FROM jardineria.pedido;

-- Tabla: Detalle de Pedidos
DROP TABLE IF EXISTS stg_detalle_pedido;
CREATE TABLE stg_detalle_pedido AS 
SELECT * FROM jardineria.detalle_pedido;

-- Tabla: Pagos
DROP TABLE IF EXISTS stg_pago;
CREATE TABLE stg_pago AS 
SELECT * FROM jardineria.pago;