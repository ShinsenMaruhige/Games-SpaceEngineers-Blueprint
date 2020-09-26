#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;

package MooImager;
use Moo;
extends qw/
  Data::3D::Grids::FileHandler::GDImage
  /;

1;

package I2BClass;
use Moo;
extends qw/
  Data::3D::Grids::FileHandler::SpaceEngineersBlueprint
  /;
with qw/
  Moo::GenericRole::JSON
  /;

sub translate_particle {
	my $self = shift;
	$self->_translate_rgb_particle( @_ );
}

sub set_map_from_file {
	my ( $self, $path ) = @_;
	$self->colour_map( $self->json_load_file( $path ) );
}

1;

package main;
use Data::3D::Grids::SQLiteJSON;
use Moo::GenericRoleClass::CLI;
main();

sub main {
	my $cli = Moo::GenericRoleClass::CLI->new();
	my $c   = $cli->get_config( [qw/ infile mapfile action /] );

	$cli->check_file( $c->{infile} );
	$cli->check_file( $c->{mapfile} );

	if ( $c->{action} eq 'image' ) {

		#read an image into a new database and then parse it
		my $d3g = Data::3D::Grids::SQLiteJSON->new( {dbfile => "temp_" . time . ".sqlite"} );
		my $gdi = MooImager->new( {d3g => $d3g} );

		my $i2b = I2BClass->new(
			{
				d3g => $d3g,
			}
		);

		$i2b->set_map_from_file( $c->{mapfile} );
		$gdi->read( $c->{infile} );
		$d3g->commit();

		$i2b->write( "temp_out" . time . '.xml' );
		$d3g->done();
	} elsif ( $c->{action} eq 'db' ) {

		#use an existing frobnicated database
		my $d3g = Data::3D::Grids::SQLiteJSON->new( {dbfile => $c->{infile}} );
		my $i2b = I2BClass->new(
			{
				d3g => $d3g,
			}
		);
		$i2b->set_map_from_file( $c->{mapfile} );
		$i2b->write( "temp_out" . time . '.xml' );
		$d3g->done();
	} else {
		die "Action not supported!";
	}

}
