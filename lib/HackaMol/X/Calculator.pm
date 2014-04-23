  package HackaMol::X::Calculator;
  # ABSTRACT: Abstract calculator class for HackaMol
  use Moose::Util::TypeConstraints;
  use Moose;
  use Carp;
  use File::chdir;
  with qw(HackaMol::ExeRole HackaMol::PathRole); 

  has 'molecule'  => (
                      is        => 'ro',
                      isa       => 'HackaMol::Molecule',
                      required  => 1,
                     );

  has 'map_in'    => (
                      is        => 'ro',
                      isa       => 'CodeRef',
                      predicate => 'has_map_in',
                     );
  has 'map_out'   => (
                      is        => 'ro',
                      isa       => 'CodeRef',
                      predicate => 'has_map_out',
                     );

  #some setup
  sub BUILD {
    my $self = shift;
    
    if ($self->has_scratch){ 
      $self->scratch->mkpath unless ($self->scratch->exists);
    }
    #build command
    unless ($self->has_command) {
      my $cmd ;
      $cmd = $self->exe                if $self->has_exe;
      $cmd .= " "  . $self->in_fn      if $self->has_in_fn;
      $cmd .= " "  . $self->exe_endops if $self->has_exe_endops;
      # no cat of out_fn because we capture and then write in doit 
      $self->command($cmd) if $cmd;
    }    
    if ($self->has_in_fn){ 
      carp "has in_fn and no map_in to map to it!" unless($self->has_map_in);
    }
    else {
      carp "has map_in and no in_fn to map to!" if($self->has_map_in);
    }
  
    return;
  }

  sub doit{
    my $self = shift;
    # always work in scratch if scratch is set
    local $CWD = $self->scratch if ($self->has_scratch);

    # input file is not required to generate output!
    if ($self->has_in_fn){
      my $input = $self->map_in($self->mol); 
      $self->in_fn->spew($input);
    }

    my ($stdout, $stderr) = capture $self->command;
    $self->out_fn->spew($stdout) if $self->has_out_fn;
    $self->err_fn->spew($stderr) if $self->has_err_fn;
 
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
                    exe      => '~/bin/xyzenergy < ', # some magical executable
      );      
      
      $Calc->doit;

      printf ("Energy from xyz file: %10.6f\n", $mol->energy;

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



