
$x = 1;

sub testRoutine
{
    return "first arg is $_[0];";
}

<native>
this is native text  .... what ever you want goes here.

\$x is $x

testRoutine is " . &testRoutine($x) . "

</native>


sub anotherProgram
{
    my ($arg1) = @_;

    return "anotherProgram called with $arg1";
}

<native>
more stdout

call another program " . anotherProgram(testRoutine($x)) . "

what is $ENV{SHELL}?
</native>

<<anotherFile>>
