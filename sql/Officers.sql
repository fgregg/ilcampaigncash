CREATE TABLE officers
AS
  SELECT
    ID as id,
    LastName as last_name,
    FirstName as first_name,
    Address1 as address_1,
    Address2 as address_2,
    City as city,
    State as state,
    Zip as zip,
    Title as title,
    Phone as phone,
    RedactionRequested as redaction_requested
FROM raw_Officers
;
