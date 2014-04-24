  package HackaMol::X::Calculator;
  # ABSTRACT: Abstract calculator class for HackaMol
  use Moose::Util::TypeConstraints;
  use Moose;
  use Carp;
  use Capture::Tiny ':all';
  use File::chdir;
  with qw(HackaMol::ExeRole HackaMol::PathRole); 

  has 'mol'  => (
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
      return unless ($self->has_exe);
      my $cmd = $self->build_command;
      $self->command($cmd);
    }    

    return;
  }

  sub build_command {
      # the command won't be overwritten during build, but may be overwritten with this method
      my $self = shift;
      my $cmd ;
      $cmd = $self->exe ;
      $cmd .= " "  . $self->in_fn      if $self->has_in_fn;
      $cmd .= " "  . $self->exe_endops if $self->has_exe_endops;
      # no cat of out_fn because of options to run without writing, etc
      return $cmd;
  }

  sub map_input {
    # pass everything and anything to map_in... i.e. keep @_ in tact
    my ($self) = @_;
    unless ($self->has_in_fn and $self->has_map_in){
      carp "in_fn and map_in attrs required to map input";
      return 0;
    }
    local $CWD = $self->scratch if ($self->has_scratch);
    my $input = &{$self->map_in}(@_);    
    # $self->in_fn->spew($input); leaving such actions inside the map_in coderef is more flexible
    # too flexible?
    return $input;
  }

  sub map_output {
    # pass everything and anything to map_out... i.e. keep @_ in tact
    my ($self) = @_;
    unless ($self->has_out_fn and $self->has_map_out){
      carp "out_fn and map_out attrs required to map output";
      return 0;
    }
    local $CWD = $self->scratch if ($self->has_scratch);
    my $output = &{$self->map_out}(@_);
    return $output;
  }

  sub run_command {
    # run it and return all that is captured
    my $self= shift;
    return 0 unless $self->has_command;
    local $CWD = $self->scratch if ($self->has_scratch);
    my ($stdout,$stderr,$exit) = capture {
      system($self->command);
    };
    return ($stdout,$stderr,$exit); 
  }  

#  sub doit{
#    my $self = shift;
#    # always work in scratch if scratch is set
#    local $CWD = $self->scratch if ($self->has_scratch);
#
#    # input file is not required to generate output!
#    if ($self->has_in_fn){
#      my $input = $self->map_in($self->mol); 
#      $self->in_fn->spew($input);
#    }
#
#    my ($stdout, $stderr) = capture $self->command;
#    $self->out_fn->spew($stdout) if $self->has_out_fn;
#    $self->err_fn->spew($stderr) if $self->has_err_fn;
# 
#  }

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



