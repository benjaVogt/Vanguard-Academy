CREATE DATABASE classroom;
USE classroom;

CREATE TABLE roles (
	id_rol INT(3) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    nombre_rol VARCHAR(26) NOT NULL
);

CREATE TABLE usuarios (
	id_usuario INT(3) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    mail VARCHAR(32) NOT NULL,
	pass_hash VARCHAR(256) NOT NULL,
    salt VARCHAR(64) NOT NULL,
    fecha_creacion DATETIME NOT NULL,
    ultimo_login DATETIME NOT NULL,
    intentos_login DATETIME NOT NULL,
    pfp_link VARCHAR(128)
);

CREATE TABLE cursos (
	id_curso INT(3) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    codigo_curso VARCHAR(12) UNIQUE NOT NULL,
    nombre_curso VARCHAR(26),
    descripcion_curso VARCHAR(4096),
    fecha_creacion DATETIME NOT NULL,
    FOREIGN KEY (id_admin) REFERENCES usuarios(id_usuario)
);

CREATE TABLE inscripciones (
	id_inscripcion INT(3) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    fecha_union DATETIME NOT NULL,
    expulsado BOOL NOT NULL,
    nota_general INT(3) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);

CREATE TABLE tareas (
	id_tarea INT(3) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    nombre_tarea VARCHAR(26) NOT NULL,
    descripcion_tarea VARCHAR(26) NOT NULL,
    link_material VARCHAR(128),
    fecha_creacion DATETIME NOT NULL,
    fecha_entrega DATETIME
);

CREATE TABLE respuestas_tareas (
	id_respuesta INT(3) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    link_respuesta VARCHAR(128),
    fecha_entregado DATETIME NOT NULL,
    nota_tarea INT(3) NOT NULL,
    FOREIGN KEY (id_tarea) REFERENCES tareas(id_tarea),
    FOREIGN KEY (id_alumno) REFERENCES alumnos(id_alumno)
);