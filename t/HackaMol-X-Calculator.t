#!/usr/bin/env perl

use strict;
use warnings;
use Test::Moose;
use Test::More;
use Test::Fatal qw(lives_ok dies_ok);
use Test::Dir;
use Test::Warn;
use HackaMol::X::Calculator;
use HackaMol;
use Cwd;

my $cwd = getcwd;
# coderef
my $sub_cr = sub{return(@_)};

{    # test HackaMol class attributes and methods

    my @attributes = qw(mol map_in map_out);
    my @methods    = qw(doit);

    my @roles = qw(HackaMol::ExeRole HackaMol::PathRole);

    map has_attribute_ok( 'HackaMol::X::Calculator', $_ ), @attributes;
    map can_ok( 'HackaMol::X::Calculator', $_ ), @methods;
    map does_ok( 'HackaMol::X::Calculator', $_ ), @roles;

}

my $mol = HackaMol::Molecule->new();
my $obj;

{ # test basic functionality

  dies_ok {
    $obj = HackaMol::X::Calculator->new();
  }
  'creation without required mol dies';
  
  lives_ok {
    $obj = HackaMol::X::Calculator->new(mol => $mol);
  }
  'creation of an obj with mol';

  dir_not_exists_ok("t/tmp", 'scratch directory does not exist yet');

  lives_ok {
    $obj = HackaMol::X::Calculator->new(mol => $mol, exe => "foo.exe");
  }
  'creation of an obj with exe';

  dir_not_exists_ok("t/tmp", 'scratch directory does not exist yet');
  
  is($obj->command, $obj->exe,    "command set to exe");

  lives_ok {
    $obj = HackaMol::X::Calculator->new(mol   => $mol, exe => "foo.exe <",
                                        map_in => $sub_cr, map_out => $sub_cr,
                                        in_fn => "foo.inp", scratch => "t/tmp");
  }
  'Test creation of an obj with exe in_fn and scratch';

   warning_is { HackaMol::X::Calculator->new(mol   => $mol, map_in => $sub_cr) }
    "has map_in and no in_fn to map to!",
    "warning map_in no in_fn";

   warning_is { HackaMol::X::Calculator->new(mol   => $mol, in_fn => 'foo.inp') }
    "has in_fn and no map_in to map to it!",
    "warning map_in no in_fn";

  dir_exists_ok($obj->scratch, 'scratch directory exists');

  is($obj->command, $obj->exe . " " .$obj->in_fn,  "command set to exe and input");
  is($obj->scratch, "$cwd/t/tmp", "scratch directory");

  $obj->scratch->remove_tree;
  dir_not_exists_ok("t/tmp", 'scratch directory deleted');

}

{ # test the map_in and map_out

  $obj = HackaMol::X::Calculator->new(mol => $mol, in_fn => "foo.inp", map_in => $sub_cr, map_out => $sub_cr);

  my @tv = qw(1 2 3 4);
  my @def_map_in = &{$obj->map_in}(@tv);
  my @def_map_out = &{$obj->map_out}(@tv);

  is_deeply(\@tv, \@def_map_in, 'default map_in returns what you send in');
  is_deeply(\@tv, \@def_map_out, 'default map_out returns what you send in');

}

done_testing();


