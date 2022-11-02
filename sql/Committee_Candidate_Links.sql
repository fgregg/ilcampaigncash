CREATE TABLE committee_candidate_links AS
    SELECT
        id as id,
        candidateid as candidate_id,
        committeeid as committee_id
    FROM
        raw_cmtecandidatelinks
;

