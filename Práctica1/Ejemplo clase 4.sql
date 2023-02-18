USE BD2;


select * from practica1.Course;
select * from practica1.Usuarios;

-- SELECT USANDO uniqueidentifier
select * from practica1.Usuarios where Id = '69D34A67-2924-4A59-A6AD-236177215F97';


select * from practica1.Course;

DROP PROCEDURE if exists EjemploCurso
GO

-- PROCEDIMIENTO INSERTAR CURSO
CREATE PROCEDURE InsertarCurso
	@CursoId int,
	@Nombre nvarchar(100),
	@CreditosRequeridos int

	AS
	EXEC Validacion N'Curso', null, null, @Nombre, @CreditosRequeridos; --PR6
	DECLARE @find int
	SET @find = (select count(*) from practica1.Course where CodCourse=@CursoId)
	
	if (@find>0)
		THROW 51000, 'El curso ya existe',1;
	INSERT practica1.Course(CodCourse,Name,CreditsRequired) values(@CursoId,@Nombre, @CreditosRequeridos);
	GO

EXEC InsertarCurso N'489', N'BD2', N'60';

-- PROCEDIMIENTO INSERTAR USUARIO
CREATE PROCEDURE InsertarUsuario
	@UsuarioId uniqueidentifier,
	@Nombre nvarchar(100),
	@Apellido nvarchar(100),
	@Correo nvarchar(100),
	@Nacimiento datetime2(7),
	@Pass nvarchar(100),
	@FechaCambio datetime2(7),
	@ConfirmacionCorreo bit
	AS
	EXEC Validacion N'Usuario', @Nombre, @Apellido, null, null; --PR6
	--DECLARE @find int
	--SET @find = (select count(*) from practica1.Course where CodCourse=@CursoId)

	--if (@find>0)
		--THROW 51000, 'El curso ya existe',1;
	GO
	
DECLARE @id uniqueidentifier;
SET @id = NEWID();
EXEC InsertarUsuario @id, N'Juan', N'Rodas', N'correo',N'1999-11-04',N'123',N'2023-11-04',N'1'; 
EXEC InsertarCurso N'896', N'Modela 2', N'-60';


-- PROCEDIMIENTO DE VALIDACION
CREATE PROCEDURE Validacion
	@TipoOperacion VARCHAR(30),
	-- PARAMETROS PARA VALIDAR LOS DATOS DEL USUARIO
	@FirstName nvarchar(100) null,
	@LastName nvarchar(100) null,
	-- PARAMETROS PARA VALIDAR LOS DATOS DEL CURSO
	@CourseName nvarchar(100) null,
	@CreditsRequired int null

	AS
	if (@TipoOperacion='Curso')
		BEGIN
			if(@CreditsRequired<0)
				THROW 51000, 'Los creditos requeridos deben un numero positivo',1;
		END
	else
		PRINT('Entra a validar usuario')
		
	--PRINT('Si pasa la validacion')
GO

-- ELIMINAR SP
DROP PROCEDURE InsertarCurso

select * from practica1.Course;

-- MANEJO DE TRIGGER PARA LA TABLA DE BITACORA
CREATE TABLE Bitacora(
	descripcion nvarchar(300),
	tipo nvarchar(30),
	exitosa bit
);

select * from Bitacora;

CREATE TRIGGER ActivarCurso
ON practica1.Course
after INSERT
AS
	Insert into Bitacora(descripcion,tipo,exitosa) VALUES('Se inserto en la tabla de curso', 'INSERT', 1)



EXEC EjemploCurso N'125', N'Modela 1', N'60';