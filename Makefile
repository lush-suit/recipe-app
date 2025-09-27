LB_DOCKER=docker run --rm -v "$$(PWD)":/liquibase --network host liquibase/liquibase --defaultsFile=/liquibase/liquibase/liquibase.properties

db-status:
	$(LB_DOCKER) status --verbose
db-update:
	$(LB_DOCKER) update
db-baseline:
	$(LB_DOCKER) changelogSync
db-diff:
	$(LB_DOCKER) diff
db-diff-changelog:
	$(LB_DOCKER) diffChangeLog

.PHONY: db-status db-update db-baseline db-diff db-diff-changelog
