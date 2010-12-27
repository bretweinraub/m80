# -*-perl-*- # just for formatting

# this file was programtically generated 
# edit it at your own risk.



# loaded m80buildMacros.m4

# end m80buildMacros.m4

# m80NewEntity(HOST,renwixDotCom, ...)
export HOSTS += renwixDotCom
export HOST_renwixDotCom_HOSTNAME		=	renwix.com
export HOST_renwixDotCom_IP		=	(66.179.18.29,66.179.18.30)
export HOST_renwixDotCom_OS		=	Linux
export HOST_renwixDotCom_DISTRIBUTION		=	Debian
export HOST_renwixDotCom_Version		=	3.0
export HOST_renwixDotCom_m80Lib		=	/home/sites/95264840/users/bret/Linux-2.4.21/share/m80/lib

# m80NewEntity(USER,m80user, ...)
export USERS += m80user
export USER_m80user_HOST		=	renwixDotCom
export USER_m80user_USERNAME		=	bret

# m80NewApacheModule(renwixDotComApache)

export WEBSERVER_MODULES += renwixDotComApache
export WEBSERVER_renwixDotComApache_HOST		=	renwixDotCom
export WEBSERVER_renwixDotComApache_DocumentRoot		=	/home/sites/95264840/web/renwix.com
export WEBSERVER_renwixDotComApache_HTMLDIR		=	$(WEBSERVER_renwixDotComApache_DocumentRoot)
export WEBSERVER_renwixDotComApache_PORT		=	80
export WEBSERVER_renwixDotComApache_CGI_BIN		=	$(WEBSERVER_renwixDotComApache_DocumentRoot)/cgi-bin
export WEBSERVER_renwixDotComApache_CONF_FILE		=	/etc/apache/httpd.conf
export WEBSERVER_renwixDotComApache_OWNER		=	root
export WEBSERVER_renwixDotComApache_TYPE		=	APACHE
export WEBSERVER_renwixDotComApache_RESTART_COMMAND		=	apachectl restart

# m80NewPostgresModule(DEFAULT)

export DATABASE_MODULES += DEFAULT
export DATABASE_DEFAULT_USERNAME		=	bweinraub
export DATABASE_DEFAULT_PASSWORD		=	bweinraub
export DATABASE_DEFAULT_DBNAME		=	mydb
export DATABASE_DEFAULT_HOSTNAME		=	localhost
export DATABASE_DEFAULT_PORT		=	5433
export DATABASE_DEFAULT_TYPE		=	POSTGRES

# m80NewEntity(WebContentOwner,DefaultWebContentOwner, ...)
export WebContentOwnerS += DefaultWebContentOwner
export WebContentOwner_DefaultWebContentOwner_WEBSERVER		=	renwixDotComApache
export WebContentOwner_DefaultWebContentOwner_USER		=	m80user


