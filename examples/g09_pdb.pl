#!/usr/bin/env perl
# DMR April 29, 2014
#   
#   perl examples/g09_pdb.pl ~/some/path 
# 
# pull energy from gaussian single-point outputs in directory (path submitted 
# on commandline) 
#

use Modern::Perl;
use HackaMol;
use HackaMol::X::Calculator;
use Path::Tiny;

my $path = shift || die "pass path to gaussian outputs";
 
my $hack = HackaMol->new(
                         data => $path,
                        );

foreach my $out ( $hack->data->children( qr/\.out$/ ) )
{
 
   my $Calc = HackaMol::X::Calculator->new (
                 mol        => HackaMol::Molecule->new,
                 out_fn     => $out,
                 map_out    => \&output_map,
   );    
    
   my $qs = $Calc->map_output;
   print $qs; 
 
}
 
#  our function to map molec info from output
 use Data::Dumper;
sub output_map {
  my $calc    = shift;
  my $conv    = shift;
  my @lines   = $calc->out_fn->lines;
  my @qs      = mulliken_qs(@lines);
  my @atoms   = Zxyz(@lines);
  print Dumper \@atoms;
  return (join("_", @qs));
}

sub Zxyz {
  #pull all coordinates
  my @lines = @_;
  my @ati_zxyz = grep {m/(\s+\d+){3}(\s+-?\d+.\d+){3}/}
                 grep {
                     m/(Input orientation)|(Standard orientation):|(Z-Matrix orientation:)/
                  .. m/(Stoichiometry)|(Distance matrix \(angstroms\))|(Rotational constants) /
                      } @lines;
  my @splits   = map {[split]}   @ati_zxyz;
  my @ati      = map {$_->[0]-1} @splits;
  my @Z        = map {$_->[1]}   @splits;
  my @x        = map {$_->[3]}   @splits;
  my @y        = map {$_->[4]}   @splits;
  my @z        = map {$_->[5]}   @splits;

  my @atoms;
  foreach my $i (0 .. $#ati){
    push @{$atoms[$ati[$i]]}, [$Z[$i],$x[$i],$y[$i],$z[$i]];
  }  
  return @atoms;
}

sub mulliken_qs {
  my @lines = @_;
  my @imuls   =  grep {$lines[$_] =~ m/Mulliken atomic charges/}  0 .. $#lines;
  my @mull_ls =  grep {m/\s+\d+\s+\w+\s+-*\d+/} @lines[$imuls[0] ..  $imuls[1]];
  my @mull_qs = map {$_->[2]} map{[split]} @mull_ls;
  return @mull_qs;
}

sub nbo_qs {
  my @lines = @_;
  my @inbos =  grep {$lines[$_] =~ m/(\s){5}Natural Population/} 0 .. $#lines;
  my @nbo_ls  = grep {m/\s+\w+\s+\d+\s+-*\d+.\d+/} @lines[$inbos[0] ..  $inbos[1]];
  my @nbo_qs  = map {$_->[2]} map{[split]} @nbo_ls;
  return @nbo_qs;
}

