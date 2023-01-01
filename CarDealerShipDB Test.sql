------ Cars SEARCH --------------------------------------------------------------------------------------
execute spCarsSearchDynamicSQL @CarId = NULL, @Model = NULL, @Color = NULL, @Number_of_seats = NULL, 
@Year_of_production = NULL, @FuelName = 'diesel', @GearboxName = 'manual', 
@Cubic_capacity = NULL, @Mileage = NULL, @Chassis_number = NULL, 
@Engine_power = NULL, @Own_Weight = NULL, @Sold = NULL, @NettoPrice = NULL
go
---- CARS Delete ------------------------------------------------------------------------------------------------
execute spCarsDelete @CarId = 2
go
Delete from vWCarsDetails where CarId IN (3, 4)
go
------ CARS Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @CarId = létezõ
execute spCarsUpdateOrInsert @CarId = 1000001, @Model = 'Update', @Color = 'Update', @Number_of_seats = 2, 
@Year_of_production = '2011-10-20 15:09:12.1234567', @FuelName = 'Benzin', @GearboxName = 'automat', 
@Cubic_capacity = 2000, @Mileage = 560031, @Chassis_number = 'wx0jsdfnu5', 
@Engine_power = 80, @Own_Weight = 1100, @Sold = 0, @NettoPrice = 14000
-- Insert with selected ID = @CarId = selected
execute spCarsUpdateOrInsert @CarId = 1000100, @Model = 'AudiA9', @Color = 'Gold', @Number_of_seats = 5, 
@Year_of_production = '2021-10-20 15:09:12.1234567', @FuelName = 'Benzin', @GearboxName = 'automat', 
@Cubic_capacity = 2000, @Mileage = 0, @Chassis_number = 'wx0jsdknwoihnst', 
@Engine_power = 150, @Own_Weight = 1100, @Sold = 0, @NettoPrice = 34000
-- Insert with next Id =@CarId = NULL
execute spCarsUpdateOrInsert @CarId = NULL, @Model = 'Audi', @Color = 'Gold', @Number_of_seats = 2, 
@Year_of_production = '2021-10-20 15:09:12.1234567', @FuelName = 'Benzin', @GearboxName = 'automat', 
@Cubic_capacity = 5000, @Mileage = 0, @Chassis_number = 'wx0jsdknwoi3oi32', 
@Engine_power = 400, @Own_Weight = 1300, @Sold = 0, @NettoPrice = 65000



------ Fuel SEARCH --------------------------------------------------------------------------------------
execute spFuelSearchDynamicSQL @FuelId = null, @FuelName = 's'
go

---- FUEL Delete ------------------------------------------------------------------------------------------------
execute spFuelDelete @FuelId = 2
go
Delete from tblFuel where FuelId IN (3, 4)
go
------ FUEL Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @FuelId = létezõ
execute spFuelUpdateOrInsert @FuelId = 1, @FuelName = 'Update'
-- Insert with selected ID = @FuelId = selected
execute spFuelUpdateOrInsert @FuelId = 9, @FuelName = 'Kerosin'
-- Insert with next Id = @FuelId = NULL
execute spFuelUpdateOrInsert @FuelId = NULL, @FuelName = 'Alkohol'
go



------ Gearbox SEARCH --------------------------------------------------------------------------------------
execute spGearboxSearchDynamicSQL @GearboxId = null, @GearboxName = ''
go
---- Gearbox Delete ------------------------------------------------------------------------------------------------
execute spGearboxDelete @GearboxId = 2
go
Delete from tblGearbox where GearboxId IN (3, 4)
go
------ Gearbox Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @GearboxId = létezõ
execute spGearboxUpdateOrInsert @GearboxId = 1, @GearboxName = 'Update'
-- Insert with selected ID = @GearboxId = selected
execute spGearboxUpdateOrInsert @GearboxId = 9, @GearboxName = 'Kerosin'
-- Insert with next Id = @GearboxId = NULL
execute spGearboxUpdateOrInsert @GearboxId = NULL, @GearboxName = 'Alkohol'
go

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------------- CUSTOMER -----------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

go
------- CUSTOMER SEARCH ------------------------------------------
------- CUSTOMER SEARCH ------------------------------------------
execute spCustomerSearchDynamicSQL @CustomerId=Null, @FirstName = NULL, @LastName = 'Toth', @SexName = 'weiblich', 
@Street = NULL, @House_Number = NULL, @PostalCode = NULL, 
@Location = NULL, @CountryName = NULL, @DateOfBirth = NULL, 
@TelNr = NULL, @Email = NULL
go
---- CUSTOMER Delete ------------------------------------------------------------------------------------------------
execute spCustomerDelete @CustomerId = 2
go
Delete from vWCustomerAllData where CustomerId IN (3, 4)
go
------ CUSTOMER Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @CustomerId = létezõ
execute spCustomerUpdateOrInsert @CustomerId = 1, @FirstName = 'Update', @LastName = 'Update', @SexName = 'weiblich', 
@Street = 'Update', @House_Number = 'Update', @PostalCode = 1020, 
@Location = 'Update', @CountryName = 'Update', @DateOfBirth = '1915-10-20 15:09:12.1234567', 
@TelNr = 32456256, @Email = 'Update.vienna@gmail.com'
-- Insert with selected ID = @CustomerId = selected
execute spCustomerUpdateOrInsert @CustomerId = 100, @FirstName = 'Ramóna', @LastName = 'Toth', @SexName = 'weiblich', 
@Street = 'Insert', @House_Number = 'Insert', @PostalCode = 1020, 
@Location = 'Insert', @CountryName = 'Insert', @DateOfBirth = '1955-10-20 15:09:12.1234567', 
@TelNr = 32896256, @Email = 'Insert.vienna@gmail.com'
-- Insert with next Id = @CustomerId = NULL
execute spCustomerUpdateOrInsert @CustomerId = NULL, @FirstName = 'Insert', @LastName = 'Insert', @SexName = 'weiblich', 
@Street = 'Insert', @House_Number = 'Insert', @PostalCode = 1020, 
@Location = 'Insert', @CountryName = 'Insert', @DateOfBirth = '1993-10-20 15:09:12.1234567', 
@TelNr = 32246256, @Email = 'Insertnext.vienna@gmail.com'
go

------ SEX SEARCH --------------------------------------------------------------------------------------
execute spSexSearchDynamicSQL @SexId=Null, @SexName = ''
go
---- SEX Delete ------------------------------------------------------------------------------------------------
execute spSexDelete @SexId = 2
go
Delete from tblSex where SexId IN (3, 4)
------ SEX Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @SexId = létezõ
execute spSexUpdateOrInsert @SexId = 1, @SexName = 'Update'
-- Insert with selected ID = @SexId = selected
execute spSexUpdateOrInsert @SexId = 9, @SexName = 'Insertselected'
-- Insert with next Id = @SexId = NULL
execute spSexUpdateOrInsert @SexId = NULL, @SexName = 'Insertnext'
go


------ Country SEARCH --------------------------------------------------------------------------------------
execute spCountrySearchDynamicSQL @CountryId=Null, @CountryName = NULL, @CountryTaxPercentageValue = NULL
go
---- Country Delete ------------------------------------------------------------------------------------------------
execute spCountryDelete @CountryId = 2
go
Delete from tblCountry where CountryId IN (100, 101)
------ Country Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @CountryId = exist
execute spCountryUpdateOrInsert @CountryId = 3, @CountryName = 'Update', @CountryTaxPercentageValue = 9
-- Insert with selected ID = @CountryId = selected
execute spCountryUpdateOrInsert @CountryId = 100, @CountryName = 'Insert with selected', @CountryTaxPercentageValue = 11
-- Insert with next Id = @CountryId = NULL
execute spCountryUpdateOrInsert @CountryId = NULL, @CountryName = 'Insert with next', @CountryTaxPercentageValue = 13




------ SEX SEARCH --------------------------------------------------------------------------------------
execute spSexSearchDynamicSQL @SexId=Null, @SexName = ''
go
---- SEX Delete ------------------------------------------------------------------------------------------------
Delete from tblSex where SexId IN (3, 4)
------ SEX Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @SexId = létezõ
execute spSexUpdateOrInsert @SexId = 1, @SexName = 'Update'
-- Insert with selected ID = @SexId = selected
execute spSexUpdateOrInsert @SexId = 9, @SexName = 'Insertselected'
-- Insert with next Id = @SexId = NULL
execute spSexUpdateOrInsert @SexId = NULL, @SexName = 'Insertnext'
go


------ Country SEARCH --------------------------------------------------------------------------------------
execute spCountrySearchDynamicSQL @CountryId=Null, @CountryName = NULL, @CountryTaxPercentageValue = NULL
go
---- Country Delete ------------------------------------------------------------------------------------------------
Delete from tblCountry where CountryId IN (100, 101)
------ Country Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @CountryId = exist
execute spCountryUpdateOrInsert @CountryId = 3, @CountryName = 'Update', @CountryTaxPercentageValue = 9
-- Insert with selected ID = @CountryId = selected
execute spCountryUpdateOrInsert @CountryId = 100, @CountryName = 'Insert with selected', @CountryTaxPercentageValue = 11
-- Insert with next Id = @CountryId = NULL
execute spCountryUpdateOrInsert @CountryId = NULL, @CountryName = 'Insert with next', @CountryTaxPercentageValue = 13






------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------- Salespersons --------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

------ Salespersons SEARCH --------------------------------------------------------------------------------------
execute spSalespersonsSearchDynamicSQL @SalesId = NULL, @FirstName = NULL, @LastName = NULL, @SexName = Null, 
@SpokenLanguesName = NULL, @ManagerId = NULL, @ManagerFirstName = NULL, @ManagerLastName = NULL, @DateOfBirth = NULL, 
@Street = NULL, @House_Number = NULL, @PostalCode = NULL, @Location = NULL, @CountryName = null, 
@EntryDate = NULL, @TelNr = NULL, @Email = NULL
go
----- Salespersons Delete ------------------------------------------------------------------------------------------------
execute spSalespersonsDelete @SalesId = 2
go
Delete from vWSalespersonsAllData where SalesId IN (3, 4)
go
------ Salespersons Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @SalesId = exist
execute spSalespersonsUpdateOrInsert @SalesId = 2, @FirstName = 'Update', @LastName = 'Update', @SexName = 'männlich', 
@SpokenLanguesName = 'Russisch', @ManagerId = 6, @DateOfBirth = '2003-10-20 15:09:12.1234567', @Street = 'Operngasse', 
@House_Number = '80', @PostalCode = 1010, @Location = 'Wien', @CountryName = 'Österreich', 
@EntryDate = '2013-10-20 15:09:12.1234567', @TelNr = 3666760, @Email = 'paliwer6ss.vienna@gmail.com'
-- Insert with selected ID = @SalesId = selected
execute spSalespersonsUpdateOrInsert @SalesId = 100, @FirstName = 'Insert with selected', @LastName = 'Insert with selected', @SexName = 'männlich', 
@SpokenLanguesName = 'Russisch', @ManagerId = 6, @DateOfBirth = '2003-10-20 15:09:12.1234567', @Street = 'Operngasse', 
@House_Number = '80', @PostalCode = 1010, @Location = 'Wien', @CountryName = 'Österreich', 
@EntryDate = '2013-10-20 15:09:12.1234567', @TelNr = 366724760, @Email = 'paliw4536ss.vienna@gmail.com'
-- Insert with next Id =@SalesId = NULL
execute spSalespersonsUpdateOrInsert @SalesId = NULL, @FirstName = 'Insert with next', @LastName = 'Insert with next', @SexName = 'männlich', 
@SpokenLanguesName = 'Russisch', @ManagerId = 6, @DateOfBirth = '2003-10-20 15:09:12.1234567', @Street = 'Operngasse', 
@House_Number = '80', @PostalCode = 1010, @Location = 'Wien', @CountryName = 'Österreich', 
@EntryDate = '2013-10-20 15:09:12.1234567', @TelNr = 3666352760, @Email = 'pabrtwer6ss.vienna@gmail.com'
go





------ SpokenLangues SEARCH --------------------------------------------------------------------------------------
execute spSpokenLanguesSearchDynamicSQL @SpokenLanguesId = null, @SpokenLanguesName = ''
go
---- SpokenLangues Delete ------------------------------------------------------------------------------------------------
execute spSpokenLanguesDelete @SpokenLanguesId = 2
go
Delete from tblSpokenLangues where SpokenLanguesId IN (15, 17)
go
------ SpokenLanguages Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @SpokenLanguesId = exist
execute spSpokenLanguesUpdateOrInsert @SpokenLanguesId = 3, @SpokenLanguesName = 'Update'
-- Insert with selected ID = @SpokenLanguesId = selected
execute spSpokenLanguesUpdateOrInsert @SpokenLanguesId = 100, @SpokenLanguesName = 'Insert with selected'
-- Insert with next Id = @SpokenLanguesId = NULL
execute spSpokenLanguesUpdateOrInsert @SpokenLanguesId = NULL, @SpokenLanguesName = 'Insert with next'


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------- CarAccessories  ----------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------ CarAccessories SEARCH --------------------------------------------------------------------------------------
execute spCarAccessoriesSearchDynamicSQL @CAId = NULL, @ProductName = NULL, @CAPGName = NULL, @QuantityOfStock = NULL, 
@MinimumStockQuantity = NULL, @NetSellingPrice = NULL, @SalesUnit = NULL, @UnitPrice = NULL, @UnitName = NULL, 
@LastUpdateTime = NULL, @Brand = NULL, @CreationDate = NULL, @Description = NULL, @Version = NULL, @PhotoPath = NULL
----- CarAccessoriesId Delete ------------------------------------------------------------------------------------------------
go
execute spCarAccessoriesDelete @CarAccessoriesId = 2
go
Delete from vWCarAccessoriesAllData where CarAccessoriesId IN (3, 4)
go
------ CarAccessories Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @CarAccessoriesId = exist
execute spCarAccessoriesUpdateOrInsert @CarAccessoriesId = 10, @ProductName = 'Update', @CAPGName = 'Autoreinigungs', @QuantityOfStock = 100000, 
@MinimumStockQuantity = 500, @NetSellingPrice = 50000, @SalesUnit = 0.1, @UnitPrice = NULL, @UnitName = '€uro/Liter', @LastUpdateTime = NULL, 
@Brand = 'Update', @CreationDate = '1900-10-20 15:09:12.1234567', @Description = 'Update', @Version = 10000, @PhotoPath = NULL
-- Insert with selected ID = @CarAccessoriesId = selected
execute spCarAccessoriesUpdateOrInsert @CarAccessoriesId = 1000, @ProductName = 'Insert with selected', @CAPGName = 'Autoreinigungs', @QuantityOfStock = 100000, 
@MinimumStockQuantity = 500, @NetSellingPrice = 50000, @SalesUnit = 0.1, @UnitPrice = NULL, @UnitName = '€uro/Liter', @LastUpdateTime = NULL, 
@Brand = 'Insert with selected', @CreationDate = '1900-10-20 15:09:12.1234567', @Description = 'Insert with selected', @Version = 10000, @PhotoPath = NULL
-- Insert with next Id =@CarAccessoriesId = NULL
execute spCarAccessoriesUpdateOrInsert @CarAccessoriesId = NULL, @ProductName = 'Insert with next', @CAPGName = 'Autoreinigungs', @QuantityOfStock = 100000, 
@MinimumStockQuantity = 900, @NetSellingPrice = 50000, @SalesUnit = 0.1, @UnitPrice = NULL, @UnitName = '€uro/Liter', @LastUpdateTime = NULL, 
@Brand = 'Insert with next', @CreationDate = '1900-10-20 15:09:12.1234567', @Description = 'Insert with next', @Version = 10000, @PhotoPath = NULL
go



------ CarAccessoriesProductGroup SEARCH --------------------------------------------------------------------------------------
execute spCarAccessoriesProductGroupSearchDynamicSQL @CAPGId = NULL, @CAPGName = ''
go
---- CarAccessoriesProductGroup Delete ------------------------------------------------------------------------------------------------
execute spCarAccessoriesProductGroupDelete @CAPGId = 2
go
Delete from tblCarAccessoriesProductGroup where CAPGId IN (100, 101)
------ CarAccessoriesProductGroup Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @CAPGId = exist
execute spCarAccessoriesProductGroupUpdateOrInsert @CAPGId = 3, @CAPGName = 'Update'
-- Insert with selected ID = @CAPGId = selected
execute spCarAccessoriesProductGroupUpdateOrInsert @CAPGId = 100, @CAPGName = 'Insert with selected'
-- Insert with next Id = @CAPGId = NULL
execute spCarAccessoriesProductGroupUpdateOrInsert @CAPGId = NULL, @CAPGName = 'Insert with next'
go



------ Car Accessories Unit SEARCH --------------------------------------------------------------------------------------
execute spCarAccessoriesUnitSearchDynamicSQL @CAUId = NULL, @UnitName = ''
go
---- Car Accessories Unit Delete ------------------------------------------------------------------------------------------------
execute spCarAccessoriesUnitDelete @CAUId = 2
go
Delete from tblCarAccessoriesUnit where CAUId IN (100, 101)
------ Car Accessories Unit Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @CAUId = exist
execute spCarAccessoriesUnitUpdateOrInsert @CAUId = 3, @UnitName = 'Update'
-- Insert with selected ID = @CAUId = selected
execute spCarAccessoriesUnitUpdateOrInsert @CAUId = 100, @UnitName = 'Insert with selected'
-- Insert with next Id = @CAUId = NULL
execute spCarAccessoriesUnitUpdateOrInsert @CAUId = NULL, @UnitName = 'Insert with next'
go


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------- Orders  ----------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------ Orders SEARCH --------------------------------------------------------------------------------------
execute spOrdersSearchDynamicSQL @OrderId = NULL, @CustomerId = NULL, @CustomerFirstName = NULL, 
@CustomerLastName = NULL, @SalesPersonId  = NULL, @SalesPersonFirstName = NULL, @SalesPersonLastName = NULL, 
@ProductId = NULL, @ProductGroup = NULL, @ProductName = NULL, @CarModel = NULL, @CarColor = NULL, @Quantity = NULL, 
@OrderDate = NULL, @OrderStatusId = NULL, @OrderStatusName = NULL, @Discount = NULL, @ShippedDate = NULL, 
@SaleAmount = NULL, @SaleAmountPaid = NULL, @TaxPercentageValue = NULL, @SaleTime  = NULL, 
@ShoppingCartOrderId =  NULL, @ShoppingCartStatusName = NULL 
go
----- CarAccessoriesId Delete ------------------------------------------------------------------------------------------------
Delete from vWOrdersAllData where OrderId IN (3, 4)
go
---- Orders Delete ------------------------------------------------------------------------------------------------
execute spOrdersDelete @OrderId = 2
go
Delete from vWOrdersAllData where OrderId = 8
Delete from vWOrdersAllData where OrderId IN (5, 6)
go
------ Orders Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @OrderId = exist, automatic quantity posting to warehouse
-- Shopping cart status name cannot be updated from the view. Insert update 'spShoppingCartStatusSettings'
-- Der Statusname des Einkaufswagens kann in der Ansicht nicht aktualisiert werden. Update 'spShoppingCartStatusSettings' einfügen
-- Bevásárló kosár állapotának neve nem frissíthetõ a nézetbõl. Beszúrás, frissítés a 'spShoppingCartStatusSettings'
-- if I update the product or the quantity of the product in the orders table, I also update it in the shopping cart table
-- Wenn ich das Produkt oder die Menge des Produkts in der Bestelltabelle aktualisiere, aktualisiere ich es auch in der Einkaufswagentabelle
-- ha frissítem a rendelések táblázatban a terméket vagy a termék mennyiségét, akkor a bevásárlókosár táblázatban is frissítek
execute spOrdersUpdateOrInsert @OrderId = 4, @CustomerId = 50, @CustomerFirstName = NULL, 
@CustomerLastName = NULL, @SalesPersonId  = 25, @SalesPersonFirstName = NULL, @SalesPersonLastName = NULL, 
@ProductId = 70, @ProductGroup = NULL, @ProductName = NULL, @CarModel = NULL, @CarColor = NULL, @Quantity = 100, 
@OrderDate = '1022-10-08 11:07:23.3033333', @OrderStatusId = 3, @OrderStatusName = NULL, @Discount = 10, 
@ShippedDate = '1800-10-08 11:07:23.3033333', 
@SaleAmount = NULL, @SaleAmountPaid = 80, @TaxPercentageValue = 17, @SaleTime  = '2000-10-08 11:07:23.3033333',
@ShoppingCartOrderId =  NULL, @ShoppingCartStatusName = NULL
-- Insert with selected ID = @OrderId = selected
execute spOrdersUpdateOrInsert @OrderId = 27, @CustomerId = 1020, @CustomerFirstName = NULL, 
@CustomerLastName = NULL, @SalesPersonId  = 25, @SalesPersonFirstName = NULL, @SalesPersonLastName = NULL, 
@ProductId = 70, @ProductGroup = NULL, @ProductName = NULL, @CarModel = NULL, @CarColor = NULL, @Quantity = 3, 
@OrderDate = '1022-10-08 11:07:23.3033333', @OrderStatusId = 3, @OrderStatusName = NULL, @Discount = 10, 
@ShippedDate = '1800-10-08 11:07:23.3033333', 
@SaleAmount = NULL, @SaleAmountPaid = 80, @TaxPercentageValue = 17, @SaleTime  = '2000-10-08 11:07:23.3033333',
@ShoppingCartOrderId =  NULL, @ShoppingCartStatusName = NULL
-- Insert with next Id =@OrderId = NULL 
execute spOrdersUpdateOrInsert @OrderId = NULL, @CustomerId = 1033, @CustomerFirstName = NULL, 
@CustomerLastName = NULL, @SalesPersonId  = 25, @SalesPersonFirstName = NULL, @SalesPersonLastName = NULL, 
@ProductId = 1, @ProductGroup = NULL, @ProductName = NULL, @CarModel = NULL, @CarColor = NULL, @Quantity = 60, 
@OrderDate = NULL, @OrderStatusId = 1, @OrderStatusName = NULL, @Discount = 0, 
@ShippedDate = NULL, 
@SaleAmount = NULL, @SaleAmountPaid = NULL, @TaxPercentageValue = NULL, @SaleTime  = NULL,
@ShoppingCartOrderId =  NULL, @ShoppingCartStatusName = NULL
GO



------ OrderStatus SEARCH --------------------------------------------------------------------------------------
execute spOrderStatusSearchDynamicSQL @OrderStatusId = NULL, @OrderStatusName = ''
go
---- OrderStatus Delete ------------------------------------------------------------------------------------------------
execute spOrderStatusDelete @OrderStatusId = 2
go
Delete from tblOrderStatus where OrderStatusId IN (100, 101)
------ OrderStatus Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @OrderStatusId = exist
execute spOrderStatusUpdateOrInsert @OrderStatusId = 3, @OrderStatusName = 'Update'
-- Insert with selected ID = @OrderStatusId = selected
execute spOrderStatusUpdateOrInsert @OrderStatusId = 100, @OrderStatusName = 'Insert with selected'
-- Insert with next Id = @OrderStatusId = NULL
execute spOrderStatusUpdateOrInsert @OrderStatusId = NULL, @OrderStatusName = 'Insert with next'
go

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------- ShoppingCart  ----------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

---- ShoppingCart SEARCH ------------------------------------------------------------------------------------------------
execute spShoppingCartSearchDynamicSQL @ShoppingCartOrderId = NULL, @UserId = NULL, @CustomerId = NULL,
@CustomerFirstName = NULL, @CustomerLastName = NULL, @SalesPersonId  = NULL, @SalesPersonFirstName = NULL, 
@SalesPersonLastName = NULL, @ProductId = NULL, @ProductGroup = NULL, @ProductName = NULL, @CarModel = NULL,
@CarColor = NULL, @Quantity = NULL, @CountryTaxPercentageValue = NULL, @Discount = NULL, @SaleAmount = NULL, 
@OrderStatusId = NULL, @OrderStatusName = NULL, @ShoppingCartStatusId = NULL, @ShoppingCartStatusName = NULL
go

---- ShoppingCart Delete ------------------------------------------------------------------------------------------------
-- Automatically when deletion actions:
-- If they are car accessories, the deleted quantity is posted back to the inventory. 
-- It checks the warehouse order list, if the stock rises above the minimum level, it deletes the item from the list. 
-- If it is a car, the value of the sales bool is set to false.
execute spShoppingCartDelete @ShoppingCartOrderId = 17
go


------ ShoppingCart Update and Insert ------------------------------------------------------------------------------------------------
go
-- Automatically when update actions:
-- In the case of car accessories, the stock will be reduced or increased in the event of a change in quantity. 
-- In the event of a product change, the quantity of the old product is credited back to stock, and the quantity of 
-- the new product is deducted from stock.
-- In any case, it checks the warehouse replenishment list, deletes the product or adds it to the list if necessary.
-- If it is a car, it is not possible to change the product or the quantity of the product.
-- Ha autós kiegészítõk, mennyiség változás esetén a raktárkészletet csökkenti vagy növeli. Termék változtatás esetén a régi termék 
-- mennyiségét visszakönyveli raktárkészletre az új termék mennyiségét levonja a raktárkészletrõl.
-- Minden esetben ellenõrzi a raktárfeltöltési listát, szükség esetén törli az árúcikket vagy hozzáadja a listához. 
-- Ha autó akkor nem lehetséges sem a termék sem a termék mennyiségének változtatása sem.
-- SaleAmount for insert, update
-- automatically generated Trigger tr_tblOrders_SaleAmount_AND_tblCarAccessoriesStock_QuantityOfStock_AND_tblCars_Sold_Settings
-- Update with exist Id = @ShoppingCartOrderId = exist
execute spShoppingCartUpdateOrInsert @ShoppingCartOrderId = 1, @UserId = 3, @CustomerId = 1055,
@CustomerFirstName = NULL, @CustomerLastName = NULL, @SalesPersonId  = 3, @SalesPersonFirstName = NULL, 
@SalesPersonLastName = NULL, @ProductId = 43, @ProductGroup = NULL, @ProductName = NULL, @CarModel = NULL,
@CarColor = NULL, @Quantity = 18,  @CountryTaxPercentageValue = NULL, @Discount = NULL, @SaleAmount = NULL,
@OrderStatusId = 1, @OrderStatusName = 1, @ShoppingCartStatusId = 1, @ShoppingCartStatusName = NULL

-- Automatically when inserting actions:
-- If they are car accessories, they will be deducted from the stock if the stock is sufficient for the order,
-- if the stock falls below the minimum level, it creates a stock replenishment list with the product item.
-- If it is a car, the value of the sales bool is set to true.
-- Ha autós kiegészítõk, akkor levonásra kerül a raktárkészletbõl, ha a raktárkészlet elegendõ a rendeléshez, 
-- ha a raktárkészlet a minimális szint alá esik vissza, akkor raktárfeltöltési listát készít a termék elemmel. 
-- Ha autó akkor az eladási bool értéke igazra állítódik.
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
-- when placing the product in the shopping cart, ShoppingCart Status = "Im Einkaufswagen" and Order Status = "Ausstehend" preparing the order
-- each time a new item is added, the Shopping Cart Status Id and Order Status Id are automatically updated to 1
-- beim Einlegen des Produkts in den Warenkorb, ShoppingCart Status = "Im Einkaufswagen" und Order Status = "Ausstehend" zur Vorbereitung der Bestellung
-- Jedes Mal, wenn ein neuer Artikel hinzugefügt wird, werden die Warenkorb-Status-ID und die Bestellstatus-ID automatisch auf 1 aktualisiert
-- a termék bevásásrlókosárba helyezésénél a ShoppingCart Status = "Im Einkaufswagen" az Order Status = "Ausstehend" elõkészítve a megrendelést
-- minden új elem hozzáadásánál automatikusan a Shopping Cart Status Id és az Order Status Id 1-re frissül 
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
-- Setting CustomerId And SalesPersonId from UserId for insert, if customer then SalesPersonId = 0 and Discount = 0
-- automatically generated Trigger tr_tblShoppingCart_Setting_CustomerId_And_SalesPersonId_And_Discount
-- Setting SaleAmount for insert, update
-- automatically generated Trigger tr_tblOrders_SaleAmount_AND_tblCarAccessoriesStock_QuantityOfStock_AND_tblCars_Sold_Settings
-- Insert with selected ID = @ShoppingCartOrderId = selected
execute spShoppingCartUpdateOrInsert @ShoppingCartOrderId = 16, @UserId = 28, @CustomerId = 1039,
@CustomerFirstName = NULL, @CustomerLastName = NULL, @SalesPersonId  = 28, @SalesPersonFirstName = NULL, 
@SalesPersonLastName = NULL, @ProductId = 1000152, @ProductGroup = NULL, @ProductName = NULL, @CarModel = NULL,
@CarColor = NULL, @Quantity = 13, @CountryTaxPercentageValue = NULL, @Discount = NULL, @SaleAmount = NULL,
@OrderStatusId = 2, @OrderStatusName = 1, @ShoppingCartStatusId = 1, @ShoppingCartStatusName = NULL

-- Setting CustomerId And SalesPersonId from UserId for insert, if customer then SalesPersonId = 0 and Discount = 0
-- automatically generated Trigger tr_tblShoppingCart_Setting_CustomerId_And_SalesPersonId_And_Discount
-- Setting SaleAmount for insert, update
-- automatically generated Trigger tr_tblOrders_SaleAmount_AND_tblCarAccessoriesStock_QuantityOfStock_AND_tblCars_Sold_Settings
-- Insert with next Id =@ShoppingCartOrderId = NULL
execute spShoppingCartUpdateOrInsert  @UserId = 14, @CustomerId = Null,
@CustomerFirstName = NULL, @CustomerLastName = NULL, @SalesPersonId  = NULL, @SalesPersonFirstName = NULL, 
@SalesPersonLastName = NULL, @ProductId = 62, @ProductGroup = NULL, @ProductName = NULL, @CarModel = NULL,
@CarColor = NULL, @Quantity = 1, @CountryTaxPercentageValue = NULL, @Discount = 0, @SaleAmount = NULL,
@OrderStatusId = NULL, @OrderStatusName = NULL, @ShoppingCartStatusId = 1, @ShoppingCartStatusName = NULL
go




------ ShoppingCartStatus SEARCH --------------------------------------------------------------------------------------
execute spShoppingCartStatusSearchDynamicSQL @ShoppingCartStatusId=Null, @ShoppingCartStatusName = NULL
go
---- ShoppingCartStatus Delete ------------------------------------------------------------------------------------------------
execute spShoppingCartStatusDelete @ShoppingCartStatusId = 2
go
------ ShoppingCartStatus Update and Insert ------------------------------------------------------------------------------------------------
go
-- Update with exist Id = @ShoppingCartStatusId = exist
execute spShoppingCartStatusUpdateOrInsert @ShoppingCartStatusId=1, @ShoppingCartStatusName = 'Update'
-- Insert with selected ID = @ShoppingCartStatusId = selected
execute spShoppingCartStatusUpdateOrInsert @ShoppingCartStatusId=50, @ShoppingCartStatusName = 'SelectedId'
-- Insert with next Id = @ShoppingCartStatusId = NULL
execute spShoppingCartStatusUpdateOrInsert @ShoppingCartStatusId=Null, @ShoppingCartStatusName = 'Next Id'
go



------------ Shopping Cart only Status Settings ---------------------------------------------------
execute spShoppingCartStatusSettings @ShoppingCartOrderId = Null, @ShoppingCartStatusName  = 'Unterwegs'
go
