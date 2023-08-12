
--- PROCEDIMIENTO 1 (PR1)

CREATE OR ALTER PROCEDURE practica1.PR1 
	@Firstname varchar(max),
	@Lastname varchar(max), 
	@Email varchar(max), 
	@DateOfBirth datetime2(7), 
	@Password varchar(max), 
	@Credits int
AS
BEGIN
	
	DECLARE @ErrorMessage nvarchar(300);
	DECLARE @ErrorSeverity int;
	DECLARE @UserId uniqueidentifier;
	DECLARE @RolId uniqueidentifier;

	IF(@Firstname IS NULL OR @Firstname='')
		BEGIN 
			SET @ErrorMessage = 'El nombre no puede estar vacio';
			SET @ErrorSeverity = 16;
			RAISERROR(@ErrorMessage,@ErrorSeverity,1);
			RETURN;
		END
	IF(@Lastname IS NULL OR @Lastname='')
		BEGIN 
			SET @ErrorMessage = 'El apellido no puede estar vacio';
			SET @ErrorSeverity = 16;
			RAISERROR(@ErrorMessage,@ErrorSeverity,1);
			RETURN;
		END
	IF(@Email IS NULL OR @Email='')
		BEGIN 
			SET @ErrorMessage = 'El correo no puede estar vacio';
			SET @ErrorSeverity = 16;
			RAISERROR(@ErrorMessage,@ErrorSeverity,1);
			RETURN;
		END
	IF(@DateOfBirth IS NULL)
		BEGIN
			SET @ErrorMessage = 'La fecha de nacimiento no puede ser null';
			SET @ErrorSeverity = 16;
			RAISERROR(@ErrorMessage,@ErrorSeverity,1);
			RETURN;
		END
	IF(@Password IS NULL OR @Password='')
		BEGIN
			SET @ErrorMessage = 'El password no puede estar en blanco';
			SET @ErrorSeverity = 16;
			RAISERROR(@ErrorMessage,@ErrorSeverity,1);
			RETURN;
		END
	IF(@Credits < 0)
		BEGIN
			SET @ErrorMessage = 'La cantidad de creditos no puede ser negativa';
			SET @ErrorSeverity = 16;
			RAISERROR(@ErrorMessage,@ErrorSeverity,1);
			RETURN;
		END
	BEGIN TRY
		
		IF NOT EXISTS(SELECT * FROM practica1.Usuarios WHERE Email = @Email)
			BEGIN
				IF @Firstname NOT LIKE '%[^a-zA-Z]%'
					BEGIN	 
						IF @Lastname NOT LIKE '%[^a-zA-Z]%'
							BEGIN
								SELECT @RolId = Id FROM practica1.Roles WHERE RoleName = 'Student';
									IF @RolId IS NOT NULL
										BEGIN
											BEGIN TRANSACTION
												SET @UserId = NEWID();
												INSERT INTO practica1.Usuarios(Id, Firstname, Lastname, Email, DateOfBirth, Password, LastChanges, EmailConfirmed)
												VALUES (@UserId, @Firstname, @Lastname, @Email, @DateOfBirth, @Password, GETDATE(), 1);

												INSERT INTO practica1.HistoryLog(Date,Description) VALUES (GETDATE(),'Insert - Tabla usuarios');

												INSERT INTO practica1.UsuarioRole (RoleId, UserId, IsLatestVersion)
												VALUES (@RoleId, @UserId, 1);
												INSERT INTO practica1.HistoryLog (Date, Description)
												VALUES (GETDATE(), 'Insert - UsuarioRole');

												INSERT INTO practica1.ProfileStudent (UserId, Credits)
												VALUES (@UserId, @Credits);
												INSERT INTO practica1.HistoryLog (Date, Description)
												VALUES (GETDATE(), 'Insert - ProfileStudent');

												INSERT INTO practica1.TFA (UserId, Status, LastUpdate)
												VALUES (@UserId, 1, GETDATE());
												INSERT INTO practica1.HistoryLog (Date, Description)
												VALUES (GETDATE(), 'Insert - TFA');

												INSERT INTO practica1.Notification (UserId, Message, Date)
												VALUES (@UserId, 'Se ha registrado en el sistema', GETDATE());
												INSERT INTO practica1.HistoryLog (Date, Description)
												VALUES (GETDATE(), 'Insert - Notification');
											COMMIT TRANSACTION;
										END
									ELSE
										BEGIN
											RAISERROR('El rol del usuario no existe',16,1);
										END
								END
							
							ELSE
								BEGIN
									RAISERROR('El apellido del usuario no contiene unicamente letras',16,1);
								END
							END
						ELSE
							BEGIN
								RAISERROR('El nombre del usuario no contiene unicamente letras',16,1);
							END
						END
					ELSE
						BEGIN
							RAISERROR('Ya hay un usuario asociadocon el correo indicado',16,1);
						END
					
			END TRY
				
			BEGIN CATCH
				ROLLBACK;
					SELECT @ErrorMessage = ERROR_MESSAGE(); -- ASIGNAR EL ERROR ALMACENADO EN LAS PRIMERAS VALIDACIONES
					RAISERROR (@ErrorMessage, 16, 1);
			END CATCH;
		END;

EXEC practica1.PR1 'Estudiante','1','correo@gmail.com','2021-10-22 13:54:19:55','123',6; -- TRANSACCION INCORRECTA
EXEC practica1.PR1 'Estudiante','uno','correo@gmail.com','2021-10-22 13:54:19:55','123',6; -- TRANSACCION CORRECTA


--- TRIGGER PARA GUARDAR ACCIONES AUTOMATIZADAS DE TABLA USUARIOS
create  or alter    TRIGGER practica1.Trigger_Usarios
ON practica1.Usuarios
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @EventData XML = EVENTDATA();
    INSERT INTO practica1.HistoryLog (Date, Description)
    VALUES (GETDATE(), @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]','nvarchar(256)')
                        + ' operation on ' + @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]','nvarchar(256)'));
END;
go

--- FUNCION PARA OBTENER TODOS LOS LOGS CREADOS
CREATE or alter FUNCTION F4 ()
RETURNS TABLE
AS
RETURN
(
  SELECT practica1.HistoryLog.Date, practica1.HistoryLog.Description
  FROM practica1.HistoryLog
);
