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



-- 2
DELIMITER $$

CREATE TRIGGER registro_salarios
BEFORE UPDATE
ON empleados 
FOR EACH ROW
BEGIN 
  IF NEW.salario IS NOT NULL THEN 
    INSERT INTO historial_salarios(id_empleado,salario_anterior,salario_nuevo)
    VALUES (
      -- el old agarra la insersion de la tabla anterior
      OLD.id,
      OLD.salario,
      -- el new coge los valores de la tabla nueva 
      NEW.salario
    );
  END IF;
END $$  

DELIMITER ;
-- probar el tirgger 
INSERT INTO empleados (nombre, salario) VALUES ('Laura Méndez', 2500.00);
UPDATE empleados SET salario = 3000.00 WHERE id = 1;
SELECT * FROM historial_salarios;



-- 3
DELIMITER $$

CREATE TRIGGER eliminar_cliente
AFTER DELETE 
ON clientes 
FOR EACH ROW
BEGIN 
  INSERT INTO clientes_auditoria(id_cliente,nombre,email)
  VALUES (
    OLD.id,
    OLD.nombre,
    OLD.email 
  );
END $$

DELIMITER ;
-- probar trigger
INSERT INTO clientes (nombre, email) VALUES ('Pedro', 'juanito@gmail.com'),('Lucía', 'nose@1234'),('Roberto', 'sadfl@1234');
SELECT * FROM clientes;
DELETE FROM clientes WHERE id = 2;
SELECT * FROM clientes_auditoria;



-- 4
DELIMITER $$

CREATE TRIGGER evitar_eliminar
BEFORE DELETE 
ON pedidos 
FOR EACH ROW 
BEGIN
  IF NEW.precio < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El producto no puede ser encargado';
  END IF;
END $$

DELIMITER ;
-- PROBAR trigger
