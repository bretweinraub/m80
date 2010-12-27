#!/usr/bin/perl  -I/usr/local/m80-0.07/share/m80/lib/perl 





while (<>) {
    m/^(.+?):(.*)/;
    ($fields[0],$fields[1]) = ($1, $2);
    $fields[0] =~ s/ /-/g;
    $fields[1] =~ s/^ //g;
    chomp($fields[1]);
    $fields[1] = "\"$fields[1]\"";
    print join('=', @fields) . "\n";
}

