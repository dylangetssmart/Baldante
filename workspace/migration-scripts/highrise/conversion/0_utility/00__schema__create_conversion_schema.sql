use [Baldante_SA_Highrise]
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'conversion')
EXEC sys.sp_executesql N'CREATE SCHEMA [conversion]'
GO