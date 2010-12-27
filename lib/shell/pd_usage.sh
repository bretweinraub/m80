function pd_usage {
    export PD_FLAGS=-T
    export PD_DIRS=`dirname $0`
    pd `basename $0 .sh`
}
