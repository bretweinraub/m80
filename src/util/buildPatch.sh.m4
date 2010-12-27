m4_include(shell/shellScripts.m4)m4_dnl
shell_load_functions(printmsg,cleanup,require,docmd,docmdi,docmdqi,checkfile)
#
# File:		buildPatch.sh
#
# Description:  This is an Oracle version of the (in)famous buildPatch script.
#		It is your friend.  It's been written for Solaris 2.6
#
# Notes:
#
# Here's the schema for this baby:
#
# -- -*-c-*-
# 
# -- Schema definitions for patch logging on database.
# 
# define V_TINY_EXT=8K
# define V_SMALL_EXT=64K
# 
# DROP TABLE m80moduleVersion
# /
# 
# /* The rowlock field uses a check constraint and a unique constraint that
#  * one and only one row can ever be inserted into this table. */
# 
# CREATE TABLE m80moduleVersion (
#   module_name			VARCHAR2(32) NOT NULL,
#   release 			NUMBER NOT NULL,
#   rowlock			NUMBER NOT NULL
#     CONSTRAINT m80moduleVersion_ck0 CHECK (rowlock IN (0)),
# --
#   CONSTRAINT m80moduleVersion_pk PRIMARY KEY (rowlock)
#     USING INDEX TABLESPACE index1 STORAGE
#       (INITIAL &&V_TINY_EXT NEXT &&V_TINY_EXT)
# )
# TABLESPACE data1
# STORAGE (INITIAL &&V_TINY_EXT NEXT &&V_TINY_EXT)
# /
# 
# DROP TABLE m80patchLog
# /
# 
# CREATE TABLE m80patchLog (
#   release                       NUMBER NOT NULL,
#   patchlevel                    NUMBER NOT NULL,
#   datetime_applied              DATE NOT NULL,
#   oracle_user                   VARCHAR2(32) NOT NULL,
#   hostname                      VARCHAR2(64) NOT NULL,
#   host_user                     VARCHAR2(64) NOT NULL,
#   host_path                     VARCHAR2(512) NOT NULL,
# -- 
#   CONSTRAINT m80patchLog_pk PRIMARY KEY (release, patchlevel)
#     USING INDEX TABLESPACE index1 STORAGE
#       (INITIAL &&V_SMALL_EXT NEXT &&V_SMALL_EXT)
# )
# TABLESPACE data1
# STORAGE (INITIAL &&V_SMALL_EXT NEXT &&V_SMALL_EXT)
# /
# 
# INSERT INTO 
#   m80moduleVersion (module_name, release, rowlock)
# VALUES
#   ( '&value_for_seed_module_name', &value_for_seed_release_number, 0
# );
# 

#########################################################################

shell_exit_handler
shell_getopt((s,-module_name),(r,-release_number),(p,-patch_number),(c,-code_file),(-f,force),(-m,produceM4))
m4_changequote(<++,>++)m4_dnl

checkfile -r ${code_file} does not exist or is not readable

# check for '"'s in the file
#

grep "\"\'s" ${code_file} >/dev/null 2>&1

if [ $? -eq 0 ]; then
    cleanup 3 '"'\'s are not allowed in the source file
fi

if [ ${patch_number} -lt 1 ]; then
    cleanup 2 -p [patch \#] must be greater than or equal to 1
fi

currentDir=`basename $(pwd)`

patchNum=$(perl -e 'printf ("%03d\n", '${patch_number}');')

#if [ "${currentDir}" != "${module_name}" ]; then

if [ -z "${produceM4}" ]; then
    shellSuffix="sh"
else
    shellSuffix="sh.m4"
fi

patchFile=r${release_number}/patch${patchNum}.${shellSuffix}
${DEBUG} mkdir -p r${release_number}
#else
#    patchFile=patch${patchNum}.sh
#fi


if [ -z "${force}" ]; then
    test ! -f ${patchFile} || cleanup 3 ${patchFile} already exists
fi

${DEBUG} exec > ${patchFile}

${DEBUG} cat <<EOF
#!/bin/sh

PROGNAME=\${0##*/}

#
# Function:	printmsg
#
# Description:	generic error reporting routine.
#               BEWARE, white space is stripped and replaced with single spaces
#
# \$Id: buildPatch.sh.m4,v 1.2 2004/03/12 21:40:22 bretweinraub Exp $
#

printmsg () {
    if [ \$# -ge 1 ]; then
	PRINTDASHN -n \$PROGNAME: >&2
	while [ \$# -gt 0 ]; do PRINTDASHN -n " "\$1 >&2 ; shift ; done
	echo . >&2
    fi
}

localclean=true

localclean () {
    rm -f \${TMPFILE} /tmp/\${PROGNAME}.\$\$.*
}

#
# Function:	cleanup
#
# Description:	
#
# \$Id: buildPatch.sh.m4,v 1.2 2004/03/12 21:40:22 bretweinraub Exp $
#

cleanup () {
    export EXITCODE=\$1
    shift
    if [ \$# -gt 0 ]; then
	printmsg \$*
    fi
    if [ -n "\${DQITMPFILE}" ]; then
	rm -f \${DQITMPFILE}
    fi
    if [ -n "\${LOCALCLEAN}" ]; then
	localclean # this function must be set
    fi
    if [ \${EXITCODE} -ne 0 ]; then
	# this is an error condition
	printmsg exiting with error code \${EXITCODE}
    else
	printmsg done
    fi
    exit \${EXITCODE}
}

#
# Function:	docmdqi
#
# Description:	execute a command quietly, but ignore the error code
#
# \$Id: buildPatch.sh.m4,v 1.2 2004/03/12 21:40:22 bretweinraub Exp $
#

docmdqi () {
    if [ \$# -lt 1 ]; then return; fi
    DQITMPFILE=/tmp/\${PROGNAME}.\$\$.dcmdqi
    eval \$* 2>&1 > \${DQITMPFILE}
    export RETURNCODE=\$?
    if [ \${RETURNCODE} -ne 0 ]; then
	cat \${DQITMPFILE}
    fi
    rm -f \${DQITMPFILE}
    return \$RETURNCODE
}
# \$Id: buildPatch.sh.m4,v 1.2 2004/03/12 21:40:22 bretweinraub Exp $
# check for connectivity

sqlnettest () {
    TMPFILE=\${TMPFILE:-/tmp/\${PROGNAME}.\$\$.snt}
    
    sqlplus \$1 2>&1 > \${TMPFILE} <<!
	whenever oserror exit failure;
	whenever sqlerror exit failure;
	select 1 from dual;
!
    
    if [ \$? -ne 0 ]; then
	if [ -f \${TMPFILE} ]; then
	    cat \${TMPFILE}
	fi
	docmdqi rm -f \${TMPFILE}
	cleanup 1 the connect string of \$1 is inoperable
    fi
    
    ERROR=\$(grep -c 'ERROR' \${TMPFILE})
    
    if [ "\$ERROR" -gt 0 ]; then
	cat \$TMPFILE
	echo
	docmdqi rm -f \${TMPFILE}
	cleanup 1 the connect string of \$1 is inoperable
    fi
    
    docmdqi rm -f \${TMPFILE}
}

sqlfunc () {
    TMPFILE=\${TMPFILE:-/tmp/\${PROGNAME}.\$\$}
    while getopts :idq c
	do case \$c in
	    i) ignoreError=true;;
	    q) quiet=true;;
	    d) DEBUG=true;;
	esac
    done

    if [ -n "\${DEBUG}" ]; then
	echo \*\*\* sqlplus code is :
cat<<!
\$code
!
	echo \*\*\* end sqlplus code
    fi

    sqlout=
    sqlplus -s \$DATABASE_NAME <<! >/dev/null 2>&1
    whenever oserror exit 3
    whenever sqlerror exit 5
    set echo off feedb off timi off pau off pages 0 lines 500 trimsp on
    spool \${TMPFILE}.sqlfunc
    \${code}
    exit success
!
    RC=\$?
    
    if [ -z "\$ignoreError" ]; then
	if [ \$RC -ne 0 ]; then	
	    cat \${TMPFILE}.sqlfunc
	    cleanup 1 failure of \$code
	fi
    else
	if [ -z "\${quiet}" ]; then	
	    cat \${TMPFILE}.sqlfunc
	    printmsg warning, failure of \$code
	fi
    fi

    if [ \$RC -eq 0 ]; then
	sqlout=\$(cat \${TMPFILE}.sqlfunc)
    fi
    if [ -n "\${DEBUG}" ]; then
	echo \*\*\* sqlplus output is :
	cat \${TMPFILE}.sqlfunc
	echo \*\*\* end sqlplus output
    fi
    return \$RC
}

usage () {
    cleanup 1 usage is \$PROGNAME -d {debug .. transaction rolled back} -v {display sql code} -c [connect-string] -i {print info and exit} -n {no checking ... just execute code \(be careful\)}
}

while getopts :dvinc: c
    do case \$c in
        c) DATABASE_NAME=\$OPTARG;;
	d) debug=TRUE;;
	v) verbose=TRUE;;
	i) info=TRUE;;
	n) nocheck=TRUE;;
	:) printmsg \$OPTARG requires a value
	   usage;;
	\?) printmsg unknown option \$OPTARG
	   usage;;
    esac
done

releaseNumber=${release_number}
patchNumber=${patch_number}
schemaName=${module_name}

buildDate="$(date '+%m/%d/%Y %T %Z')"
buildUser=$(whoami)
buildHost=$(hostname)
sourceCode=$(pwd)/${code_file}

if [ -n "\${info}" ]; then
    echo \${PROGNAME} was built \${buildDate} on \${buildHost} by \${buildUser} from file \${sourceCode}.
    echo \${PROGNAME} is for schema \${schemaName} release \${releaseNumber}.
    exit 0
fi

test -n "\${DATABASE_NAME}" || usage 

printmsg testing valid connectivity to \${DATABASE_NAME}
sqlnettest \${DATABASE_NAME}

hostname=\$(hostname)
host_user=\$(whoami)
host_path=\$(pwd)/\${PROGNAME}

# get release number  (as opposed to THIS patchs release number).

code="
  select 
    release 
  from 
    m80moduleVersion 
  where
    module_name = '${module_name}';
"

sqlfunc

curReleaseNumber=\$sqlout

# get patch number

code="
  select 
    NVL(max (patchlevel),0) 
  from
    m80patchLog 
  where
    module_name = '\${schemaName}' 
  and
    release = '\${curReleaseNumber}';
"

sqlfunc
curPatchNumber=\$sqlout

if [ -z "\${nocheck}" ]; then
    if [ "\${releaseNumber}" != "\${curReleaseNumber}" ]; then
	cleanup 3 r\${releaseNumber} patch will not apply against r\${curReleaseNumber} database
    fi
fi

if [ -z "\${nocheck}" ]; then
    if ((\$patchNumber - \$curPatchNumber != 1)); then
	cleanup 4 last patch applied was \$curPatchNumber, patch \$patchNumber failed
    fi
fi

code="
EOF
# "

${DEBUG} cat ${code_file}

${DEBUG} cat <<EOF
  INSERT INTO 
    m80patchLog (module_name, release, patchlevel, datetime_applied, hostname, host_user, host_path)
  VALUES
    ('\${schemaName}', '\${curReleaseNumber}', \${patchNumber}, SYSDATE, '\${hostname}', '\${host_user}', '\${sourceCode}');

"

if [ -n "\${debug}" ]; then
    code=\$code"
    rollback;
"
fi

test -z "\${verbose}" || eval 'echo; echo CODE IS: ; echo ; echo \$code'

sqlfunc
echo \$sqlout > \${PROGNAME}.\$\$.log

test -z "\${verbose}" || eval 'echo; echo OUTPUT IS: ; echo ; cat \${PROGNAME}.\$\$.log; echo'

if [ -n "\${debug}" ]; then
    printmsg transaction was rolled back in virtue of debug flag
fi

printmsg output was left in \${PROGNAME}.\$\$.log

cleanup 0

EOF

${DEBUG} chmod +x ${patchFile}
printmsg output left in ${patchFile}
cat 1>&2 <<EOF
Did you remember:

- 	patches are wrapped in 'whenever sqlerror' exit.  Your patch should not
	produce ignored errors.
	
	consider wrapping them as such if they do
	
	BEGIN
		execute immediate 'whatever';
	EXCEPTION
		when others then
		NULL;
	END;
	/

-	To explicitly define tablespaces and storage clauses if appropriate.

-	Your code should not depend on anything other than the current 
	serialized version of this database as managed within these patches.
	Packages, functions, and views are not patch managed and if you 
	are expecting a particular version to exist, your patch may fail.

Have a nice day.
EOF

cleanup 0

