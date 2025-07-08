-- 1
DELIMITER $$

CREATE TRIGGER prevent_stock
BEFORE INSERT 
ON ventas 
FOR EACH ROW 
BEGIN
  DECLARE stock_disponible INT;

  SELECT stock INTO stock_disponible
  FROM productos;

  IF NEW.cantidad > stock_disponible THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'stock no disponible';
  END IF;
END $$ 

DELIMITER ;
-- inserts para probar el trigger 
INSERT INTO productos (nombre, stock) VALUES ('Lapicero', 10);
INSERT INTO ventas (id_producto, cantidad) VALUES (1, 5);
INSERT INTO ventas (id_producto, cantidad) VALUES (1, 20); -- sale error


