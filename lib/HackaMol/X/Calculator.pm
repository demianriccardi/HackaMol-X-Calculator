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

sub build_command {
    # exe -options file.inp -moreoptions > file.out
    my $self = shift;
    return 0 unless $self->exe;
    my $cmd;
    $cmd = $self->exe;
    $cmd .= " " . $self->in_fn->stringify    if $self->has_in_fn;
    $cmd .= " " . $self->exe_endops          if $self->has_exe_endops;
    $cmd .= " > " . $self->out_fn->stringify if $self->has_out_fn;

    # no cat of out_fn because of options to run without writing, etc
    return $cmd;
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
   use Path::Tiny;
   
   my $path = shift || die "pass path to gaussian outputs";
   
   my $hack = HackaMol->new( data => $path, );
   
   foreach my $out ( $hack->data->children(qr/\.out$/) ) {

       my $Calc = HackaMol::X::Calculator->new(
           out_fn  => $out,
           map_out => \&output_map,
       );
   
       my $energy = $Calc->map_output(627.51);
   
       printf( "%-40s: %10.6f\n", $Calc->out_fn->basename, $energy );
   
   }
   
   #  our function to map molec info from output
   
   sub output_map {
       my $calc = shift;
       my $conv = shift;
       my $re   = qr/-\d+.\d+/;
       my @energys = $calc->out_fn->slurp =~ m/SCF Done:.*(${re})/g;
       return ( $energys[-1] * $conv );
   }

=head1 DESCRIPTION

The HackaMol::X::Calculator extension generalizes molecular calculations using external programs. 
The Calculator class consumes the HackaMol::X::ExtensionRole role, which manage the running of executables... 
perhaps on files; perhaps in directories.  This extension is intended to provide a 
simple example of interfaces with external programs. This is a barebones use of the ExtensionRole that is 
intended to be flexible. See the examples and testing directory for use of the map_in and map_out functions
inside and outside of the map_input and map_output functions.  Extensions with more rigid and encapsulated 
APIs can evolve from this starting point. In the synopsis, a Gaussian output is processed for the SCF Done
value (a classic scripting of problem computational chemists).  See the examples and tests to learn how the 
calculator can be used to: 

  1. generate inputs 
  2. run programs
  3. process outputs

via interactions with HackaMol objects.

=attr scratch

If scratch is set, the object will build that directory if needed.  See HackaMol::PathRole for more information about 
the scratch attribute.

=head1 SEE ALSO

=for :list
* L<HackaMol>
* L<HackaMol::X::Extension>
* L<HackaMol::PathRole>
* L<Path::Tiny>
 

