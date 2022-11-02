CREATE TABLE committee_officer_links AS
    SELECT
        id as id,
        officerid as officer_id,
        committeeid as committee_id
    FROM
        raw_cmteofficerlinks
;
