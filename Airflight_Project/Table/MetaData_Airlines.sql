CREATE DATABASE BI_Proj_Airlines_MetaData;
GO

USE BI_Proj_Airlines_MetaData;
GO
CREATE TABLE DL_Control (
    ID INT IDENTITY PRIMARY KEY,
    TableName       VARCHAR(100),
    LSET            DATETIME,
    CET             DATETIME,
    Description     VARCHAR(200)
);

CREATE TABLE ETL_RunLog (
    RunID INT IDENTITY PRIMARY KEY,
    PackageName VARCHAR(200),
    StartTime DATETIME,
    EndTime DATETIME,
    Status VARCHAR(50),
    RowsInserted INT,
    RowsUpdated INT,
    ErrorMessage VARCHAR(MAX)
);

CREATE TABLE ETL_ErrorLog (
    ErrorID INT IDENTITY PRIMARY KEY,
    PackageName VARCHAR(200),
    RowData VARCHAR(MAX),
    ErrorMessage VARCHAR(MAX),
    ErrorTime DATETIME DEFAULT GETDATE()
);


CREATE TABLE DQ_Rules (
    RuleID INT IDENTITY PRIMARY KEY,
    TableName VARCHAR(100),
    ColumnName VARCHAR(100),
    RuleExpression VARCHAR(300),
    Severity VARCHAR(20),
    ErrorDescription VARCHAR(300)
);

CREATE TABLE DQ_Issues (
    IssueID INT IDENTITY PRIMARY KEY,
    RuleID INT,
    TableName VARCHAR(100),
    RowData VARCHAR(MAX),
    ErrorMessage VARCHAR(300),
    DetectedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE MD_TableDictionary (
    TableName VARCHAR(100) PRIMARY KEY,
    Layer VARCHAR(20),
    BusinessDescription VARCHAR(500),
    TechnicalDescription VARCHAR(500),
    SourceName VARCHAR(100),
    CreateDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE MD_ColumnDictionary (
    TableName VARCHAR(100),
    ColumnName VARCHAR(100),
    DataType VARCHAR(50),
    BusinessMeaning VARCHAR(500),
    SourceColumn VARCHAR(100),
    TransformRule VARCHAR(500),

    PRIMARY KEY (TableName, ColumnName),
    FOREIGN KEY (TableName)
        REFERENCES MD_TableDictionary(TableName)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

 -- Source-to-Target Mapping
 CREATE TABLE STM_TableMapping (
    STM_TableID INT IDENTITY(1,1) PRIMARY KEY,

    SourceTable VARCHAR(200) NULL,        -- Airlines.csv, Airports.csv, Flights.csv, Manual Input
    StageTable VARCHAR(200) NULL,         -- Airlines_stg, Airports_stg, Flights_stg
    NDSTable VARCHAR(200) NULL,           -- NDS_Airlines, NDS_Airports,...
    DDSTable VARCHAR(200) NULL,           -- Dim_Airlines, Fact_Flights,...

    BusinessMeaning VARCHAR(MAX),         -- Mục đích nghiệp vụ
    CreateDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE STM_ColumnMapping (
    STM_ColumnID INT IDENTITY(1,1) PRIMARY KEY,

    STM_TableID INT NOT NULL,             -- FK → STM_TableMapping

    SourceTable VARCHAR(200) NULL,
    SourceColumn VARCHAR(200) NULL,

    StageTable VARCHAR(200) NULL,
    StageColumn VARCHAR(200) NULL,

    NDSTable VARCHAR(200) NULL,
    NDSColumn VARCHAR(200) NULL,

    DDSTable VARCHAR(200) NULL,
    DDSColumn VARCHAR(200) NULL,

    MappingType VARCHAR(50),              -- Direct / Transform / Lookup / Derived / Manual
    TransformLogic VARCHAR(MAX),          -- Mô tả logic transform

    CreateDate DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (STM_TableID)
        REFERENCES STM_TableMapping(STM_TableID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE BG_Domain (
    DomainID INT IDENTITY(1,1) PRIMARY KEY,
    DomainName VARCHAR(200) NOT NULL,
    DomainDescription VARCHAR(MAX),
    CreateDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE BG_BusinessGlossary (
    TermID INT IDENTITY(1,1) PRIMARY KEY,
    DomainID INT NOT NULL,                 -- FK → BG_Domain

    TermName VARCHAR(200) NOT NULL,        -- OTP, DelayOver15, Flight, Airline…
    BusinessDefinition NVARCHAR(MAX),       -- Định nghĩa nghiệp vụ
    TechnicalMapping VARCHAR(MAX),         -- Ánh xạ sang tên cột DDS/NDS
    DataOwner VARCHAR(200),                -- Ai chịu trách nhiệm: BI Team, Airline Ops...
    Example NVARCHAR(MAX),                  -- Example để hiểu đúng nghĩa

    CreateDate DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (DomainID)
        REFERENCES BG_Domain(DomainID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO
CREATE TABLE MD_Business_KPI (
    KPI_ID INT IDENTITY PRIMARY KEY,
    KPI_Name VARCHAR(200),
    Description VARCHAR(MAX),
    RelatedTable VARCHAR(200),
    CalculationLogic VARCHAR(MAX),
    BusinessOwner VARCHAR(100),
    CreateDate DATETIME DEFAULT GETDATE()
);


CREATE TABLE MD_ETL_Process (
    ProcessID INT IDENTITY PRIMARY KEY,
    ProcessName VARCHAR(200),
    Description VARCHAR(MAX),
    SourceLayer VARCHAR(50),
    TargetLayer VARCHAR(50),
    Frequency VARCHAR(50),
    Owner VARCHAR(100),
    CreateDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE MD_MeasureDictionary (
    MeasureID INT IDENTITY PRIMARY KEY,
    TableName VARCHAR(200),
    MeasureName VARCHAR(200),
    MeasureType VARCHAR(50),        
    BusinessMeaning VARCHAR(MAX),
    CalculationRule VARCHAR(MAX),
    CreateDate DATETIME DEFAULT GETDATE()
);


INSERT INTO dbo.MD_ETL_Process
(ProcessName, Description, SourceLayer, TargetLayer, Frequency, Owner)
VALUES
('SRC_to_STG',
 'Extract raw CSV files into staging tables',
 'SRC', 'STG', 'Daily', 'BI Team'),

('STG_to_NDS',
 'Clean, validate, and normalize data into NDS with DQ rules',
 'STG', 'NDS', 'Daily', 'BI Team'),

('NDS_to_DDS',
 'Load dimensions and fact tables for analytics and mining',
 'NDS', 'DDS', 'Daily', 'BI Team');


INSERT INTO MD_MeasureDictionary
(TableName, MeasureName, MeasureType, BusinessMeaning, CalculationRule)
VALUES
('Fact_Flights', 'Distance', 'Additive',
 'Total flight distance in miles',
 'SUM(Distance)'),

('Fact_Flights', 'Arrival_Delay', 'Additive',
 'Minutes flight arrives late or early',
 'AVG(Arrival_Delay)'),

('Fact_Flights', 'Departure_Delay', 'Additive',
 'Minutes flight departs late or early',
 'AVG(Departure_Delay)'),

('Fact_Flights', 'OTP_PlusMinus5_Flag', 'Non-Additive',
 'Indicates whether flight arrived within ±5 minutes',
 'CASE WHEN Arrival_Delay BETWEEN -5 AND 5 THEN 1 ELSE 0'),

('Fact_Flights', 'DelayOver15_Flag', 'Non-Additive',
 'Indicates whether flight delay exceeds 15 minutes',
 'CASE WHEN Arrival_Delay > 15 THEN 1 ELSE 0');


INSERT INTO MD_Business_KPI
(KPI_Name, Description, RelatedTable, CalculationLogic, BusinessOwner)
VALUES
('On-Time Performance (OTP)',
 'Percentage of flights arriving within ±5 minutes',
 'Fact_Flights',
 'SUM(OTP_PlusMinus5_Flag) / COUNT(*)',
 'Airline Operations'),

('Delay Rate > 15 Minutes',
 'Percentage of flights delayed more than 15 minutes',
 'Fact_Flights',
 'SUM(DelayOver15_Flag) / COUNT(*)',
 'Airline Operations');