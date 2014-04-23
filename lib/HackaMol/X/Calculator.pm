  package HackaMol::X::Calculator;
  # ABSTRACT: Abstract calculator class for HackaMol
  use Moose::Util::TypeConstraints;
  use Moose;
  use File::chdir;
  with qw(HackaMol::ExeRole HackaMol::PathRole); 

  has 'molecule'     => (
                      is       => 'ro',
                      isa      => 'HackaMol::Molecule',
                      #required => 1,
                      );

  has 'map_in'    => (
                      is       => 'rw',
                      isa      => 'CodeRef',
                      builder  => '_build_map_in',
                      lazy     => 1,
                      );
  sub _build_map_in {
    my $sub_rf = sub {return(@_)}; 
    return ($sub_rf);
  }

  has 'map_out'   => (
                      is       => 'rw',
                      isa      => 'CodeRef',
                      builder  => '_build_map_out',
                      lazy     => 1,
                      );

  sub _build_map_out {
    my $sub_rf = sub {return(@_)}; 
    return ($sub_rf);
  }
  
  #some setup
  sub BUILD {
    my $self = shift;
    
    if ($self->has_scratch){ 
      $self->scratch->mkpath unless ($self->scratch->exists);
    }
    #build command
    unless ($self->has_command) {
      my $cmd ;
      $cmd = $self->exe              if $self->has_exe;
      $cmd .= " ". $self->in_fn      if $self->has_in_fn;
      $cmd .= " ". $self->exe_endops if $self->has_exe_endops;
      $self->command($cmd) if $cmd;
    }     

    return;
  }

  sub doit{
    my $self = shift;
    # always work in scratch if scratch is set
    local $CWD = $self->scratch if ($self->has_scratch); 
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

   foreach my $pdb ($hack->data->children(qr/\.pdb$/)){

      my $mol = $hack->read_file_mol($pdb);

      my $Calc = HackaMol::X::Calculator->new (
                    molecule => $mol,
                    scratch  => 'realtmp/tmp',
                    map_in   => \&input_map,
                    map_out  => \&output_map,
      );      

      say $mol->energy;

   }

   ######## our functions to map molecular info to input to output and back to molecular info
   sub input_map {
     my $mol = shift;
     return $mol->str_xyz; # string with formatted xyz file
   }

   sub output_map {
     my $mol = shift;
     my ($ener) = map {my @ener = split; $ener[1] } 
                  grep {/ENERGY=.*\d/} @_;
     $mol->set_energy($mol->t, $ener);
   }



