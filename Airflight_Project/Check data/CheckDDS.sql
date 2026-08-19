USE BI_Proj_Airlines_DDS;
GO

SELECT * FROM Dim_Aircrafts
SELECT * FROM Dim_Airlines
SELECT * FROM Dim_Airports
SELECT * FROM Dim_CancellationReasons
SELECT * FROM Dim_Date
SELECT * FROM Dim_Time
SELECT * FROM Fact_Flights 

/*
-- 1. Xóa bảng Fact trước (để gỡ bỏ tham chiếu khóa ngoại)
DELETE FROM Fact_Flights;
DBCC CHECKIDENT ('Fact_Flights', RESEED, 0); -- Reset ID về 0 (Dòng tiếp theo sẽ là 1)

-- 2. Xóa các bảng Dimension (trừ Dim_Time)
DELETE FROM Dim_Aircrafts;
DBCC CHECKIDENT ('Dim_Aircrafts', RESEED, 0);

DELETE FROM Dim_Airlines;
DBCC CHECKIDENT ('Dim_Airlines', RESEED, 0);

DELETE FROM Dim_Airports;
DBCC CHECKIDENT ('Dim_Airports', RESEED, 0);

DELETE FROM Dim_CancellationReasons;
DBCC CHECKIDENT ('Dim_CancellationReasons', RESEED, 0);

DELETE FROM Dim_Date;
DBCC CHECKIDENT ('Dim_Date', RESEED, 0);
*/
