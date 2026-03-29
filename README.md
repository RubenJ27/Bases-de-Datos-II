# 🏢 Data Warehouse de Recursos Humanos (RRHH) - Proyecto End-to-End

![SQL](https://img.shields.io/badge/SQL-Data_Warehouse-blue?style=for-the-badge&logo=mysql)
![ETL](https://img.shields.io/badge/ETL-Stored_Procedures-orange?style=for-the-badge)
![Analytics](https://img.shields.io/badge/Analytics-Business_Intelligence-success?style=for-the-badge)

Bienvenido a este repositorio. Este proyecto demuestra el ciclo de vida completo de la ingeniería de datos aplicado a un departamento de Recursos Humanos: desde la creación de un sistema transaccional (OLTP), pasando por el diseño de un modelo dimensional (Esquema en Estrella), hasta la construcción de procesos ETL y el análisis de datos (OLAP).

## 🎯 Objetivo del Proyecto
Transformar los datos operativos de una empresa ficticia (empleados, salarios, ausencias, capacitaciones y evaluaciones) en un **Data Warehouse** optimizado para consultas analíticas rápidas, permitiendo a los líderes de RRHH tomar decisiones basadas en datos.

---

## 🏗️ Arquitectura y Modelo de Datos

El Data Warehouse fue diseñado utilizando un **Esquema en Estrella (Star Schema)**, compuesto por:

* **5 Tablas de Dimensiones:** `DimEmpleado`, `DimDepartamento`, `DimOficina`, `DimPuesto` y `DimFecha` (Dimensión de tiempo generada automáticamente).
* **4 Tablas de Hechos:**
    * `FactSalarios`: Análisis de nómina y brecha salarial.
    * `FactAusencias`: Monitoreo de ausentismo y días perdidos.
    * `FactEvaluaciones`: Medición del desempeño del personal.
    * `FactCapacitaciones`: Control de inversión (ROI) y calificaciones de cursos.

---

## 📂 Estructura del Repositorio

El proyecto está dividido de forma secuencial para replicar el proceso paso a paso:

| Archivo | Descripción |
| :--- | :--- |
| `01_OLTP_RRHH.sql` | Creación de la base de datos transaccional original. |
| `02_Poblar_RRHH_OLTP.sql` | Inserción de datos de prueba (Mock data) en el OLTP. |
| `03_a_06_Crear_Dimensiones_y_Fecha.sql` | Creación del DWH y las tablas de Dimensiones. |
| `07_ETL_Cargar_Dimensiones.sql` | Procedimientos almacenados para ingestar datos a las dimensiones. |
| `Crear_Hechos.sql` | DDL para la creación de las tablas de hechos con llaves foráneas. |
| `08_ETL_Cargar_Hechos.sql` | Procedimientos almacenados para cruzar llaves y cargar las tablas de hechos. |
| `Validaciones_DWH.sql` | Scripts de Data Quality (búsqueda de duplicados, huérfanos, nulos). |
| `10_Consultas_Analiticas.sql` | 15 Queries de negocio (Gasto de nómina, ROI, Ausentismo, etc.). |

---

## ⚙️ Cómo ejecutar este proyecto

Si deseas replicar este proyecto en tu entorno local (DBeaver, MySQL Workbench, SQL Server, etc.), sigue estos pasos en orden:

1. **Clona el repositorio:**
   ```bash
   git clone [https://github.com/](https://github.com/)[TuUsuario]/[NombreDeTuRepo].git

