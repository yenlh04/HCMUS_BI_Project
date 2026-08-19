USE [BI_Proj_Airlines_DDS]
GO
-- 1. Tổng số chuyến bay theo Quý/Tháng
SELECT 
    d.Quarter,
    d.Month,
    COUNT(f.Flight_SK) AS Flights_Count
FROM Fact_Flights f
JOIN Dim_Date d ON f.Date_SK = d.Date_SK
GROUP BY d.Quarter, d.Month
ORDER BY d.Quarter, d.Month;

GO
-- 2. Top 5 Sân bay bận rộn nhất
-- Theo Sân bay đi (Origin)
SELECT TOP 5
    a.Airport_Name AS Origin_Airport,
    COUNT(f.Flight_SK) AS Flights_Count
FROM Fact_Flights f
JOIN Dim_Airports a ON f.Origin_Airport_SK = a.Airport_SK
GROUP BY a.Airport_Name
ORDER BY COUNT(f.Flight_SK) DESC;
GO
-- Theo Sân bay đến (Destination)
SELECT TOP 5
    a.Airport_Name AS Dest_Airport,
    COUNT(f.Flight_SK) AS Flights_Count
FROM Fact_Flights f
JOIN Dim_Airports a ON f.Destination_Airport_SK = a.Airport_SK
GROUP BY a.Airport_Name
ORDER BY COUNT(f.Flight_SK) DESC;
GO

-- 3. Tỉ lệ chuyến bay đúng giờ (On-Time Performance - OTP) ± 5 theo sân bay
SELECT 
    a.Airport_Name AS Origin_Airport,
    SUM(CAST(f.OTP_PlusMinus5_Flag AS INT)) AS OnTime_Flights,
    COUNT(f.Flight_SK) AS Completed_Flights,
    CAST(SUM(f.OTP_PlusMinus5_Flag * 100.0) / NULLIF(COUNT(f.Flight_SK), 0) AS DECIMAL(18, 2)) AS OTP_Rate
FROM Fact_Flights f
JOIN Dim_Airports a ON f.Origin_Airport_SK = a.Airport_SK
WHERE f.Cancelled = 0
GROUP BY a.Airport_Name
ORDER BY OTP_Rate DESC;
GO

-- 4. Tỷ lệ huỷ chuyến theo nguyên nhân
SELECT 
    ISNULL(cr.Reason_Description, 'Unknown') AS Cancellation_Reason,
    CAST(COUNT(f.Flight_SK) AS FLOAT) / (SELECT COUNT(*) FROM Fact_Flights) * 100 AS Cancellation_Rate
FROM Fact_Flights f
LEFT JOIN Dim_CancellationReasons cr ON f.Cancellation_Reason_SK = cr.Reason_SK
WHERE f.Cancelled = 1 
GROUP BY cr.Reason_Description;
GO

-- 5. Trung bình thời gian delay theo sân bay đi/đến
-- Delay khi xuất phát (Origin)
SELECT 
    a.Airport_Name AS Origin_Airport,
    CAST(SUM(f.Departure_Delay) AS FLOAT) / NULLIF(COUNT(f.Flight_SK), 0) AS Avg_Dept_Delay
FROM Fact_Flights f
JOIN Dim_Airports a ON f.Origin_Airport_SK = a.Airport_SK
WHERE f.Cancelled = 0 -- CHỈ LẤY CÁC CHUYẾN KHÔNG BỊ HỦY
GROUP BY a.Airport_Name
ORDER BY Avg_Dept_Delay DESC;
-- Delay khi hạ cánh (Destination)
SELECT 
    a.Airport_Name AS Dest_Airport,
    CAST(SUM(f.Arrival_Delay) AS FLOAT) / NULLIF(COUNT(f.Flight_SK), 0) AS Avg_Arr_Delay
FROM Fact_Flights f
JOIN Dim_Airports a ON f.Destination_Airport_SK = a.Airport_SK
WHERE f.Cancelled = 0 -- CHỈ LẤY CÁC CHUYẾN KHÔNG BỊ HỦY
GROUP BY a.Airport_Name
ORDER BY Avg_Arr_Delay DESC;

-- 6. Tổng số chuyến bay và OTP toàn ngành
SELECT 
    COUNT(Flight_SK) AS Total_Flights,
    SUM(CAST(OTP_PlusMinus5_Flag AS INT)) AS Total_OTP_Count
FROM Fact_Flights;
GO

-- 7. Tỷ lệ Huỷ và Tỷ lệ Delay toàn ngành
SELECT 
    -- Tính % chuyến bị hủy
    CAST(SUM(CAST(Cancelled AS INT)) AS FLOAT) / COUNT(*) * 100 AS Cancellation_Rate,
    -- Tính % chuyến bị delay (>15 phút)
    CAST(SUM(CAST(DelayOver15_Flag AS INT)) AS FLOAT) / COUNT(*) * 100 AS Delay_Over15_Rate
FROM Fact_Flights;
GO

-- 8. Top 5 Hãng hàng không theo OTP -- 
SELECT TOP 5
    al.Airline_Name,
    -- Số lượng chuyến bay đúng giờ (OTP Count)
    SUM(CAST(f.OTP_PlusMinus5_Flag AS INT)) AS OTP_Count,
    
    -- Tổng số chuyến bay đã thực hiện (Flight Performed)
    COUNT(f.Flight_SK) AS Flight_Performed,
    
    -- Tỉ lệ OTP (OTP Rate)
    (CAST(SUM(CAST(f.OTP_PlusMinus5_Flag AS INT)) AS FLOAT) / NULLIF(COUNT(f.Flight_SK), 0)) * 100 AS OTP_Rate

FROM Fact_Flights f
JOIN Dim_Airlines al ON f.Airline_SK = al.Airline_SK
WHERE f.Cancelled = 0 
GROUP BY al.Airline_Name
ORDER BY OTP_Rate DESC; 

-- 9. Top 5 Sân bay có tỷ lệ delay cao nhất 
SELECT TOP 5
    a.Airport_Name,
    AVG(CAST(f.DelayOver15_Flag AS FLOAT)) * 100 AS Delay_Rate
FROM Fact_Flights f
JOIN Dim_Airports a ON f.Origin_Airport_SK = a.Airport_SK
GROUP BY a.Airport_Name
ORDER BY Delay_Rate DESC; 

-- 10. Xu hướng chuyến bay theo Tháng/Quý
SELECT 
    d.Quarter,
    d.Month,
    COUNT(f.Flight_SK) AS Total_Flights
FROM Fact_Flights f
JOIN Dim_Date d ON f.Date_SK = d.Date_SK
GROUP BY d.Quarter, d.Month
ORDER BY d.Quarter, d.Month;

-- 11. Nguyên nhân Delay
SELECT 
    SUM(Air_System_Delay) AS Total_Min_Air_System,
    SUM(Security_Delay) AS Total_Min_Security,
    SUM(Airline_Delay) AS Total_Min_Airline,
    SUM(Late_Aircraft_Delay) AS Total_Min_Late_Aircraft,
    SUM(Weather_Delay) AS Total_Min_Weather
FROM Fact_Flights
WHERE DelayOver15_Flag = 1;

-- 12. Thời gian Delay trung bình theo Nguyên nhân --
SELECT 
    -- Hệ thống hàng không
    CAST(COUNT(CASE WHEN Air_System_Delay > 0 THEN 1 END) AS FLOAT) 
        / NULLIF(COUNT(Flight_SK), 0) * 100 AS Air_System_Delay_Rate,

    -- An ninh
    CAST(COUNT(CASE WHEN Security_Delay > 0 THEN 1 END) AS FLOAT) 
        / NULLIF(COUNT(Flight_SK), 0) * 100 AS Security_Delay_Rate,

    -- Hãng hàng không
    CAST(COUNT(CASE WHEN Airline_Delay > 0 THEN 1 END) AS FLOAT) 
        / NULLIF(COUNT(Flight_SK), 0) * 100 AS Airline_Delay_Rate,

    -- Máy bay đến muộn
    CAST(COUNT(CASE WHEN Late_Aircraft_Delay > 0 THEN 1 END) AS FLOAT) 
        / NULLIF(COUNT(Flight_SK), 0) * 100 AS Late_Aircraft_Delay_Rate,

    -- Thời tiết
    CAST(COUNT(CASE WHEN Weather_Delay > 0 THEN 1 END) AS FLOAT) 
        / NULLIF(COUNT(Flight_SK), 0) * 100 AS Weather_Delay_Rate

FROM Fact_Flights
WHERE Cancelled = 0;

-- 13. Xu hướng Delay theo Tháng và Mùa
SELECT 
    d.Season,
    d.Month,
    AVG(CAST(f.DelayOver15_Flag AS FLOAT)) * 100 AS Delay_Rate,
    AVG(CAST(f.Arrival_Delay AS FLOAT)) AS Avg_Arr_Delay_Min
FROM Fact_Flights f
JOIN Dim_Date d ON f.Date_SK = d.Date_SK
GROUP BY d.Season, d.Month
ORDER BY d.Season, d.Month;

-- 14. Delay theo Khung giờ bay
SELECT 
    t.HourOfDay,
    AVG(CAST(f.DelayOver15_Flag AS FLOAT)) AS Delay_Rate,
    AVG(CAST(f.Departure_Delay AS FLOAT)) AS Avg_Dept_Delay_Min
FROM Fact_Flights f
JOIN Dim_Time t ON f.Scheduled_Departure_SK = t.Time_SK
GROUP BY t.HourOfDay
ORDER BY t.HourOfDay;

-- 15. Sân bay đóng góp vào Cancel, Delay
SELECT 
    a.Airport_Name,
    -- Hủy
    CAST(SUM(CAST(f.Cancelled AS INT)) AS FLOAT) / NULLIF(SUM(SUM(CAST(f.Cancelled AS INT))) OVER(), 0) * 100 AS Pct_Contribution_To_Cancel,
    -- Delay 
    CAST(SUM(CAST(f.DelayOver15_Flag AS INT)) AS FLOAT) / NULLIF(SUM(SUM(CAST(f.DelayOver15_Flag AS INT))) OVER(), 0) * 100 AS Pct_Contribution_To_Delay
FROM Fact_Flights f
JOIN Dim_Airports a ON f.Origin_Airport_SK = a.Airport_SK
GROUP BY a.Airport_Name
ORDER BY Pct_Contribution_To_Delay DESC;