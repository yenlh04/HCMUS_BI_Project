USE BI_Proj_Airlines_MetaData;
GO
DROP TABLE IF EXISTS ETL_RunLog;
GO

CREATE TABLE ETL_RunLog (
    RunID INT IDENTITY(1,1) PRIMARY KEY,
    FlowName VARCHAR(100),        -- Airlines, Airports, Aircraft, Flights...
    
    StartTime DATETIME,
    EndTime DATETIME,

    Status VARCHAR(20),           -- Success / Failed

    RowsInserted INT DEFAULT 0,
    RowsUpdated INT DEFAULT 0,
    RowsFailed INT DEFAULT 0,

    ErrorMessage VARCHAR(MAX)
);
