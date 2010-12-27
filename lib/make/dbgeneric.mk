
include		$(M80_LIB)/make/generic.mk

sqllogfiles	=	$(derivedsqlfiles:.sql=.log)

clean		::;	rm -f $(sqllogfiles)

.SUFFIXES : .sql .log

