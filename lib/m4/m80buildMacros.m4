# loaded m80buildMacros.m4
m4_divert(-1)m4_dnl
#
# Copyright (c) 2002 Phideas Corporation.
#

#
# Macro:		m80NewDatabaseUser
#
# Purpose:		adds a database user to a database instance
#
# Call Signature:	
#

m4_define([_m80NewDatabaseUser],[
# $0($1,$2,$3,$4,$5,$6,$7,$8)
append_variable_space([DATABASE_USERS],[$1_$3])
append_variable_space([$1_USERS],[$1_$3])
define_variable([$1_$3_USERNAME],[$3])
append_variable_space([REQUIRED_VARIABLES],[$1_$3_USERNAME])
append_variable_space([REQUIRED_VARIABLES],[$1_$3_PASSWORD])
m4_ifelse($3,Y,
# defining the PHI_USER
define_variable([$1_PHI_USER],[$1_$3]),
# ignored $3 as not the PHI User
)
define_variable([$1_$3_DESCRIPTION],[$2])
#define_variable([$1_$3_IS_PHI_USER],[$4])
define_variable([$1_$3_IS_SYSTEM_USER],[$5])
define_variable([$1_$3_IS_REPLICATION_ADMIN],[$6])
define_variable([$1_$3_IS_SYS_USER],[$7])
#define_variable([$1_$3_IS_TDBADMIN],[$8])
define_variable([$1_$3_CREATE_USER],[$9])
])m4_dnl

m4_define([m80NewDatabaseUser],[
# $0($1,$2,$3,$4,$5,$6,$7,$8,$9)
_m80NewDatabaseUser($1,$2,$3,$4,$5,$6,$7,$8,$9)
define_variable([$1_$3_CONNECTSTRING],[m80var($1_$3_USERNAME)/m80var($1_$3_PASSWORD)@m80var($1_TNS)])
])

# For usernames and passwords that are actually variables themselves, use this
# macro.  Otherwise you'll get ksh that can be evaluated.

m4_define([m80NewDatabaseUserComplex],[
# $0($1,$2,$3,$4,$5,$6,$7,$8,$9)
_m80NewDatabaseUser($1,$2,$3,$4,$5,$6,$7,$8,$9)
define_variable([$1_$3_CONNECTSTRING],[complexVar(_cat($1_,$3)_USERNAME)/complexVar(_cat($1_,$3)_PASSWORD)@m80var($1_TNS)])
])


#
# Macro:		m80NewDatabaseInstance
#
# Purpose:		builds out the namespace for a database instance.
#
# Call Signature:	m80NewDatabaseInstance(nameSpace,vendor,vendor_version,
#					       sid,port,tns)
#

m4_define([m80NewDatabaseInstance],[
# $0($1,$2,$3,$4,$5,$6)
append_variable_space([DATABASE_INSTANCES], [$1])
define_variable([$1_DESCRIPTION], [$2])
define_variable([$1_VENDOR],[$3])
define_variable([$1_VENDOR_VERSION],[$4])
define_variable([$1_SID],[$5])
define_variable([$1_LISTENER_PORT],[$6])
define_variable([$1_TNS],[$7])
m80NewDatabaseUser($1,$1 Oracle System User,SYSTEM,N,Y,N,N,N)
# m80NewDatabaseUser($1,$1 Replication Admin,REPADMIN,,N,N,Y,N,N)
# m80NewDatabaseUser($1,$1 TargetDB Admin,TDBADMIN,N,N,N,N,Y)
# define_variable([$1_REPADMIN_USERNAME],repadmin)
# define_variable([$1_REPADMIN_PASSWORD],repadmin)
# define_variable([$1_TDBADMIN_USERNAME],[TDBADMIN_USER])
# define_variable([$1_TDBADMIN_PASSWORD],[TDBADMIN_PASSWORD])
])

#
# Macro:		m80NewLogicalHost
#
# Purpose:		adds a logical host to the namespace.
#
# Call Signature:	m80NewLogicalHost(logicalHostName,
#

m4_define([m80NewLogicalHost],[
# $0($1,$2,$3,$4,$5,$6)
append_variable_space([LOGICAL_HOSTS],[$1])
define_variable([$1_LOGICAL_HOST_NAME],[$2])
define_variable([$1_SYSTEM_SPECIFIC_HOSTNAME],[$3])
define_variable([$1_NUM_CPUS],[$4])
define_variable([$1_OS_FLAVOR],[$5])
define_variable([$1_OS_NAME],[$6])
define_variable([$1_OS_VERSION],[$7])
define_variable([$1_INIT_TRANS],[shellcommand(expr m80var($1_NUM_CPUS) \* 2)])
])

#
# Macro:		m80NewDatabaseUserRelation
#
# Purpose:		
#
# Call Signature:	
#

m4_define([m80NewDatabaseUserRelation],[
# $0($1,$2,$3,$4,$5,$6,$7,$8,$9,$10
append_variable_space([$1_DATABASE_USER_RELATIONS],[$2])
define_variable([$1_$2_DATABASE_USER_RELATION_TYPE],[$3])
define_variable([$1_$2_PARENT_DATABASE_USER],[$4])
define_variable([$1_$2_CHILD_DATABASE_USER],[$5])
define_variable([$1_$2_PARENT_CAN_SELECT],[$6])
define_variable([$1_$2_PARENT_CAN_INSERT],[$7])
define_variable([$1_$2_PARENT_CAN_DELETE],[$8])
define_variable([$1_$2_PARENT_CAN_UPDATE],[$9])
])

m4_define([m80NewStandardModule],[
# $0($1,$2,$3,$4,$5,$6,$7,$8)
append_variable_space([MODULES],[$1])
define_variable([$1_baseline_PATH],[$2/baseline])
define_variable([$1_schemapatch_PATH],[$2/src/schema])
define_variable([$1_codepatch_PATH],[$2/src/code])
])m4_dnl

m4_define([m80NewStandardOracleModule],[
m80NewStandardModule($*)
define_variable([$1_truncate_PATH],[tools])
define_variable([$1_packageHeaders_PATH],[$2/src/code])
define_variable([$1_notPakageHeaders_PATH],[$2/src/code])
])




#
# {{{ m4 macro: M80NewCustomModule
#
# Name: M80NewCustomModule
# Arguments: $1: MODULE_NAME, $2: ((m80 TARGET NAME, TARGET SRC PATH, TARGET TOOL (default='make'), BOOLEAN APPEND TARGET NAME TO 'make' (true|)))
# Description: 
#
# This is the primary building block for creating the structured data in the 
# shell environment. The MODULE_NAME is put onto a MODULES variable that is 
# used by the naiveProcess tool. That tool will loop over modules, cd into 
# the TARGET SRC PATH, and exec the TARGET TOOL (with or without make). This 
# is all wired up in m80, where running an "oldschool" command - 
# C<m80 --oldschool> -t TARGET NAME will invoke naiveProcess. 
#
# In most cases, this macro should be subclassed with something that sets the
# target name. I.e.
#
#   # $1: Module name, $2: src path, $3: tool
#   m4_ define([newTARGETNAME],[m80NewCustomModule( $1, ((TARGETNAME, $2, TARGETTOOL, )))])
#
# Or, if you have more "known" information, then something like the following
# may be more appropriate:
#
#  # $1: Module name, $2: src path
#   m4_ define([newTARGETNAME],[m80NewCustomModule( $1, ((TARGETNAME, $2, TARGETTOOL, )))])
#

m4_define([_addPath],[
# $0($1,$2,$3,$4,$5,$6,$7,$8)
append_variable_space($2_MODULES,[$1])
define_variable([$1_$2_PATH],[$3])
m4_ifelse($4,,
define_variable([$1_$2_TOOL],make),
define_variable([$1_$2_TOOL],$4))
m4_ifelse($5,true,
define_variable([$1_$2_SUPPRESS_TARGET_APPEND],$5),
)])m4_dnl

m4_define([m80NewCustomModule],[
# $0($1,$2,$3,$4,$5,$6,$7,$8)
append_variable_space([MODULES],[$1])
m4_foreach([X], $2, [_cat([_addPath], m4_push(_cnt, m4_unshift($1, X)))])
])
# }}} end M80NewCustomModule


m4_define([_m80CreateTargetModuleList],[
# $0($1,$2,$3,$4,$5,$6,$7,$8)
append_variable_space([TARGETS],[$2])
define_variable([$1_$2_MODULES], m4_foreach([X], $3, [X ]))
])m4_dnl

m4_define([m80CreateTargetModuleList],[
# $0($1,$2,$3,$4,$5,$6,$7,$8)
m4_foreach(X, $2, [_cat([_m80CreateTargetModuleList], ($1, X, $3))])
])m4_dnl


m4_define([m80NewModuleRelation],[])m4_dnl nothing yet

m4_define([m80NewModuleDatabase],[])m4_dnl nothing yet

m4_define([setVirtualTargets],[
# POD
# POD =head2 Virtual Targets
# POD 
# POD Defining a virtual target means that a another build target is actually run
# POD 
# POD =over
# POD
$1
# POD
# POD =back
# POD
])

m4_define([virtualTarget],[
define_variable([$1_VIRTUAL],[$2])
# POD 
# POD =item $1 is mapped to $2
# POD 
])

#
# Macro:		assignUserRelationVars
#
# Purpose:		assigns a number of local macros based on a unique tag passed in
#			as argument $2 to m80NewDatabaseUserRelation()
#
# Call Signature:	
#

m4_define([assignUserRelationVars],[
m4_undefine(parent_database_user)
m4_define([parent_database_user],m4_env2([_cat(_cat(DATABASE_INSTANCE,_$1),_PARENT_DATABASE_USER)]))
m4_undefine(parent_can_update)
m4_define([parent_can_update],m4_env2([_cat(_cat(DATABASE_INSTANCE,_$1),_PARENT_CAN_UPDATE)]))

m4_undefine(parent_can_delete)
m4_define([parent_can_delete],m4_env2([_cat(_cat(DATABASE_INSTANCE,_$1),_PARENT_CAN_DELETE)]))

m4_undefine(parent_can_insert)
m4_define([parent_can_insert],m4_env2([_cat(_cat(DATABASE_INSTANCE,_$1),_PARENT_CAN_INSERT)]))

m4_undefine(parent_can_select)
m4_define([parent_can_select],m4_env2([_cat(_cat(DATABASE_INSTANCE,_$1),_PARENT_CAN_SELECT)]))

m4_undefine(child_database_user)
m4_define([child_database_user],m4_env2([_cat(_cat(DATABASE_INSTANCE,_$1),_CHILD_DATABASE_USER)]))

m4_undefine(parent_database_username)
m4_define([parent_database_username],m4_env2([_cat(_cat(_cat(DATABASE_INSTANCE,_),parent_database_user),_USERNAME)]))

m4_undefine(parent_database_password)
m4_define([parent_database_password],m4_env2([_cat(_cat(_cat(DATABASE_INSTANCE,_),parent_database_user),_PASSWORD)]))

m4_undefine(child_database_username)
m4_define([child_database_username],m4_env2([_cat(_cat(_cat(DATABASE_INSTANCE,_),child_database_user),_USERNAME)]))

m4_undefine(child_database_password)
m4_define([child_database_password],m4_env2([_cat(_cat(_cat(DATABASE_INSTANCE,_),child_database_user),_PASSWORD)]))

m4_undefine(database_user_relation_type)
m4_define([database_user_relation_type],m4_env2([_cat(_cat(DATABASE_INSTANCE,_$1),_DATABASE_USER_RELATION_TYPE)]))

])m4_dnl



#
# Macro:		m80NewWebServInstance
#
# Purpose:		adds info about an Web server instance
#
# Call Signature:	m80NewWebServInstance(hostname, user, server_type, server_version, port_start_range)
#

m4_define([m80NewWebServInstance],[
# $0($1,$2,$3,$4,$5,$6)
append_variable_space([WEB_SERV_HOSTS],[$1])
define_variable([$1_USER],[$2])
define_variable([$1_TYPE],[$3])
define_variable([$1_VERSION],[$4])
define_variable([$1_PORT_START_RANGE],[$5])
])


#
# Macro:		m80NewWebAppModule
#
# Purpose:		add a webapp module
#
# Call Signature:	m80NewWebAppModule(module_name, path_relative_to_webapp_subsystem_root )
#

m4_define([m80NewWebAppModule],[
# $0($1,$2,$3,$4,$5,$6,$7,$8)
append_variable_space([WEBAPP_MODULES],[$1])
define_variable([$1_PATH],[$2])
])m4_dnl
# define_variable([$1_FILEMASK],[$3])

# use the same m80CreateTargetModuleList macro
# use the m80NewModuleRelation macro (which isn't currently defined?)

m4_define([m80NewGenericModule],[
append_variable_space([$1[]_MODULES],[$2])
setFlags($3,$1[]_[]$2)])

m4_define([m80NewEntity],[# m80NewEntity($1,$2, ...)
append_variable_space([$1[]S],[$2])
setFlags($3,$1[]_[]$2)])

m4_define([m80NewApacheModule],[# m80NewApacheModule($1)
m80NewGenericModule(WEBSERVER,$1,$2)setFlags([(TYPE=APACHE,RESTART_COMMAND=[apachectl restart])],WEBSERVER_[]$1)])

m4_define([m80NewPostgresModule],[# m80NewPostgresModule($1)
m80NewGenericModule(DATABASE,$1,$2)setFlags([(TYPE=POSTGRES)],DATABASE_[]$1)])

m4_define([m80NewHost],[# m80NewHost($1)
m80NewGenericModule(HOST,$1,$2)])

m4_define([have_perforce],[
define_variable([HAVE_VC],[true])
define_variable([VC_TYPE],[p4])
define_variable([VC_ADD],[p4 add])
define_variable([VC_EDIT],[p4 edit])
])

m4_define([have_cvs],[
define_variable([HAVE_VC],[true])
define_variable([VC_TYPE],[cvs])
define_variable([VC_ADD],[cvs add])
define_variable([VC_EDIT],[chmod +w])
])

m4_divert
# end m80buildMacros.m4
