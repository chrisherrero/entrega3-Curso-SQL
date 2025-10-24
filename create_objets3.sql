
CREATE DATABASE Ludoteca_entrega3 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE Ludoteca_entrega3;

CREATE TABLE Categoria (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL UNIQUE,
  descripcion TEXT
);

CREATE TABLE Etiqueta (
  id_etiqueta INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Autor (
  id_autor INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL
);

CREATE TABLE Editorial (
  id_editorial INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL
);

CREATE TABLE Sede (
  id_sede INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(255)
);

CREATE TABLE Juego (
  id_juego INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(150) NOT NULL,
  id_categoria INT,
  id_autor INT,
  id_editorial INT,
  anio_publicacion YEAR,
  copias INT NOT NULL DEFAULT 1,
  copias_disponibles INT NOT NULL DEFAULT 1,
  duracion_min INT,
  edad_min INT,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_juego_categoria FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
  CONSTRAINT fk_juego_autor FOREIGN KEY (id_autor) REFERENCES Autor(id_autor),
  CONSTRAINT fk_juego_editorial FOREIGN KEY (id_editorial) REFERENCES Editorial(id_editorial)
);

CREATE TABLE Juego_Etiqueta (
  id_juego INT,
  id_etiqueta INT,
  PRIMARY KEY (id_juego, id_etiqueta),
  CONSTRAINT fk_je_juego FOREIGN KEY (id_juego) REFERENCES Juego(id_juego) ON DELETE CASCADE,
  CONSTRAINT fk_je_etiqueta FOREIGN KEY (id_etiqueta) REFERENCES Etiqueta(id_etiqueta) ON DELETE CASCADE
);

CREATE TABLE Usuario (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(60) NOT NULL,
  apellido VARCHAR(60) NOT NULL,
  telefono VARCHAR(30),
  email VARCHAR(120) UNIQUE,
  documento VARCHAR(30) UNIQUE,
  registrado_en DATETIME,
  activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Empleado (
  id_empleado INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80),
  apellido VARCHAR(80),
  puesto VARCHAR(80),
  id_sede INT,
  CONSTRAINT fk_empleado_sede FOREIGN KEY (id_sede) REFERENCES Sede(id_sede)
);

CREATE TABLE Prestamo (
  id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_juego INT NOT NULL,
  id_empleado INT,
  fecha_prestamo DATE NOT NULL,
  fecha_devolucion DATE,
  devuelto BOOLEAN DEFAULT FALSE,
  observaciones TEXT,
  fecha_limite_devolucion DATE,
  id_sede_prestamo INT,
  CONSTRAINT fk_prestamo_usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
  CONSTRAINT fk_prestamo_juego FOREIGN KEY (id_juego) REFERENCES Juego(id_juego),
  CONSTRAINT fk_prestamo_empleado FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
  CONSTRAINT fk_prestamo_sede FOREIGN KEY (id_sede_prestamo) REFERENCES Sede(id_sede)
);

CREATE TABLE Pago (
  id_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  fecha_pago DATE,
  tipo_pago ENUM('donacion','cuota','multa') NOT NULL,
  descripcion VARCHAR(255),
  CONSTRAINT fk_pago_usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Multa (
  id_multa INT AUTO_INCREMENT PRIMARY KEY,
  id_prestamo INT,
  monto DECIMAL(10,2) NOT NULL,
  motivo VARCHAR(255),
  pagada BOOLEAN DEFAULT FALSE,
  CONSTRAINT fk_multa_prestamo FOREIGN KEY (id_prestamo) REFERENCES Prestamo(id_prestamo)
);

CREATE TABLE Reserva (
  id_reserva INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_juego INT NOT NULL,
  fecha_reserva DATE NOT NULL,
  vigente BOOLEAN DEFAULT TRUE,
  CONSTRAINT fk_reserva_usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
  CONSTRAINT fk_reserva_juego FOREIGN KEY (id_juego) REFERENCES Juego(id_juego)
);

CREATE TABLE DevolucionLog (
  id_log INT AUTO_INCREMENT PRIMARY KEY,
  id_prestamo INT,
  fecha_devolucion DATE,
  id_empleado INT,
  observacion TEXT,
  CONSTRAINT fk_log_prestamo FOREIGN KEY (id_prestamo) REFERENCES Prestamo(id_prestamo),
  CONSTRAINT fk_log_empleado FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);

CREATE TABLE EstadisticaPrestamo (
  id_estadistica INT AUTO_INCREMENT PRIMARY KEY,
  id_juego INT NOT NULL,
  anio INT NOT NULL,
  mes TINYINT NOT NULL,
  prestamos INT DEFAULT 0,
  devoluciones INT DEFAULT 0,
  CONSTRAINT fk_estadistica_juego FOREIGN KEY (id_juego) REFERENCES Juego(id_juego),
  UNIQUE KEY uk_estadistica_juego_periodo (id_juego, anio, mes)
);

CREATE TABLE Donacion (
  id_donacion INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT,
  monto DECIMAL(10,2),
  fecha_donacion DATE,
  descripcion VARCHAR(255),
  CONSTRAINT fk_donacion_usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Evento (
  id_evento INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150),
  fecha_evento DATE,
  lugar VARCHAR(255),
  descripcion TEXT
);

CREATE TABLE HechoPrestamo (
  id_hecho INT AUTO_INCREMENT PRIMARY KEY,
  id_prestamo INT,
  id_juego INT,
  id_usuario INT,
  fecha_evento DATE,
  tipo_evento ENUM('prestamo','devolucion') NOT NULL,
  duracion_dias INT,
  multa_aplicada DECIMAL(10,2) DEFAULT 0,
  CONSTRAINT fk_hecho_prestamo FOREIGN KEY (id_prestamo) REFERENCES Prestamo(id_prestamo),
  CONSTRAINT fk_hecho_juego FOREIGN KEY (id_juego) REFERENCES Juego(id_juego),
  CONSTRAINT fk_hecho_usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE INDEX idx_juego_titulo ON Juego(titulo);
CREATE INDEX idx_usuario_email ON Usuario(email);
CREATE INDEX idx_prestamo_usuario_devuelto ON Prestamo(id_usuario, devuelto);
CREATE INDEX idx_estadistica_periodo ON EstadisticaPrestamo(anio, mes);

CREATE VIEW vista_prestamos_activos AS
SELECT p.id_prestamo, p.id_usuario, u.nombre, u.apellido, p.id_juego, j.titulo, p.fecha_prestamo, p.fecha_limite_devolucion, p.observaciones
FROM Prestamo p
JOIN Usuario u ON p.id_usuario = u.id_usuario
JOIN Juego j ON p.id_juego = j.id_juego
WHERE p.devuelto = FALSE;

CREATE VIEW vista_catalogo_publico AS
SELECT j.id_juego, j.titulo, c.nombre AS categoria, j.anio_publicacion, j.copias_disponibles
FROM Juego j
LEFT JOIN Categoria c ON j.id_categoria = c.id_categoria;

CREATE VIEW vista_usuarios_prestamos_count AS
SELECT u.id_usuario, u.nombre, u.apellido, COUNT(p.id_prestamo) AS prestamos_activos
FROM Usuario u
LEFT JOIN Prestamo p ON u.id_usuario = p.id_usuario AND p.devuelto = FALSE
GROUP BY u.id_usuario;

CREATE VIEW vista_estadisticas_mensuales AS
SELECT e.id_juego, j.titulo, e.anio, e.mes, e.prestamos, e.devoluciones
FROM EstadisticaPrestamo e
JOIN Juego j ON e.id_juego = j.id_juego;

CREATE VIEW vista_juegos_populares AS
SELECT e.id_juego, j.titulo, SUM(e.prestamos) AS total_prestamos
FROM EstadisticaPrestamo e
JOIN Juego j ON e.id_juego = j.id_juego
GROUP BY e.id_juego
ORDER BY total_prestamos DESC
LIMIT 50;


DELIMITER //
CREATE FUNCTION fn_dias_retraso(p_id_prestamo INT) RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE dias INT;
  DECLARE fp DATE;
  DECLARE fd DATE;
  SELECT fecha_prestamo, fecha_devolucion INTO fp, fd FROM Prestamo WHERE id_prestamo = p_id_prestamo;
  IF fd IS NULL THEN
    SET dias = DATEDIFF(CURRENT_DATE, fp);
  ELSE
    SET dias = DATEDIFF(fd, fp);
  END IF;
  RETURN dias;
END;
//
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_juegos_disponibles(p_id_juego INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  DECLARE disponibles INT;
  SELECT copias_disponibles INTO disponibles FROM Juego WHERE id_juego = p_id_juego;
  RETURN (disponibles > 0);
END;
//
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_prestamos_usuario_activos(p_id_usuario INT) RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE cnt INT;
  SELECT COUNT(*) INTO cnt FROM Prestamo WHERE id_usuario = p_id_usuario AND devuelto = FALSE;
  RETURN cnt;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_registrar_prestamo(
  IN p_id_usuario INT,
  IN p_id_juego INT,
  IN p_id_empleado INT,
  IN p_fecha_limite DATE,
  OUT p_result VARCHAR(200)
)
BEGIN
  DECLARE v_disp INT DEFAULT NULL;

  -- Handler para errores SQL: hace rollback y setea mensaje
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_result = 'ERROR: Excepción en sp_registrar_prestamo';
  END;

  START TRANSACTION;

  -- Bloqueo y verificación de disponibilidad
  SELECT copias_disponibles
    INTO v_disp
    FROM Juego
   WHERE id_juego = p_id_juego
   FOR UPDATE;

  IF v_disp IS NULL THEN
    -- Juego no existe
    SET p_result = 'ERROR: juego inexistente';
    ROLLBACK;
  ELSEIF v_disp <= 0 THEN
    -- No hay copias disponibles
    SET p_result = 'ERROR: no hay copias disponibles';
    ROLLBACK;
  ELSE
    -- Insertar préstamo y actualizar inventario
    INSERT INTO Prestamo (id_usuario, id_juego, id_empleado, fecha_prestamo, fecha_limite_devolucion, devuelto)
    VALUES (p_id_usuario, p_id_juego, p_id_empleado, CURRENT_DATE(), p_fecha_limite, FALSE);

    UPDATE Juego
      SET copias_disponibles = copias_disponibles - 1
     WHERE id_juego = p_id_juego;

    -- Actualizar estadística mensual (insert o update)
    INSERT INTO EstadisticaPrestamo (id_juego, anio, mes, prestamos, devoluciones)
    VALUES (p_id_juego, YEAR(CURRENT_DATE()), MONTH(CURRENT_DATE()), 1, 0)
    ON DUPLICATE KEY UPDATE prestamos = prestamos + 1;

    COMMIT;
    SET p_result = 'OK: préstamo registrado';
  END IF;

END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_devolver_prestamo(
  IN p_id_prestamo INT,
  IN p_id_empleado INT,
  OUT p_result VARCHAR(200)
)
BEGIN
  DECLARE v_id_juego INT DEFAULT NULL;
  DECLARE v_id_usuario INT DEFAULT NULL;
  DECLARE v_fecha DATE DEFAULT NULL;

  -- Manejador de excepciones SQL
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_result = 'ERROR: fallo en sp_devolver_prestamo';
  END;

  START TRANSACTION;

  -- Recuperar datos del préstamo
  SELECT id_juego, id_usuario, fecha_prestamo
    INTO v_id_juego, v_id_usuario, v_fecha
    FROM Prestamo
   WHERE id_prestamo = p_id_prestamo
   FOR UPDATE;

  IF v_id_juego IS NULL THEN
    SET p_result = 'ERROR: préstamo no existe';
    ROLLBACK;
  ELSE
    -- Marcar devolución
    UPDATE Prestamo
       SET devuelto = TRUE,
           fecha_devolucion = CURRENT_DATE()
     WHERE id_prestamo = p_id_prestamo;

    -- Incrementar copias disponibles
    UPDATE Juego
       SET copias_disponibles = copias_disponibles + 1
     WHERE id_juego = v_id_juego;

    -- Registrar en hecho
    INSERT INTO HechoPrestamo (id_prestamo, id_juego, id_usuario, fecha_evento, tipo_evento, duracion_dias)
    VALUES (p_id_prestamo, v_id_juego, v_id_usuario, CURRENT_DATE(), 'devolucion', DATEDIFF(CURRENT_DATE(), v_fecha));

    -- Actualizar estadística mensual
    INSERT INTO EstadisticaPrestamo (id_juego, anio, mes, prestamos, devoluciones)
    VALUES (v_id_juego, YEAR(CURRENT_DATE()), MONTH(CURRENT_DATE()), 0, 1)
    ON DUPLICATE KEY UPDATE devoluciones = devoluciones + 1;

    COMMIT;
    SET p_result = 'OK: devolución procesada';
  END IF;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE sp_generar_estadistica_mes(IN p_anio INT, IN p_mes INT)
BEGIN
  -- Aquí podrías hacer operaciones complejas; dejamos un procedimiento demostrativo
  INSERT INTO EstadisticaPrestamo (id_juego, anio, mes, prestamos, devoluciones)
  SELECT id_juego, p_anio, p_mes, SUM(CASE WHEN tipo_evento='prestamo' THEN 1 ELSE 0 END),
         SUM(CASE WHEN tipo_evento='devolucion' THEN 1 ELSE 0 END)
  FROM HechoPrestamo
  WHERE YEAR(fecha_evento)=p_anio AND MONTH(fecha_evento)=p_mes
  GROUP BY id_juego
  ON DUPLICATE KEY UPDATE prestamos = VALUES(prestamos), devoluciones = VALUES(devoluciones);
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_usuario_before_insert
BEFORE INSERT ON Usuario
FOR EACH ROW
BEGIN
  IF NEW.registrado_en IS NULL THEN
    SET NEW.registrado_en = NOW();
  END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_pago_before_insert
BEFORE INSERT ON Pago
FOR EACH ROW
BEGIN
  IF NEW.fecha_pago IS NULL THEN
    SET NEW.fecha_pago = CURRENT_DATE();
  END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_prestamo_before_insert
BEFORE INSERT ON Prestamo
FOR EACH ROW
BEGIN
  DECLARE v_disp INT;
  SELECT copias_disponibles INTO v_disp FROM Juego WHERE id_juego = NEW.id_juego;
  IF v_disp IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Juego inexistente';
  END IF;
  IF v_disp <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay copias disponibles';
  END IF;
  IF NEW.fecha_prestamo IS NULL THEN
    SET NEW.fecha_prestamo = CURRENT_DATE();
  END IF;
END;
//
DELIMITER ;