GO
CREATE DATABASE BI_Proj_Airlines_DDS;
GO
USE BI_Proj_Airlines_DDS;

GO
CREATE TABLE Dim_Date (
    Date_SK        INT IDENTITY(1,1) PRIMARY KEY,
    [FullDate]     DATE  UNIQUE,
    [Year]         INT,
    [Quarter]      INT,
    [Month]        INT,
    [DayOfMonth]   INT,
    WeekOfYear     INT,
    IsWeekend      BIT,
    Season         NVARCHAR(6) -- Winter, Spring, Summer, Fall
);

GO
CREATE TABLE Dim_Time (
    Time_SK        INT IDENTITY(1,1) PRIMARY KEY,
    Time_NK        INT,
    TimeOfDay      TIME(0),
    HourOfDay      INT,
    MinuteOfHour   INT
);

GO
CREATE TABLE Dim_Airlines (
    Airline_SK     INT IDENTITY(1,1) PRIMARY KEY,
    Airline_NK     VARCHAR(10),
    Airline_Name   VARCHAR(200),
    Status         BIT DEFAULT 1,
    CreatedDate    DATETIME DEFAULT GETDATE(),
    UpdatedDate    DATETIME NULL
);

CREATE UNIQUE INDEX IX_Dim_Airlines_AirlineNK ON Dim_Airlines(Airline_NK);

GO
CREATE TABLE Dim_Airports (
    Airport_SK     INT IDENTITY(1,1) PRIMARY KEY,
    Airport_NK     VARCHAR(10),
    Airport_Name   VARCHAR(200),
    City           VARCHAR(200),
    StateProv      VARCHAR(100),
    Country        VARCHAR(100),
    Latitude       DECIMAL(10,6) NULL,
    Longitude      DECIMAL(10,6) NULL,
    Status         BIT DEFAULT 1,
    CreatedDate    DATETIME DEFAULT GETDATE(),
    UpdatedDate    DATETIME NULL
);

CREATE UNIQUE INDEX IX_Dim_Airports_AirportNK ON Dim_Airports(Airport_NK);

GO
CREATE TABLE Dim_Aircrafts (
    Aircraft_SK    INT IDENTITY(1,1) PRIMARY KEY,
    Aircraft_NK    VARCHAR(20),
    Status         BIT DEFAULT 1,
    CreatedDate    DATETIME DEFAULT GETDATE(),
    UpdatedDate    DATETIME NULL
);

CREATE UNIQUE INDEX IX_Dim_Aircrafts_AircraftNK ON Dim_Aircrafts(Aircraft_NK);

GO
CREATE TABLE Dim_CancellationReasons (
    Reason_SK          INT IDENTITY(1,1) PRIMARY KEY,
    Reason_NK          VARCHAR(10),
    Reason_Description VARCHAR(200),
    Status             BIT DEFAULT 1,
    CreatedDate        DATETIME DEFAULT GETDATE(),
    UpdatedDate        DATETIME NULL
);

CREATE UNIQUE INDEX IX_Dim_CancellationReasons_ReasonNK ON Dim_CancellationReasons(Reason_NK);

GO
CREATE TABLE Fact_Flights (
    Flight_SK                BIGINT IDENTITY(1,1) PRIMARY KEY,
    -- Foreign Keys (Dimensions)
    Date_SK                 INT, 
    Scheduled_Departure_SK  INT NULL, 
    Scheduled_Arrival_SK    INT NULL, 
    Departure_Time_SK       INT NULL, 
    Arrival_Time_SK         INT NULL,
    Wheels_Off_SK           INT NULL,
    Wheels_On_SK            INT NULL,
    Airline_SK              INT NULL, 
    Aircraft_SK             INT NULL, 
    Origin_Airport_SK       INT NULL, 
    Destination_Airport_SK  INT NULL, 
    Cancellation_Reason_SK  INT NULL, 

    Flight_Number           INT NULL, 
    Scheduled_Time          INT NULL, 
    Elapsed_Time            INT NULL, 
    Air_Time                INT NULL,
    Distance                INT NULL, 
    
    Departure_Delay         INT NULL, 
    Arrival_Delay           INT NULL,
    Taxi_Out                INT NULL, 
    Taxi_In                 INT NULL, 
    
    Air_System_Delay        INT NULL, 
    Security_Delay          INT NULL, 
    Airline_Delay           INT NULL, 
    Late_Aircraft_Delay     INT NULL, 
    Weather_Delay           INT NULL, 
    
    Diverted                BIT DEFAULT 0, 
    Cancelled               BIT DEFAULT 0, 

    -- Calculated
    OTP_PlusMinus5_Flag     BIT NULL, -- On-Time Performance +/- 5 phút
    DelayOver15_Flag        BIT NULL, -- Delay > 15 phút

    CreatedDate              DATETIME DEFAULT GETDATE(),
);
GO

-- FK constraints của Fact_Flights
ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_Date FOREIGN KEY (Date_SK) REFERENCES Dim_Date(Date_SK);
GO

ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_ScheduledDeparture FOREIGN KEY (Scheduled_Departure_SK) REFERENCES Dim_Time(Time_SK);
GO

ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_ScheduledArrival FOREIGN KEY (Scheduled_Arrival_SK) REFERENCES Dim_Time(Time_SK);
GO

ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_DepartureTime FOREIGN KEY (Departure_Time_SK) REFERENCES Dim_Time(Time_SK);
GO

ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_ArrivalTime FOREIGN KEY (Arrival_Time_SK) REFERENCES Dim_Time(Time_SK);
GO

ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_Wheels_On FOREIGN KEY (Wheels_On_SK) REFERENCES Dim_Time(Time_SK);
GO

ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_Wheels_Off FOREIGN KEY (Wheels_Off_SK) REFERENCES Dim_Time(Time_SK);
GO

ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_Airline FOREIGN KEY (Airline_SK) REFERENCES Dim_Airlines(Airline_SK);
GO

ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_TailNumber FOREIGN KEY (Aircraft_SK) REFERENCES Dim_Aircrafts(Aircraft_SK);
GO

ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_OriginAirport FOREIGN KEY (Origin_Airport_SK) REFERENCES Dim_Airports(Airport_SK);
GO

ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_DestAirport FOREIGN KEY (Destination_Airport_SK) REFERENCES Dim_Airports(Airport_SK);
GO

ALTER TABLE Fact_Flights
    ADD CONSTRAINT FK_FactFlights_CancellationReason FOREIGN KEY (Cancellation_Reason_SK) REFERENCES Dim_CancellationReasons(Reason_SK);
GO
