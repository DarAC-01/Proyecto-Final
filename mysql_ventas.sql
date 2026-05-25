-- LIMPIAR TABLAS:

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE detalle_ventas;
TRUNCATE TABLE ventas_mostrador;
TRUNCATE TABLE productos;
TRUNCATE TABLE categorias;
TRUNCATE TABLE clientes;

SET FOREIGN_KEY_CHECKS = 1;

--DDL

CREATE TABLE `categorias` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `nombre_categoria` varchar(150) DEFAULT NULL,
  `pasillo` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `clientes` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `nombre_completo` varchar(100) DEFAULT NULL,
  `rfc` varchar(100) DEFAULT NULL,
  `telefono` varchar(10) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `productos` (
  `id_producto` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(75) DEFAULT NULL,
  `marca` varchar(50) DEFAULT NULL,
  `id_categoria` int NOT NULL,
  `precio_unitario` varchar(15) DEFAULT NULL,
  `tipo_venta` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id_producto`),
  KEY `fk_producto_categoria` (`id_categoria`),
  CONSTRAINT `fk_producto_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `ventas_mostrador` (
  `id_venta` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int DEFAULT NULL,
  `fecha_venta` date DEFAULT NULL,
  `total_venta` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id_venta`),
  KEY `fk_venta_cliente` (`id_cliente`),
  CONSTRAINT `fk_venta_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `detalle_ventas` (
  `id_detalle` int NOT NULL AUTO_INCREMENT,
  `id_venta` int DEFAULT NULL,
  `id_producto` int DEFAULT NULL,
  `cantidad` varchar(25) DEFAULT NULL,
  `subtotal` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `fk_detalle_venta` (`id_venta`),
  KEY `fk_detalle_producto` (`id_producto`),
  CONSTRAINT `fk_detalle_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`),
  CONSTRAINT `fk_detalle_venta` FOREIGN KEY (`id_venta`) REFERENCES `ventas_mostrador` (`id_venta`)
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--=============================================================================================40 consultas=================================================================================================

-- 1. Mostrar todos los productos
SELECT * FROM productos;

-- 2. Mostrar todas las categorías
SELECT * FROM categorias;

-- 3. Mostrar todos los clientes
SELECT * FROM clientes;

-- 4. Ventas realizadas hoy
SELECT * FROM ventas_mostrador WHERE fecha_venta = CURDATE();

-- 5. Contar productos a 'unidad' o 'Kilo'
SELECT COUNT(*) FROM productos WHERE tipo_venta IN ('unidad', 'kilo');

-- 6. Productos con precio mayor a $500
SELECT * FROM productos WHERE precio_unitario > 500;

-- 7. Producto más barato
SELECT * FROM productos ORDER BY precio_unitario ASC LIMIT 1;

-- 8. Clientes con correo 'example.com'
SELECT * FROM clientes WHERE email LIKE '%@example.com';

-- 9. Contar productos por categoría
SELECT id_categoria, COUNT(*) FROM productos GROUP BY id_categoria;

-- 10. Ventas mayores a $2,000
SELECT * FROM ventas_mostrador WHERE total_venta > 2000;

-- 11. Clientes que empiezan con 'H'
SELECT * FROM clientes WHERE nombre_completo LIKE 'H%';

-- 12. Productos 'Truper' o 'Bosch'
SELECT * FROM productos WHERE marca IN ('truper', 'bosch');

-- 13. Productos de categorías 1, 3 o 5
SELECT * FROM productos WHERE id_categoria IN (1, 3, 5);

-- 14. Ventas del último trimestre (ejemplo fechas actuales)
SELECT * FROM ventas_mostrador WHERE fecha_venta BETWEEN '2026-02-01' AND '2026-04-30';

-- 15. Primeros 15 productos alfabéticamente
SELECT * FROM productos ORDER BY nombre ASC LIMIT 15;

-- 16. Ventas realizadas por cada cliente
SELECT id_cliente, COUNT(*) AS total_ventas FROM ventas_mostrador GROUP BY id_cliente;

-- 16. Contar cuántas ventas ha realizado cada cliente (con nombre del cliente)
SELECT c.nombre_completo, COUNT(v.id_venta) AS total_ventas
FROM clientes c
LEFT JOIN ventas_mostrador v ON c.id_cliente = v.id_cliente
GROUP BY c.nombre_completo;

-- 17. Mostrar categorías ubicadas en el pasillo 4
SELECT * FROM categorias WHERE pasillo = 4;

-- 18. Mostrar productos que se venden por 'Metro'
SELECT * FROM productos WHERE tipo_venta = 'metro';

-- 19. Mostrar los distintos tipos de venta registrados (DISTINCT)
SELECT DISTINCT tipo_venta FROM productos;

-- 20. Mostrar ventas donde el total sea exactamente $100
SELECT * FROM ventas_mostrador WHERE total_venta = 100;

-- 21. Contar cuántos productos tiene la marca 'Pretul'
SELECT COUNT(*) AS total_pretul FROM productos WHERE marca = 'pretul';

-- 22. Mostrar categorías con más de 15 productos registrados (HAVING)
SELECT id_categoria, COUNT(*) AS total_productos
FROM productos
GROUP BY id_categoria
HAVING total_productos > 15;

-- 23. Mostrar la longitud del nombre de cada cliente
SELECT nombre_completo, LENGTH(nombre_completo) AS longitud_nombre FROM clientes;

-- 24. Nombres de productos en MAYÚSCULAS
SELECT UPPER(nombre) AS nombre_mayusculas FROM productos;

-- 25. Los 10 clientes más recientes (suponiendo que ID creciente indica antigüedad)
SELECT * FROM clientes ORDER BY id_cliente DESC LIMIT 10;

-- 26. Ventas ordenadas por fecha (desc) y total
SELECT * FROM ventas_mostrador ORDER BY fecha_venta DESC, total_venta DESC;

-- 27. Clientes con al menos una compra (Subconsulta)
SELECT * FROM clientes WHERE id_cliente IN (SELECT DISTINCT id_cliente FROM ventas_mostrador);

-- 28. Clientes que NUNCA han comprado (Subconsulta)
SELECT * FROM clientes WHERE id_cliente NOT IN (SELECT DISTINCT id_cliente FROM ventas_mostrador);

-- 29. Productos de la categoría 'Herramienta Eléctrica' (Subconsulta)
SELECT * FROM productos WHERE id_categoria = (SELECT id_categoria FROM categorias WHERE nombre_categoria = 'herramienta eléctrica');

-- 30. Total de ventas agrupadas por mes
SELECT MONTH(fecha_venta) AS mes, SUM(total_venta) AS ingresos_mes FROM ventas_mostrador GROUP BY mes;

-- 31. Productos ordenados por precio de mayor a menor
SELECT * FROM productos ORDER BY precio_unitario DESC;

-- 32. Extraer el día de la fecha de las ventas
SELECT id_venta, DAY(fecha_venta) AS dia_venta FROM ventas_mostrador;

-- 33. Concatenar producto y marca
SELECT CONCAT(nombre, ' - ', marca) AS producto_marca FROM productos;

-- 34. Detalle de venta con la mayor cantidad de artículos
SELECT * FROM detalle_ventas ORDER BY cantidad DESC LIMIT 1;

-- 35. Clientes que han gastado más que el promedio
SELECT id_cliente, SUM(total_venta) AS gasto_total FROM ventas_mostrador 
GROUP BY id_cliente 
HAVING gasto_total > (SELECT AVG(total_venta) FROM ventas_mostrador);

-- 36. Artículos distintos en la venta con ID 5
SELECT COUNT(DISTINCT id_producto) FROM detalle_ventas WHERE id_venta = 5;

-- 37. IDs de categorías sin productos
SELECT id_categoria FROM categorias WHERE id_categoria NOT IN (SELECT DISTINCT id_categoria FROM productos);

-- 38. Producto más caro
SELECT * FROM productos ORDER BY precio_unitario DESC LIMIT 1;

-- 39. Suma de ingresos por ventas en el mes actual
SELECT SUM(total_venta) FROM ventas_mostrador WHERE MONTH(fecha_venta) = MONTH(CURRENT_DATE());

-- 40. Productos que contienen 'Tornillo'
SELECT * FROM productos WHERE nombre LIKE '%Tornillo%';

--================================================================================================JOINS===================================================================================================


--1. Mostrar el nombre del producto y el nombre de su categoría
SELECT 
    p.nombre AS nombre_producto, 
    c.nombre_categoria 
FROM productos p 
INNER JOIN categorias c 
    ON p.id_categoria = c.id_categoria;


--2. Mostrar todas las categorías y cuántos productos tienen
SELECT 
    c.nombre_categoria, 
    COUNT(p.id_producto) AS total_productos
FROM categorias c 
LEFT JOIN productos p 
    ON c.id_categoria = p.id_categoria
GROUP BY c.nombre_categoria;


--3. Mostrar el ID de la venta, la cantidad y el nombre del producto vendido
SELECT 
    dv.id_venta, 
    dv.cantidad, 
    p.nombre AS nombre_producto
FROM detalle_ventas dv 
INNER JOIN productos p 
    ON dv.id_producto = p.id_producto;


--4. Triple JOIN: cliente, fecha de venta y producto comprado
SELECT 
    cl.nombre_completo, 
    v.fecha_venta, 
    p.nombre AS nombre_producto
FROM clientes cl
INNER JOIN ventas_mostrador v 
    ON cl.id_cliente = v.id_cliente
INNER JOIN detalle_ventas dv 
    ON v.id_venta = dv.id_venta
INNER JOIN productos p 
    ON dv.id_producto = p.id_producto;


--5. Mostrar categorías que NO tienen productos asignados
SELECT 
    c.nombre_categoria
FROM categorias c
LEFT JOIN productos p 
    ON c.id_categoria = p.id_categoria
WHERE p.id_producto IS NULL;


--6. Mostrar el nombre del cliente y la suma total de sus compras
SELECT 
    cl.nombre_completo, 
    SUM(v.total_venta) AS gran_total_compras
FROM clientes cl
INNER JOIN ventas_mostrador v 
    ON cl.id_cliente = v.id_cliente
GROUP BY cl.id_cliente, cl.nombre_completo;


--7. Mostrar productos que NUNCA se han vendido
SELECT 
    p.nombre AS producto_sin_ventas
FROM productos p
LEFT JOIN detalle_ventas dv 
    ON p.id_producto = dv.id_producto
WHERE dv.id_producto IS NULL;


--8. Mostrar ventas cuyo cliente tiene correo de example.com
SELECT 
    v.id_venta, 
    v.fecha_venta, 
    cl.nombre_completo, 
    cl.email
FROM ventas_mostrador v
INNER JOIN clientes cl 
    ON v.id_cliente = cl.id_cliente
WHERE cl.email LIKE '%@example.com';


--9. Mostrar todos los productos aunque no tengan categoría
SELECT 
    c.nombre_categoria, 
    p.nombre AS nombre_producto
FROM categorias c
RIGHT JOIN productos p 
    ON c.id_categoria = p.id_categoria;


--10. Triple JOIN: categoría, producto y cantidad vendida
SELECT 
    c.nombre_categoria, 
    p.nombre AS nombre_producto, 
    dv.cantidad
FROM categorias c
INNER JOIN productos p 
    ON c.id_categoria = p.id_categoria
INNER JOIN detalle_ventas dv 
    ON p.id_producto = dv.id_producto;

--===============================================================================================TRIGGERS=================================================================================================

-- 1. TRG_Precio_Valido
DELIMITER //
CREATE TRIGGER TRG_Precio_Valido
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    IF NEW.precio_unitario <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El precio debe ser mayor a 0';
    END IF;
END;
//
DELIMITER ;

-- 2. TRG_Valida_Venta_Unidad
DELIMITER //
CREATE TRIGGER TRG_Valida_Venta_Unidad
BEFORE INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    DECLARE v_tipo VARCHAR(50);
    SELECT tipo_venta INTO v_tipo FROM productos WHERE id_producto = NEW.id_producto;
    
    IF v_tipo = 'Unidad' AND NEW.cantidad <> ROUND(NEW.cantidad) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'en ventas por unidad no se permiten decimales';
    END IF;
END;
//
DELIMITER ;

-- 3. TRG_Mayusculas_Cliente
DELIMITER //
CREATE TRIGGER TRG_Mayusculas_Cliente
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
    SET NEW.nombre_completo = UPPER(NEW.nombre_completo);
END;
//
DELIMITER ;


--4. TRG_Impide_Baja_Categoria -Evita borrar una categoría que aún tiene productos registrados para mantener la integridad referencial.
DELIMITER //
CREATE TRIGGER TRG_Impide_Baja_Categoria
BEFORE DELETE ON categorias
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM productos WHERE id_categoria = OLD.id_categoria;
    
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'no se puede borrar la categoría porque tiene productos asignados';
    END IF;
END;
//
DELIMITER ;

--5. TRG_Calcula_Subtotal - Calcula automáticamente el subtotal en detalle_ventas al momento de insertar un nuevo registro.
DELIMITER //
CREATE TRIGGER TRG_Calcula_Subtotal
BEFORE INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    SELECT precio_unitario INTO v_precio FROM productos WHERE id_producto = NEW.id_producto;
    SET NEW.subtotal = NEW.cantidad * v_precio;
END;
//
DELIMITER ;


--6. TRG_Actualiza_Total_Venta - ctualiza el total_venta en la tabla ventas_mostrador sumando el subtotal del nuevo detalle.
DELIMITER //

CREATE TRIGGER TRG_Actualiza_Total_Venta
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE ventas_mostrador
    SET total_venta = (
        SELECT SUM(subtotal)
        FROM detalle_ventas
        WHERE id_venta = NEW.id_venta
    )
    WHERE id_venta = NEW.id_venta;
END;
//

DELIMITER ;


--7. TRG_Cero_Ventas_Pasadas - Valida que la fecha de la venta no sea anterior al año 2020.
DELIMITER //
CREATE TRIGGER TRG_Cero_Ventas_Pasadas
BEFORE INSERT ON ventas_mostrador
FOR EACH ROW
BEGIN
    IF YEAR(NEW.fecha_venta) < 2020 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'no se permiten ventas con fecha anterior al 2020';
    END IF;
END;
//
DELIMITER ;
