m4_include(shell/shellScripts.m4)m4_dnl
shell_load_functions(printmsg,cleanup,require,docmd,docmdi,docmdqi,checkfile)
shell_exit_handler
shell_getopt((t, -TARGET), (-l, LOADM80_BDF), (b, -M80_BDF), (T, -TOP))

m4_changequote(<++,>++)m4_dnl

requireSet () { 
    if [ $# -ne 1 ]; then  
	return 
    fi 
    derived=$(eval "echo \$"$1) ; 
    if [ -z "$derived" ]; then 
         echo variable \$${1} was not found in the build environment
         eval `varWarrior ${1}` 
         eval export ${1}=$(eval "echo \$"$1) 
    fi 
}  

test -n "${DEBUG}" && {
    set -x
}

if [ "${LOADM80_BDF}" = "TRUE" ]; then
    require M80_REPOSITORY
    require M80_BDF
    (cd ${M80_REPOSITORY}; make)
    . ${M80_REPOSITORY}/bdfs/${M80_BDF}.sh
    test -n "${ENV}" && {
	. ${M80_REPOSITORY}/environments/${ENV}.sh
    }
    test -n "${PROJECT}" && { 
	. ${M80_REPOSITORY}/projects/${PROJECT}.sh
    }
fi

for var in $REQUIRED_VARIABLES ; do 
        requireSet $var 
done 

targetName=${TARGET} 
x=0
testTargetName=${targetName}

pathCheckList=${targetName}
while [ -z "$stopLooping" ]; do
  virtualTarget=$(eval "echo \$"${testTargetName}"_VIRTUAL") 
  if [ -n "${virtualTarget}" ]; then 
      realTarget=${virtualTarget} 
      pathCheckList=${pathCheckList}" "${realTarget}
  else 
      realTarget=${testTargetName} 
  fi 
  if [ "${realTarget}" = "${testTargetName}" ]; then
    stopLooping=true
  else
    testTargetName=${realTarget}
  fi
  ((x=$x+1))
  if [ $x -gt 100 ]; then
    cleanup virtual targets nested to deep\; probably a logic error
  fi
done

findPath() {
  set ${pathCheckList}
  while [ $# -gt 0 ]; do
    MODULE_BUILD_PATH=$(eval "echo \$"${MODULE}"_"$1"_PATH")
    if [ -z "${MODULE_BUILD_PATH}" ]; then
      echo "Didn't find value for "${MODULE}"_"${targetName}"_PATH".
      shift
    else
      return
    fi
  done
}

if [ -n "${BUILD_INSTANCE_LIST}" ]; then 
  buildInstanceList=${BUILD_INSTANCE_LIST} 
else  
  buildInstanceList=${BUILD_INSTANCES} 
fi 

for buildInstance in ${buildInstanceList} ; do 
  echo $$" : "$(date)" : "${buildInstance}" : "${buildUser}" : "${MODULE} 
  export DATABASE_INSTANCE=${buildInstance} 
  if [ -n "${BUILD_USER_LIST}" ]; then 
    buildUserList=${BUILD_USER_LIST} 
  else  
    buildUserList=$(eval echo \$${buildInstance}_BUILD_USERS) 
  fi 
  for buildUser in ${buildUserList} ; do 
    echo $$" : "$(date)" : "${buildInstance}" : "${buildUser}" : "${MODULE} 
    export DATABASE_USER=$buildUser 
    echo making ${realTarget} for $buildUser 
    if [ -n "${MODULE_LIST}" ]; then 
      moduleList=${MODULE_LIST} 
    else 
      moduleList=$(eval "echo \$"${buildUser}"_"${targetName}"_MODULES") 
    fi 
    echo eligible modules for $buildUser are ${moduleList}. 
    if [ -z "${moduleList}" ]; then 
      continue 
    fi 
    for MODULE in ${moduleList} ; do 
      export MODULE
      echo $$" : "$(date)" : "${buildInstance}" : "${buildUser}" : "${MODULE} 
      if [ -z "${MODULE}" ]; then        
          break
      fi 
      echo making ${realTarget} for $buildUser module $MODULE 
      if [ ${targetName} = "REPLICATION" ]; then 
        export CONNECTSTRING=${REPLICATION_ADMIN}@$(eval "echo \$"${buildUser}"_TNS") 
      else 
        export CONNECTSTRING=$(eval "echo \$"${buildUser}"_CONNECTSTRING") 
      fi 
#     the module NAME is in hand.  Derive the path.
#
      findPath
      if [ -n "${MODULE_BUILD_PATH}" -a -d $MODULE_BUILD_PATH ]; then 
          if [ -n "${DEBUG}" ]; then
	    echo "(cd $MODULE_BUILD_PATH ; make ${realTarget} )"
	  else
	    (cd $MODULE_BUILD_PATH ; make ${realTarget} )
          fi
      else 
         echo ERROR: ${MODULE} was skipped because no directory name \"${MODULE_BUILD_PATH}\" was found. 
         exit 
      fi 
      if [ $? -ne 0 ]; then 
           echo ${realTarget} failed for $buildUser"."$MODULE \(${MODULE_BUILD_PATH}\)
          exit 1 
      fi 
    done 
  done 
done

#
# Local Variables:
# mode: shell-script
# End:
# 

