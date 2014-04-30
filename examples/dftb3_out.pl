#!/usr/bin/env perl
# DMR April 29, 2014
#
#   perl examples/dftd3_out.pl
#
# process the output
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
        out_fn  => "calc-$i.out",
        map_out => \&output_map,

    );

    my $energy = $Calc->map_output(627.51);

    printf( "Energy from xyz file: %10.6f\n", $energy );

    $i++;

}

#  our function to map molec info from output

sub output_map {
    my $calc = shift;
    my $conv = shift;
    my $out  = $calc->out_fn->slurp;
    $out =~ m /Edisp \/kcal,au:\s+-\d+.\d+\s+(-\d+.\d+)/;
    return ( $1 * $conv );
}
