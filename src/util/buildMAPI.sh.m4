m4_changecom()
#!/bin/sh
PROGNAME=${0##*/}
DIRNAME=$(dirname $0)
TMPFILE=/tmp/${PROGNAME}.$$
usage () {
#  echo Usage: $PROGNAME: -c {isComponent} [-p ProtoFiles] objectName
  echo Usage: $PROGNAME: -p {ProtoFiles} -m {MailingTable} objectName
  exit 1
}
#
# Function:	printmsg
#
# Description:	generic error reporting routine.
#               BEWARE, white space is stripped and replaced with single spaces
#
# $Id: buildMAPI.sh.m4,v 1.3 2004/04/09 20:30:13 bretweinraub Exp $
#
printmsg () {
    if [ $# -ge 1 ]; then
	PRINTDASHN -n $PROGNAME: >&2
	while [ $# -gt 0 ]; do PRINTDASHN -e " "$1 >&2 ; shift ; done
	echo . >&2
    fi
}
#
# Function:	cleanup
#
# Description:	generic KSH funtion for the end of a script
#
# History:	02.22.2000	bdw	passed error code through to localclean
#
# $Id: buildMAPI.sh.m4,v 1.3 2004/04/09 20:30:13 bretweinraub Exp $
#
cleanup () {
    export EXITCODE=$1
    shift
    if [ $# -gt 0 ]; then
	printmsg $*
    fi
    if [ -n "${DQITMPFILE}" ]; then
	rm -f ${DQITMPFILE}
    fi
    if [ -n "${LOCALCLEAN}" ]; then
	localclean ${EXITCODE} # this function must be set
    fi
    if [ ${EXITCODE} -ne 0 ]; then
	# this is an error condition
	printmsg exiting with error code ${EXITCODE}
    else
	printmsg done
    fi
    exit ${EXITCODE}
}
# $Id: buildMAPI.sh.m4,v 1.3 2004/04/09 20:30:13 bretweinraub Exp $
# check for connectivity
sqlnettest () {
    TMPFILE=${TMPFILE:-/tmp/${PROGNAME}.$$.snt}
    
    sqlplus $1 2>&1 > ${TMPFILE} <<EOF
	select 1 from dual;
EOF
    
    if [ $? -ne 0 ]; then
	if [ -f ${TMPFILE} ]; then
	    cat ${TMPFILE}
	fi
	docmdqi rm -f ${TMPFILE}
	cleanup 1 the connect string of $1 is inoperable
    fi
    
    ERROR=$(grep -c 'ERROR' ${TMPFILE})
    
    if [ "$ERROR" -gt 0 ]; then
	cat $TMPFILE
	echo
	docmdqi rm -f ${TMPFILE}
	cleanup 1 the connect string of $1 is inoperable
    fi
    
    docmdqi rm -f ${TMPFILE}
}
#
# Function:	docmdqi
#
# Description:	execute a command quietly, but ignore the error code
#
# $Id: buildMAPI.sh.m4,v 1.3 2004/04/09 20:30:13 bretweinraub Exp $
#
docmdqi () {
    if [ $# -lt 1 ]; then return; fi
    DQITMPFILE=/tmp/${PROGNAME}.$$.dcmdqi
    eval $* 2>&1 > ${DQITMPFILE}
    export RETURNCODE=$?
    if [ ${RETURNCODE} -ne 0 ]; then
	cat ${DQITMPFILE}
    fi
    rm -f ${DQITMPFILE}
    return $RETURNCODE
}
sqlnettest $DATABASE_NAME
sqlfunc () {
    TMPFILE=${TMPFILE:-/tmp/${PROGNAME}.$$}
    while getopts :idq c
	do case $c in
	    i) ignoreError=true;;
	    q) quiet=true;;
	    d) DEBUG=true;;
	esac
    done
    if [ -n "${DEBUG}" ]; then
	echo -e \*\*\* sqlplus code is :
cat<<EOF
$code
EOF
	echo -e \*\*\* end sqlplus code
    fi
    sqlout=
    sqlplus -s $DATABASE_NAME <<EOF >/dev/null 2>&1
    whenever oserror exit 3
    whenever sqlerror exit 5
    set echo off feedb off timi off pau off pages 0 lines 500 trimsp on
    spool ${TMPFILE}.sqlfunc
    ${code}
    exit success
EOF
    RC=$?
    
    if [ -z "$ignoreError" ]; then
	if [ $RC -ne 0 ]; then	
	    cat ${TMPFILE}.sqlfunc
	    cleanup 1 failure of $code
	fi
    else
	if [ -z "${quiet}" ]; then	
	    cat ${TMPFILE}.sqlfunc
	    printmsg warning, failure of $code
	fi
    fi
    if [ $RC -eq 0 ]; then
	sqlout=$(cat ${TMPFILE}.sqlfunc)
    fi
    if [ -n "${DEBUG}" ]; then
	echo -e \*\*\* sqlplus output is :
	cat ${TMPFILE}.sqlfunc
	echo -e \*\*\* end sqlplus output
    fi
    return $RC
}
printList () {
    while [ $# -gt 1 ]; do
	echo -e -n "\t\t\t"$1
	if [ $# -gt 2 ]; then
	    echo ","
	fi
    shift;shift
    done
}
printQualifiedList () {
    qual=$1
    shift
    while [ $# -gt 1 ]; do
	echo -e -n "\t\t\t"$qual"."$1
	if [ $# -gt 2 ]; then
	    echo ","
	fi
    shift;shift
    done
}
printArgList () {
    while [ $# -gt 1 ]; do
	echo -e -n "\t"$1"\t"${objectName}"."$1"%type"
	if [ $# -gt 2 ]; then
	    echo ","
	fi
    shift;shift
    done
}
printQualifiedListUpdateFmt () {
    qual=$1
    shift
    while [ $# -gt 1 ]; do
	echo -e -n "\t"$1" = "$qual"."$1
	if [ $# -gt 2 ]; then
	    echo ","
	fi
    shift;shift
    done
}
PREFIX=${PREFIX:-MD_}

while getopts cdpm c
   do case $c in
    c) isComponent=true
       shift;;
    d) DEBUG=true
       shift;;
    p) PROTO=true
       shift;;
    m) MAILINGTABLE=true
	shift;;
    :) printmsg $OPTARG requires a value
       usage;;
    \?) printmsg unknown option $OPTARG
       usage;;
   esac
done
if [ $# -ne 1 ]; then
    usage
else
    printmsg Generating PL/SQL package for $1
fi
    
#--*-sh-*-
objectName=$(echo $1 | perl -e 'print lc(<STDIN>)')
objectNameUpper=$(echo $objectName | perl -e 'print uc(<STDIN>)')
objectNameVar=${upperCaseName}_NAME
code="
set pages 0
set lines 150
select
  lower(A.column_name), lower(B.table_name), lower(B.column_name)
from
    (select
       table_name,
       column_name,
       constraint_name
     from
       user_cons_columns) B,
    (select
      user_constraints.constraint_name, 
      user_constraints.r_constraint_name,
      user_cons_columns.column_name
    from
      user_constraints, user_cons_columns
    where
      user_constraints.table_name = '${objectNameUpper}'
    and
      constraint_type = 'R'
    and
      user_constraints.constraint_name = user_cons_columns.constraint_name) A
where
  A.r_constraint_name = B.constraint_name
/
"
sqlfunc 
parentTableKeys=${sqlout}
echo "Parent Table Keys are:"
echo $parentTableKeys
code="
set lines 150
set pages 0
select
  lower(column_name), lower(data_type)
from
  user_tab_columns
where
  table_name = '${objectNameUpper}'
and
  column_name
in (
  select
    column_name
  from
    user_cons_columns
  where 
    constraint_name IN
  (
      select
        constraint_name
      from
        user_constraints
      where
        constraint_type = 'P'
      and
        table_name = '${objectNameUpper}'
  )
)
/
"
sqlfunc 
echo
echo "Primary Key Columns are:"
echo $sqlout
primaryKeyColumns=${sqlout}
primaryKeyName=$(echo ${primaryKeyColumns} | awk '{print $1}')
upperPrimaryKeyName=$(echo ${primaryKeyName} | perl -e 'print uc(<STDIN>)')
code="
set lines 150
set pages 0
select
  lower(column_name), lower(data_type)
from
  user_tab_columns
where
  table_name = '${objectNameUpper}'
and
  column_name
in (
  select
    column_name
  from
    user_cons_columns
  where 
    constraint_name IN
  (
      select
        constraint_name
      from
        user_constraints
      where
        constraint_type = 'U'
      and
        table_name = '${objectNameUpper}'
  )
)
/
"
sqlfunc
alternateKeyColumns=${sqlout}
echo
echo "Alternate Key Columns are:"
echo $sqlout
if [ -n "${alternateKeyColumns}" ]; then
    set ${alternateKeyColumns}
    alternateKeyName=$1
fi
code="
set lines 150
set pages 0
select
  lower(column_name), lower(data_type)
from
  user_tab_columns
where
  table_name = '${objectNameUpper}'
and
  column_name
in (
  select
    column_name
  from
    user_cons_columns
  where 
    constraint_name IN
  (
      select
        constraint_name
      from
        user_constraints
      where
        constraint_type = 'R'
      and
        table_name = '${objectNameUpper}'
  )
)
/
"
sqlfunc
foreignKeyColumns=${sqlout}
echo
echo "Foreign Key Columns are:"
echo $sqlout
code="
set lines 150
set pages 0
select
  lower(column_name), lower(data_type)
from
  user_tab_columns
where
  table_name = '${objectNameUpper}'
and
  upper(column_name) not in ( 'IS_DELETED', 'UPDATED_DT', 'INSERTED_DT')
and
  column_name
not in (
  select
    column_name
  from
    user_cons_columns
  where 
    constraint_name IN
  (
      select
        constraint_name
      from
        user_constraints
      where
        table_name = '${objectNameUpper}'
      and
        constraint_type <> 'C'
  )
)
/
"
sqlfunc 
nonKeyColumns=${sqlout}
echo
echo "Non Key Columns are:"
echo $sqlout
code="
set pages 0
DECLARE	
   table_not_found exception;
   PRAGMA EXCEPTION_INIT(table_not_found, -942);
BEGIN
   execute immediate 'drop table tmp_user_constraints ';
EXCEPTION
   WHEN table_not_found THEN
     NULL;
END;
/
create table tmp_user_constraints as 
  select
    constraint_name
  from
    user_constraints
  where
    r_constraint_name = '${objectNameUpper}_PK';
select 
  lower(table_name),
  lower(column_name)
from
  user_cons_columns
where constraint_name IN
(
  select
    constraint_name
  from
    tmp_user_constraints
);
DECLARE	
   table_not_found exception;
   PRAGMA EXCEPTION_INIT(table_not_found, -942);
BEGIN
   execute immediate 'drop table tmp_user_constraints ';
EXCEPTION
   WHEN table_not_found THEN
     NULL;
END;
/
"
sqlfunc 
childTableColumns=${sqlout}
echo
echo "Child table Columns are:"
echo $sqlout
code="
set lines 150
set pages 0
select
  lower(column_name), lower(data_type)
from
  user_tab_columns
where
  table_name = '${objectNameUpper}'
and
  column_name
in (
  select
    column_name
  from
    user_cons_columns
  where 
    constraint_name IN
  (
      select
        constraint_name
      from
        user_constraints
      where
        constraint_type = 'R'
      and
        table_name = '${objectNameUpper}'
  )
) and column_name NOT in (
  select
    column_name
  from
    user_cons_columns
  where 
    constraint_name IN
  (
      select
        constraint_name
      from
        user_constraints
      where
        constraint_type = 'U'
      and
        table_name = '${objectNameUpper}'
  )
)
/
"
sqlfunc 
foreignKeyNotAlternateColumns=${sqlout}
echo
echo "Foreign Key columns that are not part of an alternate key are:"
echo $sqlout
code="
set lines 150
set pages 0
select
  user_cons_columns.constraint_name
from
  user_cons_columns,
  user_constraints
where
  user_constraints.constraint_name = user_cons_columns.constraint_name
and
  user_cons_columns.table_name = '${objectNameUpper}'
and
  user_cons_columns.column_name = '${objectNameUpper}_NAME'
and
  user_constraints.constraint_type  = 'U'
/
"
sqlfunc 
UniqueKeyConstraints=${sqlout}
echo
if [ -n "${UniqueKeyConstraints}" ]; then
  echo "Unique Key constraint on ${objectNameUpper}_NAME:"
  echo $sqlout
fi
##########  #######  ####   #####  #  #
#         # #       #         #    ## #
##########  #######
#         # #
##########  #######
mkdir -p auto
exec > ${PREFIX}${objectNameUpper}_pkg_head.proto
cat <<EOF
-- -*-sql-*- --
-----------------------------------------------------------------
-- Package:		${PREFIX}${objectNameUpper}
--
-- Date:		
--
-- Description:		
--
-----------------------------------------------------------------
--
PROMPT Creating PACKAGE ${PREFIX}${objectNameUpper}.
CREATE OR REPLACE PACKAGE ${PREFIX}${objectNameUpper} AUTHID CURRENT_USER AS
  package_name CONSTANT VARCHAR(32) := '${PREFIX}${objectNameUpper}';
EOF
exec > ${PREFIX}${objectNameUpper}_pkg_func.proto
echo
echo -e "PROCEDURE      NEW_${objectNameUpper} \n("
printArgList ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
echo -e "\n);"
echo
echo -e "PROCEDURE      PNEW_${objectNameUpper} \n("
printArgList ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
echo -e -n ",\n  "
set ${primaryKeyColumns}
echo -e "  "$1"	OUT "${objectName}"."$1"%TYPE\n);"
echo
echo -e "FUNCTION	      FNEW_${objectNameUpper}\n("
printArgList ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
echo -e "\n) RETURN "${objectName}"."${objectName}_id"%type;"
echo
echo
echo -e "FUNCTION	      F_${objectNameUpper}_ID\n("
if [ -n "${alternateKeyColumns}" ]; then
    printArgList ${alternateKeyColumns}
else
    printArgList ${foreignKeyColumns} ${nonKeyColumns}
fi
echo -e "\n) RETURN "${objectName}"."${objectName}_id"%type;"
echo
echo -e "PROCEDURE      PF_${objectNameUpper}_ID\n("
if [ -n "${alternateKeyColumns}" ]; then
    printArgList ${alternateKeyColumns}
else
    printArgList ${foreignKeyColumns} ${nonKeyColumns}
fi
echo -e ",\n    "$1"  OUT   "${objectName}"."${objectName}_id"%type\n);"
if [ -n "${MAILINGTABLE}" ]; then
echo
echo -e "PROCEDURE    UPDATE_${objectNameUpper}\n("
printArgList ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
echo -e "\n);"
fi
cat <<EOF
----------------------------------------
-- 
-- REF Cursor for fetching a ${objectName} object.
--
----------------------------------------
TYPE ${objectName}_cur is REF CURSOR RETURN ${objectName}%ROWTYPE;
PROCEDURE F_${objectNameUpper}_REC
(
  ${primaryKeyName}		${objectName}.${primaryKeyName}%TYPE,
  cur			IN OUT	${objectName}_cur
);
PROCEDURE F_${objectNameUpper}
(
  ${primaryKeyName}		${objectName}.${primaryKeyName}%TYPE,
  cur			IN OUT	${objectName}_cur
);
EOF
exec > ${PREFIX}${objectNameUpper}_pkg_foot.proto
echo
echo "END;"
exec > ${PREFIX}${objectNameUpper}_pkb_head.proto
cat <<EOF
-- -*-sql-*- --
-----------------------------------------------------------------
-- Package:		${PREFIX}${objectNameUpper}
--
-- Date:		
--
-- Description:		
--
-----------------------------------------------------------------
--
PROMPT Creating PACKAGE BODY ${PREFIX}${objectNameUpper}.
CREATE OR REPLACE PACKAGE BODY ${PREFIX}${objectNameUpper} AS
  c_${objectName}_id	${objectName}.${objectName}_id%type := NULL;
EOF
  
if [ -n "${alternateKeyColumns}" ]; then
    set ${alternateKeyColumns}
else
    set ${foreignKeyColumns} ${nonKeyColumns}
fi
while [ $# -gt 1 ]; do
    echo -e "  c_"$1"\t"${objectName}"."$1"%TYPE := NULL;"
    shift;shift
done
cat <<EOF
CURSOR c1 (package_id ${objectName}.${primaryKeyName}%type) is
  select * from ${objectName} where ${primaryKeyName} = package_id;
package_data c1%ROWTYPE;
EOF
exec > ${PREFIX}${objectNameUpper}_pkb_func.proto
cat <<EOF
--------------------------------
-- END LOCAL VARIABLE SECTION --
--------------------------------
--
-----------------------------------------------------------------
-- Procedure:		check_package_data
--
-- Date:		05.31.1999
--
-- Description:		checks the local data to insure that we are prepared
--                      for normal processing.  Basically I check to see
--                      whether package cursors are open.  If so ... they
--                      are closed
--
-- $Id: buildMAPI.sh.m4,v 1.3 2004/04/09 20:30:13 bretweinraub Exp $
-----------------------------------------------------------------
--
PROCEDURE check_package_data AS
BEGIN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
END check_package_data;
--
-----------------------------------------------------------------
-- Procedure:		package_init
--
-- Date:		05.31.1999
--
-- Description:		initializes a cursor for work with the table
--
-----------------------------------------------------------------
--
PROCEDURE package_init (package_id IN NUMBER) AS
BEGIN
  check_package_data;
  OPEN c1 (package_id);
  FETCH c1 INTO package_data;
  IF c1%ROWCOUNT > 1
  THEN 
    raise_application_error (-20999 , 'mutliple rows found', TRUE);
  ELSIF c1%ROWCOUNT < 1 THEN
    raise_application_error (-20997 , 
			     'no ${objectName} record with the sid ' || package_id || ' found', TRUE);
  END IF;
END package_init;
EOF
echo
echo -e "PROCEDURE      NEW_${objectNameUpper} \n("
printArgList ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
cat <<EOF
)
IS
BEGIN
        IF ${PREFIX}CONTROL.debugging = TRUE
	THEN
	    DBMS_OUTPUT.PUT_LINE ('entered NEW_${objectNameUpper}');
	END IF;
	INSERT 
	    INTO
	${objectName} (
EOF
        printList ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
cat <<EOF
	) VALUES (
EOF
	printQualifiedList new_${objectName} ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
cat<<EOF
	);
EOF
    if [ -n "${alternateKeyColumns}" ]; then
	echo "	${PREFIX}CONTROL.DO_COMMIT ('${objectName} ' || ${alternateKeyName} );"
    else
	echo "	${PREFIX}CONTROL.DO_COMMIT ('${objectName}');"
    fi
cat <<EOF
END;
--
------------------------------------------------------------------------------
--
-- Procedure:	
--
-- Description:	
--
-- History:	
--
------------------------------------------------------------------------------
--
PROCEDURE PNEW_${objectNameUpper} (
EOF
printArgList ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
echo -e -n ",\n  "
set ${primaryKeyColumns}
echo -e "  "$1"	OUT "${objectName}"."$1"%TYPE\n)"
cat <<EOF
IS
BEGIN
    NEW_${objectNameUpper} (
EOF
    printList ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
cat <<EOF
    );
EOF
if [ -z "${UniqueKeyConstraints}" ]; then
  echo -e "\tselect ${objectNameUpper}_S.CURRVAL into ${primaryKeyName} from dual;"
else
  echo -e "\t${primaryKeyName} := F_${upperPrimaryKeyName} ("
  if [ -n "${alternateKeyColumns}" ]; then
      printList ${alternateKeyColumns}
  else
      printList ${foreignKeyColumns} ${nonKeyColumns}
  fi
  echo "    );"
fi
cat <<EOF
END;
--
------------------------------------------------------------------------------
--
-- Procedure:	
--
-- Description:	
--
-- History:	
--
------------------------------------------------------------------------------
--
FUNCTION F_${objectNameUpper}_ID 
(
EOF
    if [ -n "${alternateKeyColumns}" ]; then
	printArgList ${alternateKeyColumns}
    else
	printArgList ${foreignKeyColumns} ${nonKeyColumns}
    fi
cat <<EOF
) RETURN ${objectName}.${primaryKeyName}%type
IS
    procedure_name        varchar2(32) := 'F_${objectNameUpper}_ID';
    localArgs                  varchar2(256);
BEGIN
  IF ${PREFIX}CONTROL.CACHING = TRUE AND c_${primaryKeyName} IS NOT NULL AND
EOF
if [ -n "${alternateKeyColumns}" ]; then
    set ${alternateKeyColumns}
else
    set ${foreignKeyColumns} ${nonKeyColumns}
fi
while [ $# -gt 1 ]; do
    echo -n "    f_${objectName}_id."$1" = c_"$1
    if [ $# -gt 2 ]; then
	echo " AND "
    fi
    shift;shift
done
cat <<EOF
  THEN
    IF ${PREFIX}CONTROL.debugging = TRUE
    THEN
      DBMS_OUTPUT.PUT_LINE ('using c_ ${objectName} id of ' || 
			    c_${primaryKeyName});
    END IF;
    RETURN c_${primaryKeyName};
  END IF;
  localArgs := '(';
EOF
if [ -n "${alternateKeyColumns}" ]; then
    set ${alternateKeyColumns}
else
    set ${foreignKeyColumns} ${nonKeyColumns}
fi
while [ $# -gt 1 ]; do
    echo "  localArgs   := localArgs || $1;"
    if [ $# -gt 2 ]; then
      echo "  localArgs   := localArgs || ', ';"	
    fi
    shift;shift
done
cat <<EOF
  BEGIN
    select ${primaryKeyName} 
    INTO   c_${primaryKeyName}
    from   ${objectName}
    where
EOF
if [ -n "${alternateKeyColumns}" ]; then
    set ${alternateKeyColumns}
    while [ $# -gt 1 ]; do
	echo -n "      "$1" = f_${primaryKeyName}."$1
	if [ $# -gt 2 ]; then
	    echo -e "\n  AND"
	fi
	shift;shift
    done
else
    set ${foreignKeyColumns} ${nonKeyColumns}
    while [ $# -gt 1 ]; do
    	datatype=$(echo $2 | perl -e 'print uc(<STDIN>)')
	if [ "${datatype}" = "VARCHAR2" ]; then
	    echo -n "       NVL("$1", 'BLOODY NULL MATE') = NVL(f_${primaryKeyName}."$1", 'BLOODY NULL MATE')"
	elif [ "${datatype}" = "DATE" ]; then
	    echo -n "       NVL("$1", TO_DATE('01-Jan-1900', 'DD-Mon-YYYY')) = NVL(f_${primaryKeyName}."$1", TO_DATE('01-Jan-1900', 'DD-Mon-YYYY'))"
	elif [ "${datatype}" = "NUMBER" ]; then
	    echo -n "       NVL("$1", 0) = NVL(f_${primaryKeyName}."$1", 0)"
	else
	    echo -n "      "$1" = f_${primaryKeyName}."$1
	fi
	if [ $# -gt 2 ]; then
	    echo -e "\n  AND"
	fi
	shift;shift
    done
fi
echo ";"
echo
if [ -n "${alternateKeyColumns}" ]; then
    set ${alternateKeyColumns}
else
    set ${foreignKeyColumns} ${nonKeyColumns}
fi
while [ $# -gt 1 ]; do
    echo "  c_"$1" := f_${primaryKeyName}."$1";"
    shift;shift
done
cat<<EOF
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ${PREFIX}CONTROL.DEBUG(package_name || '.' || procedure_name || ': no data found when fetching ' || localArgs || ')');
	RAISE;
    END;
  RETURN c_${primaryKeyName};
END;
--
------------------------------------------------------------------------------
--
-- Procedure:	
--
-- Description:	
--
-- History:	
--
------------------------------------------------------------------------------
--
PROCEDURE PF_${upperPrimaryKeyName}
(	  
EOF
if [ -n "${alternateKeyColumns}" ]; then
    printArgList ${alternateKeyColumns}
else
    printArgList ${foreignKeyColumns} ${nonKeyColumns}
fi
    echo -e ",\n    "${primaryKeyName}"      OUT "${objectName}"."${primaryKeyName}"%type"
cat <<EOF
)
IS
BEGIN
    ${primaryKeyName} := F_${upperPrimaryKeyName} (
EOF
if [ -n "${alternateKeyColumns}" ]; then
    printList ${alternateKeyColumns}
else
    printList ${foreignKeyColumns} ${nonKeyColumns}
fi
cat <<EOF
    );
END;
--
------------------------------------------------------------------------------
--
-- Procedure:	
--
-- Description:	
--
-- History:	
--
------------------------------------------------------------------------------
--
FUNCTION FNEW_${objectNameUpper}
(
EOF
  printArgList ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
cat<<EOF
) RETURN ${objectName}.${primaryKeyName}%TYPE
IS
  ${primaryKeyName}                  ${objectName}.${primaryKeyName}%TYPE;
BEGIN
  PNEW_${objectNameUpper} (
EOF
  printList ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
  echo -e ",\n                        ${primaryKeyName}"
cat <<EOF
  );
 
  return ${primaryKeyName};
END;
----------------------------------------
-- 
-- REF Cursor for fetching a ${objectName} object.
--
----------------------------------------
PROCEDURE F_${objectNameUpper}_REC
(
  ${primaryKeyName}		${objectName}.${primaryKeyName}%TYPE,
  cur			IN OUT	${objectName}_cur
)
IS
  procedure_name        varchar2(32) := 'F_${objectNameUpper}_REC';
BEGIN
  OPEN cur FOR 
    SELECT 
      *
    from 
      ${objectName}
    where
      ${primaryKeyName} = f_${objectName}_rec.${primaryKeyName};
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ${PREFIX}CONTROL.DEBUG(package_name || '.' || procedure_name || ': no data found when fetching ${objectName}_REC for id ' || ${primaryKeyName});
      RAISE;
END;
PROCEDURE F_${objectNameUpper}
(
  ${primaryKeyName}		${objectName}.${primaryKeyName}%TYPE,
  cur			IN OUT	${objectName}_cur
)
IS
BEGIN
  ${PREFIX}${objectNameUpper}.F_${objectNameUpper}_REC (
     ${primaryKeyName}  =>  ${primaryKeyName},
     cur                =>  cur
  );
END;
EOF
if [ -n "${MAILINGTABLE}" ]; then
cat <<EOF
--
------------------------------------------------------------------------------
--
-- Procedure:	
--
-- Description:	
--
-- History:	
--
------------------------------------------------------------------------------
--
PROCEDURE UPDATE_${objectNameUpper}
(
EOF
printArgList ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
cat <<EOF
)
IS
BEGIN
  UPDATE
    ${objectNameUpper}
  SET
EOF
printQualifiedListUpdateFmt update_${objectName} ${alternateKeyColumns} ${foreignKeyNotAlternateColumns} ${nonKeyColumns}
cat <<EOF
  
  WHERE
    ${objectName}_name = update_${objectName}.${objectName}_name;
  ${PREFIX}CONTROL.DO_COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ${PREFIX}CONTROL.DEBUG('UNABLE TO UPDATE ${objectName}:' || sqlerrm);
    RAISE;
END;
EOF
fi
 
exec > ${PREFIX}${objectNameUpper}_pkb_foot.proto
cat <<EOF
END;
EOF
rm -f ${TMPFILE}.*
if [ -z "${PROTO}" ]; then
    cat ${PREFIX}${objectNameUpper}_pkg_head.proto > ${PREFIX}${objectNameUpper}.pkg
    cat ${PREFIX}${objectNameUpper}_pkg_func.proto >> ${PREFIX}${objectNameUpper}.pkg
    cat ${PREFIX}${objectNameUpper}_pkg_foot.proto >> ${PREFIX}${objectNameUpper}.pkg
    cat ${PREFIX}${objectNameUpper}_pkb_head.proto > ${PREFIX}${objectNameUpper}.pkb
    cat ${PREFIX}${objectNameUpper}_pkb_func.proto >> ${PREFIX}${objectNameUpper}.pkb
    cat ${PREFIX}${objectNameUpper}_pkb_foot.proto >> ${PREFIX}${objectNameUpper}.pkb
    rm -f *.proto
fi
