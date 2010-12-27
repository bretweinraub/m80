m4_include(shell/shellScripts.m4)m4_dnl
shell_load_functions(printmsg,cleanup,require,docmd,docmdi,docmdqi,checkfile,loadenv)
#any code placed here will be included into script exithandler
#by default the exit handler is called on INT QUIT TERM HUP
#and by the "cleanup" shell function
shell_exit_handler

#
#  a couple of helper macros so that we can list this scripts
#  commands in a single place
#

m4_define([commandGen1],
[ 	 --$1)
	  command=$1
	  shift
	  ;;
])m4_dnl
m4_define([commandGen2],
[ 	  --$1	($2)
])m4_dnl

m4_define([relist],[$1$2])m4_dnl

#
# Need to add a command?  Do it on the next line.
#

m4_define([commandsList],[((newModule,builds a new m80 module),(newRepository,builds a new m80 repository),(version,prints out the command version),(libpath,print out the m80 lib path),(reconf,rebuilds the m80 repository),(execute,execute a command in the current m80 environment),(env,show the relevant M80 environment variables),(dump,dump the build environment),(dumpxml,dump the xml repository),(oldschool,run an oldschool m80 build),(chooser,select a m80 env),(export,generate export statements for the current environment),(genfuncs,generates convenient shell functions for eval),(directory,choose an m80 repository or other variables based on a m80 directory),(diredit,edit the m80 directory file))])m4_dnl

case $[]1 in
m4_foreach([X],commandsList,[relist([commandGen1],X)])
esac

export M80_DIRECTORY=${M80_DIRECTORY:-~/.m80directory}

if test -z "$command"; then
    cat <<EOF >&2
${PROGNAME}: a sub-command is required.  For example:

${PROGNAME} --newModule arg1 arg2 ...

Available commands are:

m4_foreach([X],commandsList,[relist([commandGen2],X)])

Arguments depend on subcommands.  See the documentation for a particular subcommand,
or run a subcommand with no arguments to see a usage statement.
EOF
    cleanup 1 
fi

m4_changequote(<++,++>)

archiveOpts () {
    while test $# -gt 0; do
	archivedOpts=${archivedOpts}" \"$1\""
	shift
    done
}
archiveOpts $*

m80ReposFiles () {
    if [ -n "${M80_BDF}" ]; then
        echo ${M80_REPOSITORY}/projects/${PROJECT}.sh ${M80_REPOSITORY}/bdfs/${M80_BDF}.sh ${M80_REPOSITORY}/environments/${ENV}.sh
    elif [ -n "${M80_ENV}" -a -n "${M80_PROJECT}" ]; then
        echo ${M80_REPOSITORY}/projects/${M80_PROJECT}.sh ${M80_REPOSITORY}/environments/${M80_ENV}.sh        
    elif [ -n "${M80_ENV}" ]; then
        echo ${M80_REPOSITORY}/environments/${M80_ENV}.sh        
    fi
#    echo ${M80_REPOSITORY}/projects/${PROJECT}.sh ${M80_REPOSITORY}/bdfs/${M80_BDF}.sh ${M80_REPOSITORY}/environments/${ENV}.sh
}

m80env () {
    M80_SUPRESS_PERIOD=true
    test -f ${M80_REPOSITORY}/module.mk && {
	. ${M80_REPOSITORY}/module.mk
    }
    M80_REPOSITORY_TYPE=${M80_REPOSITORY_TYPE:-tagvalue}
    printmsg \$M80_DIRECTORY" : "${M80_DIRECTORY}" ("${M80_DIRECTORY_SELECTED}")"
    printmsg \$M80_REPOSITORY" : "${M80_REPOSITORY}" ("${M80_REPOSITORY_TYPE}")"
    printmsg \$M80_BDF" : "${M80_BDF}
    printmsg \$TOP" : "${TOP}
    unset M80_SUPRESS_PERIOD
}


# requireSet () { 
#     test $# -ne 1 && {
# 	return 
#     }
#     derived=$(eval "echo \$"$1) ; 
#     test -z "$derived" && {
#          echo variable \$${1} was not found in the build environment
#          eval `varWarrior ${1}` 
#          eval export ${1}=$(eval "echo \$"$1) 
#     }
# }  

# validate () {
#     for var in ${M80_REQUIRED_VARIABLES} ; do 
#         requireSet $var 
#     done 
# }


# loadenv () {
#     require M80_REPOSITORY
#     require M80_BDF
#     (cd ${M80_REPOSITORY}; make all 1> /dev/null)
#     test -f ${M80_REPOSITORY}/module.mk && {
# 	. ${M80_REPOSITORY}/module.mk
#     }
#     if [ "${M80_REPOSITORY_TYPE}" != "xml" ]; then
# 	. ${M80_REPOSITORY}/bdfs/${M80_BDF}.sh
# 	test -n "${ENV}" && {
# 	    . ${M80_REPOSITORY}/environments/${ENV}.sh
# 	}
# 	test -n "${PROJECT}" && { 
# 	    . ${M80_REPOSITORY}/projects/${PROJECT}.sh
# 	}
#     else
# 	eval $(exportXML.pl -export)
#     fi
#     validate
# }

buildModuleMakefile () {
    OPTIND=0 # required in bash
    while getopts :S:R: c
      do case $c in        
	S)  export SUBS=$OPTARG;;
	R)  export RULES=$OPTARG;;
	:) printmsg $OPTARG requires a value in buildModuleMakefile;;
	\?) printmsg unknown option $OPTARG to buildModuleMakefile;;
      esac
    done

    ssubs=$(echo ${SUBS} | sed -e 's/,/ /g')
    rrules=$(echo ${RULES} | sed -e 's/,/ /g')
    
    cat <<EOF

SUBS	=	${ssubs}

SUBRULES=	${rrules} 

LOCALRULES=	latest

default ::
	@echo 'No action taken by default ..... try one of \$(SUBRULES) \$(LOCALRULES).'

#nothing 	:; @echo Nothing to be done for \$@

#include		\$(SYSDEPTH)/node.mk

\$(SUBRULES) ::	
	@set X \$(SUBS); shift ; \\
	for dir \\
	do \\
		echo "Making \$@ in \$\$dir:" ; \\
		(cd ./\$\$dir ; \$(MAKE) -S \$@ ); \\
		if test \$\$? -ne 0 ; then exit 1 ; fi ; \\
	done

EOF
}

#
# First replace \ with \\
# then replace $ with \$
#

#
#
# To be honest this should get replaced with a generated makefile in /usr/local/share/m80
#

writeM4Rules () {
    for suffix in $(echo $* | tr "," "\n"); do
	echo "%."${suffix}" : %."${suffix}.m4 Makefile
cat <<EOF
	@export REQUIRED_VALUES=\$\$(awk '\$\$2 == "M80_VARIABLE" {print \$\$3}' < $<) ; \\
        echo REQUIRED_VALUES are \$\${REQUIRED_VALUES} ; \\
        eval \`varWarrior \$\$REQUIRED_VALUES\` ; \\
	if test -n "\${VC_EDIT}" -a -z "\${SUPPRESS_VC}"; then \\
		\${VC_EDIT} \$@ ; \\
	fi ; \\
	echo \$(<++M4++>) \$(M4_FLAGS) \$\$(echo \$\${MACRO_DEFS} | tr \\' \\") \$< \\> \$@ ; \\
        if test -s \$*.m4errors ; then \\
           rm -f \$*.m4errors ; \\
        fi ; \\
	eval \$(<++M4++>) \$(M4_FLAGS) \$\$(echo \$\${MACRO_DEFS} | tr \\' \\") \$< 2> \$*.m4errors > \$@ ; \\
        if test  \$\$? -ne 0 -o -s \$*.m4errors ; then \\
           echo m4 errors\\; bailing out ; \\
	   echo Errors from file \$*.m4errors : ; \\
           cat \$*.m4errors ; \\
           exit 1 ; \\
        else  \\
           rm -f \$*.m4errors ; \\
        fi ; \\
	exit 0
${suffix}m4files	=	\$(wildcard *.${suffix}.m4)
derived${suffix}files = 	\$(${suffix}m4files:.${suffix}.m4=.${suffix})
clean		::;	rm -f \$(derived${suffix}files)
EOF
	done
        echo m4command	::\;	echo \$\(<++M4++>\) \$\(M4_FLAGS\)
}

writeHeader () {
	cat <<EOF
# this file was programtically generated by $PROGNAME, edit it at your own risk.
#
# $PROGNAME was base_build_signature
# 
# Edits MAY be lost if this file is regenerated.
#
# The following line(s) is for internal use and should not be changed:
# CLISP (setq COMMAND "$command"
# CLISP       ARGS '($archivedOpts)
# CLISP       <++VERSION++> "VERSION")
#

M80LIB=\$(shell m80 --libpath)

# The following loads local make rules.  Use this local file
# for rules, as editing this file could cause your rules to be overwritten.

localHeadRules=\$(wildcard localHead.mk)
ifneq (\$(localHeadRules),)
include localHead.mk
endif
EOF
}

writeTailRule () {
    cat <<EOF
#
# The following loads local make rules.  Use this local file
# for rules, as editing this file could cause your rules to be overwritten.
#

localTailRules=\$(wildcard localTail.mk)
ifneq (\$(localTailRules),)
include localTail.mk
endif
EOF
}

writeBdfRule () {
    cat <<EOF
ifdef M80_BDF
  ifdef M80_REPOSITORY
    include \$(M80_REPOSITORY)/bdfs/\$(M80_BDF).mk

    ifneq (\$(ENV),)
      include \$(M80_REPOSITORY)/environments/\$(ENV).mk
    endif

    ifneq (\$(PROJECT),)
      include \$(M80_REPOSITORY)/projects/\$(PROJECT).mk
    endif

  endif
endif
EOF
}

writeSuffixes () {
	PRINTDASHN -n "SUFFIXES	=	"
	for suffix in $(echo $* | tr "," "\n"); do
	    PRINTDASHN -n "."$suffix" ."${suffix}.m4" "
	done
	echo
}

writeMakefile () {
    printmsg writeMakefile $*
    OPTIND=0 # required in bash
    while getopts :t:m:M:P:s:S:A: c
      do case $c in        
	t)  export type=$OPTARG;;
	m)  export lModuleName=$OPTARG;;
	M)  export lModuleDir=$OPTARG;;
	P)  export modulePath=$OPTARG;;
	s)  export specialCode=$OPTARG;;
	A)  export addMakeFiles=$OPTARG;;
	:) printmsg $OPTARG requires a value in writeMakefile;;
	\?) printmsg unknown option $OPTARG to writeMakefile;;
      esac
    done

    target=${lModuleDir}/Makefile
    printmsg Creating rules in ${target}
    docmd mkdir -p $lModuleDir
    if test -e ${target} && test -z "${FORCE}"; then
	cleanup 1 ${target} exists, use \-f to force overwrite
    else
	if test -n "${VC_EDIT}" -a -z "${SUPPRESS_VC}"; then
		${VC_ADD} $target
		${VC_EDIT} $target
	fi 
	docmdi rm -f ${target}.old
	if test -f ${target}.old ; then
	    docmdqi mv ${target} ${target}.old 
	fi
    fi
    printmsg creating ${target}
    exec 6<&1          # link stdout to 6
    exec > ${target}   # stdout is redirected to ${target}
    writeHeader
#    writeBdfRule
    if test -n "${modulePath}" ; then
	echo "MODULE_PATH="${modulePath}
	echo include \$\(MODULE_PATH\)/module.mk
    fi
    echo "include \$(M80LIB)/make/local.mk"
    echo "include \$(M80LIB)/make/m80generic.mk"
    echo "include \$(M80LIB)/make/repositoryRules.mk"
    for addMake in $(echo ${addMakeFiles} | tr "," "\n"); do
	echo include ${addMake}
    done
    if test $type = "generic"; then 
	if test -n "${suffixes}" ; then
	    writeSuffixes ${suffixes}	
	    writeM4Rules ${suffixes}
	fi
    elif test $type = "dbBaseline"; then	
        echo include \$\(M80LIB\)/make/systemWide.mk
	echo include \$\(M80LIB\)/make/${databaseType}.mk
	echo M4_FLAGS += -DRDBMS_TYPE=\$\(RDBMS_TYPE\)
	echo baseline :: destructcheck ${moduleName}.log
	writeSuffixes sql
	writeM4Rules sql
    fi
    if test -n "$specialCode" ; then
	eval $specialCode
    fi
    writeTailRule
    exec 1<&6 6<&-  # take 6 back to 1 and close 6.
    if test -f ${target}.old ; then 
	docmdqi diff ${target} ${target}.old 2> /dev/null
	if test $? -eq 0 ; then
	    docmdqi rm ${target}.old
	fi
    fi
#
#   clean these local vars up so this procedure is re-entrant.
#
    export type=
    export lModuleName=
    export lModuleDir=
    export modulePath=
    export specialCode=
    export addMakeFiles=
}

newDir="docmd mkdir -p "

if test "$command" = "newModule"; then 
    m4_changequote([,])
    shell_getopt((m,-moduleName),(n,seqIncrementNo,1 ),(v,seqIncrementVal,1 ),(t,-moduleType,generic,(generic,database,webDBModule)),(-f, FORCE),(M,-moduleDir,$moduleName),(S, suffixes),(D,databaseType,,(oracle,postgresql)),(P,pathToModuleMakeFile),(A,addMakeFiles))
    m4_changequote(<++,++>)
    moduleName=$(echo $moduleName | cut -d/ -f1)
m4_define(<++if_command++>,<++elif test "$command" = "$1"; then++>)m4_dnl
    if test $moduleType = "generic"; then
	if [ -d $moduleName -a ! -n "${FORCE}" ]; then
	    cleanup 1 $moduleName exists\; use -f to force
	fi
	export SUFFIXES=${suffixes}
	cmd="m80templateDir.pl -source M80_LIB/../templates/generic -dest $moduleName"
	test -n "$DEBUG" && {
	    cmd=$cmd" -debug"
	}
	docmd $cmd
	cleanup 0 done
    elif test $moduleType = "webDBModule"; then
      require databaseType
      $newDir $moduleName
      cd $moduleName
      writeMakefile -t unknown -m $moduleName -M . -P .  -s "buildModuleMakefile -R clean,baseline -S db,web" 
      docmd m80 --newModule -M db -d ${moduleName} -n $seqIncrementNo -v $seqIncrementVal -m database -f  -D $databaseType -P ..
      docmd m80 --newModule -M web -d ${moduleName} -m generic -P .. -f -A \$\(M80LIB\)/make/webDBweb.mk
    elif test $moduleType = "database"; then
      require databaseType
#      moduleDir=$moduleName

      doVersionControl () {
	  test -n "$havePerforce" && {
	      p4 ${p4Command} $1
	  }
      }

      ${newDir} $moduleDir

#      cat > $moduleDir/depth.mk <<EOF
#MODDEPTH=.
#SUBSYSDEPTH=$subsysDepth
#SYSDEPTH=$sysDepth
#EOF

    cat > $moduleDir/${pathToModuleMakeFile}/module.mk <<EOF
# -*-makefile-*- #############################################################
#
# File:		module.mk
#
# Description:	this are for make macro definitions specific to the $moduleName
#		module
#
# Date:		
#
##############################################################################

#
# SCHEMA_NAME - this is built directly into the CM_DATABASE_VERSION table, and
# 		becomes a token that logically seperates this database schema
#		from others.
#

localHeadRules=\$(wildcard \$(MODULE_PATH)/localHead.mk)
ifneq (\$(localHeadRules),)
include \$(MODULE_PATH)/localHead.mk
endif

export MODULE_NAME		=	$moduleName
export SCHEMA_NAME		=	\$(MODULE_NAME)
export RELEASE_NUMBER		=	1.0
export RDBMS_TYPE		=	$databaseType
export SEQ_INCREMENT_NO         =       $seqIncrementNo
export SEQ_INCREMENT_VAL        =       $seqIncrementVal

module_name		::;	@echo \$(MODULE_NAME)
release_number		::;	@echo \$(RELEASE_NUMBER)

localTailRules=\$(wildcard \$(MODULE_PATH)/localTail.mk)
ifneq (\$(localTailRules),)
include \$(MODULE_PATH)/localTail.mk
endif

EOF


    writeMakefile -t unknown -m $moduleName -M $moduleDir -P ${pathToModuleMakeFile:-.}  -s "buildModuleMakefile -R clean,patch,baseline -S baseline,src"
    ${newDir} $moduleDir/baseline
    ${newDir} $moduleDir/src
    ${newDir} $moduleDir/src/code
    ${newDir} $moduleDir/src/schema
    ${newDir} $moduleDir/src/schema/src
    ${newDir} $moduleDir/src/schema/r1.0

#    cat > $moduleDir/baseline/depth.mk <<EOF
#MODDEPTH=..
#SUBSYSDEPTH=\$(MODDEPTH)/$subsysDepth
#SYSDEPTH=\$(MODDEPTH)/$sysDepth
#EOF

    writeMakefile -t dbBaseline -m  $moduleName -M $moduleDir/baseline -P ../${pathToModuleMakeFile:-.}
    if test ! -e $moduleDir/baseline/localObjects.sql ; then
cat > $moduleDir/baseline/localObjects.sql <<EOF
-- local objects -*-perl-*-
--
--
-- createM80[]StandardTable
-- Arg1 => tablename
-- Arg2 => custom columns In a list
-- Arg3 => List of reference tables
-- Arg4 => a List of check constraints
-- (checkConstraint1 [, .... checkConstraint1n])
-- where each check constraint is of form
-- (field, nullflag, (list of values))
--
-- some useful tokens:
-- varcharType
-- INSTANTIATION_TABLE
-- datetime
-- bigNumber
--
--
-- if nullflag is blank, nulls are not allowed
-- Arg5 => list of arguments of form (flag1,flag2=value2,flag3
EOF
    fi

    docmd touch $moduleDir/baseline/localObjects.sql

    cat > $moduleDir/baseline/$moduleName.sql.m4 <<EOF
-- -*-sql-*--

-- M80_VARIABLE SCHEMA_NAME
-- M80_VARIABLE RELEASE_NUMBER
-- M80_VARIABLE MODULE_NAME
-- M80_VARIABLE SEQ_INCREMENT_NO
-- M80_VARIABLE SEQ_INCREMENT_VAL

<++m4_include(m4/base.m4)++>
<++m4_include++>(db/RDBMS_TYPE/RDBMS_TYPE.m4)
<++m4_include++>(db/generic/tables.m4)
m80init
<++newModule(SCHEMA_NAME,RELEASE_NUMBER)++>
-- put your baseline objects in localObjects.sql
<++m4_include++>(./localObjects.sql)

EOF


writeSrcMakefile () {
    cat <<EOF

SUBS	=	schema code 

SUBRULES=	patch

default ::
	@echo 'No action taken by default ..... try one of \$(SUBRULES).'

replication baseline 	:; @echo Nothing to be done for \$@

#include		\$(SYSDEPTH)/node.mk

\$(SUBRULES) ::	# recurse 
	@set X \$(SUBS); shift ; \\
	for dir \\
	do \\
		echo "Making \$@ in \$\$dir:" ; \\
		(cd ./\$\$dir ; \$(MAKE) -S \$@ ); \\
		if [ \$\$? -ne 0 ]; then exit 1 ; fi ; \\
	done
EOF
}

    writeMakefile -t unknown -m $moduleName -M $moduleDir/src  -s writeSrcMakefile  -P ../${pathToModuleMakeFile:-.}

#    cat > $moduleDir/src/depth.mk <<EOF
#MODDEPTH=..
#SUBSYSDEPTH=\$(MODDEPTH)/$subsysDepth
#SYSDEPTH=\$(MODDEPTH)/$sysDepth
#EOF

writeCodeMakefile () {
    cat <<EOF
# nothing yet
EOF
}

    writeMakefile -t unknown -m $moduleName -M $moduleDir/src/code -s writeCodeMakefile  -P ../../${pathToModuleMakeFile:-.} -A \$\(M80LIB\)/make/dbcode.mk,\$\(M80LIB\)/make/${databaseType}.mk


    if [ ! -e $moduleDir/src/code/repository.conf ]; then
	cat > $moduleDir/src/code/repository.conf <<EOF
# -*-makefile-*- #############################################################
#
# File:		repository.conf
#
# Description:	this file contains a representation of the code repository for
#		use by the 'make patch' and 'make diff' rules.  See the
#		Makefile in this directory for more information.
#
# Format:
#
#	line 		: {comment | repository-line}
#
#	comment 	: '#' any-tokens newline
#
#	field-separator : {white-space} ':' {white-space}
#	repository-line	: {source-file} {field-separator} {object-name} {field-separator} {object-type}
#		
#
# Warning : 	Please no blank lines in the file, thanks.
#
# Date:		???		bdw	original
#
##############################################################################
#

EOF
    fi


#    cat > $moduleDir/src/code/depth.mk <<EOF
#MODDEPTH=../..
#SUBSYSDEPTH=\$(MODDEPTH)/$subsysDepth
#SYSDEPTH=\$(MODDEPTH)/$sysDepth
#EOF


#    cat > $moduleDir/src/schema/depth.mk <<EOF
#MODDEPTH=../..
#SUBSYSDEPTH=\$(MODDEPTH)/$subsysDepth
#SYSDEPTH=\$(MODDEPTH)/$sysDepth
#EOF


writeSchemaMakefile () {
    cat <<EOF

include \$(M80LIB)/make/${databaseType}.mk

#define this for a "masterdef" module
#IS_MASTERDEF_MODULE	= true

include	\$(M80LIB)/make/schemaPatch.mk
EOF
}

    writeMakefile -t unknown -m $moduleName -M $moduleDir/src/schema -s writeSchemaMakefile  -P ../../${pathToModuleMakeFile:-.} 

#    cat > $moduleDir/src/schema/$moduleName/r1.0/depth.mk <<EOF
#MODDEPTH=../../../..
#SUBSYSDEPTH=\$(MODDEPTH)/$subsysDepth
#SYSDEPTH=\$(MODDEPTH)/$sysDepth
#EOF

writeR10Makefile () {
    cat <<EOF

include $(M80LIB)/make/${databaseType}.mk
EOF
}

    writeMakefile -t unknown -m $moduleName -M $moduleDir/src/schema/r1.0/ -s writeR10Makefile  -P ../../../${pathToModuleMakeFile:-.} -s"writeSuffixes sh;writeM4Rules sh"
  fi
if_command(version)
    if [ $# -gt 0 ]; then
	echo VERSION
	exit 0
    fi
    printmsg version VERSION, by Bret Weinraub and Jim Renwick
    printmsg m80 is free software, see the LICENSE file for restrictions
    printmsg base_build_signature
if_command(diredit)
    EDITOR=${EDITOR:-vi}
    if [ ! -f $M80_DIRECTORY/directory.dat ]; then
	docmd mkdir -p $M80_DIRECTORY
	cat > $M80_DIRECTORY/directory.dat <<EOF
#
# this is a m80 directory file.
#

%directory = (
	      dummy => {
		  description => "dummy description",
		  ANY_ENV_VARIABLE => "ANY VALUE",
	      },);

#
# run m80 --directory to load your directory entry.
#
# or run eval \$(m80 --genfuncs) to load the m80directory alias.
#

EOF
    fi
    ${EDITOR} $M80_DIRECTORY/directory.dat
if_command(directory)
    m80repos.pl
if_command(genfuncs)
    cat M80_LIB/shell/shellcommands.sh
if_command(libpath)
    echo M80_LIB
if_command(reconf)
    (cd ${M80_REPOSITORY} ; make clean all)
if_command(env)
    m80env
if_command(dumpxml)
    m80env
    loadenv
    if [ "${M80_REPOSITORY_TYPE}" != "xml" ]; then
	cleanup 1 not an xml repository
    else
	cat ${M80_REPOSITORY}/bdfs/${M80_BDF}
    fi
if_command(export)
    loadenv
    if [ "${M80_REPOSITORY_TYPE}" != "xml" ]; then
	exports=$(grep export $(m80ReposFiles) 2> /dev/null | perl -ple 's/^.*?export\s+(\w+)=.*$/$1/;' | sort -u)
	for export in $exports; do 
	    echo export $export=\"$(eval echo \$$export)\"
	done
    else
	cleanup 1 not implemented for xml repository
    fi
if_command(dump)
    m80env
    loadenv

    if [ "${M80_REPOSITORY_TYPE}" != "xml" ]; then
        printmsg "Checking $(m80ReposFiles)"
	exports=$(grep export $(m80ReposFiles) 2> /dev/null | perl -ple 's/^.*?export\s+(\w+)=.*$/$1/;' | sort -u)
	for export in $exports; do 
	    echo $export=$(eval echo \$$export)
	done
    else
	exportXML.pl 
#	cat ${M80_REPOSITORY}/bdfs/${M80_BDF}
    fi
if_command(oldschool)
    export M80_OVERRIDE_DOLLAR0=${PROGNAME} 
    eval naiveProcess \'$1\' \'$2\' \'$3\' \'$4\' \'$5\' \'$6\' \'$7\' \'$8\' \'$9\' \'$10\' \'$11\' \'$12\' \'$13\' \'$14\' \'$15\' \'$16\' \'$17\' \'$18\' \'$19\' \'$20\' \'$21\' \'$22\' \'$23\' \'$24\' \'$25\' \'$26\' \'$27\' \'$28\' \'$29\' \'$30\' \'$31\' \'$32\' \'$33\' \'$34\' \'$35\' \'$36\' \'$37\' \'$38\' \'$39\' \'$40\' \'$41\' \'$42\' \'$43\' 
    exit $?
if_command(execute)
    loadenv
    if [ -z "${QUIET}" ]; then 
	printmsg running $*
    fi
    eval $*
if_command(newRepository)
    m4_changequote([,])
    shell_getopt((-d, DEBUG),(-f, FORCE),(r,repositoryName,m80repository),(t,-repositoryType,,(tagvalue,xml)))
    m4_changequote(<++,++>)
    if test -z "${FORCE}"; then
	checkNotFile -e ${repositoryName} already exists, try using -f to overwrite
    else
	checkfile -d $repositoryName is not a directory, dude
    fi

    if [ "${repositoryType}" = "xml" ]; then
	cmd="m80templateDir.pl -source M80_LIB/../templates/m80xmlRepos -dest $repositoryName"
	test -n "$DEBUG" && {
	    cmd=$cmd" -debug"
	}
	docmd $cmd
	cleanup 0 done
    fi
    for dir in $repositoryName $repositoryName/bdfs $repositoryName/projects $repositoryName/environments; do
	docmd mkdir -p $dir
    done
    for dir in $repositoryName/bdfs $repositoryName/projects $repositoryName/environments; do
	printmsg creating $dir/Makefile
	exec 6<&1 # stdout is redirected to 6
	exec > $dir/Makefile  # redirect stdout to a file
	writeHeader
	echo "include \$(M80LIB)/make/local.mk"
	echo "include \$(M80LIB)/make/m80generic.mk"
	echo "include \$(M80LIB)/make/repositoryRules.mk"
	writeTailRule
	exec 1<&6 6<&- # take 6 back to 1 and close 6
    done
    exec 6<&1 # stdiout is 6
    exec > $repositoryName/Makefile  # redirect stdout to a file
    writeHeader
    cat <<EOF
SUBS=bdfs environments projects
all default clean realclean ::
	@set X \$(SUBS); shift ; \\
	for dir \\
	do \\
		echo "Making \$@ in \$\$dir:" ; \\
		(cd ./\$\$dir ; \$(MAKE) -S \$@ ); \\
		if [ \$\$? -ne 0 ]; then exit 1 ; fi ; \\
	done
EOF
    writeTailRule
    exec 1<&6 6<&- # take 6 back to 1 and close 6
if_command(chooser)
    if [ -z "$M80_REPOSITORY" ]; then
	$(m80 --env)
       cleanup 2 set M80_REPOSITORY
    fi
    if [ -f ${M80_REPOSITORY}/module.mk ]; then
	. ${M80_REPOSITORY}/module.mk
    fi
    if [ "${M80_REPOSITORY_TYPE}" = "xml" ]; then
	bdfs=$(/bin/ls $M80_REPOSITORY/bdfs/*.m80 | perl -nle 's/.*\/(.*)\.m80/$1/g; print') 
    else
	bdfs=$(/bin/ls $M80_REPOSITORY/bdfs/*.m4 $M80_REPOSITORY/bdfs/*.m80 | perl -ple 's/.*\/(.*)\.(m4|m80)$/$1/g' | perl -ple 's/\.(sh|mk)//')
    fi
    x=0
    if [ -z "$bdfs" ]; then
	cleanup 3 no bdf files found in $M80_REPOSITORY
    fi
    set $bdfs
    printmsg try \"eval \$\(m80 --chooser\)\"
    while [ $# -gt 0 ];do 
	((x=$x+1))
	echo $x"): "$1 >&2
	shift
    done
    read line
    x=0
    set $bdfs
    while [ $# -gt 0 ];do 
	((x=$x+1))
	if [ "$line" = "$x" ]; then
	    echo export M80_BDF=$1
	fi
	shift
    done
else
    printmsg unknown command 
fi
#
# Local Variables:
# mode: shell-script
# End:
# 

