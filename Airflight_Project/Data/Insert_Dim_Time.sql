USE BI_Proj_Airlines_DDS;
GO

-- Kiểm tra xem bảng đã có dữ liệu chưa trước khi Insert
IF NOT EXISTS (SELECT TOP 1 1 FROM Dim_Time)
BEGIN
    WITH TimeSequence AS (
        SELECT CAST('00:00:00' AS TIME(0)) AS TimeVal
        UNION ALL
        SELECT DATEADD(MINUTE, 1, TimeVal)
        FROM TimeSequence
        WHERE TimeVal < '23:59:00' -- Điều kiện dừng đúng để lấy đủ phút cuối cùng
    )
    INSERT INTO Dim_Time (Time_NK, TimeOfDay, HourOfDay, MinuteOfHour)
    SELECT 
        (DATEPART(HOUR, TimeVal) * 100) + DATEPART(MINUTE, TimeVal) AS Time_NK,
        TimeVal,
        DATEPART(HOUR, TimeVal),
        DATEPART(MINUTE, TimeVal)
    FROM TimeSequence
    OPTION (MAXRECURSION 0);
    
    PRINT 'Da insert du lieu thanh cong.';
END
ELSE
BEGIN
    PRINT 'Du lieu trong Dim_Time da ton tai. Khong thuc hien Insert.';
END