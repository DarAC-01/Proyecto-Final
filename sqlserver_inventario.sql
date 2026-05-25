-- LIMPIAR TABLAS:

DELETE FROM detalle_pedidos;
DELETE FROM lotes_inventario;

DELETE FROM pedidos_compra;
DELETE FROM almacenes;
DELETE FROM proveedores;

DBCC CHECKIDENT ('detalle_pedidos', RESEED, 0);
DBCC CHECKIDENT ('pedidos_compra', RESEED, 0);
DBCC CHECKIDENT ('lotes_inventario', RESEED, 0);
DBCC CHECKIDENT ('almacenes', RESEED, 0);
DBCC CHECKIDENT ('proveedores', RESEED, 0);

--DDL

CREATE TABLE inventario_logistica_db.dbo.almacenes (
	id_almacen int IDENTITY(1,1) NOT NULL,
	nombre_sucursal varchar(75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	capacidad_mts2 varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT almacenes_pk PRIMARY KEY (id_almacen)
);

CREATE TABLE inventario_logistica_db.dbo.proveedores (
	id_proveedor int IDENTITY(1,1) NOT NULL,
	razon_social varchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	rfc_proveedor varchar(13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	telefono varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT proveedores_pk PRIMARY KEY (id_proveedor)
);

CREATE TABLE inventario_logistica_db.dbo.lotes_inventario (
	id_lote int IDENTITY(1,1) NOT NULL,
	id_producto_ref int NULL,
	id_proveedor int NULL,
	id_almacen int NULL,
	cantidad_stock varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	fecha_ingreso date NULL,
	CONSTRAINT lotes_inventario_pk PRIMARY KEY (id_lote),
	CONSTRAINT fk_lote_almacen FOREIGN KEY (id_almacen) REFERENCES inventario_logistica_db.dbo.almacenes(id_almacen),
	CONSTRAINT fk_lote_proveedor FOREIGN KEY (id_proveedor) REFERENCES inventario_logistica_db.dbo.proveedores(id_proveedor)
);


CREATE TABLE inventario_logistica_db.dbo.pedidos_compra (
	id_pedido int IDENTITY(1,1) NOT NULL,
	id_proveedor int NULL,
	fecha_pedido date NULL,
	estado_pedido varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT pedidos_compra_pk PRIMARY KEY (id_pedido),
	CONSTRAINT fk_pedido_proveedor FOREIGN KEY (id_proveedor) REFERENCES inventario_logistica_db.dbo.proveedores(id_proveedor)
);

CREATE TABLE inventario_logistica_db.dbo.detalle_pedidos (
	id_detalle_pedido int IDENTITY(1,1) NOT NULL,
	id_pedido int NULL,
	id_producto_ref int NULL,
	cantidad_solicitada varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	costo_unitario varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT detalle_pedidos_pk PRIMARY KEY (id_detalle_pedido),
	CONSTRAINT fk_det_pedido_padre FOREIGN KEY (id_pedido) REFERENCES inventario_logistica_db.dbo.pedidos_compra(id_pedido)
);

--==========================================================================40 consultas=================================================================================================
-- 41. Mostrar todos los proveedores
SELECT * FROM proveedores;

-- 42. Mostrar todos los almacenes de la ferretería
SELECT * FROM almacenes;

-- 43. Mostrar todos los lotes de inventario
SELECT * FROM lotes_inventario;

-- 44. Mostrar todos los pedidos de compra a proveedores
SELECT * FROM pedidos_compra;

-- 45. Contar cuántos lotes de inventario hay por cada almacén
SELECT id_almacen, COUNT(*) AS total_lotes 
FROM lotes_inventario 
GROUP BY id_almacen;

-- 46. Calcular el costo unitario promedio de los detalles de pedidos
SELECT AVG(TRY_CAST(costo_unitario AS DECIMAL(10,2))) AS costo_promedio 
FROM detalle_pedidos;

-- 47. Mostrar el pedido de compra más reciente
SELECT TOP 1 * FROM pedidos_compra 
ORDER BY fecha_pedido DESC;

-- 48. Mostrar lotes de inventario con cantidad_stock menor a 10 (para resurtir)
SELECT * FROM lotes_inventario 
WHERE TRY_CAST(cantidad_stock AS INT) < 10;

-- 49. Mostrar proveedores de la ciudad local (filtrando por LADA del teléfono)
SELECT * FROM proveedores 
WHERE telefono LIKE '222%';

-- 50. Sumar el total de mercancía solicitada en la tabla detalle_pedidos
SELECT SUM(TRY_CAST(cantidad_solicitada AS INT)) AS total_mercancia 
FROM detalle_pedidos;

-- 51. Mostrar proveedores cuya razón social sea 'Cemex'
SELECT * FROM proveedores 
WHERE razon_social = 'Cemex';

-- 52. Mostrar el TOP 5 de almacenes con mayor capacidad en metros cuadrados
SELECT TOP 5 * FROM almacenes 
ORDER BY TRY_CAST(capacidad_mts2 AS INT) DESC;

-- 53. Mostrar pedidos de compra en estado 'Pendiente'
SELECT * FROM pedidos_compra 
WHERE estado_pedido = 'Pendiente';

-- 54. Mostrar la longitud en caracteres de la razón social de cada proveedor (LEN)
SELECT 
    razon_social, 
    LEN(razon_social) AS longitud_nombre 
FROM proveedores;

-- 55. Contar cuántos pedidos se han hecho a cada proveedor
SELECT 
    id_proveedor, 
    COUNT(*) AS total_pedidos 
FROM pedidos_compra 
GROUP BY id_proveedor;

-- 56. Mostrar lotes de inventario que pertenezcan al almacén 1 o 2
SELECT * FROM lotes_inventario 
WHERE id_almacen IN (1, 2);

-- 57. Mostrar pedidos con fecha de pedido en este año (usando YEAR y GETDATE)
SELECT * FROM pedidos_compra 
WHERE YEAR(fecha_pedido) = YEAR(GETDATE());

-- 58. Mostrar los distintos estados de pedido registrados (DISTINCT)
SELECT DISTINCT estado_pedido 
FROM pedidos_compra;

-- 59. Mostrar almacenes ordenados por capacidad de menor a mayor
SELECT * FROM almacenes 
ORDER BY TRY_CAST(capacidad_mts2 AS INT) ASC;

-- 60. Mostrar detalles de pedidos ordenados por cantidad solicitada descendente
SELECT * FROM detalle_pedidos 
ORDER BY TRY_CAST(cantidad_solicitada AS INT) DESC;

-- 61. Mostrar los nombres de los proveedores en MAYÚSCULAS
SELECT UPPER(razon_social) AS proveedor_mayusculas 
FROM proveedores;

-- 62. Mostrar el costo unitario y un costo simulado con el 16% de IVA
SELECT 
    costo_unitario, 
    (TRY_CAST(costo_unitario AS DECIMAL(10,2)) * 1.16) AS costo_con_iva 
FROM detalle_pedidos;

-- 63. Mostrar los lotes correspondientes al producto de referencia 20
SELECT * FROM lotes_inventario 
WHERE id_producto_ref = 20;

-- 64. Mostrar los proveedores (ID) a los que se les han hecho más de 5 pedidos (HAVING)
SELECT 
    id_proveedor, 
    COUNT(*) AS total_pedidos 
FROM pedidos_compra 
GROUP BY id_proveedor 
HAVING COUNT(*) > 5;

-- 65. Agrupar por proveedor y contar cuántos lotes de stock nos han surtido
SELECT 
    id_proveedor, 
    COUNT(*) AS total_lotes_surtidos
FROM lotes_inventario
GROUP BY id_proveedor;

-- 66. Sumar la cantidad de stock total disponible en toda la ferretería
SELECT 
    SUM(TRY_CAST(cantidad_stock AS INT)) AS stock_total_ferreteria
FROM lotes_inventario;

-- 67. Mostrar los lotes ordenados por fecha de ingreso de más antiguo a más reciente
SELECT * FROM lotes_inventario
ORDER BY fecha_ingreso ASC;

-- 68. Mostrar proveedores a los que SÍ se les ha hecho un pedido (Subconsulta)
SELECT * FROM proveedores 
WHERE id_proveedor IN (
    SELECT id_proveedor 
    FROM pedidos_compra 
    WHERE id_proveedor IS NOT NULL
);

-- 69. Mostrar proveedores que NO tienen ningún pedido registrado (Subconsulta)
SELECT * FROM proveedores 
WHERE id_proveedor NOT IN (
    SELECT id_proveedor 
    FROM pedidos_compra 
    WHERE id_proveedor IS NOT NULL
);

-- 70. Mostrar los lotes almacenados en la sucursal 'Bodega Central' (Subconsulta)
SELECT * FROM lotes_inventario 
WHERE id_almacen = (
    SELECT id_almacen 
    FROM almacenes 
    WHERE nombre_sucursal = 'Bodega Central'
);

-- 71. Mostrar lotes cuyo stock esté por debajo del promedio general de stock
SELECT * FROM lotes_inventario 
WHERE TRY_CAST(cantidad_stock AS INT) < (
    SELECT AVG(TRY_CAST(cantidad_stock AS FLOAT)) 
    FROM lotes_inventario
);

-- 72. Mostrar los primeros 3 caracteres del RFC del proveedor usando SUBSTRING
SELECT 
    razon_social, 
    rfc_proveedor, 
    SUBSTRING(rfc_proveedor, 1, 3) AS rfc_inicio 
FROM proveedores;

-- 73. Mostrar el detalle de pedido con la menor cantidad solicitada
SELECT TOP 1 * FROM detalle_pedidos 
ORDER BY TRY_CAST(cantidad_solicitada AS INT) ASC;

-- 74. Contar cuántos IDs de productos distintos tenemos en lotes de inventario
SELECT COUNT(DISTINCT id_producto_ref) AS total_productos_distintos 
FROM lotes_inventario;

-- 75. Mostrar lotes de inventario con stock igual a 0
SELECT * FROM lotes_inventario 
WHERE TRY_CAST(cantidad_stock AS INT) = 0;

-- 76. Mostrar el TOP 1 del lote con mayor cantidad de unidades almacenadas
SELECT TOP 1 * FROM lotes_inventario 
ORDER BY TRY_CAST(cantidad_stock AS INT) DESC;

-- 77. Sumar las cantidades solicitadas en pedidos de estado 'Pendiente'
SELECT SUM(TRY_CAST(dp.cantidad_solicitada AS INT)) AS total_mercancia_pendiente
FROM detalle_pedidos dp
INNER JOIN pedidos_compra pc ON dp.id_pedido = pc.id_pedido
WHERE pc.estado_pedido = 'Pendiente';

-- 78. Mostrar proveedores con RFC que empiece con la letra 'A'
SELECT * FROM proveedores 
WHERE rfc_proveedor LIKE 'A%';

-- 79. Mostrar almacenes cuya capacidad supere los 500 mts2
SELECT * FROM almacenes 
WHERE TRY_CAST(capacidad_mts2 AS INT) > 500;

-- 80. Mostrar pedidos de compra realizados en el mes actual
SELECT * FROM pedidos_compra 
WHERE MONTH(fecha_pedido) = MONTH(GETDATE()) 
  AND YEAR(fecha_pedido) = YEAR(GETDATE());

--=================================================================================================JOINS====================================================================================
-- 11. Mostrar la sucursal del almacén y la cantidad en stock de sus lotes (INNER JOIN)
SELECT 
    a.nombre_sucursal, 
    li.cantidad_stock
FROM almacenes a
INNER JOIN lotes_inventario li ON a.id_almacen = li.id_almacen;

-- 12. Mostrar todos los proveedores y sumar la cantidad de stock que nos han surtido (LEFT JOIN)
SELECT 
    p.razon_social, 
    SUM(TRY_CAST(li.cantidad_stock AS INT)) AS total_stock_surtido
FROM proveedores p
LEFT JOIN lotes_inventario li ON p.id_proveedor = li.id_proveedor
GROUP BY p.id_proveedor, p.razon_social;

-- 13. Triple JOIN: Fecha del pedido, cantidad solicitada y la razón social del proveedor
SELECT 
    pc.fecha_pedido, 
    dp.cantidad_solicitada, 
    p.razon_social
FROM pedidos_compra pc
INNER JOIN detalle_pedidos dp ON pc.id_pedido = dp.id_pedido
INNER JOIN proveedores p ON pc.id_proveedor = p.id_proveedor;

-- 14. Mostrar almacenes que NO tienen lotes de inventario (LEFT JOIN)
SELECT 
    a.nombre_sucursal
FROM almacenes a
LEFT JOIN lotes_inventario li ON a.id_almacen = li.id_almacen
WHERE li.id_lote IS NULL;

-- 15. Agrupar por proveedor y contar cuántos pedidos de compra tienen
SELECT 
    p.razon_social, 
    COUNT(pc.id_pedido) AS total_pedidos
FROM proveedores p
LEFT JOIN pedidos_compra pc ON p.id_proveedor = pc.id_proveedor
GROUP BY p.id_proveedor, p.razon_social;

-- 16. Mostrar el estado del pedido y el costo unitario de su detalle
SELECT 
    pc.estado_pedido, 
    dp.costo_unitario
FROM pedidos_compra pc
INNER JOIN detalle_pedidos dp ON pc.id_pedido = dp.id_pedido;

-- 17. Contar cuántos lotes tiene cada almacén usando RIGHT JOIN
SELECT 
    a.nombre_sucursal, 
    COUNT(li.id_lote) AS total_lotes
FROM lotes_inventario li
RIGHT JOIN almacenes a ON li.id_almacen = a.id_almacen
GROUP BY a.id_almacen, a.nombre_sucursal;

-- 18. Mostrar pedidos en estado 'Pendiente' cruzados con la razón social del proveedor
SELECT 
    pc.id_pedido, 
    pc.fecha_pedido, 
    p.razon_social
FROM pedidos_compra pc
INNER JOIN proveedores p ON pc.id_proveedor = p.id_proveedor
WHERE pc.estado_pedido = 'Pendiente';

-- 19. Mostrar proveedores con RFC que empiece con 'C' y los lotes que surtieron
SELECT 
    p.razon_social, 
    p.rfc_proveedor, 
    li.id_lote, 
    li.cantidad_stock
FROM proveedores p
INNER JOIN lotes_inventario li ON p.id_proveedor = li.id_proveedor
WHERE p.rfc_proveedor LIKE 'C%';

-- 20. Mostrar proveedores a los que actualmente NO se les ha hecho ningún pedido de compra
SELECT 
    p.razon_social
FROM proveedores p
LEFT JOIN pedidos_compra pc ON p.id_proveedor = pc.id_proveedor
WHERE pc.id_pedido IS NULL;


--================================================================================================TRIGGERS==================================================================================
-- 8. TRG_Stock_Negativo: Evitar stock por debajo de 0 en lotes_inventario
CREATE TRIGGER TRG_Stock_Negativo
ON lotes_inventario
AFTER UPDATE
AS
BEGIN

    IF EXISTS (SELECT 1 FROM inserted WHERE TRY_CAST(cantidad_stock AS INT) < 0)
    BEGIN
        RAISERROR ('Operación cancelada. El stock no puede ser negativo.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


-- 9. TRG_Impide_Borrado_Almacen: Impedir que se eliminen almacenes
CREATE TRIGGER TRG_Impide_Borrado_Almacen
ON almacenes
AFTER DELETE
AS
BEGIN

    RAISERROR ('No está permitido eliminar almacenes para evitar dejar inventario huérfano.', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO


-- 10. TRG_Valida_Telefono: Validar que el teléfono del proveedor tenga >= 10 caracteres
CREATE TRIGGER TRG_Valida_Telefono
ON proveedores
AFTER INSERT, UPDATE
AS
BEGIN
   
    IF EXISTS (SELECT 1 FROM inserted WHERE LEN(ISNULL(telefono, '')) < 10)
    BEGIN
        RAISERROR ('el número de teléfono del proveedor debe tener al menos 10 caracteres', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


-- 11. TRG_Costo_Cero: Si el costo unitario es <= 0, forzarlo a 10
CREATE TRIGGER TRG_Costo_Cero
ON detalle_pedidos
INSTEAD OF INSERT
AS
BEGIN

    INSERT INTO detalle_pedidos (id_pedido, id_producto_ref, cantidad_solicitada, costo_unitario)
    SELECT 
        id_pedido, 
        id_producto_ref, 
        cantidad_solicitada, 
        CASE 
            WHEN TRY_CAST(costo_unitario AS DECIMAL(10,2)) <= 0 THEN '10' 
            ELSE costo_unitario 
        END
    FROM inserted;
END;
GO


-- 12. TRG_Log_Lote_Agotado: Alertar si el stock llega a 0
IF OBJECT_ID('resurtido_urgente', 'U') IS NULL
BEGIN
    CREATE TABLE resurtido_urgente (
        id_alerta int IDENTITY(1,1) PRIMARY KEY,
        id_lote int,
        fecha_alerta datetime DEFAULT GETDATE()
    );
END;
GO

CREATE TRIGGER TRG_Log_Lote_Agotado
ON lotes_inventario
AFTER UPDATE
AS
BEGIN

    IF EXISTS (SELECT 1 FROM inserted WHERE TRY_CAST(cantidad_stock AS INT) = 0)
    BEGIN
        INSERT INTO resurtido_urgente (id_lote)
        SELECT id_lote FROM inserted WHERE TRY_CAST(cantidad_stock AS INT) = 0;
    END
END;
GO


-- 13. TRG_Impide_Baja_Proveedor: No borrar proveedor si tiene pedidos 'Pendiente'
CREATE TRIGGER TRG_Impide_Baja_Proveedor
ON proveedores
AFTER DELETE
AS
BEGIN
   
    IF EXISTS (
        SELECT 1 
        FROM deleted d
        INNER JOIN pedidos_compra pc ON d.id_proveedor = pc.id_proveedor
        WHERE pc.estado_pedido = 'Pendiente'
    )
    BEGIN
        RAISERROR ('no se puede eliminar al proveedor porque tiene pedidos en estado Pendiente.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


-- 14. TRG_Formato_RFC_Proveedor: Longitud de RFC estrictamente de 12 o 13
CREATE TRIGGER TRG_Formato_RFC_Proveedor
ON proveedores
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE LEN(ISNULL(rfc_proveedor, '')) NOT IN (12, 13)
    )
    BEGIN
        RAISERROR ('el RFC del proveedor debe tener exactamente 12 o 13 caracteres.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


