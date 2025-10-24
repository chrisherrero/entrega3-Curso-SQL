USE Ludoteca_entrega3;

INSERT INTO Categoria (nombre, descripcion) VALUES
('Familiar','Juegos para todas las edades'),
('Estrategia','Juegos con componente estratégico'),
('Cooperativo','Juegos donde los jugadores cooperan'),
('Party','Juegos para grupo grande');

INSERT INTO Autor (nombre) VALUES ('Reiner Knizia'),('Klaus Teuber'),('Matt Leacock'),('Uwe Rosenberg');

INSERT INTO Editorial (nombre) VALUES ('Editorial A'),('Editorial B'),('Mayfair Games');

INSERT INTO Etiqueta (nombre) VALUES ('fácil'),('mediocre'),('estratégico'),('rápido'),('cooperativo');

INSERT INTO Sede (nombre, direccion) VALUES
('Sede Central','Av. Principal 123'),
('Sucursal Norte','Calle 45 678');

INSERT INTO Juego (titulo, id_categoria, id_autor, id_editorial, anio_publicacion, copias, copias_disponibles, duracion_min, edad_min)
VALUES
('Catan', 2, 2, 2, 1995, 5, 5, 90, 10),
('Pandemic', 3, 3, 3, 2008, 3, 3, 60, 8),
('Carcassonne', 2, 1, 1, 2000, 4, 4, 45, 8),
('Azul', 1, 4, 1, 2017, 4, 4, 30, 8),
('Dixit', 4, 1, 1, 2008, 2, 2, 30, 6),
('Terraforming Mars', 2, 1, 2, 2016, 2, 2, 120, 12),
('The Crew',3,3,1,2019,3,3,20,8),
('7 Wonders',2,1,2,2010,3,3,45,10);

INSERT INTO Juego_Etiqueta (id_juego, id_etiqueta) VALUES
(1,3),(1,4),(2,5),(2,1),(3,3),(4,1),(5,4),(6,3),(7,4),(8,3);

INSERT INTO Usuario (nombre, apellido, telefono, email, documento) VALUES
('Ana','Gomez','111-1111','ana.gomez@mail.com','DNI1111'),
('Luis','Perez','222-2222','luis.perez@mail.com','DNI2222'),
('María','Lopez','333-3333','maria.lopez@mail.com','DNI3333'),
('Pedro','Martinez','444-4444','pedro.martinez@mail.com','DNI4444'),
('Sofia','Garcia','555-5555','sofia.garcia@mail.com','DNI5555');

INSERT INTO Empleado (nombre, apellido, puesto, id_sede) VALUES
('Carlos','Diaz','Encargado',1),
('Lucia','Ferrari','Voluntaria',2);

INSERT INTO Prestamo (id_usuario, id_juego, id_empleado, fecha_prestamo, fecha_devolucion, devuelto, fecha_limite_devolucion, id_sede_prestamo, observaciones)
VALUES
(1,1,1,'2025-09-01',NULL,FALSE,'2025-09-15',1,'Préstamo por 2 semanas'),
(2,2,2,'2025-08-20','2025-08-27',TRUE,'2025-08-27',2,'Devuelto con comentarios'),
(3,3,1,'2025-10-01',NULL,FALSE,'2025-10-10',1,'Prestado a alumno'),
(1,4,1,'2025-09-05','2025-09-12',TRUE,'2025-09-12',1,'Devuelto ok'),
(4,2,2,'2025-10-10',NULL,FALSE,'2025-10-17',2,'Reserva realizada y prestado');

UPDATE Juego SET copias_disponibles = copias - (
  SELECT IFNULL(SUM(CASE WHEN p.devuelto = FALSE THEN 1 ELSE 0 END),0)
  FROM Prestamo p WHERE p.id_juego = Juego.id_juego
)
WHERE id_juego > 0;

INSERT INTO Pago (id_usuario, monto, fecha_pago, tipo_pago, descripcion) VALUES
(1,200.00,'2025-07-01','cuota','Cuota anual'),
(2,50.00,'2025-08-01','donacion','Donación voluntaria'),
(3,15.00,NULL,'multa','Multa por retraso');

INSERT INTO Donacion (id_usuario, monto, fecha_donacion, descripcion) VALUES
(2,50.00,'2025-08-01','Donación para ampliación');

INSERT INTO Multa (id_prestamo, monto, motivo, pagada) VALUES
(2,10.00,'Retraso 1 semana',TRUE),
(5,5.00,'Empaque dañado',FALSE);

INSERT INTO Reserva (id_usuario, id_juego, fecha_reserva, vigente) VALUES
(5,1,'2025-10-20',TRUE),
(4,6,'2025-10-15',TRUE);

INSERT INTO DevolucionLog (id_prestamo, fecha_devolucion, id_empleado, observacion) VALUES
(2,'2025-08-27',2,'Devolución ok');

INSERT INTO EstadisticaPrestamo (id_juego, anio, mes, prestamos, devoluciones) VALUES
(1,2025,9,1,0),
(2,2025,8,1,1),
(3,2025,10,1,0);

INSERT INTO HechoPrestamo (id_prestamo, id_juego, id_usuario, fecha_evento, tipo_evento, duracion_dias) VALUES
(2,2,2,'2025-08-20','prestamo',7),
(2,2,2,'2025-08-27','devolucion',7);

INSERT INTO Evento (nombre, fecha_evento, lugar, descripcion) VALUES
('Tarde de juegos familia','2025-11-01','Sede Central','Actividad abierta a vecinos'),
('Torneo estrategia','2025-12-05','Sucursal Norte','Torneo para socios');

INSERT INTO Juego (titulo, id_categoria, id_autor, id_editorial, anio_publicacion, copias, copias_disponibles)
VALUES
('King of Tokyo',1,1,1,2011,3,3),
('Splendor',2,4,2,2014,2,2),
('Azul Variacion',1,4,1,2019,1,1);

INSERT INTO EstadisticaPrestamo (id_juego, anio, mes, prestamos, devoluciones)
VALUES (1,2025,10,2,1)
ON DUPLICATE KEY UPDATE prestamos = prestamos + 2, devoluciones = devoluciones + 1;
