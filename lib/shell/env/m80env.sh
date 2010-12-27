# -*-shell-script-*-

#
#
##

test -n "$DEBUG" && { set -x ; }

_m80_id=$(/usr/bin/whoami)

_m80_pid=$$

_m80_key=$_m80_id/$_m80_pid

_m80_env_dir=/tmp/.m80env/$_m80_key

_m80_lib_path=$(m80 --libpath)

_m80_dot_file_name=localenv

_m80_dotfile_make=${_m80_lib_path}/make/${_m80_dot_file_name}.mk

_m80_hostname=$(hostname | cut -d\. -f1)

_m80_domainname=$(domainname 2> /dev/null)

rm -rf ${_m80_env_dir}

mkdir -p ${_m80_env_dir}

_m80loadOrder () {
    echo $( /bin/ls -1f .${_m80_dot_file_name}.${PROJECT} \
                  .${_m80_dot_file_name}.${ENV} \
                  .${_m80_dot_file_name}.${M80_BDF} \
                  .${_m80_dot_file_name}.${_m80_hostname} \
                  .${_m80_dot_file_name}.${_m80_domainname} \
                  .${_m80_dot_file_name} \
                  .${_m80_dot_file_name}.? \
                  .${_m80_dot_file_name}.?? \
	          .${_m80_dot_file_name}.last 2> /dev/null)
}

_loadFile () {
    if [ $# -gt 0 ]; then
	set $*
    else
	return 1
    fi
    while [ $# -gt 0 ]; do
	if [ -f $1 ]; then
	    test -n "$DEBUG" && { echo loading $1 ; }
	    . $1
	fi
	shift
    done
}

loadfiles () {
    _m80_localLoadExists=$(set | perl -nle 'print $1 if /^(_m80localLoadOrder)\s+\(\)/;')
    if [ -n "${_m80_localLoadExists}" ]; then
	loadOrder=$(_m80localLoadOrder)
    else
	loadOrder=$(_m80loadOrder)
    fi
    _loadFile $loadOrder

}

SET () {
    set | perl -nle 'unless (/BASH_VERSINFO/ || /EUID/ || /PPID/ || /SHELLOPTS/ || /UID/) {print;}'
}

cdinto () { 
    test -n "$DEBUG" && { echo cdinto $1 ; }
    command cd $*; 
    SET > ${_m80_env_dir}/${PWD//\//.}.pre
    if [ -f .${_m80_dot_file_name}.enablemake -a -f ${_m80_dotfile_make} ]; then
	make -f ${_m80_dotfile_make}
    fi
    loadfiles
    SET > ${_m80_env_dir}/${PWD//\//.}.post
    $(m80 --binpath)/genPopFile.pl ${_m80_env_dir}/${PWD//\//.}.pre ${_m80_env_dir}/${PWD//\//.}.post > ${_m80_env_dir}/${PWD//\//.}.pop
}

cdoutof () {
    _loadFile ${_m80_env_dir}/${PWD//\//.}.pop ${_m80_env_dir}/${PWD//\//.}.pre
    test -n "$DEBUG" && { echo cdoutof $1 ; }
    command cd $*; 
    loadfiles
}

cd () {
    if [ $# -eq 0 ]; then
	cdinto ~
    fi
    args=$*
    if [ "$args" = "${args#/}" ]; then
	for dir in $(echo $* | perl -nle 's/^(\/{0,1})*\//$1 /g; print'); do
	    if [ $dir = ".." ]; then
		cdoutof $dir
	    else
		cdinto $dir
	    fi
	done
    else
	command cd $*; 
    fi
}

test -n "$DEBUG" && { set +x ; }
