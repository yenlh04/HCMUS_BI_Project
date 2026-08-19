USE BI_Proj_Airlines_NDS;
GO
INSERT INTO dbo.NDS_Source (Source_ID, SourceName, CreateDate, UpdateDate)
VALUES 
    (1, 'SRC 1', GETDATE(), GETDATE())


Insert into dbo.NDS_CancellationReasons (reason_NK,reason_description, source_id, createdate, updatedate) values 
('A', 'Airline/Carrier', 1, GETDATE(), GETDATE()), 
('B', 'Weather', 1, GETDATE(), GETDATE()), 
('C', 'National Air System', 1, GETDATE(), GETDATE()), 
('D', 'Security', 1,GETDATE(), GETDATE())

