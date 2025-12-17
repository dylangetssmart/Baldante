CREATE TABLE dbo.AddressHelper (
    AddressID INT IDENTITY(1,1) PRIMARY KEY,
    RawAddress NVARCHAR(500),
    StreetAddress NVARCHAR(300),
    City NVARCHAR(150),
    State NVARCHAR(100),
    Zip NVARCHAR(20),
    Country NVARCHAR(100)
);


INSERT INTO dbo.AddressHelper (
    RawAddress,
    StreetAddress,
    City,
    State,
    Zip,
    Country
)
SELECT
    A.address AS RawAddress,

    -- STREET (everything before the city)
    LTRIM(RTRIM(
        LEFT(A.address,
            CASE 
                WHEN CHARINDEX(',', A.address) > 0 
                     THEN CHARINDEX(',', A.address) - 1
                ELSE LEN(A.address)
            END)
    )) AS StreetAddress,

    -- CITY (text between 1st and 2nd comma)
    LTRIM(RTRIM(
        PARSENAME(REPLACE(A.address, ',', '.'), 3)
    )) AS City,

    -- STATE (normally near end; clean up full names too)
    LTRIM(RTRIM(
        CASE 
            WHEN TRY_CAST(PARSENAME(REPLACE(A.address, ',', '.'), 2) AS INT) IS NOT NULL
                THEN PARSENAME(REPLACE(A.address, ',', '.'), 3) -- number found  previous token is state
            ELSE PARSENAME(REPLACE(A.address, ',', '.'), 2)
        END
    )) AS State,

    -- ZIP (last numeric token)
    LTRIM(RTRIM(
        CASE 
            WHEN TRY_CAST(PARSENAME(REPLACE(A.address, ',', '.'), 1) AS INT) IS NOT NULL
                THEN PARSENAME(REPLACE(A.address, ',', '.'), 1)
            WHEN TRY_CAST(PARSENAME(REPLACE(A.address, ',', '.'), 2) AS INT) IS NOT NULL
                THEN PARSENAME(REPLACE(A.address, ',', '.'), 2)
        END
    )) AS Zip,

    -- COUNTRY (last token if alphabetic)
    LTRIM(RTRIM(
        CASE 
            WHEN PATINDEX('%[0-9]%', PARSENAME(REPLACE(A.address, ',', '.'), 1)) = 0
                THEN PARSENAME(REPLACE(A.address, ',', '.'), 1)
            ELSE NULL
        END
    )) AS Country

FROM Baldante_Highrise..address a;

select * from AddressHelper 