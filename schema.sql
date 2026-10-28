CREATE DATABASE IF NOT EXISTS classroom_escolar CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE classroom_escolar;

-- =========================================================
-- TABLAS NUEVAS (estructura escolar)
-- =========================================================

-- 1) roles: antes "rol" era un texto libre; ahora es un catálogo
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- 2) especialidades (Programación, Electromecánica, etc.)
CREATE TABLE especialidades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL
);

-- 3) años (1° a 7°)
CREATE TABLE anios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero TINYINT NOT NULL UNIQUE,
    nombre VARCHAR(30) NOT NULL
);

-- 4) divisiones (A, B, C... de un año y una especialidad)
CREATE TABLE divisiones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    anio_id INT NOT NULL,
    especialidad_id INT NOT NULL,
    nombre VARCHAR(10) NOT NULL,
    UNIQUE (anio_id, especialidad_id, nombre),
    CONSTRAINT fk_div_anio FOREIGN KEY (anio_id) REFERENCES anios(id) ON DELETE CASCADE,
    CONSTRAINT fk_div_esp FOREIGN KEY (especialidad_id) REFERENCES especialidades(id) ON DELETE CASCADE
);

-- 5) materias (Matemática, Programación, Base de Datos...)
--    Una clase = una materia dictada a una división
CREATE TABLE materias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    especialidad_id INT NULL,
    CONSTRAINT fk_mat_esp FOREIGN KEY (especialidad_id) REFERENCES especialidades(id) ON DELETE SET NULL
);

-- =========================================================
-- TABLAS DEL DIAGRAMA (con los ajustes necesarios)
-- =========================================================

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    division_id INT NULL,                      -- división a la que pertenece un alumno
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usr_div FOREIGN KEY (division_id) REFERENCES divisiones(id) ON DELETE SET NULL
);

CREATE TABLE cursos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    seccion VARCHAR(50),
    codigo_acceso VARCHAR(10) NOT NULL UNIQUE,
    materia_id INT NOT NULL,
    division_id INT NOT NULL,
    color VARCHAR(7) NOT NULL DEFAULT '#1a73e8',  -- color de la tarjeta
    creador_id INT NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cursos_creador FOREIGN KEY (creador_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_cursos_materia FOREIGN KEY (materia_id) REFERENCES materias(id) ON DELETE RESTRICT,
    CONSTRAINT fk_cursos_division FOREIGN KEY (division_id) REFERENCES divisiones(id) ON DELETE RESTRICT
);

CREATE TABLE curso_usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    curso_id INT NOT NULL,
    usuario_id INT NOT NULL,
    rol_id INT NOT NULL,
    fecha_union TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (curso_id, usuario_id),
    CONSTRAINT fk_cu_curso FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE,
    CONSTRAINT fk_cu_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_cu_rol FOREIGN KEY (rol_id) REFERENCES roles(id)
);

CREATE TABLE asistencias (
    curso_usuario_id INT NOT NULL,
    fecha DATE NOT NULL,
    estado ENUM('presente', 'ausente', 'tarde', 'justificado') NOT NULL DEFAULT 'presente',
    observacion VARCHAR(255) NULL,
    PRIMARY KEY (curso_usuario_id, fecha),
    CONSTRAINT fk_asistencia_cu FOREIGN KEY (curso_usuario_id) REFERENCES curso_usuarios(id) ON DELETE CASCADE
);

CREATE TABLE publicaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    curso_usuario_id INT NOT NULL,
    contenido TEXT NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pub_cu FOREIGN KEY (curso_usuario_id) REFERENCES curso_usuarios(id) ON DELETE CASCADE
);

CREATE TABLE comentarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id INT NOT NULL,
    curso_usuario_id INT NOT NULL,
    contenido TEXT NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_com_pub FOREIGN KEY (publicacion_id) REFERENCES publicaciones(id) ON DELETE CASCADE,
    CONSTRAINT fk_com_cu FOREIGN KEY (curso_usuario_id) REFERENCES curso_usuarios(id) ON DELETE CASCADE
);

CREATE TABLE tareas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    curso_id INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_limite DATETIME,
    puntaje_maximo DECIMAL(4,2) DEFAULT 10.00,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tareas_curso FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE
);

CREATE TABLE entregas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tarea_id INT NOT NULL,
    curso_usuario_id INT NOT NULL,
    contenido_texto TEXT,
    entregado BOOLEAN NOT NULL DEFAULT TRUE,
    entregado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (tarea_id, curso_usuario_id),
    CONSTRAINT fk_entregas_tarea FOREIGN KEY (tarea_id) REFERENCES tareas(id) ON DELETE CASCADE,
    CONSTRAINT fk_entregas_cu FOREIGN KEY (curso_usuario_id) REFERENCES curso_usuarios(id) ON DELETE CASCADE
);

-- curso_usuario_id = el docente que calificó
CREATE TABLE calificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entrega_id INT NOT NULL UNIQUE,
    curso_usuario_id INT NOT NULL,
    nota DECIMAL(4,2) NOT NULL,
    feedback TEXT,
    calificado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_calif_entrega FOREIGN KEY (entrega_id) REFERENCES entregas(id) ON DELETE CASCADE,
    CONSTRAINT fk_calif_cu FOREIGN KEY (curso_usuario_id) REFERENCES curso_usuarios(id) ON DELETE CASCADE
);

CREATE TABLE archivos_adjuntos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    url_archivo VARCHAR(255) NOT NULL,
    nombre_original VARCHAR(150) NOT NULL,
    publicacion_id INT NULL,
    tarea_id INT NULL,
    entrega_id INT NULL,
    subido_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_arch_pub FOREIGN KEY (publicacion_id) REFERENCES publicaciones(id) ON DELETE CASCADE,
    CONSTRAINT fk_arch_tarea FOREIGN KEY (tarea_id) REFERENCES tareas(id) ON DELETE CASCADE,
    CONSTRAINT fk_arch_entrega FOREIGN KEY (entrega_id) REFERENCES entregas(id) ON DELETE CASCADE
);

-- =========================================================
-- DATOS INICIALES
-- =========================================================
INSERT INTO roles (nombre) VALUES ('docente'), ('alumno');

INSERT INTO especialidades (nombre, descripcion) VALUES
 ('Ciclo Básico', 'Primero a tercer año'),
 ('Programación', 'Técnico en Programación'),
 ('Electromecánica', 'Técnico en Electromecánica'),
 ('Electrónica', 'Técnico en Electrónica');

INSERT INTO anios (numero, nombre) VALUES
 (1,'Primer año'),(2,'Segundo año'),(3,'Tercer año'),(4,'Cuarto año'),
 (5,'Quinto año'),(6,'Sexto año'),(7,'Séptimo año');

-- ids: anios 1..7 / especialidades 1 Básico, 2 Programación, 3 Electromecánica, 4 Electrónica
INSERT INTO divisiones (anio_id, especialidad_id, nombre) VALUES
 (1,1,'A'),(1,1,'B'),(2,1,'A'),(3,1,'A'),
 (4,2,'A'),(5,2,'A'),(5,3,'A'),(6,2,'A'),(7,2,'A'),(6,4,'A');

INSERT INTO materias (nombre, especialidad_id) VALUES
 ('Matemática', NULL),
 ('Lengua y Literatura', NULL),
 ('Inglés', NULL),
 ('Física', NULL),
 ('Programación', 2),
 ('Base de Datos', 2),
 ('Sistemas Operativos', 2),
 ('Redes', 2),
 ('Electrónica Analógica', 4),
 ('Mecanismos', 3);
