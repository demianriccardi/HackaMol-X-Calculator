#!/usr/bin/env perl
# DMR April 29, 2014
#
#   perl examples/dftd3_out.pl
#
# run the program, generate output
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
        mol        => $mol,
        scratch    => $scratch,
        in_fn      => "bah$i.xyz",
        out_fn     => "calc-$i.out",
        exe        => '~/bin/dftd3',
        exe_endops => '-func b3pw91 -bj',

    );
    $Calc->capture_sys_command;
    $i++;

}

