-- Create Database 'DataWarehouse'

USE MASTER
GO

CREATE DATABASE DataWarehouse
GO

USE DataWarehouse
GO

--Create schemas
CREATE SCHEMA bronze
GO
CREATE SCHEMA silver
GO
CREATE SCHEMA gold
GO
