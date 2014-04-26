use Modern::Perl;
use HackaMol;
use HackaMol::X::Calculator;
 
my $hack = HackaMol->new(
                          data => "examples/xyzs",
                        );
  
my $i = 0;
 
foreach my $xyz ( $hack->data->children( qr/\.xyz$/ ) )
{
   my $mol = $hack->read_file_mol( $xyz );
 
   my $Calc = HackaMol::X::Calculator->new (
                 mol        => $mol,
                 scratch    => 'realtmp/tmp',
                 in_fn      => "bah$i.xyz",
                 out_fn     => "calc-$i.out",
                 map_in     => \&input_map,
                 map_out    => \&output_map,
                 exe        => '~/bin/dftd3',
                 exe_endops => '-func b3pw91 -bj',
              
   );    
   $Calc->map_input;
   $Calc->capture_sys_command;
    
   my $energy = $Calc->map_output(627.51);
 
   printf ("Energy from xyz file: %10.6f\n", $energy);
 
   $i++;
 
}
 
#  our functions to map molec info to input and from output
sub input_map {
  my $calc = shift;
  $calc->mol->print_xyz($calc->in_fn);
}
 
sub output_map {
  my $calc   = shift;
  my $conv   = shift;
  my @eners  = map { /Edisp \/kcal,au:\s+-\d+.\d+\s+(-\d+.\d+)/; $1*$conv } grep {/Edisp/} $calc->out_fn->lines;
  return pop @eners;
}
