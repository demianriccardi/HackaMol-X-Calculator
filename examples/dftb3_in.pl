#!/usr/bin/env perl
# DMR April 29, 2014
#
#   perl examples/dftd3_out.pl
#
# generate input
#
# See examples/dftd3.pl for full script that writes input,
# runs program, and processes output.

use Modern::Perl;
use HackaMol;
use HackaMol::X::Calculator;
use Path::Tiny;

my $hack = HackaMol->new( data => "examples/xyzs", );

my $scratch = $hack->data;

foreach my $xyz ( grep {!/^symbol_/} $hack->data->children(qr/\.xyz$/) ) {

    my $mol = $hack->read_file_mol($xyz);
    my $sym_xyz = 'symbol_' . $xyz->basename;

    say $sym_xyz;
    my $Calc = HackaMol::X::Calculator->new(
        mol     => $mol,
        scratch => $scratch,
        in_fn   => $sym_xyz,
        map_in  => \&input_map,
    );

    $Calc->map_input;

}

#  our function to map molec info to input
sub input_map {
    my $calc = shift;
    $calc->mol->print_xyz( $calc->in_fn );
}

