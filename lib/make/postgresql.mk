
include	$(M80_LIB)/make/dbgeneric.mk

DATABASE_NAME	:
	@if [ -z "$(DATABASE_NAME)" ]; then \
		echo Please define \$$DATABASE_NAME ; \
		exit 1 ; \
	fi 

%.log : %.sql $<
	@rm -f $@ ; \
	psql -d $(DATABASE_NAME) --file $< >& $@ ; \
	errors=$$(grep ERROR $@) ; \
	if [ -n "$$errors" ]; then \
		cat $@ ; \
		exit 1 ; \
	else \
		cat $@ ; \
	fi
