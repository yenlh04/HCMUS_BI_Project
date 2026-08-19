USE BI_Proj_Airlines_NDS;
GO
---------------------------------------------------
-- 1. XÓA BẢNG TRUNG TÂM (FACT TABLE) TRƯỚC
---------------------------------------------------
-- Xóa dữ liệu
DELETE FROM NDS_Flights;
-- Reset ID tự tăng về 0 (để dòng tiếp theo nhập vào sẽ là 1)
DBCC CHECKIDENT ('NDS_Flights', RESEED, 0);

---------------------------------------------------
-- 2. XÓA CÁC BẢNG VỆ TINH (DIMENSION TABLES)
---------------------------------------------------

-- Bảng Aircraft
DELETE FROM NDS_Aircraft;
DBCC CHECKIDENT ('NDS_Aircraft', RESEED, 0);

-- Bảng Airlines
DELETE FROM NDS_Airlines;
DBCC CHECKIDENT ('NDS_Airlines', RESEED, 0);

-- Bảng Airports
DELETE FROM NDS_Airports;
DBCC CHECKIDENT ('NDS_Airports', RESEED, 0);

-- Bảng CancellationReasons
DELETE FROM NDS_CancellationReasons;
DBCC CHECKIDENT ('NDS_CancellationReasons', RESEED, 0);

---------------------------------------------------
-- KIỂM TRA LẠI
---------------------------------------------------
SELECT COUNT(*) as Count_Flights FROM NDS_Flights;
SELECT COUNT(*) as Count_Aircraft FROM NDS_Aircraft;
SELECT COUNT(*) as Count_Airlines FROM NDS_Airlines;
SELECT COUNT(*) as Count_Airports FROM NDS_Airports;
SELECT COUNT(*) as Count_Cancel FROM NDS_CancellationReasons;

SELECT * FROM NDS_Aircraft
SELECT * FROM NDS_Airlines
SELECT * FROM NDS_Airports
SELECT * FROM NDS_CancellationReasons
SELECT * FROM NDS_Flights 

