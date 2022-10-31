###############################################################################
#
# ILLINOIS STATE BOARD OF ELECTION CAMPAIGN FINANCE LOADER
#
# Run `make help` to see commands.
# 
# You must have a .env file with:
#
#       
###############################################################################

# Source tables
TABLES = $(basename $(notdir $(wildcard sql/tables/*.sql)))

# Views
VIEWS = $(basename $(notdir $(wildcard sql/views/*.sql)))


##@ Basic usage

.PHONY: all
all: views db/vacuum ## Build database

.PHONY: download
download: $(patsubst %, data/download/%.txt, $(TABLES)) ## Download source data

.PHONY: process
process: $(patsubst %, data/processed/%.csv, $(TABLES)) ## Process source data

.PHONY: load
load: $(patsubst %, db/csv/%, $(TABLES)) ## Process load processed data

.PHONY: views
views: $(patsubst %, db/views/%, $(VIEWS)) ## Create views

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z\%\\.\/_-]+:.*?##/ { printf "\033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Database views

define create_view
	(psql -c "\d $(subst db/views/,,$@)" > /dev/null 2>&1 && \
		echo "view $(subst db/views/,,$@) exists") || \
	psql -v ON_ERROR_STOP=1 -qX1ef sql/views/$(subst db/views,,$@).sql
endef

.PHONY: db/views/%
db/views/%: sql/views/%.sql load ## Create view % specified in sql/views/%.sql (will load all data)
	$(call create_view)

.PHONY: db/views/Candidate_Elections
db/views/Candidate_Elections: sql/views/Candidate_Elections.sql db/views/Candidates
	$(call create_view)

.PHONY: db/views/Committee_Candidate_Links
db/views/Committee_Candidate_Links: db/views/Committees db/views/Candidates
	$(call create_view)

.PHONY: db/views/Committee_Officer_Links
db/views/Committee_Officer_Links: db/views/Committees db/views/Officers
	$(call create_view)

.PHONY: db/views/Previous_Officers
db/views/Previous_Officers: db/views/Committees
	$(call create_view)

.PHONY: db/views/Receipts
db/views/Receipts: db/views/Committees
	$(call create_view)

.PHONY: db/views/Expenditures
db/views/Expenditures: db/views/Committees
	$(call create_view)

.PHONY: db/views/Condensed_Receipts
db/views/Condensed_Receipts: db/views/Receipts db/views/Most_Recent_Filings
	$(call create_view)

.PHONY: db/views/Condensed_Expenditures
db/views/Condensed_Expenditures: db/views/Expenditures db/views/Most_Recent_Filings
	$(call create_view)

.PHONY: db/views/Most_Recent_Filings
db/views/Most_Recent_Filings: db/views/Committees db/views/Filed_Docs db/views/D2_Reports
	$(call create_view)

##@ Database structure

ilcampaigncash.db : ## Create database
	touch $@

.PHONY: db/vacuum
db/vacuum: ilcampaigncash.db
	echo "VACUUM ANALYZE;" | sqlite3 $<

.PHONY: db/tables/%
db/tables/%: sql/tables/%.sql data/processed/%.csv # Create table % from sql/tables/%.sql
	sqlite3 ilcampaigncash.db < $<
	sqlite3 ilcampaigncash.db < "\copy $* from '$(CURRDIR)/$(word 2, $^)' with csv header"


.PHONY: dropdb
dropdb: ## Drop database
	dropdb --if-exists -e $(PGDATABASE)


##@ Data processing
data/download/%.txt: ## Download %.txt (where % is something like Candidates)
	wget -O $@ https://www.elections.il.gov/CampaignDisclosureDataFiles/$@

data/processed/%.csv: data/download/%.txt  ## Convert data/download/%.txt to data/processed/%.csv
	$(PIPENV) python processors/clean_isboe_tsv.py $< $* > $@


##@ Maintenance
.PHONY: clean
clean: clean/processed clean/download  ## Delete downloads and processed data files

.PHONY: clean/%
clean/%:  ## Clean data/%
	rm -f data/$*/*
