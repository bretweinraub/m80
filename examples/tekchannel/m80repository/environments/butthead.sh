# -*-perl-*- # just for formatting

# this file was programtically generated 
# edit it at your own risk.



# loaded m80buildMacros.m4

# end m80buildMacros.m4

# m80NewEntity(HOST,localhost, ...)
export HOSTS="${HOSTS} localhost"
export HOST_localhost_HOSTNAME="localhost"
export HOST_localhost_IP="(127.0.0.1)"
export HOST_localhost_OS="Linux"
export HOST_localhost_DISTRIBUTION="redhat"
export HOST_localhost_Version="9"
export HOST_localhost_m80Lib="/usr/local/share/m80/lib"

# m80NewEntity(USER,m80user, ...)
export USERS="${USERS} m80user"
export USER_m80user_HOST="localhost"
export USER_m80user_USERNAME="bweinraub"

# m80NewApacheModule(defaultWebserver)

export WEBSERVER_MODULES="${WEBSERVER_MODULES} defaultWebserver"
export WEBSERVER_defaultWebserver_HOST="localhost"
export WEBSERVER_defaultWebserver_DocumentRoot="/var/www"
export WEBSERVER_defaultWebserver_HTMLDIR="${WEBSERVER_defaultWebserver_DocumentRoot}/html"
export WEBSERVER_defaultWebserver_PORT="80"
export WEBSERVER_defaultWebserver_CGI_BIN="${WEBSERVER_defaultWebserver_DocumentRoot}/cgi-bin"
export WEBSERVER_defaultWebserver_CONF_FILE="/etc/httpd/conf/httpd.conf"
export WEBSERVER_defaultWebserver_OWNER="root"
export WEBSERVER_defaultWebserver_TYPE="APACHE"
export WEBSERVER_defaultWebserver_RESTART_COMMAND="apachectl restart"

# m80NewPostgresModule(DEFAULT)

export DATABASE_MODULES="${DATABASE_MODULES} DEFAULT"
export DATABASE_DEFAULT_USERNAME="bweinraub"
export DATABASE_DEFAULT_PASSWORD="bweinraub"
export DATABASE_DEFAULT_DBNAME="mydb"
export DATABASE_DEFAULT_HOSTNAME="localhost"
export DATABASE_DEFAULT_PORT="5432"
export DATABASE_DEFAULT_TYPE="POSTGRES"

# m80NewEntity(WebContentOwner,DefaultWebContentOwner, ...)
export WebContentOwnerS="${WebContentOwnerS} DefaultWebContentOwner"
export WebContentOwner_DefaultWebContentOwner_WEBSERVER="defaultWebserver"
export WebContentOwner_DefaultWebContentOwner_USER="m80user"



