# -*-perl-*- # just for formatting

m4_include(m4/FILETYPE.m4)m4_dnl
m4_include(m4/base.m4)m4_dnl
m4_include(m4/m80buildMacros.m4)m4_dnl
m4_dnl # var must be quoted : [var] since it is a macro name

define_variable(projectName,deb)
define_variable(projectRoot,m80var(envProjectRoot)/m80var(projectName))

m80NewEntity(GenSite,
	     qbchores,
	     (database=DEFAULT,
	      webserver=defaultWebserver,
	      customization=m80var(projectRoot)/qbchores/customization.pl
	      )
	     )m4_dnl;

m80NewEntity(masonSite,
	     qbchores,
	     (database=DEFAULT,
	      webserver=modPerlApache,
	      customization=m80var(projectRoot)/qbchores/customization.pl
	      )
	     )m4_dnl;



