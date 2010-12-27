# -*-make-*-require
m4_changequote([[,]])
m4_dnl a simple macro to generate a require() style rule
m4_define([[_requireMakeVar]],[[if [ -z "$($1)" ]; then \
			echo \$$\($1\) $2 ; \
			exit 1 ; \
		    fi ; \
	      	    exit 0]])m4_dnl

m4_define([[_requireShellVar]],[[if [ -z "$${$1}" ]; then \
		echo \$$\($1\) $2 ; \
		exit 1 ; \
        fi]])m4_dnl

m4_define([[requireMakeVar]],[[ m4_dnl a simple macro to generate a require() style rule
$1::; @_requireMakeVar($1,[[must be defined]])]])m4_dnl

m4_define([[deriveAndAssign]],[[export $1=$$(eval "echo \$$[[]]$2_"$${$3}"_$4") ; \
	echo setting \$$[[]]$1 = \$$\{$2"_"$${$3}"_"$4\} \($${$1}\)]])m4_dnl

m4_define([[deriveAssignAndRequire]],[[deriveAndAssign($*) ; \
	_requireShellVar($1,[[could not be derived from \$$[[]]$2_"$${$3}"_$4 ]])]])

m4_define([[requireWritePermission]],[[if [ ! -w "$1" ]; then \
			echo $1 must be writable and it isn\'t. ; \
			exit 1 ; \
		fi]])m4_dnl

m4_define([[doPotentiallyRemoteCommand]],[[if [ -n "$${REMOTE_COMMAND}" ]; then \
			echo  $${REMOTE_COMMAND} '$*' ; \
			$${REMOTE_COMMAND} $* ; \
		else \
			echo $* ; \
			$* ; \
		fi]])m4_dnl

m4_define([[ifRemoteCommand]],[[if [ -n "$${REMOTE_COMMAND}" ]; then \
			m4_ifelse($1,,dummy=null,$1) ; \
		else \
			m4_ifelse($2,,dummy=null,$2) ; \
		fi]])m4_dnl

m4_define([[scriptBase]],[[
	@if [ -n "$(DEBUG)" ]; then \
		set -x ; \
	fi ; \
	rm -rf $(MODULE_NAME) ; \
	mkdir $(MODULE_NAME) ; \
	deriveAssignAndRequire(DBTYPE,DATABASE,DATABASE,TYPE); \
	if [ "$${DBTYPE}" != "POSTGRES" ]; then \
		echo Database type $${TYPE} not currently implemented ; \
		exit 1 ; \
	fi ; \
	deriveAssignAndRequire(DBUSER,DATABASE,DATABASE,USERNAME) ; \
	deriveAssignAndRequire(DBPASS,DATABASE,DATABASE,PASSWORD) ; \
	deriveAssignAndRequire(DBNAME,DATABASE,DATABASE,DBNAME) ; \
	deriveAssignAndRequire(DBPORT,DATABASE,DATABASE,PORT) ; \
	deriveAssignAndRequire(DBHOST,DATABASE,DATABASE,HOSTNAME) ; \
	deriveAssignAndRequire(WEBSERVER,WebContentOwner,WEBCONTENTOWNER,WEBSERVER) ; \
	deriveAssignAndRequire(USER,WebContentOwner,WEBCONTENTOWNER,USER) ; \
	deriveAssignAndRequire(TYPE,WEBSERVER,WEBSERVER,TYPE) ; \
	deriveAssignAndRequire(HOST,WEBSERVER,WEBSERVER,HOST) ; \
	deriveAssignAndRequire(m80Lib,HOST,HOST,m80Lib) ; \
	deriveAndAssign(customization,GenSite,MODULE_NAME,customization) ; \
	buildSite.pl -module $(MODULE_NAME) -dbType $(RDBMS_TYPE) -dbName $${DBNAME} -dbUser $${DBUSER} -dbPass $${DBPASS} -dbPort $${DBPORT} -dbHost $${DBHOST}  -m80Lib $${m80Lib} -custom $$customization]])m4_dnl

requireMakeVar(WEBCONTENTOWNER)
requireMakeVar(MODULE_NAME)
requireMakeVar(DATABASE)
requireMakeVar(RDBMS_TYPE)

scripts : DATABASE
	scriptBase

specialTag=m80

baseline:: WEBCONTENTOWNER MODULE_NAME DATABASE
	scriptBase ; \
	if [ $${TYPE} = "APACHE" ]; then \
		deriveAssignAndRequire(CGI_BIN,WEBSERVER,WEBSERVER,CGI_BIN) ; \
		deriveAssignAndRequire(HTMLDIR,WEBSERVER,WEBSERVER,HTMLDIR) ; \
		deriveAssignAndRequire(CONF_FILE,WEBSERVER,WEBSERVER,CONF_FILE) ; \
m4_dnl		deriveAssignAndRequire(RESTART_COMMAND,WEBSERVER,WEBSERVER,RESTART_COMMAND) ; \
		deriveAssignAndRequire(HOSTNAME,HOST,HOST,HOSTNAME) ; \
		deriveAssignAndRequire(m80Lib,HOST,HOST,m80Lib) ; \
		deriveAssignAndRequire(USERNAME,USER,USER,USERNAME) ; \
		if [ $${HOSTNAME} != "localhost" ]; then \
			REMOTE_COMMAND="ssh -l $${USERNAME} $${HOSTNAME}" ; \
		fi ; \
		ifRemoteCommand(,mkdir -p $${CGI_BIN}/$(MODULE_NAME)) ; \
		ifRemoteCommand($${REMOTE_COMMAND} mkdir -p $${HTMLDIR}/$(specialTag),mkdir -p $${HTMLDIR}/$(specialTag)) ; \
		ifRemoteCommand(,requireWritePermission($${CGI_BIN}/$(MODULE_NAME))) ; \
		ifRemoteCommand(,requireWritePermission($${HTMLDIR}/$(specialTag))) ; \
		ifRemoteCommand(tar cvf - $(MODULE_NAME)/*.cgi | $${REMOTE_COMMAND} '(cd '$${CGI_BIN}' ; tar xvf -)', cp -p $(MODULE_NAME)/*.cgi $${CGI_BIN}/$(MODULE_NAME)) ; \
		ifRemoteCommand(tar --create --directory $(MODULE_NAME) -f - $(MODULE_NAME).html | $${REMOTE_COMMAND} '(cd '$${HTMLDIR}/$(specialTag)' ; tar xvf -)', cp -p $(MODULE_NAME)/$(MODULE_NAME).html $${HTMLDIR}/$(specialTag)) ; \
		exit $$? ; \
	else \
		echo Unknown webserver type $${TYPE}. ; \
		exit 1 ; \
	fi
