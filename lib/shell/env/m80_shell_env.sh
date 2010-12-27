
push=`which push.pl`;
addappend=`which addappendenv.pl`;
test -n "$push" && echo "Found PUSH: $push";
test -n "$addappend" && echo "Found ADDAPPEND: $addappend";

cd () {
    if [ -n "$push" ]; then
	test -f .pop.env && source .pop.env; rm -f .pop.env;
	command cd $*;
	if [ -f .localenv.plx ]; then
	    make .localenv;
	fi;
	if [ -f .localenv ]; then
	    $push .localenv;
	    if [ -f .push.env ]; then
		source .push.env; rm -f .push.env;
	    else
		source .localenv;
	    fi
	    cat .localenv;
	fi;
    else
	command cd $*;
	if [ -f .localenv ]; then
	    source .localenv;
	    cat .localenv;
	fi;
    fi;
    if [ -z "$addappend" ]; then
	export CDPATH=$(echo $CDPATH:$PWD|perl -nle '@x=split /:/;print join ":",sort @x')
    else
	`$addappend CDPATH "$PWD"`;
    fi;
}

