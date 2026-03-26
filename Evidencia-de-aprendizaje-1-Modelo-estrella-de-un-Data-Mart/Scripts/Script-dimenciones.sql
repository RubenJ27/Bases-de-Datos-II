USE jardineria;
GO

-- ==========================================
-- 1. PRIMERO CREAMOS LAS DIMENSIONES (Los Catálogos)
-- ==========================================

-- Dimensión Producto
CREATE TABLE Dim_Producto (
    Producto_Key INT PRIMARY KEY, 
    Codigo_Producto VARCHAR(15),
    Nombre_Producto VARCHAR(70),
    Categoria VARCHAR(50) 
);

-- Dimensión Tiempo
CREATE TABLE Dim_Tiempo (
    Tiempo_Key INT PRIMARY KEY, 
    Fecha DATE,
    Anio INT,
    Mes INT,
    Trimestre INT
);

-- Dimensión Cliente (Opcional pero recomendada para el modelo estrella)
CREATE TABLE Dim_Cliente (
    Cliente_Key INT PRIMARY KEY,
    Nombre_Cliente VARCHAR(50),
    Ciudad VARCHAR(50),
    Pais VARCHAR(50)
);

