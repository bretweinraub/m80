# -*-perl-*- # just for formatting

m4_include(m4/FILETYPE.m4)m4_dnl
m4_include(m4/base.m4)m4_dnl
m4_include(m4/m80buildMacros.m4)m4_dnl
m4_dnl # ;var must be quoted : [var] since it is a macro name;

m80NewEntity(HOST,
	     renwixDotCom,
	     (HOSTNAME=renwix.com,
	      IP=(66.179.18.29,66.179.18.30),
	      OS=Linux,
	      DISTRIBUTION=Debian,
	      Version=3.0,
	      m80Lib=/home/sites/95264840/users/bret/Linux-2.4.21/share/m80/lib
	      )
	     )m4_dnl;

m80NewEntity(USER,
	     m80user,
	     (HOST=renwixDotCom,
	      USERNAME=bret
	      )
	     )m4_dnl;

m80NewApacheModule(renwixDotComApache,
                    (HOST=renwixDotCom,
		     DocumentRoot=/home/sites/95264840/web/renwix.com,
		     HTMLDIR=m80var(WEBSERVER_renwixDotComApache_DocumentRoot),
                     PORT=80,
                     CGI_BIN=m80var(WEBSERVER_renwixDotComApache_DocumentRoot)/cgi-bin,
		     CONF_FILE=/etc/apache/httpd.conf,
		     OWNER=root
                     )
                    )m4_dnl;

m80NewPostgresModule(DEFAULT,
		     (USERNAME=bweinraub,
		      PASSWORD=bweinraub,
		      DBNAME=mydb,
		      HOSTNAME=localhost,
		      PORT=5433)
		     )m4_dnl;

m80NewEntity(WebContentOwner,
	     DefaultWebContentOwner,
	     (WEBSERVER=renwixDotComApache,
	      USER=m80user
	      )
	     )m4_dnl;


