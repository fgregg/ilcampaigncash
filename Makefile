###############################################################################
#
# ILLINOIS STATE BOARD OF ELECTION CAMPAIGN FINANCE LOADER
#
###############################################################################

.PHONY : all
all : il_campaign_disclosure.db

il_campaign_disclosure.db : raw_Candidates.csv raw_CanElections.csv	\
                            raw_CmteCandidateLinks.csv			\
                            raw_CmteOfficerLinks.csv			\
                            raw_Committees.csv raw_D2Totals.csv		\
                            raw_Expenditures.csv raw_FiledDocs.csv	\
                            raw_Investments.csv raw_Officers.csv	\
                            raw_PrevOfficers.csv raw_Receipts.csv
	csvs-to-sqlite $^ $@

	sqlite3 $@ < sql/Candidates.sql
	sqlite-utils transform $@ candidates --pk id

	sqlite3 $@ < sql/Committees.sql
	sqlite-utils transform $@ committees --pk id

	sqlite3 $@ < sql/Officers.sql
	sqlite-utils transform $@ officers --pk id

	sqlite3 $@ < sql/Filed_Docs.sql
	sqlite-utils transform $@ filed_docs --pk id
	sqlite-utils add-foreign-key $@ filed_docs committee_id committees id

	sqlite3 $@ < sql/Candidate_Elections.sql
	sqlite-utils transform $@ candidate_elections --pk id
	sqlite-utils add-foreign-key $@ candidate_elections candidate_id candidates id
	sqlite3 $@ < sql/Committee_Candidate_Links.sql
	sqlite-utils transform $@ committee_candidate_links --pk id
	sqlite-utils add-foreign-keys $@ committee_candidate_links candidate_id candidates id committee_candidate_links committee_id committees id

	sqlite3 $@ < sql/Committee_Officer_Links.sql
	sqlite-utils transform $@ committee_officer_links --pk id
	sqlite-utils add-foreign-keys $@ committee_officer_links officer_id officers id committee_officer_links committee_id committees id

	sqlite3 $@ < sql/Previous_Officers.sql
	sqlite-utils transform $@ previous_officers --pk id
	sqlite-utils add-foreign-key $@ previous_officers committee_id committees id

	sqlite3 $@ < sql/Expenditures.sql
	sqlite-utils transform $@ expenditures --pk id
	sqlite-utils add-foreign-keys $@ expenditures committee_id committees id expenditures filed_doc_id filed_docs id

	sqlite3 $@ < sql/Receipts.sql
	sqlite-utils transform $@ receipts --pk id
	sqlite-utils add-foreign-keys $@ receipts committee_id committees id receipts filed_doc_id filed_docs id 

	sqlite3 $@ < sql/Investments.sql
	sqlite-utils transform $@ investments --pk id
	sqlite-utils add-foreign-keys $@ investments committee_id committees id investments filed_doc_id filed_docs id 

	sqlite3 $@ < sql/D2_Reports.sql
	sqlite-utils transform $@ d2_reports --pk id
	sqlite-utils add-foreign-keys $@ d2_reports committee_id committees id d2_reports filed_doc_id filed_docs id

	echo "SELECT 'drop table ' || t.name || ';' FROM sqlite_master t where t.name like 'raw_%';" | sqlite3 $@ | sqlite3 $@
	echo "VACUUM;" | sqlite3 $@
	echo "ANALYZE;" | sqlite3 $@


##@ Data processing
%.txt: ## Download %.txt (where % is something like Candidates)
	wget -O $@ --no-check-certificate https://www.elections.il.gov/CampaignDisclosureDataFiles/$@

raw_%.csv: %.txt  ## Convert data/download/%.txt to data/processed/%.csv
	python processors/clean_isboe_tsv.py $< $* > $@
