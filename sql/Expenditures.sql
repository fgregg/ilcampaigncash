CREATE TABLE expenditures
AS
  SELECT
    id as id,
    committeeid as committee_id,
    fileddocid as filed_doc_id,
    etransid as etrans_id,
    lastonlyname as last_name,
    firstname as first_name,
    expendeddate as expended_date,
    amount as amount,
    aggregateamount as aggregate_amount,
    address1 as address1,
    address2 as address2,
    city as city,
    state as state,
    zip as zipcode,
    d2part as d2_part,
    purpose as purpose,
    archived as archived,
    country as country,
    redactionrequested as redaction_requested
  FROM raw_Expenditures
;

CREATE TABLE independent_expenditures
AS
  SELECT
    id as expenditure_id,
    candidatename as candidate_name,
    office as office,
    supporting as supporting,
    opposing as opposing
  FROM raw_Expenditures
  WHERE d2part like '9%'
;
