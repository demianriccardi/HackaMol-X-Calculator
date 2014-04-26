use Modern::Perl;
use YAML::XS qw(Dump LoadFile);
use Path::Tiny;
use File::chdir;

#system("wget http://pubs.acs.org/doi/suppl/10.1021/ct300296k/suppl_file/ct300296k_si_001.txt");
my $data = LoadFile("ct300296k_si_001.txt");
my $xyzdir = path("xyzs");
$xyzdir->mkpath unless $xyzdir->exists;
$CWD = $xyzdir;

foreach my $sol ( qw(aq) )
{
  foreach my $nw ( keys ( %{$data->{$sol}}  ) )
  {
    foreach my $config (keys ( %{ $data->{$sol}{$nw} }  ) )
    {
      #print Dump $data->{$sol}{$nw}{$config};
      my $xyz = $data->{$sol}{$nw}{$config}{Z_xyz};
      my $dump_xyz  = scalar(@{$xyz}) . "\n\n";
      $dump_xyz    .= join ("\n", @{$xyz}); 
      my $fxyz = path("$sol-$nw-$config.xyz");
      $fxyz->spew($dump_xyz);
    }
  }

}

