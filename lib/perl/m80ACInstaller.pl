#-*-perl-*-
# M80_VARIABLE M80_LIB





=pod

=head1 NAME

m80ACInstaller.pl - embedperl library for converting Perl AC structs to shell export statments

=head1 DESCRIPTION

Include this in your m80 file like so:

 # $m80path = [{ command => 'embedperl.pl -l m80ACInstaller' }]

and then you can add nodes with the perl named functions.

I am slowly coming to a CLOS-like object structure where global function manipulate 
a global (or otherwise) namespace. Access to the objects/globals is always provided
through functions (for interface adherence and 1 additional layer).

=cut

%named_roles = ();
%named_nodes = ();

sub add2role {
    my %data = @_;
    my $o = '';

    # ASSERT - requires a role and a name
    die 'add2role requires "name" and "role" hash elements' unless $data{'name'} && $data{'role'};

    $o .= "export ROLES=\"\${ROLES} $data{role}\"\n" unless ( $roles{ $data{ 'role' } } ); # dedupe roles in memory
    $o .= "export NODES=\"\${NODES} $data{name}\"\n" unless ( $roles{ $data{ 'name' } } ); # dedupe node names in memory

    
    for my $tmp ( @{ $data{ 'nodes' } } ) {
        $o .= "export $data{name}_NODES=\"\${$data{name}_NODES} $tmp\"\n";
    }

    
    for my $tmp ( @{ $data{ 'data_include' } } ) {
        $o .= "export $data{name}_DATA_INCLUDE=\"\${$data{name}_DATA_INCLUDE} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'bin_include' } } ) {
        $o .= "export $data{name}_BIN_INCLUDE=\"\${$data{name}_BIN_INCLUDE} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'lib_include' } } ) {
        $o .= "export $data{name}_LIB_INCLUDE=\"\${$data{name}_LIB_INCLUDE} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'extra_include' } } ) {
        $o .= "export $data{name}_EXTRA_INCLUDE=\"\${$data{name}_EXTRA_INCLUDE} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'subdir_include' } } ) {
        $o .= "export $data{name}_SUBDIR_INCLUDE=\"\${$data{name}_SUBDIR_INCLUDE} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'data_exclude' } } ) {
        $o .= "export $data{name}_DATA_EXCLUDE=\"\${$data{name}_DATA_EXCLUDE} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'bin_exclude' } } ) {
        $o .= "export $data{name}_BIN_EXCLUDE=\"\${$data{name}_BIN_EXCLUDE} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'lib_exclude' } } ) {
        $o .= "export $data{name}_LIB_EXCLUDE=\"\${$data{name}_LIB_EXCLUDE} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'extra_exclude' } } ) {
        $o .= "export $data{name}_EXTRA_EXCLUDE=\"\${$data{name}_EXTRA_EXCLUDE} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'subdir_exclude' } } ) {
        $o .= "export $data{name}_SUBDIR_EXCLUDE=\"\${$data{name}_SUBDIR_EXCLUDE} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'install-data-local' } } ) {
        $o .= "export $data{name}_INSTALL_DATA_LOCAL=\"\${$data{name}_INSTALL_DATA_LOCAL} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'install-exec-local' } } ) {
        $o .= "export $data{name}_INSTALL_EXEC_LOCAL=\"\${$data{name}_INSTALL_EXEC_LOCAL} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'install-data-hook' } } ) {
        $o .= "export $data{name}_INSTALL_DATA_HOOK=\"\${$data{name}_INSTALL_DATA_HOOK} $tmp\"\n";
    }

    for my $tmp ( @{ $data{ 'install-exec-hook' } } ) {
        $o .= "export $data{name}_INSTALL_EXEC_HOOK=\"\${$data{name}_INSTALL_EXEC_HOOK} $tmp\"\n";
    }


    return $o;
}


=pod

=head1 THE LIBRARY/TOOL THINGY

find a new name for this! - the concept is that this can be put together
with a generalized perl processor to do work. 

build implements the perl_recurse_function.pl interface to create the 
necessary autoconf files in each node. These autoconf files can be used
to quickly create a boiler plate distribution, or they can be tied into
metadata about your distribution to expand into something that is a little
more customized.

It finishes up by running aclocal; autoconf; automake -ac.

metadata might look like this:

 
  %x_data = ( 
            PACKAGE_INFO => {
                PACKAGE_VERSION => '00.01',
                PACKAGE_NAME => 'perf_framework',
                PACKAGE_PREFIX => '/performance',
                EXTERNAL_SCRIPTS_DIR => 'installer/framework_installer'
            },
            RELATIONSHIPS => {
                ADMINSERVER =>  'REPO', 'BDFS' ,

            },

            GLOBAL => {
                bin_scripts_include =>  'm,\.m80$,', 'm,\.m4$,', 's,\.ac_bundler,.', 'm/./' ,
                extra_dist_include =>  'm,\.m80$,', 'm,\.m4$,', 's,\.ac_bundler,.', 'm/./' ,
                x_include_files_include =>  '$(top_srcdir)/autofiles/someglobaltestinclude.mk' ,
            },


            #
            REPO => {
                PATH =>  'm80repository' ,
            },
            
            BDFS => {
                PATH =>  'm80repository/bdfs' ,
                x_include_files_include =>  '$(top_srcdir)/autofiles/sometest.mk' ,
                x_include_files_exclude =>  '/someglobaltestinclude.mk/' ,
            }

          );




   sub my_data { return %x_data };
   1;

Where PACKAGE_INFO, RELATIONSHIPS and GLOBAL are all "special namespaces" - that is, they 
are hardcoded into this library. Anything else is a "MODULE". RELATIONSHIPS is a container
for modules. It is used to derive Makefile.am Conditionals which are enabled through configure
variables like --enable-adminserver. GLOBAL are rules that will be evaluated on each node
of the recursion. The script will derive the MODULE based on the node that it is in by looking
at the MODULE PATH. The MODULE with the deepedst matching path will override the GLOBAL values
if it so chooses. 

The rules are made up of 2 flavors: rules that affect files, and passthrough rules. Any rule
that matches /_(exclude|include)$/ but not /^x_/ affects files, those that match both expressions
affect the data that is passed to the Makefile.am and configure.in templates directly. Include 
rules will prefer to include data in the pass to the templates. Exclude will prefer to remove
data. If there is matching include and exclude rules for a file or data, the exclude is taken.

I added callbacks to build. If you want to specify some, add a pointer to your function 
in the @pre_build_callbacks or the @post_build_callbacks. The functions will be exec'ed in 
order passing in the arguments that were passed into build. Callbacks have access to the
global namespace, including the %D (metadata) which is guaranteed to be configured before
passing to callbacks.

=cut 

use File::Copy;
use Storable qw(dclone);

$version_number = '0.07.33';
@Makefiles = ();
$do_recursive_kill_ac_files = 0;
$existing_Makefiles = 0;
$manifest_file_name = '.acmanifest';
%D = ();


# this struct has the mapping of roles, module, paths, include_patterns, exclude_patterns
%named_nodes = ();
%named_roles = ();
@pre_build_callbacks = ();
@post_build_callbacks = ();


# test off a command line arg.
my @test_subdirs = ('x');
my @test_files = ('file1.m80', 'file2.m4', 'file3.txt');

sub build { 

    # the data mapping interface:
    # this says :  get the hash that is returned by &my_data() || %my_data;
    %D = grab_data('my_data');

    # now exec the callbacks
    for my $pre_build (@pre_build_callbacks) {
        if (ref($pre_build) eq 'CODE') {
            &{ $pre_build }(@_);
        }
    }

    # now run the actual build routine
    if ($test) {
        return &_build('.', \@test_subdirs, \@test_files);
    } else {
        return &_build(@_);
    }

    # and run the post action call backs.
    for my $post_build (@post_build_callbacks) {
        if (ref($post_build) eq 'CODE') {
            &{ $post_build }(@_);
        }
    }

}


sub _build {
    my ($dir, $rasubdirs, $rafiles) = @_;
    my $tmp = '';
    my $makefiletext = '';
    my %makefiledata = ();
    my @module_keys = grep { ! /(GLOBAL|PACKAGE_INFO|RELATIONSHIPS)/ } keys %D;

    # certain files should be ignored in this!
    my @files = grep { ! /^Makefile/ } 
                grep { ! /^config/   } 
                grep { ! /~$/        } @$rafiles;

    my ($test_for_makefile) = grep { /^Makefile$/ } @$rafiles;
    if ($test_for_makefile) {
        $existing_Makefiles = 1 ;
        # Move the file to a safe place, create an autoconf hook that
        # will put the file back on install.
        $makefiledata{'include_files'} .= " \$(top_srcdir)/autofiles/ac_bundler_special_files.mk";
        move( "$dir/Makefile", "$dir/Makefile.ac_bundler");
    }

    debugprint "Inside createMakefileam on $dir with root $root and files:", 
               scalar @files, " and subdirs:", scalar @$rasubdirs;

    if (scalar @$rasubdirs) {
        for my $d (@$rasubdirs) {
            opendir(D1, "$dir/$d");
            my @contents = grep { ! /^\.+$/ } readdir(D1);
            closedir(D1);
            if (scalar @contents) { # only include the subdir if there are files in it.
                $tmp .= " $d";
            }
        }
        $makefiledata{'subdirs'} = $tmp;
    } else {
        $makefiledata{'subdirs'} = '';
    }


    # derive the files and the locations that they end up in.
    # this constructs a pattern (rules) match engine and then 
    # passes each file through it for each make.am target. There is a 
    # a naming convention on the rule name - it should end in '_include'
    # or '_exclude' to decide if the file is in or out.
    #
    # If there is an _include and an _exclude, the _exclude overrides
    # If there is an _include and no _exclude, only files that match the include are in
    # If there is an _exclude and no _include, then all files that don't match are in.
    #
    # additionally - there are 2 namespaces that are merged to determine the
    # ruleset. The GLOBAL namespace is "pushed" onto the current node namespace where
    # the current node is calculated by finding the metadata PATH that has the longest
    # match against the current working directory (the $dir variable).
    # The rules in the current namespace are evaled in order, then the rules in the 
    # GLOBAL namespace are evaled in order.
    #
    my %mod_info = get_module_info($dir, @module_keys);
    my %global = (); %global = %{ $D{GLOBAL} } if exists $D{GLOBAL};

    # merge the 2 hashes into mod_info:
    # the node takes precedence over the GLOBAL namespace.
    # debugprint( "pre transform DATA: ", Dumper(\%D) );
    debugprint( "pre transform MOD_INFO: ", Dumper( \%mod_info ) );
    for $tmp (keys %global) {
        debugprint("looking at $tmp in glbl and ", exists $mod_info{$tmp} );
        if (exists $mod_info{$tmp}) {
            push  @{ $mod_info{ $tmp } }, @{ $global{ $tmp } };
        } else {
            $mod_info{$tmp} = $global{$tmp};
        }
    }
    debugprint( "post transform MOD_INFO: ", Dumper( \%mod_info ) );

    # this is a general algorithm that looks for the '_include' and '_exclude' 
    # and tries to build the correct set of resultant data from that infomation.
    #
    # the GLOBAL directive can effectively be overridden by lower level data
    # (via the %_info hash).
    #
    if (scalar keys %mod_info) { # it found something to use
        for my $k (grep { ! /^x_/ } keys %mod_info) {
            for my $f (@files) {
                my $tmp_f = $f;
                debugprint "Checking $tmp_f against $k ($name, $type)";
                if ($k =~ m/(.+)_(exclude|include)/) {
                    my $name = $1; my $type = $2;

                    if ( $type eq 'include'  && exists $mod_info{$name . '_exclude'}) {
                        for my $include ( @{ $mod_info{ $k } } ) {
                            if (eval("\$tmp_f =~ $include")) {
                                debugprint( "matched $include to $tmp_f on $name, checking if it is an exclude\n");
                                for my $exclude (  @{ $mod_info{$name . '_exclude'} } ) {
                                    if (eval("\$tmp_f =~ $exclude")) {
                                        debugprint "exlcuded per the $exclude rule";
                                    } else {
                                        $makefiledata{ $name } .= " $tmp_f";
                                    }
                                }
                            }
                        }
                    } elsif ( $type eq 'include') { # exclude doesn't exist
                        for my $match ( @{ $mod_info{ $k } } ) {
                            if (eval("\$tmp_f =~ $match")) {
                                debugprint( "matched $tmp_f to $name on $type - $match");
                                $makefiledata{ $name } .= " $tmp_f";
                            }
                        }
                    }  elsif ( $type eq 'exclude' && ! exists $mod_info{$name . '_include'} ) {
                        my $do_exclude = 0;
                        for my $match ( @{ $mod_info{$name . '_exclude'} } ) {
                            if (eval("\$tmp_f =~ $match")) {
                                debugprint( "matched $tmp_f to $name on $type - $match");
                                $do_exclude++;
                            }
                        }
                        # it didn't match an exclude rule
                        $makefiledata{ $name } .= " $tmp_f" unless $do_exclude;
                    }
                }
            }
        }
    } else {
        $makefiledata{'bin_scripts'} = join " ", @files;
    }


    # the x_ prefix is for checking the makefiledata and including, excluding it based
    # on what the x_ data says to do. The postfixes are _include _exclude.
    if (scalar keys %mod_info) { # it found something to use
        for my $k (grep { /^x_/ } keys %mod_info) {

            if ($k =~ m/^x_(.+)_(exclude|include)/) {
                my $name = $1; my $type = $2;

                if ( $type eq 'include'  && exists $mod_info{'x_' . $name . '_exclude'}) {
                    my @tmp = getarray( $rasubdirs, $rafiles, $mod_info{ $k } );
                    for my $include ( @tmp ) {
                        add_elem( \%makefiledata, $name, $include );
                    }
                    my @tmp = getarray( $rasubdirs, $rafiles, $mod_info{ 'x_' . $name . '_exclude' } );
                    for my $exclude (  @tmp ) {
                        remove_elem( \%makefiledata, $name, $exclude );
                    }
                } elsif ( $type eq 'include') { # exclude doesn't exist
                    my @tmp = getarray( $rasubdirs, $rafiles, $mod_info{ $k } );
                    debugprint( "build: about to add @tmp to $name" );
                    for my $include ( @tmp ) {
                        add_elem( \%makefiledata, $name, $include );
                    }
                }  elsif ( $type eq 'exclude' && ! exists $mod_info{ 'x_' . $name . '_include'} ) {
                    my @tmp = getarray( $rasubdirs, $rafiles, $mod_info{ $k } );
                    debugprint( "build: about to remove @tmp from $name" );
                    for my $exclude (  @tmp ) {
                        remove_elem( \%makefiledata, $name, $exclude );
                    }
                }

            }
        }
    } else {
        $makefiledata{'bin_scripts'} = join " ", @files;
    }



    debugprint( "About to gen files with: ", Dumper(\%makefiledata));

    # save the env state, so we can put it back after we build the templates - I think ENV is tied.
    {
        my %cache_env = ();
        @cache_env{ keys %ENV } = values %ENV;

        if ( $dir eq $root ) { # top level
            debugprint "I think this is the toplevel";
            
            # include a manifest file
            $makefiledata{'include_files'} .= " \$(top_srcdir)/autofiles/ac_bundler_special_files.mk";
            $makefiledata{'special_rule_files'} .= " $manifest_file_name";
            add_elem( \%makefiledata, 'extra_dist', $manifest_file_name );
            add_elem( \%makefiledata, 'bin_scripts', $manifest_file_name );

            # slurp in the package info that goes into configure.in
            if ($D{PACKAGE_INFO}) {
                for my $k (keys %{ $D{PACKAGE_INFO} } ) {
                    if (ref($D{PACKAGE_INFO}->{$k}) eq 'ARRAY') {
                        $ENV{lc $k} = join " ", @{ $D{PACKAGE_INFO}->{$k} };
                    } else {
                        $ENV{lc $k} = $D{PACKAGE_INFO}->{$k};
                    }
                }
            }

            # calculate the roles - this is a serialization
            my %roles = ();
            if (exists $D{'RELATIONSHIPS'}) {
                for my $rel (keys %{ $D{'RELATIONSHIPS'} } ) {
                    my @nodes = @{ $D{ 'RELATIONSHIPS' }->{ $rel } };
                    for my $node (@nodes) {
                        if (exists $D{$node}) {
                            my @node_path = @{ $D{$node}->{'PATH'} };
                            $roles{ $rel } .= join " ", (' ', @node_path);
                            debugprint("ROLE put $roles{$rel}\n");
                        }
                    }
                }
            }
            for my $role ( keys %roles) {
                $makefiledata{ 'roles' } .= "$role=$roles{$role};";
            }
            debugprint( "roles data is: ", $makefiledata{'roles'});
            makeTopLevelFiles( $dir, strip_whitespace(%makefiledata) );

        } else {   

            makeMakefileam( $dir, strip_whitespace(%makefiledata) );
        }

        # clean up the environment
        if ($D{PACKAGE_INFO}) {
            for my $k (keys %{ $D{PACKAGE_INFO} } ) {
                debugprint "flushing ENV $k";
                delete $ENV{$k};
            }
        }
        for my $tmp_k (keys %makefiledata) {
            debugprint "flushing ENV $tmp_k";
            delete $ENV{$tmp_k};
        }
        @ENV{ keys %cache_env } = values %cache_env;
    }

    debugprint "Leaving $dir with the following environment state";
    for $x (keys %ENV) {
        debugprint "ENV $x = $ENV{$x}";
    }

    return 1;
}

sub getarray {
    my ($rasubdirs, $rafiles, @data) = @_;
    debugprint( "getarray: \@data=@data ", scalar @data );
    if (scalar @data > 1) {
        return @data;
    } else {
        my $data = shift @data;
        debugprint( "getarray: working with $data=", ref($data) );
        if ( ref( $data ) eq 'CODE' ) {
            debugprint( "getarray: found CODE dirs:", @$rasubdirs, " files:", @$rafiles );
            return ( &{ $data }($rasubdirs, $rafiles) );

        } elsif ( ref( $data ) eq 'ARRAY' ) {
            return @{ $data };

        } elsif ( ref( $data ) eq 'HASH' ) {
            return %{ $data };

        } else {
            debugprint( "getarray: \@data has regular data: $data0" );
            return $data;
        }
    }
}

sub add_elem {
    my ($rahash, $name, $value ) = @_;
    debugprint "ADD_ELEM: $name $value";
    my @tmp = split /\s+/, $$rahash{$name};
    my ($exists) = grep { /^$value$/ } @tmp;
    $$rahash{$name} .= " $value" unless ($exists);
    debugprint "ADD_ELEM: DATA = ", Dumper($rahash);
}

sub remove_elem {
    my ($rahash, $name, $value ) = @_;
    my @out = ();
    debugprint "REMOVE_ELEM: $name $value";
    my @tmp = split /\s+/, $$rahash{$name};
    for my $tmp (@tmp) {
        push @out, $tmp unless (eval("\$tmp =~ $value"));
    }
    $$rahash{$name} = "@out";
    debugprint "remove_elem: DATA = ", Dumper($rahash);
}


sub test_module_info {
    $debug = 1;
    print "Test_module_info: ", Dumper( get_module_info( "m80repository", 'M80REPO', 'GRASSHOPPER' ) );
}
    
sub get_module_info {
    my ($dir, @keys) = @_;
    my ($longest_path, $longest_key, %out);
    
    # the module with the longest path that matches where we are now
    # is the module the data that I will use.
    for my $k (@keys) {
        my @path = @{ $D{$k}->{PATH} };
        for my $p (@path) {
            debugprint "testing $k against $p where dir = $dir";
            if (length $p > length $longest_path) {
                my ($tmp_dir, $tmp_p);
                ($tmp_dir = $dir) =~ s,^(\./|\.),,;
                ($tmp_p = $p) =~ s,^(\./|\.),,;
                if ( $tmp_dir =~ m,^$tmp_p, ) {
                    debugprint "setting key = $k";
                    $longest_path = $p;
                    $longest_key = $k;
                }
            }
        }
    }
     
    return (exists $D{$longest_key}) && %{ dclone($D{$longest_key}) };

}
    

sub strip_whitespace {
    my (%data) = @_;
    # and clean up the the hash elems a little before passing them on:
    for my $elem (keys %data) {
        $data{$elem} =~ s/^\s+//;
        $data{$elem} =~ s/\s+$//;
    }
    return %data;
}

sub templator_call {
    my ($dir, $src, $dest) = @_;
    my $cmd;
    $cmd = "(cd $dir; " if $dir;
    $cmd .= "m80templateDir.pl --source '$src' --dest '$dest' --no-append-log";
    $cmd .= " --debug" if ($debug > 1);
    $cmd .= " )" if $dir;
    debugprint "Execing $cmd\n";
    system($cmd);
}
        

sub makeMakefileam {
    my ($dir, %data) = @_;
    debugprint "Inside makeMakefileam with $dir\n";

    while (my ($k,$v) = (each %data)) {
        $ENV{$k} = $v;
    }
    templator_call( $dir, '/usr/local/m80-0.07/share/m80/lib/../templates/makefileam.tmpl', './Makefile.am');

#    open(F, ">$dir/Makefile.am") || die "$!";
#    print F $str, "\n";
#    close(F);
    push @Makefiles, "$dir/Makefile";
}

sub makeTopLevelFiles {
    my ($dir, %makefileamdata) = @_;
    
    makeMakefileam($dir, %makefileamdata, 'istoplevel', 'true');

    debugprint "Using Makefiles: @Makefiles";
    $ENV{"makefiles"} = "@Makefiles";
    templator_call($dir, '/usr/local/m80-0.07/share/m80/lib/../templates/autoconfTemplate', '.');

#    my $p = m80path::new(source => 'M80_LIB/../templates/autoconfTemplate',
#                         dest   => ".",
#                         debug  => $debug);
#    $p->generate;

    for my $f qw(README AUTHORS ChangeLog NEWS) {
        system( "touch $dir/$f" );
    }

        print "running aclocal\n";
    system( "aclocal");
        print "running autoconf\n";
    system( "autoconf");
        print "running automake -ac\n";
    system( "automake -ac");

    # generate the top level .dat file :)
#    if (-f "$dir/$manifest_file_name" ) {
        open(DAT, ">>$dir/$manifest_file_name");
#    } else {
#        open(DAT, ">$dir/$manifest_file_name");
#    }
    print DAT "m80ACInstaller --version = $version_number\n";
    print DAT "$0 @ORIGINAL_ARGV\n";
    close(DAT);
}


=pod

=head2 clean

recursively clean up the Makefile.am (and backups) and the configure.in (and bkups).
It will also pick up all the top level files, README, AUTOHORS, ChangeLog, etc...

=cut

sub clean { return &_clean(@_); }

sub clean {

    unless ($ENV{'QUIET'} || $do_recursive_kill_ac_files) {
        my $line = '';
        print STDERR "ABOUT TO RECURSIVELY DELETE MAKEFILE.AM AND CONFIGURE.IN. ARE YOU SURE? [Y]/N\n";
        read( STDIN, $line, 1 );
        chomp $line; # =~ s/[[\r\n]]*$//g;
        exit 0 if $line && $line !~ /y$/i;
        $do_recursive_kill_ac_files = 1;
    }

    my @dealy = qw(Makefile.am Makefile.in);

    debugprint " running!";

    my ($dir, $rasubdirs, $rafiles) = @_;
    for my $check (@dealy) {
        my @acfiles = grep { /$check/ } @$rafiles;
        for my $f (@acfiles) { 
            debugprint "killing $dir/$f"; 
            if ( -f "$dir/Makefile.am" ) {
                system( "rm -f Makefile" ); 
            }
            system( "rm -rf $dir/$f"); 
        }
    }

    # undo the ac_bundle files
    my @ac_bundler_files = grep { /.ac_bundler$/ } @$rafiles;
    if (scalar @ac_bundler_files) {
        debugprint "compare @$rafiles to @ac_bundler_files\n";
    
        for my $f (@ac_bundler_files) {
            my $shrtname; ($shrtname = $f) =~ s/\.ac_bundler$//;
            move( "$dir/$f", "$dir/$shrtname" );
        }
    }
    
    if ( $dir eq $root ) { # top level
        push @dealy, 
          qw(configure* README AUTHORS ChangeLog NEWS aclocal.m4 *.tar.gz *.cache *.log *.status install-sh missing COPYING INSTALL);
        for my $f (@dealy, $manifest_file_name) {
            debugprint "killing $dir/$f"; system( "rm -rf $dir/$f" );
        }
        (-d "$dir/autofiles") && system( " rm -rf $dir/autofiles " );
    }
}

=pod

=head1 ACCESSOR GENERATORS (CLOSURES)

Testing the idea that a closure is the easiest way to implement the interface between
the data struct (in metadata) and the consumer of that data (these scripts). Basically,
I know the interface has to be generated because the data structures can change and I
don't want to mess with Perl references everytime I need to change the structure. So
the closure provides the insulation. It generates the get_ methods per some convention.
I could use a preprocessor for this, but it would be m4 and perl in m4 is UGLY!

So - getnodes is the 1-many map between roles and nodes. genaccessor creates the 
interface at compile time. It takes an array and it will create a "get_" function
with the last element of the array appended. The array represents the path through
the hash. The assumption is that generally speaking the structs will be hashes of 
hashes or hashes of arrays. genaccessor will create a get method that can traverse
the tree (assuming one of those structures) to return the list or hash at the named 
posistion. Presumably this will just be used to access lists from a name. The lists 
can consist of anything - that is a function of the code that consumes the list.

=cut

sub getnodes { 
    my ($role) = @_; 
    my @o = ();
    for $n ( @{ $named_roles{ $role } } ) {
        push @o, $named_nodes{ $n };
    }
    return @o;
}

sub genaccessor {
    my (@keys) = @_;
    my $fname;
    if (scalar @keys == 1) {
        $fname = join "", @keys;
    } else {
        $fname = $keys[scalar @keys - 1];
    }

    *{"::get_$fname"} = sub { 
        my ($role) = @_;
        my $r ; my @path = @keys;
        my $bloop = 0; my $ret;

        if (ref($role) eq '') {
            ($r) = &getnodes($role);
         } else {
            $r = $role;
        }
        
        my $tmp = '$ret = $r->';
        for my $p (@path) {
            $tmp .= '->' if $bloop;
            $tmp .= '{' . $p . '}';
            $bloop = 1;
        }

        $ret = eval("$tmp"); die "ERROR! $@" if $@;
#        print STDERR " evaled: $tmp from @path with:", Dumper($r), " got ", Dumper($ret), "\n";
        if (ref( $ret ) eq 'ARRAY' ) {
#            print STDERR "D: ", $ret, " = ", ref($ret), " - ", @{ $ret }, "\n";
            return @{ $ret };
        } elsif (ref( $ret ) eq 'HASH' ) {
#            print STDERR "D: ", $ret, " = ", ref($ret), " - ", %{ $ret }, "\n";
            return %{ $ret };
        }
    };
}

# test some entry point to try and get the data I want

genaccessor('exclude_patterns');
genaccessor('make_rules');
genaccessor('paths');
genaccessor('make_rules', 'bin_include');
        

#print Dumper( keys %{*{'::'}} );
#print Dumper( getnodes('role1') );

#print Dumper( get_exclude_patterns(getnodes('role1'))), "\n";
#print Dumper( get_make_rules(getnodes('role1')) );
#print "output = " , get_bin_include( getnodes('role1')), "\n";
#print Dumper( get_bin_include( getnodes('role1')) );
#print "output = ", get_bin_include( 'role1' ) , "\n";


1;
