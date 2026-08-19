USE BI_Proj_Airlines_MetaData;
GO

TRUNCATE TABLE DQ_Rules

INSERT INTO DQ_Rules (TableName, ColumnName, RuleExpression, Severity, ErrorDescription)
VALUES
('Airlines_stg', 'IATA_CODE', 'LEN(IATA_CODE) BETWEEN 2 AND 3', 'Error', 'IATA code must be 2-3 chars'),
('Airlines_stg', 'AIRLINE', 'LEN(AIRLINE) > 0', 'Error', 'AirlineName must not be empty');
INSERT INTO DQ_Rules (TableName, ColumnName, RuleExpression, Severity, ErrorDescription)
VALUES
('Airports_stg', 'IATA_CODE', 'LEN(IATA_CODE) = 3', 'Error', 'Airport IATA must be 3 chars'),
('Airports_stg', 'AIRPORT', 'LEN(AIRPORT) > 0', 'Error', 'Airport name must not be empty'),
('Airports_stg', 'CITY', 'LEN(CITY) > 0', 'Warning', 'City should not be empty'),
('Airports_stg', 'COUNTRY', 'LEN(COUNTRY) > 0', 'Error', 'Country is mandatory'),
('Airports_stg', 'LATITUDE', 'LATITUDE IS NOT NULL', 'Error', 'Latitude missing'),
('Airports_stg', 'LONGITUDE', 'LONGITUDE IS NOT NULL', 'Error', 'Longitude missing');
INSERT INTO DQ_Rules (TableName, ColumnName, RuleExpression, Severity, ErrorDescription)
VALUES
('Flights_stg', 'TAIL_NUMBER_Get_Null', 'LEN(LTRIM(RTRIM(Tail_Number))) > 0', 'Error', 'Tail number cannot be empty'),
('Flights_stg', 'TAIL_NUMBER_Contain_Space', 'Tail_Number NOT LIKE ''% %''', 'Error', 'Tail number cannot contain spaces');
INSERT INTO DQ_Rules (TableName, ColumnName, RuleExpression, Severity, ErrorDescription) VALUES 
('Flights_stg', 'ROUTE_Origin_Dest_Same', 'Origin == Destination', 'Error', 'Origin and Destination cannot be the same'),
('Flights_stg', 'TIME_Format_Invalid', 'Time NOT BETWEEN 0 AND 2400', 'Error', 'Time columns (Dep/Arr/Wheels) must be 0-2400'),
('Flights_stg', 'FLIGHT_Status_Conflict', 'Cancelled=1 AND Diverted=1', 'Error', 'Flight cannot be both Cancelled and Diverted'),
('Flights_stg', 'FLIGHT_Ghost_Record', 'Cancelled=1 AND AirTime > 0', 'Error', 'Cancelled flight cannot have AirTime recorded'),
('Flights_stg', 'TIME_Physics_Error', 'AirTime > ElapsedTime', 'Error', 'AirTime cannot be greater than ElapsedTime');

INSERT INTO DQ_Rules (TableName, ColumnName, RuleExpression, Severity, ErrorDescription) VALUES 
('Flights_stg', 'LOOKUP_AIRLINE_FAIL', 'Airline Code not found in Dim', 'Error', 'Airline Business Key does not exist in Dimension'),
('Flights_stg', 'LOOKUP_AIRCRAFT_FAIL', 'Tail Number not found in Dim', 'Error', 'Aircraft (Tail Number) does not exist in Dimension'),
('Flights_stg', 'LOOKUP_ORIGIN_FAIL', 'Origin Airport not found in Dim', 'Error', 'Origin Airport Code does not exist in Dimension'),
('Flights_stg', 'LOOKUP_DEST_FAIL', 'Dest Airport not found in Dim', 'Error', 'Destination Airport Code does not exist in Dimension');
SELECT * FROM DQ_Issues