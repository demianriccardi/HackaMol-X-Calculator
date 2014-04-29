#!/usr/bin/env perl
# DMR April 29, 2014
#   
#   perl examples/g09_out.pl ~/some/path 
# 
# pull energies from gaussian outputs in directory (path submitted on commandline) 
#

use Modern::Perl;
use HackaMol;
use HackaMol::X::Calculator;
use Path::Tiny;

my $path = shift || die "pass path to gaussian outputs";
 
my $hack = HackaMol->new(
                         data => $path,
                        );
  
my $i = 0;


my $scratch = path('tmp');
 
foreach my $out ( $hack->data->children( qr/\.out$/ ) )
{
 
   my $Calc = HackaMol::X::Calculator->new (
                 out_fn     => $out,
                 map_out    => \&output_map,
   );    
    
   my $energy = $Calc->map_output(627.51);
   
   printf ("%-40s: %10.6f\n", $Calc->out_fn->basename, $energy);
 
   $i++;
 
}
 
#  our function to map molec info from output
 
sub output_map {
  my $calc   = shift;
  my $conv   = shift;
  my $out    = $calc->out_fn->slurp;
  $out =~ m /SCF Done:.*(-\d+.\d+)/;
  return ($1*$conv);
}
