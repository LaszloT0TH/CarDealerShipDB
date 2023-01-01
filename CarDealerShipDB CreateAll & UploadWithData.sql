------------ closing existing relationships -----------------------------------------------------
--EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'CarDealerShipDB'
--GO
--use [master];
--GO
--USE [master]
--GO
--ALTER DATABASE [CarDealerShipDB] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
--GO
--------------------------------------------------------------------------------------------------
USE [master]
GO

DROP DATABASE IF EXISTS CarDealerShipDB
go

CREATE DATABASE CarDealerShipDB
go

ALTER DATABASE [CarDealerShipDB] SET  MULTI_USER
go

USE CarDealerShipDB
GO

-- Create procedure to retrieve error information.  
CREATE PROCEDURE usp_GetErrorInfo  
AS  
SELECT  
    ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS ErrorMessage;  
GO  
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------- tblCar -------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------


CREATE Table tblFuel
	(
 	  FuelId int identity(1,1) primary key,
	  FuelName nvarchar(20),
	  CONSTRAINT [Unique Fuel Name Violation] UNIQUE NONCLUSTERED 
		(
			FuelName ASC
		)
	)
go

CREATE Table tblGearbox
	(
 	  GearboxId int identity(1,1) primary key,
	  GearboxName nvarchar(20),
	  CONSTRAINT [Unique Gearbox Name Violation] UNIQUE NONCLUSTERED 
		(
			GearboxName ASC
		)
	)
go

CREATE Table tblCars
	(
 	  CarId int identity(1000000,1) primary key,
	  Model nvarchar(50),
	  Color nvarchar(50),
	  Number_of_seats int,
	  Year_of_production datetime2,
	  Fuel int foreign key references tblFuel(FuelId),
	  Gearbox int foreign key references tblGearbox(GearboxId), 
	  Cubic_capacity FLOAT,
	  Mileage FLOAT,
	  Chassis_number nvarchar(50),
	  Engine_power int,
	  Own_Weight int,
	  Sold bit,
	  NettoPrice float,
	  CONSTRAINT [Unique Chassis_number Violation] UNIQUE NONCLUSTERED 
		(
			Chassis_number ASC
		)
	)
go

----- Audit tblCars ----------------------------------------------------------------
CREATE TABLE tblCarsAudit
(
  CarsAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go
------ Audit tblGearbox ----------------------------------------------------------------
CREATE TABLE tblGearboxAudit
(
  GearboxAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go
------ Audit tblFuel ----------------------------------------------------------------
CREATE TABLE tblFuelAudit
(
  FuelAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go


------ Insert Audit tblCars ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCars_ForInsert
ON tblCars
FOR INSERT
AS
BEGIN
	BEGIN TRY  
		--Begin tran
			Declare @Id int
			Select @Id = CarId from inserted
			insert into tblCarsAudit 
			values('New Car with Id  = ' + Cast(@Id as nvarchar(10)) + 
				' is added at ' + cast(Getdate() as nvarchar(20)) +
				' Login Name = ' + ORIGINAL_LOGIN())
		--Commit tran
	END TRY  
	BEGIN CATCH  
		--Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Delete Audit tblCars ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCars_ForDelete
ON tblCars
FOR DELETE
AS
BEGIN 
	BEGIN TRY  
		--Begin tran
			Declare @Id int
			Select @Id = CarId from deleted 
			insert into tblCarsAudit 
			values('An existing Car with Id  = ' + Cast(@Id as nvarchar(10)) + 
				' is deleted at ' + cast(Getdate() as nvarchar(20)) +
				' Login Name = ' + ORIGINAL_LOGIN())
		--Commit tran
	END TRY  
	BEGIN CATCH  
		--Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Update Audit tblCars ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCars_ForUpdate
ON tblCars
for Update
as
BEGIN
	BEGIN TRY  
		--Begin tran
			  Declare @Id int 
			  Declare @OldModel nvarchar(50), @NewModel nvarchar(50)
			  Declare @OldColor nvarchar(50), @NewColor nvarchar(50)
			  Declare @OldNumber_of_seats int, @NewNumber_of_seats int
			  Declare @OldYear_of_production datetime2, @NewYear_of_production datetime2
			  Declare @OldFuel int, @NewFuel int
			  Declare @OldGearbox int, @NewGearbox int
			  Declare @OldCubic_capacity FLOAT, @NewCubic_capacity FLOAT
			  Declare @OldMileage FLOAT, @NewMileage FLOAT
			  Declare @OldChassis_number nvarchar(50), @NewChassis_number nvarchar(50)
			  Declare @OldEngine_power int, @NewEngine_power int
			  Declare @OldOwn_Weight int, @NewOwn_Weight int
			  Declare @OldSold bit, @NewSold bit
			  Declare @OldNettoPrice float, @NewNettoPrice float
     
			  Declare @AuditString nvarchar(1000)
      
			  Select *
			  into #TempTable 
			  from inserted
     
			  While(Exists(Select CarId from #TempTable))
			  Begin
					Set @AuditString = ''
					Select Top 1 @Id = CarId, 
					@NewModel = Model, 
					@NewColor = Color, 
					@NewNumber_of_seats = Number_of_seats,
					@NewYear_of_production = Year_of_production,
					@NewFuel = Fuel,
					@NewGearbox = Gearbox,
					@NewCubic_capacity = Cubic_capacity,
					@NewMileage = Mileage,
					@NewChassis_number = Chassis_number,
					@NewEngine_power = Engine_power,
					@NewOwn_Weight = Own_Weight,
					@NewSold = Sold,
					@NewNettoPrice = NettoPrice
					from #TempTable
           
					Select 
					@OldModel = Model, 
					@OldColor = Color, 
					@OldNumber_of_seats = Number_of_seats,
					@OldYear_of_production = Year_of_production,
					@OldFuel = Fuel,
					@OldGearbox = Gearbox,
					@OldCubic_capacity = Cubic_capacity,
					@OldMileage = Mileage,
					@OldChassis_number = Chassis_number,
					@OldEngine_power = Engine_power,
					@OldOwn_Weight = Own_Weight,
					@OldSold = Sold,
					@OldNettoPrice = NettoPrice
					from deleted where CarId = @Id
   
					Set @AuditString = 'Car with Id = ' + Cast(@Id as nvarchar(10)) + ' changed'
					if(@OldModel <> @NewModel)
						  Set @AuditString = @AuditString + ' Model from ' + @OldModel + ' to ' + @NewModel
           
					if(@OldColor <> @NewColor)
						  Set @AuditString = @AuditString + ' Color from ' + @OldColor + ' to ' + @NewColor
            
					if(@OldNumber_of_seats <> @NewNumber_of_seats)
						  Set @AuditString = @AuditString + ' Number of seats from ' + Cast(@OldNumber_of_seats as nvarchar(10)) + 
						  ' to ' + Cast(@NewNumber_of_seats as nvarchar(10))
            
					if(@OldYear_of_production <> @NewYear_of_production)
						  Set @AuditString = @AuditString + ' Year of production from ' + Cast(@OldYear_of_production as nvarchar(10)) + 
						  ' to ' + Cast(@NewYear_of_production as nvarchar(10))
            
					if(@OldFuel <> @NewFuel)
						  Set @AuditString = @AuditString + ' Fuel from ' + Cast(@OldFuel as nvarchar(10)) + 
						  ' to ' + Cast(@NewFuel as nvarchar(10))
            
					if(@OldGearbox <> @NewGearbox)
						  Set @AuditString = @AuditString + ' Gearbox from ' + Cast(@OldGearbox as nvarchar(10)) +
						  ' to ' + Cast(@NewGearbox as nvarchar(10))
            
					if(@OldCubic_capacity <> @NewCubic_capacity)
						  Set @AuditString = @AuditString + ' Cubic capacity from ' + Cast(@OldCubic_capacity as nvarchar(10)) + 
						  ' to ' + Cast(@NewCubic_capacity as nvarchar(10))
            
					if(@OldMileage <> @NewMileage)
						  Set @AuditString = @AuditString + ' Mileage from ' + Cast(@OldMileage as nvarchar(10)) + 
						  ' to ' + Cast(@NewMileage as nvarchar(10))
            
					if(@OldChassis_number <> @NewChassis_number)
						  Set @AuditString = @AuditString + ' Chassis number from ' + @OldChassis_number + ' to ' + @NewChassis_number
            
					if(@OldEngine_power <> @NewEngine_power)
						  Set @AuditString = @AuditString + ' Engine power from ' + Cast(@OldEngine_power as nvarchar(10)) + 
						  ' to ' + Cast(@NewEngine_power as nvarchar(10))
            
					if(@OldOwn_Weight <> @NewOwn_Weight)
						  Set @AuditString = @AuditString + ' Own Weight from ' + Cast(@OldOwn_Weight as nvarchar(10)) + 
						  ' to ' + Cast(@NewOwn_Weight as nvarchar(10))
            
					if(@OldSold <> @NewSold)
						  Set @AuditString = @AuditString + ' Sold from ' + Cast(@OldSold as nvarchar(10)) + 
						  ' to ' + Cast(@NewSold as nvarchar(10))

					if(@OldNettoPrice <> @NewNettoPrice)
						  Set @AuditString = @AuditString + ' NettoPrice from ' + Cast(@OldNettoPrice as nvarchar(10))
						  + ' to ' + Cast(@NewNettoPrice as nvarchar(10))

					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		
					insert into tblCarsAudit values(@AuditString)
            
					Delete from #TempTable where CarId = @Id
			  End
		--Commit tran
	END TRY  
	BEGIN CATCH  
		--Rollback Transaction
		 --Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ Insert Audit tblFuel ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblFuel_ForInsert
ON tblFuel
FOR INSERT
AS
BEGIN
	BEGIN TRY  
		--Begin tran
			Declare @FuelId int
			Select @FuelId = FuelId from inserted
			insert into tblFuelAudit 
			values('New Fuel with Id  = ' + Cast(@FuelId as nvarchar(5)) + 
				' is added at ' + cast(Getdate() as nvarchar(20)) +
				' Login Name = ' + ORIGINAL_LOGIN())
		--Commit tran
	END TRY  
	BEGIN CATCH  
		--Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Delete Audit tblFuel ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblFuel_ForDelete
ON tblFuel
FOR DELETE
AS
BEGIN
	BEGIN TRY  
		--Begin tran
			Declare @FuelId int
			Select @FuelId = FuelId from deleted 
			insert into tblFuelAudit 
			values('An existing Fuel with Id  = ' + Cast(@FuelId as nvarchar(5)) + 
				' is deleted at ' + cast(Getdate() as nvarchar(20)) +
				' Login Name = ' + ORIGINAL_LOGIN())
		--Commit tran
	END TRY  
	BEGIN CATCH  
		--Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Update Audit tblFuel ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblFuel_ForUpdate
ON tblFuel
for Update
as
BEGIN
	BEGIN TRY  
		--Begin tran
		  Declare @Id int 
		  Declare @OldFuelName nvarchar(50), @NewFuelName nvarchar(50)
     
		  Declare @AuditString nvarchar(1000)
      
		  Select *
		  into #TempTable 
		  from inserted
     
		  While(Exists(Select FuelId from #TempTable))
		  Begin
				Set @AuditString = ''
           
				Select Top 1 @Id = FuelId, 
				@NewFuelName = FuelName
				from #TempTable
           
				Select 
				@OldFuelName = FuelName
				from deleted where FuelId = @Id
   
				Set @AuditString = 'Car with FuelId = ' + Cast(@Id as nvarchar(4)) + ' changed'
				if(@OldFuelName <> @NewFuelName)
					  Set @AuditString = @AuditString + ' Fuel Name from ' + @OldFuelName + ' to ' + @NewFuelName
           
				Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		
				insert into tblFuelAudit values(@AuditString)
            
				Delete from #TempTable where FuelId = @Id
		  End
		--Commit tran
	END TRY  
	BEGIN CATCH  
		--Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ Insert Audit tblGearbox ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblGearbox_ForInsert
ON tblGearbox
FOR INSERT
AS
BEGIN
	BEGIN TRY  
		--Begin tran
			Declare @GearboxId int
			Select @GearboxId = GearboxId from inserted
			insert into tblGearboxAudit 
			values('New Gearbox with Id  = ' + Cast(@GearboxId as nvarchar(5)) + 
				' is added at ' + cast(Getdate() as nvarchar(20)) +
				' Login Name = ' + ORIGINAL_LOGIN())
		--Commit tran
	END TRY  
	BEGIN CATCH  
		--Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Delete Audit tblGearbox -----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblGearbox_ForDelete
ON tblGearbox
FOR DELETE
AS
BEGIN
	BEGIN TRY  
--		Begin tran
			Declare @GearboxId int
			Select @GearboxId = GearboxId from deleted 
			insert into tblGearboxAudit 
			values('An existing Gearbox with Id  = ' + Cast(@GearboxId as nvarchar(5)) + 
				' is deleted at ' + cast(Getdate() as nvarchar(20)) +
				' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Update Audit tblGearbox ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblGearbox_ForUpdate
ON tblGearbox
for Update
as
BEGIN
	BEGIN TRY  
--		Begin tran
		  Declare @Id int 
		  Declare @OldGearboxName nvarchar(50), @NewGearboxName nvarchar(50)
     
		  Declare @AuditString nvarchar(1000)
      
		  Select *
		  into #TempTable 
		  from inserted
     
		  While(Exists(Select GearboxId from #TempTable))
		  Begin
				Set @AuditString = ''
				Select Top 1 @Id = GearboxId, 
				@NewGearboxName = GearboxName
				from #TempTable
				Select 
				@OldGearboxName = GearboxName
				from deleted where GearboxId = @Id
				Set @AuditString = 'Car with GearboxId = ' + Cast(@Id as nvarchar(4)) + ' changed'
				if(@OldGearboxName <> @NewGearboxName)
					  Set @AuditString = @AuditString + ' Gearbox Name from ' + @OldGearboxName + ' to ' + @NewGearboxName
           
				Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		
				insert into tblGearboxAudit values(@AuditString)
            
				Delete from #TempTable where GearboxId = @Id
		  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

----- View update, delete, insert Trigger --------------------------------------------------
Create or alter View vWCarsDetails
as
select CarId, Model, Color, Number_of_seats, Year_of_production, 
FuelName, GearboxName, Cubic_capacity, Mileage, Chassis_number, 
Engine_power, Own_Weight, Sold, NettoPrice 
from	tblCars
JOIN	tblFuel
ON		tblCars.Fuel = tblFuel.FuelId
JOIN	tblGearbox
ON		tblCars.Gearbox = tblGearbox.GearboxId
go
------------------------ Insert -- SNAPSHOT BLOCK-------------------------------------------------------------
CREATE or Alter Trigger tr_vWCarsDetails_InsteadOfInsert
on vWCarsDetails
Instead Of Insert
as
BEGIN
	BEGIN TRY  
	  -- SNAPSHOT full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--		Begin tran
			Declare @FuelId int
			Declare @GearboxId int
			Select @FuelId = FuelId
			from tblFuel 
			join inserted
			on inserted.FuelName = tblFuel.FuelName
			if(@FuelId is null)
			Begin
			Raiserror('Invalid Fuel Name. Statement terminated', 16, 1)
			return 
			End
			----------------------------------------------------------------
			Select @GearboxId = GearboxId
			from tblGearbox 
			join inserted
			on inserted.GearboxName = tblGearbox.GearboxName
			if(@GearboxId is null)
			Begin
				Raiserror('Invalid Gearbox Name. Statement terminated', 16, 1)
				return 
			End
			SET IDENTITY_INSERT [dbo].[tblCars] ON
			Insert into tblCars(CarId, Model, Color, Number_of_seats, Year_of_production, 
				Fuel, Gearbox, Cubic_capacity, Mileage, Chassis_number, 
				Engine_power, Own_Weight, Sold, NettoPrice )
			Select CarId, Model, Color, Number_of_seats, Year_of_production, 
				@FuelId, @GearboxId, Cubic_capacity, Mileage, Chassis_number, 
				Engine_power, Own_Weight, Sold, NettoPrice 
			from inserted
			SET IDENTITY_INSERT [dbo].[tblCars] OFF
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------------------------ DELETE -- SNAPSHOT BLOCK-------------------------------------------------------------
CREATE or Alter Trigger tr_vWCarsDetails_InsteadOfDelete
on vWCarsDetails
Instead Of DELETE
as
BEGIN
	BEGIN TRY  
	  -- SNAPSHOT full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--		Begin tran
			Delete tblCars 
			from tblCars
			join deleted
			on tblCars.CarId = deleted.CarId
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------------------------ Update -- SNAPSHOT BLOCK-------------------------------------------------------------
Create or Alter Trigger tr_vWCarsDetails_InsteadOfUpdate
on vWCarsDetails
instead of update
as
BEGIN
	BEGIN TRY  
	  -- SNAPSHOT full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--		Begin tran
			-- if CarId is updated
			if(Update(CarId))
			Begin
				Raiserror('Id cannot be changed', 16, 1)
				Return
			End

			if(Update(Model))
			Begin
				Update tblCars set Model = inserted.Model
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End

			if(Update(Color))
			Begin
				Update tblCars set Color = inserted.Color
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End
	
			if(Update(Number_of_seats))
			Begin
				Update tblCars set Number_of_seats = inserted.Number_of_seats
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End
 
			if(Update(Year_of_production))
			Begin
				Update tblCars set Year_of_production = inserted.Year_of_production
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End

			if(Update(FuelName)) 
			Begin
				Declare @FuelId int

				Select @FuelId = FuelId
				from tblFuel
				join inserted
				on inserted.FuelName = tblFuel.FuelName
  
				if(@FuelId is NULL )
				Begin
					Raiserror('Invalid Fuel Name', 16, 1)
					Return
				End
  
				Update tblCars set Fuel = @FuelId
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End

			if(Update(GearboxName)) 
			Begin
				Declare @GearboxId int

				Select @GearboxId= GearboxId
				from tblGearbox
				join inserted
				on inserted.GearboxName = tblGearbox.GearboxName
  
				if(@GearboxId is NULL )
				Begin
					Raiserror('Invalid Gearbox Name', 16, 1)
					Return
				End
  
				Update tblCars set Gearbox = @GearboxId
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End

			if(Update(Cubic_capacity))
			Begin
				Update tblCars set Cubic_capacity = inserted.Cubic_capacity
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End
 
			if(Update(Mileage))
			Begin
				Update tblCars set Mileage = inserted.Mileage
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End
 
			if(Update(Chassis_number))
			Begin
				Update tblCars set Chassis_number = inserted.Chassis_number
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End
 
			if(Update(Engine_power))
			Begin
				Update tblCars set Engine_power = inserted.Engine_power
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End
 
			if(Update(Own_Weight))
			Begin
				Update tblCars set Own_Weight = inserted.Own_Weight
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End
 
			if(Update(Sold))
			Begin
				Update tblCars set Sold = inserted.Sold
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End

			if(Update(NettoPrice))
			Begin
				Update tblCars set NettoPrice = inserted.NettoPrice
				from inserted
				join tblCars
				on tblCars.CarId = inserted.CarId
			End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go



------- Stored Procedure ------------------------------------------------------------------------
go
------ Cars SEARCH ------------------------------------------------------------------------------
Create or alter Procedure spCarsSearchDynamicSQL
@CarId int = NULL,
@Model nvarchar(50) = NULL,
@Color nvarchar(50) = NULL,
@Number_of_seats int = NULL,
@Year_of_production datetime2 = NULL,
@FuelName nvarchar(50) = NULL,
@GearboxName nvarchar(50) = NULL,
@Cubic_capacity FLOAT = NULL,
@Mileage FLOAT = NULL,
@Chassis_number nvarchar(50) = NULL,
@Engine_power int = NULL,
@Own_Weight int = NULL,
@Sold bit = NULL,
@NettoPrice float = NULL
As
BEGIN
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)

			 Set @sql = 'Select CarId, Model, Color, Number_of_seats, Year_of_production, 
			tblFuel.FuelName, tblGearbox.GearboxName, Cubic_capacity, Mileage, Chassis_number, 
			Engine_power, Own_Weight, Sold, NettoPrice 
			from tblCars 
			JOIN tblFuel 
			ON tblCars.Fuel = tblFuel.FuelId 
			JOIN tblGearbox 
			ON tblCars.Gearbox = tblGearbox.GearboxId 
			where 1 = 1'
    
			 if(@CarId is not null)
				  Set @sql = @sql + ' and CarId=@CI'
			 if(@Model is not null)
				  Set @sql = @sql + ' and Model like(@Mo + @PS)'
			 if(@Color is not null)
				  Set @sql = @sql + ' and Color like(@Col + @PS)'
			 if(@Number_of_seats is not null)
				  Set @sql = @sql + ' and Number_of_seats=@NOS'
			 if(@Year_of_production is not null)
				  Set @sql = @sql + ' and Year_of_production=@YOP'
			 if(@FuelName is not null)
				  Set @sql = @sql + ' and FuelName like(@Fu + @PS)'
			 if(@GearboxName is not null)
				  Set @sql = @sql + ' and GearboxName like(@GB + @PS)'
			 if(@Cubic_capacity is not null)
				  Set @sql = @sql + ' and Cubic_capacity=@CC'
			 if(@Mileage is not null)
				  Set @sql = @sql + ' and Mileage=@Mi'
			 if(@Chassis_number is not null)
				  Set @sql = @sql + ' and Chassis_number like(@CN + @PS)'
			 if(@Engine_power is not null)
				  Set @sql = @sql + ' and Engine_power=@EP'
			 if(@Own_Weight is not null)
				  Set @sql = @sql + ' and Own_Weight=@OW'
			 if(@Sold is not null)
				  Set @sql = @sql + ' and Sold=@So'
			 if(@NettoPrice is not null)
				  Set @sql = @sql + ' and NettoPrice=@NP'

			 Execute sp_executesql @sql,
			 N'@CI int, @Mo nvarchar(50), @Col nvarchar(50), @NOS int, @YOP datetime2, @Fu nvarchar(50), @GB nvarchar(50),
			 @CC float, @Mi float, @CN nvarchar(50), @EP int, @OW int, @So bit, @NP float, @PS nvarchar(1)',
			 @CI=@CarId, @Mo=@Model, @Col=@Color, @NOS=@Number_of_seats, @YOP=@Year_of_production, @Fu=@FuelName, @GB=@GearboxName,
			 @CC=@Cubic_capacity, @Mi=@Mileage, @CN=@Chassis_number, @EP=@Engine_power, @OW=@Own_Weight, @So=@Sold,
			 @NP=@NettoPrice, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Cars Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spCarsUpdateOrInsert
@CarId int = NULL,
@Model nvarchar(50) = NULL,
@Color nvarchar(50) = NULL,
@Number_of_seats int = NULL,
@Year_of_production datetime2 = NULL,
@FuelName nvarchar(50) = NULL,
@GearboxName nvarchar(50) = NULL,
@Cubic_capacity FLOAT = NULL,
@Mileage FLOAT = NULL,
@Chassis_number nvarchar(50) = NULL,
@Engine_power int = NULL,
@Own_Weight int = NULL,
@Sold bit = NULL,
@NettoPrice float = NULL
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (exists (select * from vWCarsDetails with (updlock,serializable) where CarId = @CarId))
			begin
			   update vWCarsDetails set Model = @Model, Color = @Color, Number_of_seats = @Number_of_seats, 
					Year_of_production = @Year_of_production, FuelName = @FuelName, GearboxName = @GearboxName,
					Cubic_capacity = @Cubic_capacity, Mileage = @Mileage, Chassis_number = @Chassis_number, 
					Engine_power = @Engine_power, Own_Weight = @Own_Weight, Sold = @Sold, NettoPrice = @NettoPrice
			   where CarId = @CarId
			end
			else
			begin
				if(@CarId is not Null)
				begin
					insert into vWCarsDetails  values (@CarId , @Model, @Color, @Number_of_seats, 
					@Year_of_production, @FuelName, @GearboxName, @Cubic_capacity,
					@Mileage, @Chassis_number, @Engine_power, @Own_Weight, @Sold, @NettoPrice)
				end
				else
				begin
					insert into vWCarsDetails  values (IDENT_CURRENT('tblCars')+1 , @Model, @Color, @Number_of_seats, 
					@Year_of_production, @FuelName, @GearboxName, @Cubic_capacity,
					@Mileage, @Chassis_number, @Engine_power, @Own_Weight, @Sold, @NettoPrice)
				end
			end
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Cars Delete ---------------------------------------------------------------------
Create or alter Procedure spCarsDelete
@CarId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@CarId is not Null)
			begin
				Delete from [dbo].[vWCarsDetails] where CarId = @CarId
			end
			else
			begin
				Print 'CarId is not found ' + @CarId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ Fuel SEARCH ---------------------------------------------------------------------
Create or alter Procedure spFuelSearchDynamicSQL
@FuelId int = NULL,
@FuelName nvarchar(50) = NULL
As
BEGIN
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)

			 Set @sql = 'Select FuelId, FuelName 
			from tblFuel 
			where 1 = 1'
    
			 if(@FuelId is not null)
				  Set @sql = @sql + ' and FuelId=@FuI'
			 if(@FuelName is not null)
				  Set @sql = @sql + ' and FuelName like(@FuN + @PS)'
     
			 Execute sp_executesql @sql,
			 N'@FuI int, @FuN nvarchar(50), @PS nvarchar(1)',
			 @FuI=@FuelId, @FuN=@FuelName, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Fuel Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spFuelUpdateOrInsert
@FuelId int = NULL,
@FuelName nvarchar(50) = NULL
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (exists (select * from tblFuel with (updlock,serializable) where FuelId = @FuelId))
			begin
			   update tblFuel set FuelName = @FuelName
			   where FuelId = @FuelId
			end
			else
			begin
				if(@FuelId is not Null)
				begin
					SET IDENTITY_INSERT dbo.tblFuel ON
					insert into tblFuel (FuelId, FuelName) values (@FuelId , @FuelName)
					SET IDENTITY_INSERT dbo.tblFuel OFF
				end
				else
				begin
					SET IDENTITY_INSERT dbo.tblFuel ON
					insert into tblFuel (FuelId, FuelName) values (IDENT_CURRENT('tblFuel')+1 , @FuelName)
					SET IDENTITY_INSERT dbo.tblFuel OFF
				end
			end
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Fuel Delete ---------------------------------------------------------------------
Create or alter Procedure spFuelDelete
@FuelId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@FuelId is not Null)
			begin
				Delete from [dbo].[tblFuel] where FuelId = @FuelId
			end
			else
			begin
				Print 'FuelId is not found ' + @FuelId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go


------ Gearbox SEARCH ---------------------------------------------------------------------
Create or alter Procedure spGearboxSearchDynamicSQL
@GearboxId int = null,
@GearboxName nvarchar(50) = NULL
As
BEGIN
	BEGIN TRY  
		Begin tran
			Declare @sql nvarchar(max)
			Declare @sqlParams nvarchar(max)

			Set @sql = 'Select GearboxId, GearboxName 
						from tblGearbox 
						where 1 = 1'
    
			if(@GearboxId is not null)
				Set @sql = @sql + ' and GearboxId=@GBI'
			if(@GearboxName is not null)
				Set @sql = @sql + ' and GearboxName like(@GBN + @PS)'
     
			Execute sp_executesql @sql,
			N'@GBI int, @GBN nvarchar(50), @PS nvarchar(1)',
			@GBI=@GearboxId, @GBN=@GearboxName, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Gearbox Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spGearboxUpdateOrInsert
@GearboxId int = NULL,
@GearboxName nvarchar(50) = NULL
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (exists (select * from tblGearbox with (updlock,serializable) where GearboxId = @GearboxId))
			begin
			   update tblGearbox set GearboxName = @GearboxName
			   where GearboxId = @GearboxId
			end
			else
			begin
				if(@GearboxId is not Null)
				begin
					SET IDENTITY_INSERT dbo.tblGearbox ON
					insert into tblGearbox (GearboxId, GearboxName) values (@GearboxId, @GearboxName)
					SET IDENTITY_INSERT dbo.tblGearbox OFF
				end
				else
				begin
					SET IDENTITY_INSERT dbo.tblGearbox ON
					insert into tblGearbox (GearboxId, GearboxName) values (IDENT_CURRENT('tblGearbox')+1 , @GearboxName)
					SET IDENTITY_INSERT dbo.tblGearbox OFF
				end
			end
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Gearbox Delete ---------------------------------------------------------------------
Create or alter Procedure spGearboxDelete
@GearboxId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@GearboxId is not Null)
			begin
				Delete from tblGearbox where GearboxId = @GearboxId
			end
			else
			begin
				Print 'GearboxId is not found ' + @GearboxId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go







------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------- tblCustomer --------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------


CREATE Table tblCountry
	(
 	  CountryId int identity(1,1) primary key,
	  CountryName nvarchar(70),
	  CountryTaxPercentageValue float
	)
go

CREATE Table tblSex
	(
 	  SexId int identity(1,1) primary key,
	  SexName nvarchar(20)
	)
go

CREATE Table tblCustomer
	(
 	  CustomerId int identity(1000,1) primary key,
	  FirstName nvarchar(50),
	  LastName nvarchar(50),
	  Sex int foreign key references tblSex([SexId]),
	  Street nvarchar(50),
	  House_Number nvarchar(50),
	  PostalCode int,
	  [Location] nvarchar(50),
	  CountryId int foreign key references tblCountry(CountryId),
	  DateOfBirth datetime2,
	  TelNr float,
	  Email nvarchar(50),
	  CONSTRAINT [Unique Email Violation] UNIQUE NONCLUSTERED 
		(
			Email ASC
		),
	  CONSTRAINT [Unique Telephone Number Violation] UNIQUE NONCLUSTERED 
		(
			TelNr ASC
		)
	)
go
----- Audit tblCustomer ----------------------------------------------------------------
CREATE TABLE tblCustomerAudit
(
  CustomerAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go

------ Audit tblSex ----------------------------------------------------------------
CREATE TABLE tblSexAudit
(
  SexAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go

CREATE TABLE tblCountryAudit
(
  CountryAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go

---- FUNCTION Email Syntax Check ------------------------------------------------------------------
CREATE FUNCTION [IsEmailValid](@email nvarchar(1000))   
RETURNS bit 
BEGIN
  IF @email is null RETURN 0 
  IF @email = '' RETURN 0
  IF @email LIKE '%_@%_._%' RETURN 1 
  RETURN 0
END
go

---- Customer Email Syntax Check -- SERIALIZABLE BLOCK----------------------------------------------------------------
create or alter trigger tr_tblCustomerEmailSyntaxCheck
on tblCustomer
for insert, update -- beszúrás és módosítás is érdekel
as
Begin
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
--		Begin tran
			if exists(select 1 from inserted i where dbo.IsEmailValid(i.Email)=0)
			  throw 51234, 'Invalid Email Address', 1 
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

------ Insert Audit tblCustomer ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCustomer_ForInsert
ON tblCustomer
FOR INSERT
AS
Begin 
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = CustomerId from inserted
			  insert into tblCustomerAudit 
			 values('New Customer with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) + 
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Delete Audit tblCustomer ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCustomer_ForDelete
ON tblCustomer
FOR DELETE
AS
Begin
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = CustomerId from deleted 
			  insert into tblCustomerAudit 
			 values('An existing Customer with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) + 
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Update Audit tblCustomer ----------------------------------------------------------------
CREATE Or ALTER TRIGGER tr_tblCustomer_ForUpdate
ON tblCustomer
for Update
as
Begin
	BEGIN TRY  
--		Begin tran
			  Declare @Id int 
			  Declare @OldFirstName nvarchar(50), @NewFirstName nvarchar(50)
			  Declare @OldLastName nvarchar(50), @NewLastName nvarchar(50)
			  Declare @OldSex int, @NewSex int
			  Declare @OldStreet nvarchar(50), @NewStreet nvarchar(50)
			  Declare @OldHouse_Number nvarchar(50), @NewHouse_Number nvarchar(50)
			  Declare @OldPostalCode int, @NewPostalCode int
			  Declare @OldLocation nvarchar(50), @NewLocation nvarchar(50)
			  Declare @OldCountryId int, @NewCountryId int
			  Declare @OldDateOfBirth datetime2, @NewDateOfBirth datetime2
			  Declare @OldTelNr FLOAT, @NewTelNr FLOAT
			  Declare @OldEmail nvarchar(50), @NewEmail nvarchar(50)

			  Declare @AuditString nvarchar(1000)
      
			  Select *
			  into #TempTable
			  from inserted
     
			  While(Exists(Select CustomerId from #TempTable))
			  Begin
					Set @AuditString = ''
					Select Top 1 @Id = CustomerId, 
					  @OldFirstName = FirstName,
					  @OldLastName = LastName,
					  @OldSex = Sex,
					  @OldStreet = Street,
					  @OldHouse_Number = House_Number,
					  @OldPostalCode = PostalCode,
					  @OldLocation = [Location],
					  @OldCountryId = CountryId,
					  @OldDateOfBirth = DateOfBirth,
					  @OldTelNr = TelNr,
					  @OldEmail = Email
					from #TempTable
           
					Select 
					  @NewFirstName = FirstName,
					  @NewLastName = LastName,
					  @NewSex = Sex,
					  @NewStreet = Street,
					  @NewHouse_Number = House_Number,
					  @NewPostalCode = PostalCode,
					  @NewLocation = [Location],
					  @NewCountryId = CountryId,
					  @NewDateOfBirth = DateOfBirth,
					  @NewTelNr = TelNr,
					  @NewEmail  = Email
					from deleted where CustomerId = @Id
   
					Set @AuditString = 'Customer with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'
					if(@OldFirstName <> @NewFirstName)
						  Set @AuditString = @AuditString + ' FirstName from ' + @OldFirstName + ' to ' + @NewFirstName
           
					if(@OldLastName <> @NewLastName)
						  Set @AuditString = @AuditString + ' LastName from ' + @OldLastName + ' to ' + @NewLastName
            
					if(@OldSex <> @NewSex)
						  Set @AuditString = @AuditString + ' Sex from ' + Cast(@OldSex as nvarchar(10)) + 
						  ' to ' + Cast(@NewSex as nvarchar(10))
            
					if(@OldStreet <> @NewStreet)
						  Set @AuditString = @AuditString + ' Street from ' + @OldStreet + ' to ' + @NewStreet
            
					if(@OldHouse_Number <> @NewHouse_Number)
						  Set @AuditString = @AuditString + ' House_Number from ' + @OldHouse_Number + ' to ' + @NewHouse_Number
            
					if(@OldPostalCode <> @NewPostalCode)
						  Set @AuditString = @AuditString + ' PostalCode from ' + Cast(@OldPostalCode as nvarchar(10)) + 
						  ' to ' + Cast(@NewPostalCode as nvarchar(10))
            
					if(@OldLocation <> @NewLocation)
						  Set @AuditString = @AuditString + ' Location from ' + @OldLocation + ' to ' + @NewLocation
            
					if(@OldCountryId <> @NewCountryId)
						  Set @AuditString = @AuditString + ' CountryId from ' + @OldCountryId + ' to ' + @NewCountryId
            
					if(@OldDateOfBirth <> @NewDateOfBirth)
						  Set @AuditString = @AuditString + ' DateOfBirth from ' + Cast(@OldDateOfBirth as nvarchar(10)) + 
						  ' to ' + Cast(@NewDateOfBirth as nvarchar(10))
            
					if(@OldTelNr <> @NewTelNr)
						  Set @AuditString = @AuditString + ' TelNr from ' + Cast(@OldTelNr as nvarchar(20)) +
						  ' to ' + Cast(@NewTelNr as nvarchar(20))
            
					if(@OldEmail <> @NewEmail)
						  Set @AuditString = @AuditString + ' Email from ' + @OldEmail + ' to ' + @NewEmail
            
					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
					insert into tblCustomerAudit values(@AuditString)
            
					Delete from #TempTable where CustomerId = @Id
			  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

------ Insert Audit tblSex ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSex_ForInsert
ON tblSex
FOR INSERT
AS
BEGIN
	BEGIN TRY  
--		Begin tran
			Declare @SexId int
			Select @SexId = SexId from inserted
			insert into tblSexAudit 
			values('New Sex with Id  = ' + Cast(@SexId as nvarchar(5)) + 
				' is added at ' + cast(Getdate() as nvarchar(20)) +
				' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Delete Audit tblSex ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSex_ForDelete
ON tblSex
FOR DELETE
AS
BEGIN
	BEGIN TRY  
--		Begin tran
			Declare @SexId int
			Select @SexId = SexId from deleted
			insert into tblSexAudit 
			values('An existing Sex with Id  = ' + Cast(@SexId as nvarchar(5)) + 
				' is deleted at ' + cast(Getdate() as nvarchar(20)) +
				' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Update Audit tblSex ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSex_ForUpdate
ON tblSex
for Update
as
BEGIN
	BEGIN TRY  
--		Begin tran
			  Declare @Id int 
			  Declare @OldSexName nvarchar(50), @NewSexName nvarchar(50)
     
			  Declare @AuditString nvarchar(1000)
			  Select *
			  into #TempTable 
			  from inserted
     
			  While(Exists(Select SexId from #TempTable))
			  Begin
					Set @AuditString = ''
           
					Select Top 1 @Id = SexId, 
					@NewSexName = SexName
					from #TempTable
           
					Select 
					@OldSexName = SexName
					from deleted where SexId = @Id
   
					Set @AuditString = 'Sex with SexId = ' + Cast(@Id as nvarchar(4)) + ' changed'
					if(@OldSexName <> @NewSexName)
						  Set @AuditString = @AuditString + ' Sex Name from ' + @OldSexName + ' to ' + @NewSexName
           
					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		
					insert into tblSexAudit values(@AuditString)
            
					Delete from #TempTable where SexId = @Id
			  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

-------- Insert Audit tblCountry ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCountry_ForInsert
ON tblCountry
FOR INSERT
AS
BEGIN
	BEGIN TRY   
--		Begin tran 
			 Declare @Id int
			 Select @Id = CountryId from inserted
			  insert into tblCountryAudit 
			 values('New Country with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
-------- Delete Audit tblCountry ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCountry_ForDelete
ON tblCountry
FOR DELETE
AS
BEGIN 
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = CountryId from deleted 
			  insert into tblCountryAudit 
			 values('An existing Country with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
-------- Update Audit tblOrderStatus ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCountry_ForUpdate
ON tblCountry
for Update
as
BEGIN 
	BEGIN TRY  
--		Begin tran
			  Declare @Id int 
			  Declare @OldCountryName nvarchar(50), @NewCountryName nvarchar(50)
			  Declare @OldCountryTaxPercentageValue float, @NewCountryTaxPercentageValue float

			  Declare @AuditString nvarchar(1000)
      
			  Select *
			  into #TempTable 
			  from inserted
     
			  While(Exists(Select CountryId from #TempTable))
			  Begin
					Set @AuditString = ''
					Select Top 1 @Id = CountryId, 
						@OldCountryName = CountryName,
						@OldCountryTaxPercentageValue = CountryTaxPercentageValue
					from #TempTable
					Select 
						@NewCountryName = CountryName,
						@NewCountryTaxPercentageValue = CountryTaxPercentageValue

					from deleted where CountryId = @Id
					Set @AuditString = 'Country with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'
			
					if(@OldCountryName <> @NewCountryName)
						  Set @AuditString = @AuditString + ' Country Name from ' + 
						  @OldCountryName + ' to ' + @NewCountryName
            
					if(@OldCountryTaxPercentageValue <> @NewCountryTaxPercentageValue)
						  Set @AuditString = @AuditString + ' Country Tax Percentage Value from ' + Cast(@OldCountryTaxPercentageValue as nvarchar(10)) + 
						  ' to ' + Cast(@NewCountryTaxPercentageValue as nvarchar(10))

					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
					insert into tblCountryAudit values(@AuditString)
            
					Delete from #TempTable where CountryId = @Id
			  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go


----- View update, delete, insert Triggers --------------------------------------------------
Create or Alter View vWCustomerAllData
as
Select  CustomerId, FirstName, LastName, SexName, Street, House_Number, PostalCode, 
		[Location], CountryName, DateOfBirth, TelNr, Email
from	tblCustomer 
JOIN	tblSex
ON		tblCustomer.Sex = tblSex.SexId
JOIN	tblCountry
ON		tblCustomer.CountryId = tblCountry.CountryId
go
------------------------ Insert -- SNAPSHOT BLOCK-------------------------------------------------------------
CREATE or Alter Trigger tr_vWCustomerDetails_InsteadOfInsert
on vWCustomerAllData
Instead Of Insert
as
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
--		Begin tran
			Declare @SexId int
			Select @SexId = SexId
			from tblSex 
			join inserted
			on inserted.SexName = tblSex.SexName
			if(@SexId is null)
			Begin
			Raiserror('Invalid Sex Name. Statement terminated', 16, 1)
			return 
			End

			Declare @CountryId int
			Select @CountryId = CountryId
			from tblCountry 
			join inserted
			on inserted.CountryName = tblCountry.CountryName
			if(@CountryId is null)
			Begin
			Raiserror('Invalid Country Name. Statement terminated', 16, 1)
			return 
			End

			SET IDENTITY_INSERT dbo.tblCustomer ON
			Insert into tblCustomer(CustomerId, FirstName, LastName, Sex, Street, 
				House_Number, PostalCode, [Location], CountryId, DateOfBirth, 
				TelNr, Email)
			Select CustomerId, FirstName, LastName, @SexId, Street, House_Number, 
					PostalCode, [Location], @CountryId, DateOfBirth, TelNr, Email
			from inserted
			SET IDENTITY_INSERT dbo.tblCustomer OFF
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------------------------ DELETE -- SNAPSHOT BLOCK-------------------------------------------------------------
CREATE or Alter Trigger tr_vWCustomerDetails_InsteadOfDelete
on vWCustomerAllData
Instead Of DELETE
as
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
--		Begin tran
			Delete tblCustomer 
			from tblCustomer
			join deleted
			on tblCustomer.CustomerId = deleted.CustomerId	
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------------------------ Update -- SNAPSHOT BLOCK-------------------------------------------------------------
Create or Alter Trigger tr_vWCustomerDetails_InsteadOfUpdate
on vWCustomerAllData
instead of update
as
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
--		Begin tran
			-- if CustomerId is updated
			if(Update(CustomerId))
			Begin
				Raiserror('Id cannot be changed', 16, 1)
				Return
			End
 
			if(Update(FirstName))
			Begin
				Update tblCustomer set FirstName = inserted.FirstName
				from inserted
				join tblCustomer
				on tblCustomer.CustomerId = inserted.CustomerId
			End
	
			if(Update(LastName))
			Begin
				Update tblCustomer set LastName = inserted.LastName
				from inserted
				join tblCustomer
				on tblCustomer.CustomerId = inserted.CustomerId
			End
	
			if(Update(SexName)) 
			Begin
				Declare @SexId int

				Select @SexId = SexId
				from tblSex
				join inserted
				on inserted.SexName = tblSex.SexName
  
				if(@SexId is NULL )
				Begin
					Raiserror('Invalid Sex Name', 16, 1)
					Return
				End
  
				Update tblCustomer set Sex = @SexId
				from inserted
				join tblCustomer
				on tblCustomer.CustomerId = inserted.CustomerId
			End

			if(Update(Street))
			Begin
				Update tblCustomer set Street = inserted.Street
				from inserted
				join tblCustomer
				on tblCustomer.CustomerId = inserted.CustomerId
			End
	
			if(Update(House_Number))
			Begin
				Update tblCustomer set House_Number = inserted.House_Number
				from inserted
				join tblCustomer
				on tblCustomer.CustomerId = inserted.CustomerId
			End
	
			if(Update(PostalCode))
			Begin
				Update tblCustomer set PostalCode = inserted.PostalCode
				from inserted
				join tblCustomer
				on tblCustomer.CustomerId = inserted.CustomerId
			End
	
			if(Update([Location]))
			Begin
				Update tblCustomer set [Location] = inserted.[Location]
				from inserted
				join tblCustomer
				on tblCustomer.CustomerId = inserted.CustomerId
			End
	
			if(Update(CountryName))
			Begin
				Declare @CountryId int
				Select @CountryId = CountryId
				from tblCountry 
				join inserted
				on inserted.CountryName = tblCountry.CountryName
				if(@CountryId is null)
				Begin
					Raiserror('Invalid Country Name. Statement terminated', 16, 1)
					return
				End

				Update tblCustomer set CountryId = @CountryId
				from inserted
				join tblCustomer
				on tblCustomer.CustomerId = inserted.CustomerId
			End
	
			if(Update(DateOfBirth))
			Begin
				Update tblCustomer set DateOfBirth = inserted.DateOfBirth
				from inserted
				join tblCustomer
				on tblCustomer.CustomerId = inserted.CustomerId
			End
	
			if(Update(TelNr))
			Begin
				Update tblCustomer set TelNr = inserted.TelNr
				from inserted
				join tblCustomer
				on tblCustomer.CustomerId = inserted.CustomerId
			End
	
			if(Update(Email))
			Begin
				Update tblCustomer set Email = inserted.Email
				from inserted
				join tblCustomer
				on tblCustomer.CustomerId = inserted.CustomerId
			End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go




------- Stored Procedure ------------------------------------------------------------------------
go
------ Customer SEARCH --------------------------------------------------------------------------------------
Create or alter Procedure spCustomerSearchDynamicSQL
@CustomerId int = NULL,
@FirstName nvarchar(50) = NULL,
@LastName nvarchar(50) = NULL,
@SexName nvarchar(50) = NULL,
@Street nvarchar(50) = NULL,
@House_Number nvarchar(50) = NULL,
@PostalCode int = NULL,
@Location nvarchar(50) = NULL,
@CountryName nvarchar(50) = NULL,
@DateOfBirth datetime2 = NULL,
@TelNr FLOAT = NULL,
@Email nvarchar(50) = NULL
As
BEGIN
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)

			 Set @sql = 'Select  CustomerId, FirstName, LastName, SexName, Street, House_Number, PostalCode, 
								[Location], CountryName, DateOfBirth, TelNr, Email
						from	tblCustomer 
						JOIN	tblSex
						ON		tblCustomer.Sex = tblSex.SexId
						JOIN	tblCountry
						ON		tblCustomer.CountryId = tblCountry.CountryId
						where 1 = 1'
     
			 if(@CustomerId is not null)
				  Set @sql = @sql + ' and CustomerId =@CI'
			 if(@FirstName is not null)
				  Set @sql = @sql + ' and FirstName like(@FN + @PS)'
			 if(@LastName is not null)
				  Set @sql = @sql + ' and LastName like(@LN + @PS)'
			 if(@SexName is not null)
				  Set @sql = @sql + ' and SexName like(@Se + @PS)'
			 if(@Street is not null)
				  Set @sql = @sql + ' and Street like(@St + @PS)'
			 if(@House_Number is not null)
				  Set @sql = @sql + ' and House_Number like(@HN + @PS)'
			 if(@PostalCode is not null)
				  Set @sql = @sql + ' and PostalCode=@PC'
			 if(@Location is not null)
				  Set @sql = @sql + ' and Location like(@Lo + @PS)'
			 if(@CountryName is not null)
				  Set @sql = @sql + ' and CountryName like(@CN + @PS)'
			 if(@DateOfBirth is not null)
				  Set @sql = @sql + ' and DateOfBirth=@DOB'
			 if(@TelNr is not null)
				  Set @sql = @sql + ' and TelNr=@TN'
			 if(@Email is not null)
				  Set @sql = @sql + ' and Email like(@Em + @PS)'

			 Execute sp_executesql @sql,
			 N'@CI int, @FN nvarchar(50), @LN nvarchar(50), @Se nvarchar(50), @St nvarchar(50), @HN nvarchar(50), @PC int,
			 @Lo nvarchar(50), @CN nvarchar(50), @DOB datetime2, @TN float, @Em nvarchar(50), @PS nvarchar(1)',
			 @CI=@CustomerId, @FN=@FirstName, @LN=@LastName, @Se=@SexName, @St=@Street, @HN=@House_Number, @PC=@PostalCode,
			 @Lo=@Location, @CN=@CountryName, @DOB=@DateOfBirth, @TN=@TelNr, @Em=@Email, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Customer Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spCustomerUpdateOrInsert
@CustomerId int = NULL,
@FirstName nvarchar(50) = NULL,
@LastName nvarchar(50) = NULL,
@SexName nvarchar(50) = NULL,
@Street nvarchar(50) = NULL,
@House_Number nvarchar(50) = NULL,
@PostalCode int = NULL,
@Location nvarchar(50) = NULL,
@CountryName nvarchar(50) = NULL,
@DateOfBirth datetime2 = NULL,
@TelNr FLOAT = NULL,
@Email nvarchar(50) = NULL
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (exists (select * from vWCustomerAllData with (updlock,serializable) where CustomerId = @CustomerId))
			begin
				update vWCustomerAllData set FirstName = @FirstName, LastName = @LastName, SexName = @SexName, 
				Street = @Street, House_Number = @House_Number, PostalCode = @PostalCode, [Location] = @Location, 
				CountryName = @CountryName, DateOfBirth = @DateOfBirth, TelNr = @TelNr, Email = @Email
				where CustomerId = @CustomerId
			end
			else
			begin
				if(@CustomerId is not Null)
				begin
					insert into vWCustomerAllData  values (@CustomerId, @FirstName, @LastName, @SexName ,@Street, 
					@House_Number, @PostalCode, @Location, @CountryName, @DateOfBirth, @TelNr, @Email)
				end
				else
				begin
					insert into vWCustomerAllData  values (IDENT_CURRENT('tblCustomer')+1 , @FirstName, @LastName, 
					@SexName ,@Street, @House_Number, @PostalCode, @Location, @CountryName, @DateOfBirth, @TelNr, @Email)
				end
			end		 
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Customer Delete ---------------------------------------------------------------------
Create or alter Procedure spCustomerDelete
@CustomerId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@CustomerId is not Null)
			begin
				Delete from [dbo].[vWCustomerAllData] where CustomerId = @CustomerId
			end
			else
			begin
				Print 'CustomerId is not found ' + @CustomerId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go


------ SEX SEARCH ---------------------------------------------------------------------
Create or alter Procedure spSexSearchDynamicSQL
@SexId int = NULL,
@SexName nvarchar(50) = NULL
As
BEGIN
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)

			 Set @sql = 'Select SexId, SexName 
						from tblSex 
						where 1 = 1'
    
			 if(@SexId is not null)
				  Set @sql = @sql + ' and SexId=@SI'    
			 if(@SexName is not null)
				  Set @sql = @sql + ' and SexName like(@SN + @PS)'
     
			 Execute sp_executesql @sql,
			 N'@SI int, @SN nvarchar(50), @PS nvarchar(1)',
			 @SI=@SexId, @SN=@SexName, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ SEX Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spSexUpdateOrInsert
@SexId int = NULL,
@SexName nvarchar(50) = NULL
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (exists (select * from tblSex with (updlock,serializable) where SexId = @SexId))
			begin
			   update tblSex set SexName = @SexName
			   where SexId = @SexId
			end
			else
			begin
				if(@SexId is not Null)
				begin
					SET IDENTITY_INSERT dbo.tblSex ON
					insert into tblSex (SexId, SexName) values (@SexId, @SexName)
					SET IDENTITY_INSERT dbo.tblSex OFF
				end
				else
				begin
					SET IDENTITY_INSERT dbo.tblSex ON
					insert into tblSex (SexId, SexName) values (IDENT_CURRENT('tblSex')+1 , @SexName)
					SET IDENTITY_INSERT dbo.tblSex OFF
				end
			end
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ SEX Delete ---------------------------------------------------------------------
Create or alter Procedure spSexDelete
@SexId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@SexId is not Null)
			begin
				Delete from [dbo].[tblSex] where SexId = @SexId
			end
			else
			begin
				Print 'SexId is not found ' + @SexId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ Country SEARCH ---------------------------------------------------------------------
Create or alter Procedure spCountrySearchDynamicSQL
@CountryId int = NULL,
@CountryName nvarchar(50) = NULL,
@CountryTaxPercentageValue float = NULL
As
BEGIN 
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max) 

			 Set @sql = 'Select CountryId, CountryName, CountryTaxPercentageValue 
						from tblCountry 
						where 1 = 1'
    
				 if(@CountryId is not null)
				  Set @sql = @sql + ' and CountryId=@CI'

			 if(@CountryName is not null)
				  Set @sql = @sql + ' and CountryName like(@CN + @PS)'
     
			 if(@CountryTaxPercentageValue is not null)
				  Set @sql = @sql + ' and CountryTaxPercentageValue=@CTPV'
     
			 Execute sp_executesql @sql,
			 N'@CI int, @CN nvarchar(50), @CTPV float, @PS nvarchar(1)',
			 @CI=@CountryId, @CN=@CountryName, @CTPV=@CountryTaxPercentageValue, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Country Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spCountryUpdateOrInsert
@CountryId int = NULL,
@CountryName nvarchar(50) = NULL,
@CountryTaxPercentageValue float = NULL
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (exists (select * from tblCountry with (updlock,serializable) where CountryId = @CountryId))
			begin
			   update tblCountry set CountryName = @CountryName, CountryTaxPercentageValue = @CountryTaxPercentageValue
			   where CountryId = @CountryId
			end
			else
			begin
				if(@CountryId is not Null)
				begin
					SET IDENTITY_INSERT dbo.tblCountry ON
					insert into tblCountry (CountryId, CountryName, CountryTaxPercentageValue) values (@CountryId , @CountryName, @CountryTaxPercentageValue)
					SET IDENTITY_INSERT dbo.tblCountry OFF
				end
				else
				begin
					SET IDENTITY_INSERT dbo.tblCountry ON
					insert into tblCountry (CountryId, CountryName, CountryTaxPercentageValue) values (IDENT_CURRENT('tblCountry')+1 , @CountryName, @CountryTaxPercentageValue)
					SET IDENTITY_INSERT dbo.tblCountry OFF
				end
			end
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Country Delete ---------------------------------------------------------------------
Create or alter Procedure spCountryDelete
@CountryId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@CountryId is not Null)
			begin
				Delete from [dbo].[tblCountry] where CountryId = @CountryId
			end
			else
			begin
				Print 'CountryId is not found ' + @CountryId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go





------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---------------tblSalespersons------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------



USE CarDealerShipDB
go

Create Table tblSpokenLangues
	(
 	  SpokenLanguesId int identity(1,1) primary key,
	  SpokenLanguesName nvarchar(20)
	)
go

Create Table tblSalespersons
	(
 	  SalesId int identity(1,1) primary key,
	  FirstName nvarchar(50),
	  LastName nvarchar(50),
	  Sex int foreign key references tblSex([SexId]),
	  SpokenLangues int foreign key references tblSpokenLangues(SpokenLanguesId),
	  ManagerID int
	)
go

Create Table tblSalespersonsSecretData
	(
 	  SalesId int primary key,
	  DateOfBirth datetime2,
	  Street nvarchar(50),
	  House_Number nvarchar(50),
	  PostalCode int,
	  [Location] nvarchar(50),
	  CountryId int foreign key references tblCountry(CountryId),
	  EntryDate datetime2,
	  TelNr float,
	  Email nvarchar(50),
	  CONSTRAINT [Unique SalesP Email Violation] UNIQUE NONCLUSTERED 
		(
			Email ASC
		),
	  CONSTRAINT [Unique SalesP Telephone Number Violation] UNIQUE NONCLUSTERED 
		(
			TelNr ASC
		)
	)
go

---- Audit tblSalespersons ----------------------------------------------------------------
CREATE TABLE tblSalespersonAudit
(
  SalespersonAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go
---- Audit tblSpokenLanguages ----------------------------------------------------------------
CREATE TABLE tblSpokenLanguesAudit
(
  SpokenLanguesAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go

---- Salespersons Secret Data Email Syntax Check -- SERIALIZABLE BLOCK----------------------------------------------------------------
create OR ALTER trigger tr_tblSalespersonsSecretDataEmailSyntaxCheck
  on tblSalespersonsSecretData
  for insert, update 
as
Begin
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
--		Begin tran
			if exists(select 1 from inserted i where dbo.IsEmailValid(i.Email)=0)
			  throw 51234, 'invalid email address', 1		
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

------ Insert Audit tblSalesperson ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSalesperson_ForInsert
ON tblSalespersons
FOR INSERT
AS
Begin
	BEGIN TRY  
--		Begin tran
			Declare @Id int
			 Select @Id = SalesId from inserted
			 insert into tblSalespersonAudit 
			 values('New Salesperson with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) + 
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Delete Audit tblSalesperson ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSalesperson_ForDelete
ON tblSalespersons
FOR DELETE
AS
Begin
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = SalesId from deleted 
			 insert into tblSalespersonAudit 
			 values('An existing Salesperson with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) + 
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Update Audit tblSalesperson ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSalesperson_ForUpdate
ON tblSalespersons
for Update
as
Begin
	BEGIN TRY  
--		Begin tran
		  Declare @Id int 
		  Declare @OldFirstName nvarchar(50), @NewFirstName nvarchar(50)
		  Declare @OldLastName nvarchar(50), @NewLastName nvarchar(50)
		  Declare @OldSex int, @NewSex int
		  Declare @OldSpokenLangues int, @NewSpokenLangues int
		  Declare @OldManagerID int, @NewManagerID int
		  Declare @AuditString nvarchar(1000)
		  Select *
		  into #TempTable 
		  from inserted
		  While(Exists(Select SalesId from #TempTable))
		  Begin
				Set @AuditString = ''
				Select Top 1 @Id = SalesId, 
				  @OldFirstName = FirstName,
				  @OldLastName = LastName,
				  @OldSex = Sex,
				  @OldSpokenLangues = SpokenLangues,
				  @OldManagerID = ManagerID
				from #TempTable
           
				Select 
				  @NewFirstName = FirstName,
				  @NewLastName = LastName,
				  @NewSex = Sex,
				  @NewSpokenLangues = SpokenLangues,
				  @NewManagerID = ManagerID
				from deleted where SalesId = @Id
   
				Set @AuditString = 'Salesperson with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'

				if(@OldFirstName <> @NewFirstName)
					  Set @AuditString = @AuditString + ' FirstName from ' + @OldFirstName + ' to ' + @NewFirstName
           
				if(@OldLastName <> @NewLastName)
					  Set @AuditString = @AuditString + ' LastName from ' + @OldLastName + ' to ' + @NewLastName
            
				if(@OldSex <> @NewSex)
					  Set @AuditString = @AuditString + ' Sex from ' + Cast(@OldSex as nvarchar(10)) + 
					  ' to ' + Cast(@NewSex as nvarchar(10))
            
				if(@OldSpokenLangues <> @NewSpokenLangues)
					  Set @AuditString = @AuditString + ' Spoken Langues from ' + Cast(@OldSpokenLangues as nvarchar(10)) + 
					  ' to ' + Cast(@NewSpokenLangues as nvarchar(10))
            
				if(@OldManagerID <> @NewManagerID)
					  Set @AuditString = @AuditString + ' ManagerId from ' + Cast(@OldManagerID as nvarchar(10)) + 
					  ' to ' + Cast(@NewManagerID as nvarchar(10))
            
				Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
				insert into tblSalespersonAudit values(@AuditString)
            
				Delete from #TempTable where SalesId = @Id
		  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

------ Insert Audit tblSalespersonsSecretData ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSalespersonsSecretData_ForInsert
ON tblSalespersonsSecretData
FOR INSERT
AS
Begin
	BEGIN TRY  
--		Begin tran
		 Declare @Id int
		 Select @Id = SalesId from inserted
		  insert into tblSalespersonAudit 
		 values('New SalespersonsSecretData with Id  = ' + Cast(@Id as nvarchar(5)) + 
				' is added at ' + cast(Getdate() as nvarchar(20)) + 
				' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Delete Audit tblSalespersonsSecretData ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSalespersonsSecretData_ForDelete
ON tblSalespersonsSecretData
FOR DELETE
AS
Begin
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = SalesId from deleted 
			  insert into tblSalespersonAudit 
			 values('An existing SalespersonsSecretData with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) + 
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Update Audit tblSalespersonsSecretData ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSalespersonsSecretData_ForUpdate
ON tblSalespersonsSecretData
for Update
as
Begin
	BEGIN TRY  
--		Begin tran
			  -- Változók deklarálása a régi és frissített adatok
			  Declare @Id int -- nem változik 
			  Declare @OldDateOfBirth datetime2, @NewDateOfBirth datetime2
			  Declare @OldStreet nvarchar(50), @NewStreet nvarchar(50)
			  Declare @OldHouse_Number nvarchar(50), @NewHouse_Number nvarchar(50)
			  Declare @OldPostalCode int, @NewPostalCode int
			  Declare @OldLocation nvarchar(50), @NewLocation nvarchar(50)
			  Declare @OldCountryId int, @NewCountryId int
			  Declare @OldEntryDate datetime2, @NewEntryDate datetime2
			  Declare @OldTelNr FLOAT, @NewTelNr FLOAT
			  Declare @OldEmail nvarchar(50), @NewEmail nvarchar(50)

			  -- Változó az audit karakterlánc
			  Declare @AuditString nvarchar(max)
      
			  -- Töltse be a frissített rekordokat az ideiglenes táblába
			  -- ha valaki frissít egy adott sort, az új adatok a beszúrt
			  -- táblában lesznek ezeket tároljuk a #TempTable-ben
			  Select *
			  into #TempTable -- tedd be ezt a sort az ideiglenes táblába
			  from inserted
			----------+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
			  -- Hurok a temp tábla
			  -- mivel tetszőleges számú azonosítót adhatunk meg, így ha 
			  -- ennyi rekordok frissítünk egyszerre, akkor ciklust kell használni
			  -- mert frissíteni akarunk minden kiválasztott alkalmazottat
			  -- ezért tesszük az ideiglenes táblába
			  -- az ideiglenes táblából kiválasztjuk az azonosítókat, ha vannak
			  -- ha nincsenek, akkor nem ad vissza semmit az Exists() függvény 
			  -- false értéket ad vissza
			  While(Exists(Select SalesId from #TempTable))
			  Begin
					--Inicializálja az audit karakterláncot az üres karakterlánchoz
					Set @AuditString = ''
           
					-- Válassza ki az első sor adatait a temp táblából
					-- mert ezt a sort a frissítési művelet befejezése után 
					-- köveztkező lépésben törölni fogom
					-- az új megváltoztatott adatokat tartalmazza
					Select Top 1 @Id = SalesId, 
					  @OldDateOfBirth = DateOfBirth,
					  @OldStreet = Street,
					  @OldHouse_Number = House_Number,
					  @OldPostalCode = PostalCode,
					  @OldLocation = [Location],
					  @OldCountryId = CountryId,
					  @OldEntryDate = EntryDate,
					  @OldTelNr = TelNr,
					  @OldEmail = Email
					from #TempTable
           
					-- Válassza ki a megfelelő sort a törölt táblázatból
					-- a régi eredeti adatokat tartalmazza
					Select 
					  @NewDateOfBirth = DateOfBirth,
					  @NewStreet = Street,
					  @NewHouse_Number = House_Number,
					  @NewPostalCode = PostalCode,
					  @NewLocation = [Location],
					  @NewCountryId = CountryId,
					  @NewEntryDate = EntryDate,
					  @NewTelNr = TelNr,
					  @NewEmail  = Email
					from deleted where SalesId = @Id
   
					--  Az audit karakterlánc összeállítása dinamikusan
					-- régi és új adatok összehasonlítása, majd a karakterláncba fűzése
					Set @AuditString = 'SalespersonsSecretData with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'
            
					if(@OldDateOfBirth <> @NewDateOfBirth)
						  Set @AuditString = @AuditString + ' DateOfBirth from ' + Cast(@OldDateOfBirth as nvarchar(10)) + 
						  ' to ' + Cast(@NewDateOfBirth as nvarchar(10))
            
					if(@OldStreet <> @NewStreet)
						  Set @AuditString = @AuditString + ' Street from ' + @OldStreet + ' to ' + @NewStreet
            
					if(@OldHouse_Number <> @NewHouse_Number)
						  Set @AuditString = @AuditString + ' House_Number from ' + @OldHouse_Number + ' to ' + @NewHouse_Number
            
					if(@OldPostalCode <> @NewPostalCode)
						  Set @AuditString = @AuditString + ' PostalCode from ' + Cast(@OldPostalCode as nvarchar(10)) + 
						  ' to ' + Cast(@NewPostalCode as nvarchar(10))
            
					if(@OldLocation <> @NewLocation)
						  Set @AuditString = @AuditString + ' Location from ' + @OldLocation + ' to ' + @NewLocation
            
					if(@OldCountryId <> @NewCountryId)
						  Set @AuditString = @AuditString + ' CountryId from ' + Cast(@OldCountryId as nvarchar(10)) + ' to ' + Cast(@NewCountryId as nvarchar(10))
            
					if(@OldEntryDate <> @NewEntryDate)
						  Set @AuditString = @AuditString + ' EntryDate from ' + Cast(@OldEntryDate as nvarchar(10)) + 
						  ' to ' + Cast(@NewEntryDate as nvarchar(10))
            
					if(@OldTelNr <> @NewTelNr)
						  Set @AuditString = @AuditString + ' TelNr from ' + Cast(@OldTelNr as nvarchar(20)) +
						  ' to ' + Cast(@NewTelNr as nvarchar(20))
            
					if(@OldEmail <> @NewEmail)
						  Set @AuditString = @AuditString + ' Email from ' + @OldEmail + ' to ' + @NewEmail
            
					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
					-- ellenőrzés és karakterlánc fűzés után eltároljuk, a számozás automatikus
					insert into tblSalespersonAudit values(@AuditString)
            
					-- Töröljük a sort a temp táblából
					Delete from #TempTable where SalesId = @Id
			  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
GO

------ Insert Audit tblSpokenLanguages ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSpokenLangues_ForInsert
ON tblSpokenLangues
FOR INSERT
AS
Begin
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = SpokenLanguesId from inserted
			  insert into tblSpokenLanguesAudit  
			 values('New Spoken Langues with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) + 
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Delete Audit tblSpokenLanguages ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSpokenLangues_ForDelete
ON tblSpokenLangues
FOR DELETE
AS
Begin
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = SpokenLanguesId from deleted 
			  insert into tblSpokenLanguesAudit 
			 values('An existing Spoken Langues with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) + 
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Update Audit tblSpokenLanguages ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblSpokenLangues_ForUpdate
ON tblSpokenLangues
for Update
as
Begin
	BEGIN TRY  
--		Begin tran
		  Declare @Id int 
		  Declare @OldSpokenLanguesName nvarchar(50), @NewSpokenLanguesName nvarchar(50)
		  Declare @AuditString nvarchar(1000)
		  Select *
		  into #TempTable
		  from inserted
     
		  While(Exists(Select SpokenLanguesId from #TempTable))
		  Begin
				Set @AuditString = ''
				Select Top 1 @Id = SpokenLanguesId, 
				  @OldSpokenLanguesName = SpokenLanguesName
				from #TempTable
				Select 
				  @NewSpokenLanguesName = SpokenLanguesName
				from deleted where SpokenLanguesId = @Id
   
				Set @AuditString = 'Spoken Langues with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'

				if(@OldSpokenLanguesName <> @NewSpokenLanguesName)
					  Set @AuditString = @AuditString + ' Spoken Langues Name from ' + @OldSpokenLanguesName + ' to ' + @NewSpokenLanguesName
           
				Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
				insert into tblSpokenLanguesAudit values(@AuditString)
            
				Delete from #TempTable where SpokenLanguesId = @Id
		  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

----- View update, delete, insert Triggers --------------------------------------------------
Create or Alter View vWSalespersonsAllData
as
Select S.SalesId, S.FirstName, S.LastName, tblSex.SexName, tblSpokenLangues.SpokenLanguesName, S.ManagerID, 
ISNULL(M.FirstName, 'No Manager') as ManagerFirstName, ISNULL(M.LastName, 'No Manager') as ManagerLastName, 
DateOfBirth, Street, House_Number, PostalCode, [Location], CountryName, EntryDate, TelNr, Email
From			tblSalespersons S
JOIN			tblSalespersonsSecretData
on				tblSalespersonsSecretData.SalesId = S.SalesId
JOIN			tblSex
ON				S.Sex = tblSex.SexId
JOIN			tblSpokenLangues
ON				tblSpokenLangues.SpokenLanguesId = S.SpokenLangues
Left JOIN		tblSalespersons M
ON				S.ManagerID = M.SalesId
JOIN			tblCountry
ON				tblSalespersonsSecretData.CountryId = tblCountry.CountryId
go
------------------------ Insert -- SNAPSHOT BLOCK-------------------------------------------------------------
CREATE or Alter Trigger tr_vWSalespersonsDetails_InsteadOfInsert
on vWSalespersonsAllData
Instead Of Insert
as
Begin
	BEGIN TRY    
	  -- SNAPSHOT full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--		Begin tran
			Declare @SexId int
			Select @SexId = SexId
			from tblSex 
			join inserted
			on inserted.SexName = tblSex.SexName
			if(@SexId is null)
				Begin
				Raiserror('Invalid Sex Name. Statement terminated', 16, 1)
				return 
			End

			-- Spoken Languages
			Declare @SpokenLanguesId int
			Select @SpokenLanguesId = SpokenLanguesId
			from tblSpokenLangues 
			join inserted
			on inserted.SpokenLanguesName = tblSpokenLangues.SpokenLanguesName
			if(@SpokenLanguesId is null)
				Begin
				Raiserror('Invalid Spoken Langues Name. Statement terminated', 16, 1)
				return
			End

			Declare @CountryId int
			Select @CountryId = CountryId
			from tblCountry 
			join inserted
			on inserted.CountryName = tblCountry.CountryName
			if(@CountryId is null)
			Begin
			Raiserror('Invalid Country Name. Statement terminated', 16, 1)
			return 
			End
		
			SET IDENTITY_INSERT dbo.tblSalespersons ON

			Insert into tblSalespersons(SalesId, FirstName, LastName, Sex, SpokenLangues, ManagerID)
			Select SalesId, FirstName, LastName, @SexId, @SpokenLanguesId, ManagerID
			from inserted

			Insert into tblSalespersonsSecretData(SalesId, DateOfBirth, Street, House_Number, PostalCode, 
			[Location], CountryId, EntryDate, TelNr, Email)
			Select SalesId, DateOfBirth, Street, House_Number, PostalCode, 
			[Location], @CountryId, EntryDate, TelNr, Email
			from inserted

			SET IDENTITY_INSERT dbo.tblSalespersons OFF
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End


go
------------------------ DELETE -- SNAPSHOT BLOCK-------------------------------------------------------------
CREATE or Alter Trigger tr_vWSalespersonsDetails_InsteadOfDelete
on vWSalespersonsAllData
Instead Of DELETE
as
Begin
	BEGIN TRY  
	  -- SNAPSHOT full blocking until finalization 
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--		Begin tran
			Delete tblSalespersons 
			from tblSalespersons
			join deleted
			on tblSalespersons.SalesId = deleted.SalesId

			Delete tblSalespersonsSecretData 
			from tblSalespersonsSecretData
			join deleted
			on tblSalespersonsSecretData.SalesId = deleted.SalesId
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End




go
------------------------ Update -- SNAPSHOT BLOCK-------------------------------------------------------------
Create Or Alter Trigger tr_vWSalespersonsDetails_InsteadOfUpdate
on vWSalespersonsAllData
instead of update
as
Begin
	BEGIN TRY  
--		Begin tran
			-- if SalesId is updated
			if(Update(SalesId))
			Begin
				Raiserror('Id cannot be changed', 16, 1)
				Return
			End

			if(Update(FirstName))
			Begin
				Update tblSalespersons set FirstName = inserted.FirstName
				from inserted
				join tblSalespersons
				on tblSalespersons.SalesId = inserted.SalesId
			End
	
			if(Update(LastName))
			Begin
				Update tblSalespersons set LastName = inserted.LastName
				from inserted
				join tblSalespersons
				on tblSalespersons.SalesId = inserted.SalesId
			End
	
			if(Update(SexName)) 
			Begin
				Declare @SexId int

				Select @SexId = SexId
				from tblSex
				join inserted
				on inserted.SexName = tblSex.SexName
  
				if(@SexId is NULL )
				Begin
					Raiserror('Invalid Sex Name', 16, 1)
					Return
				End
  
				Update tblSalespersons set Sex = @SexId
				from inserted
				join tblSalespersons
				on tblSalespersons.SalesId = inserted.SalesId
			End

			if(Update(SpokenLanguesName)) 
			Begin
				Declare @SpokenLanguesId int

				Select @SpokenLanguesId = SpokenLanguesId
				from tblSpokenLangues
				join inserted
				on inserted.SpokenLanguesName = tblSpokenLangues.SpokenLanguesName
  
				if(@SpokenLanguesId is NULL )
				Begin
					Raiserror('Invalid Spoken Languages Name', 16, 1)
					Return
				End
  
				Update tblSalespersons set SpokenLangues = @SpokenLanguesId
				from inserted
				join tblSalespersons
				on tblSalespersons.SalesId = inserted.SalesId
			End
	
			if(Update(ManagerId))
			Begin
				Update tblSalespersons set ManagerId = inserted.ManagerId
				from inserted
				join tblSalespersons
				on tblSalespersons.SalesId = inserted.SalesId
			End
	
			if(Update(DateOfBirth))
			Begin
				Update tblSalespersonsSecretData set DateOfBirth = inserted.DateOfBirth
				from inserted
				join tblSalespersonsSecretData
				on tblSalespersonsSecretData.SalesId = inserted.SalesId
			End
	
			if(Update(Street))
			Begin
				Update tblSalespersonsSecretData set Street = inserted.Street
				from inserted
				join tblSalespersonsSecretData
				on tblSalespersonsSecretData.SalesId = inserted.SalesId
			End
	
			if(Update(House_Number))
			Begin
				Update tblSalespersonsSecretData set House_Number = inserted.House_Number
				from inserted
				join tblSalespersonsSecretData
				on tblSalespersonsSecretData.SalesId = inserted.SalesId
			End
	
			if(Update(PostalCode))
			Begin
				Update tblSalespersonsSecretData set PostalCode = inserted.PostalCode
				from inserted
				join tblSalespersonsSecretData
				on tblSalespersonsSecretData.SalesId = inserted.SalesId
			End
	
			if(Update([Location]))
			Begin
				Update tblSalespersonsSecretData set [Location] = inserted.[Location]
				from inserted
				join tblSalespersonsSecretData
				on tblSalespersonsSecretData.SalesId = inserted.SalesId
			End
	
			if(Update(CountryName))
			Begin
				Declare @CountryId int
				Select @CountryId = CountryId
				from tblCountry 
				join inserted
				on inserted.CountryName = tblCountry.CountryName
				if(@CountryId is null)
				Begin
					Raiserror('Invalid Country Name. Statement terminated', 16, 1)
					return
				End

				Update tblSalespersonsSecretData set CountryId = @CountryId
				from inserted
				join tblSalespersonsSecretData
				on tblSalespersonsSecretData.SalesId = inserted.SalesId
			End
	
			if(Update(EntryDate))
			Begin
				Update tblSalespersonsSecretData set EntryDate = inserted.EntryDate
				from inserted
				join tblSalespersonsSecretData
				on tblSalespersonsSecretData.SalesId = inserted.SalesId
			End
	
			if(Update(TelNr))
			Begin
				Update tblSalespersonsSecretData set TelNr = inserted.TelNr
				from inserted
				join tblSalespersonsSecretData
				on tblSalespersonsSecretData.SalesId = inserted.SalesId
			End
	
			if(Update(Email))
			Begin
				Update tblSalespersonsSecretData set Email = inserted.Email
				from inserted
				join tblSalespersonsSecretData
				on tblSalespersonsSecretData.SalesId = inserted.SalesId
			End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go


------- Stored Procedure ------------------------------------------------------------------------
go
------ Salespersons SEARCH ------------------------------------------------------------------------------
Create or alter Procedure spSalespersonsSearchDynamicSQL
@SalesId int = NULL,
@FirstName nvarchar(50) = NULL,
@LastName nvarchar(50) = NULL,
@SexName nvarchar(50) = NULL,
@SpokenLanguesName nvarchar(20) = NULL,
@ManagerId int = NULL,
@ManagerFirstName nvarchar(50) = NULL,
@ManagerLastName nvarchar(50) = NULL,
@DateOfBirth datetime2 = NULL,
@Street nvarchar(50) = NULL,
@House_Number nvarchar(50) = NULL,
@PostalCode int = NULL,
@Location nvarchar(50) = NULL,
@CountryName nvarchar(50) = NULL,
@EntryDate datetime2 = NULL,
@TelNr FLOAT = NULL,
@Email nvarchar(50) = NULL
As
Begin
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)

				Set @sql = 'Select S.SalesId, S.FirstName, S.LastName, tblSex.SexName, tblSpokenLangues.SpokenLanguesName, S.ManagerID, ISNULL(M.FirstName, @Manager) as ManagerFirstName,
							ISNULL(M.LastName, @Manager) as ManagerLastName, DateOfBirth, Street, House_Number, PostalCode, [Location], CountryName, EntryDate, TelNr, Email
							From			tblSalespersons S
							JOIN			tblSalespersonsSecretData
							on				tblSalespersonsSecretData.SalesId = S.SalesId
							JOIN			tblSex
							ON				S.Sex = tblSex.SexId
							JOIN			tblSpokenLangues
							ON				tblSpokenLangues.SpokenLanguesId = S.SpokenLangues
							Left JOIN		tblSalespersons M
							ON				S.ManagerID = M.SalesId
							JOIN			tblCountry
							ON				tblSalespersonsSecretData.CountryId = tblCountry.CountryId
							where 1 = 1'
     
			 if(@SalesId is not null)
				  Set @sql = @sql + ' and S.SalesId=@SI'
			 if(@FirstName is not null)
				  Set @sql = @sql + ' and S.FirstName like(@FN + @PS)'
			 if(@LastName is not null)
				  Set @sql = @sql + ' and S.LastName like(@LN + @PS)'
			 if(@SexName is not null)
				  Set @sql = @sql + ' and SexName like(@Se + @PS)'
			 if(@SpokenLanguesName is not null)
				  Set @sql = @sql + ' and SpokenLanguesName like(@SLN + @PS)'
			 if(@ManagerId is not null)
				  Set @sql = @sql + ' and S.ManagerID=@MI'
			 if(@ManagerFirstName is not null)
				  Set @sql = @sql + ' and M.FirstName like(@MFN + @PS)'
			 if(@ManagerLastName is not null)
				  Set @sql = @sql + ' and M.LastName like(@MLN + @PS)'		  
			 if(@DateOfBirth is not null)
				  Set @sql = @sql + ' and DateOfBirth=@DOB'
			 if(@Street is not null)
				  Set @sql = @sql + ' and Street like(@St + @PS)'
			 if(@House_Number is not null)
				  Set @sql = @sql + ' and House_Number like(@HN + @PS)'
			 if(@PostalCode is not null)
				  Set @sql = @sql + ' and PostalCode=@PC'
			 if(@Location is not null)
				  Set @sql = @sql + ' and Location like(@Lo + @PS)'
			 if(@CountryName is not null)
				  Set @sql = @sql + ' and CountryName like(@CN + @PS)'
			 if(@EntryDate is not null)
				  Set @sql = @sql + ' and EntryDate=@ED'
			 if(@TelNr is not null)
				  Set @sql = @sql + ' and TelNr=@TN'
			 if(@Email is not null)
				  Set @sql = @sql + ' and Email like(@Em + @PS)'

			 Execute sp_executesql @sql,
			 N'@SI int, @FN nvarchar(50), @LN nvarchar(50), @Se nvarchar(50), @SLN nvarchar(50), @MI int, @MFN nvarchar(50),
			 @MLN nvarchar(50), @DOB datetime2, @St nvarchar(50), @HN nvarchar(50), @PC int,
			 @Lo nvarchar(50), @CN nvarchar(50), @ED datetime2, @TN float, @Em nvarchar(50), @Manager nvarchar(10), @PS nvarchar(1)',
			 @SI=@SalesId, @FN=@FirstName, @LN=@LastName, @Se=@SexName, @SLN=@SpokenLanguesName, @MI=@ManagerId, @MFN=@ManagerFirstName,
			 @MLN=@ManagerLastName, @DOB=@DateOfBirth, @St=@Street, @HN=@House_Number, @PC=@PostalCode,
			 @Lo=@Location, @CN=@CountryName, @ED=@EntryDate, @TN=@TelNr, @Em=@Email, @Manager = 'No Manager', @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Salespersons Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spSalespersonsUpdateOrInsert
@SalesId int = NULL,
@FirstName nvarchar(50) = NULL,
@LastName nvarchar(50) = NULL,
@SexName nvarchar(50) = NULL,
@SpokenLanguesName nvarchar(20) = NULL,
@ManagerId int = NULL,
@ManagerFirstName nvarchar(50) = NULL,
@ManagerLastName nvarchar(50) = NULL,
@DateOfBirth datetime2 = NULL,
@Street nvarchar(50) = NULL,
@House_Number nvarchar(50) = NULL,
@PostalCode int = NULL,
@Location nvarchar(50) = NULL,
@CountryName nvarchar(50) = NULL,
@EntryDate datetime2 = NULL,
@TelNr FLOAT = NULL,
@Email nvarchar(50) = NULL
AS
Begin
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (exists (select * from vWSalespersonsAllData with (updlock,serializable) where SalesId = @SalesId))
				begin
				   update vWSalespersonsAllData set FirstName = @FirstName, LastName = @LastName, SexName = @SexName, 
						SpokenLanguesName = @SpokenLanguesName, ManagerId = @ManagerId, DateOfBirth = @DateOfBirth,
						Street = @Street, House_Number = @House_Number, PostalCode = @PostalCode, 
						Location = @Location, CountryName = @CountryName, EntryDate = @EntryDate, TelNr = @TelNr, Email = @Email
				   where SalesId = @SalesId
				end
				else
				begin
					if(@SalesId is not Null)
					begin
						insert into vWSalespersonsAllData  values (@SalesId , @FirstName, @LastName, @SexName, 
						@SpokenLanguesName, @ManagerId, @ManagerFirstName, @ManagerLastName, @DateOfBirth, @Street, 
						@House_Number, @PostalCode, @Location, @CountryName, @EntryDate, @TelNr, @Email)
					end
					else
					begin
						insert into vWSalespersonsAllData  values (IDENT_CURRENT('tblSalespersons')+1 , @FirstName, 
						@LastName, @SexName, @SpokenLanguesName, @ManagerId, @ManagerFirstName, @ManagerLastName, @DateOfBirth, 
						@Street, @House_Number, @PostalCode, @Location, @CountryName, @EntryDate, @TelNr, @Email)
					end
				end
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Salespersons Delete ---------------------------------------------------------------------
Create or alter Procedure spSalespersonsDelete
@SalesId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@SalesId is not Null)
			begin
				Delete from  [dbo].[vWSalespersonsAllData] where SalesId = @SalesId
			end
			else
			begin
				Print 'SalesId is not found ' + @SalesId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ SpokenLanguages SEARCH ---------------------------------------------------------------------
Create or alter Procedure spSpokenLanguesSearchDynamicSQL
@SpokenLanguesId int = NULL,
@SpokenLanguesName nvarchar(50) = NULL
As
Begin
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)

			 Set @sql = 'Select SpokenLanguesId, SpokenLanguesName 
						from tblSpokenLangues 
						where 1 = 1'
    
			 if(@SpokenLanguesId is not null)
				  Set @sql = @sql + ' and SpokenLanguesId=@SLI'
			 if(@SpokenLanguesName is not null)
				  Set @sql = @sql + ' and SpokenLanguesName like(@SLN + @PS)'
     
			 Execute sp_executesql @sql,
			 N'@SLI int, @SLN nvarchar(50), @PS nvarchar(1)',
			 @SLI=@SpokenLanguesId, @SLN=@SpokenLanguesName, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ SpokenLangues Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spSpokenLanguesUpdateOrInsert
@SpokenLanguesId int = NULL,
@SpokenLanguesName nvarchar(50) = NULL
AS
Begin
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (exists (select * from tblSpokenLangues with (updlock,serializable) where SpokenLanguesId = @SpokenLanguesId))
			begin
			   update tblSpokenLangues set SpokenLanguesName = @SpokenLanguesName
			   where SpokenLanguesId = @SpokenLanguesId
			end
			else
			begin
				if(@SpokenLanguesId is not Null)
				begin
					SET IDENTITY_INSERT dbo.tblSpokenLangues ON
					insert into tblSpokenLangues (SpokenLanguesId, SpokenLanguesName) values (@SpokenLanguesId , @SpokenLanguesName)
					SET IDENTITY_INSERT dbo.tblSpokenLangues OFF
				end
				else
				begin
					SET IDENTITY_INSERT dbo.tblSpokenLangues ON
					insert into tblSpokenLangues (SpokenLanguesId, SpokenLanguesName) values (IDENT_CURRENT('tblSpokenLangues')+1 , @SpokenLanguesName)
					SET IDENTITY_INSERT dbo.tblSpokenLangues OFF
				end
			end
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ SpokenLangues Delete ---------------------------------------------------------------------
Create or alter Procedure spSpokenLanguesDelete
@SpokenLanguesId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@SpokenLanguesId is not Null)
			begin
				Delete from [dbo].[tblSpokenLangues] where SpokenLanguesId = @SpokenLanguesId
			end
			else
			begin
				Print 'SpokenLanguesId is not found ' + @SpokenLanguesId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go




------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------- tblCarsAccessories ------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------


Create Table tblCarAccessoriesProductGroup
	(
		CAPGId int identity(1,1) primary key,
		CAPGName nvarchar(50),
		CONSTRAINT [Unique Car Accessories Product Name Violation] UNIQUE NONCLUSTERED 
		(
			CAPGName ASC
		)
	)
go

Create Table tblCarAccessoriesUnit
	(
 	  CAUId int identity(1,1) primary key,
	  UnitName nvarchar(50)
	)
go

Create Table tblCarAccessoriesStock
	(
 	  CASId int primary key,
	  QuantityOfStock int,
	  MinimumStockQuantity int,
	  LastUpdateTime datetime2--Az utolsó frissítés dátuma dátuma. Trigger a frissítéshez, ami beszúrja a dátumot és időt
	)
go

Create Table tblCarAccessories
	(
 	  CAId int identity(1,1) primary key,
	  ProductName nvarchar(50),
	  ProductGroupId int foreign key references tblCarAccessoriesProductGroup(CAPGId),
	  NetSellingPrice float, -- nettó eladási ár
	  SalesUnit float, -- eladási egység kiszerelés
	  Unit int foreign key references tblCarAccessoriesUnit(CAUId), -- egység liter, kg, darab
	  Brand nvarchar(50),--Karakterlánc, amely biztosítja a termék márkáját.
	  CreationDate datetime2,--A termék létrehozásának dátuma.
	  [Description] nvarchar(max), -- Rövid leíró szöveg a termékkel való megjelenítéshez.
	  [Version] int, -- Egész szám, amely a termék frissítésekor automatikusan növekszik; a verzióütközés megelőzésére szolgál.
	  PhotoPath nvarchar(100)
	)
go

---- Audit tblCarAccessories ----------------------------------------------------------------
CREATE TABLE tblCarAccessoriesAudit
(
  CarAccessoriesAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go
---- Audit tblCarAccessoriesStock ----------------------------------------------------------------
CREATE TABLE tblCarAccessoriesStockAudit
(
  CarAccessoriesStockAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go
---- Audit tblCarAccessoriesProductGroup ----------------------------------------------------------------
CREATE TABLE tblCarAccessoriesProductGroupAudit
(
  CarAccessoriesProductGroupAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go
---- Audit tblCarAccessoriesUnitAudit ----------------------------------------------------------------
CREATE TABLE tblCarAccessoriesUnitAudit
(
  CarAccessoriesUnitAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go

---- Car Accessories Stock Timestamp -- SERIALIZABLE BLOCK----------------------------------------------------------------
CREATE OR ALTER Trigger tr_tblCarAccessoriesStock_Timestamp
on tblCarAccessoriesStock for insert, update
as 
BEGIN
	BEGIN TRY  
	  -- SNAPSHOT full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
--		Begin tran
			update
				tblCarAccessoriesStock
			set
				LastUpdateTime = getdate()
			from
				Inserted
			where
				tblCarAccessoriesStock.CASId=Inserted.CASId
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

-------- Insert Audit tblCarAccessories  ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessories_ForInsert
ON tblCarAccessories
FOR INSERT
AS
BEGIN 
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = CAId from inserted
			  insert into tblCarAccessoriesAudit 
			 values('New Car Accessories with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
-------- Delete Audit tblCarAccessories ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessories_ForDelete
ON tblCarAccessories
FOR DELETE
AS 
BEGIN
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = CAId from deleted 
			  insert into tblCarAccessoriesAudit 
			 values('An existing Car Accessories with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
-------- Update Audit tblCarAccessories ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessories_ForUpdate
ON tblCarAccessories
for Update
as
BEGIN
	BEGIN TRY  
--		Begin tran
			  -- Változók deklarálása a régi és frissített adatok
			  Declare @Id int -- nem változik
			  Declare @OldProductName nvarchar(50), @NewProductName nvarchar(50)
			  Declare @OldProductGroupId int, @NewProductGroupId int
			  Declare @OldNetSellingPrice float, @NewNetSellingPrice float
			  Declare @OldSalesUnit float, @NewSalesUnit float
			  Declare @OldUnit float, @NewUnit float
			  Declare @OldBrand nvarchar(50), @NewBrand nvarchar(50)
			  Declare @OldCreationDate datetime2, @NewCreationDate datetime2
			  Declare @OldDescription nvarchar(50), @NewDescription nvarchar(50)
			  Declare @OldVersion float, @NewVersion float
			  Declare @OldPhotoPath nvarchar(100), @NewPhotoPath nvarchar(100)
					-- Változó az audit karakterlánc
			  Declare @AuditString nvarchar(1000)
      
			  -- Töltse be a frissített rekordokat az ideiglenes táblába
			  -- ha valaki frissít egy adott sort, az új adatok a beszúrt
			  -- táblában lesznek ezeket tároljuk a #TempTable-ben
			  Select *
			  into #TempTable -- tedd be ezt a sort az ideiglenes táblába
			  from inserted
     
			  -- Hurok a temp tábla
			  -- mivel tetszőleges számú azonosítót adhatunk meg, így ha 
			  -- ennyi rekordok frissítünk egyszerre, akkor ciklust kell használni
			  -- mert frissíteni akarunk minden kiválasztott alkalmazottat
			  -- ezért tesszük az ideiglenes táblába
			  -- az ideiglenes táblából kiválasztjuk az azonosítókat, ha vannak
			  -- ha nincsenek, akkor nem ad vissza semmit az Exists() függvény 
			  -- false értéket ad vissza
			  While(Exists(Select CAId from #TempTable))
			  Begin
					--Inicializálja az audit karakterláncot az üres karakterlánchoz
					Set @AuditString = ''
           
					-- Válassza ki az első sor adatait a temp táblából
					-- mert ezt a sort a frissítési művelet befejezése után 
					-- köveztkező lépésben törölni fogom
					-- az új megváltoztatott adatokat tartalmazza
					Select Top 1 @Id = CAId, 
					  @OldProductName = ProductName,
					  @OldProductGroupId = ProductGroupId,
					  @OldNetSellingPrice = NetSellingPrice,
					  @OldSalesUnit = SalesUnit,
					  @OldUnit = Unit,
					  @OldBrand = Brand,
					  @OldCreationDate = CreationDate,
					  @OldDescription = [Description],
					  @OldVersion = [Version]
					from #TempTable
           
					-- Válassza ki a megfelelő sort a törölt táblázatból
					-- a régi eredeti adatokat tartalmazza
					Select 
					  @NewProductName = ProductName,
					  @NewProductGroupId = ProductGroupId,
					  @NewNetSellingPrice = NetSellingPrice,
					  @NewSalesUnit = SalesUnit,
					  @NewUnit = Unit,
					  @NewBrand = Brand,
					  @OldCreationDate = CreationDate,
					  @OldDescription = [Description],
					  @OldVersion = [Version]
					from deleted where CAId = @Id
   
					--  Az audit karakterlánc összeállítása dinamikusan
					-- régi és új adatok összehasonlítása, majd a karakterláncba fűzése
					Set @AuditString = 'Car Accessories with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'

					if(@OldProductName <> @NewProductName)
						  Set @AuditString = @AuditString + ' Product Name from ' + @OldProductName + ' to ' + @NewProductName
           
					if(@OldProductGroupId <> @NewProductGroupId)
						  Set @AuditString = @AuditString + ' Product Group Id from ' + Cast(@OldProductGroupId as nvarchar(10)) + 
						  ' to ' + Cast(@NewProductGroupId as nvarchar(10))
            
					if(@OldNetSellingPrice <> @NewNetSellingPrice)
						  Set @AuditString = @AuditString + ' Net Selling Price from ' + Cast(@OldNetSellingPrice as nvarchar(10)) + 
						  ' to ' + Cast(@NewNetSellingPrice as nvarchar(10))

					if(@OldSalesUnit <> @NewSalesUnit)
						  Set @AuditString = @AuditString + ' Sales Unit from ' + Cast(@OldSalesUnit as nvarchar(10)) + 
						  ' to ' + Cast(@NewSalesUnit as nvarchar(10))

					if(@OldUnit <> @NewUnit)
						  Set @AuditString = @AuditString + ' Unit from ' + Cast(@OldUnit as nvarchar(10)) + 
						  ' to ' + Cast(@NewUnit as nvarchar(10))

					if(@OldBrand <> @NewBrand)
						  Set @AuditString = @AuditString + ' Brand from ' + @OldBrand + ' to ' + @NewBrand
            
					if(@OldCreationDate <> @NewCreationDate)
						  Set @AuditString = @AuditString + ' Creation Date from ' + Cast(@OldCreationDate as nvarchar(10)) + 
						  ' to ' + Cast(@NewCreationDate as nvarchar(10))
				  
					if(@OldDescription <> @NewDescription)
						  Set @AuditString = @AuditString + ' Description from ' + @OldDescription + ' to ' + @NewDescription
            
					if(@OldVersion <> @NewVersion)
						  Set @AuditString = @AuditString + ' Version from ' + Cast(@OldVersion as nvarchar(10)) + 
						  ' to ' + Cast(@NewVersion as nvarchar(10))
				  
					if(@OldPhotoPath <> @NewPhotoPath)
						  Set @AuditString = @AuditString + ' PhotoPath from ' + @OldPhotoPath + ' to ' + @NewPhotoPath
           
					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
					-- ellenőrzés és karakterlánc fűzés után eltároljuk, a számozás automatikus
					insert into tblCarAccessoriesAudit values(@AuditString)
            
					-- Töröljük a sort a temp táblából
					Delete from #TempTable where CAId = @Id
			  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ Insert Audit tblCarAccessoriesStock  ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessoriesStock_ForInsert
ON tblCarAccessoriesStock
FOR INSERT
AS
BEGIN
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = CASId from inserted
			  insert into tblCarAccessoriesStockAudit 
			 values('New Car Accessories Stock with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Delete Audit tblCarAccessoriesStock ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessoriesStock_ForDelete
ON tblCarAccessoriesStock
FOR DELETE
AS
BEGIN
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = CASId from deleted 
			  insert into tblCarAccessoriesStockAudit 
			 values('An existing Car Accessories Stock with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Update Audit tblCarAccessoriesStock ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessoriesStock_ForUpdate
ON tblCarAccessoriesStock
for Update
as
BEGIN
	BEGIN TRY  
--		Begin tran
			  -- Változók deklarálása a régi és frissített adatok
			  Declare @Id int -- nem változik
			  Declare @OldQuantityOfStock int, @NewQuantityOfStock int
			  Declare @OldMinimumStockQuantity int, @NewMinimumStockQuantity int
			  -- Változó az audit karakterlánc
			  Declare @AuditString nvarchar(1000)
      
			  -- Töltse be a frissített rekordokat az ideiglenes táblába
			  -- ha valaki frissít egy adott sort, az új adatok a beszúrt
			  -- táblában lesznek ezeket tároljuk a #TempTable-ben
			  Select *
			  into #TempTable -- tedd be ezt a sort az ideiglenes táblába
			  from inserted
     
			  -- Hurok a temp tábla
			  -- mivel tetszőleges számú azonosítót adhatunk meg, így ha 
			  -- ennyi rekordok frissítünk egyszerre, akkor ciklust kell használni
			  -- mert frissíteni akarunk minden kiválasztott alkalmazottat
			  -- ezért tesszük az ideiglenes táblába
			  -- az ideiglenes táblából kiválasztjuk az azonosítókat, ha vannak
			  -- ha nincsenek, akkor nem ad vissza semmit az Exists() függvény 
			  -- false értéket ad vissza
			  While(Exists(Select CASId from #TempTable))
			  Begin
					--Inicializálja az audit karakterláncot az üres karakterlánchoz
					Set @AuditString = ''
           
					-- Válassza ki az első sor adatait a temp táblából
					-- mert ezt a sort a frissítési művelet befejezése után 
					-- köveztkező lépésben törölni fogom
					-- az új megváltoztatott adatokat tartalmazza
					Select Top 1 @Id = CASId, 
					  @OldQuantityOfStock = QuantityOfStock,
					  @OldMinimumStockQuantity = MinimumStockQuantity
					from #TempTable
           
					-- Válassza ki a megfelelő sort a törölt táblázatból
					-- a régi eredeti adatokat tartalmazza
					Select 
					  @NewQuantityOfStock = QuantityOfStock,
					  @NewMinimumStockQuantity = MinimumStockQuantity

					from deleted where CASId = @Id
   
					--  Az audit karakterlánc összeállítása dinamikusan
					-- régi és új adatok összehasonlítása, majd a karakterláncba fűzése
					Set @AuditString = 'Car Accessories Stock with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'

					if(@OldQuantityOfStock <> @NewQuantityOfStock)
						  Set @AuditString = @AuditString + ' Quantity Of Stock from ' + Cast(@OldQuantityOfStock as nvarchar(10)) + 
						  ' to ' + Cast(@NewQuantityOfStock as nvarchar(10))
            
					if(@OldMinimumStockQuantity <> @NewMinimumStockQuantity)
						  Set @AuditString = @AuditString + ' Minimum Stock Quantity from ' + Cast(@OldMinimumStockQuantity as nvarchar(10)) + 
						  ' to ' + Cast(@NewMinimumStockQuantity as nvarchar(10))
            
					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
					-- ellenőrzés és karakterlánc fűzés után eltároljuk, a számozás automatikus
					insert into tblCarAccessoriesStockAudit values(@AuditString)
            
					-- Töröljük a sort a temp táblából
					Delete from #TempTable where CASId = @Id
			  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ Insert Audit tblCarAccessoriesProductGroup  ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessoriesProductGroup_ForInsert
ON tblCarAccessoriesProductGroup
FOR INSERT
AS
BEGIN 
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = CAPGId from inserted
			  insert into tblCarAccessoriesProductGroupAudit 
			 values('New Car Accessories Product Group with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Delete Audit tblCarAccessoriesProductGroup ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessoriesProductGroup_ForDelete
ON tblCarAccessoriesProductGroup
FOR DELETE
AS
BEGIN
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = CAPGId from deleted 
			  insert into tblCarAccessoriesProductGroupAudit 
			 values('An existing Car Accessories Product Group with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Update Audit tblCarAccessoriesProductGroup ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessoriesProductGroup_ForUpdate
ON tblCarAccessoriesProductGroup
for Update
as
BEGIN
	BEGIN TRY  
--		Begin tran
			  -- Változók deklarálása a régi és frissített adatok
			  Declare @Id int -- nem változik
			  Declare @OldCAPGName nvarchar(50), @NewCAPGName nvarchar(50)
			  -- Változó az audit karakterlánc
			  Declare @AuditString nvarchar(1000)
      
			  -- Töltse be a frissített rekordokat az ideiglenes táblába
			  -- ha valaki frissít egy adott sort, az új adatok a beszúrt
			  -- táblában lesznek ezeket tároljuk a #TempTable-ben
			  Select *
			  into #TempTable -- tedd be ezt a sort az ideiglenes táblába
			  from inserted
     
			  -- Hurok a temp tábla
			  -- mivel tetszőleges számú azonosítót adhatunk meg, így ha 
			  -- ennyi rekordok frissítünk egyszerre, akkor ciklust kell használni
			  -- mert frissíteni akarunk minden kiválasztott alkalmazottat
			  -- ezért tesszük az ideiglenes táblába
			  -- az ideiglenes táblából kiválasztjuk az azonosítókat, ha vannak
			  -- ha nincsenek, akkor nem ad vissza semmit az Exists() függvény 
			  -- false értéket ad vissza
			  While(Exists(Select CAPGId from #TempTable))
			  Begin
					--Inicializálja az audit karakterláncot az üres karakterlánchoz
					Set @AuditString = ''
           
					-- Válassza ki az első sor adatait a temp táblából
					-- mert ezt a sort a frissítési művelet befejezése után 
					-- köveztkező lépésben törölni fogom
					-- az új megváltoztatott adatokat tartalmazza
					Select Top 1 @Id = CAPGId, 
					  @OldCAPGName = CAPGName
					from #TempTable
           
					-- Válassza ki a megfelelő sort a törölt táblázatból
					-- a régi eredeti adatokat tartalmazza
					Select 
					  @NewCAPGName = CAPGName

					from deleted where CAPGId = @Id
   
					--  Az audit karakterlánc összeállítása dinamikusan
					-- régi és új adatok összehasonlítása, majd a karakterláncba fűzése
					Set @AuditString = 'Car Accessories Product Group with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'

					if(@OldCAPGName <> @NewCAPGName)
						  Set @AuditString = @AuditString + ' Car Accessories Product Group Name from ' + 
						  @OldCAPGName + ' to ' + @NewCAPGName
            
					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
					-- ellenőrzés és karakterlánc fűzés után eltároljuk, a számozás automatikus
					insert into tblCarAccessoriesProductGroupAudit values(@AuditString)
            
					-- Töröljük a sort a temp táblából
					Delete from #TempTable where CAPGId = @Id
			  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ Insert Audit tblCarAccessoriesUnitAudit ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessoriesUnit_ForInsert
ON tblCarAccessoriesUnit
FOR INSERT
AS
BEGIN
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = CAUId from inserted
			  insert into tblCarAccessoriesUnitAudit 
			 values('New Car Accessories Unit with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Delete Audit tblCarAccessoriesUnitAudit  ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessoriesUnit_ForDelete
ON tblCarAccessoriesUnit
FOR DELETE
AS
BEGIN
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = CAUId from inserted
			  insert into tblCarAccessoriesUnitAudit 
			 values('An existing Car Accessories Unit with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Update Audit tblCarAccessoriesUnitAudit  ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblCarAccessoriesUnit_ForUpdate
ON tblCarAccessoriesUnit
for Update
as
BEGIN
	BEGIN TRY  
--		Begin tran
			-- Változók deklarálása a régi és frissített adatok
			Declare @Id int -- nem változik
			Declare @OldUnitName nvarchar(50), @NewUnitName nvarchar(50)
			-- Változó az audit karakterlánc
			Declare @AuditString nvarchar(1000)
      
			-- Töltse be a frissített rekordokat az ideiglenes táblába
			-- ha valaki frissít egy adott sort, az új adatok a beszúrt
			-- táblában lesznek ezeket tároljuk a #TempTable-ben
			Select *
			into #TempTable -- tedd be ezt a sort az ideiglenes táblába
			from inserted
     
			-- Hurok a temp tábla
			-- mivel tetszőleges számú azonosítót adhatunk meg, így ha 
			-- ennyi rekordok frissítünk egyszerre, akkor ciklust kell használni
			-- mert frissíteni akarunk minden kiválasztott alkalmazottat
			-- ezért tesszük az ideiglenes táblába
			-- az ideiglenes táblából kiválasztjuk az azonosítókat, ha vannak
			-- ha nincsenek, akkor nem ad vissza semmit az Exists() függvény 
			-- false értéket ad vissza
			While(Exists(Select CAUId from #TempTable))
			Begin
				--Inicializálja az audit karakterláncot az üres karakterlánchoz
				Set @AuditString = ''
           
				-- Válassza ki az első sor adatait a temp táblából
				-- mert ezt a sort a frissítési művelet befejezése után 
				-- köveztkező lépésben törölni fogom
				-- az új megváltoztatott adatokat tartalmazza
				Select Top 1 @Id = CAUId, 
					@OldUnitName = UnitName
				from #TempTable
           
				-- Válassza ki a megfelelő sort a törölt táblázatból
				-- a régi eredeti adatokat tartalmazza
				Select 
					@NewUnitName = UnitName

				from deleted where CAUId = @Id
   
				--  Az audit karakterlánc összeállítása dinamikusan
				-- régi és új adatok összehasonlítása, majd a karakterláncba fűzése
				Set @AuditString = 'Car Accessories Unit with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'

				if(@OldUnitName <> @NewUnitName)
						Set @AuditString = @AuditString + ' Car Accessories Unit Name from ' + 
						@OldUnitName + ' to ' + @NewUnitName
            
				Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
				-- ellenőrzés és karakterlánc fűzés után eltároljuk, a számozás automatikus
				insert into tblCarAccessoriesUnitAudit values(@AuditString)
            
				-- Töröljük a sort a temp táblából
				Delete from #TempTable where CAUId = @Id
			End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go


----- View, update, delete, insert Triggers --------------------------------------------------
Create or Alter View vWCarAccessoriesAllData
as
Select CAId as CarAccessoriesId, ProductName, tblCarAccessoriesProductGroup.CAPGName as ProductGroup, 
tblCarAccessoriesStock.QuantityOfStock, tblCarAccessoriesStock.MinimumStockQuantity, NetSellingPrice, SalesUnit,
(NetSellingPrice/SalesUnit) as UnitPrice, tblCarAccessoriesUnit.UnitName,
tblCarAccessoriesStock.LastUpdateTime, Brand, CreationDate, [Description], [Version], PhotoPath
From			tblCarAccessories
JOIN			tblCarAccessoriesProductGroup
on				tblCarAccessories.ProductGroupId = tblCarAccessoriesProductGroup.CAPGId
JOIN			tblCarAccessoriesStock
ON				tblCarAccessories.CAId = tblCarAccessoriesStock.CASId
JOIN			tblCarAccessoriesUnit
ON				tblCarAccessories.Unit = tblCarAccessoriesUnit.CAUId
go
------------------------ Insert -------------------------------------------------------------
CREATE or Alter Trigger tr_vWCarAccessoriesDetails_InsteadOfInsert
on vWCarAccessoriesAllData
Instead Of Insert
as
BEGIN
	BEGIN TRY  
	  -- SNAPSHOT full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--	    Begin tran
			Declare @CAPGId int
			Select @CAPGId = CAPGId
			from tblCarAccessoriesProductGroup 
			join inserted
			on inserted.ProductGroup = tblCarAccessoriesProductGroup.CAPGName
			if(@CAPGId is null)
				Begin
				Raiserror('Invalid Car Accessories Product Group Name. Statement terminated', 16, 1)
				return 
			End
			-- 
			Declare @CAUId int
			Select @CAUId = CAUId
			from tblCarAccessoriesUnit 
			join inserted
			on inserted.UnitName = tblCarAccessoriesUnit.UnitName
			if(@CAUId is null)
				Begin
				Raiserror('Invalid Car Accessories Unit Name. Statement terminated', 16, 1)
				return
			End

			SET IDENTITY_INSERT dbo.tblCarAccessories ON

			Insert into tblCarAccessories(CAId, ProductName, ProductGroupId, NetSellingPrice, SalesUnit, Unit, Brand, CreationDate, [Description], [Version], PhotoPath)
			Select CarAccessoriesId, ProductName, @CAPGId, NetSellingPrice, SalesUnit, @CAUId, Brand, CreationDate, [Description], [Version], PhotoPath
			from inserted

			Insert into tblCarAccessoriesStock(CASId, QuantityOfStock, MinimumStockQuantity)
			Select CarAccessoriesId, QuantityOfStock, MinimumStockQuantity
			from inserted

			SET IDENTITY_INSERT dbo.tblCarAccessories OFF
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
-------------------------- DELETE -------------------------------------------------------------
CREATE or Alter Trigger tr_vWCarAccessoriesDetails_InsteadOfDelete
on vWCarAccessoriesAllData
Instead Of DELETE
as
BEGIN 
	BEGIN TRY  
	  -- SNAPSHOT full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--	    Begin tran
			Delete tblCarAccessories 
			from tblCarAccessories
			join deleted
			on tblCarAccessories.CAId = deleted.CarAccessoriesId

			Delete tblCarAccessoriesStock 
			from tblCarAccessoriesStock
			join deleted
			on tblCarAccessoriesStock.CASId = deleted.CarAccessoriesId
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
-------------------------- Update -------------------------------------------------------------
Create Or Alter Trigger tr_vWCarAccessoriesDetails_InsteadOfUpdate
on vWCarAccessoriesAllData
instead of update
as
BEGIN 
	BEGIN TRY  
	  -- SNAPSHOT full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--	    Begin tran
			-- if SalesId is updated
			if(Update(CarAccessoriesId))
			Begin
				Raiserror('Id cannot be changed', 16, 1)
				Return
			End
		 -- táblázaton belül ---------------------------------------------------
			if(Update(ProductName))
			Begin
				Update tblCarAccessories set ProductName = inserted.ProductName
				from inserted
				join tblCarAccessories
				on tblCarAccessories.CAId = inserted.CarAccessoriesId
			End
	
			if(Update(ProductGroup)) 
			Begin
				Declare @CAPGId int

				Select @CAPGId = CAPGId
				from tblCarAccessoriesProductGroup
				join inserted
				on inserted.ProductGroup = tblCarAccessoriesProductGroup.CAPGName
  
				if(@CAPGId is NULL )
				Begin
					Raiserror('Invalid Product Group Name', 16, 1)
					Return
				End
  
				Update tblCarAccessories set ProductGroupId = @CAPGId
				from inserted
				join tblCarAccessories
				on tblCarAccessories.CAId = inserted.CarAccessoriesId
			End
	
			if(Update(QuantityOfStock))
			Begin
				Update tblCarAccessoriesStock set QuantityOfStock = inserted.QuantityOfStock
				from inserted
				join tblCarAccessoriesStock
				on tblCarAccessoriesStock.CASId = inserted.CarAccessoriesId
			End

			if(Update(MinimumStockQuantity))
			Begin
				Update tblCarAccessoriesStock set MinimumStockQuantity = inserted.MinimumStockQuantity
				from inserted
				join tblCarAccessoriesStock
				on tblCarAccessoriesStock.CASId = inserted.CarAccessoriesId
			End

			if(Update(NetSellingPrice))
			Begin
				Update tblCarAccessories set NetSellingPrice = inserted.NetSellingPrice
				from inserted
				join tblCarAccessories
				on tblCarAccessories.CAId = inserted.CarAccessoriesId
			End

			if(Update(SalesUnit))
			Begin
				Update tblCarAccessories set SalesUnit = inserted.SalesUnit
				from inserted
				join tblCarAccessories
				on tblCarAccessories.CAId = inserted.CarAccessoriesId
			End

			if(Update(UnitName)) 
			Begin
				Declare @CAUId int

				Select @CAUId = CAUId
				from tblCarAccessoriesUnit
				join inserted
				on inserted.UnitName = tblCarAccessoriesUnit.UnitName
  
				if(@CAUId is NULL )
				Begin
					Raiserror('Invalid Unit Name', 16, 1)
					Return
				End
  
				Update tblCarAccessories set Unit = @CAUId
				from inserted
				join tblCarAccessories
				on tblCarAccessories.CAId = inserted.CarAccessoriesId
			End

			if(Update(Brand))
			Begin
				Update tblCarAccessories set Brand = inserted.Brand
				from inserted
				join tblCarAccessories
				on tblCarAccessories.CAId = inserted.CarAccessoriesId
			End
	
			if(Update(CreationDate))
			Begin
				Update tblCarAccessories set CreationDate = inserted.CreationDate
				from inserted
				join tblCarAccessories
				on tblCarAccessories.CAId = inserted.CarAccessoriesId
			End

			if(Update([Description]))
			Begin
				Update tblCarAccessories set [Description] = inserted.[Description]
				from inserted
				join tblCarAccessories
				on tblCarAccessories.CAId = inserted.CarAccessoriesId
			End
			
			if(Update([Version]))
			Begin
				Update tblCarAccessories set [Version] = inserted.[Version]
				from inserted
				join tblCarAccessories
				on tblCarAccessories.CAId = inserted.CarAccessoriesId
			End

			if(Update(PhotoPath))
			Begin
				Update tblCarAccessories set PhotoPath = inserted.PhotoPath
				from inserted
				join tblCarAccessories
				on tblCarAccessories.CAId = inserted.CarAccessoriesId
			End

			
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go


------- Stored Procedure ------------------------------------------------------------------------
go
------ CarAccessories SEARCH ------------------------------------------------------------------------------
Create or alter Procedure spCarAccessoriesSearchDynamicSQL
@CAId int = NULL,
@ProductName nvarchar(50) = NULL,
@CAPGName nvarchar(50) = NULL,
@QuantityOfStock int = NULL,
@MinimumStockQuantity int = NULL,
@NetSellingPrice float = NULL,
@SalesUnit float = NULL,
@UnitPrice float = NULL,
@UnitName nvarchar(50) = NULL,
@LastUpdateTime datetime2 = NULL,
@Brand nvarchar(50) = NULL,
@CreationDate datetime2 = NULL,
@Description nvarchar(max) = NULL,
@Version float = NULL,
@PhotoPath nvarchar(100) = NULL
As
BEGIN
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)

				Set @sql = 'Select CAId, ProductName, tblCarAccessoriesProductGroup.CAPGName as ProductGroup, 
							tblCarAccessoriesStock.QuantityOfStock, tblCarAccessoriesStock.MinimumStockQuantity, NetSellingPrice, SalesUnit,
							(NetSellingPrice/SalesUnit) as UnitPrice, tblCarAccessoriesUnit.UnitName,
							tblCarAccessoriesStock.LastUpdateTime, Brand, CreationDate, [Description], [Version], PhotoPath
							From			tblCarAccessories
							JOIN			tblCarAccessoriesProductGroup
							on				tblCarAccessories.ProductGroupId = tblCarAccessoriesProductGroup.CAPGId
							JOIN			tblCarAccessoriesStock
							ON				tblCarAccessories.CAId = tblCarAccessoriesStock.CASId
							JOIN			tblCarAccessoriesUnit
							ON				tblCarAccessories.Unit = tblCarAccessoriesUnit.CAUId
							where 1 = 1'
     
			 if(@CAId is not null)
				  Set @sql = @sql + ' and CAId=@CAI'
			 if(@ProductName is not null)
				  Set @sql = @sql + ' and ProductName like(@PN + @PS)'
			 if(@CAPGName is not null)
				  Set @sql = @sql + ' and CAPGName like(@CAPGN + @PS)'
			 if(@QuantityOfStock is not null)
				  Set @sql = @sql + ' and QuantityOfStock=@QOS'
			 if(@MinimumStockQuantity is not null)
				  Set @sql = @sql + ' and MinimumStockQuantity=@MSQ'
			 if(@NetSellingPrice is not null)
				  Set @sql = @sql + ' and NetSellingPrice=@NSP'
			 if(@SalesUnit is not null)
				  Set @sql = @sql + ' and SalesUnit=@SU'
			 if(@UnitPrice is not null)
				  Set @sql = @sql + ' and (NetSellingPrice/SalesUnit)=@UP'		  
			 if(@UnitName is not null)
				  Set @sql = @sql + ' and UnitName like(@UN+@PS)'
			 if(@LastUpdateTime is not null)
				  Set @sql = @sql + ' and LastUpdateTime=@LUT'
			 if(@Brand is not null)
				  Set @sql = @sql + ' and Brand like(@Br + @PS)'
			 if(@CreationDate is not null)
				  Set @sql = @sql + ' and CreationDate=@CD'
			 if(@Description is not null)
				  Set @sql = @sql + ' and Description like(@PS + @De + @PS)'
			 if(@Version is not null)
				  Set @sql = @sql + ' and Version=@Ve'

			 Execute sp_executesql @sql,
			 N'@CAI int, @PN nvarchar(50), @CAPGN nvarchar(50), @QOS int, @MSQ int, @NSP float, @SU float, @UP float, @UN nvarchar(50), 
			 @LUT datetime2, @Br nvarchar(50), @CD datetime2, @De nvarchar(max), @Ve float, @PS nvarchar(1)',
			 @CAI=@CAId, @PN=@ProductName, @CAPGN=@CAPGName, @QOS=@QuantityOfStock, @MSQ=@MinimumStockQuantity, @NSP=@NetSellingPrice, @SU=@SalesUnit,
			 @UP=@UnitPrice, @UN=@UnitName, @LUT=@LastUpdateTime, @Br=@Brand, @CD=@CreationDate,
			 @De=@Description, @Ve=@Version, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ CarAccessories Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spCarAccessoriesUpdateOrInsert
@CarAccessoriesId int = NULL,
@ProductName nvarchar(50) = NULL,
@CAPGName nvarchar(50) = NULL,
@QuantityOfStock int = NULL,
@MinimumStockQuantity int = NULL,
@NetSellingPrice float = NULL,
@SalesUnit float = NULL,
@UnitPrice float = NULL,
@UnitName nvarchar(50) = NULL,
@LastUpdateTime datetime2 = NULL,
@Brand nvarchar(50) = NULL,
@CreationDate datetime2 = NULL,
@Description nvarchar(max) = NULL,
@Version float = NULL,
@PhotoPath nvarchar(100) = NULL
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (exists (select * from vWCarAccessoriesAllData with (updlock,serializable) where CarAccessoriesId = @CarAccessoriesId))
			begin
			   update vWCarAccessoriesAllData set ProductName = @ProductName, ProductGroup = @CAPGName, 
					QuantityOfStock = @QuantityOfStock, MinimumStockQuantity = @MinimumStockQuantity, NetSellingPrice = @NetSellingPrice, SalesUnit = @SalesUnit, 
					UnitPrice = @UnitPrice, UnitName = @UnitName, LastUpdateTime = @LastUpdateTime, Brand = @Brand, 
					CreationDate = @CreationDate, Description = @Description, Version = @Version, PhotoPath = @PhotoPath
			   where CarAccessoriesId = @CarAccessoriesId
			end
			else
			begin
				if(@CarAccessoriesId is not Null)
				begin
					insert into vWCarAccessoriesAllData  values (@CarAccessoriesId , @ProductName, @CAPGName, 
					@QuantityOfStock, @MinimumStockQuantity, @NetSellingPrice, @SalesUnit, @UnitPrice, @UnitName, @LastUpdateTime, 
					@Brand, @CreationDate, @Description, @Version, @PhotoPath)
				end
				else
				begin
					insert into vWCarAccessoriesAllData  values (IDENT_CURRENT('tblCarAccessories')+1 , @ProductName, 
					@CAPGName, @QuantityOfStock, @MinimumStockQuantity, @NetSellingPrice, @SalesUnit, @UnitPrice, @UnitName, @LastUpdateTime, 
					@Brand, @CreationDate, @Description, @Version, @PhotoPath)
				end
			end
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ CarAccessories Delete ---------------------------------------------------------------------
Create or alter Procedure spCarAccessoriesDelete
@CarAccessoriesId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@CarAccessoriesId is not Null)
			begin
				Delete from [dbo].[vWCarAccessoriesAllData] where CarAccessoriesId = @CarAccessoriesId
			end
			else
			begin
				Print 'CarAccessoriesId is not found ' + @CarAccessoriesId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ CarAccessoriesProductGroup SEARCH ---------------------------------------------------------------------
Create or alter Procedure spCarAccessoriesProductGroupSearchDynamicSQL
@CAPGId int = NULL,
@CAPGName nvarchar(50) = NULL
As
BEGIN 
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)

			 Set @sql = 'Select CAPGId, CAPGName 
						from tblCarAccessoriesProductGroup 
						where 1 = 1'
    
			 if(@CAPGId is not null)
				  Set @sql = @sql + ' and CAPGId=@CAPGI'
			 if(@CAPGName is not null)
				  Set @sql = @sql + ' and CAPGName like(@CAPGN + @PS)'
     
			 Execute sp_executesql @sql,
			 N'@CAPGI int, @CAPGN nvarchar(50), @PS nvarchar(1)',
			 @CAPGI=@CAPGId, @CAPGN=@CAPGName, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ CarAccessoriesProductGroup Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spCarAccessoriesProductGroupUpdateOrInsert
@CAPGId int = NULL,
@CAPGName nvarchar(50) = NULL
AS
BEGIN 
	BEGIN TRY   
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (exists (select * from tblCarAccessoriesProductGroup with (updlock,serializable) where CAPGId = @CAPGId))
			begin
			   update tblCarAccessoriesProductGroup set CAPGName = @CAPGName
			   where CAPGId = @CAPGId
			end
			else
			begin
				if(@CAPGId is not Null)
				begin
					SET IDENTITY_INSERT dbo.tblCarAccessoriesProductGroup ON
					insert into tblCarAccessoriesProductGroup (CAPGId, CAPGName) values (@CAPGId , @CAPGName)
					SET IDENTITY_INSERT dbo.tblCarAccessoriesProductGroup OFF
				end
				else
				begin
					SET IDENTITY_INSERT dbo.tblCarAccessoriesProductGroup ON
					insert into tblCarAccessoriesProductGroup (CAPGId, CAPGName) values (IDENT_CURRENT('tblCarAccessoriesProductGroup')+1 , @CAPGName)
					SET IDENTITY_INSERT dbo.tblCarAccessoriesProductGroup OFF
				end
			end
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ CarAccessoriesProductGroup Delete ---------------------------------------------------------------------
Create or alter Procedure spCarAccessoriesProductGroupDelete
@CAPGId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@CAPGId is not Null)
			begin
				Delete from [dbo].[tblCarAccessoriesProductGroup] where CAPGId = @CAPGId
			end
			else
			begin
				Print 'CarAccessoriesProductGroupId is not found ' + @CAPGId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ Car Accessories Unit SEARCH ---------------------------------------------------------------------
Create or alter Procedure spCarAccessoriesUnitSearchDynamicSQL
@CAUId int = NULL,
@UnitName nvarchar(50) = NULL
As
BEGIN
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)

			 Set @sql = 'Select CAUId, UnitName 
						from tblCarAccessoriesUnit 
						where 1 = 1'
    
			 if(@CAUId is not null)
				  Set @sql = @sql + ' and CAUId=@CAUI'
			 if(@UnitName is not null)
				  Set @sql = @sql + ' and UnitName like(@UN + @PS)'
     
			 Execute sp_executesql @sql,
			 N'@CAUI int, @UN nvarchar(50), @PS nvarchar(1)',
			 @CAUI=@CAUId, @UN=@UnitName, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Car Accessories Unit Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spCarAccessoriesUnitUpdateOrInsert
@CAUId int = NULL,
@UnitName nvarchar(50) = NULL
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (exists (select * from tblCarAccessoriesUnit with (updlock,serializable) where CAUId = @CAUId))
			begin
			   update tblCarAccessoriesUnit set UnitName = @UnitName
			   where CAUId = @CAUId
			end
			else
			begin
				if(@CAUId is not Null)
				begin
					SET IDENTITY_INSERT dbo.tblCarAccessoriesUnit ON
					insert into tblCarAccessoriesUnit (CAUId, UnitName) values (@CAUId , @UnitName)
					SET IDENTITY_INSERT dbo.tblCarAccessoriesUnit OFF
				end
				else
				begin
					SET IDENTITY_INSERT dbo.tblCarAccessoriesUnit ON
					insert into tblCarAccessoriesUnit (CAUId, UnitName) values (IDENT_CURRENT('tblCarAccessoriesUnit')+1 , @UnitName)
					SET IDENTITY_INSERT dbo.tblCarAccessoriesUnit OFF
				end
			end
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go
------ Car Accessories Unit Delete ---------------------------------------------------------------------
Create or alter Procedure spCarAccessoriesUnitDelete
@CAUId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@CAUId is not Null)
			begin
				Delete from [dbo].[tblCarAccessoriesUnit] where CAUId = @CAUId
			end
			else
			begin
				Print 'CarAccessoriesUnitGroupId is not found ' + @CAUId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go








------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------- tblShoppingCart ------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
go
-- the order table must be created before the shopping cart view
-- die Bestelltabelle muss vor der Warenkorbansicht erstellt werden
-- a rendelési táblázatot létre kell hozni a még a bevásárlókosár nézete előtt
go
Create Table tblOrderStatus
	(
		OrderStatusId INT IDENTITY (1, 1) PRIMARY KEY,
		OrderStatusName nvarchar(50)
	)
go

-------- Insert Audit tblOrderStatus ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblOrderStatus_ForInsert
ON tblOrderStatus
FOR INSERT
AS
Begin
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = OrderStatusId from inserted
			  insert into tblOrderStatusAudit 
			 values('New Order Status with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------- Delete Audit tblOrderStatus ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblOrderStatus_ForDelete
ON tblOrderStatus
FOR DELETE
AS
Begin
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = OrderStatusId from deleted 
			  insert into tblOrderStatusAudit 
			 values('An existing Order Status with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------- Update Audit tblOrderStatus ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblOrderStatus_ForUpdate
ON tblOrderStatus
for Update
as
Begin
	BEGIN TRY  
--		Begin tran
			  Declare @Id int 
			  Declare @OldOrderStatusName nvarchar(50), @NewOrderStatusName nvarchar(50)

			  Declare @AuditString nvarchar(1000)
      
			  Select *
			  into #TempTable 
			  from inserted
     
			  While(Exists(Select OrderStatusId from #TempTable))
			  Begin
					Set @AuditString = ''
					Select Top 1 @Id = OrderStatusId, 
						@OldOrderStatusName = OrderStatusName
					from #TempTable
					Select 
						@NewOrderStatusName = OrderStatusName

					from deleted where OrderStatusId = @Id
					Set @AuditString = 'Order Status with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'
			
					if(@OldOrderStatusName <> @NewOrderStatusName)
						  Set @AuditString = @AuditString + ' Order Status Name from ' + 
						  @OldOrderStatusName + ' to ' + @NewOrderStatusName
            
					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
					insert into tblOrderStatusAudit values(@AuditString)
            
					Delete from #TempTable where OrderStatusId = @Id
			  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go


Create Table tblShoppingCartStatus
	(
		ShoppingCartStatusId INT IDENTITY (1, 1) PRIMARY KEY,
		ShoppingCartStatusName nvarchar(50)
	)
go

---- Audit tblShoppingCartStatusAudit ----------------------------------------------------------------
CREATE TABLE tblShoppingCartStatusAudit
(
  ShoppingCartStatusAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go

-------- Insert Audit tblShoppingCartStatus ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblShoppingCartStatus_ForInsert
ON tblShoppingCartStatus
FOR INSERT
AS
Begin
	BEGIN TRY  
			 Declare @Id int
			 Select @Id = ShoppingCartStatusId from inserted
			  insert into tblShoppingCartStatusAudit 
			 values('New Shopping Cart Status with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------- Delete Audit tblShoppingCartStatus ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblShoppingCartStatus_ForDelete
ON tblShoppingCartStatus
FOR DELETE
AS
Begin
	BEGIN TRY  
			 Declare @Id int
			 Select @Id = ShoppingCartStatusId from deleted 
			  insert into tblShoppingCartStatusAudit 
			 values('An existing Shopping Cart Status with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------- Update Audit tblShoppingCartStatus ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblShoppingCartStatus_ForUpdate
ON tblShoppingCartStatus
for Update
as
Begin
	BEGIN TRY  
			  Declare @Id int 
			  Declare @OldShoppingCartStatusName nvarchar(50), @NewShoppingCartStatusName nvarchar(50)

			  Declare @AuditString nvarchar(1000)
      
			  Select *
			  into #TempTable 
			  from inserted
     
			  While(Exists(Select ShoppingCartStatusId from #TempTable))
			  Begin
					Set @AuditString = ''
					Select Top 1 @Id = ShoppingCartStatusId, 
						@OldShoppingCartStatusName = ShoppingCartStatusName
					from #TempTable
					Select 
						@NewShoppingCartStatusName = ShoppingCartStatusName

					from deleted where ShoppingCartStatusId = @Id
					Set @AuditString = 'Shopping Cart Status with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'
			
					if(@OldShoppingCartStatusName <> @NewShoppingCartStatusName)
						  Set @AuditString = @AuditString + ' Shopping Cart Status Name from ' + 
						  @OldShoppingCartStatusName + ' to ' + @NewShoppingCartStatusName
            
					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
					insert into tblShoppingCartStatusAudit values(@AuditString)
            
					Delete from #TempTable where ShoppingCartStatusId = @Id
			  End
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

Create Table tblShoppingCart
	(
		ShoppingCartOrderId INT IDENTITY (0, 1) PRIMARY KEY,
		UserId INT,
		CustomerId INT,
		SalesPersonId INT,
		ProductId INT,
		Quantity INT,
		OrderStatusId INT , 
		Discount FLOAT,
		SaleAmount FLOAT,
		ShoppingCartStatusId int foreign key references tblShoppingCartStatus(ShoppingCartStatusId),
	)
go

---- ShoppingCart Setting SaleAmount ------------------------------------------------------------------
CREATE OR ALTER Trigger tr_tblShoppingCart_Setting_SaleAmount
on tblShoppingCart for insert, update
as 
Begin
	BEGIN TRY  
			Declare @ProductId int
			Select @ProductId = ProductId
			from inserted
			if(@ProductId < 1000000)
			Begin
				update tblShoppingCart 
				set SaleAmount = 
					(select NetSellingPrice 
					from	tblCarAccessories
					where	tblCarAccessories.CAId = @ProductId) 
				from Inserted 
				where tblShoppingCart.ShoppingCartOrderId=Inserted.ShoppingCartOrderId
			End
			else
			Begin
				update tblShoppingCart 
				set SaleAmount = 
					(select NettoPrice 
					from	tblCars
					where	tblCars.CarId = @ProductId) 
				from Inserted 
				where tblShoppingCart.ShoppingCartOrderId=Inserted.ShoppingCartOrderId
			End
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

---- ShoppingCart Setting CustomerId And SalesPersonId from UserId if customer then SalesPersonId = 0 -------------------------------------------------------------------
CREATE OR ALTER Trigger tr_tblShoppingCart_Setting_CustomerId_And_SalesPersonId
on tblShoppingCart for insert
as 
Begin
	BEGIN TRY  
			Declare @UserId int
			Select @UserId = UserId
			from inserted
			if(@UserId < 1000)
			Begin
				update tblShoppingCart 
				set SalesPersonId = @UserId
				from Inserted 
				where tblShoppingCart.ShoppingCartOrderId=Inserted.ShoppingCartOrderId
			End
			else
			Begin
				update tblShoppingCart 
				set CustomerId = @UserId, SalesPersonId = 0
				from Inserted 
				where tblShoppingCart.ShoppingCartOrderId=Inserted.ShoppingCartOrderId
			End
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go



---- Audit tblShoppingCart ----------------------------------------------------------------
CREATE TABLE tblShoppingCartAudit
(
  ShoppingCartAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go

-------- Insert Audit tblShoppingCart ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblShoppingCart_ForInsert
ON tblShoppingCart
FOR INSERT
AS
Begin
	BEGIN TRY  
			 Declare @Id int
			 Select @Id = ShoppingCartOrderId from inserted
			  insert into tblShoppingCartAudit 
			 values('New Shopping Cart Item with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())	 
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------- Delete Audit tblShoppingCart ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblShoppingCart_ForDelete
ON tblShoppingCart
FOR DELETE
AS
Begin
	BEGIN TRY  
			 Declare @Id int
			 Select @Id = ShoppingCartOrderId from deleted 
			  insert into tblShoppingCartAudit 
			 values('An existing Shopping Cart Item with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------- Update Audit tblShoppingCart ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblShoppingCart_ForUpdate
ON tblShoppingCart
for Update
as
Begin
	BEGIN TRY  
			  Declare @Id int 
			  Declare @OldUserId int, @NewUserId int
			  Declare @OldCustomerId int, @NewCustomerId int
			  Declare @OldSalesPersonId int, @NewSalesPersonId int
			  Declare @OldProductId int, @NewProductId int
			  Declare @OldQuantity int, @NewQuantity int
			  Declare @OldOrderStatusId int, @NewOrderStatusId int
			  Declare @OldDiscount float, @NewDiscount float
			  Declare @OldSaleAmount float, @NewSaleAmount float
			  Declare @OldShoppingCartStatusId int, @NewShoppingCartStatusId int

			  Declare @AuditString nvarchar(1000)
      
			  Select *
			  into #TempTable 
			  from inserted
     
			  While(Exists(Select ShoppingCartOrderId from #TempTable))
			  Begin
					Set @AuditString = ''
					Select Top 1 @Id = ShoppingCartOrderId, 
						@OldCustomerId  = CustomerId,
						@OldSalesPersonId = SalesPersonId,
						@OldProductId = ProductId,
						@OldQuantity = Quantity,
						@OldOrderStatusId = OrderStatusId,
						@OldDiscount = Discount,
						@OldSaleAmount = SaleAmount,
						@OldShoppingCartStatusId = ShoppingCartStatusId

					from #TempTable
					Select 
						@NewCustomerId = CustomerId,
						@NewSalesPersonId = SalesPersonId,
						@NewProductId = ProductId,
						@NewQuantity = Quantity,
						@NewOrderStatusId = OrderStatusId,
						@NewDiscount = Discount,
						@NewSaleAmount = SaleAmount,
						@NewShoppingCartStatusId = ShoppingCartStatusId

					from deleted where ShoppingCartOrderId = @Id
					Set @AuditString = 'Shopping Cart Item with Id = ' + Cast(@Id as nvarchar(10)) + ' changed'

					if(@OldCustomerId <> @NewCustomerId)
						  Set @AuditString = @AuditString + ' Customer Id from ' + Cast(@OldCustomerId as nvarchar(10)) + 
						  ' to ' + Cast(@NewCustomerId as nvarchar(10))
            
					if(@OldSalesPersonId <> @NewSalesPersonId)
						  Set @AuditString = @AuditString + ' Sales Person Id from ' + Cast(@OldSalesPersonId as nvarchar(4)) + 
						  ' to ' + Cast(@NewSalesPersonId as nvarchar(4))

					if(@OldProductId <> @NewProductId)
						  Set @AuditString = @AuditString + ' Product Id from ' + Cast(@OldProductId as nvarchar(10)) + 
						  ' to ' + Cast(@NewProductId as nvarchar(10))
				  
					if(@OldQuantity <> @NewQuantity)
						  Set @AuditString = @AuditString + ' Quantity from ' + Cast(@OldQuantity as nvarchar(10)) + 
						  ' to ' + Cast(@NewQuantity as nvarchar(10))

					if(@OldOrderStatusId <> @NewOrderStatusId)
						  Set @AuditString = @AuditString + ' Order Status Id from ' + Cast(@OldOrderStatusId as nvarchar(2)) + 
						  ' to ' + Cast(@NewOrderStatusId as nvarchar(2))
				  
					if(@OldDiscount <> @NewDiscount)
						  Set @AuditString = @AuditString + ' Discount from ' + Cast(@OldDiscount as nvarchar(10)) + 
						  ' to ' + Cast(@NewDiscount as nvarchar(10))
				  
					if(@OldSaleAmount <> @NewSaleAmount)
						  Set @AuditString = @AuditString + ' Sale Amount from ' + Cast(@OldSaleAmount as nvarchar(10)) + 
						  ' to ' + Cast(@NewSaleAmount as nvarchar(10))
				  
					if(@OldShoppingCartStatusId <> @NewShoppingCartStatusId)
						  Set @AuditString = @AuditString + ' Shopping Cart Status Id from ' + Cast(@OldShoppingCartStatusId as nvarchar(10)) + 
						  ' to ' + Cast(@NewShoppingCartStatusId as nvarchar(10))
				  
					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
					insert into tblShoppingCartAudit values(@AuditString)
            
					Delete from #TempTable where ShoppingCartOrderId = @Id
			  End
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go


Create or Alter View vWShoppingCartAllData
as
Select ShoppingCartOrderId, UserId, tblShoppingCart.CustomerId, tblCustomer.FirstName as CustomerFirstName, tblCustomer.LastName as CustomerLastName, 
tblShoppingCart.SalesPersonId, tblSalespersons.FirstName as SalesPersonFirstName, tblSalespersons.LastName as SalesPersonLastName, 
ProductId, ISNULL(tblCarAccessoriesProductGroup.CAPGName, 'Autoverkauf') as ProductGroup, 
ISNULL(tblCarAccessories.ProductName, 'Auto') as ProductName,
ISNULL(tblCars.Model, 'Verkauf von Autozubehör') as CarModel, ISNULL(tblCars.Color, 'Autozubehör') as CarColor,
Quantity, tblCountry.CountryTaxPercentageValue, Discount, SaleAmount, tblShoppingCart.OrderStatusId, OrderStatusName, 
tblShoppingCart.ShoppingCartStatusId, tblShoppingCartStatus.ShoppingCartStatusName
FROM		tblShoppingCart
LEFT JOIN	tblOrderStatus
ON			tblShoppingCart.OrderStatusId = tblOrderStatus.OrderStatusId
LEFT JOIN	tblSalespersons
ON			tblShoppingCart.SalesPersonId = tblSalespersons.SalesId
LEFT JOIN	tblCustomer
ON			tblShoppingCart.CustomerId = tblCustomer.CustomerId
LEFT JOIN	tblCountry
ON			tblCustomer.CountryId = tblCountry.CountryId
LEFT JOIN	tblShoppingCartStatus
ON			tblShoppingCart.ShoppingCartStatusId = tblShoppingCartStatus.ShoppingCartStatusId
LEFT JOIN	tblCars
ON			tblShoppingCart.ProductId = tblCars.CarId
LEFT JOIN	tblCarAccessories
ON			tblShoppingCart.ProductId = tblCarAccessories.CAId
LEFT JOIN	tblCarAccessoriesProductGroup
ON			tblCarAccessories.ProductGroupId = tblCarAccessoriesProductGroup.CAPGId
go

------------------------ Insert tblShoppingCart -------------------------------------------------------------
CREATE or Alter Trigger tr_vWShoppingCartAllDetails_InsteadOfInsert
on vWShoppingCartAllData
Instead Of Insert
as
Begin
	BEGIN TRY  

			-- Setting CustomerId And SalesPersonId from UserId for insert
			-- automatically generated Trigger tr_tblShoppingCart_Setting_CustomerId_And_SalesPersonId
			-- Setting SaleAmount for insert, update
			-- automatically generated Trigger tr_tblOrders_SaleAmount_AND_tblCarAccessoriesStock_QuantityOfStock_AND_tblCars_Sold_Settings

			-- new entry in the table tblShoppingCart
			SET IDENTITY_INSERT dbo.tblShoppingCart ON

			Insert into tblShoppingCart(ShoppingCartOrderId, UserId, CustomerId, SalesPersonId, ProductId, Quantity, OrderStatusId, Discount, ShoppingCartStatusId)
			Select ShoppingCartOrderId, UserId, CustomerId, SalesPersonId, ProductId, Quantity, OrderStatusId, Discount, ShoppingCartStatusId
			from inserted

			SET IDENTITY_INSERT dbo.tblShoppingCart OFF
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

-------------------------- DELETE tblShoppingCart --------------------------------------------------------------
CREATE or Alter Trigger tr_vWShoppingCartAllDetails_InsteadOfDelete
on vWShoppingCartAllData
Instead Of DELETE
as
Begin
	BEGIN TRY
			-- deletion from the table tblShoppingCart
			Delete tblShoppingCart 
			from tblShoppingCart
			join deleted
			on tblShoppingCart.ShoppingCartOrderId = deleted.ShoppingCartOrderId
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

-------------------------- Update tblShoppingCart -----------------------------------------------------------------------------------------
Create Or Alter Trigger tr_vWShoppingCartAllDetails_InsteadOfUpdate
on vWShoppingCartAllData 
instead of update
as
Begin
	BEGIN TRY 

			-- SaleAmount for insert, update
			-- automatically generated Trigger tr_tblOrders_SaleAmount_AND_tblCarAccessoriesStock_QuantityOfStock_AND_tblCars_Sold_Settings

	  
			-- if OrderId is updated
			if(Update(ShoppingCartOrderId))
			Begin
				Raiserror('Id cannot be changed', 16, 1)
				Return
			End

 			if(Update(UserId))
			Begin
				Update tblShoppingCart set UserId = inserted.UserId
				from inserted
				join tblShoppingCart
				on tblShoppingCart.ShoppingCartOrderId = inserted.ShoppingCartOrderId
			End

			Declare @CustomerId int
			Select @CustomerId = CustomerId
			from inserted

			if(Update(CustomerId) and (@CustomerId is not null))
			Begin
				Update tblShoppingCart set CustomerId = inserted.CustomerId
				from inserted
				join tblShoppingCart
				on tblShoppingCart.ShoppingCartOrderId = inserted.ShoppingCartOrderId
			End
	
			if(Update(SalesPersonId))
			Begin
				Update tblShoppingCart set SalesPersonId = inserted.SalesPersonId
				from inserted
				join tblShoppingCart
				on tblShoppingCart.ShoppingCartOrderId = inserted.ShoppingCartOrderId
			End
	
			if(Update(ProductId))
			Begin
				Update tblShoppingCart set ProductId = inserted.ProductId
				from inserted
				join tblShoppingCart
				on tblShoppingCart.ShoppingCartOrderId = inserted.ShoppingCartOrderId
			End

			-- ProductId and Quantity set to the value of the inserted table
			Declare @ProductId int, @Quantity int
			Select @Quantity = Quantity, @ProductId = ProductId
			from inserted

			-- it is possible to sell a quantity above the minimum stock quantity to a customer
			-- a minimális raktárkészlet mennyisége feletti mennyiséget lehetséges egy vásárlónak eladni
			if(Update(Quantity))
			Begin
				-- if Car Accessories
				if(@ProductId < 1000000)
				Begin
					-- if the quantity of stock in stock minus the minimum stock quantity + 1 is greater than the customer order quantity
					-- ha a raktáron lévő készlet mennyisége minusz a minimális raktárkészlet mennyisége + 1 nagyobb mint a vásárlói rendelési mennyiség
					if( ((Select QuantityOfStock from tblCarAccessoriesStock where CASId = @ProductId) 
						- ((Select MinimumStockQuantity from tblCarAccessoriesStock where CASId = @ProductId) + 1)) > @Quantity)
					Begin
						Update tblShoppingCart set Quantity = inserted.Quantity
						from inserted
						join tblShoppingCart
						on tblShoppingCart.ShoppingCartOrderId = inserted.ShoppingCartOrderId
					End
					-- otherwise, the customer can order the quantity of stock in stock minus the minimum stock quantity + 1 quantity
					-- különben a raktáron lévő készlet mennyisége minusz a minimális raktárkészlet mennyisége + 1 mennyiséget rendelheti meg a vásárló
					Else
					Begin
						Update tblShoppingCart set Quantity = ((Select QuantityOfStock from tblCarAccessoriesStock where CASId = @ProductId) 
						- ((Select MinimumStockQuantity from tblCarAccessoriesStock where CASId = @ProductId) + 1))
					End
				End
				Else
				Begin
					Update tblShoppingCart set Quantity = 1 -- in the case of cars, there can only be one
				End
			End

			if(Update(OrderStatusId))
			Begin
				Update tblShoppingCart set OrderStatusId = inserted.OrderStatusId
				from inserted
				join tblShoppingCart
				on tblShoppingCart.ShoppingCartOrderId = inserted.ShoppingCartOrderId
			End
	
			if(Update(Discount))
			Begin
				Update tblShoppingCart set Discount = inserted.Discount
				from inserted
				join tblShoppingCart
				on tblShoppingCart.ShoppingCartOrderId = inserted.ShoppingCartOrderId
			End
			
			Declare @ShoppingCartStatusName nvarchar(50)
			Select @ShoppingCartStatusName = ShoppingCartStatusName
			from inserted

			--if(Update(ShoppingCartStatusId))
			--Begin
			--	Update tblShoppingCart set ShoppingCartStatusId = inserted.ShoppingCartStatusId
			--	from inserted
			--	join tblShoppingCart
			--	on tblShoppingCart.ShoppingCartOrderId = inserted.ShoppingCartOrderId
			--End
			
			if(Update(ShoppingCartStatusName) and (@ShoppingCartStatusName is not null))
			Begin
				Declare @ShoppingCartStatusId int
				Select @ShoppingCartStatusId = tblShoppingCartStatus.ShoppingCartStatusId
				from tblShoppingCartStatus 
				join inserted
				on inserted.ShoppingCartStatusName = tblShoppingCartStatus.ShoppingCartStatusName
				if(@ShoppingCartStatusId is null)
				Begin
					Raiserror('Invalid Shopping Cart Status Name. Statement terminated', 16, 1)
					return
				End
				Update tblShoppingCart set ShoppingCartStatusId = @ShoppingCartStatusId
				from inserted
				join tblShoppingCart
				on tblShoppingCart.ShoppingCartOrderId = inserted.ShoppingCartOrderId
			End
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go


------ ShoppingCart SEARCH ------------------------------------------------------------------------------
Create or alter Procedure spShoppingCartSearchDynamicSQL
@ShoppingCartOrderId int = NULL, 
@UserId int = NULL, 
@CustomerId int = NULL,
@CustomerFirstName nvarchar(50) = NULL, 
@CustomerLastName nvarchar(50) = NULL,
@SalesPersonId int = NULL,
@SalesPersonFirstName nvarchar(50) = NULL, 
@SalesPersonLastName nvarchar(50) = NULL,
@ProductId int = NULL,
@ProductGroup nvarchar(50) = NULL, 
@ProductName nvarchar(50) = NULL, 
@CarModel nvarchar(50) = NULL,
@CarColor nvarchar(50) = NULL,
@Quantity int = NULL,
@CountryTaxPercentageValue float = NULL,
@Discount float = NULL,
@SaleAmount float = NULL,
@OrderStatusId int = NULL,
@OrderStatusName nvarchar(50) = NULL, 
@ShoppingCartStatusId int = NULL,
@ShoppingCartStatusName nvarchar(50) = NULL
As
Begin
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)
 
				Set @sql = 'Select ShoppingCartOrderId, UserId, tblShoppingCart.CustomerId, tblCustomer.FirstName as CustomerFirstName, 
							tblCustomer.LastName as CustomerLastName, tblShoppingCart.SalesPersonId, tblSalespersons.FirstName as SalesPersonFirstName, 
							tblSalespersons.LastName as SalesPersonLastName, ProductId, 
							ISNULL(tblCarAccessoriesProductGroup.CAPGName, @AV) as ProductGroup, 
							ISNULL(tblCarAccessories.ProductName, @Au) as ProductName,
							ISNULL(tblCars.Model, @VVA) as CarModel, ISNULL(tblCars.Color, @AZ) as CarColor, 
							Quantity, tblCountry.CountryTaxPercentageValue, Discount, SaleAmount, tblShoppingCart.OrderStatusId, OrderStatusName, 
							tblShoppingCart.ShoppingCartStatusId, tblShoppingCartStatus.ShoppingCartStatusName
							FROM		tblShoppingCart
							LEFT JOIN	tblOrderStatus
							ON			tblShoppingCart.OrderStatusId = tblOrderStatus.OrderStatusId
							LEFT JOIN	tblSalespersons
							ON			tblShoppingCart.SalesPersonId = tblSalespersons.SalesId
							LEFT JOIN	tblCustomer
							ON			tblShoppingCart.CustomerId = tblCustomer.CustomerId
							LEFT JOIN	tblCountry
							ON			tblCustomer.CountryId = tblCountry.CountryId
							LEFT JOIN	tblShoppingCartStatus
							ON			tblShoppingCart.ShoppingCartStatusId = tblShoppingCartStatus.ShoppingCartStatusId
							LEFT JOIN	tblCars
							ON			tblShoppingCart.ProductId = tblCars.CarId
							LEFT JOIN	tblCarAccessories
							ON			tblShoppingCart.ProductId = tblCarAccessories.CAId
							LEFT JOIN	tblCarAccessoriesProductGroup
							ON			tblCarAccessories.ProductGroupId = tblCarAccessoriesProductGroup.CAPGId
							where 1 = 1'
     
			 if(@ShoppingCartOrderId is not null)
				  Set @sql = @sql + ' and ShoppingCartOrderId=@SCOId'
			 if(@UserId is not null)
				  Set @sql = @sql + ' and UserId=@UId'    
			 if(@CustomerId is not null)
				  Set @sql = @sql + ' and tblShoppingCart.CustomerId=@CI'    
			 if(@CustomerFirstName is not null)
				  Set @sql = @sql + ' and tblCustomer.FirstName like(@CFN + @PS)'    
			 if(@CustomerLastName is not null)
				  Set @sql = @sql + ' and tblCustomer.LastName like(@CLN + @PS)'  
			 if(@SalesPersonId is not null)
				  Set @sql = @sql + ' and tblShoppingCart.SalesPersonId=@SPI'      
			 if(@SalesPersonFirstName is not null)
				  Set @sql = @sql + ' and tblSalespersons.FirstName like(@SPFN + @PS)'    
			 if(@SalesPersonLastName is not null)
				  Set @sql = @sql + ' and tblSalespersons.LastName like(@SPLN + @PS)'  
			 if(@ProductId is not null)
				  Set @sql = @sql + ' and ProductId=@PrI'		  
			 if(@ProductGroup is not null)
				  Set @sql = @sql + ' and tblCarAccessoriesProductGroup.CAPGName like(@PG + @PS)'
			 if(@ProductName is not null)
				  Set @sql = @sql + ' and tblCarAccessories.ProductName like(@PN + @PS)'  
			 if(@CarModel is not null)
				  Set @sql = @sql + ' and tblCars.Model like(@CM + @PS)'  	  
			 if(@CarColor is not null)
				  Set @sql = @sql + ' and tblCars.Color like(@CC + @PS)'  
			 if(@Quantity is not null)
				  Set @sql = @sql + ' and Quantity=@Qa'
			 if(@CountryTaxPercentageValue is not null)
				  Set @sql = @sql + ' and tblCountry.CountryTaxPercentageValue=@CTPV'
			if(@Discount is not null)
				  Set @sql = @sql + ' and Discount=@Di'				  
			if(@SaleAmount is not null)
				  Set @sql = @sql + ' and SaleAmount=@SAm'
			 if(@OrderStatusId is not null)
				  Set @sql = @sql + ' and tblShoppingCart.OrderStatusId=@OSI'     
			 if(@OrderStatusName is not null)
				  Set @sql = @sql + ' and OrderStatusName like(@OSN + @PS)'    
			if(@ShoppingCartStatusId is not null)
				  Set @sql = @sql + ' and tblShoppingCart.ShoppingCartStatusId=@SCSI'
			if(@ShoppingCartStatusName is not null)
				  Set @sql = @sql + ' and ShoppingCartStatusName like(@SCSN + @PS)'

			 Execute sp_executesql @sql,
			 N'@SCOId int, @UId int, @CI int, @CFN nvarchar(50), @CLN nvarchar(50), @SPI int, @SPFN nvarchar(50), @SPLN nvarchar(50), 
			 @PrI int, @PG nvarchar(50), @PN nvarchar(50), @CM nvarchar(50), @CC nvarchar(50), @Qa int, @CTPV float, @Di float, @SAm float,
			 @OSI int, @OSN nvarchar(50), @SCSI int, @SCSN nvarchar(50),
			 @AV nvarchar(11), @Au nvarchar(4), @VVA nvarchar(21), @AZ nvarchar(11), @PS nvarchar(1)',
			 @SCOId=@ShoppingCartOrderId, @UId= @UserId, @CI=@CustomerId, @CFN=@CustomerFirstName, @CLN=@CustomerLastName,
			 @SPI=@SalesPersonId, @SPFN=@SalesPersonFirstName, @SPLN=@SalesPersonLastName, @PrI=@ProductId,
			 @PG=@ProductGroup, @PN=@ProductName, @CM=@CarModel, @CC=@CarColor, @Qa=@Quantity, @CTPV=@CountryTaxPercentageValue,
			 @Di=@Discount, @SAm=@SaleAmount, @OSI=@OrderStatusId, @OSN=@OrderStatusName, @SCSI=@ShoppingCartStatusId, @SCSN=@ShoppingCartStatusName,
			 @AV='Autoverkauf', @Au='Auto', @VVA='VerkaufVonAutozubehör', @AZ='Autozubehör', @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ ShoppingCart Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spShoppingCartUpdateOrInsert
@ShoppingCartOrderId int = NULL, 
@UserId int = NULL, 
@CustomerId int = NULL,
@CustomerFirstName nvarchar(50) = NULL, 
@CustomerLastName nvarchar(50) = NULL,
@SalesPersonId int = NULL,
@SalesPersonFirstName nvarchar(50) = NULL, 
@SalesPersonLastName nvarchar(50) = NULL,
@ProductId int = NULL,
@ProductGroup nvarchar(50) = NULL, 
@ProductName nvarchar(50) = NULL, 
@CarModel nvarchar(50) = NULL,
@CarColor nvarchar(50) = NULL,
@Quantity int = NULL,
@CountryTaxPercentageValue float = NULL,
@Discount float = NULL,
@SaleAmount float = NULL,
@OrderStatusId int = NULL,
@OrderStatusName nvarchar(50) = NULL, 
@ShoppingCartStatusId int = NULL,
@ShoppingCartStatusName nvarchar(50) = NULL
AS
Begin
	Begin Try
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		begin tran
			-- if you already have this ShoppingCart
			if (exists (select * from vWShoppingCartAllData with (updlock,serializable) where ShoppingCartOrderId = @ShoppingCartOrderId))
			begin
				update vWShoppingCartAllData set UserId = @UserId, CustomerId = @CustomerId, 
				CustomerFirstName = @CustomerFirstName, CustomerLastName = @CustomerLastName, SalesPersonId = @SalesPersonId, 
				SalesPersonFirstName = @SalesPersonFirstName, SalesPersonLastName = @SalesPersonLastName, ProductId = @ProductId, 
				ProductGroup = @ProductGroup, ProductName = @ProductName, CarModel = @CarModel, CarColor = @CarColor, Quantity = @Quantity,
				CountryTaxPercentageValue = @CountryTaxPercentageValue, Discount = @Discount, SaleAmount = @SaleAmount,
				OrderStatusId = @OrderStatusId, OrderStatusName = @OrderStatusName, ShoppingCartStatusId = @ShoppingCartStatusId, 
				ShoppingCartStatusName = @ShoppingCartStatusName
				where ShoppingCartOrderId = @ShoppingCartOrderId
			end
			else 
			begin
				if(@ShoppingCartOrderId is not Null)
				begin
					insert into vWShoppingCartAllData values (@ShoppingCartOrderId, @UserId, @CustomerId, @CustomerFirstName, @CustomerLastName, @SalesPersonId, 
					@SalesPersonFirstName, @SalesPersonLastName, @ProductId, @ProductGroup, @ProductName, @CarModel, @CarColor, @Quantity, @CountryTaxPercentageValue,
					@Discount, @SaleAmount,@OrderStatusId, @OrderStatusName, @ShoppingCartStatusId, @ShoppingCartStatusName)
				end
				else
				begin
					insert into vWShoppingCartAllData values (IDENT_CURRENT('tblShoppingCart')+1 , @UserId, @CustomerId, @CustomerFirstName, 
					@CustomerLastName, @SalesPersonId, @SalesPersonFirstName, @SalesPersonLastName, @ProductId, @ProductGroup, 
					@ProductName, @CarModel, @CarColor, @Quantity, @CountryTaxPercentageValue,
					@Discount, @SaleAmount,@OrderStatusId, @OrderStatusName, @ShoppingCartStatusId, @ShoppingCartStatusName)
				end			
			end
		commit tran	
	End Try
    Begin Catch 
		Rollback Transaction
		EXECUTE usp_GetErrorInfo
    End Catch 
End
go
------ ShoppingCart Delete ---------------------------------------------------------------------
Create or alter Procedure spShoppingCartDelete
@ShoppingCartOrderId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@ShoppingCartOrderId is not Null)
			begin
				Delete from dbo.vWShoppingCartAllData where ShoppingCartOrderId = @ShoppingCartOrderId
			end
			else
			begin
				Print 'Shopping Cart Order Id is not found ' + @ShoppingCartOrderId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ ShoppingCartStatus SEARCH ----------------------------------------------------------------------
Create or alter Procedure spShoppingCartStatusSearchDynamicSQL
@ShoppingCartStatusId int = Null,
@ShoppingCartStatusName nvarchar(50) = NULL
As
Begin
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)

			 Set @sql = 'Select ShoppingCartStatusId, ShoppingCartStatusName
						from	tblShoppingCartStatus
						where 1 = 1'
    
			 if(@ShoppingCartStatusId is not null)
				  Set @sql = @sql + ' and ShoppingCartStatusId=@SCSI'
     
			 if(@ShoppingCartStatusName is not null)
				  Set @sql = @sql + ' and ShoppingCartStatusName like(@SCSN + @PS)'
     
			 Execute sp_executesql @sql,
			 N'@SCSI int, @SCSN nvarchar(50), @PS nvarchar(1)',
			 @SCSI=@ShoppingCartStatusId, @SCSN=@ShoppingCartStatusName, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ ShoppingCartStatus Update or Insert  ---------
Create or alter Procedure spShoppingCartStatusUpdateOrInsert
@ShoppingCartStatusId int = Null,
@ShoppingCartStatusName nvarchar(50) = NULL
AS
Begin
BEGIN TRY  
   	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	begin tran
		if (exists (select * from tblShoppingCartStatus with (updlock,serializable) where ShoppingCartStatusId = @ShoppingCartStatusId))
			begin
			   update tblShoppingCartStatus set ShoppingCartStatusName = @ShoppingCartStatusName
			   where ShoppingCartStatusId = @ShoppingCartStatusId
			end
			else
			begin
				if(@ShoppingCartStatusId is not Null)
				begin
					insert into tblShoppingCartStatus (ShoppingCartStatusId, ShoppingCartStatusName) 
					values (@ShoppingCartStatusId, @ShoppingCartStatusName)
				end
				else
				begin
					insert into tblShoppingCartStatus (ShoppingCartStatusId, ShoppingCartStatusName) 
					values (IDENT_CURRENT('tblShoppingCartStatus')+1 , @ShoppingCartStatusName)
				end
			end
	commit tran
END TRY  
BEGIN CATCH  
	Rollback Transaction
    -- Execute error retrieval routine.  
    EXECUTE usp_GetErrorInfo;  
END CATCH
End
go
------ ShoppingCartStatus Delete ----------------------------------------------------------------------
Create or alter Procedure spShoppingCartStatusDelete
@ShoppingCartStatusId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@ShoppingCartStatusId is not Null)
			begin
				Delete from dbo.tblShoppingCartStatus where ShoppingCartStatusId = @ShoppingCartStatusId
			end
			else
			begin
				Print 'ShoppingCartStatusId is not found ' + @ShoppingCartStatusId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ Shopping Cart Customer Id Null Count ------------------------------------------------------------------------------
-- all items in the seller's shopping cart minus those without a customer ID. If the value is zero, then every shopping cart item has a customer
-- alle Artikel im Warenkorb des Verkäufers abzüglich der Artikel ohne Kundennummer. Wenn der Wert null ist, dann hat jede Warenkorbposition einen Kunden
-- az eladó összes bevásárló kosárban lévő eleme mínusz a vevő azonosító nélküliek. Ha az érték nulla, akkor minden bevásárló kosár elemhez tartozik ügyfél
Create or alter Procedure spShoppingCartCustomerIdNullCount
@UserId int = NULL,
@ShoppingCartStatusName nvarchar(50) = NULL
As
Begin
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)
 
				Set @sql = 'Select		COUNT(UserId) - COUNT(CustomerId)
							FROM		vWShoppingCartAllData
							where		1 = 1'
     
			 if(@UserId is not null)
				  Set @sql = @sql + ' and UserId=@UId'    

			 if(@ShoppingCartStatusName is not null)
				  Set @sql = @sql + ' and ShoppingCartStatusName=@SCSN'    

			 Execute sp_executesql @sql,
			 N'@UId int, @SCSN nvarchar(50)', 
			 @UId= @UserId, @SCSN=@ShoppingCartStatusName
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

-- when placing the product in the shopping cart, ShoppingCart Status = "Im Einkaufswagen" and Order Status = "Ausstehend" preparing the order
-- each time a new item is added, the Shopping Cart Status Id and Order Status Id are automatically updated to 1
-- Discount = 0
-- beim Einlegen des Produkts in den Warenkorb, ShoppingCart Status = "Im Einkaufswagen" und Order Status = "Ausstehend" zur Vorbereitung der Bestellung
-- Jedes Mal, wenn ein neuer Artikel hinzugefügt wird, werden die Warenkorb-Status-ID und die Bestellstatus-ID automatisch auf 1 aktualisiert
-- Discount = 0
-- a termék bevásásrlókosárba helyezésénél a ShoppingCart Status = "Im Einkaufswagen" az Order Status = "Ausstehend" előkészítve a megrendelést
-- minden új elem hozzáadásánál automatikusan a Shopping Cart Status Id és az Order Status Id 1-re frissül
-- Discount = 0
---- ShoppingCart Setting ShoppingCartStatusId And OrderStatusId -------------------------------------------------------------------
CREATE OR ALTER Trigger tr_tblShoppingCart_Setting_ShoppingCartOrderId_And_OrderStatusId_And_Discount
on tblShoppingCart for insert
as 
Begin
	BEGIN TRY  
			update tblShoppingCart 
				set ShoppingCartStatusId = 1, OrderStatusId = 1, Discount = 0
				from Inserted 
				where tblShoppingCart.ShoppingCartOrderId=Inserted.ShoppingCartOrderId
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

------------ Shopping Cart only Status Settings ---------------------------------------------------
Create or alter Procedure spShoppingCartStatusSettings
@ShoppingCartOrderId int = Null,
@ShoppingCartStatusName nvarchar(50) = NULL
AS
Begin
BEGIN TRY  
   	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	begin tran
		if (exists (select * from tblShoppingCart with (updlock,serializable) where ShoppingCartOrderId = @ShoppingCartOrderId))
			begin
			   Declare @ShoppingCartStatusId int
			   
				Select @ShoppingCartStatusId = ShoppingCartStatusId
				from tblShoppingCartStatus
				Where ShoppingCartStatusName = @ShoppingCartStatusName

			   
			   if(@ShoppingCartStatusId is NULL )
				Begin
					Raiserror('Invalid Shopping Cart Status Name', 16, 1)
					Return
				End
  
			   update tblShoppingCart set ShoppingCartStatusId = @ShoppingCartStatusId
			   where ShoppingCartOrderId = @ShoppingCartOrderId
			end			
	commit tran
END TRY  
BEGIN CATCH  
	Rollback Transaction
    -- Execute error retrieval routine.  
    EXECUTE usp_GetErrorInfo;  
END CATCH
End
go

------------ Number of shopping cart list items by shopping cart status ------------
Create or alter Procedure spNumber_of_shopping_cart_list_items_by_status
@UserId int = NULL,
@ShoppingCartStatusName nvarchar(50) = NULL
As
Begin
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)
 
				Set @sql = 'Select		COUNT(ShoppingCartStatusName)
							FROM		vWShoppingCartAllData
							where		1 = 1'
     
			 if(@UserId is not null)
				  Set @sql = @sql + ' and UserId=@UId'    

			 if(@ShoppingCartStatusName is not null)
				  Set @sql = @sql + ' and ShoppingCartStatusName=@SCSN'    

			 Execute sp_executesql @sql,
			 N'@UId int, @SCSN nvarchar(50)', 
			 @UId= @UserId, @SCSN=@ShoppingCartStatusName
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go







------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------- tblOrders ------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------


Create Table tblStockReplenishmentList
	(
		SRLId INT IDENTITY (1, 1) PRIMARY KEY,
		ProductId int NOT NULL foreign key references tblCarAccessories(CAId),
		OrderedStatus bit NOT NULL,
		SRLTimeStamp datetime2
	)
go

Create Table tblOrders
	(
		OrderId INT IDENTITY (0, 1) PRIMARY KEY,
		CustomerId INT NOT NULL foreign key references tblCustomer(CustomerId),
		SalesPersonId INT NOT NULL foreign key references tblSalespersons(SalesId),
		ProductId INT,-- autók 1000000-től, kiegészítők 1-tól
		Quantity INT NOT NULL, --mennyiség
		OrderDate datetime2, --rendelés dátuma
		OrderStatusId INT NOT NULL foreign key references tblOrderStatus(OrderStatusId), 
		Discount FLOAT NOT NULL DEFAULT 0, --kedvezmény
		ShippedDate datetime2, --kiszállítás dátuma
		SaleAmount FLOAT, --Eladási összeg
		SaleAmountPaid FLOAT,--kifizetett Eladási összeg
		TaxPercentageValue FLOAT, -- Adószázalék
		SaleTime datetime2, --Eladási dátum, idő ekkor már bérkezett a Kifizetett Eladási összeg
		ShoppingCartOrderId int NOT NULL foreign key references tblShoppingCart(ShoppingCartOrderId)
	)
go

---- Audit tblOrders ----------------------------------------------------------------
CREATE TABLE tblOrdersAudit
(
  OrdersAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go
---- Audit tblOrderStatus ----------------------------------------------------------------
CREATE TABLE tblOrderStatusAudit
(
  OrderStatusAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go
----- Audit tblStockReplenishmentList ----------------------------------------------------------------
CREATE TABLE tblStockReplenishmentListAudit
(
  SRLAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go

---- Orders Timestamp -----------------------------------------------------------------
CREATE OR ALTER Trigger tr_tblOrders_Timestamp_And_TaxAmount_ShippedDate_Sold_Settings
on tblOrders for insert
as 
Begin
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
--		Begin tran
			update tblOrders 
			set OrderDate = getdate(), 
				ShippedDate = getdate()+4,
				TaxPercentageValue = 
				(select CountryTaxPercentageValue from tblCountry
				join tblCustomer
				on tblCountry.CountryId = tblCustomer.CountryId
				where CustomerId = inserted.CustomerId) 
			from Inserted 
			where tblOrders.OrderId=Inserted.OrderId
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-- Orders & Car.Sold Settings & calculation SaleAmount AND QuantityOfStock AND Discont -- SERIALIZABLE BLOCK --------
CREATE OR ALTER Trigger tr_tblOrders_SaleAmount_AND_tblCarAccessoriesStock_QuantityOfStock_AND_tblCars_Sold_Settings
on tblOrders for insert, update
as 
Begin
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
--		Begin tran
			-- CarAccessories SaleAmount calculation
			update tblOrders 
			set SaleAmount = ((tblOrders.Quantity * tblCarAccessories.NetSellingPrice * ((tblOrders.TaxPercentageValue / 100) + 1)) * (1-(tblOrders.Discount/100)))
			from Inserted 
			JOIN tblCarAccessories
			ON Inserted.ProductId = tblCarAccessories.CAId
			where tblOrders.OrderId=Inserted.OrderId
	
			-- Car SaleAmount calculation
			update tblOrders 
			set SaleAmount = ((tblCars.NettoPrice * ((tblOrders.TaxPercentageValue / 100) + 1)) * (1-(tblOrders.Discount/100)))
			from Inserted 
			JOIN tblCars
			ON Inserted.ProductId = tblCars.CarId
			where tblOrders.OrderId=Inserted.OrderId

			--Car reserved
			update tblCars
			set Sold = 1
			from inserted
			where tblCars.CarId=Inserted.ProductId			
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

-------- Insert Audit tblOrders ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblOrders_ForInsert
ON tblOrders
FOR INSERT
AS
Begin
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = OrderId from inserted
			  insert into tblOrdersAudit 
			 values('New Order with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())	 
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------- Delete Audit tblOrders ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblOrders_ForDelete
ON tblOrders
FOR DELETE
AS
Begin
	BEGIN TRY  
--		Begin tran
			 Declare @Id int
			 Select @Id = OrderId from deleted 
			  insert into tblOrdersAudit 
			 values('An existing Order with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------- Update Audit tblOrders ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblOrders_ForUpdate
ON tblOrders
for Update
as
Begin
	BEGIN TRY  
--		Begin tran
			  Declare @Id int 
			  Declare @OldCustomerId int, @NewCustomerId int
			  Declare @OldSalesPersonId int, @NewSalesPersonId int
			  Declare @OldProductId int, @NewProductId int
			  Declare @OldQuantity int, @NewQuantity int
			  Declare @OldOrderDate datetime2, @NewOrderDate datetime2
			  Declare @OldOrderStatusId int, @NewOrderStatusId int
			  Declare @OldDiscount float, @NewDiscount float
			  Declare @OldShippedDate datetime2, @NewShippedDate datetime2
			  Declare @OldSaleAmount float, @NewSaleAmount float
			  Declare @OldSaleAmountPaid float, @NewSaleAmountPaid float
			  Declare @OldTaxPercentageValue float, @NewTaxPercentageValue float
			  Declare @OldShoppingCartOrderId int, @NewShoppingCartOrderId int

			  Declare @AuditString nvarchar(1000)
      
			  Select *
			  into #TempTable 
			  from inserted
     
			  While(Exists(Select OrderId from #TempTable))
			  Begin
					Set @AuditString = ''
					Select Top 1 @Id = OrderId, 
						@OldCustomerId  = CustomerId,
						@OldSalesPersonId = SalesPersonId,
						@OldProductId = ProductId,
						@OldQuantity = Quantity,
						@OldOrderDate = OrderDate,
						@OldOrderStatusId = OrderStatusId,
						@OldDiscount = Discount,
						@OldShippedDate = ShippedDate,
						@OldSaleAmount = SaleAmount,
						@OldSaleAmountPaid = SaleAmountPaid,
						@OldTaxPercentageValue = TaxPercentageValue,
						@OldShoppingCartOrderId = ShoppingCartOrderId

					from #TempTable
					Select 
						@NewCustomerId = CustomerId,
						@NewSalesPersonId = SalesPersonId,
						@NewProductId = ProductId,
						@NewQuantity = Quantity,
						@NewOrderDate = OrderDate,
						@NewOrderStatusId = OrderStatusId,
						@NewDiscount = Discount,
						@NewShippedDate = ShippedDate,
						@NewSaleAmount = SaleAmount,
						@NewSaleAmountPaid = SaleAmountPaid,
						@NewTaxPercentageValue = TaxPercentageValue,
						@NewShoppingCartOrderId = ShoppingCartOrderId

					from deleted where OrderId = @Id
					Set @AuditString = 'Order with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'

					if(@OldCustomerId <> @NewCustomerId)
						  Set @AuditString = @AuditString + ' Customer Id from ' + Cast(@OldCustomerId as nvarchar(10)) + 
						  ' to ' + Cast(@NewCustomerId as nvarchar(10))
            
					if(@OldSalesPersonId <> @NewSalesPersonId)
						  Set @AuditString = @AuditString + ' Sales Person Id from ' + Cast(@OldSalesPersonId as nvarchar(4)) + 
						  ' to ' + Cast(@NewSalesPersonId as nvarchar(4))

					if(@OldProductId <> @NewProductId)
						  Set @AuditString = @AuditString + ' Product Id from ' + Cast(@OldProductId as nvarchar(10)) + 
						  ' to ' + Cast(@NewProductId as nvarchar(10))
				  
					if(@OldQuantity <> @NewQuantity)
						  Set @AuditString = @AuditString + ' Quantity from ' + Cast(@OldQuantity as nvarchar(10)) + 
						  ' to ' + Cast(@NewQuantity as nvarchar(10))

					if(@OldOrderDate <> @NewOrderDate)
						  Set @AuditString = @AuditString + ' Order Date ' + Cast(@OldOrderDate as nvarchar(40)) + 
						  ' to ' + Cast(@NewOrderDate as nvarchar(40))
				  
					if(@OldOrderStatusId <> @NewOrderStatusId)
						  Set @AuditString = @AuditString + ' Order Status Id from ' + Cast(@OldOrderStatusId as nvarchar(2)) + 
						  ' to ' + Cast(@NewOrderStatusId as nvarchar(2))
				  
					if(@OldDiscount <> @NewDiscount)
						  Set @AuditString = @AuditString + ' Discount from ' + Cast(@OldDiscount as nvarchar(10)) + 
						  ' to ' + Cast(@NewDiscount as nvarchar(10))
				  
					if(@OldShippedDate <> @NewShippedDate)
						  Set @AuditString = @AuditString + ' Shipped Date from ' + Cast(@OldShippedDate as nvarchar(20)) + 
						  ' to ' + Cast(@NewShippedDate as nvarchar(20))
				  
					if(@OldSaleAmount <> @NewSaleAmount)
						  Set @AuditString = @AuditString + ' Sale Amount from ' + Cast(@OldSaleAmount as nvarchar(10)) + 
						  ' to ' + Cast(@NewSaleAmount as nvarchar(10))
				  
					if(@OldSaleAmountPaid <> @NewSaleAmountPaid)
						  Set @AuditString = @AuditString + ' Sale Amount Paid from ' + Cast(@OldSaleAmountPaid as nvarchar(10)) + 
						  ' to ' + Cast(@NewSaleAmountPaid as nvarchar(10))
				  
					if(@OldTaxPercentageValue <> @NewTaxPercentageValue)
						  Set @AuditString = @AuditString + ' Tax Amount from ' + Cast(@OldTaxPercentageValue as nvarchar(3)) + 
						  ' to ' + Cast(@NewTaxPercentageValue as nvarchar(3))
				  
					if(@OldShoppingCartOrderId <> @NewShoppingCartOrderId)
						  Set @AuditString = @AuditString + ' Shopping Cart Order Id from ' + Cast(@OldShoppingCartOrderId as nvarchar(10)) + 
						  ' to ' + Cast(@NewShoppingCartOrderId as nvarchar(10))
            
					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
					insert into tblOrdersAudit values(@AuditString)
            
					Delete from #TempTable where OrderId = @Id
			  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

------ Insert Audit tblStockReplenishmentList ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblStockReplenishmentList_ForInsert
ON tblStockReplenishmentList
FOR INSERT
AS
Begin 
	BEGIN TRY  
--		Begin tran
			Declare @Id int
			Select @Id = SRLId from inserted
			insert into tblStockReplenishmentListAudit 
			values('New Stock Replenishment Item with Id  = ' + Cast(@Id as nvarchar(10)) + 
				' is added at ' + cast(Getdate() as nvarchar(30)) +
				' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Delete Audit tblStockReplenishmentList ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblStockReplenishmentList_ForDelete
ON tblStockReplenishmentList
FOR DELETE
AS
Begin 
	BEGIN TRY  
--		Begin tran
			Declare @Id int
			Select @Id = SRLId from deleted 
			insert into tblStockReplenishmentListAudit 
			values('An existing Stock Replenishment Item with Id  = ' + Cast(@Id as nvarchar(10)) + 
				' is deleted at ' + cast(Getdate() as nvarchar(30)) +
				' Login Name = ' + ORIGINAL_LOGIN())
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Update Audit tblStockReplenishmentList ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblStockReplenishmentList_ForUpdate
ON tblStockReplenishmentList
for Update
as
Begin 
	BEGIN TRY  
--		Begin tran
			  -- Változók deklarálása a régi és frissített adatok
			  Declare @Id int -- nem változik
			  Declare @OldProductId int, @NewProductId int
			  Declare @OldOrderedStatus bit, @NewOrderedStatus bit
			  Declare @OldSRLTimeStamp datetime2, @NewSRLTimeStamp datetime2
     
			  -- Változó az audit karakterlánc
			  Declare @AuditString nvarchar(1000)
      
			  -- Töltse be a frissített rekordokat az ideiglenes táblába
			  -- ha valaki frissít egy adott sort, az új adatok a beszúrt
			  -- táblában lesznek ezeket tároljuk a #TempTable-ben
			  Select *
			  into #TempTable -- tedd be ezt a sort az ideiglenes táblába
			  from inserted
     
			  -- Hurok a temp tábla
			  -- mivel tetszőleges számú azonosítót adhatunk meg, így ha 
			  -- ennyi rekordok frissítünk egyszerre, akkor ciklust kell használni
			  -- mert frissíteni akarunk minden kiválasztott alkalmazottat
			  -- ezért tesszük az ideiglenes táblába
			  -- az ideiglenes táblából kiválasztjuk az azonosítókat, ha vannak
			  -- ha nincsenek, akkor nem ad vissza semmit az Exists() függvény 
			  -- false értéket ad vissza
			  While(Exists(Select SRLId from #TempTable))
			  Begin
					--Inicializálja az audit karakterláncot az üres karakterlánchoz
					Set @AuditString = ''
           
					-- Válassza ki az első sor adatait a temp táblából
					-- mert ezt a sort a frissítési művelet befejezése után 
					-- köveztkező lépésben törölni fogom
					-- az új megváltoztatott adatokat tartalmazza
					Select Top 1 @Id = SRLId, 
					@NewProductId = ProductId, 
					@NewOrderedStatus = OrderedStatus,
					@NewSRLTimeStamp = SRLTimeStamp
					from #TempTable
           
					-- Válassza ki a megfelelő sort a törölt táblázatból
					-- a régi eredeti adatokat tartalmazza
					Select 
					@OldProductId = ProductId, 
					@OldOrderedStatus = OrderedStatus,
					@OldSRLTimeStamp = SRLTimeStamp
					from deleted where SRLId = @Id
   
					--  Az audit karakterlánc összeállítása dinamikusan
					-- régi és új adatok összehasonlítása, majd a karakterláncba fűzése
					Set @AuditString = 'Stock Replenishment Item with Id = ' + Cast(@Id as nvarchar(10)) + ' changed'
            
					if(@OldProductId <> @NewProductId)
						  Set @AuditString = @AuditString + ' Number of seats from ' + Cast(@OldProductId as nvarchar(10)) + 
						  ' to ' + Cast(@NewProductId as nvarchar(10))
            
					if(@OldOrderedStatus <> @NewOrderedStatus)
						  Set @AuditString = @AuditString + ' Year of production from ' + Cast(@OldOrderedStatus as nvarchar(10)) + 
						  ' to ' + Cast(@NewOrderedStatus as nvarchar(10))
            
					if(@OldSRLTimeStamp <> @NewSRLTimeStamp)
						  Set @AuditString = @AuditString + ' SRLTimeStamp from ' + Cast(@OldSRLTimeStamp as nvarchar(30)) + 
						  ' to ' + Cast(@NewSRLTimeStamp as nvarchar(30))
            
					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		
					-- ellenőrzés és karakterlánc fűzés után eltároljuk, a számozás automatikus
					insert into tblStockReplenishmentListAudit values(@AuditString)
            
					-- Töröljük a sort a temp táblából
					Delete from #TempTable where SRLId = @Id
			  End
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go


----- View, update, delete, insert Triggers --------------------------------------------------
Create or Alter View vWOrdersAllData
as
Select OrderId, tblOrders.CustomerId, tblCustomer.FirstName as CustomerFirstName, tblCustomer.LastName as CustomerLastName, 
tblOrders.SalesPersonId, tblSalespersons.FirstName as SalesPersonFirstName, tblSalespersons.LastName as SalesPersonLastName, 
tblOrders.ProductId, ISNULL(tblCarAccessoriesProductGroup.CAPGName, 'Autoverkauf') as ProductGroup, 
ISNULL(tblCarAccessories.ProductName, 'Auto') as ProductName,
ISNULL(tblCars.Model, 'Verkauf von Autozubehör') as CarModel, ISNULL(tblCars.Color, 'Autozubehör') as CarColor,
tblOrders.Quantity, OrderDate, tblOrderStatus.OrderStatusId, OrderStatusName, tblOrders.Discount, ShippedDate, 
tblOrders.SaleAmount, SaleAmountPaid, TaxPercentageValue, SaleTime, tblOrders.ShoppingCartOrderId, tblShoppingCartStatus.ShoppingCartStatusName
FROM		tblOrders
JOIN		tblOrderStatus
ON			tblOrders.OrderStatusId = tblOrderStatus.OrderStatusId
JOIN		tblSalespersons
ON			tblOrders.SalesPersonId = tblSalespersons.SalesId
JOIN		tblCustomer
ON			tblOrders.CustomerId = tblCustomer.CustomerId
LEFT JOIN	tblCars
ON			tblOrders.ProductId = tblCars.CarId
LEFT JOIN	tblCarAccessories
ON			tblOrders.ProductId = tblCarAccessories.CAId
LEFT JOIN	tblCarAccessoriesProductGroup
ON			tblCarAccessories.ProductGroupId = tblCarAccessoriesProductGroup.CAPGId
LEFT JOIN	tblShoppingCart
ON			tblShoppingCart.ShoppingCartOrderId = tblOrders.ShoppingCartOrderId
LEFT JOIN	tblShoppingCartStatus
ON			tblShoppingCart.ShoppingCartStatusId = tblShoppingCartStatus.ShoppingCartStatusId

go
------------------------ Insert tblOrders -- SNAPSHOT BLOCK-------------------------------------------------------------
----------- tblCarAccessoriesStock ---- deduction from stock with inserted.ProductId ------------
----------- tblStockReplenishmentList ---- order if the stock is lower than 50 pieces ------------
CREATE or Alter Trigger tr_vWOrdersAllDetails_InsteadOfInsert
on vWOrdersAllData
Instead Of Insert
as
Begin
	BEGIN TRY  
	  -- SNAPSHOT full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
--	  SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--		Begin tran
			-- storing the parameters of a new entry
			Declare @ProductId int, @Quantity int, @DT datetime2
			Set @DT = GETDATE()
			Select @ProductId = ProductId, @Quantity = Quantity
			from inserted

			-- if Product = Car Accessories Stock
			if(@ProductId < 1000000)
			begin
				-- deduction from stock with inserted.ProductId
				Update tblCarAccessoriesStock set QuantityOfStock = tblCarAccessoriesStock.QuantityOfStock - inserted.Quantity
				from inserted 
				join tblCarAccessoriesStock
				on tblCarAccessoriesStock.CASId = inserted.ProductId

				-- add list element (tblStockReplenishmentList) -- if the CarAccessories Stock is lower than MinimumStockQuantity
				if
				(
					-- the Quantity Of Stock is lower than 50 pieces
					(((Select QuantityOfStock from tblCarAccessoriesStock where CASId = @ProductId) - @Quantity) < (Select MinimumStockQuantity from tblCarAccessoriesStock where CASId = @ProductId))
					and
					-- ProductId not included AND with "0" ordered status in the Stock Replenishment List 
					((select COUNT(DISTINCT ProductId) from tblStockReplenishmentList where ProductId = @ProductId and OrderedStatus = 0) = 0)
				)
				begin
					insert into tblStockReplenishmentList (ProductId, OrderedStatus, SRLTimeStamp) values(@ProductId, 0, @DT)
				end
			end

			-- if Product = Car, is reserved for sale
			Else
			begin
				Update tblCars set Sold = 1
				from inserted 
				join tblCars
				on tblCars.CarId = inserted.ProductId
			end

			-- Timestamp TaxAmount ShippedDate
			-- automatically generated for insert from Trigger tr_tblOrders_Timestamp_And_TaxAmount_ShippedDate

			-- SaleAmount QuantityOfStock Sold Settings for insert, update
			-- automatically generated Trigger tr_tblOrders_SaleAmount_AND_tblCarAccessoriesStock_QuantityOfStock_AND_tblCars_Sold_Settings
				

			-- new entry in the table tblOrders
			SET IDENTITY_INSERT dbo.tblOrders ON

			Insert into tblOrders(OrderId, CustomerId, SalesPersonId, ProductId, Quantity, OrderDate, OrderStatusId, Discount, 
			ShippedDate, SaleAmount, SaleAmountPaid, TaxPercentageValue, SaleTime, ShoppingCartOrderId)
			Select OrderId, CustomerId, SalesPersonId, ProductId, Quantity, OrderDate, OrderStatusId, Discount, 
			ShippedDate, SaleAmount, SaleAmountPaid, TaxPercentageValue, SaleTime, ShoppingCartOrderId
			from inserted

			SET IDENTITY_INSERT dbo.tblOrders OFF
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------------------------- DELETE tblOrders -- SNAPSHOT BLOCK-------------------------------------------------------------
----------- return to tblCarAccessoriesStock ---- add to QuantityOfStock deleted.Product Id -------------
----------- tblCarAccessoriesStock ------order if the stock is bigger than 50 pieces
CREATE or Alter Trigger tr_vWOrdersAllDetails_InsteadOfDelete
on vWOrdersAllData
Instead Of DELETE
as
Begin
	BEGIN TRY  
	  -- SNAPSHOT full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads
--	  SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--		Begin tran
			-- storing the parameters of the entry to be deleted
			Declare @ProductId int, @Quantity int
			Select @ProductId = ProductId, @Quantity = Quantity
			from deleted

			-- if Product = Car Accessories Stock
			if(@ProductId < 1000000)
			begin
				-- return to warehouse -- writing back the quantity of the deleted entry to the warehouse
				Update tblCarAccessoriesStock set QuantityOfStock = QuantityOfStock + deleted.Quantity
				from deleted 
				join tblCarAccessoriesStock
				on tblCarAccessoriesStock.CASId = deleted.ProductId

				-- delete an entry from the Stock Replenishment List whose Ordered Status is 0
				if
				(
					----order if the stock is bigger than MinimumStockQuantity
					(((Select QuantityOfStock from tblCarAccessoriesStock where CASId = @ProductId) + @Quantity) > (Select MinimumStockQuantity from tblCarAccessoriesStock where CASId = @ProductId))
				)
					begin
						Delete tblStockReplenishmentList
						from tblStockReplenishmentList 
						join deleted
						on tblStockReplenishmentList.ProductId = deleted.ProductId
						where OrderedStatus = 0
					end
			end

			-- if Product = Car, then not sold
			Else
			begin
				Update tblCars set Sold = 0
				from deleted 
				join tblCars
				on tblCars.CarId = deleted.ProductId
			end

			-- deletion from the table tblOrders
			Delete tblOrders 
			from tblOrders
			join deleted
			on tblOrders.OrderId = deleted.OrderId
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------------------------- Update -- SNAPSHOT BLOCK-------------------------------------------------------------------------------------------
----------- tblStockReplenishmentList order if the stock is lower than 50 pieces insert new List Item --------------------------------------------------
----------- tblStockReplenishmentList order if the stock is biger than 50 pieces delete List Item --------------------------------------------------
----------- Update tblCarAccessoriesStock ---- adding order quantity to Stock with tblOrders.Quantity ------------------
----------- Update tblCarAccessoriesStock ---- deduction from stock with inserted.ProductId ------------------
Create Or Alter Trigger tr_vWOrdersAllDetails_InsteadOfUpdate
on vWOrdersAllData
instead of update
as
Begin
	BEGIN TRY 
			-- SaleAmount QuantityOfStock Sold Settings for insert, update
			-- automatically generated Trigger tr_tblOrders_SaleAmount_AND_tblCarAccessoriesStock_QuantityOfStock_AND_tblCars_Sold_Settings


			-- storing the parameters of the entry to be inserted
			Declare @NewInsertedOrderId int, @NewInsertedProductId int, @NewInsertedQuantity int, @DT datetime2
			Set @DT = GETDATE()
			Select @NewInsertedOrderId = OrderId, @NewInsertedProductId = ProductId, @NewInsertedQuantity = Quantity
			from inserted

			-- storing the parameters of the entry to be Original Orders
			Declare @OldOrdersOrderId int, @OldOrdersProductId int, @OldOrdersQuantity int
			Select @OldOrdersOrderId = OrderId, @OldOrdersProductId = ProductId, @OldOrdersQuantity = Quantity
			from tblOrders

			-- if OrderId is updated
			if(Update(OrderId))
			Begin
				Raiserror('Id cannot be changed', 16, 1)
				Return
			End
 
			if(Update(CustomerId))
			Begin
				Update tblOrders set CustomerId = inserted.CustomerId
				from inserted
				join tblOrders
				on tblOrders.OrderId = inserted.OrderId
			End
	
			if(Update(SalesPersonId))
			Begin
				Update tblOrders set SalesPersonId = inserted.SalesPersonId
				from inserted
				join tblOrders
				on tblOrders.OrderId = inserted.OrderId
			End
	
			-- if you choose a different product or a different quantity
			if(Update(ProductId) OR Update(Quantity))
			Begin
				if(@NewInsertedProductId < 1000000) -- if Product = Car Accessories Stock
				begin
				--------- Old ORDER Item = from tblOrders ------------------------------------------------------------------------------------------------------------------------------------------------------------
					-- check old order in terms of Stock Replenishment List -------------------------------------------------------------------------------------
					-- new Stock Replenishment List Item order if the stock is lower than Minimum Stock Quantity and doesn't exist yet -------------------
					-- delete Stock Replenishment List Item order if the stock is lower than Minimum Stock Quantity and not yet ordered status -------------------
					if
						(
							-- the Quantity Of Stock is lower than Minimum Stock Quantity
							(((Select QuantityOfStock from tblCarAccessoriesStock where CASId = @OldOrdersProductId) + (@OldOrdersQuantity)) < (Select MinimumStockQuantity from tblCarAccessoriesStock where CASId = @OldOrdersOrderId))
							and
							-- ProductId not included AND with "0" ordered status in the Stock Replenishment List 
							((select COUNT(DISTINCT ProductId) from tblStockReplenishmentList where ProductId = @OldOrdersProductId and OrderedStatus = 0) = 0)
						)
					begin
						insert into tblStockReplenishmentList (ProductId, OrderedStatus, SRLTimeStamp) values(@OldOrdersProductId, 0, @DT)
					end
					else
					begin
						Delete tblStockReplenishmentList
						from tblStockReplenishmentList 
						join tblOrders
						on tblStockReplenishmentList.ProductId = tblOrders.ProductId
						where OrderedStatus = 0
					end

					-- adding an old order (= data from the table tblOrders) quantity with an old identifier to the registry set
					Update tblCarAccessoriesStock set QuantityOfStock = tblCarAccessoriesStock.QuantityOfStock + tblOrders.Quantity
					from tblCarAccessoriesStock 
					join tblOrders
					on tblOrders.ProductId = tblCarAccessoriesStock.CASId

				--------- New ORDER Item = from Inserted ------------------------------------------------------------------------------------------------------------------------------------------------------------
					-- check new order in terms of Stock Replenishment List -------------------------------------------------------------------------------------
					-- new Stock Replenishment List Item order if the stock is lower than Minimum Stock Quantity and doesn't exist yet -------------------
					-- delete Stock Replenishment List Item order if the stock is lower than Minimum Stock Quantity and not yet ordered status -------------------
					if
						(
							-- the Quantity Of Stock is lower than Minimum Stock Quantity
							(((Select QuantityOfStock from tblCarAccessoriesStock where CASId = @NewInsertedProductId) - (@NewInsertedQuantity)) < (Select MinimumStockQuantity from tblCarAccessoriesStock where CASId = @NewInsertedOrderId))
							and
							-- ProductId not included AND with "0" ordered status in the Stock Replenishment List 
							((select COUNT(DISTINCT ProductId) from tblStockReplenishmentList where ProductId = @NewInsertedProductId and OrderedStatus = 0) = 0)
						)
					begin
						insert into tblStockReplenishmentList (ProductId, OrderedStatus, SRLTimeStamp) values(@NewInsertedProductId, 0, @DT)
					end
					else
					begin
						Delete tblStockReplenishmentList
						from tblStockReplenishmentList 
						join inserted
						on tblStockReplenishmentList.ProductId = inserted.ProductId
						where OrderedStatus = 0
					end

					-- deducting a new order (= data from the inserted) quantity with a new identifier from the stock
					Update tblCarAccessoriesStock set QuantityOfStock = tblCarAccessoriesStock.QuantityOfStock - inserted.Quantity
					from tblCarAccessoriesStock 
					join inserted
					on tblCarAccessoriesStock.CASId = inserted.ProductId

					-- the quantity in the table tblOrders is updated
					if(Update(Quantity))
					Begin
						Update tblOrders set Quantity = inserted.Quantity
						from inserted
						join tblOrders
						on tblOrders.OrderId = inserted.OrderId

						-- tblShoppingCart UPDATE
						-- if I update the order quantity in the orders table, I also update it in the shopping cart table
						-- ha frissítem a rendelések táblázatban a rendelési mennyiséget, akkor a bevásárlókosár táblázatban is frissítek
						Update tblShoppingCart set Quantity = inserted.Quantity
						from inserted
						join tblShoppingCart
						on tblShoppingCart.ShoppingCartOrderId = inserted.ShoppingCartOrderId
					End
				end		
				Else -- if Product = Car -- we do not update the sales volume of the car, but we can exchange the car for another one
				begin
					-- the old identifier sold is reset to 0
					Update tblCars set Sold = 0
					from tblCars 
					join tblOrders
					on tblCars.CarId = tblOrders.ProductId

					-- the sold value of the new identifier is updated to 1
					Update tblCars set Sold = 1
					from inserted 
					join tblCars
					on tblCars.CarId = inserted.ProductId
				end
		
				-- the product ID in the table tblOrders is updated
				if(Update(ProductId))
				Begin
					Update tblOrders set ProductId = inserted.ProductId
					from inserted
					join tblOrders
					on tblOrders.OrderId = inserted.OrderId

					-- tblShoppingCart UPDATE
					-- if I update the product in the orders table, I also update it in the shopping cart table
					-- ha frissítem a rendelések táblázatban a terméket, akkor a bevásárlókosár táblázatban is frissítek
					Update tblShoppingCart set ProductId = inserted.ProductId
					from inserted
					join tblShoppingCart
					on tblShoppingCart.ShoppingCartOrderId = inserted.ShoppingCartOrderId
				End
			End
	
			if(Update(OrderStatusId))
			Begin
				Update tblOrders set OrderStatusId = inserted.OrderStatusId
				from inserted
				join tblOrders
				on tblOrders.OrderId = inserted.OrderId
			End
	
			if(Update(Discount))
			Begin
				Update tblOrders set Discount = inserted.Discount
				from inserted
				join tblOrders
				on tblOrders.OrderId = inserted.OrderId
			End
	
			if(Update(ShippedDate))
			Begin
				Update tblOrders set ShippedDate = inserted.ShippedDate
				from inserted
				join tblOrders
				on tblOrders.OrderId = inserted.OrderId
			End
	
			if(Update(SaleAmountPaid))
			Begin
				Update tblOrders set SaleAmountPaid = inserted.SaleAmountPaid
				from inserted
				join tblOrders
				on tblOrders.OrderId = inserted.OrderId
			End
	
			if(Update(TaxPercentageValue))
			Begin
				Update tblOrders set TaxPercentageValue = inserted.TaxPercentageValue
				from inserted
				join tblOrders
				on tblOrders.OrderId = inserted.OrderId
			End
	
			if(Update(SaleTime))
			Begin
				Update tblOrders set SaleTime = inserted.SaleTime
				from inserted
				join tblOrders
				on tblOrders.OrderId = inserted.OrderId
			End

			if(Update(ShoppingCartOrderId))
			Begin
				Update tblOrders set ShoppingCartOrderId = inserted.ShoppingCartOrderId
				from inserted
				join tblOrders
				on tblOrders.OrderId = inserted.OrderId
			End
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go




----- View, update, delete, insert Triggers --------------------------------------------------
Create or Alter View vWStockReplenishmentListAllData
as
Select SRLId, ProductId, ProductName, OrderedStatus, SRLTimeStamp 
from	tblStockReplenishmentList
join	tblCarAccessories
on		tblCarAccessories.CAId = tblStockReplenishmentList.ProductId
go
------------------------ Insert -------------------------------------------------------------
CREATE or Alter Trigger tr_vWStockReplenishmentListAllDetails_InsteadOfInsert
on vWStockReplenishmentListAllData
Instead Of Insert
as
Begin
	BEGIN TRY  
--		Begin tran
			SET IDENTITY_INSERT dbo.tblStockReplenishmentList ON

			Insert into tblStockReplenishmentList(SRLId, ProductId, OrderedStatus)
			Select SRLId, ProductId, OrderedStatus
			from inserted

			SET IDENTITY_INSERT dbo.tblStockReplenishmentList OFF
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------------------------- DELETE -------------------------------------------------------------
CREATE or Alter Trigger tr_vWStockReplenishmentListAllDetails_InsteadOfDelete
on vWStockReplenishmentListAllData
Instead Of DELETE
as
Begin
	BEGIN TRY  
--		Begin tran
			Delete tblStockReplenishmentList 
			from tblStockReplenishmentList
			join deleted
			on tblStockReplenishmentList.SRLId = deleted.SRLId
--		Commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------------------------- Update -------------------------------------------------------------
Create Or Alter Trigger tr_vWStockReplenishmentListAllDetails_InsteadOfUpdate
on vWStockReplenishmentListAllData
instead of update
as
Begin
	BEGIN TRY  
 --   Begin tran
		if(Update(SRLId))
		Begin
			Raiserror('Id cannot be changed', 16, 1)
			Return
		End
 
		if(Update(ProductId))
		Begin
			Update tblStockReplenishmentList set ProductId = inserted.ProductId
			from inserted
			join tblStockReplenishmentList
			on tblStockReplenishmentList.SRLId = inserted.SRLId
		End
	
		if(Update(OrderedStatus))
		Begin
			Update tblStockReplenishmentList set OrderedStatus = inserted.OrderedStatus
			from inserted
			join tblStockReplenishmentList
			on tblStockReplenishmentList.SRLId = inserted.SRLId
		End
	
		if(Update(SRLTimeStamp))
		Begin
			Update tblStockReplenishmentList set SRLTimeStamp = inserted.SRLTimeStamp
			from inserted
			join tblStockReplenishmentList
			on tblStockReplenishmentList.SRLId = inserted.SRLId
		End
--	commit tran
	END TRY  
	BEGIN CATCH  
--		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

------- Stored Procedure ------------------------------------------------------------------------
go
------ Orders SEARCH ------------------------------------------------------------------------------
Create or alter Procedure spOrdersSearchDynamicSQL
@OrderId int = NULL, 
@CustomerId int = NULL,
@CustomerFirstName nvarchar(50) = NULL, 
@CustomerLastName nvarchar(50) = NULL,
@SalesPersonId int = NULL,
@SalesPersonFirstName nvarchar(50) = NULL, 
@SalesPersonLastName nvarchar(50) = NULL,
@ProductId int = NULL,
@ProductGroup nvarchar(50) = NULL, 
@ProductName nvarchar(50) = NULL, 
@CarModel nvarchar(50) = NULL,
@CarColor nvarchar(50) = NULL,
@Quantity int = NULL,
@OrderDate datetime2 = NULL,
@OrderStatusId int = NULL,
@OrderStatusName nvarchar(50) = NULL, 
@Discount float = NULL,
@ShippedDate datetime2 = NULL,
@SaleAmount float = NULL,
@SaleAmountPaid float = NULL,
@TaxPercentageValue float = NULL,
@SaleTime datetime2 = NULL,
@ShoppingCartOrderId int = NULL,
@ShoppingCartStatusName nvarchar(50) = NULL
As
Begin
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)
 
				Set @sql = 'Select OrderId, tblOrders.CustomerId, tblCustomer.FirstName as CustomerFirstName, tblCustomer.LastName as CustomerLastName, 
							tblOrders.SalesPersonId, tblSalespersons.FirstName as SalesPersonFirstName, tblSalespersons.LastName as SalesPersonLastName, 
							tblOrders.ProductId, ISNULL(tblCarAccessoriesProductGroup.CAPGName, @AV) as ProductGroup, 
							ISNULL(tblCarAccessories.ProductName, @Au) as ProductName,
							ISNULL(tblCars.Model, @VVA) as CarModel, ISNULL(tblCars.Color, @AZ) as CarColor, 
							tblOrders.Quantity, OrderDate, tblOrderStatus.OrderStatusId, OrderStatusName, tblOrders.Discount, ShippedDate, tblOrders.SaleAmount, 
							tblOrders.SaleAmountPaid, TaxPercentageValue, SaleTime, tblOrders.ShoppingCartOrderId, tblShoppingCartStatus.ShoppingCartStatusName
							FROM		tblOrders
							JOIN		tblOrderStatus
							ON			tblOrders.OrderStatusId = tblOrderStatus.OrderStatusId
							JOIN		tblSalespersons
							ON			tblOrders.SalesPersonId = tblSalespersons.SalesId
							JOIN		tblCustomer
							ON			tblOrders.CustomerId = tblCustomer.CustomerId
							LEFT JOIN	tblCars
							ON			tblOrders.ProductId = tblCars.CarId
							LEFT JOIN	tblCarAccessories
							ON			tblOrders.ProductId = tblCarAccessories.CAId
							LEFT JOIN	tblCarAccessoriesProductGroup
							ON			tblCarAccessories.ProductGroupId = tblCarAccessoriesProductGroup.CAPGId
							LEFT JOIN	tblShoppingCart
							ON			tblShoppingCart.ShoppingCartOrderId = tblOrders.ShoppingCartOrderId
							LEFT JOIN	tblShoppingCartStatus
							ON			tblShoppingCart.ShoppingCartStatusId = tblShoppingCartStatus.ShoppingCartStatusId
							where 1 = 1'
     
			 if(@OrderId is not null)
				  Set @sql = @sql + ' and OrderId=@OI'
			 if(@CustomerId is not null)
				  Set @sql = @sql + ' and tblOrders.CustomerId=@CI'    
			 if(@CustomerFirstName is not null)
				  Set @sql = @sql + ' and tblCustomer.FirstName like(@CFN + @PS)'    
			 if(@CustomerLastName is not null)
				  Set @sql = @sql + ' and tblCustomer.LastName like(@CLN + @PS)'  
			 if(@SalesPersonId is not null)
				  Set @sql = @sql + ' and tblOrders.SalesPersonId=@SPI'      
			 if(@SalesPersonFirstName is not null)
				  Set @sql = @sql + ' and tblSalespersons.FirstName like(@SPFN + @PS)'    
			 if(@SalesPersonLastName is not null)
				  Set @sql = @sql + ' and tblSalespersons.LastName like(@SPLN + @PS)'  
			 if(@ProductId is not null)
				  Set @sql = @sql + ' and tblOrders.ProductId=@PrI'		  
			 if(@ProductGroup is not null)
				  Set @sql = @sql + ' and tblCarAccessoriesProductGroup.CAPGName like(@PG + @PS)'
			 if(@ProductName is not null)
				  Set @sql = @sql + ' and tblCarAccessories.ProductName like(@PN + @PS)'  
			 if(@CarModel is not null)
				  Set @sql = @sql + ' and tblCars.Model like(@CM + @PS)'  	  
			 if(@CarColor is not null)
				  Set @sql = @sql + ' and tblCars.Color like(@CC + @PS)'  
			 if(@Quantity is not null)
				  Set @sql = @sql + ' and tblOrders.Quantity=@Qa'
			 if(@OrderDate is not null)
				  Set @sql = @sql + ' and OrderDate like(@OD + @PS)'
			 if(@OrderStatusId is not null)
				  Set @sql = @sql + ' and tblOrders.OrderStatusId=@OSI'     
			 if(@OrderStatusName is not null)
				  Set @sql = @sql + ' and OrderStatusName like(@OSN + @PS)'    
			if(@Discount is not null)
				  Set @sql = @sql + ' and tblOrders.Discount=@Di'
			if(@ShippedDate is not null)
				  Set @sql = @sql + ' and ShippedDate like(@SD + @PS)'
			if(@SaleAmount is not null)
				  Set @sql = @sql + ' and tblOrders.SaleAmount=@SA'
			if(@SaleAmountPaid is not null)
				  Set @sql = @sql + ' and SaleAmountPaid=@SAP'
			if(@TaxPercentageValue is not null)
				  Set @sql = @sql + ' and TaxPercentageValue=@TPAV'
			if(@SaleTime is not null)
				  Set @sql = @sql + ' and SaleTime like(@ST + @PS)'
			if(@ShoppingCartOrderId is not null)
				  Set @sql = @sql + ' and tblOrders.ShoppingCartOrderId=@SCOI'    
			 if(@ShoppingCartStatusName is not null)
				  Set @sql = @sql + ' and tblShoppingCartStatus.ShoppingCartStatusName like(@SCSN + @PS)'  
			 Execute sp_executesql @sql,
			 N'@OI int, @CI int, @CFN nvarchar(50), @CLN nvarchar(50), @SPI int, @SPFN nvarchar(50), @SPLN nvarchar(50), 
			 @PrI int, @PG nvarchar(50), @PN nvarchar(50), @CM nvarchar(50), @CC nvarchar(50), @Qa int, @OD datetime2, 
			 @OSI int, @OSN nvarchar(50), @Di float, @SD datetime2, @SA float, @SAP float, @TPAV float, @ST datetime2,
			 @SCOI int, @SCSN nvarchar(50),
			 @AV nvarchar(11), @Au nvarchar(4), @VVA nvarchar(21), @AZ nvarchar(11), @PS nvarchar(1)',
			 @OI=@OrderId, @CI=@CustomerId, @CFN=@CustomerFirstName, @CLN=@CustomerLastName,
			 @SPI=@SalesPersonId, @SPFN=@SalesPersonFirstName, @SPLN=@SalesPersonLastName, @PrI=@ProductId,
			 @PG=@ProductGroup, @PN=@ProductName, @CM=@CarModel, @CC=@CarColor, @Qa=@Quantity, @OD=@OrderDate, 
			 @OSI=@OrderStatusId, @OSN=@OrderStatusName, @Di=@Discount, @SD=@ShippedDate, @SA=@SaleAmount, 
			 @SAP=@SaleAmountPaid, @TPAV=@TaxPercentageValue, @ST=@SaleTime, @SCOI=@ShoppingCartOrderId, @SCSN=@ShoppingCartStatusName,
			 @AV='Autoverkauf', @Au='Auto', @VVA='VerkaufVonAutozubehör', @AZ='Autozubehör', @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ Orders Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spOrdersUpdateOrInsert
@OrderId int = NULL, 
@CustomerId int = NULL,
@CustomerFirstName nvarchar(50) = NULL, 
@CustomerLastName nvarchar(50) = NULL,
@SalesPersonId int = NULL,
@SalesPersonFirstName nvarchar(50) = NULL, 
@SalesPersonLastName nvarchar(50) = NULL,
@ProductId int = NULL,
@ProductGroup nvarchar(50) = NULL, 
@ProductName nvarchar(50) = NULL, 
@CarModel nvarchar(50) = NULL,
@CarColor nvarchar(50) = NULL,
@Quantity int = NULL,
@OrderDate datetime2 = NULL,
@OrderStatusId int = NULL,
@OrderStatusName nvarchar(50) = NULL, 
@Discount float = NULL,
@ShippedDate datetime2 = NULL,
@SaleAmount float = NULL,
@SaleAmountPaid float = NULL,
@TaxPercentageValue float = NULL,
@SaleTime datetime2 = NULL,
@ShoppingCartOrderId int = NULL,
@ShoppingCartStatusName nvarchar(50) = NULL
AS
Begin
	Begin Try
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		begin tran
			-- if you already have this order and the stock is greater than or equal to the order quantity or the car is not sold
			if (
					(exists (select * from vWOrdersAllData with (updlock,serializable) where OrderId = @OrderId)) 
					and 
					(
						((Select QuantityOfStock From tblCarAccessoriesStock where CASId = @ProductId) >= (@Quantity - (Select Quantity from tblOrders where OrderId = @OrderId))) 
						or
						((select Sold from tblCars where CarId = @ProductId) = 0)
					)
				)
			begin
				update vWOrdersAllData set CustomerId = @CustomerId, CustomerFirstName = @CustomerFirstName, 
				CustomerLastName = @CustomerLastName, SalesPersonId = @SalesPersonId, SalesPersonFirstName = @SalesPersonFirstName, 
				SalesPersonLastName = @SalesPersonLastName, ProductId = @ProductId, ProductGroup = @ProductGroup, ProductName = @ProductName, 
				CarModel = @CarModel, CarColor = @CarColor, Quantity = @Quantity, OrderDate = @OrderDate, OrderStatusId = @OrderStatusId, 
				OrderStatusName = @OrderStatusName, Discount = @Discount, ShippedDate = @ShippedDate, SaleAmount = @SaleAmount, 
				SaleAmountPaid = @SaleAmountPaid, TaxPercentageValue = @TaxPercentageValue, SaleTime = @SaleTime, 
				ShoppingCartOrderId = @ShoppingCartOrderId, ShoppingCartStatusName = @ShoppingCartStatusName
				where OrderId = @OrderId
			end

			-- if the stock is greater than or equal to the order quantity or the car is not sold
			else if (
						((Select QuantityOfStock From tblCarAccessoriesStock where CASId = @ProductId) >= @Quantity) 
						or
						((select Sold from tblCars where CarId = @ProductId) = 0)
					)
			begin
				if(@OrderId is not Null)
				begin
					insert into vWOrdersAllData values (@OrderId, @CustomerId, @CustomerFirstName, @CustomerLastName, @SalesPersonId, 
					@SalesPersonFirstName, @SalesPersonLastName, @ProductId, @ProductGroup, @ProductName, @CarModel, @CarColor, @Quantity, 
					@OrderDate, @OrderStatusId, @OrderStatusName, @Discount, @ShippedDate, @SaleAmount, 
					@SaleAmountPaid, @TaxPercentageValue, @SaleTime, @ShoppingCartOrderId, @ShoppingCartStatusName)
				end
				else
				begin
					insert into vWOrdersAllData values (IDENT_CURRENT('tblOrders')+1 , @CustomerId, @CustomerFirstName, 
					@CustomerLastName, @SalesPersonId, @SalesPersonFirstName, @SalesPersonLastName, @ProductId, @ProductGroup, 
					@ProductName, @CarModel, @CarColor, @Quantity, @OrderDate, @OrderStatusId, @OrderStatusName, @Discount, 
					@ShippedDate, @SaleAmount, @SaleAmountPaid, @TaxPercentageValue, @SaleTime, @ShoppingCartOrderId, @ShoppingCartStatusName)
				end			
			end

			Else
			Begin
				Raiserror('Not enough in stock. Statement terminated', 16, 1)
			end
		commit tran	
	End Try
    Begin Catch 
		Rollback Transaction
		EXECUTE usp_GetErrorInfo
    End Catch 
End
go
------ Orders Delete ---------------------------------------------------------------------
Create or alter Procedure spOrdersDelete
@OrderId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@OrderId is not Null)
			begin
				Delete from [dbo].[vWOrdersAllData] where OrderId = @OrderId
			end
			else
			begin
				Print 'OrderId is not found ' + @OrderId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ OrderStatus SEARCH ---------------------------------------------------------------------
Create or alter Procedure spOrderStatusSearchDynamicSQL
@OrderStatusId int = NULL,
@OrderStatusName nvarchar(50) = NULL
As
Begin
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)
			  
			 Set @sql = 'Select OrderStatusId, OrderStatusName 
						from tblOrderStatus 
						where 1 = 1'
    		 if(@OrderStatusId is not null)
				  Set @sql = @sql + ' and @OrderStatusId=@OSI'

			 if(@OrderStatusName is not null)
				  Set @sql = @sql + ' and OrderStatusName like(@OSN + @PS)'
     
			 Execute sp_executesql @sql,
			 N'@OSI int, @OSN nvarchar(50), @PS nvarchar(1)',
			 @OSI=@OrderStatusId, @OSN=@OrderStatusName, @PS='%'			 
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ OrderStatus Update Or Insert ---------------------------------------------------------------------
Create or alter Procedure spOrderStatusUpdateOrInsert
@OrderStatusId int = NULL,
@OrderStatusName nvarchar(50) = NULL
AS
Begin
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		begin tran
			if (exists (select * from tblOrderStatus with (updlock,serializable) where OrderStatusId = @OrderStatusId))
				begin
				   update tblOrderStatus set OrderStatusName = @OrderStatusName
				   where OrderStatusId = @OrderStatusId
				end
				else
				begin
					if(@OrderStatusId is not Null)
					begin
						SET IDENTITY_INSERT dbo.tblOrderStatus ON
						insert into tblOrderStatus (OrderStatusId, OrderStatusName) values (@OrderStatusId , @OrderStatusName)
						SET IDENTITY_INSERT dbo.tblOrderStatus OFF
					end
					else
					begin
						SET IDENTITY_INSERT dbo.tblOrderStatus ON
						insert into tblOrderStatus (OrderStatusId, OrderStatusName) values (IDENT_CURRENT('tblOrderStatus')+1 , @OrderStatusName)
						SET IDENTITY_INSERT dbo.tblOrderStatus OFF
					end
				end
		commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ OrderStatus Delete ---------------------------------------------------------------------
Create or alter Procedure spOrderStatusDelete
@OrderStatusId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@OrderStatusId is not Null)
			begin 
				Delete from [dbo].[tblOrderStatus] where OrderStatusId = @OrderStatusId
			end
			else
			begin
				Print 'OrderStatusId is not found ' + @OrderStatusId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

------ StockReplenishmentList SEARCH ----------------------------------------------------------------------
Create or alter Procedure spStockReplenishmentListSearchDynamicSQL
@SRLId int = Null,
@ProductId int = Null,
@ProductName nvarchar(50) = NULL,
@OrderedStatus bit = NULL,
@SRLTimeStamp datetime2  = NULL
As
Begin
	BEGIN TRY  
		Begin tran
			 Declare @sql nvarchar(max)
			 Declare @sqlParams nvarchar(max)

			 Set @sql = 'Select SRLId, ProductId, ProductName, OrderedStatus, SRLTimeStamp
						from	tblStockReplenishmentList
						join	tblCarAccessories
						on		tblCarAccessories.CAId = tblStockReplenishmentList.ProductId
						where 1 = 1'
    
			 if(@SRLId is not null)
				  Set @sql = @sql + ' and SRLId=@SRLI'
     
			 if(@ProductId is not null)
				  Set @sql = @sql + ' and ProductId=@PI'
     
			 if(@ProductName is not null)
				  Set @sql = @sql + ' and ProductName like(@PN + @PS)'
     
			 if(@OrderedStatus is not null)
				  Set @sql = @sql + ' and OrderedStatus=@OS'
     
			 if(@SRLTimeStamp is not null)
				  Set @sql = @sql + ' and SRLTimeStamp=@SRLTS'
     
			 Execute sp_executesql @sql,
			 N'@SRLI int, @PI int, @PN nvarchar(50), @OS bit, @SRLTS datetime2, @PS nvarchar(1)',
			 @PN=@ProductName, @PI=@ProductId, @SRLI=@SRLId, @OS=@OrderedStatus, @SRLTS=@SRLTimeStamp, @PS='%'
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
------ StockReplenishmentList Update or Insert / the insertion is automatically generated when the inventory falls below a specified value / ---------
Create or alter Procedure spStockReplenishmentListUpdateOrInsert
@SRLId int = Null,
@ProductId int = NULL,
@OrderedStatus bit = NULL
AS
Begin
BEGIN TRY  
   	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	begin tran
		if (exists (select * from tblStockReplenishmentList with (updlock,serializable) where SRLId = @SRLId))
			begin
			   update vWStockReplenishmentListAllData set ProductId = @ProductId, OrderedStatus = @OrderedStatus
			   where SRLId = @SRLId
			end
			else
			begin
				if(@SRLId is not Null)
				begin
					insert into vWStockReplenishmentListAllData (SRLId, ProductId, OrderedStatus) 
					values (@SRLId, @ProductId, @OrderedStatus)
				end
				else
				begin
					insert into vWStockReplenishmentListAllData (SRLId, ProductId, OrderedStatus) 
					values (IDENT_CURRENT('tblStockReplenishmentList')+1 , @ProductId, @OrderedStatus)
				end
			end
	commit tran
END TRY  
BEGIN CATCH  
	Rollback Transaction
    -- Execute error retrieval routine.  
    EXECUTE usp_GetErrorInfo;  
END CATCH
End
go
------ StockReplenishmentList Delete ----------------------------------------------------------------------
Create or alter Procedure spStockReplenishmentListDelete
@SRLId int
AS
BEGIN
	BEGIN TRY  
	  -- SERIALIZABLE full blocking until finalization
	  -- blocked Dirty Reads, Nonrepeatable Reads, Phantom Reads, Missing / Double Reads	  
	  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		Begin tran
			if (@SRLId is not Null)
			begin
				Delete from [dbo].[tblStockReplenishmentList] where SRLId = @SRLId
			end
			else
			begin
				Print 'StockReplenishmentListId is not found ' + @SRLId
			END
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go






------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------- tblLogin ------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------


Create Table tblLogin
	(
 	  LoginId INT IDENTITY (1, 1) PRIMARY KEY,
 	  UserId INT,
	  UserName nvarchar(100),
	  Password nvarchar(100),
	  UserEmail nvarchar(100),
	  LoginTimestamp datetime2, 
	  CounterOfFailedLoginAttempts INT 
	 -- CONSTRAINT [Unique User Name Violation] UNIQUE NONCLUSTERED 
		--(
		--	UserName ASC
		--),
	  CONSTRAINT [Unique User Email Violation] UNIQUE NONCLUSTERED 
		(
			UserEmail ASC
		)
	)
go

---- Audit tblLogin ----------------------------------------------------------------
CREATE TABLE tblLoginAudit
(
  LoginAuditId int identity(1,1) primary key,
  AuditData nvarchar(1000)
)
go
-------- Insert Audit tblLogin ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblLogin_ForInsert
ON tblLogin
FOR INSERT
AS
Begin
	BEGIN TRY  
			 Declare @Id int
			 Select @Id = LoginId from inserted
			  insert into tblLoginAudit 
			 values('New Login with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is added at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())	 
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------- Delete Audit tblLogin ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblLogin_ForDelete
ON tblLogin
FOR DELETE
AS
Begin
	BEGIN TRY  
			 Declare @Id int
			 Select @Id = LoginId from deleted 
			  insert into tblLoginAudit 
			 values('An existing Login with Id  = ' + Cast(@Id as nvarchar(5)) + 
					' is deleted at ' + cast(Getdate() as nvarchar(20)) +
					' Login Name = ' + ORIGINAL_LOGIN())
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go
-------- Update Audit tblLogin ----------------------------------------------------------------
CREATE OR ALTER TRIGGER tr_tblLogin_ForUpdate
ON tblLogin
for Update
as
Begin
	BEGIN TRY  
			  Declare @Id int 
			  Declare @OldUserId int, @NewUserId int
			  Declare @OldUserName nvarchar(100), @NewUserName nvarchar(100)
			  Declare @OldPassword nvarchar(100), @NewPassword nvarchar(100)
			  Declare @OldUserEmail nvarchar(100), @NewUserEmail nvarchar(100)

			  Declare @AuditString nvarchar(1000)
      
			  Select *
			  into #TempTable 
			  from inserted
     
			  While(Exists(Select LoginId from #TempTable))
			  Begin
					Set @AuditString = ''
					Select Top 1 @Id = LoginId, 
						@OldUserId  = UserId,
						@OldUserName = UserName,
						@OldPassword = Password,
						@OldUserEmail = UserEmail
					from #TempTable
					Select 
						@NewUserId = UserId,
						@NewUserName = @NewUserName,
						@NewPassword = Password,
						@NewUserEmail = UserEmail

					from deleted where LoginId = @Id
					Set @AuditString = 'Login with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'

					if(@OldUserId <> @NewUserId)
						  Set @AuditString = @AuditString + ' User Id from ' + Cast(@OldUserId as nvarchar(10)) + 
						  ' to ' + Cast(@NewUserId as nvarchar(10))
            
					if(@OldUserName <> @NewUserName)
						  Set @AuditString = @AuditString + ' User Name from ' + @OldUserName + ' to ' + @NewUserName

					if(@OldPassword <> @NewPassword)
						  Set @AuditString = @AuditString + ' Password from ' + @OldPassword + ' to ' + @NewPassword
				  
					if(@OldUserEmail <> @NewUserEmail)
						  Set @AuditString = @AuditString + ' User Email from ' + @OldUserEmail + ' to ' + @NewUserEmail

					Set @AuditString = @AuditString + ' is updated at ' + cast(Getdate() as nvarchar(20)) + ' Login Name = ' + ORIGINAL_LOGIN()
		   
					insert into tblOrdersAudit values(@AuditString)
            
					Delete from #TempTable where LoginId = @Id
			  End
	END TRY  
	BEGIN CATCH  
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
End
go

CREATE OR ALTER Trigger tr_tblLogin_Timestamp
on tblLogin for insert
as 
begin
	update tblLogin 
	set LoginTimestamp = getdate()
	from Inserted 
	where tblLogin.LoginId=Inserted.LoginId
end
go


Create or alter Procedure spEmailUpload
@UserEmail nvarchar(50)
AS
BEGIN
	BEGIN TRY  
		Begin tran
				insert into dbo.tblLogin values(null, null, null, @UserEmail, NULL, NULL)
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

Create or alter Procedure spEmailUploadFromAlterData
AS
BEGIN
	BEGIN TRY  
		Begin tran
		Declare @a int

		
		Declare @CounterSalesId int
		Set @CounterSalesId = Cast((select count(SalesId) from tblSalespersonsSecretData) as int)
		Set @a = 1
			while @a < @CounterSalesId 
			Begin
				Declare @emails nvarchar(50)
				Set @emails = cast((select Email from tblSalespersonsSecretData where SalesId = @a) as nvarchar(50))
				insert into dbo.tblLogin values(@a, null, null, @emails, NULL, NULL)
				Set @a = @a + 1
			End

		Declare @CounterCustomer int
		Set @CounterCustomer = Cast((select count(CustomerId) from tblCustomer) as int) + 1000
		Set @a = 1000
			while @a < @CounterCustomer 
			Begin
				Declare @email nvarchar(50)
				Set @email = cast((select Email from tblCustomer where CustomerId = @a) as nvarchar(50))
				insert into dbo.tblLogin values(@a, null,null,  @email, NULL, NULL)
				Set @a = @a + 1
			End
		
		Commit tran
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go

Create or alter Procedure spSetUserId
@UserEmail nvarchar(50),
@UserId int output
AS
BEGIN
	BEGIN TRY  
		-- If the email address is in the list
		if((select count(UserEmail) from tblLogin where UserEmail = @UserEmail) > 0)
		begin
			-- If the e-mail address is included among the sellers
			if((Select count(SalesId) from tblSalespersonsSecretData where Email = @UserEmail) > 0)
			begin
				Set @UserId = (Select SalesId from tblSalespersonsSecretData where Email = @UserEmail)
			end
			-- If the email address is included among the customers
			else
			begin
				Set @UserId = (Select CustomerId from tblCustomer where Email = @UserEmail)
			end
		end
	END TRY  
	BEGIN CATCH  
		Rollback Transaction
		-- Execute error retrieval routine.  
		EXECUTE usp_GetErrorInfo  
	END CATCH
END
go






------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------Data Upload-------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- tblShoppingCartStatus Data uploading
insert into tblShoppingCartStatus values ('Im Einkaufswagen')
insert into tblShoppingCartStatus values ('Bestellt')
insert into tblShoppingCartStatus values ('Für später gespeichert')
insert into tblShoppingCartStatus values ('Unterwegs')
insert into tblShoppingCartStatus values ('Zugestellt')


-- tblGearbox Data uploading
Insert into tblGearbox values ('manual')
Insert into tblGearbox values ('automat')
Insert into tblGearbox values ('Es gibt keine')


-- tblCountry DATA uploading
Insert into tblCountry values ('Albanien', 20)
Insert into tblCountry values ('Andorra', 4.5)
Insert into tblCountry values ('Armenia', 20)
Insert into tblCountry values ('Belarus', 20)
Insert into tblCountry values ('Belgien', 21)
Insert into tblCountry values ('Bosnien und Herzegowina', 17)
Insert into tblCountry values ('Bulgarien', 20)
Insert into tblCountry values ('Dänemark', 25)
Insert into tblCountry values ('Deutschland', 19)
Insert into tblCountry values ('Estland', 20)
Insert into tblCountry values ('Finnland', 24)
Insert into tblCountry values ('Frankreich', 20)
Insert into tblCountry values ('Georgien', 18)
Insert into tblCountry values ('Griechenland', 24)
Insert into tblCountry values ('Irland', 23)
Insert into tblCountry values ('Island', 24)
Insert into tblCountry values ('Italien', 22)
Insert into tblCountry values ('Kasachstan', 20)
Insert into tblCountry values ('Kosovo', 20)
Insert into tblCountry values ('Kroatien', 25)
Insert into tblCountry values ('Lettland', 21)
Insert into tblCountry values ('Liechtenstein', 8)
Insert into tblCountry values ('Litauen', 21)
Insert into tblCountry values ('Luxemburg', 17)
Insert into tblCountry values ('Malta', 18)
Insert into tblCountry values ('Moldau', 20)
Insert into tblCountry values ('Monaco', 0)
Insert into tblCountry values ('Montenegro', 21)
Insert into tblCountry values ('Niederlande', 21)
Insert into tblCountry values ('Nordmazedonien', 18)
Insert into tblCountry values ('Norwegen', 25)
Insert into tblCountry values ('Österreich', 20)
Insert into tblCountry values ('Polen', 23)
Insert into tblCountry values ('Portugal', 23)
Insert into tblCountry values ('Rumänien', 19)
Insert into tblCountry values ('Russland', 20)
Insert into tblCountry values ('San Marino', 20)
Insert into tblCountry values ('Schweden', 25)
Insert into tblCountry values ('Schweiz', 8)
Insert into tblCountry values ('Serbien', 20)
Insert into tblCountry values ('Slowakei', 20)
Insert into tblCountry values ('Slowenien', 22)
Insert into tblCountry values ('Spanien', 21)
Insert into tblCountry values ('Tschechien', 21)
Insert into tblCountry values ('Türkei', 18)
Insert into tblCountry values ('Ukraine', 20)
Insert into tblCountry values ('Ungarn', 27)
Insert into tblCountry values ('Vereinigtes Königreich', 20)
Insert into tblCountry values ('Zypern', 19)
Insert into tblCountry values ('Andere', 20)


-- tblFuel Data uploading

Insert into tblFuel values ('Strom')
Insert into tblFuel values ('Benzin')
Insert into tblFuel values ('Diesel')
Insert into tblFuel values ('Erdgas')


-- tblSex DATA uploading

Insert into tblSex values ('männlich')
Insert into tblSex values ('weiblich')
Insert into tblSex values ('divers')
Insert into tblSex values ('inter')
Insert into tblSex values ('offen')
Insert into tblSex values ('kein Eintrag')


-- tblSpokenLanguages DATA uploading

Insert into tblSpokenLangues values ('Albanisch')
Insert into tblSpokenLangues values ('Arabisch')
Insert into tblSpokenLangues values ('Deutsch')
Insert into tblSpokenLangues values ('Englisch')
Insert into tblSpokenLangues values ('Finnisch')
Insert into tblSpokenLangues values ('Französisch')
Insert into tblSpokenLangues values ('Griechisch')
Insert into tblSpokenLangues values ('Italienisch')
Insert into tblSpokenLangues values ('Irisch')
Insert into tblSpokenLangues values ('Niederländisch')
Insert into tblSpokenLangues values ('Ukrainisch')
Insert into tblSpokenLangues values ('Ungarisch')
Insert into tblSpokenLangues values ('Polnisch')
Insert into tblSpokenLangues values ('Portugiesisch')
Insert into tblSpokenLangues values ('Rumänisch')
Insert into tblSpokenLangues values ('Russisch')
Insert into tblSpokenLangues values ('Schwedisch')
Insert into tblSpokenLangues values ('Slowakisch')
Insert into tblSpokenLangues values ('Slowenisch')
Insert into tblSpokenLangues values ('Spanisch')
Insert into tblSpokenLangues values ('Weißrussisch')
Insert into tblSpokenLangues values ('Andere Sprache')

-- tblCarAccessoriesUnit DATA uploading

Insert into tblCarAccessoriesUnit values ('€uro/Stück')
Insert into tblCarAccessoriesUnit values ('€uro/Liter')
Insert into tblCarAccessoriesUnit values ('€uro/Kilogram')


-- tblCarAccessoriesProductGroup DATA uploading

Insert into tblCarAccessoriesProductGroup values ('Autoinnenraum')
Insert into tblCarAccessoriesProductGroup values ('Autoreinigungs')
Insert into tblCarAccessoriesProductGroup values ('Winter-Autozubehör')
Insert into tblCarAccessoriesProductGroup values ('Straßennotfälle und Erste Hilfe')
Insert into tblCarAccessoriesProductGroup values ('Zubehör für Autotelefone')
Insert into tblCarAccessoriesProductGroup values ('Schutzausrüstung')
Insert into tblCarAccessoriesProductGroup values ('Unterhaltung im Auto')


-- tblOrderStatus DATA uploading

Insert into tblOrderStatus values ('Ausstehend') --Függőben
Insert into tblOrderStatus values ('Verarbeitung') --Feldolgozás alatt
Insert into tblOrderStatus values ('Abgelehnt') --Elutasítva
Insert into tblOrderStatus values ('Abgeschlossen') --Befejezve



-- tblCars Data uploading

Insert into tblCars values ('Ford','Silber', 5, '2013-10-20 15:09:12.1234567', 3, 1, 1765, 287355,'XFOW3AT152HhWNS9FF', 85, 1270, 0, 2700)
Insert into tblCars values ('Opel','Weis', 5, '2014-10-20 15:09:12.1234567', 3, 1,1670, 298603,'XFOW3AT612G54WNS9FF', 75, 1170, 0, 3500)
Insert into tblCars values ('Mercedes','Grün', 5, '2012-10-20 15:09:12.1234567', 2, 1,2002, 350355,'XFOW3EG56692GWNS9FF', 110, 1670, 0, 5100)
Insert into tblCars values ('BMW','Blau', 5, '2016-10-20 15:09:12.1234567', 2, 2,2500, 156478,'XFOW5GH125GW65NS9FF', 150, 1450, 0, 6200)
Insert into tblCars values ('Suzuki','Gelb', 5, '2018-10-20 15:09:12.1234567', 3, 1,1040, 150355,'XFOW3AT12563GWNS9FF', 61, 1120, 0, 4500)
Insert into tblCars values ('Citoen','Schwarz', 5, '2018-10-25 15:09:12.1234567', 2, 1,950, 84355,'XFOW3AT98573GWNS9FF', 54, 988, 0, 5300)
Insert into tblCars values ('Volkswagen','Pink', 5, '2020-10-20 15:09:12.1234567', 3, 2,1400, 25355,'XFOW3AT345253GWNS9FF', 66, 972, 0, 6250)
Insert into tblCars values ('Ford', 'grau', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'wf0utk1wsd421', 85, 1300, 0, 1800)
Insert into tblCars values ('Tesla', 'rot', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'we36xsgvf2656dfs2', 130, 1000, 0, 28000)
Insert into tblCars values ('Skoda', 'weiss', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'vs3daffew8sdf3', 57, 950, 0, 1500) 
Insert into tblCars values ('Ford', 'grau', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'wf0utk4wsd4ht21', 85, 1300, 0, 1800)
Insert into tblCars values ('Tesla', 'rot', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'we36xsgvf6556dfseh2', 130, 1000, 0, 28000)
Insert into tblCars values ('Skoda', 'weiss', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'vsda6ffertew8sdf3', 57, 950, 0, 1500)
Insert into tblCars values ('Audi', 'pink', 3, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 50000, 'srg55dfg721dfs4', 190, 1400, 0, 5200)
Insert into tblCars values ('Bmw', 'schwarz', 3, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 160000, 'dsfg8ds5fssgfsd65', 210, 1600, 0, 4500)
Insert into tblCars values ('Ford', 'lila', 5, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 86958, 'wf0utkwsd9436', 89, 1550, 0, 2300)
Insert into tblCars values ('Tesla', 'grau', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'we36x10sgvf656dfs7', 125, 1650, 0, 12000)
Insert into tblCars values ('Skoda', 'hellrot', 5, '1997-10-20 15:09:12.1234567', 3, 2, 4693, 214563, 'vsda11ffew8sdf8', 44, 1750, 0, 2300)
Insert into tblCars values ('Audi', 'weiss', 3, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 50000, 'srg55d12fg21dfs9', 120, 1850, 0, 3000)
Insert into tblCars values ('Bmw', 'dunkelpink', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 160000, 'dsfgd13s5fssgfsd710', 142, 1950, 0, 2800)
Insert into tblCars values ('Ford', 'schwarz', 3, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 26000, 'wf0utk14wsd4411', 100, 2050, 0, 4200)
Insert into tblCars values ('Polo', 'lila', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 16000, 'wf0utkwsd154312', 85, 1300, 0, 3700)
Insert into tblCars values ('A4', 'grau', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'we36xsgvf61656dfs13', 130, 1000, 0, 5600)
Insert into tblCars values ('Vectra', 'hellrot', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'vsdaf17few8sdf14', 57, 950, 0, 2900)
Insert into tblCars values ('Saxo', 'weiss', 3, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 109260, 'srg55dfg2118dfs15', 190, 1400, 0, 4800)
Insert into tblCars values ('Civic', 'dunkelpink', 5, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 106806, 'dsfgds195fssgfsd716', 210, 1600, 0, 3900)
Insert into tblCars values ('Primera', 'schwarz', 2, '2004-10-20 15:09:12.1234567', 3, 1, 3726, '104353', 'wf0utkw20sd4417', 89, 1550, 0, 6600)
Insert into tblCars values ('Focus', 'rot', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 0, 'we36xsgvf656df21s18', 125, 1650, 0, 8000)
Insert into tblCars values ('Passat', 'weiss', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 9944, 'vsdaffew8s22df19', 44, 1750, 0, 4200)
Insert into tblCars values ('C Class', 'pink', 3, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 363636, 'srg55dfg2123dfs20', 120, 1850, 0, 2900)
Insert into tblCars values ('Mondeo', 'schwarz', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 9453, 'dsfgds5fssgf24sd821', 142, 1950, 0, 3500)
Insert into tblCars values ('Skoda', 'lila', 3, '2007-10-20 15:09:12.1234567', 3, 2, 6143, 9208, 'wf0utkwsd425522', 100, 2050, 0, 4700)
Insert into tblCars values ('Audi', 'grau', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 89632, 'wf0utkwsd442263', 850, 1300, 0, 4400)
Insert into tblCars values ('Bmw', 'hellrot', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 30000, 'we36xsgvf65627dfs24', 130, 1000, 0, 9800)
Insert into tblCars values ('Ford', 'pink', 2, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 28000, 'vsdaf28few8sdf25', 57, 950, 0, 3000)
Insert into tblCars values ('Polo', 'schwarz', 5, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 20000, 'srg5295dfg21dfs26', 190, 1400, 0, 37000)
Insert into tblCars values ('A4', 'lila', 5, '2010-10-20 15:09:12.1234567', 3, 2, 4000, 25000, 'dsfgds5fs30sgfsd827', 210, 1600, 0, 1800)
Insert into tblCars values ('Vectra', 'grau', 5, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 27000, 'wf0utkw31sd4528', 89, 1550, 0, 28000)
Insert into tblCars values ('Saxo', 'hellrot', 2, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 27000, 'we36xsgv32f656dfs29', 125, 1650, 0, 1500)
Insert into tblCars values ('Civic', 'pink', 2, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 18000, 'vsdaffew833sdf30', 44, 1750, 0, 5200)
Insert into tblCars values ('Toyota', 'weiss', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'srg55dfg3421dfs31', 85, 1300, 0, 4500)
Insert into tblCars values ('BMW', 'dunkelpink', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'dsfgds534fssgfsd732', 130, 1000, 0, 2300)
Insert into tblCars values ('Mazda', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'wf0ut35kwsd4433', 57, 950, 0, 12000)
Insert into tblCars values ('Mercedes', 'lila', 5, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 50000, 'we36xsg36vf656dfs34', 190, 1400, 0, 2300)
Insert into tblCars values ('Opel', 'grau', 5, '2010-10-20 15:09:12.1234567', 3, 2, 4000, 160000, 'vsdaffew8sdf3735', 210, 1600, 0, 3000)
Insert into tblCars values ('Ferrari', 'hellrot', 3, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 86958, 'srg5385dfg21dfs36', 89, 1550, 0, 2800)
Insert into tblCars values ('Jaguar', 'weiss', 3, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'dsfgds5fs39sgfsd837', 125, 1650, 0, 4200)
Insert into tblCars values ('Maserati', 'dunkelpink', 5, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 214563, 'wf040utkwsd4238', 44, 1750, 0, 3700)
Insert into tblCars values ('Porsche', 'schwarz', 2, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 50000, 'wf0utkwsd441139', 120, 1850, 0, 5600)
Insert into tblCars values ('Vectra', 'rot', 5, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 160000, 'we36xsg42vf656dfs40', 142, 1950, 0, 2900)
Insert into tblCars values ('Saxo', 'weiss', 3, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 26000, 'vsdaffew843sdf41', 100, 2050, 0, 4800)
Insert into tblCars values ('Civic', 'pink', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 16000, 'srg55dfg2144dfs42', 850, 1300, 0, 3900)
Insert into tblCars values ('Primera', 'schwarz', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'dsfgds455fssgfsd843', 130, 1000, 0, 6600)
Insert into tblCars values ('Focus', 'lila', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'wf0utkw46sd4544', 57, 950, 0, 8000)
Insert into tblCars values ('Passat', 'grau', 3, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 109260, 'we36xsgv47f656dfs45', 190, 1400, 0, 4200)
Insert into tblCars values ('C Class', 'hellrot', 5, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 106806, 'vsdaff48ew8sdf46', 210, 1600, 0, 2900)
Insert into tblCars values ('Mondeo', 'pink', 2, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 104353, 'srg55dfg21d49fs47', 89, 1550, 0, 3500)
Insert into tblCars values ('Skoda', 'schwarz', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 0, 'dsf50gds5fssgfsd948', 125, 1650, 0, 4700)
Insert into tblCars values ('Audi', 'lila', 5, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 9944, 'wf0utk51wsd4349', 44, 1750, 0, 4400)
Insert into tblCars values ('Bmw', 'grau', 3, '1999-10-20 15:09:12.1234567', 2, 2, 5177, 363636, 'wf0utkw52sd4250', 120, 1850, 0, 9800)
Insert into tblCars values ('Ford', 'hellrot', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 9453, 'we36xsg53vf656dfs51', 142, 1950, 0, 3000)
Insert into tblCars values ('Polo', 'pink', 5, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 9208, 'vsdaffew8sdf5452', 100, 2050, 0, 37000)
Insert into tblCars values ('A4', 'weiss', 5, '2008-10-20 15:09:12.12345673', 3, 2, 1783, 89632, 'srg55dfg21dfs5553', 85, 1300, 0, 1800)
Insert into tblCars values ('Vectra', 'dunkelpink', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 30000, 'dsfgds556fssgfsd954', 130, 1000, 0, 28000)
Insert into tblCars values ('Saxo', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 28000, 'wf570utkwsd4655', 57, 950, 0, 1500)
Insert into tblCars values ('Civic', 'lila', 5, '2013-10-20 15:09:12.1234567', 2, 2, 2300, 20000, 'we36xs58gvf656dfs56', 190, 1400, 0, 5200)
Insert into tblCars values ('Toyota', 'grau', 2, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 25000, 'vsdaffe59w8sdf57', 210, 1600, 0, 4500)
Insert into tblCars values ('BMW', 'hellrot', 5, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 27000, 'srg55dfg2601dfs58', 89, 1550, 0, 2300)
Insert into tblCars values ('Mazda', 'weiss', 3, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 27000, 'dsfgds5fssg61fsd859', 125, 1650, 0, 12000)
Insert into tblCars values ('Mercedes', 'dunkelpink', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, '18000', 'wf062utkwsd4560', 44, 1750, 0, 2300)
Insert into tblCars values ('Opel', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'we36xsgvf656d63fs61', 850, 1300, 0, 3000)
Insert into tblCars values ('Ferrari', 'rot', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'vs64daffew8sdf62', 130, 1000, 0, 2800)
Insert into tblCars values ('Jaguar', 'weiss', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'sr65g55dfg21dfs63', 57, 950, 0, 4200)
Insert into tblCars values ('Maserati', 'pink', 5, '2013-10-20 15:09:12.1234567', 2, 2, 2300, 50000, 'dsfg66ds5fssgfsd964', 190, 1400, 0, 3700)
Insert into tblCars values ('Porsche', 'schwarz', 2, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 160000, 'wf067utkwsd4065', 210, 1600, 0, 5600)
Insert into tblCars values ('Vectra', 'lila', 5, '2004-10-20 15:09:12.1234567', 3, 2, 3726, 86958, 'wf0utkwsd368966', 89, 1550, 0, 2900)
Insert into tblCars values ('Saxo', 'grau', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'wf0utkwsd694667', 125, 1650, 0, 4800)
Insert into tblCars values ('Civic', 'hellrot', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 214563, 'we36xs70gvf656dfs68', 44, 1750, 0, 3900)
Insert into tblCars values ('Primera', 'pink', 5, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 50000, 'vsdaffew871sdf69', 120, 1850, 0, 6600)
Insert into tblCars values ('Focus', 'schwarz', 2, '2005-10-20 15:09:12.1234567', 3, 2, 5660, 160000, 'srg55dfg2721dfs70', 142, 1950, 0, 8000)
Insert into tblCars values ('Passat', 'lila', 5, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 26000, 'wf0ut73kwsd4671', 100, 2050, 0, 4200)
Insert into tblCars values ('C Class', 'grau', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 16000, 'wf0utk74wsd4672', '88', 1300, 0, 2900)
Insert into tblCars values ('Mondeo', 'hellrot', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'we36xs75gvf656dfs73', 130, 1000, 0, 3500)
Insert into tblCars values ('Skoda', 'pink', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'srg55dfg2176dfs74', 57, 950, 0, 4700)
Insert into tblCars values ('Ford', 'grau', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'wf0utkws77d4275', 85, 1300, 0, 4400)
Insert into tblCars values ('Tesla', 'rot', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'we36xsgvf67856dfs76', 130, 1000, 0, 9800)
Insert into tblCars values ('Skoda', 'weiss', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'vsdaf79few8sdf77', 57, 950, 0, 3000)
Insert into tblCars values ('Audi', 'pink', 3, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 50000, 'srg55dfg2180dfs78', 190, 1400, 0, 37000)
Insert into tblCars values ('Bmw', 'schwarz', 3, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 160000, 'dsfgds815fssgfsd679', 210, 1600, 0, 1800)
Insert into tblCars values ('Ford', 'lila', 5, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 86958, 'wf0ut82kwsd4380', 89, 1550, 0, 28000)
Insert into tblCars values ('Tesla', 'grau', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'we3836xsgvf656dfs81', 125, 1650, 0, 1500)
Insert into tblCars values ('Skoda', 'hellrot', 5, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 214563, 'v84sdaffew8sdf82', 44, 1750, 0, 5200)
Insert into tblCars values ('Audi', 'weiss', 3, '1999-10-20 15:09:12.1234567', 2, 2, 5177, 50000, 'srg55df85g21dfs83', 120, 1850, 0, 4500)
Insert into tblCars values ('Bmw', 'dunkelpink', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 160000, 'dsfg86ds5fssgfsd784', 142, 1950, 0, 2300)
Insert into tblCars values ('Ford', 'schwarz', 3, '2007-10-20 15:09:12.1234567', 3, 2, 6143, 26000, 'wf0utkwsd874485', 100, 2050, 0, 12000)
Insert into tblCars values ('Polo', 'lila', 5, '2003-10-20 15:09:12.1234567', 3, 2, 1783, 16000, 'wf0ut88kwsd4386', 85, 1300, 0, 2300)
Insert into tblCars values ('A4', 'grau', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'we36xsgv89f656dfs87', 130, 1000, 0, 3000)
Insert into tblCars values ('Vectra', 'hellrot', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'vs90daffew8sdf88', 57, 950, 0, 2800)
Insert into tblCars values ('Saxo', 'weiss', 3, '2013-10-20 15:09:12.1234567', 2, 2, 2300, 109260, 'srg55dfg9121dfs89', 190, 1400, 0, 4200)
Insert into tblCars values ('Civic', 'dunkelpink', 5, '2010-10-20 15:09:12.1234567', 3, 2, 4000, 106806, 'dsf92gds5fssgfsd790', 210, 1600, 0, 3700)
Insert into tblCars values ('Primera', 'schwarz', 2, '2004-10-20 15:09:12.1234567', 3, 1, 3726, '104353', 'wf0u93tkwsd4491', 89, 1550, 0, 5600)
Insert into tblCars values ('Focus', 'rot', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 0, 'we36xsgvf656d94fs92', 125, 1650, 0, 2900)
Insert into tblCars values ('Passat', 'weiss', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 9944, 'vsdaffew895sdf93', 44, 1750, 0, 4800)
Insert into tblCars values ('C Class', 'pink', 3, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 363636, 'srg55dfg2961dfs94', 120, 1850, 0, 3900)
Insert into tblCars values ('Mondeo', 'schwarz', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 9453, 'dsfgds5fssg97fsd895', 142, 1950, 0, 6600)
Insert into tblCars values ('Skoda', 'lila', 3, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 9208, 'wf980utkwsd4596', 100, 2050, 0, 8000)
Insert into tblCars values ('Audi', 'grau', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 89632, 'wf0u99tkwsd4497', '75', 1300, 0, 4200)
Insert into tblCars values ('Bmw', 'hellrot', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 30000, 'we36100xsgvf656dfs98', 130, 1000, 0, 2900)
Insert into tblCars values ('Ford', 'pink', 2, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 28000, 'vsdaffew8101sdf99', 57, 950, 0, 3500)
Insert into tblCars values ('Polo', 'schwarz', 5, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 20000, 'srg55dfg21021dfs100', 190, 1400, 0, 4700)
Insert into tblCars values ('A4', 'lila', 5, '2010-10-20 15:09:12.1234567', 3, 2, 4000, 25000, 'dsfgds5fss103gfsd8101', 210, 1600, 0, 4400)
Insert into tblCars values ('Vectra', 'grau', 5, '2004-10-20 15:09:12.1234567', 3, 2, 3726, 27000, 'wf0utkwsd10445102', 89, 1550, 0, 9800)
Insert into tblCars values ('Saxo', 'hellrot', 2, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 27000, 'we36xsgvf651056dfs103', 125, 1650, 0, 3000)
Insert into tblCars values ('Civic', 'pink', 2, '1997-10-20 15:09:12.1234567', 3, 1, 4693, '18000', 'vsda106ffew8sdf104', 44, 1750, 0, 37000)
Insert into tblCars values ('Toyota', 'weiss', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'srg55d107fg21dfs105', 850, 1300, 0, 1800)
Insert into tblCars values ('BMW', 'dunkelpink', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'dsfgds5fssgf108sd7106', 130, 1000, 0, 28000)
Insert into tblCars values ('Mazda', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'wf0utkwsd41094107', 57, 950, 0, 1500)
Insert into tblCars values ('Mercedes', 'lila', 5, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 50000, 'we31106xsgvf656dfs108', 190, 1400, 0, 5200)
Insert into tblCars values ('Opel', 'grau', 5, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 160000, 'vsdaffew8111sdf109', 210, 1600, 0, 4500)
Insert into tblCars values ('Ferrari', 'hellrot', 3, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 86958, 'srg55df112g21dfs110', 89, 1550, 0, 2300)
Insert into tblCars values ('Jaguar', 'weiss', 3, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'dsfgds5fssgf113sd8111', 125, 1650, 0, 12000)
Insert into tblCars values ('Maserati', 'dunkelpink', 5, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 214563, 'wf0u114tkwsd42112', 44, 1750, 0, 2300)
Insert into tblCars values ('Porsche', 'schwarz', 2, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 50000, 'wf0utkwsd41111513', 120, 1850, 0, 3000)
Insert into tblCars values ('Vectra', 'rot', 5, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 160000, 'we36xsgvf656dfs114', 142, 1950, 0, 2800)
Insert into tblCars values ('Saxo', 'weiss', 3, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 26000, 'vsdaff116ew8sdf115', 100, 2050, 0, 4200)
Insert into tblCars values ('Civic', 'pink', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 16000, 'srg55dfg21171dfs116', 850, 1300, 0, 3700)
Insert into tblCars values ('Primera', 'schwarz', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'dsfgds5118fssgfsd8117', 130, 1000, 0, 5600)
Insert into tblCars values ('Focus', 'lila', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'wf0utk119wsd45118', 57, 950, 0, 2900)
Insert into tblCars values ('Passat', 'grau', 3, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 109260, 'we36xsg120vf656dfs119', 190, 1400, 0, 4800)
Insert into tblCars values ('C Class', 'hellrot', 5, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 106806, 'vsdaff123ew8sdf120', 210, 1600, 0, 3900)
Insert into tblCars values ('Mondeo', 'pink', 2, '2004-10-20 15:09:12.1234567', 3, 1, 3726, '104353', 'srg55dfg21124dfs121', 89, 1550, 0, 6600)
Insert into tblCars values ('Skoda', 'schwarz', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 0, 'dsfgds5afssgfsd9122', 125, 1650, 0, 8000)
Insert into tblCars values ('Audi', 'lila', 5, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 9944, 'wf0utkwsdq43123', 44, 1750, 0, 4200)
Insert into tblCars values ('Bmw', 'grau', 3, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 363636, 'wf0utkwsdw42124', 120, 1850, 0, 2900)
Insert into tblCars values ('Ford', 'hellrot', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 9453, 'we36xsgvef656dfs125', 142, 1950, 0, 3500)
Insert into tblCars values ('Polo', 'pink', 5, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 9208, 'vsdaffew8sdfr126', 100, 2050, 0, 4700)
Insert into tblCars values ('A4', 'weiss', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 89632, 'srg55dfg21dfst127', 97, 1300, 0, 4400)
Insert into tblCars values ('Vectra', 'dunkelpink', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 30000, 'dsfgdzus5fssgfsd9128', 130, 1000, 0, 9800)
Insert into tblCars values ('Saxo', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 28000, 'wf0utkwsd461i29', 57, 950, 0, 3000)
Insert into tblCars values ('Civic', 'lila', 5, '2013-10-20 15:09:12.1234567', 2, 2, 2300, 20000, 'we36xsgvf656dfso130', 190, 1400, 0, 37000)
Insert into tblCars values ('Toyota', 'grau', 2, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 25000, 'vsdaffew8sdf131p', 210, 1600, 0, 1800)
Insert into tblCars values ('BMW', 'hellrot', 5, '2004-10-20 15:09:12.1234567', 3, 2, 3726, 27000, 'srg55dfg21dfs132a', 89, 1550, 0, 28000)
Insert into tblCars values ('Mazda', 'weiss', 3, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 27000, 'dsfgds5fssgfsd813s3', 125, 1650, 0, 1500)
Insert into tblCars values ('Mercedes', 'dunkelpink', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, '18000', 'wf0utkwsdd45134', 44, 1750, 0, 5200)
Insert into tblCars values ('Opel', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'we36xsgvf656dfs13f5', 84, 1300, 0, 4500)
Insert into tblCars values ('Ferrari', 'rot', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'vfsdaffew8sdf136', 130, 1000, 0, 2300)
Insert into tblCars values ('Jaguar', 'weiss', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'srgg55dfg21dfs137', 57, 950, 0, 12000)
Insert into tblCars values ('Maserati', 'pink', 5, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 50000, 'dsfhgds5fssgfsd9138', 190, 1400, 0, 2300)
Insert into tblCars values ('Porsche', 'schwarz', 2, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 160000, 'wjf0utkwsd40139', 210, 1600, 0, 3000)
Insert into tblCars values ('Vectra', 'lila', 5, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 86958, 'wf0utkwksd39140', 89, 1550, 0, 2800)
Insert into tblCars values ('Saxo', 'grau', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'we36xsgvf6l56dfs141', 125, 1650, 0, 4200)
Insert into tblCars values ('Civic', 'hellrot', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 214563, 'vsdafflew8sdf142', 44, 1750, 0, 3700)
Insert into tblCars values ('Primera', 'pink', 5, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 50000, 'srg55dyfg21dfs143', 120, 1850, 0, 5600)
Insert into tblCars values ('Focus', 'schwarz', 2, '2005-10-20 15:09:12.1234567', 3, 2, 5660, 160000, 'dsfgdxs5fssgfsd9144', 142, 1950, 0, 2900)
Insert into tblCars values ('Passat', 'lila', 5, '2007-10-20 15:09:12.1234567', 3, 2, 6143, 26000, 'wf0utkwsdc46145', 100, 2050, 0, 4800)
Insert into tblCars values ('C Class', 'grau', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 16000, 'we36xsgvfcc656dfs146', 96, 1300, 0, 3900)
Insert into tblCars values ('Mondeo', 'hellrot', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'vsdaffew8vsdf147', 130, 1000, 0, 6600)
Insert into tblCars values ('Skoda', 'pink', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'srg55dfg21dfsb148', 57, 950, 0, 8000)
Insert into tblCars values ('Audi', 'pink', 3, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 50000, 'srg5b5dfg21dfs4', 190, 1400, 0, 5200)
Insert into tblCars values ('Bmw', 'schwarz', 3, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 160000, 'dsnfgds5fssgfsd65', 210, 1600, 0, 4500)
Insert into tblCars values ('Ford', 'lila', 5, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 86958, 'wf0utkmwsd436', 89, 1550, 0, 2300)
Insert into tblCars values ('Tesla', 'grau', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'we36xsqqgvf656dfs7', 125, 1650, 0, 12000)
Insert into tblCars values ('Skoda', 'hellrot', 5, '1997-10-20 15:09:12.1234567', 3, 2, 4693, 214563, 'vsdaqwffew8sdf8', 44, 1750, 0, 2300)
Insert into tblCars values ('Audi', 'weiss', 3, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 50000, 'srg55dfg21qedfs9', 120, 1850, 0, 3000)
Insert into tblCars values ('Bmw', 'dunkelpink', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 160000, 'dsfgds5qrfssgfsd710', 142, 1950, 0, 2800)
Insert into tblCars values ('Ford', 'schwarz', 3, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 26000, 'wf0utkwsd441qd1', 100, 2050, 0, 4200)
Insert into tblCars values ('Polo', 'lila', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 16000, 'wf0uqftkwsd4312', 85, 1300, 0, 3700)
Insert into tblCars values ('A4', 'grau', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'we36xsgvqaf656dfs13', 130, 1000, 0, 5600)
Insert into tblCars values ('Vectra', 'hellrot', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'vsqsdaffew8sdf14', 57, 950, 0, 2900)
Insert into tblCars values ('Saxo', 'weiss', 3, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 109260, 'srg55dfgxs21dfs15', 190, 1400, 0, 4800)
Insert into tblCars values ('Civic', 'dunkelpink', 5, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 106806, 'dsfgxads5fssgfsd716', 210, 1600, 0, 3900)
Insert into tblCars values ('Primera', 'schwarz', 2, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 104353, 'wf0utxyr4kwsd4417', 89, 1550, 0, 6600)
Insert into tblCars values ('Focus', 'rot', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 0, 'we36xsgvfer656dfs18', 125, 1650, 0, 8000)
Insert into tblCars values ('Passat', 'weiss', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 9944, 'vsdafr2few8sdf19', 44, 1750, 0, 4200)
Insert into tblCars values ('C Class', 'pink', 3, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 363636, 'srg55r1dfg21dfs20', 120, 1850, 0, 2900)
Insert into tblCars values ('Mondeo', 'schwarz', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 9453, 'dsfgds5r15fssgfsd821', 142, 1950, 0, 3500)
Insert into tblCars values ('Skoda', 'lila', 3, '2007-10-20 15:09:12.1234567', 3, 2, 6143, 9208, 'wf0utkwsghd4522', 100, 2050, 0, 4700)
Insert into tblCars values ('Audi', 'grau', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 89632, 'wf0utkwsd4gg423', 850, 1300, 0, 4400)
Insert into tblCars values ('Bmw', 'hellrot', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 30000, 'we36xsgvf6xx56dfs24', 130, 1000, 0, 9800)
Insert into tblCars values ('Ford', 'pink', 2, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 28000, 'vsdaffew8smjdf25', 57, 950, 0, 3000)
Insert into tblCars values ('Polo', 'schwarz', 5, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 20000, 'srg55dfg2mk1dfs26', 190, 1400, 0, 37000)
Insert into tblCars values ('A4', 'lila', 5, '2010-10-20 15:09:12.1234567', 3, 2, 4000, 25000, 'dsfgds5fssgfsd8mn27', 210, 1600, 0, 1800)
Insert into tblCars values ('Vectra', 'grau', 5, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 27000, 'wf0utkwsd452nn8', 89, 1550, 0, 28000)
Insert into tblCars values ('Saxo', 'hellrot', 2, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 27000, 'we36xsgvf656bndfs29', 125, 1650, 0, 1500)
Insert into tblCars values ('Civic', 'pink', 2, '1997-10-20 15:09:12.1234567', 3, 1, 4693, '18000', 'vsdaffew8sdf30mb', 44, 1750, 0, 5200)
Insert into tblCars values ('Toyota', 'weiss', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'srg55dfg21fgdfs31', 85, 1300, 0, 4500)
Insert into tblCars values ('BMW', 'dunkelpink', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'dsfgds5fssgfsd7fb32', 130, 1000, 0, 2300)
Insert into tblCars values ('Mazda', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'wf0utkwsd4fmm433', 57, 950, 0, 12000)
Insert into tblCars values ('Mercedes', 'lila', 5, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 50000, 'we36xsgvf656dfmvfs34', 190, 1400, 0, 2300)
Insert into tblCars values ('Opel', 'grau', 5, '2010-10-20 15:09:12.1234567', 3, 2, 4000, 160000, 'vsdaffew8sdxqsdef35', 210, 1600, 0, 3000)
Insert into tblCars values ('Ferrari', 'hellrot', 3, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 86958, 'srg55dfg21dfgbfs36', 89, 1550, 0, 2800)
Insert into tblCars values ('Jaguar', 'weiss', 3, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'dsfgds5fssgfsdkrf837', 125, 1650, 0, 4200)
Insert into tblCars values ('Maserati', 'dunkelpink', 5, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 214563, 'wf0utkwsfghd4238', 44, 1750, 0, 3700)
Insert into tblCars values ('Porsche', 'schwarz', 2, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 50000, 'wf0utkwfgsd4139', 120, 1850, 0, 5600)
Insert into tblCars values ('Vectra', 'rot', 5, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 160000, 'we36xsgvf656dfgsbfs40', 142, 1950, 0, 2900)
Insert into tblCars values ('Saxo', 'weiss', 3, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 26000, 'vsdaffew8sdf4hjk1', 100, 2050, 0, 4800)
Insert into tblCars values ('Civic', 'pink', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 16000, 'srg55dfg21dfneg6s42', 850, 1300, 0, 3900)
Insert into tblCars values ('Primera', 'schwarz', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'dsfgds5fnge6ssgfsd843', 130, 1000, 0, 6600)
Insert into tblCars values ('Focus', 'lila', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'wf0utkwgne5sd4544', 57, 950, 0, 8000)
Insert into tblCars values ('Passat', 'grau', 3, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 109260, 'we36xsgvfdfgh656dfs45', 190, 1400, 0, 4200)
Insert into tblCars values ('C Class', 'hellrot', 5, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 106806, 'vsdaffew86nsdf46', 210, 1600, 0, 2900)
Insert into tblCars values ('Mondeo', 'pink', 2, '2004-10-20 15:09:12.1234567', 3, 1, 3726, '104353', 'srg55dfg21df2ns47', 89, 1550, 0, 3500)
Insert into tblCars values ('Skoda', 'schwarz', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 0, 'dsfgds5fssgf4n2sd948', 125, 1650, 0, 4700)
Insert into tblCars values ('Audi', 'lila', 5, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 9944, 'wf0utkwsk75d4349', 44, 1750, 0, 4400)
Insert into tblCars values ('Bmw', 'grau', 3, '1999-10-20 15:09:12.1234567', 2, 2, 5177, 363636, 'wf0utkwsdmrn664250', 120, 1850, 0, 9800)
Insert into tblCars values ('Ford', 'hellrot', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 9453, 'we36xsgvf655mr6dfs51', 142, 1950, 0, 3000)
Insert into tblCars values ('Polo', 'pink', 5, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 9208, 'vsdaffew8sbbdf52', 100, 2050, 0, 37000)
Insert into tblCars values ('A4', 'weiss', 5, '2003-10-20 15:09:12.1234567', 3, 2, 1783, 89632, 'srg55dfg2nhe1dfs53', 85, 1300, 0, 1800)
Insert into tblCars values ('Vectra', 'dunkelpink', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 30000, 'dshgz56fgds5fssgfsd954', 130, 1000, 0, 28000)
Insert into tblCars values ('Saxo', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 28000, 'wf0utkwsd44bk655', 57, 950, 0, 1500)
Insert into tblCars values ('Civic', 'lila', 5, '2013-10-20 15:09:12.1234567', 2, 2, 2300, 20000, 'we36xsgvf656adfdfs56', 190, 1400, 0, 5200)
Insert into tblCars values ('Toyota', 'grau', 2, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 25000, 'vsdaffew8sdevsf57', 210, 1600, 0, 4500)
Insert into tblCars values ('BMW', 'hellrot', 5, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 27000, 'srg55dfg21dqxxfs58', 89, 1550, 0, 2300)
Insert into tblCars values ('Mazda', 'weiss', 3, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 27000, 'dsfgds5fssgfsverd859', 125, 1650, 0, 12000)
Insert into tblCars values ('Mercedes', 'dunkelpink', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, '18000', 'wf0utje45kwsd4560', 44, 1750, 0, 2300)
Insert into tblCars values ('Opel', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'we36xsgvf656dfgh5fs61', 850, 1300, 0, 3000)
Insert into tblCars values ('Ferrari', 'rot', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'vsdaffebgr5w8sdf62', 130, 1000, 0, 2800)
Insert into tblCars values ('Jaguar', 'weiss', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'srg55hjw4dfg21dfs63', 57, 950, 0, 4200)
Insert into tblCars values ('Maserati', 'pink', 5, '2013-10-20 15:09:12.1234567', 2, 2, 2300, 50000, 'dsfgds5fs44ggsgfsd964', 190, 1400, 0, 3700)
Insert into tblCars values ('Porsche', 'schwarz', 2, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 160000, 'wf0utkwsd4eg3e065', 210, 1600, 0, 5600)
Insert into tblCars values ('Vectra', 'lila', 5, '2004-10-20 15:09:12.1234567', 3, 2, 3726, 86958, 'wf0utkwsdkjiu73966', 89, 1550, 0, 2900)
Insert into tblCars values ('Saxo', 'grau', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'wf0utkwsh6d4667', 125, 1650, 0, 4800)
Insert into tblCars values ('Civic', 'hellrot', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 214563, 'we36xhjksgvf656dfs68', 44, 1750, 0, 3900)
Insert into tblCars values ('Primera', 'pink', 5, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 50000, 'vsdaffew8su6kdf69', 120, 1850, 0, 6600)
Insert into tblCars values ('Focus', 'schwarz', 2, '2005-10-20 15:09:12.1234567', 3, 2, 5660, 160000, 'srg55dfg21dr56fs70', 142, 1950, 0, 8000)
Insert into tblCars values ('Passat', 'lila', 5, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 26000, 'wf0utkwsdfgh6t4671', 100, 2050, 0, 4200)
Insert into tblCars values ('C Class', 'grau', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 16000, 'wf0utkwsd46hj5672', '88', 1300, 0, 2900)
Insert into tblCars values ('Mondeo', 'hellrot', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'we36xsgvf65dj66dfs73', 130, 1000, 0, 3500)
Insert into tblCars values ('Skoda', 'pink', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'srg55dfdh6g21dfs74', 57, 950, 0, 4700)
Insert into tblCars values ('Ford', 'grau', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'wf0utkwsd4dz275', 85, 1300, 0, 4400)
Insert into tblCars values ('Tesla', 'rot', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'we36xsgvf656dfsef5676', 130, 1000, 0, 9800)
Insert into tblCars values ('Skoda', 'weiss', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'vsdaffewsd898sdf77', 57, 950, 0, 3000)
Insert into tblCars values ('Audi', 'pink', 3, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 50000, 'srg55dfg21df4ghs78', 190, 1400, 0, 37000)
Insert into tblCars values ('Bmw', 'schwarz', 3, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 160000, 'dsfgds5fssgf32fsd679', 210, 1600, 0, 1800)
Insert into tblCars values ('Ford', 'lila', 5, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 86958, 'wf0utkwsd4f23380', 89, 1550, 0, 28000)
Insert into tblCars values ('Tesla', 'grau', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'we36xsgvfn5gh656dfs81', 125, 1650, 0, 1500)
Insert into tblCars values ('Skoda', 'hellrot', 5, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 214563, 'vsdaffew834fsdf82', 44, 1750, 0, 5200)
Insert into tblCars values ('Audi', 'weiss', 3, '1999-10-20 15:09:12.1234567', 2, 2, 5177, 50000, 'srg55dfg2r51dfs83', 120, 1850, 0, 4500)
Insert into tblCars values ('Bmw', 'dunkelpink', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 160000, 'dsfgds54v5fssgfsd784', 142, 1950, 0, 2300)
Insert into tblCars values ('Ford', 'schwarz', 3, '2007-10-20 15:09:12.1234567', 3, 2, 6143, 26000, 'wf0utkwsd448eag5', 100, 2050, 0, 12000)
Insert into tblCars values ('Polo', 'lila', 5, '2003-10-20 15:09:12.1234567', 3, 2, 1783, 16000, 'wf0utkwsdfvbd4386', 85, 1300, 0, 2300)
Insert into tblCars values ('A4', 'grau', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'we36xsgvf656dfjk5s87', 130, 1000, 0, 3000)
Insert into tblCars values ('Vectra', 'hellrot', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'vsdaffew8dr4sdf88', 57, 950, 0, 2800)
Insert into tblCars values ('Saxo', 'weiss', 3, '2010-10-20 15:09:12.12345673', 2, 2, 2300, 109260, 'srg55dfg21vr3dfs89', 190, 1400, 0, 4200)
Insert into tblCars values ('Civic', 'dunkelpink', 5, '2010-10-20 15:09:12.1234567', 3, 2, 4000, 106806, 'dsfgds5gr4fssgfsd790', 210, 1600, 0, 3700)
Insert into tblCars values ('Primera', 'schwarz', 2, '2004-10-20 15:09:12.1234567', 3, 1, 3726, '104353', 'wf0utkwge4sd4491', 89, 1550, 0, 5600)
Insert into tblCars values ('Focus', 'rot', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 0, 'we36xsgvre4g5f656dfs92', 125, 1650, 0, 2900)
Insert into tblCars values ('Passat', 'weiss', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 9944, 'vsdaffek7gw8sdf93', 44, 1750, 0, 4800)
Insert into tblCars values ('C Class', 'pink', 3, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 363636, 'srg5523df4hg21dfs94', 120, 1850, 0, 3900)
Insert into tblCars values ('Mondeo', 'schwarz', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 9453, 'dsfgds534fsersgfsd895', 142, 1950, 0, 6600)
Insert into tblCars values ('Skoda', 'lila', 3, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 9208, 'wf0utkwsd534596', 100, 2050, 0, 8000)
Insert into tblCars values ('Audi', 'grau', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 89632, 'wf0utkwsd4wer3497', '75', 1300, 0, 4200)
Insert into tblCars values ('Bmw', 'hellrot', 5, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 30000, 'we36xsgvf654fg6dfs98', 130, 1000, 0, 2900)
Insert into tblCars values ('Ford', 'pink', 2, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 28000, 'vsdaffew8sdhzr5f99', 57, 950, 0, 3500)
Insert into tblCars values ('Polo', 'schwarz', 5, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 20000, 'srg55dfg21dfgre3s100', 190, 1400, 0, 4700)
Insert into tblCars values ('A4', 'lila', 5, '2010-10-20 15:09:12.1234567', 3, 2, 4000, 25000, 'dsfgds5fssxxergfsd8101', 210, 1600, 0, 4400)
Insert into tblCars values ('Vectra', 'grau', 5, '2004-10-20 15:09:12.1234567', 3, 2, 3726, 27000, 'wf0utkwsd4ydx5102', 89, 1550, 0, 9800)
Insert into tblCars values ('Saxo', 'hellrot', 2, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 27000, 'we36xsgvf65ycq6dfs103', 125, 1650, 0, 3000)
Insert into tblCars values ('Civic', 'pink', 2, '1997-10-20 15:09:12.1234567', 3, 1, 4693, '18000', 'vsdaffew8sdf10w4', 44, 1750, 0, 37000)
Insert into tblCars values ('Toyota', 'weiss', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'srg55dfg2wcac1dfs105', 850, 1300, 0, 1800)
Insert into tblCars values ('BMW', 'dunkelpink', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'dsfgds5fssgfsd7bw4106', 130, 1000, 0, 28000)
Insert into tblCars values ('Mazda', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'wf0utkwsd4wyb4107', 57, 950, 0, 1500)
Insert into tblCars values ('Mercedes', 'lila', 5, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 50000, 'we36xwybxcsgvf656dfs108', 190, 1400, 0, 5200)
Insert into tblCars values ('Opel', 'grau', 5, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 160000, 'vsdaffew8swhjadf109', 210, 1600, 0, 4500)
Insert into tblCars values ('Ferrari', 'hellrot', 3, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 86958, 'srg55dfgw53fs21dfs110', 89, 1550, 0, 2300)
Insert into tblCars values ('Jaguar', 'weiss', 3, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'dsfgds5fssgfebnjsd8111', 125, 1650, 0, 12000)
Insert into tblCars values ('Maserati', 'dunkelpink', 5, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 214563, 'wf0utkuzsbwsd42112', 44, 1750, 0, 2300)
Insert into tblCars values ('Porsche', 'schwarz', 2, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 50000, 'wf0utkwsgdr5d41113', 120, 1850, 0, 3000)
Insert into tblCars values ('Vectra', 'rot', 5, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 160000, 'we36xsgvd5bf656dfs114', 142, 1950, 0, 2800)
Insert into tblCars values ('Saxo', 'weiss', 3, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 26000, 'vsdaffew8sdfvbdr5115', 100, 2050, 0, 4200)
Insert into tblCars values ('Civic', 'pink', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 16000, 'srg55dfgkzew21dfs116', 850, 1300, 0, 3700)
Insert into tblCars values ('Primera', 'schwarz', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'dsfgds5wefssgfsd8117', 130, 1000, 0, 5600)
Insert into tblCars values ('Focus', 'lila', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'wf0utkwsd4511wer8', 57, 950, 0, 2900)
Insert into tblCars values ('Passat', 'grau', 3, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 109260, 'we36xsgvf656dfdgs119', 190, 1400, 0, 4800)
Insert into tblCars values ('C Class', 'hellrot', 5, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 106806, 'vsdaffew8dgsdf120', 210, 1600, 0, 3900)
Insert into tblCars values ('Mondeo', 'pink', 2, '2004-10-20 15:09:12.1234567', 3, 1, 3726, '104353', 'srg55dfg21dfs1gr21', 89, 1550, 0, 6600)
Insert into tblCars values ('Skoda', 'schwarz', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 0, 'dsfgds5fssgfsd91rg22', 125, 1650, 0, 8000)
Insert into tblCars values ('Audi', 'lila', 5, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 9944, 'wf0utkwsd431gr23', 44, 1750, 0, 4200)
Insert into tblCars values ('Bmw', 'grau', 3, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 363636, 'wf0utkwsd4212drr4', 120, 1850, 0, 2900)
Insert into tblCars values ('Ford', 'hellrot', 3, '2005-10-20 15:09:12.1234567', 3, 1, 5660, 9453, 'we36xsgvf656dfs12ggj5', 142, 1950, 0, 3500)
Insert into tblCars values ('Polo', 'pink', 5, '2007-10-20 15:09:12.1234567', 3, 1, 6143, 9208, 'vsdaffew8sdf12ftm6', 100, 2050, 0, 4700)
Insert into tblCars values ('A4', 'weiss', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 89632, 'srg55dfg21dfs12s57', 97, 1300, 0, 4400)
Insert into tblCars values ('Vectra', 'dunkelpink', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 30000, 'dsfgds5fssgfsd912hr8', 130, 1000, 0, 9800)
Insert into tblCars values ('Saxo', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 28000, 'wf0utkwsd4612hr9', 57, 950, 0, 3000)
Insert into tblCars values ('Civic', 'lila', 5, '2013-10-20 15:09:12.1234567', 2, 2, 2300, 20000, 'we36xsgvf656dfs1hsrtz30', 190, 1400, 0, 37000)
Insert into tblCars values ('Toyota', 'grau', 2, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 25000, 'vsdaffew8sdf13ehr1', 210, 1600, 0, 1800)
Insert into tblCars values ('BMW', 'hellrot', 5, '2004-10-20 15:09:12.1234567', 3, 2, 3726, 27000, 'srg55dfg21dfs13rh2', 89, 1550, 0, 28000)
Insert into tblCars values ('Mazda', 'weiss', 3, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 27000, 'dsfgds5fssgfsd813dr3', 125, 1650, 0, 1500)
Insert into tblCars values ('Mercedes', 'dunkelpink', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, '18000', 'wf0utkwsd451nr34', 44, 1750, 0, 5200)
Insert into tblCars values ('Opel', 'schwarz', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 289000, 'we36xsgvf656dfs13ndr5', 84, 1300, 0, 4500)
Insert into tblCars values ('Ferrari', 'rot', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 0, 'vsdaffew8sdf1wyc36', 130, 1000, 0, 2300)
Insert into tblCars values ('Jaguar', 'weiss', 3, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 214563, 'srg55dfg21dfs1wcd37', 57, 950, 0, 12000)
Insert into tblCars values ('Maserati', 'pink', 5, '2013-10-20 15:09:12.1234567', 2, 1, 2300, 50000, 'dsfgds5fssgfsd91wc38', 190, 1400, 0, 2300)
Insert into tblCars values ('Porsche', 'schwarz', 2, '2010-10-20 15:09:12.1234567', 3, 1, 4000, 160000, 'wf0utkwsd4013yw9', 210, 1600, 0, 3000)
Insert into tblCars values ('Vectra', 'lila', 5, '2004-10-20 15:09:12.1234567', 3, 1, 3726, 86958, 'wf0utkwsd3914wcw0', 89, 1550, 0, 2800)
Insert into tblCars values ('Saxo', 'grau', 5, '2014-10-20 15:09:12.1234567', 1, 3, 4210, 59676, 'we36xsgvf656dfs1wac41', 125, 1650, 0, 4200)
Insert into tblCars values ('Civic', 'hellrot', 3, '1997-10-20 15:09:12.1234567', 3, 1, 4693, 214563, 'vsdaffew8sdf14vd2', 44, 1750, 0, 3700)
Insert into tblCars values ('Primera', 'pink', 5, '1999-10-20 15:09:12.1234567', 2, 1, 5177, 50000, 'srg55dfg21dfs14ve3', 120, 1850, 0, 5600)
Insert into tblCars values ('Focus', 'schwarz', 2, '2005-10-20 15:09:12.1234567', 3, 2, 5660, 160000, 'dsfgds5fssgfsd914re4', 142, 1950, 0, 2900)
Insert into tblCars values ('Passat', 'lila', 5, '2007-10-20 15:09:12.1234567', 3, 2, 6143, 26000, 'wf0utkwsd4614ev5', 100, 2050, 0, 4800)
Insert into tblCars values ('C Class', 'grau', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1783, 16000, 'we36xsgvf656dfs14esve6', 96, 1300, 0, 3900)
Insert into tblCars values ('Mondeo', 'hellrot', 3, '2019-10-20 15:09:12.1234567', 1, 3, 1900, 10000, 'vsdaffew8sdf14efh27', 130, 1000, 0, 6600)
Insert into tblCars values ('Skoda', 'pink', 5, '2003-10-20 15:09:12.1234567', 3, 1, 1400, 111713, 'srg55dfg21dfs1f3r348', 57, 950, 0, 8000)


-- tblCustomer DATA uploading


Insert into tblCustomer values ('Zmölnig', 'Andreas', 1, 'Erdbergstraße', '5', 1032, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43634561411, 'zmölnig.andreas@gmail.com')
Insert into tblCustomer values ('Kamerhan', 'Apollonia', 2, 'Gurkg.', '5/13', 1140, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43673461411, 'kamerhan.apollonia@gmail.com')
Insert into tblCustomer values ('Chourine', 'Simon', 1, 'Forchtenau', '9', 4971, 'Aurolzmünster', 32, '2013-10-20 15:09:12.1234567', 43673561411, 'chourine.simon@gmail.com')
Insert into tblCustomer values ('Katzlberger-Laimer', 'Christine', 2, 'Hohlweggasse', '88', 1032, 'Wien', 32, '2013-10-20 15:09:12.1234567', 4367635761411, 'katzlberger-laimer.christine@gmail.com')
Insert into tblCustomer values ('Heikenwälder', 'Anna', 2, 'Gottfried Alber Gasse', '114', 1140, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763581411, 'heikenwälder.anna@gmail.com')
Insert into tblCustomer values ('Schiller', 'Lukas', 1, 'Brünner Bundesstraße', '4', 2201, 'Seyring', 32, '2013-10-20 15:09:12.1234567', 43676359411, 'schiller.lukas@gmail.com')
Insert into tblCustomer values ('Burghofer', 'Cornelia', 2, 'Waidhofner Str.', '95/3/14', 3300, 'Amstetten', 32, '2013-10-20 15:09:12.1234567', 43676360411, 'burghofer.cornelia@gmail.com')
Insert into tblCustomer values ('Nehler', 'Tine', 2, 'Traviatag.', '13/10', 1232, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43676361411, 'nehler.tine@gmail.com')
Insert into tblCustomer values ('Ehart', 'Margherita', 2, 'Gentzgasse', '10', 1180, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763538011, 'ehart.margherita@gmail.com')
Insert into tblCustomer values ('Marinkovic', 'Virdzinija', 2, 'Zehenthofg.', '16/35/10', 1190, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43673811411, 'marinkovic.virdzinija@gmail.com')
Insert into tblCustomer values ('Langfeld', 'Stefanie', 2, 'Esslingg.', '46/8/28', 1010, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763388411, 'langfeld.stefanie@gmail.com')
Insert into tblCustomer values ('Träxler', 'Paul', 1, 'Altmütterg.', '22/4', 1090, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43676400411, 'träxler.paul@gmail.com')
Insert into tblCustomer values ('Hinterndorfer', 'Susanne', 2, 'Hetzendorferstraße', '55/22', 1120, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763400111, 'hinterndorfer.susanne@gmail.com')
Insert into tblCustomer values ('Garcia', 'Susanne', 2, 'Passauerstr.', '68/5', 4722, 'Peuerbach', 32, '2013-10-20 15:09:12.1234567', 436763401411, 'garcia.susanne@gmail.com')
Insert into tblCustomer values ('Eckerstorfer', 'Aurora', 2, 'Seb.Brunner-G.', '8/7', 1132, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436758461411, 'eckerstorfer.aurora@gmail.com')
Insert into tblCustomer values ('Ebner', 'Marika', 2, 'Thelemangasse', '9/16', 1170, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436765001411, 'ebner.marika@gmail.com')
Insert into tblCustomer values ('Nymark', 'Clara', 2, 'Belvederegasse', '4/6', 1040, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436750161411, 'nymark.clara@gmail.com')
Insert into tblCustomer values ('Messer', 'Gerald', 1, 'Trazerberggasse', '13/10', 1132, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43675020411, 'messer.gerald@gmail.com')
Insert into tblCustomer values ('Fuchs', 'Michael', 1,' Wienerbergstraße', '16/1', 1120, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436505161411, 'fuchs.michael@gmail.com')
Insert into tblCustomer values ('Butcaru', 'Karoline', 2, 'Waidhofner Str.', '93/8/8', 3300, 'Amstetten', 32, '2013-10-20 15:09:12.1234567', 436757561411, 'butcaru.karoline@gmail.com')
Insert into tblCustomer values ('Schönfelder', 'Hermann', 1, 'Clementinengasse', '28/7', 1150, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436767511411, 'schönfelder.hermann@gmail.com')
Insert into tblCustomer values ('Obdrzálek', 'Marek', 1, 'Kinderspitalg.', '26', 1090, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43676752411, 'obdrzálek.marek@gmail.com')
Insert into tblCustomer values ('Marinovic', 'Tobias', 1, 'Schanzstraße', '88', 3390, 'Melk', 32, '2013-10-20 15:09:12.1234567', 436775331411, 'marinovic.tobias@gmail.com')
Insert into tblCustomer values ('Lamparter', 'Franz', 1, 'Absberggasse', '1', 1100, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436767541411, 'lamparter.franz@gmail.com')
Insert into tblCustomer values ('Kuschka', 'Gerhard', 1, 'Humboldtplatz', '73', 1100, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436767551411, 'kuschka.gerhard@gmail.com')
Insert into tblCustomer values ('Fellner', 'Jacqueline', 2, 'Rudolf ReiterStr.', '7/6', 2540, 'Bad Vöslau', 32, '2013-10-20 15:09:12.1234567', 436775661411, 'fellner.jacqueline@gmail.com')
Insert into tblCustomer values ('Gellert', 'Yvonne', 2, 'Gersthoferstraße', '119', 1180, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436767571411, 'gellert.yvonne@gmail.com')
Insert into tblCustomer values ('Woda', 'Richie', 1, 'Afrikanergasse', '6', 1020, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763758411, 'woda.richie@gmail.com')
Insert into tblCustomer values ('Cernajsek', 'Odette', 2, 'Waaggasse', '93/8/8', 1040, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436767591411, 'cernajsek.odette@gmail.com')
Insert into tblCustomer values ('Mandl', 'Dorothea', 2, 'Dittmanng.', '46/18', 1110, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763780411, 'mandl.dorothea@gmail.com')
Insert into tblCustomer values ('Lagrange', 'Traude', 2, 'Eyslerstr.', '46/8/28', 4600, 'Wels', 32, '2013-10-20 15:09:12.1234567', 436778161411, 'lagrange.traude@gmail.com')
Insert into tblCustomer values ('Schuch', 'Hermann', 1, 'Esslingg.', '261/3', 1010, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43676782411, 'schuch.hermann@gmail.com')
Insert into tblCustomer values ('Enetjan', 'Til', 1, 'Schulgasse', '8/11', '8740', 'Zeltweg', 32, '2013-10-20 15:09:12.1234567', 436767831411, 'enetjan.til@gmail.com')
Insert into tblCustomer values ('Fally', 'Momcinovic', 2, 'Schönlaterngasse', '8', 1010, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436778461411, 'fally.momcinovic@gmail.com')
Insert into tblCustomer values ('Ottitsch', 'Anna', 2, 'Argentinierstr.', '39/13', 1040, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436767851411, 'ottitsch.anna@gmail.com')
Insert into tblCustomer values ('Obdrzalek', 'Josefine', 2, 'Aschbachg.', '4/12', 1238, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436767861411, 'obdrzalek.josefine@gmail.com')
Insert into tblCustomer values ('Beiser', 'Christoph', 1, 'Dr. Adolf Schärf Str.', '7', 3200, 'St.Pölten', 32, '2013-10-20 15:09:12.1234567', 43678961411, 'beiser.christoph@gmail.com')
Insert into tblCustomer values ('Stein', 'Evelyn', 2, 'Martinstraße', '15', 3400, 'Klosterneuburg', 32, '2013-10-20 15:09:12.1234567', 43677901411, 'stein.evelyn@gmail.com')
Insert into tblCustomer values ('Wendlandt', 'Jochen', 1, 'Tivolig.', '119/3/19', 1120, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436711061411, 'wendlandt.jochen@gmail.com')
Insert into tblCustomer values ('Wenhoda', 'Werner', 1, 'Mollardg.', '11', 1060, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43671111411, 'wenhoda.werner@gmail.com')
Insert into tblCustomer values ('Weihskircher', 'Peter', 1, 'Theobaldgasse', '103//5', 1060, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436711261411, 'weihskircher.peter@gmail.com')
Insert into tblCustomer values ('Granaas', 'Josefine', 2, 'Parkstraße', '68/15', 3100, 'St. Pölten', 32, '2013-10-20 15:09:12.1234567', 436711361411, 'granaas.josefine@gmail.com')
Insert into tblCustomer values ('Gruber', 'Ingolf', 1, 'Theresianumg.', '114/1/10', 1040, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43676114411, 'gruber.ingolf@gmail.com')
Insert into tblCustomer values ('Zottelhofer', 'Herbert', 1, 'Pichlergasse', '91', 1090, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763511511, 'zottelhofer.herbert@gmail.com')
Insert into tblCustomer values ('Rubenser', 'Madeleine', 2, 'Zohmanngasse', '17/3/17', 1100, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436761161411, 'rubenser.madeleine@gmail.com')
Insert into tblCustomer values ('Holzmann', 'Stanislava', 2, 'Hagenmüllerg.', '5/28', 1032, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436761171411, 'holzmann.stanislava@gmail.com')
Insert into tblCustomer values ('Josipa', 'Barbara', 2, 'Gurkg.', '5/13', 1140, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43676311811, 'josipa.barbara@gmail.com')
Insert into tblCustomer values ('Obdrzálek', 'Marek', 1, 'Klosterstraße', '25', 2362, 'Biedermannsdorf', 32, '2013-10-20 15:09:12.1234567', 43671991411, 'obdr1zálek.marek@gmail.com')
Insert into tblCustomer values ('Pilz', 'Hans Christian', 1, 'Altmütterg.', '30/30', 1090, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43671221411, 'pilz.hans christian@gmail.com')
Insert into tblCustomer values ('Hofstötter', 'Birgit', 2, 'Herzgasse', '89', 1100, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436761231411, 'hofstötter.birgit@gmail.com')
Insert into tblCustomer values ('Lachtner', 'Wilhelmine', 2, 'Geusaugassea', '5/13', 1032, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436712341411, 'lachtner.wilhelmine@gmail.com')
Insert into tblCustomer values ('Marinovic', 'Tobias', 1, 'Preiseckergasse', '25', 3420, 'Kritzendorf', 32, '2013-10-20 15:09:12.1234567', 4312561411, 'marin45ovic.tobias@gmail.com')
Insert into tblCustomer values ('Stockner-Thanheuser', 'Michaela', 2, 'Webg.', '15/2/7', 1060, 'Wien', 32, '2013-10-20 15:09:12.1234567', 4361261411, 'stockner-thanheuser.michaela@gmail.com')
Insert into tblCustomer values ('Eckerstorfer', 'Katja', 2, 'Spittelbreitengasse', '81/8', 1120, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43612761411, 'eckerstorfer.katja@gmail.com')
Insert into tblCustomer values ('Svirac', 'Paul', 1, 'Keilg.', '25/15', 1032, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436712881411, 'svirac.paul@gmail.com')
Insert into tblCustomer values ('Lauw', 'Sigrid', 2, 'Erdbergstr.', '46/5/7', 1032, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43671291411, 'lauw.sigrid@gmail.com')
Insert into tblCustomer values ('Leibinger', 'Peter', 1, 'Hüttelbergstraße', '68', 1140, 'Wien', 32, '2013-10-20 15:09:12.1234567', 4361301411, 'leibinger.peter@gmail.com')
Insert into tblCustomer values ('Ratz', 'Ines', 2, 'Langg.', '24', 6832, 'Rankweil', 32, '2013-10-20 15:09:12.1234567', 436713161411, 'ratz.ines@gmail.com')
Insert into tblCustomer values ('Handwerk', 'Gudrun', 2, 'Mannagettagasse', '60-64/1/12', 2340, 'Mödling', 32, '2013-10-20 15:09:12.1234567', 436713261411, 'handwerk.gudrun@gmail.com')
Insert into tblCustomer values ('Bogonslavskaia', 'Roswitha', 2, 'Walzengasse', '101/5/5', 2380, 'Perchtoldsdorf', 32, '2013-10-20 15:09:12.1234567', 436133561411, 'bogonslavskaia.roswitha@gmail.com')
Insert into tblCustomer values ('Rafael Androwitsch', 'Marina Elisabeth', 2, 'Sverigestraße', '103//5', 1220, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436713461411, 'rafaelandrowitsch.marinaelisabeth@gmail.com')
Insert into tblCustomer values ('Dr. Polivnick', 'Johanna', 2, 'A. Hofer Str.', '3/4/7', 2345, 'Brunn am Gebirge', 32, '2013-10-20 15:09:12.1234567', 436761351411, 'dr.polivnick.johanna@gmail.com')
Insert into tblCustomer values ('Peham', 'Kora', 2, 'Anton Langer Gasse', '39/13', 1132, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43671361411, 'peham.kora@gmail.com')
Insert into tblCustomer values ('Haas', 'Herbert', 1, 'Dorotheergasse', '6', 1010, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43671371411, 'haas.herbert@gmail.com')
Insert into tblCustomer values ('Reithner', 'Franz', 1, 'Lassallestr.', '22', 1020, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436138861411, 'reithner.franz@gmail.com')
Insert into tblCustomer values ('Weinert', 'Martin', 1, 'Meidlinger Hauptstraße', '11', 1120, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436713961411, 'weinert.martin@gmail.com')
Insert into tblCustomer values ('Sücs', 'Alexandra', 2, 'Hetzendorferstraße', '25/2', 1120, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436714061411, 'sücs.alexandra@gmail.com')
Insert into tblCustomer values ('Biener', 'Christof', 1, 'Engerthstraße', '8', 1200, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436714161411, 'biener.christof@gmail.com')
Insert into tblCustomer values ('Fellermann', 'Lourenco César', 1, 'Rudolf Zellergasse', '72/5/11', 1232, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436714261411, 'fellermann.lourencocésar@gmail.com')
Insert into tblCustomer values ('Puhrer', 'Jonas', 1, 'Keilg.', '3/4', 1032, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763143411, 'puhrer.jonas@gmail.com')
Insert into tblCustomer values ('Skorpis', 'Manfred', 1, 'Loudonstraße', '18', 1140, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436761441411, 'skorpis.manfred@gmail.com')
Insert into tblCustomer values ('Simhandl', 'Josef', 1, 'Lochaustr.', '21', 3382, 'Loosdorf', 32, '2013-10-20 15:09:12.1234567', 436761451411, 'simhandl.josef@gmail.com')
Insert into tblCustomer values ('Arnold', 'Janine', 2, 'Alszeile', 6, 1170, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436761461411, 'arnold.janine@gmail.com')
Insert into tblCustomer values ('Peham', 'Edita', 2, 'Amalienstraße', '36/2/12', 1132, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436714761411, 'peham.edita@gmail.com')
Insert into tblCustomer values ('Kranzler', 'Elisabeth', 2, 'Waidhausenstr.', '132/3', 1140, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436148561411, 'kranzler.elisabeth@gmail.com')
Insert into tblCustomer values ('Leibinger', 'Peter', 1, 'Kärntnerstraße', '35', 1010, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436714961411, 'leibinger12.peter@gmail.com')
Insert into tblCustomer values ('Lötsch', 'Günther', 1, 'Kärntnerstraße', '33', 1010, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436761501411, 'lötsch.günther@gmail.com')
Insert into tblCustomer values ('Wollein', 'Hannes', 1, 'Reisnerstr.', '2/3', 1032, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436715161411, 'wollein.hannes@gmail.com')
Insert into tblCustomer values ('Bauer', 'Agata', 2, 'Widerhoferplatz', 20, 1090, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436715261411, 'bauer.agata@gmail.com')
Insert into tblCustomer values ('Dankl', 'Johannes', 1, 'FranzSchuh.Gasse', '9', 1100, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436761531411, 'dankl.johannes@gmail.com')
Insert into tblCustomer values ('Warkenthin', 'Geri', 1, 'Wallgasse', '2/8', 1060, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43676311411, 'warkenthin.geri@gmail.com')
Insert into tblCustomer values ('Leshem', 'Markus', 1, 'Zwettlerstraße', '19/31', 3920, 'Groß-Gerungs', 32, '2013-10-20 15:09:12.1234567', 436761541411, 'leshem.markus@gmail.com')
Insert into tblCustomer values ('Vafaikish', 'Turadj', 1, 'Burggasse', '4', 1070, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763561511, 'vafaikish.turadj@gmail.com')
Insert into tblCustomer values ('Skorpis', 'Manfred', 1, 'Lugeck', '16', 1010, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763515611, 'skorpis34.manfred@gmail.com')
Insert into tblCustomer values ('Berndorfer', 'Marta', 2, 'Währinger Gürtel', '13/5', 1180, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763157411, 'berndorfer.marta@gmail.com')
Insert into tblCustomer values ('Butunoi', 'Gabriella', 2, 'Burgring', '3', 1010, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763158111, 'butunoi.gabriella@gmail.com')
Insert into tblCustomer values ('Csepela', 'Cordelia', 2, 'Untere Viaduktg.', '9/2/28', 1032, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436761591411, 'csepela.cordelia@gmail.com')
Insert into tblCustomer values ('Franke', 'Gudrun', 2, 'Pfeilgasse', '7/5', 1080, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763516011, 'franke.gudrun@gmail.com')
Insert into tblCustomer values ('Müller', 'Heidrun', 1, 'Ketzergasse', '29', 2380, 'Perchtoldsdorf', 32, '2013-10-20 15:09:12.1234567', 436763161411, 'müller.heidrun@gmail.com')
Insert into tblCustomer values ('Ren', 'Elke', 2, 'Spittelbreitengasse', '3/3/2', 1120, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763162411, 'ren.elke@gmail.com')
Insert into tblCustomer values ('Hinterndorfer', 'Elisabeth', 2, 'Leonard Bernsteinstr.', '6/18', 1220, 'Wien', 32, '2013-10-20 15:09:12.1234567', 4367616361411, 'hinterndorfer.elisabeth@gmail.com')
Insert into tblCustomer values ('Helfert', 'Erich', 1, 'Am Kaisermühlendamm', '6', 1220, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763516411, 'helfert.erich@gmail.com')
Insert into tblCustomer values ('Finatti', 'Luise', 2, 'Reisnerstr.', '7/5', 1032, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763564651, 'finatti.luise@gmail.com')
Insert into tblCustomer values ('Gindl', 'Horst', 1, 'Glockenblumengasse', '114', 1220, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43676316611, 'gindl.horst@gmail.com')
Insert into tblCustomer values ('Donhoffer', 'Anna', 2, 'Traungauergasse', '9/16', 8020, 'Graz', 32, '2013-10-20 15:09:12.1234567', 436763516711, 'donhoffer.anna@gmail.com')
Insert into tblCustomer values ('Peter', 'Wolfgang', 1, 'Kurzbauergasse', '24', 1020, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763561681, 'peter.wolfgang@gmail.com')
Insert into tblCustomer values ('Köksal', 'Elif', 2, 'Daringergasse', '2/a', 1190, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43676351691, 'köksal.elif@gmail.com')
Insert into tblCustomer values ('Hinterndorfer', 'Michaela', 2, 'Hummelg.', '57/3/3', 1132, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763517011, 'hinterndorfer.michaela@gmail.com')
Insert into tblCustomer values ('Nikrang-Mofrad', 'Linde', 2, 'Blechturmgasse', '44/6', 1040, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763517101, 'nikrang-mofrad.linde@gmail.com')
Insert into tblCustomer values ('Pany', 'Peter', 1, 'Konsumstraße', '25', 2331, 'Vösendorf', 32, '2013-10-20 15:09:12.1234567', 43676351721, 'pany.peter@gmail.com')
Insert into tblCustomer values ('Huber', 'Astrid', 2, 'Hackhofergasse', '5/2', 1190, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763517311, 'huber.astrid@gmail.com')
Insert into tblCustomer values ('Massenbauer', 'Helga', 2, 'Clementinengasse', '46/18', 1150, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43676317441, 'massenbauer.helga@gmail.com')
Insert into tblCustomer values ('Schiff', 'Elke', 2, 'Leonard Bernsteinstr.', '3/1/13', 1220, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436761751411, 'schiff.elke@gmail.com')
Insert into tblCustomer values ('Bugl', 'Gusti', 2, 'Wallgasse', '97/1/3', 1060, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763176411, 'bugl.gusti@gmail.com')
Insert into tblCustomer values ('Thometits', 'Sharon', 2, 'Burggasse', '4', 1070, 'Wien', 32, '2013-10-20 15:09:12.1234567', 43676177411, 'thometits.sharon@gmail.com')
Insert into tblCustomer values ('Dorner', 'Herbert', 1, 'Frauentorg.', '10', 3432, 'Tulln', 32, '2013-10-20 15:09:12.1234567', 43676991411, 'dorner.herbert@gmail.com')
Insert into tblCustomer values ('Schuh', 'Detlef', 1, 'Sternwartestraße', '10/14', 1180, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436769861411, 'schuh.detlef@gmail.com')
Insert into tblCustomer values ('Säumig', 'Ronald', 1, 'Spießhammerg.', '1/5', 1120, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436763551411, 'säumig.ronald@gmail.com')
Insert into tblCustomer values ('Neumann', 'Helmut', 1, 'Simmeringer Hauptstraße', '1/33', 1110, 'Wien', 32, '2013-10-20 15:09:12.1234567', 436663561411, 'neumann.helmut@gmail.com')



-- tblSalespersons & tblSalespersonsSecretData DATA uploading

execute spSalespersonsUpdateOrInsert @SalesId = 0, @FirstName = 'Incoming Order Manager', @LastName = 'Ordering Automatic', @SexName = 'kein Eintrag', 
@SpokenLanguesName = 'Andere Sprache', @ManagerId = 0, @DateOfBirth = '2003-10-20 15:09:12.1234567', @Street = 'Car Dealership', 
@House_Number = '8', @PostalCode = 1010, @Location = 'Wien', @CountryName = 'Österreich', 
@EntryDate = '2013-10-20 15:09:12.1234567', @TelNr = 366724760, @Email = 'car.dealership.vienna@car.com'
Insert into tblSalespersons values ('Maria','Hansel', 2, 4, 7)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 1020,'Wien',32,
'2019-11-25 10:42:56.1234567', 15204567476,'dgr.vienna@gmail.com')
Insert into tblSalespersons values ('Arpad','Ruttinger', 1, 4, 11)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 1020,'Wien',32,
'2019-11-25 10:42:56.1234567', 1527867476,'jkt.vienna@gmail.com')
Insert into tblSalespersons values ('Porod','Annemarie', 2, 8, 9)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 1020,'Wien',32,
'2019-11-25 10:42:56.1234567', 15298567476,'dfg.vienna@gmail.com')
Insert into tblSalespersons values ('Weintraud','Anna', 2, 4, 20)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 1020,'Wien',32,
'2019-11-25 10:42:56.1234567', 15245689576,'hg.vienna@gmail.com')
Insert into tblSalespersons values ('Schiller','Herta  ', 2, 9, 11)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 3452,'Wien',32,
'2019-11-25 10:42:56.1234567', 122257476,'dferr.vienna@gmail.com')
Insert into tblSalespersons values ('Kutil','Christine', 2, 14, 11)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 4566,'Wien',32,
'2019-11-25 10:42:56.1234567', 13412367476,'jk1t.vie123nna@gmail.com')
Insert into tblSalespersons values ('Oswald','Willi', 1, 5, 15)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 2345,'Wien',32,
'2019-11-25 10:42:56.1234567', 152985674726,'df32g.vi12enna@gmail.com')
Insert into tblSalespersons values ('Grimm','Maria', 2, 13, 11)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 1524435576,'hg.vie34nna@gmail.com')
Insert into tblSalespersons values ('Grimm','Maria', 2, 13, 11)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 152400000576,'orbfib.vie34nna@gmail.com')
Insert into tblSalespersons values ('Marischler','Elisabeth', 2, 13, 15)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 157454435576,'h365g.vie34nna@gmail.com')
Insert into tblSalespersons values ('Woldrich','Maria', 2, 13, 20)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 150005576,'hbsfg.vnna@gmail.com')
Insert into tblSalespersons values ('Teubel','Frieda', 2, 13, 15)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 153333335576,'bwr5tgh4.vie34nna@gmail.com')
Insert into tblSalespersons values ('Staudigl','Valerie', 2, 1, 11)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 15244331550,'rthw53.vienna@gmail.com')
Insert into tblSalespersons values ('Lederer','Brigitte', 2, 8, 11)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 5234435576,'uutz.vie3adgnna@gmail.com')
Insert into tblSalespersons values ('Frauwallner','Johann', 1, 16, 9)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 2534435576,'taver.vie3fnna@gmail.com')
Insert into tblSalespersons values ('Stark','Erich', 1, 18, NULL)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 423564435576,'ertzb.viertbnna@gmail.com')
Insert into tblSalespersons values ('Urbaschek','Franz', 1, 7, 20)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 1524325576,'wertzfv.tzh@gmail.com')
Insert into tblSalespersons values ('Owessle','Adelheid', 2, 9, 7)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 4445576,'ft12h.unt@gmail.com')
Insert into tblSalespersons values ('Lorich','Beate', 2, 17, 11)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 3335576,'rvg43g4.cvbnm@gmail.com')
Insert into tblSalespersons values ('Kotzian','Rosemarie', 2, 5, 11)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 98764435576,'klpzu.vie24nna@gmail.com')
Insert into tblSalespersons values ('Oberndorfer','Anna', 2, 13, 15)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 15777776,'qwery3f.viertnna@gmail.com')
Insert into tblSalespersons values ('Jarmer','Klaus', 1, 8, 11)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 152557341576,'aaecwev.xuefg@gmail.com')
Insert into tblSalespersons values ('Böhm','Karoline', 2, 13, 9)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 125467776,'aqaaea.vienna@gmail.com')
Insert into tblSalespersons values ('Pfleger','Andrea', 2, 21, 20)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 867376,'veaghr.lfzjb@gmail.com')
Insert into tblSalespersons values ('Sobotka','Eva', 2, 20, 7)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 27746645,'nsdubrg.reva@gmail.com')
Insert into tblSalespersons values ('Radvan','Anna', 2, 13, 9)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 77723576,'tzwstr.vie3rwnna@gmail.com')
Insert into tblSalespersons values ('Ritter','Gertrude', 2, 6, 11)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 5537357555,'baehd.vjafnna@gmail.com')
Insert into tblSalespersons values ('Grünzweig','Maria', 2, 9, 20)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 376852111,'vre5vbf5b.v47nna@gmail.com')
Insert into tblSalespersons values ('Würth','Irmgard', 2, 2, 9)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 10000576,'rutbmu.viemun nna@gmail.com')
Insert into tblSalespersons values ('Kantler','Margarete', 2, 1, 20)
Insert into tblSalespersonsSecretData values (IDENT_CURRENT('tblSalespersons'), '2003-10-20 15:09:12.1234567','Kräntner Strasse', '8-9', 6254,'Wien',32,
'2019-11-25 10:42:56.1234567', 15244300006,'hgdgcgvgjbdfhvc@gmail.com')






go

-- tblCarAccessories & tblCarAccessoriesStock DATA uploading

Insert into tblCarAccessories values ('Sitzbezüge', 1, 16.99, 1, 1, 'LIONSTRONG', '2013-10-20 15:09:12.1234567', 'Sitzbezüge Sitzschoner für Autositze, Sitzbezug Werkstatt Auto, universal Autositzschoner, Sitzbezüge, wasserdichter Stoff (Polyester)', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1500, null)

Insert into tblCarAccessories values ('Gepäckraumschalen', 1, 49.99, 1, 1, 'M MOTOS', '2013-10-20 15:09:12.1234567', 'Kofferraumwanne Kofferraummatte passt für Audi Q3 II, unterer Kofferraumboden 2018 Verbessern Sie Ihren Reisekomfort mit Antirutschmatte Auto', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 7000, 500, null)

Insert into tblCarAccessories values ('Kühlbox', 1, 62.84, 1, 1, 'AEG', '2013-10-20 15:09:12.1234567', 'AEG Automotive Thermoelektrische Kühl- und Warmhaltebox KK 14 Liter, 12 Volt für Auto und', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 4800, 300, null)

Insert into tblCarAccessories values ('Lenkradschutz', 1, 29.99, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Lenkradschutz', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1500, null)

Insert into tblCarAccessories values ('Lenkschloss', 1, 89, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Lenkschloss', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 6500, 500, null)

Insert into tblCarAccessories values ('Kühltasche', 1, 17, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Kühltasche', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Auto-Staubsauger', 1, 49, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Auto-Staubsauger', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 2500, 250, null)

Insert into tblCarAccessories values ('Windschutzscheibendecke', 1, 18.99, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Windschutzscheibendecke', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Autositzschutz', 1, 22.97, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Autositzschutz', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 600, null)

Insert into tblCarAccessories values ('Nackenkissen', 1, 29.95, 1, 1,'Oneil', '2013-10-20 15:09:12.1234567', 'Nackenkissen', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 700, null)

Insert into tblCarAccessories values ('Anti-Rutsch-Armaturenbrett', 1, 10.99, 2, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Anti-Rutsch-Armaturenbrett', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Lenkradtaste', 1, 48.81, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Lenkradtaste', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 800, null)

Insert into tblCarAccessories values ('Beheizter Sitzbezug', 1, 37.99, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Beheizter Sitzbezug', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 8000, 500, null)

Insert into tblCarAccessories values ('Armlehne', 1, 20.5, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Armlehne', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 5000, 300, null)

Insert into tblCarAccessories values ('Fahrradträger', 1, 278, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Fahrradträger', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 2000, 200, null)

Insert into tblCarAccessories values ('Kindersitz', 1, 142.8, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Kindersitz', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 6000, 500, null)

Insert into tblCarAccessories values ('Nummernschildhalterung ', 1, 23.99, 1, 1, 'GENMAG', '2013-10-20 15:09:12.1234567', 'Nummernschildhalterung ', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)


-- Autoreinigungs
Insert into tblCarAccessories values ('Hirschleder Schal', 2, 20.9, 1, 1, 'LINDENMANN', '2013-10-20 15:09:12.1234567', 'Hirschleder Schal', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 900, null)

Insert into tblCarAccessories values ('Mikrofasertücher', 2, 14.9, 5, 1, 'GLART', '2013-10-20 15:09:12.1234567', 'Mikrofasertücher', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 850, null)

Insert into tblCarAccessories values ('Schwämme', 2, 8.95, 5, 1, 'SONAX', '2013-10-20 15:09:12.1234567', 'Schwämme', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1500, null)

Insert into tblCarAccessories values ('Auto Lufterfrischer', 2, 59.95, 1, 1, 'Febreze', '2013-10-20 15:09:12.1234567', 'Auto Lufterfrischer', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 50000, 2000, null)

Insert into tblCarAccessories values ('Auto Luftentfeuchter', 2, 19.99, 1, 1, 'LICARGO', '2013-10-20 15:09:12.1234567', 'Auto Luftentfeuchter', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Reinigungsbürste', 2, 13.99, 3, 1, 'SONAX', '2013-10-20 15:09:12.1234567', 'Reinigungsbürste', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1300, null)

Insert into tblCarAccessories values ('Gummiwischer', 2, 32.99, 2, 1, 'COFIT', '2013-10-20 15:09:12.1234567', 'Gummiwischer', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 5000, 500, null)

Insert into tblCarAccessories values ('Hochdruckreiniger', 2, 78.82, 1, 1, 'BOSCH', '2013-10-20 15:09:12.1234567', 'Hochdruckreiniger', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 2500, 400, null)

Insert into tblCarAccessories values ('Händedesinfektionsmittel', 2, 32.99, 0.5, 2, 'SONAX', '2013-10-20 15:09:12.1234567', 'Händedesinfektionsmittel', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1500, null)

Insert into tblCarAccessories values ('Papierhandtuch', 2, 41.95, 8, 1, 'Tork', '2013-10-20 15:09:12.1234567', 'Papierhandtuch', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Autowaschbürste', 2, 13.99, 2, 1, 'WillingHeart', '2013-10-20 15:09:12.1234567', 'Autowaschbürste', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1100, null)

Insert into tblCarAccessories values ('Felgenreinigungsbürste', 2, 19.99, 1, 1, 'LICARGO', '2013-10-20 15:09:12.1234567', 'Felgenreinigungsbürste', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 500, null)

Insert into tblCarAccessories values ('Reinigungstücher', 2, 8.32, 3, 1, 'SONAX', '2013-10-20 15:09:12.1234567', 'Reinigungstücher', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 2000, null)


-- Winter-Autozubehör
Insert into tblCarAccessories values ('Glasreiniger', 3, 29.99, 0.7, 2, 'LICARGO', '2013-10-20 15:09:12.1234567', 'Glasreiniger', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1100, null)

Insert into tblCarAccessories values ('Eiskratzer', 3, 11.98, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Eiskratzer', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 800, null)

Insert into tblCarAccessories values ('Schneeketten', 3, 107.99, 1, 1, 'MICHELIN', '2013-10-20 15:09:12.1234567', 'Schneeketten', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 6000, 500, null)

Insert into tblCarAccessories values ('Dachbox', 3, 76.49, 1, 1, 'NABIYE', '2013-10-20 15:09:12.1234567', 'Dachbox', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 5000, 400, null)

Insert into tblCarAccessories values ('Skitasche', 3, 59.99, 1, 1, 'Brubaker', '2013-10-20 15:09:12.1234567', 'Skitasche', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)



-- Straßennotfälle und Erste Hilfe
Insert into tblCarAccessories values ('Arbeitshandschuhe', 4, 19.98, 1, 1, 'Uvex', '2013-10-20 15:09:12.1234567', 'Arbeitshandschuhe', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1500, null)

Insert into tblCarAccessories values ('Erste-Hilfe-Kit für das Auto', 4, 22.99, 1, 1, 'Oneil', '2013-10-20 15:09:12.1234567', 'Erste-Hilfe-Kit für das Auto', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Warndreieck', 4, 16.99, 1, 1, 'AYKRM', '2013-10-20 15:09:12.1234567', 'Warndreieck', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1300, null)

Insert into tblCarAccessories values ('Hammer zum Glasbrechen', 4, 18.49, 1, 1, 'Heldenwerk', '2013-10-20 15:09:12.1234567', 'Hammer zum Glasbrechen', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1500, null)

Insert into tblCarAccessories values ('Feuerlöscher', 4, 29.39, 1, 1, 'Brandengel', '2013-10-20 15:09:12.1234567', 'Feuerlöscher', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 800, null)

Insert into tblCarAccessories values ('Warnweste', 4, 5.94, 1, 1, 'SULWZM', '2013-10-20 15:09:12.1234567', 'Warnweste', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 900, null)

Insert into tblCarAccessories values ('Bull-Kabel', 4, 53.99, 1, 1, 'EBROM', '2013-10-20 15:09:12.1234567', 'Bull-Kabel', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Taschenlampe', 4, 34.99, 1, 1, 'LE LED', '2013-10-20 15:09:12.1234567', 'Taschenlampe', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 100000, 2000, null)

Insert into tblCarAccessories values ('Abschleppseil', 4, 24.95, 1, 1, 'Tadussi', '2013-10-20 15:09:12.1234567', 'Abschleppseil', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 800, null)

Insert into tblCarAccessories values ('Hebegurt', 4, 19.99, 1, 1, 'Tubayia', '2013-10-20 15:09:12.1234567', 'Hebegurt', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Benzinkanister', 4, 64.75, 1, 1, 'CHARON', '2013-10-20 15:09:12.1234567', 'Benzinkanister 20 Liter', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1500, null)

Insert into tblCarAccessories values ('Schneeschaufel', 4, 24.99, 1, 1, 'CLISPEED', '2013-10-20 15:09:12.1234567', 'Schneeschaufel', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 2000, null)

Insert into tblCarAccessories values ('Alkoholtester Digital', 4, 31.99, 1, 1, 'ACE', '2013-10-20 15:09:12.1234567', 'Alkoholtester Digital', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 500, null)

Insert into tblCarAccessories values ('Montagerampe', 4, 84.99, 1, 1, 'XMTECH', '2013-10-20 15:09:12.1234567', 'Montagerampe', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1700, null)

Insert into tblCarAccessories values ('CB-Funk', 4, 32.99, 2, 1, 'Radtel', '2013-10-20 15:09:12.1234567', 'CB-Funk', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 3000, 300, null)

Insert into tblCarAccessories values ('Installationslampe', 4, 17.99, 1, 1, 'LICARGO', '2013-10-20 15:09:12.1234567', 'Installationslampe', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 2000, null)

Insert into tblCarAccessories values ('Batterieladegeräte', 4, 118.54, 1, 1, 'NOCO', '2013-10-20 15:09:12.1234567', 'Batterieladegeräte', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 4000, 500, null)

Insert into tblCarAccessories values ('Warnlicht', 4, 69.99, 1, 1, 'LE LED', '2013-10-20 15:09:12.1234567', 'Warnlicht', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 3000, 350, null)

Insert into tblCarAccessories values ('Scheuklappen', 4, 19.9, 1, 1, 'Carbigo', '2013-10-20 15:09:12.1234567', 'Scheuklappen', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 500, null)

Insert into tblCarAccessories values ('Scheinwerfer', 4, 39.99, 1, 1, 'MONDEVIEW', '2013-10-20 15:09:12.1234567', 'Scheinwerfer', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 500, null)

Insert into tblCarAccessories values ('Deichsel', 4, 45.94, 1, 1, 'FISCHER', '2013-10-20 15:09:12.1234567', 'Deichsel', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 500, null)


--Zubehör für Autotelefone
Insert into tblCarAccessories values ('Freisprecheinrichtung im Auto', 5, 59.97, 1, 1, 'VeoPulse', '2013-10-20 15:09:12.1234567', 'Freisprecheinrichtung im Auto', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 500, null)

Insert into tblCarAccessories values ('Auto-Ladegerät für Handy', 5, 15.99, 1, 1, 'Syncwire', '2013-10-20 15:09:12.1234567', 'Auto-Ladegerät für Handy', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 100000, 3000, null)

Insert into tblCarAccessories values ('Autotelefonhalter', 5, 29.99, 1, 1, 'VANMASS', '2013-10-20 15:09:12.1234567', 'Autotelefonhalter', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 100000, 2500, null)



--Schutzausrüstung

Insert into tblCarAccessories values ('Augenschutz', 6, 19.99, 1, 1, 'SolidWork', '2013-10-20 15:09:12.1234567', 'Augenschutz', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Arbeitshosen und Overalls', 6, 59.99, 1, 1, 'Uvex', '2013-10-20 15:09:12.1234567', 'Arbeitshosen und Overalls', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 5000, 500, null)

Insert into tblCarAccessories values ('Ohrschutz', 6, 15.99, 1, 1, 'Senner', '2013-10-20 15:09:12.1234567', 'Ohrschutz', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 500, null)

Insert into tblCarAccessories values ('Staubmasken und Atemschutzmasken', 6, 26.89, 1, 1, 'Vanderfields', '2013-10-20 15:09:12.1234567', 'Staubmasken und Atemschutzmasken', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1100, null)

Insert into tblCarAccessories values ('Sicheres Schuhwerk', 6, 49.99, 1, 1, 'TAERGU', '2013-10-20 15:09:12.1234567', 'Sicheres Schuhwerk', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Schutz vor Schweißen', 6, 45, 1, 1, 'ANUNU', '2013-10-20 15:09:12.1234567', 'Schutz vor Schweißen Vollmaske mit Filter', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 1000, 300, null)

Insert into tblCarAccessories values ('Arbeitshemden', 6, 25.90, 1, 1, 'LUCKY', '2013-10-20 15:09:12.1234567', 'Arbeitshemden Thermojacke Arbeitshemd Herren Holzfäller Langarm', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Arbeitsjacken und -westen', 6, 45, 1, 1, 'ADAC', '2013-10-20 15:09:12.1234567', 'Arbeitsjacken und -westen', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 500, null)


-- Unterhaltung im Auto,

Insert into tblCarAccessories values ('Schallschutzplatte', 7, 79.99, 1, 1, 'GMP Tech', '2013-10-20 15:09:12.1234567', 'Akustikschaumstoff Selbstklebend Pyramide Matte 200x100 x 8 cm von GMP Tech beauty of sound - Dämmung', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1500, null)

Insert into tblCarAccessories values ('Autoradio', 7, 164.80, 1, 1, 'Pioneer', '2013-10-20 15:09:12.1234567', 'Autoradio Pioneer 15,2 cm (6,2 Zoll) 2-DIN-Display mit Bluetooth', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 5000, 400, null)

Insert into tblCarAccessories values ('Auto Lautsprecher', 7, 82.99, 1, 1, 'Herdio', '2013-10-20 15:09:12.1234567', 'Auto Lautsprecher Herdio 6,5 Zoll Deckenlautsprecher, 160 Watt Bluetooth Einbaulautsprecher, Bündige Montage Sound, für Zuhause Badezimmer Küche Büro mit Full Range Sound', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 1000, null)

Insert into tblCarAccessories values ('Auto Verstärker', 7, 99.9, 1, 1, 'Sony', '2013-10-20 15:09:12.1234567', 'Auto Verstärker Sony XMN1004 Kfz-Verstärker (1000 Watt)', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 6000, 500, null)

Insert into tblCarAccessories values ('Multimedia-Haupteinheit', 7, 289.99, 1, 1, 'BOOYES', '2013-10-20 15:09:12.1234567', 'Multimedia-Haupteinheit BOOYES für Mercedes-Benz W169 W245 B160 B170 B180 B200 W639 Vito Viano W906 Sprinter', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 4000, 500, null)

Insert into tblCarAccessories values ('Subwoofer', 7, 45, 1, 1, 'JBL', '2013-10-20 15:09:12.1234567', 'Subwoofer JBL Stadium 102SSI 10 Zoll Subwoofer Auto Set von Harman Kardon - Leistungsstarke 1350 Watt Kfz Bassbox Autolautsprecher - 30Hz – 175Hz - 250mm mit SSI Impedanzschalter', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 10000, 500, null)

Insert into tblCarAccessories values ('Autoradio-Kondensator', 7, 14.99, 1, 1, 'Hama', '2013-10-20 15:09:12.1234567', 'Autoradio-Kondensator Hama Hochleistungs-Entstörfilter, 10 Amp', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 5000, 500, null)

Insert into tblCarAccessories values ('Autoradio-Kabelsatz', 7, 15.49, 1, 1, '‎Adapter-Universe', '2013-10-20 15:09:12.1234567', 'Autoradio-Kabelsatz Adapter Kabel Auto Radio aktiv System ISO kompatibel mit Audi VW Seat Bose DSP', 1, null)
Insert into tblCarAccessoriesStock values (IDENT_CURRENT('tblCarAccessories'), 3000, 500, null)


-- Upload Email from alter Customers & Salespersons email
execute spEmailUploadFromAlterData
go

