
package dbiGeneric;

sub slurp
{
    local ($DATA, $cursor) = @_;
    my @row;
    
    $DATA->{rows} = 0;
    while (@row = $cursor->fetchrow_array()) {
	$DATA->{rows}++;
	for (my $i = 0; $i < $cursor->{NUM_OF_FIELDS} ; $i++) {
	    push (@{$DATA->{$cursor->{NAME}->[$i]}},$row[$i]);
	}
    }
    for (my $i = 0; $i < $cursor->{NUM_OF_FIELDS}; $i++) {
	push (@{$DATA->{_fields}},$cursor->{NAME}->[$i]);
    }
    $cursor->finish;
}

my $dummy = 1;
