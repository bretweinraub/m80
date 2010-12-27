# -*-make-*-require











 WEBCONTENTOWNER::; @if [ -z "$(WEBCONTENTOWNER)" ]; then \
			echo \$$\(WEBCONTENTOWNER\) must be defined ; \
			exit 1 ; \
		    fi ; \
	      	    exit 0
 MODULE_NAME::; @if [ -z "$(MODULE_NAME)" ]; then \
			echo \$$\(MODULE_NAME\) must be defined ; \
			exit 1 ; \
		    fi ; \
	      	    exit 0
 DATABASE::; @if [ -z "$(DATABASE)" ]; then \
			echo \$$\(DATABASE\) must be defined ; \
			exit 1 ; \
		    fi ; \
	      	    exit 0
 RDBMS_TYPE::; @if [ -z "$(RDBMS_TYPE)" ]; then \
			echo \$$\(RDBMS_TYPE\) must be defined ; \
			exit 1 ; \
		    fi ; \
	      	    exit 0

scripts : DATABASE
	
	@if [ -n "$(DEBUG)" ]; then \
		set -x ; \
	fi ; \
	rm -rf $(MODULE_NAME) ; \
	mkdir $(MODULE_NAME) ; \
	export DBTYPE=$$(eval "echo \$$DATABASE_"$${DATABASE}"_TYPE") ; \
	echo setting \$$DBTYPE = \$$\{DATABASE"_"$${DATABASE}"_"TYPE\} \($${DBTYPE}\) ; \
	if [ -z "$${DBTYPE}" ]; then \
		echo \$$\(DBTYPE\) could not be derived from \$$DATABASE_"$${DATABASE}"_TYPE  ; \
		exit 1 ; \
        fi; \
	if [ "$${DBTYPE}" != "POSTGRES" ]; then \
		echo Database type $${TYPE} not currently implemented ; \
		exit 1 ; \
	fi ; \
	export DBUSER=$$(eval "echo \$$DATABASE_"$${DATABASE}"_USERNAME") ; \
	echo setting \$$DBUSER = \$$\{DATABASE"_"$${DATABASE}"_"USERNAME\} \($${DBUSER}\) ; \
	if [ -z "$${DBUSER}" ]; then \
		echo \$$\(DBUSER\) could not be derived from \$$DATABASE_"$${DATABASE}"_USERNAME  ; \
		exit 1 ; \
        fi ; \
	export DBPASS=$$(eval "echo \$$DATABASE_"$${DATABASE}"_PASSWORD") ; \
	echo setting \$$DBPASS = \$$\{DATABASE"_"$${DATABASE}"_"PASSWORD\} \($${DBPASS}\) ; \
	if [ -z "$${DBPASS}" ]; then \
		echo \$$\(DBPASS\) could not be derived from \$$DATABASE_"$${DATABASE}"_PASSWORD  ; \
		exit 1 ; \
        fi ; \
	export DBNAME=$$(eval "echo \$$DATABASE_"$${DATABASE}"_DBNAME") ; \
	echo setting \$$DBNAME = \$$\{DATABASE"_"$${DATABASE}"_"DBNAME\} \($${DBNAME}\) ; \
	if [ -z "$${DBNAME}" ]; then \
		echo \$$\(DBNAME\) could not be derived from \$$DATABASE_"$${DATABASE}"_DBNAME  ; \
		exit 1 ; \
        fi ; \
	export DBPORT=$$(eval "echo \$$DATABASE_"$${DATABASE}"_PORT") ; \
	echo setting \$$DBPORT = \$$\{DATABASE"_"$${DATABASE}"_"PORT\} \($${DBPORT}\) ; \
	if [ -z "$${DBPORT}" ]; then \
		echo \$$\(DBPORT\) could not be derived from \$$DATABASE_"$${DATABASE}"_PORT  ; \
		exit 1 ; \
        fi ; \
	export DBHOST=$$(eval "echo \$$DATABASE_"$${DATABASE}"_HOSTNAME") ; \
	echo setting \$$DBHOST = \$$\{DATABASE"_"$${DATABASE}"_"HOSTNAME\} \($${DBHOST}\) ; \
	if [ -z "$${DBHOST}" ]; then \
		echo \$$\(DBHOST\) could not be derived from \$$DATABASE_"$${DATABASE}"_HOSTNAME  ; \
		exit 1 ; \
        fi ; \
	export WEBSERVER=$$(eval "echo \$$WebContentOwner_"$${WEBCONTENTOWNER}"_WEBSERVER") ; \
	echo setting \$$WEBSERVER = \$$\{WebContentOwner"_"$${WEBCONTENTOWNER}"_"WEBSERVER\} \($${WEBSERVER}\) ; \
	if [ -z "$${WEBSERVER}" ]; then \
		echo \$$\(WEBSERVER\) could not be derived from \$$WebContentOwner_"$${WEBCONTENTOWNER}"_WEBSERVER  ; \
		exit 1 ; \
        fi ; \
	export USER=$$(eval "echo \$$WebContentOwner_"$${WEBCONTENTOWNER}"_USER") ; \
	echo setting \$$USER = \$$\{WebContentOwner"_"$${WEBCONTENTOWNER}"_"USER\} \($${USER}\) ; \
	if [ -z "$${USER}" ]; then \
		echo \$$\(USER\) could not be derived from \$$WebContentOwner_"$${WEBCONTENTOWNER}"_USER  ; \
		exit 1 ; \
        fi ; \
	export TYPE=$$(eval "echo \$$WEBSERVER_"$${WEBSERVER}"_TYPE") ; \
	echo setting \$$TYPE = \$$\{WEBSERVER"_"$${WEBSERVER}"_"TYPE\} \($${TYPE}\) ; \
	if [ -z "$${TYPE}" ]; then \
		echo \$$\(TYPE\) could not be derived from \$$WEBSERVER_"$${WEBSERVER}"_TYPE  ; \
		exit 1 ; \
        fi ; \
	export HOST=$$(eval "echo \$$WEBSERVER_"$${WEBSERVER}"_HOST") ; \
	echo setting \$$HOST = \$$\{WEBSERVER"_"$${WEBSERVER}"_"HOST\} \($${HOST}\) ; \
	if [ -z "$${HOST}" ]; then \
		echo \$$\(HOST\) could not be derived from \$$WEBSERVER_"$${WEBSERVER}"_HOST  ; \
		exit 1 ; \
        fi ; \
	export m80Lib=$$(eval "echo \$$HOST_"$${HOST}"_m80Lib") ; \
	echo setting \$$m80Lib = \$$\{HOST"_"$${HOST}"_"m80Lib\} \($${m80Lib}\) ; \
	if [ -z "$${m80Lib}" ]; then \
		echo \$$\(m80Lib\) could not be derived from \$$HOST_"$${HOST}"_m80Lib  ; \
		exit 1 ; \
        fi ; \
	export customization=$$(eval "echo \$$GenSite_"$${MODULE_NAME}"_customization") ; \
	echo setting \$$customization = \$$\{GenSite"_"$${MODULE_NAME}"_"customization\} \($${customization}\) ; \
	buildSite.pl -module $(MODULE_NAME) -dbType $(RDBMS_TYPE) -dbName $${DBNAME} -dbUser $${DBUSER} -dbPass $${DBPASS} -dbPort $${DBPORT} -dbHost $${DBHOST}  -m80Lib $${m80Lib} -custom $$customization

specialTag=m80

baseline:: WEBCONTENTOWNER MODULE_NAME DATABASE
	
	@if [ -n "$(DEBUG)" ]; then \
		set -x ; \
	fi ; \
	rm -rf $(MODULE_NAME) ; \
	mkdir $(MODULE_NAME) ; \
	export DBTYPE=$$(eval "echo \$$DATABASE_"$${DATABASE}"_TYPE") ; \
	echo setting \$$DBTYPE = \$$\{DATABASE"_"$${DATABASE}"_"TYPE\} \($${DBTYPE}\) ; \
	if [ -z "$${DBTYPE}" ]; then \
		echo \$$\(DBTYPE\) could not be derived from \$$DATABASE_"$${DATABASE}"_TYPE  ; \
		exit 1 ; \
        fi; \
	if [ "$${DBTYPE}" != "POSTGRES" ]; then \
		echo Database type $${TYPE} not currently implemented ; \
		exit 1 ; \
	fi ; \
	export DBUSER=$$(eval "echo \$$DATABASE_"$${DATABASE}"_USERNAME") ; \
	echo setting \$$DBUSER = \$$\{DATABASE"_"$${DATABASE}"_"USERNAME\} \($${DBUSER}\) ; \
	if [ -z "$${DBUSER}" ]; then \
		echo \$$\(DBUSER\) could not be derived from \$$DATABASE_"$${DATABASE}"_USERNAME  ; \
		exit 1 ; \
        fi ; \
	export DBPASS=$$(eval "echo \$$DATABASE_"$${DATABASE}"_PASSWORD") ; \
	echo setting \$$DBPASS = \$$\{DATABASE"_"$${DATABASE}"_"PASSWORD\} \($${DBPASS}\) ; \
	if [ -z "$${DBPASS}" ]; then \
		echo \$$\(DBPASS\) could not be derived from \$$DATABASE_"$${DATABASE}"_PASSWORD  ; \
		exit 1 ; \
        fi ; \
	export DBNAME=$$(eval "echo \$$DATABASE_"$${DATABASE}"_DBNAME") ; \
	echo setting \$$DBNAME = \$$\{DATABASE"_"$${DATABASE}"_"DBNAME\} \($${DBNAME}\) ; \
	if [ -z "$${DBNAME}" ]; then \
		echo \$$\(DBNAME\) could not be derived from \$$DATABASE_"$${DATABASE}"_DBNAME  ; \
		exit 1 ; \
        fi ; \
	export DBPORT=$$(eval "echo \$$DATABASE_"$${DATABASE}"_PORT") ; \
	echo setting \$$DBPORT = \$$\{DATABASE"_"$${DATABASE}"_"PORT\} \($${DBPORT}\) ; \
	if [ -z "$${DBPORT}" ]; then \
		echo \$$\(DBPORT\) could not be derived from \$$DATABASE_"$${DATABASE}"_PORT  ; \
		exit 1 ; \
        fi ; \
	export DBHOST=$$(eval "echo \$$DATABASE_"$${DATABASE}"_HOSTNAME") ; \
	echo setting \$$DBHOST = \$$\{DATABASE"_"$${DATABASE}"_"HOSTNAME\} \($${DBHOST}\) ; \
	if [ -z "$${DBHOST}" ]; then \
		echo \$$\(DBHOST\) could not be derived from \$$DATABASE_"$${DATABASE}"_HOSTNAME  ; \
		exit 1 ; \
        fi ; \
	export WEBSERVER=$$(eval "echo \$$WebContentOwner_"$${WEBCONTENTOWNER}"_WEBSERVER") ; \
	echo setting \$$WEBSERVER = \$$\{WebContentOwner"_"$${WEBCONTENTOWNER}"_"WEBSERVER\} \($${WEBSERVER}\) ; \
	if [ -z "$${WEBSERVER}" ]; then \
		echo \$$\(WEBSERVER\) could not be derived from \$$WebContentOwner_"$${WEBCONTENTOWNER}"_WEBSERVER  ; \
		exit 1 ; \
        fi ; \
	export USER=$$(eval "echo \$$WebContentOwner_"$${WEBCONTENTOWNER}"_USER") ; \
	echo setting \$$USER = \$$\{WebContentOwner"_"$${WEBCONTENTOWNER}"_"USER\} \($${USER}\) ; \
	if [ -z "$${USER}" ]; then \
		echo \$$\(USER\) could not be derived from \$$WebContentOwner_"$${WEBCONTENTOWNER}"_USER  ; \
		exit 1 ; \
        fi ; \
	export TYPE=$$(eval "echo \$$WEBSERVER_"$${WEBSERVER}"_TYPE") ; \
	echo setting \$$TYPE = \$$\{WEBSERVER"_"$${WEBSERVER}"_"TYPE\} \($${TYPE}\) ; \
	if [ -z "$${TYPE}" ]; then \
		echo \$$\(TYPE\) could not be derived from \$$WEBSERVER_"$${WEBSERVER}"_TYPE  ; \
		exit 1 ; \
        fi ; \
	export HOST=$$(eval "echo \$$WEBSERVER_"$${WEBSERVER}"_HOST") ; \
	echo setting \$$HOST = \$$\{WEBSERVER"_"$${WEBSERVER}"_"HOST\} \($${HOST}\) ; \
	if [ -z "$${HOST}" ]; then \
		echo \$$\(HOST\) could not be derived from \$$WEBSERVER_"$${WEBSERVER}"_HOST  ; \
		exit 1 ; \
        fi ; \
	export m80Lib=$$(eval "echo \$$HOST_"$${HOST}"_m80Lib") ; \
	echo setting \$$m80Lib = \$$\{HOST"_"$${HOST}"_"m80Lib\} \($${m80Lib}\) ; \
	if [ -z "$${m80Lib}" ]; then \
		echo \$$\(m80Lib\) could not be derived from \$$HOST_"$${HOST}"_m80Lib  ; \
		exit 1 ; \
        fi ; \
	export customization=$$(eval "echo \$$GenSite_"$${MODULE_NAME}"_customization") ; \
	echo setting \$$customization = \$$\{GenSite"_"$${MODULE_NAME}"_"customization\} \($${customization}\) ; \
	buildSite.pl -module $(MODULE_NAME) -dbType $(RDBMS_TYPE) -dbName $${DBNAME} -dbUser $${DBUSER} -dbPass $${DBPASS} -dbPort $${DBPORT} -dbHost $${DBHOST}  -m80Lib $${m80Lib} -custom $$customization ; \
	if [ $${TYPE} = "APACHE" ]; then \
		export CGI_BIN=$$(eval "echo \$$WEBSERVER_"$${WEBSERVER}"_CGI_BIN") ; \
	echo setting \$$CGI_BIN = \$$\{WEBSERVER"_"$${WEBSERVER}"_"CGI_BIN\} \($${CGI_BIN}\) ; \
	if [ -z "$${CGI_BIN}" ]; then \
		echo \$$\(CGI_BIN\) could not be derived from \$$WEBSERVER_"$${WEBSERVER}"_CGI_BIN  ; \
		exit 1 ; \
        fi ; \
		export HTMLDIR=$$(eval "echo \$$WEBSERVER_"$${WEBSERVER}"_HTMLDIR") ; \
	echo setting \$$HTMLDIR = \$$\{WEBSERVER"_"$${WEBSERVER}"_"HTMLDIR\} \($${HTMLDIR}\) ; \
	if [ -z "$${HTMLDIR}" ]; then \
		echo \$$\(HTMLDIR\) could not be derived from \$$WEBSERVER_"$${WEBSERVER}"_HTMLDIR  ; \
		exit 1 ; \
        fi ; \
		export CONF_FILE=$$(eval "echo \$$WEBSERVER_"$${WEBSERVER}"_CONF_FILE") ; \
	echo setting \$$CONF_FILE = \$$\{WEBSERVER"_"$${WEBSERVER}"_"CONF_FILE\} \($${CONF_FILE}\) ; \
	if [ -z "$${CONF_FILE}" ]; then \
		echo \$$\(CONF_FILE\) could not be derived from \$$WEBSERVER_"$${WEBSERVER}"_CONF_FILE  ; \
		exit 1 ; \
        fi ; \
		export HOSTNAME=$$(eval "echo \$$HOST_"$${HOST}"_HOSTNAME") ; \
	echo setting \$$HOSTNAME = \$$\{HOST"_"$${HOST}"_"HOSTNAME\} \($${HOSTNAME}\) ; \
	if [ -z "$${HOSTNAME}" ]; then \
		echo \$$\(HOSTNAME\) could not be derived from \$$HOST_"$${HOST}"_HOSTNAME  ; \
		exit 1 ; \
        fi ; \
		export m80Lib=$$(eval "echo \$$HOST_"$${HOST}"_m80Lib") ; \
	echo setting \$$m80Lib = \$$\{HOST"_"$${HOST}"_"m80Lib\} \($${m80Lib}\) ; \
	if [ -z "$${m80Lib}" ]; then \
		echo \$$\(m80Lib\) could not be derived from \$$HOST_"$${HOST}"_m80Lib  ; \
		exit 1 ; \
        fi ; \
		export USERNAME=$$(eval "echo \$$USER_"$${USER}"_USERNAME") ; \
	echo setting \$$USERNAME = \$$\{USER"_"$${USER}"_"USERNAME\} \($${USERNAME}\) ; \
	if [ -z "$${USERNAME}" ]; then \
		echo \$$\(USERNAME\) could not be derived from \$$USER_"$${USER}"_USERNAME  ; \
		exit 1 ; \
        fi ; \
		if [ $${HOSTNAME} != "localhost" ]; then \
			REMOTE_COMMAND="ssh -l $${USERNAME} $${HOSTNAME}" ; \
		fi ; \
		if [ -n "$${REMOTE_COMMAND}" ]; then \
			dummy=null ; \
		else \
			mkdir -p $${CGI_BIN}/$(MODULE_NAME) ; \
		fi ; \
		if [ -n "$${REMOTE_COMMAND}" ]; then \
			$${REMOTE_COMMAND} mkdir -p $${HTMLDIR}/$(specialTag) ; \
		else \
			mkdir -p $${HTMLDIR}/$(specialTag) ; \
		fi ; \
		if [ -n "$${REMOTE_COMMAND}" ]; then \
			dummy=null ; \
		else \
			if [ ! -w "$${CGI_BIN}/$(MODULE_NAME)" ]; then \
			echo $${CGI_BIN}/$(MODULE_NAME) must be writable and it isn\'t. ; \
			exit 1 ; \
		fi ; \
		fi ; \
		if [ -n "$${REMOTE_COMMAND}" ]; then \
			dummy=null ; \
		else \
			if [ ! -w "$${HTMLDIR}/$(specialTag)" ]; then \
			echo $${HTMLDIR}/$(specialTag) must be writable and it isn\'t. ; \
			exit 1 ; \
		fi ; \
		fi ; \
		if [ -n "$${REMOTE_COMMAND}" ]; then \
			tar cvf - $(MODULE_NAME)/*.cgi | $${REMOTE_COMMAND} '(cd '$${CGI_BIN}' ; tar xvf -)' ; \
		else \
			cp -p $(MODULE_NAME)/*.cgi $${CGI_BIN}/$(MODULE_NAME) ; \
		fi ; \
		if [ -n "$${REMOTE_COMMAND}" ]; then \
			tar --create --directory $(MODULE_NAME) -f - $(MODULE_NAME).html | $${REMOTE_COMMAND} '(cd '$${HTMLDIR}/$(specialTag)' ; tar xvf -)' ; \
		else \
			cp -p $(MODULE_NAME)/$(MODULE_NAME).html $${HTMLDIR}/$(specialTag) ; \
		fi ; \
		exit $$? ; \
	else \
		echo Unknown webserver type $${TYPE}. ; \
		exit 1 ; \
	fi
