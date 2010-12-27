m4_include(shell/shellScripts.m4)m4_dnl -*-sh-*-
m4_divert(-1)

#
# This is a library for defining naiveProcess LIKE applications.
# the concept being that naiveProcess is really just a thing that
# iterates over namespaces and shifts them around then execs a tool.
#
# This library allows you to abstract the namespace requirements.
#


#
# {{{ m4 macro: NAIVEPROCESS

#
# Name: NAIVEPROCESS
# Arguments: $1: ScriptName, $2: Type(Plural), $3: Type(singular)
# Description: 
#
m4_define([NAIVEPROCESS],[
shell_load_functions(printmsg,cleanup,require,docmd,docmdi,docmdqi,checkfile,loadenv)
shell_exit_handler
shell_getopt((t, -TARGETLIST), (b, -M80_BDF), (T, TOP), (m, $3_LIST), (-e, ECHO_ONLY),(-d, DEBUG), (-i, IGNORE_ERRORS), (a, ARGS))

export TOP=${TOP:-$(pwd)}
printmsg TOP is $TOP

requireSet () { 
    if test ${#} -ne 1; then  
	return 
    fi 
    derived=$(eval "echo \$"${1}) ; 
    if test -z "$derived"; then 
         printmsg variable \$${1} was not found in the build environment
         eval `varWarrior ${1}` 
         eval export ${1}=$(eval "echo \$"${1}) 
    fi 
}  

test -n "${DEBUG}" && {
    set -x
}

RC=0

loadenv $REQUIRED_VARIABLES

#
# Jim - why are you setting QUIET to true?
#
#export QUIET=true 

findPath() {
  set ${1} ${pathCheckList}
  while test ${#} -gt 0; do
    $3_BUILD_PATH=$(eval "echo \$"${$3}"_"${1}"_PATH")
    if test -z "${$3_BUILD_PATH}"; then
	printmsg "Didn't find value for "${$3}"_"${targetName}"_PATH".
      shift
    else
      return
    fi
  done
}

resolveVirtualTarget () {
    returnTarget=${2}
    resolvedTarget=$(eval "echo \$"${1}"_"${2}"_VIRTUAL")
    if test -n "${resolvedTarget}"; then
	returnTarget=${resolvedTarget}
    fi
    echo ${returnTarget}
}

#
# If "OBJECT_THIS" Is defined, than we want to convert the namespace of the object back to the real names.
#
# For example:
#
# 
# OBJECT_THIS = FOO
#
# Then for variable FOO_DATABASE_NAME,
#
# set ${DATABASE_NAME} = ${FOO_DATABASE_NAME};
#

for targetName in ${TARGETLIST} ; do 
    rc=0
    pathCheckList=${targetName}
    realTarget=${targetName}

    if test -n "${$3_LIST}"; then 
	m4_lcase($3)List=${$3_LIST} 
    else 
	m4_lcase($3)List=$(eval "echo \$"${targetName}"_$2") 
    fi 
    printmsg eligible m4_lcase($2) for $targetName are ${m4_lcase($3)List}. 
    if test -z "${m4_lcase($3)List}"; then 
	continue 
    fi 

    for $3 in ${m4_lcase($3)List} ; do 
	export $3
	printmsg $(date)" : "${targetName}" : "${$3} 
	if test -z "${$3}"; then        
	    break
	fi 
    
	thisTarget=$(resolveVirtualTarget $$3 ${realTarget})
	thisTool=$(eval "echo \$"${$3}"_"${thisTarget}"_TOOL")
    
    #    the m4_lcase($3) NAME is in hand.  Derive the path.
	findPath $thisTarget
	suppressAppendToolTargetName=$(eval "echo \$"${$3}"_"${thisTarget}"_SUPPRESS_TARGET_APPEND")
	printmsg running ${thisTool} ${realTarget} \(${thisTarget}\) for m4_lcase($3) $$3 in $$3_BUILD_PATH
	if test -n "${$3_BUILD_PATH}" -a -d "${$3_BUILD_PATH}" ; then 
	    if test -n "${DEBUG}"; then
	        if test -z "${suppressAppendToolTargetName}"; then
		    printmsg "(cd $$3_BUILD_PATH ; ${thisTool} ${thisTarget} )"
		else
		    printmsg "(cd $$3_BUILD_PATH ; ${thisTool} )"
		fi
	    else
		if test -z "${ECHO_ONLY}"; then 
		    _args=$(echo $ARGS)
		    export M80_THIS=$(eval "echo \$"${$3}"_THIS")
		    printmsg M80_THIS resolved to ${M80_THIS}
		    PATH=".:$PATH"
		    if test -z "${suppressAppendToolTargetName}"; then
			if test -n "${DEBUG}"; then
			    printmsg "(cd "$$3_BUILD_PATH" ; eval "$(m80this.pl) ${thisTool} ${thisTarget} ${_args}" )"
			fi
			(cd $$3_BUILD_PATH ; eval $(m80this.pl) ${thisTool} ${thisTarget} ${_args} )
		    else
			if test -n "${DEBUG}"; then
			    printmsg "(cd "$$3_BUILD_PATH" ; eval "$(m80this.pl) ${thisTool} ${_args}" )"
			fi
			(cd $$3_BUILD_PATH ; eval $(m80this.pl) ${thisTool} ${_args})
		    fi
		else
		    test 1 -eq 1
		fi
	    fi
	else 
	    cleanup 1 ERROR: ${$3} was skipped because no directory name \"${$3_BUILD_PATH}\" was found. 
	    exit 
	fi 
	if test $? -ne 0; then 
	    if test -z "${IGNORE_ERRORS}"; then
		cleanup 1 $thisTool $realTarget \(${thisTarget}\) failed for $$3 \(${$3_BUILD_PATH}\)
	    else 
		printmsg $thisTool $realTarget \(${thisTarget}\) failed for $$3 \(${$3_BUILD_PATH}\) ... ignoring
		((RC=$RC+1))
	    fi
	fi 
    done 
done

cleanup $RC

m4_changequote(<++,++>)
#
# =pod
#
# =head1 NAME
#
# $1 - a naiveProcess implementation on the $2 and $3 namespaces
# 
# =head1 SYNOPSIS
# 
# $1 [ -t <TARGETLIST> -b <M80_BDF> -t <TOP> -m <$3_LIST> -e -d -i -a <ARGS>]
# 
# =head1 OPTIONS AND ARGUMENTS
# 
# =over 4
# 
# =item t - $TARGETLIST
# 
# required. The list of targets that $1 should be executed against
# 
# =item b - $M80_BDF
# 
# optional M80_BDF. IF this is not provided, it is taked from the env var
# 
# =item T - $TOP
# 
# required TOP. It can be in the env or on the commandline, if not given it will be `pwd`
# 
# =item m - $3_LIST
# 
# optional $3_LIST. It can be in the env or on the commandline. Defaults to the value
# of the iterated $TARGETLIST + '_$2'.
# 
# =item e - $ECHO_ONLY
# 
# optional argument to echo commands and not execute them
# 
# =item d - $DEBUG
# 
# optional arguement to turn on debug information
# 
# =item i - $IGNORE_ERRORS
# 
# optional arguement to ignore errors. The default is to exit when an error occurs.
# The error code will be the error code of the evaluated _TOOL.
# 
# =item a - $ARGS
# 
# optional ARGS to be passed to the tool
# 
# =back
# 
# =head1 DESCRIPTION
# 
# The $1 tool is an implementation of the naiveProcess library. This library is about 
# taking a namespace defined in environment variable naming conventions and iterating
# through a list of elements (in this case $3_LIST), then shifting the namespace as
# appropriate and executing a tool in a directory against the new context (namespace).
# 
# The tool that is called will be listed in the $3_TOOL variable. 
# 
# The path that the tool should be execed in is in the $3_BUILD_PATH variable.
# 
# There is a variable that can be used to turn off the appending of the TARGET when
# running a tool: it is the NAMESPACE + '_SUPPRESS_TARGET_APPEND' and if it is non-zero
# length, then the target will not be prepended to the argument list for the tool.
# 
# A little historical information here... This tool grep up sitting on top of make or 
# ant (or any tool that walks a dependency graph). In these tools, the user needs to
# specify the entry point of the graph and that is called a target. As a result this
# library grew up with the idea that it needed to exec some dependency graph target
# for some node list. Over time, the dependency graph tool requirement came off of it, 
# and the ability to exec any application in a node list became a requirement. However,
# there is a difference between the call signatures - a standalone tool will likely not
# need the target variable. That is the point of the '_SUPPRESS_TARGET_APPEND' variable. 
# The tool requires a TARGET in order to run, but the code that is actually run is a 
# function of shifting namespace and examination of the '_TOOL' variable.
# 
# An example:
# 
#  A_MODULE_env_SUPPRESS_TARGET_APPEND=true
#  A_MODULE_env_TOOL=env
#  A_MODULE_env_PATH=/some/path
# 
# will result in (roughly) C<(cd /some/path; env)>
# 
# While:
# 
#  A_MODULE_env_SUPPRESS_TARGET_APPEND=
#  A_MODULE_env_TOOL=make
#  A_MODULE_env_PATH=/some/path
# 
# will result in (roughly) C<(cd /some/path; make TARGET)>
#  
# 
# =cut
# 
m4_changequote([,])
])

# }}} end NAIVEPROCESS

m4_divert[]
