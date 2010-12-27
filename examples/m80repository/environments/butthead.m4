# -*-perl-*- # just for formatting

m4_include(m4/FILETYPE.m4)m4_dnl
m4_include(m4/base.m4)m4_dnl
m4_include(m4/m80buildMacros.m4)m4_dnl
m4_dnl # var must be quoted : [var] since it is a macro name

m80NewEntity(HOST,
	     localhost,
	     (HOSTNAME=localhost,
	      IP=(127.0.0.1),
	      OS=Linux,
	      DISTRIBUTION=redhat,
	      Version=9,
	      m80Lib=/usr/local/share/m80/lib
	      )
	     )m4_dnl;

m80NewEntity(USER,
	     m80user,
	     (HOST=localhost,
	      USERNAME=bweinraub
	      )
	     )m4_dnl;

m80NewApacheModule(defaultWebserver,
                    (HOST=localhost,
		     DocumentRoot=/var/www,
		     HTMLDIR=m80var(WEBSERVER_defaultWebserver_DocumentRoot)/html,
                     PORT=80,
                     CGI_BIN=m80var(WEBSERVER_defaultWebserver_DocumentRoot)/cgi-bin,
		     CONF_FILE=/etc/httpd/conf/httpd.conf,
		     OWNER=root
                     )
                    )m4_dnl;

m80NewApacheModule(modPerlApache,
                    (HOST=localhost,
		     InstallationDir=/usr/local/apache,
		     DocumentRoot=m80var(WEBSERVER_modPerlApache_InstallationDir)/htdocs,
		     HTMLDIR=m80var(WEBSERVER_modPerlApache_DocumentRoot),
                     PORT=8080,
                     CGI_BIN=m80var(WEBSERVER_modPerlApache_DocumentRoot)/cgi-bin,
		     CONF_FILE=/etc/httpd/conf/httpd.conf,
		     OWNER=root
                     )
                    )m4_dnl;


m80NewPostgresModule(DEFAULT,
		     (USERNAME=bweinraub,
		      PASSWORD=bweinraub,
		      DBNAME=mydb,
		      HOSTNAME=localhost,
		      PORT=5432)
		     )m4_dnl;

m80NewEntity(WebContentOwner,
	     DefaultWebContentOwner,
	     (WEBSERVER=defaultWebserver,
	      USER=m80user
	      )
	     )m4_dnl;
	    
define_variable(envProjectRoot,/home/bweinraub/m80/examples/projects)
