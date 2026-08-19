USE BI_Proj_Airlines_MetaData;
Go

INSERT INTO DL_Control (TableName,LSET, CET)
VALUES
('Flights', '1900-01-01', NULL),
('Airlines', '1900-01-01', NULL),
('Airports', '1900-01-01', NULL),
('Aircraft', '1900-01-01', NULL),
('Source', '1900-01-01', NULL),
('NDS_Airlines', '1900-01-01', NULL),
('NDS_Airports', '1900-01-01', NULL),
('NDS_Aircraft', '1900-01-01', NULL),
('NDS_CancellationReasons', '1900-01-01', NULL),
('NDS_Flights', '1900-01-01', NULL);

-- DELETE FROM DL_CONTROL


-- 1.1) TableDict: STG
INSERT INTO MD_TableDictionary (TableName, Layer, BusinessDescription, TechnicalDescription, SourceName)
VALUES
('Airlines_stg', 'STG', 'Raw airline master data from source CSV/API.', 'Extracted as-is from source.', 'Raw Source'),
('Airports_stg', 'STG', 'Raw airport lookup data.', 'Extracted with minimal preprocessing.', 'Raw Source'),
('Flights_stg', 'STG', 'Raw flight-level data containing operational records.', 'Direct ingestion of flight dataset.', 'Raw Source');

-- 1.2) ColumnDict: STG
INSERT INTO MD_ColumnDictionary (TableName, ColumnName, DataType, BusinessMeaning, SourceColumn, TransformRule)
VALUES
('Airlines_stg', 'IATA_CODE', 'VARCHAR(10)', 'Two-letter airline code', 'IATA_CODE', 'Trim whitespace'),
('Airlines_stg', 'AIRLINE', 'VARCHAR(100)', 'Official airline name', 'AIRLINE', 'Trim whitespace'),
('Airlines_stg', '_ExtractTime', 'DATETIME2', 'System extract timestamp', '_ExtractTime', 'Auto-generated');

INSERT INTO MD_ColumnDictionary
VALUES
('Airports_stg','IATA_CODE','VARCHAR(10)','Airport IATA code','IATA_CODE','Trim'),
('Airports_stg','AIRPORT','VARCHAR(150)','Airport full name','AIRPORT','Trim'),
('Airports_stg','CITY','VARCHAR(100)','City of airport','CITY','Standardize casing'),
('Airports_stg','STATE','VARCHAR(100)','State name','STATE','No transform'),
('Airports_stg','COUNTRY','VARCHAR(100)','Country name','COUNTRY','Normalize spelling'),
('Airports_stg','LATITUDE','FLOAT','Latitude coordinate','LATITUDE','Convert to decimal'),
('Airports_stg','LONGITUDE','FLOAT','Longitude coordinate','LONGITUDE','Convert to decimal'),
('Airports_stg','_ExtractTime','DATETIME2','System extraction','_ExtractTime','Auto-generated');

INSERT INTO MD_ColumnDictionary (TableName, ColumnName, DataType, BusinessMeaning, SourceColumn, TransformRule)
VALUES
('Flights_stg', 'FLIGHT_DATE', 'DATE', 
 'Scheduled flight date from source dataset.', 
 'FLIGHT_DATE', 'Standardize date format'),

('Flights_stg', 'AIRLINE', 'VARCHAR(10)', 
 'Airline IATA code operating the flight.', 
 'AIRLINE', 'Trim + Uppercase'),

('Flights_stg', 'FLIGHT_NUMBER', 'VARCHAR(20)', 
 'Flight number assigned by airline.', 
 'FLIGHT_NUMBER', 'Trim; convert to INT in NDS'),

('Flights_stg', 'TAIL_NUMBER', 'VARCHAR(20)', 
 'Aircraft tail registration number.', 
 'TAIL_NUMBER', 'Trim; Uppercase; validate no spaces'),

('Flights_stg', 'ORIGIN_AIRPORT', 'VARCHAR(10)', 
 'Departure airport (IATA code).', 
 'ORIGIN_AIRPORT', 'Trim + Uppercase'),

('Flights_stg', 'DESTINATION_AIRPORT', 'VARCHAR(10)', 
 'Arrival airport (IATA code).',
 'DESTINATION_AIRPORT', 'Trim + Uppercase'),

('Flights_stg', 'SCHEDULED_DEPARTURE', 'INT', 
 'Scheduled departure time as HHMM.', 
 'SCHEDULED_DEPARTURE', 'Convert INT → TIME'),

('Flights_stg', 'DEPARTURE_TIME', 'INT', 
 'Actual departure time as HHMM.',
 'DEPARTURE_TIME', 'Convert INT → TIME'),

('Flights_stg', 'DEPARTURE_DELAY', 'FLOAT', 
 'Difference between scheduled and actual departure (minutes).', 
 'DEPARTURE_DELAY', 'Convert NULL → 0'),

('Flights_stg', 'TAXI_OUT', 'FLOAT', 
 'Taxi-out time before takeoff (minutes).', 
 'TAXI_OUT', 'Convert NULL → 0'),

('Flights_stg', 'WHEELS_OFF', 'INT', 
 'Time when wheels leave the runway (HHMM).', 
 'WHEELS_OFF', 'Convert INT → TIME'),

('Flights_stg', 'SCHEDULED_TIME', 'FLOAT', 
 'Scheduled duration of flight (minutes).',
 'SCHEDULED_TIME', 'Convert NULL → 0'),

('Flights_stg', 'ELAPSED_TIME', 'FLOAT', 
 'Total elapsed time between departure and arrival.',
 'ELAPSED_TIME', 'Convert NULL → 0'),

('Flights_stg', 'AIR_TIME', 'FLOAT', 
 'Time spent in the air (minutes).', 
 'AIR_TIME', 'Convert NULL → 0'),

('Flights_stg', 'DISTANCE', 'FLOAT', 
 'Distance between airports (miles).', 
 'DISTANCE', 'Convert to INT in NDS'),

('Flights_stg', 'WHEELS_ON', 'INT', 
 'Time when aircraft touches down (HHMM).', 
 'WHEELS_ON', 'Convert INT → TIME'),

('Flights_stg', 'TAXI_IN', 'FLOAT', 
 'Taxi-in time to gate (minutes).',
 'TAXI_IN', 'Convert NULL → 0'),

('Flights_stg', 'SCHEDULED_ARRIVAL', 'INT', 
 'Scheduled arrival time (HHMM).',
 'SCHEDULED_ARRIVAL', 'Convert INT → TIME'),

('Flights_stg', 'ARRIVAL_TIME', 'INT', 
 'Actual arrival time (HHMM).',
 'ARRIVAL_TIME', 'Convert INT → TIME'),

('Flights_stg', 'ARRIVAL_DELAY', 'FLOAT', 
 'Arrival delay in minutes.', 
 'ARRIVAL_DELAY', 'Convert NULL → 0'),

('Flights_stg', 'DIVERTED', 'BIT', 
 'Indicates whether the flight was diverted.', 
 'DIVERTED', 'Convert NULL → 0'),

('Flights_stg', 'CANCELLED', 'BIT', 
 'Indicates whether the flight was cancelled.', 
 'CANCELLED', 'Convert NULL → 0'),

('Flights_stg', 'CANCELLATION_REASON', 'CHAR(1)', 
 'Reason code: A,B,C,D as defined by DOT.', 
 'CANCELLATION_REASON', 'Trim; must be NOT NULL when Cancelled = 1'),

('Flights_stg', 'AIR_SYSTEM_DELAY', 'FLOAT', 
 'Delay caused by air traffic control (minutes).', 
 'AIR_SYSTEM_DELAY', 'Convert NULL → 0'),

('Flights_stg', 'SECURITY_DELAY', 'FLOAT', 
 'Delay caused by security issues.', 
 'SECURITY_DELAY', 'Convert NULL → 0'),

('Flights_stg', 'AIRLINE_DELAY', 'FLOAT', 
 'Delay caused by airline (crew, maintenance, etc.).', 
 'AIRLINE_DELAY', 'Convert NULL → 0'),

('Flights_stg', 'LATE_AIRCRAFT_DELAY', 'FLOAT', 
 'Delay due to late inbound aircraft.', 
 'LATE_AIRCRAFT_DELAY', 'Convert NULL → 0'),

('Flights_stg', 'WEATHER_DELAY', 'FLOAT', 
 'Delay caused by weather conditions.', 
 'WEATHER_DELAY', 'Convert NULL → 0'),

('Flights_stg', '_ExtractTime', 'DATETIME2', 
 'Timestamp when the record was extracted into STG.', 
 '_ExtractTime', 'Auto-generated');


 -- 2.1) TableDict: NDS
 INSERT INTO MD_TableDictionary (TableName, Layer, BusinessDescription, TechnicalDescription, SourceName)
VALUES
-- Airlines
('NDS_Airlines', 'NDS',
 'Standardized airline dimension loaded from Airlines_stg.',
 'Cleansed, validated, surrogate-keyed airline master data.',
 'Airlines_stg'),

-- Airports
('NDS_Airports', 'NDS',
 'Standardized airport dimension loaded from Airports_stg.',
 'Contains validated airport codes, names, cities, geo-coordinates.',
 'Airports_stg'),

-- Aircraft
('NDS_Aircraft', 'NDS',
 'Master list of aircraft tail numbers referenced by Flights.',
 'Unique tail numbers extracted from Flights_stg, validated and cleaned.',
 'Flights_stg'),

-- CancellationReason (insert thủ công)
('NDS_CancellationReasons', 'NDS',
 'List of cancellation reason codes used for reporting and Facts.',
 'Static dimension. Values inserted manually per business rules.',
 'Manual Input'),

-- Source (insert thủ công)
('NDS_Source', 'NDS',
 'Lookup table storing ETL source system identifiers.',
 'Static table, used to tag lineage for all NDS rows.',
 'Manual Input'),

-- Flights Fact Table
('NDS_Flights', 'NDS',
 'Core fact table storing all cleansed flight transactions.',
 'Includes SK references and raw performance metrics.',
 'Flights_stg');

 -- 2.2) ColumnDict: NDS
 INSERT INTO MD_ColumnDictionary 
(TableName, ColumnName, DataType, BusinessMeaning, SourceColumn, TransformRule)
VALUES
('NDS_Airlines','Airline_SK','INT','Surrogate key for airline','AUTO','Identity'),

('NDS_Airlines','Airline_NK','VARCHAR(10)',
 'Airline natural key (IATA code).',
 'IATA_CODE','Trim + Uppercase'),

('NDS_Airlines','Airline_Name','VARCHAR(200)',
 'Full airline name.',
 'AIRLINE','Trim'),

('NDS_Airlines','Source_ID','INT',
 'Origin source system ID.',
 'Source_ID','Set constant inside ETL'),

('NDS_Airlines','CreateDate','DATETIME',
 'First time the record was inserted.',
 'ETL','GETDATE()'),

('NDS_Airlines','UpdateDate','DATETIME',
 'Last time the record was updated.',
 'ETL','Updated only on changed rows');

 INSERT INTO MD_ColumnDictionary VALUES
('NDS_Airports','Airport_SK','INT','Surrogate key','AUTO','Identity'),

('NDS_Airports','Airport_NK','VARCHAR(10)',
 'Airport natural key (IATA).','IATA_CODE','Trim + Uppercase'),

('NDS_Airports','Airport_Name','VARCHAR(200)',
 'Full airport name.','AIRPORT','Trim'),

('NDS_Airports','City','VARCHAR(200)','City name.','CITY','Trim'),
('NDS_Airports','State','VARCHAR(50)','State / Region.','STATE','Trim'),
('NDS_Airports','Country','VARCHAR(50)','Country.','COUNTRY','Trim'),

('NDS_Airports','Latitude','DECIMAL(10,6)','Latitude coordinate.','LATITUDE','Float → Decimal'),
('NDS_Airports','Longitude','DECIMAL(10,6)','Longitude coordinate.','LONGITUDE','Float → Decimal'),

('NDS_Airports','Source_ID','INT','Origin Source ID.','Source_ID','Constant'),
('NDS_Airports','CreateDate','DATETIME','Insert timestamp.','ETL','GETDATE()'),
('NDS_Airports','UpdateDate','DATETIME','Update timestamp.','ETL','Updated only on changed rows');

INSERT INTO MD_ColumnDictionary VALUES
('NDS_Aircraft','Aircraft_SK','INT','Surrogate key','AUTO','Identity'),
('NDS_Aircraft','Aircraft_NK','VARCHAR(20)','Tail number natural key.','TAIL_NUMBER','Trim + Uppercase'),

('NDS_Aircraft','Source_ID','INT','Origin Source ID.','Source_ID','Constant'),
('NDS_Aircraft','CreateDate','DATETIME','Insert timestamp.','ETL','GETDATE()'),
('NDS_Aircraft','UpdateDate','DATETIME','Update timestamp.','ETL','Updated only on changed rows');

INSERT INTO MD_ColumnDictionary VALUES
('NDS_CancellationReasons','Reason_SK','INT','Surrogate key','AUTO','Identity'),
('NDS_CancellationReasons','Reason_NK','VARCHAR(10)','Cancellation code A/B/C/D','Code','Manual'),
('NDS_CancellationReasons','Reason_Description','VARCHAR(200)','Explanation of cancellation reason','Description','Manual'),

('NDS_CancellationReasons','Source_ID','INT','Manual Source ID','Manual','Constant'),
('NDS_CancellationReasons','CreateDate','DATETIME','Insert timestamp','ETL','GETDATE()'),
('NDS_CancellationReasons','UpdateDate','DATETIME','Update timestamp','ETL','Manual');

INSERT INTO MD_ColumnDictionary VALUES
('NDS_Source','Source_ID','INT','Unique identifier for ETL source','Manual','Manual'),
('NDS_Source','SourceName','VARCHAR(200)','Source system name','Manual','Manual'),
('NDS_Source','CreateDate','DATETIME','Insert timestamp','ETL','GETDATE()'),
('NDS_Source','UpdateDate','DATETIME','Update timestamp','ETL','Manual');

INSERT INTO MD_ColumnDictionary VALUES
('NDS_Flights','Flight_SK','BIGINT','Surrogate key','AUTO','Identity'),

('NDS_Flights','Airline_SK','INT','FK to NDS_Airlines','AIRLINE','Lookup Airline_NK'),
('NDS_Flights','Origin_Airport_SK','INT','FK to NDS_Airports','ORIGIN_AIRPORT','Lookup Airport_NK'),
('NDS_Flights','Destination_Airport_SK','INT','FK to NDS_Airports','DESTINATION_AIRPORT','Lookup Airport_NK'),
('NDS_Flights','Aircraft_SK','INT','FK to NDS_Aircraft','TAIL_NUMBER','Lookup Aircraft_NK'),
('NDS_Flights','CancellationReason_SK','INT','FK to NDS_CancellationReasons','CANCELLATION_REASON','Lookup Reason_NK'),

('NDS_Flights','Flight_Number','INT','Flight number','FLIGHT_NUMBER','Convert VARCHAR → INT'),
('NDS_Flights','Flight_Date','DATE','Flight date','FLIGHT_DATE','As-is'),

('NDS_Flights','Scheduled_Departure','TIME','Scheduled departure time','SCHEDULED_DEPARTURE','INT → TIME'),
('NDS_Flights','Scheduled_Arrival','TIME','Scheduled arrival time','SCHEDULED_ARRIVAL','INT → TIME'),

('NDS_Flights','Departure_Time','TIME','Actual departure time','DEPARTURE_TIME','INT → TIME'),
('NDS_Flights','Arrival_Time','TIME','Actual arrival time','ARRIVAL_TIME','INT → TIME'),

('NDS_Flights','Departure_Delay','INT','Departure delay minutes','DEPARTURE_DELAY','FLOAT → INT'),
('NDS_Flights','Arrival_Delay','INT','Arrival delay minutes','ARRIVAL_DELAY','FLOAT → INT'),

('NDS_Flights','Taxi_Out','INT','Taxi-out minutes','TAXI_OUT','FLOAT → INT'),
('NDS_Flights','Taxi_In','INT','Taxi-in minutes','TAXI_IN','FLOAT → INT'),

('NDS_Flights','Air_Time','INT','Air time minutes','AIR_TIME','FLOAT → INT'),
('NDS_Flights','Elapsed_Time','INT','Elapsed time','ELAPSED_TIME','FLOAT → INT'),
('NDS_Flights','Distance','INT','Distance miles','DISTANCE','FLOAT → INT'),

('NDS_Flights','Diverted','BIT','Whether flight was diverted','DIVERTED','As-is'),
('NDS_Flights','Cancelled','BIT','Whether flight was cancelled','CANCELLED','As-is'),

('NDS_Flights','Source_ID','INT','Origin source ID','Source_ID','Constant'),
('NDS_Flights','CreateDate','DATETIME','Insert timestamp','ETL','GETDATE()'),
('NDS_Flights','UpdateDate','DATETIME','Update timestamp','ETL','Not updated');


-- 3.1) TableDict: DDS
INSERT INTO MD_TableDictionary 
(TableName, Layer, BusinessDescription, TechnicalDescription, SourceName)
VALUES
-- Dimension Tables
('Dim_Date', 'DDS',
 'Date dimension providing hierarchical time attributes for analysis.',
 'Loaded incrementally from NDS_Flights.Flight_Date (distinct).',
 'NDS_Flights'),

('Dim_Time', 'DDS',
 'Minute-level time dimension used for analyzing delays by time-of-day.',
 'Pre-generated table with 1440 rows representing every minute of day.',
 'Generated'),

('Dim_Airlines', 'DDS',
 'Slowly Changing Dimension for airline master data.',
 'SCD Type 2 implementation based on Airline_Name changes.',
 'NDS_Airlines'),

('Dim_Airports', 'DDS',
 'Slowly Changing Dimension for airport information.',
 'Includes airport name, country, coordinates, SCD Type 2.',
 'NDS_Airports'),

('Dim_Aircrafts', 'DDS',
 'Aircraft dimension storing unique tail numbers.',
 'Incremental load; new aircraft only, no SCD.',
 'NDS_Aircraft'),

('Dim_CancellationReasons', 'DDS',
 'Slowly Changing Dimension for cancellation reason codes.',
 'SCD Type 2 on Reason Description changes.',
 'NDS_CancellationReasons'),

-- FACT table
('Fact_Flights', 'DDS',
 'Central fact table storing flight performance metrics.',
 'Includes SK lookups to all dimensions and business-calculated flags.',
 'NDS_Flights');

-- 3.2) ColumnDict: DDS
INSERT INTO MD_ColumnDictionary VALUES
('Dim_Date','Date_SK','INT','Surrogate key for date','FLIGHT_DATE','Identity'),
('Dim_Date','Date','DATE','Calendar date','FLIGHT_DATE','Distinct + Insert'),
('Dim_Date','Day','INT','Day of month','FLIGHT_DATE','DATEPART(DAY)'),
('Dim_Date','Month','INT','Month number','FLIGHT_DATE','DATEPART(MONTH)'),
('Dim_Date','MonthName','VARCHAR(20)','Month name','FLIGHT_DATE','DATENAME(MONTH)'),
('Dim_Date','Quarter','INT','Quarter of year','FLIGHT_DATE','DATEPART(QUARTER)'),
('Dim_Date','Year','INT','Calendar year','FLIGHT_DATE','DATEPART(YEAR)'),
('Dim_Date','Week','INT','Week of year','FLIGHT_DATE','DATEPART(WEEK)'),
('Dim_Date','Season','VARCHAR(20)','Season mapping','FLIGHT_DATE','Derived via CASE'),
('Dim_Date','CreateDate','DATETIME','Insert timestamp','ETL','GETDATE()');

INSERT INTO MD_ColumnDictionary VALUES
('Dim_Time','Time_SK','INT','Surrogate key for time','Generated','Identity'),
('Dim_Time','TimeValue','TIME','Time of day','Generated','Direct'),
('Dim_Time','TimeInt','INT','HHMM representation for lookup','Generated','Used for joining INT → TIME'),
('Dim_Time','Hour','INT','Hour part','Generated','DATEPART(HOUR)'),
('Dim_Time','Minute','INT','Minute part','Generated','DATEPART(MINUTE)'),
('Dim_Time','CreateDate','DATETIME','Insert timestamp','Generated','GETDATE()');

INSERT INTO MD_ColumnDictionary VALUES
('Dim_Airlines','Airline_SK','INT','Surrogate key','AUTO','Identity'),
('Dim_Airlines','Airline_NK','VARCHAR(10)','Airline natural key','Airline_NK','Copied from NDS'),
('Dim_Airlines','Airline_Name','VARCHAR(200)','Airline name','Airline_Name','SCD Type 2 – tracked'),
('Dim_Airlines','Status','BIT','Current record indicator','ETL','1 for active'),
('Dim_Airlines','CreateDate','DATETIME','Record creation timestamp','ETL','Derived'),
('Dim_Airlines','UpdateDate','DATETIME','Record last update timestamp','ETL','Derived');

INSERT INTO MD_ColumnDictionary VALUES
('Dim_Airports','Airport_SK','INT','Surrogate key','AUTO','Identity'),
('Dim_Airports','Airport_NK','VARCHAR(10)','Airport natural key','Airport_NK','Trim + Uppercase'),
('Dim_Airports','Airport_Name','VARCHAR(200)','Airport full name','Airport_Name','SCD Type 2'),
('Dim_Airports','City','VARCHAR(200)','City name','City','SCD Type 2'),
('Dim_Airports','State','VARCHAR(50)','State','State','SCD Type 2'),
('Dim_Airports','Country','VARCHAR(50)','Country','Country','SCD Type 2'),
('Dim_Airports','Latitude','DECIMAL(10,6)','Latitude','Latitude','Copied'),
('Dim_Airports','Longitude','DECIMAL(10,6)','Longitude','Longitude','Copied'),
('Dim_Airports','Status','BIT','Current version flag','ETL','1 for active'),
('Dim_Airports','CreateDate','DATETIME','Insert timestamp','ETL','GETDATE()'),
('Dim_Airports','UpdateDate','DATETIME','Last update timestamp','ETL','GETDATE()');

INSERT INTO MD_ColumnDictionary VALUES
('Dim_Aircrafts','Aircraft_SK','INT','Surrogate key','AUTO','Identity'),
('Dim_Aircrafts','Aircraft_NK','VARCHAR(20)','Tail number','Aircraft_NK','Lookup from NDS'),
('Dim_Aircrafts','Status','BIT','Always active (no SCD)','ETL','1'),
('Dim_Aircrafts','CreateDate','DATETIME','Insert timestamp','ETL','GETDATE()'),
('Dim_Aircrafts','UpdateDate','DATETIME','Last update','ETL','GETDATE()');

INSERT INTO MD_ColumnDictionary VALUES
('Dim_CancellationReasons','Reason_SK','INT','Surrogate key','AUTO','Identity'),
('Dim_CancellationReasons','Reason_NK','VARCHAR(10)','Cancellation natural key','Reason_NK','Copied'),
('Dim_CancellationReasons','Reason_Description','VARCHAR(200)','Meaning of cancellation code','Reason_Description','SCD Type 2'),
('Dim_CancellationReasons','Status','BIT','Active/inactive version','ETL','1 for active'),
('Dim_CancellationReasons','CreateDate','DATETIME','Insert timestamp','ETL','GETDATE()'),
('Dim_CancellationReasons','UpdateDate','DATETIME','Update timestamp','ETL','GETDATE()');

INSERT INTO MD_ColumnDictionary VALUES
('Fact_Flights','Flight_SK','BIGINT','Surrogate key','AUTO','Identity'),

-- Dimension Keys
('Fact_Flights','Date_SK','INT','Date surrogate key','Flight_Date','Lookup Dim_Date'),
('Fact_Flights','Airline_SK','INT','Airline SK','Airline_NK','Lookup Dim_Airlines'),
('Fact_Flights','Origin_Airport_SK','INT','Origin airport SK','Origin_Airport_NK','Lookup Dim_Airports'),
('Fact_Flights','Destination_Airport_SK','INT','Destination airport SK','Destination_Airport_NK','Lookup Dim_Airports'),
('Fact_Flights','Aircraft_SK','INT','Aircraft SK','Tail_Number','Lookup Dim_Aircrafts'),
('Fact_Flights','CancellationReason_SK','INT','Cancellation reason SK','Cancellation_Reason','Lookup Dim_CancellationReasons'),

-- Time Keys
('Fact_Flights','ScheduledDeparture_TimeSK','INT','Scheduled departure time SK','Scheduled_Departure','Lookup Dim_Time'),
('Fact_Flights','Departure_TimeSK','INT','Actual departure time SK','Departure_Time','Lookup Dim_Time'),
('Fact_Flights','WheelsOff_TimeSK','INT','Wheels off time SK','Wheels_Off','Lookup Dim_Time'),
('Fact_Flights','WheelsOn_TimeSK','INT','Wheels on time SK','Wheels_On','Lookup Dim_Time'),
('Fact_Flights','Arrival_TimeSK','INT','Arrival time SK','Arrival_Time','Lookup Dim_Time'),

-- Measures
('Fact_Flights','Distance','INT','Flight distance (miles)','Distance','Additive'),
('Fact_Flights','Air_Time','INT','Time in air (minutes)','Air_Time','Additive'),
('Fact_Flights','Elapsed_Time','INT','Total elapsed time','Elapsed_Time','Additive'),

('Fact_Flights','Departure_Delay','INT','Departure delay','Departure_Delay','Additive'),
('Fact_Flights','Arrival_Delay','INT','Arrival delay','Arrival_Delay','Additive'),
('Fact_Flights','Taxi_Out','INT','Taxi-out duration','Taxi_Out','Additive'),
('Fact_Flights','Taxi_In','INT','Taxi-in duration','Taxi_In','Additive'),

-- Delay causes
('Fact_Flights','Air_System_Delay','INT','Delay due to ATC','Air_System_Delay','Additive'),
('Fact_Flights','Security_Delay','INT','Security delay','Security_Delay','Additive'),
('Fact_Flights','Airline_Delay','INT','Airline-caused delay','Airline_Delay','Additive'),
('Fact_Flights','Late_Aircraft_Delay','INT','Delay from late inbound flight','Late_Aircraft_Delay','Additive'),
('Fact_Flights','Weather_Delay','INT','Weather-related delay','Weather_Delay','Additive'),

-- Flags
('Fact_Flights','Diverted_Flag','BIT','Whether flight was diverted','Diverted','Semi-Additive'),
('Fact_Flights','Cancelled_Flag','BIT','Whether flight was cancelled','Cancelled','Semi-Additive'),
('Fact_Flights','OTP_PlusMinus5_Flag','BIT','Flight on-time within ±5 minutes','Arrival_Delay','Derived Business Rule'),
('Fact_Flights','DelayOver15_Flag','BIT','Flight delayed over 15 minutes','Arrival_Delay','Derived Business Rule'),

-- Control Columns
('Fact_Flights','CreateDate','DATETIME','Insert timestamp','ETL','GETDATE()');


 -------------------------------------------------------------------------


-- Insert STM_TableMapping
INSERT INTO STM_TableMapping
(SourceTable, StageTable, NDSTable, DDSTable, BusinessMeaning)
VALUES
('Airlines.csv', 'Airlines_stg', 'NDS_Airlines', 'Dim_Airlines',
 'Airline master lineage from raw CSV to SCD Type 2 dimension'),

('Airports.csv', 'Airports_stg', 'NDS_Airports', 'Dim_Airports',
 'Airport master lineage used for origin/destination analysis'),

('Flights.csv', 'Flights_stg', 'NDS_Aircraft', 'Dim_Aircrafts',
 'Aircraft tail-number lineage derived from flights'),

('Manual Input', NULL, 'NDS_CancellationReasons', 'Dim_CancellationReasons',
 'Manually defined SCD Type 2 reason dimension'),

('Flights.csv', 'Flights_stg', 'NDS_Flights', 'Fact_Flights',
 'Main flight fact lineage storing performance, delays, and measures'),

('Flights.csv', NULL, NULL, 'Dim_Date',
 'Date dimension derived from NDS_Flights.Flight_Date'),

('Generated', NULL, NULL, 'Dim_Time',
 'Generated minute-level time dimension used for time-of-day analysis');


-- Insert STM_ColumnMapping
-- 1. Airlines
INSERT INTO STM_ColumnMapping
(STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)
VALUES
(1,'Airlines.csv','IATA_CODE','Airlines_stg','IATA_CODE','NDS_Airlines','Airline_NK','Dim_Airlines','Airline_NK','Direct','Trim + Uppercase'),
(1,'Airlines.csv','AIRLINE','Airlines_stg','AIRLINE','NDS_Airlines','Airline_Name','Dim_Airlines','Airline_Name','Direct','Trim whitespace'),
(1,'ETL','_ExtractTime','Airlines_stg','_ExtractTime','NDS_Airlines','CreateDate','Dim_Airlines','CreateDate','Derived','GETDATE()');

-- 2. Airports
INSERT INTO STM_ColumnMapping 
(STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)
VALUES
(2,'Airports.csv','IATA_CODE','Airports_stg','IATA_CODE','NDS_Airports','Airport_NK','Dim_Airports','Airport_NK','Direct','Trim + Uppercase'),
(2,'Airports.csv','AIRPORT','Airports_stg','AIRPORT','NDS_Airports','Airport_Name','Dim_Airports','Airport_Name','Direct','Trim'),
(2,'Airports.csv','CITY','Airports_stg','CITY','NDS_Airports','City','Dim_Airports','City','Direct','Trim'),
(2,'Airports.csv','STATE','Airports_stg','STATE','NDS_Airports','State','Dim_Airports','State','Direct','Standardize text'),
(2,'Airports.csv','COUNTRY','Airports_stg','COUNTRY','NDS_Airports','Country','Dim_Airports','Country','Direct','Trim/Normalize'),
(2,'Airports.csv','LATITUDE','Airports_stg','LATITUDE','NDS_Airports','Latitude','Dim_Airports','Latitude','Transform','FLOAT → DECIMAL'),
(2,'Airports.csv','LONGITUDE','Airports_stg','LONGITUDE','NDS_Airports','Longitude','Dim_Airports','Longitude','Transform','FLOAT → DECIMAL');

-- 3. Aircrafts
INSERT INTO STM_ColumnMapping 
(STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)
VALUES
(3,'Flights.csv','TAIL_NUMBER','Flights_stg','TAIL_NUMBER','NDS_Aircraft','Aircraft_NK','Dim_Aircrafts','Aircraft_NK','Direct','Trim + Uppercase');

-- 4. CancellationReasons
INSERT INTO STM_ColumnMapping 
(STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)VALUES
(4,'Manual Input','Reason Code',NULL,NULL,'NDS_CancellationReasons','Reason_NK','Dim_CancellationReasons','Reason_NK','Manual','Inserted manually'),
(4,'Manual Input','Description',NULL,NULL,'NDS_CancellationReasons','Reason_Description','Dim_CancellationReasons','Reason_Description','Manual','Inserted manually');

-- 5. Fact_Flights
-- Date key
INSERT INTO STM_ColumnMapping 
(STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)
VALUES
(5,'Flights.csv','FLIGHT_DATE','Flights_stg','FLIGHT_DATE','NDS_Flights','Flight_Date','Fact_Flights','Date_SK','Lookup','Lookup Dim_Date');

-- Time keys
INSERT INTO STM_ColumnMapping 
(STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)
VALUES
(5,'Flights.csv','SCHEDULED_DEPARTURE','Flights_stg','SCHEDULED_DEPARTURE','NDS_Flights','Scheduled_Departure','Fact_Flights','ScheduledDeparture_TimeSK','Lookup','INT → TIME → Dim_Time'),
(5,'Flights.csv','DEPARTURE_TIME','Flights_stg','DEPARTURE_TIME','NDS_Flights','Departure_Time','Fact_Flights','Departure_TimeSK','Lookup','INT → TIME → Dim_Time'),
(5,'Flights.csv','WHEELS_OFF','Flights_stg','WHEELS_OFF','NDS_Flights','Wheels_Off','Fact_Flights','WheelsOff_TimeSK','Lookup','INT → TIME → Dim_Time'),
(5,'Flights.csv','WHEELS_ON','Flights_stg','WHEELS_ON','NDS_Flights','Wheels_On','Fact_Flights','WheelsOn_TimeSK','Lookup','INT → TIME → Dim_Time'),
(5,'Flights.csv','ARRIVAL_TIME','Flights_stg','ARRIVAL_TIME','NDS_Flights','Arrival_Time','Fact_Flights','Arrival_TimeSK','Lookup','INT → TIME → Dim_Time');

-- FK Lookups: Airline, Airport, Aircraft, Reason
INSERT INTO STM_ColumnMapping 
(STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)
VALUES
(5,'Flights.csv','AIRLINE','Flights_stg','AIRLINE','NDS_Flights','Airline_Code','Fact_Flights','Airline_SK','Lookup','Match Airline_NK'),
(5,'Flights.csv','TAIL_NUMBER','Flights_stg','TAIL_NUMBER','NDS_Flights','Tail_Number','Fact_Flights','Aircraft_SK','Lookup','Match Aircraft_NK'),
(5,'Flights.csv','ORIGIN_AIRPORT','Flights_stg','ORIGIN_AIRPORT','NDS_Flights','Origin_Airport_Code','Fact_Flights','Origin_Airport_SK','Lookup','Match Airport_NK'),
(5,'Flights.csv','DESTINATION_AIRPORT','Flights_stg','DESTINATION_AIRPORT','NDS_Flights','Destination_Airport_Code','Fact_Flights','Destination_Airport_SK','Lookup','Match Airport_NK'),
(5,'Flights.csv','CANCELLATION_REASON','Flights_stg','CANCELLATION_REASON','NDS_Flights','Cancellation_Reason_Code','Fact_Flights','CancellationReason_SK','Lookup','Match Reason_NK');

-- Measures (Additive)
INSERT INTO STM_ColumnMapping 
(STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)
VALUES
(5,'Flights.csv','DISTANCE','Flights_stg','DISTANCE','NDS_Flights','Distance','Fact_Flights','Distance','Transform','FLOAT → INT'),
(5,'Flights.csv','AIR_TIME','Flights_stg','AIR_TIME','NDS_Flights','Air_Time','Fact_Flights','Air_Time','Transform','FLOAT → INT'),
(5,'Flights.csv','ELAPSED_TIME','Flights_stg','ELAPSED_TIME','NDS_Flights','Elapsed_Time','Fact_Flights','Elapsed_Time','Transform','FLOAT → INT'),
(5,'Flights.csv','DEPARTURE_DELAY','Flights_stg','DEPARTURE_DELAY','NDS_Flights','Departure_Delay','Fact_Flights','Departure_Delay','Transform','FLOAT → INT'),
(5,'Flights.csv','ARRIVAL_DELAY','Flights_stg','ARRIVAL_DELAY','NDS_Flights','Arrival_Delay','Fact_Flights','Arrival_Delay','Transform','FLOAT → INT'),
(5,'Flights.csv','TAXI_OUT','Flights_stg','TAXI_OUT','NDS_Flights','Taxi_Out','Fact_Flights','Taxi_Out','Transform','FLOAT → INT'),
(5,'Flights.csv','TAXI_IN','Flights_stg','TAXI_IN','NDS_Flights','Taxi_In','Fact_Flights','Taxi_In','Transform','FLOAT → INT');

-- Delay breakdowns
INSERT INTO STM_ColumnMapping 
(STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)
VALUES
(5,'Flights.csv','AIR_SYSTEM_DELAY','Flights_stg','AIR_SYSTEM_DELAY','NDS_Flights','Air_System_Delay','Fact_Flights','Air_System_Delay','Transform','FLOAT → INT'),
(5,'Flights.csv','SECURITY_DELAY','Flights_stg','SECURITY_DELAY','NDS_Flights','Security_Delay','Fact_Flights','Security_Delay','Transform','FLOAT → INT'),
(5,'Flights.csv','AIRLINE_DELAY','Flights_stg','AIRLINE_DELAY','NDS_Flights','Airline_Delay','Fact_Flights','Airline_Delay','Transform','FLOAT → INT'),
(5,'Flights.csv','LATE_AIRCRAFT_DELAY','Flights_stg','LATE_AIRCRAFT_DELAY','NDS_Flights','Late_Aircraft_Delay','Fact_Flights','Late_Aircraft_Delay','Transform','FLOAT → INT'),
(5,'Flights.csv','WEATHER_DELAY','Flights_stg','WEATHER_DELAY','NDS_Flights','Weather_Delay','Fact_Flights','Weather_Delay','Transform','FLOAT → INT');

-- Derived Flag
INSERT INTO STM_ColumnMapping 
(STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)
VALUES
(5,'NDS_Flights','Arrival_Delay','NDS_Flights','Arrival_Delay','NDS_Flights','Arrival_Delay','Fact_Flights','OTP_PlusMinus5_Flag','Derived',
 '1 if Arrival_Delay between -5 and +5 else 0'),
(5,'NDS_Flights','Arrival_Delay','NDS_Flights','Arrival_Delay','NDS_Flights','Arrival_Delay','Fact_Flights','DelayOver15_Flag','Derived',
 '1 if Arrival_Delay > 15 else 0');

 -- 6. Dim_Date
 INSERT INTO STM_ColumnMapping 
 (STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)
 VALUES
(6,'NDS_Flights','Flight_Date',NULL,NULL,NULL,NULL,'Dim_Date','Date','Derived','Distinct Flight_Date'),
(6,'NDS_Flights','Flight_Date',NULL,NULL,NULL,NULL,'Dim_Date','Year','Derived','YEAR(Date)'),
(6,'NDS_Flights','Flight_Date',NULL,NULL,NULL,NULL,'Dim_Date','Quarter','Derived','QUARTER(Date)'),
(6,'NDS_Flights','Flight_Date',NULL,NULL,NULL,NULL,'Dim_Date','Month','Derived','MONTH(Date)'),
(6,'NDS_Flights','Flight_Date',NULL,NULL,NULL,NULL,'Dim_Date','Week','Derived','WEEK(Date)'),
(6,'NDS_Flights','Flight_Date',NULL,NULL,NULL,NULL,'Dim_Date','Season','Derived','CASE Month'),
(6,'ETL','sysdate',NULL,NULL,NULL,NULL,'Dim_Date','CreateDate','Derived','GETDATE()');

-- 7. Dim_Time
INSERT INTO STM_ColumnMapping 
(STM_TableID, SourceTable, SourceColumn, StageTable, StageColumn,
 NDSTable, NDSColumn, DDSTable, DDSColumn, MappingType, TransformLogic)
VALUES
(7,'Generated','TimeInt',NULL,NULL,NULL,NULL,'Dim_Time','TimeInt','Generated','00:00 → 0000, 23:59 → 2359'),
(7,'Generated','TimeValue',NULL,NULL,NULL,NULL,'Dim_Time','TimeValue','Generated','Convert INT → TIME'),
(7,'Generated','TimeValue',NULL,NULL,NULL,NULL,'Dim_Time','Hour','Derived','DATEPART(HOUR)'),
(7,'Generated','TimeValue',NULL,NULL,NULL,NULL,'Dim_Time','Minute','Derived','DATEPART(MINUTE)'),
(7,'ETL','sysdate',NULL,NULL,NULL,NULL,'Dim_Time','CreateDate','Derived','GETDATE()');


---------------------------------------------------------------


-- Insert Business Domain
INSERT INTO BG_Domain (DomainName, DomainDescription)
VALUES
('Airlines', 'Business domain storing airline companies and identifiers'),
('Airports', 'Represents airport information including location and coordinates'),
('Flights', 'Operational data about each flight including delays and performance'),
('Time Intelligence', 'Temporal analysis domain including Date and Time dimensions'),
('Cancellations', 'Domain representing cancellation codes and root causes');

-- Insert Business Glossary
INSERT INTO BG_BusinessGlossary
(DomainID, TermName, BusinessDefinition, TechnicalMapping, DataOwner, Example)
VALUES
(1, 'Airline', 
 'Một hãng hàng không vận hành các chuyến bay thương mại.',
 'Dim_Airlines.Airline_Name', 
 'Airline Operations', 
 'Ví dụ: American Airlines, Delta, Southwest'),

(1, 'Airline Code',
 'Mã IATA gồm 2 ký tự đại diện cho hãng bay.',
 'Dim_Airlines.Airline_NK',
 'Airline Standards',
 'VN = Vietnam Airlines, AA = American Airlines');

 INSERT INTO BG_BusinessGlossary
(DomainID, TermName, BusinessDefinition, TechnicalMapping, DataOwner, Example)
VALUES
(2, 'Airport',
 'Địa điểm cất cánh hoặc hạ cánh của máy bay.',
 'Dim_Airports.Airport_Name',
 'Airport Authority',
 'SFO = San Francisco, LAX = Los Angeles'),

(2, 'Airport Code (IATA)',
 'Mã 3 ký tự xác định sân bay.',
 'Dim_Airports.Airport_NK',
 'Airport Authority',
 'SJC, JFK, DAD');

 INSERT INTO BG_BusinessGlossary
(DomainID, TermName, BusinessDefinition, TechnicalMapping, DataOwner, Example)
VALUES
(3, 'Flight',
 'Một chuyến bay thương mại được định danh bởi Airline + Flight Number + Date.',
 'Fact_Flights.Flight_SK',
 'Airline Operations',
 'AA1234 ngày 2023-01-03'),

(3, 'Departure Delay',
 'Số phút trễ so với thời gian cất cánh dự kiến.',
 'Fact_Flights.Departure_Delay',
 'Airline Performance Team',
 'Ví dụ: 15 phút'),

(3, 'Arrival Delay',
 'Số phút trễ so với giờ đến dự kiến.',
 'Fact_Flights.Arrival_Delay',
 'Airline Performance Team',
 'Ví dụ: -3 phút (đến sớm)'),

(3, 'On-Time Performance (OTP ±5)',
 'Chuyến bay được xem là đúng giờ nếu thời gian đến nằm trong ±5 phút so với lịch.',
 'Fact_Flights.OTP_PlusMinus5_Flag',
 'Performance Analytics',
 'ArrivalDelay = 4 → OTP = 1'),

(3, 'Delay Over 15',
 'Chuyến bay bị xem là delay nếu ArrivalDelay > 15 phút.',
 'Fact_Flights.DelayOver15_Flag',
 'Performance Analytics',
 'ArrivalDelay = 22 → DelayOver15 = 1'),

(3, 'Flight Distance',
 'Quãng đường bay tính bằng miles.',
 'Fact_Flights.Distance',
 'Analytics',
 'Ví dụ: 2475 miles');

 INSERT INTO BG_BusinessGlossary
(DomainID, TermName, BusinessDefinition, TechnicalMapping, DataOwner, Example)
VALUES
(4, 'Date Key',
 'Khóa thay thế đại diện cho một ngày trong Dim_Date.',
 'Fact_Flights.Date_SK',
 'BI Platform',
 '20240101'),

(4, 'Time Key',
 'Khóa thay thế đại diện cho một thời điểm trong ngày.',
 'Dim_Time.Time_SK',
 'BI Platform',
 '08:35 = 0835');

 INSERT INTO BG_BusinessGlossary
(DomainID, TermName, BusinessDefinition, TechnicalMapping, DataOwner, Example)
VALUES
(5, 'Cancellation Reason',
 'Nguyên nhân khiến chuyến bay bị hủy.',
 'Dim_CancellationReasons.Reason_Description',
 'Airline Operations',
 'A = Carrier Issue, B = Weather');


SELECT * FROM MD_TableDictionary;
SELECT * FROM MD_ColumnDictionary;
SELECT * FROM STM_TableMapping;
SELECT * FROM STM_ColumnMapping;
SELECT * FROM BG_Domain;
SELECT * FROM BG_BusinessGlossary;
