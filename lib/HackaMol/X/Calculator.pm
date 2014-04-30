package HackaMol::X::Calculator;

# ABSTRACT: Abstract calculator class for HackaMol
use 5.008;
use Moose;
use MooseX::StrictConstructor;
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use Carp;

with qw(HackaMol::X::ExtensionRole);

sub _build_map_in{
  my $sub_cr = sub { return (@_) };
  return $sub_cr;
}

sub _build_map_out{
  my $sub_cr = sub { return (@_) };
  return $sub_cr;
}


sub BUILD {
    my $self = shift;

    if ( $self->has_scratch ) {
        $self->scratch->mkpath unless ( $self->scratch->exists );
    }

    unless ( $self->has_command ) {
        return unless ( $self->has_exe );
        my $cmd = $self->build_command;
        $self->command($cmd);
    }
    return;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS
    
   use Modern::Perl;
   use HackaMol;
   use HackaMol::X::Calculator;

   my $hack = HackaMol->new( 
                             name => "hackitup" , 
                             data => "local_pdbs",
                           );
    
   my $i = 0;

   foreach my $pdb ($hack->data->children(qr/\.pdb$/)){

      my $mol = $hack->read_file_mol($pdb);

      my $Calc = HackaMol::X::Calculator->new (
                    molecule => $mol,
                    scratch  => 'realtmp/tmp',
                    in_fn    => 'calc.inp'
                    out_fn   => "calc-$i.out"
                    map_in   => \&input_map,
                    map_out  => \&output_map,
                    exe      => '~/bin/xyzenergy < ', 
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
     my @eners  = map { /ENERGY= (-*\d+.\d+)/; $1*$conv } 
                  grep {/ENERGY= -*\d+.\d+/} $calc->out_fn->lines; 
     return pop @eners; 
   }

=head1 DESCRIPTION

The HackaMol::X::Calculator extension generalizes molecular calculations using external programs. 
The Calculator class consumes the HackaMol::X::ExtensionRole role, which manage the running of executables... 
perhaps on files; perhaps in directories.  This extension is intended to provide a 
simple example of interfaces with external programs. This is a barebones use of the ExtensionRole that is 
intended to be flexible. See the examples and testing directory for use of the map_in and map_out functions
inside and outside of the map_input and map_output functions.  Extensions with more rigid and encapsulated 
APIs can evolve from this starting point. In the synopsis, the input is written (->map_input), the command 
is run (->capture_sys_command) and the output is processed (->map_output).  Thus, the calculator can be used to: 

  1. generate inputs 
  2. run programs
  3. process outputs

=attr scratch

If scratch is set, the object will build that directory if needed.  See HackaMol::PathRole for more information about 
the scratch attribute.

=head1 SEE ALSO

=for :list
* L<HackaMol>
* L<HackaMol::X::Extension>
* L<HackaMol::PathRole>
* L<Path::Tiny>
 

