CREATE TABLE candidate_elections AS
    SELECT
        id as id,
        candidateid as candidate_id,
        electiontype as election_type,
        electionyear as election_year,
        incchallopen as inc_chall_open,
        wonlost as won_lost,
        faircampaign as fair_campaign,
        limitsoff as limits_off,
        limitsoffreason as limits_off_reason
    FROM
        raw_CanElections
;
