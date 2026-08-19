CREATE DATABASE BI_Proj_Airlines_NDS;
GO
 
USE BI_Proj_Airlines_NDS;
GO

IF OBJECT_ID('NDS_Flights') IS NOT NULL DROP TABLE NDS_Flights;
IF OBJECT_ID('NDS_Airlines') IS NOT NULL DROP TABLE NDS_Airlines;
IF OBJECT_ID('NDS_Airports') IS NOT NULL DROP TABLE NDS_Airports;
IF OBJECT_ID('NDS_Aircraft') IS NOT NULL DROP TABLE NDS_Aircraft;
IF OBJECT_ID('NDS_CancellationReasons') IS NOT NULL DROP TABLE NDS_CancellationReasons;
IF OBJECT_ID('NDS_Source') IS NOT NULL DROP TABLE NDS_Source;

CREATE TABLE NDS_Source (
    Source_ID     INT PRIMARY KEY,
    SourceName    VARCHAR(200),
    CreateDate    DATETIME DEFAULT GETDATE(),
    UpdateDate    DATETIME NULL
);

CREATE TABLE NDS_Airlines (
    Airline_SK     INT IDENTITY PRIMARY KEY,    
    Airline_NK   VARCHAR(10) UNIQUE,          
    Airline_Name   VARCHAR(200),

    Source_ID      INT,
    CreateDate     DATETIME DEFAULT GETDATE(),
    UpdateDate     DATETIME NULL,

    FOREIGN KEY (Source_ID) REFERENCES NDS_Source(Source_ID)
);

	
CREATE TABLE NDS_Airports (
    Airport_SK     INT IDENTITY PRIMARY KEY,   
    Airport_NK   VARCHAR(10) UNIQUE,         

    Airport_Name   VARCHAR(200),
    City           VARCHAR(200),
    State          VARCHAR(50),
    Country        VARCHAR(50),
    Latitude       DECIMAL(10,6),
    Longitude      DECIMAL(10,6),

    Source_ID      INT,
    CreateDate     DATETIME DEFAULT GETDATE(),
    UpdateDate     DATETIME NULL,

    FOREIGN KEY (Source_ID) REFERENCES NDS_Source(Source_ID)
);


CREATE TABLE NDS_Aircraft (
    Aircraft_SK    INT IDENTITY PRIMARY KEY,    -- SK
    Aircraft_NK    VARCHAR(20) UNIQUE,          -- NK

    Source_ID      INT,
    CreateDate     DATETIME DEFAULT GETDATE(),
    UpdateDate     DATETIME NULL,

    FOREIGN KEY (Source_ID) REFERENCES NDS_Source(Source_ID)
);


CREATE TABLE NDS_CancellationReasons (
    Reason_SK          INT IDENTITY PRIMARY KEY,   
    Reason_NK        VARCHAR(10) UNIQUE,         
    Reason_Description VARCHAR(200),

    Source_ID          INT,
    CreateDate         DATETIME DEFAULT GETDATE(),
    UpdateDate         DATETIME NULL,

    FOREIGN KEY (Source_ID) REFERENCES NDS_Source(Source_ID)
);


CREATE TABLE NDS_Flights (
    Flight_SK               BIGINT IDENTITY PRIMARY KEY,

    Airline_SK              int,
    Aircraft_SK             int,
    Origin_Airport_SK       int,
    Destination_Airport_SK  int,
    Reason_NK               VARCHAR(10),

    Flight_Number           INT,
    Flight_Date             date,

    Scheduled_Departure     INT,
    Scheduled_Arrival       INT,

    Scheduled_Time          INT,
    Departure_Time          INT,
    Departure_Delay         INT,
    Taxi_Out                INT,
    Wheels_Off              INT,

    Elapsed_Time            INT,
    Air_Time                INT,
    Distance                INT,
    Wheels_On               INT,
    Taxi_In                 INT,

    Arrival_Time            INT,
    Arrival_Delay           INT,

    Diverted                INT,
    Cancelled               INT,

    Air_System_Delay        INT,
    Security_Delay          INT,
    Airline_Delay           INT,
    Late_Aircraft_Delay     INT,
    Weather_Delay           INT,

    Source_ID               INT,

    CreateDate              DATETIME DEFAULT GETDATE(),
    UpdateDate              DATETIME NULL,

    FOREIGN KEY (Source_ID) REFERENCES NDS_Source(Source_ID)
);

Insert into dbo.NDS_CancellationReasons (reason_NK,reason_description, source_id, createdate, updatedate) values 
('A', 'Airline/Carrier', 1, null, null), 
('B', 'Weather', 1, null, null), 
('C', 'National Air System', 1, null, null), 
('D', 'Security', 1,null, null)