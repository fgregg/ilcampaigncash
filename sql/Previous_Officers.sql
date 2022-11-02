CREATE TABLE previous_officers AS
    SELECT
        id as id,
        committeeid as committee_id,
        lastname as last_name,
        firstname as first_name,
        address1 as address1,
        address2 as address2,
        city as city,
        state as state,
        zip as zip,
        title as title,
        resigndate as resign_date,
        redactionrequested as redaction_requested
    FROM
        raw_prevofficers
;
