m4_include(m4/FILETYPE.m4)m4_dnl
m4_include(m4/base.m4)m4_dnl
m4_include(m4/m80buildMacros.m4)m4_dnl

m80NewEntity(HOST,DBMAIN,(hostname=dbserv1))

m80NewEntity(INSTANCE,DBSERV1DB,(HOST=DBMAIN,sid=DBSERV1,port=1521))

m80NewEntity(ORACLEUSER,production_user,(INSTANCE=DBSERV1DB,user=bweinrau,password=bweinrau))

