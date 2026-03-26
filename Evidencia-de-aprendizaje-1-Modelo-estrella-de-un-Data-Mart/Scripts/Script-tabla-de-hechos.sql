USE jardineria;
GO

-- ==========================================
-- 2. DESPUÉS CREAMOS LA TABLA DE HECHOS (El Ticket)
-- ==========================================

CREATE TABLE Fact_Ventas (
    Venta_ID INT IDENTITY(1,1) PRIMARY KEY,
    Producto_Key INT NOT NULL,  
    Tiempo_Key INT NOT NULL,    
    Cliente_Key INT NOT NULL,   
    Cantidad_Vendida INT NOT NULL,        
    Precio_Unidad DECIMAL(15,2) NOT NULL, 
    Monto_Total AS (Cantidad_Vendida * Precio_Unidad),

    CONSTRAINT FK_FactVentas_Producto FOREIGN KEY (Producto_Key) REFERENCES Dim_Producto(Producto_Key),
    CONSTRAINT FK_FactVentas_Tiempo FOREIGN KEY (Tiempo_Key) REFERENCES Dim_Tiempo(Tiempo_Key),
    CONSTRAINT FK_FactVentas_Cliente FOREIGN KEY (Cliente_Key) REFERENCES Dim_Cliente(Cliente_Key)
);