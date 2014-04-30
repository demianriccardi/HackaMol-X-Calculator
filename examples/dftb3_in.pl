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

my $i = 0;

my $scratch = path('tmp');

foreach my $xyz ( $hack->data->children(qr/\.xyz$/) ) {
    my $mol = $hack->read_file_mol($xyz);

    my $Calc = HackaMol::X::Calculator->new(
        mol     => $mol,
        scratch => $scratch,
        in_fn   => "bah$i.xyz",
        map_in  => \&input_map,

    );
    $Calc->map_input;
    $i++;

}

#  our function to map molec info to input
sub input_map {
    my $calc = shift;
    $calc->mol->print_xyz( $calc->in_fn );
}

