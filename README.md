HackaMol-X-Calculator
=====================

VERSION
========
developer version 0.00_2 
Available for testing from cpan.org:

please see *[HackaMol::X::Calculator on MetaCPAN](https://metacpan.org/release/DEMIAN/HackaMol-X-Calculator-0.00_2) for formatted documentation.

SYNOPSIS
========

       use Modern::Perl;
       use HackaMol;
       use HackaMol::X::Calculator;

       my $hack = HackaMol -> new( 
                             name => "hackitup" , 
                             data => "local_pdbs",
       );
    
       my $i = 0;

       foreach my $pdb ( $hack -> data -> children( qr/\.pdb$/ ) ){

         my $mol = $hack -> read_file_mol( $pdb );

         my $Calc = HackaMol::X::Calculator -> new (
                    molecule => $mol,
                    scratch  => 'realtmp/tmp',
                    in_fn    => 'calc.inp'
                    out_fn   => "calc-$i.out"
                    map_in   => \&input_map,
                    map_out  => \&output_map,
                    exe      => '~/bin/xyzenergy < ', 
         );     
 
         $Calc -> map_input;
         $Calc -> capture_sys_command;
         my $energy = $Calc -> map_output(627.51);

         printf ("Energy from xyz file: %10.6f\n", $energy);

         $i++;

       }

       #  our functions to map molec info to input and from output
       sub input_map {
         my $calc = shift;
         $calc -> mol -> print_xyz( $calc -> in_fn );
       }

       sub output_map {
         my $calc   = shift;
         my $conv   = shift;
         my @eners  = map { /ENERGY= (-\d+.\d+)/; $1*$conv } $calc -> out_fn -> lines; 
         return pop @eners;
       }

DESCRIPTION
============

Abstract calculator class for HackaMol. The HackaMol::X::Calculator extension generalizes molecular calculations using external programs. The Calculator class consumes roles provided by the HackaMol core that manages the running of executables... perhaps on files; perhaps in directories.  This extension is intended to provide a simple example of interfaces with external programs.  It is probably a little too flexible. New extensions can evolve from this starting point, in scripts, to more rigid encapsulated classes. 


