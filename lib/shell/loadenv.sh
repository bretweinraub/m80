#
#
# functions for validating the m80 environment.
#
#

requireSet () { 
    test $# -ne 1 && {
	return 
    }
    derived=$(eval "echo \$"$1) ; 
    test -z "$derived" && {
         echo variable \$${1} was not found in the build environment
         eval `varWarrior ${1}` 
         eval export ${1}=$(eval "echo \$"$1) 
    }
}  

validate () {
    for var in $* ; do 
        requireSet $var 
    done 
}

loadenv () {
    if [ $# -eq 0 ]; then
        validation_vars=${M80_REQUIRED_VARIABLES}
    else
        validation_vars=$*
    fi
    require M80_REPOSITORY
    test -z "$M80_ENV" && require M80_BDF

    (cd ${M80_REPOSITORY}; make all 1> /dev/null)
    test -f ${M80_REPOSITORY}/module.mk && {
	. ${M80_REPOSITORY}/module.mk
    }
    if [ "${M80_REPOSITORY_TYPE}" != "xml" -a -n "${M80_BDF}" ]; then

        # load algorithm for the bdfs. This is repeated for the environments
        # and the projects.
        # priority is: .sh and then .env and then nothing.
        test -f ${M80_REPOSITORY}/bdfs/${M80_BDF}.sh && . ${M80_REPOSITORY}/bdfs/${M80_BDF}.sh
        test -f ${M80_REPOSITORY}/bdfs/${M80_BDF}.env && . ${M80_REPOSITORY}/bdfs/${M80_BDF}.env
        test -f ${M80_REPOSITORY}/bdfs/${M80_BDF} && . ${M80_REPOSITORY}/bdfs/${M80_BDF}

        if [ -n "${ENV}" ]; then

            test -f ${M80_REPOSITORY}/environments/${ENV}.sh && . ${M80_REPOSITORY}/environments/${ENV}.sh
            test -f ${M80_REPOSITORY}/environments/${ENV}.env && . ${M80_REPOSITORY}/environments/${ENV}.env
            test -f ${M80_REPOSITORY}/environments/${ENV} && . ${M80_REPOSITORY}/environments/${ENV}

        fi

        if [ -n "${PROJECT}" ]; then

            test -f ${M80_REPOSITORY}/projects/${PROJECT}.sh && . ${M80_REPOSITORY}/projects/${PROJECT}.sh
            test -f ${M80_REPOSITORY}/projects/${PROJECT}.env && . ${M80_REPOSITORY}/projects/${PROJECT}.env
            test -f ${M80_REPOSITORY}/projects/${PROJECT} && . ${M80_REPOSITORY}/projects/${PROJECT}

        fi

    # optionally - If you don't want to specify a 
    # BDF, then you can specify the environment and the project and
    # this will pick them up. It requires that your M80_BDF env var be
    # -z length.
    #
    elif [ -n "${M80_ENV}" ]; then
        
	test -f ${M80_REPOSITORY}/environments/${M80_ENV}.sh && . ${M80_REPOSITORY}/environments/${M80_ENV}.sh
	test -f ${M80_REPOSITORY}/environments/${M80_ENV}.env && . ${M80_REPOSITORY}/environments/${M80_ENV}.env
	test -f ${M80_REPOSITORY}/environments/${M80_ENV} && . ${M80_REPOSITORY}/environments/${M80_ENV}

        if [ -n "${M80_PROJECT}" ]; then

            test -f ${M80_REPOSITORY}/projects/${M80_PROJECT}.sh && . ${M80_REPOSITORY}/projects/${M80_PROJECT}.sh
            test -f ${M80_REPOSITORY}/projects/${M80_PROJECT}.env && . ${M80_REPOSITORY}/projects/${M80_PROJECT}.env
            test -f ${M80_REPOSITORY}/projects/${M80_PROJECT} && . ${M80_REPOSITORY}/projects/${M80_PROJECT}
            
        fi

    else
	eval $(exportXML.pl -export)
    fi
    export M80_LOADED=true
    validate $validation_vars
}
