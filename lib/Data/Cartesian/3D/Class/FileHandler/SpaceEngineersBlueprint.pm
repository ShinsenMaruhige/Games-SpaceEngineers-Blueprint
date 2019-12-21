package Data::Cartesian::3D::Class::FileHandler::SpaceEngineersBlueprint;
our $VERSION = '0.02';

##~ DIGEST : 1045fdb9eb159e8b5210aaaa4491e3c9
use Moo;
use Carp qw/confess/;

INITPARAMS: {
	OBJECTS: {
		has dc3 => ( is => 'rw', required => 1 );
	}
}

# TODO refactor out into generic GD reader, writer has to be PNG apparently

=head3 read
	Turn an image into a cartesian cube element at some z level, default 0
	TODO :
		custom offsets
=cut

sub read {
	my ( $self, $path, $settings ) = @_;
	confess( "Not Implemented yet" );
}

sub write {
	my ( $self, $path, $settings ) = @_;
	confess "Output file name not defined" unless $path;

	my $colour_defs = {};
	use Data::Dumper;
	my $gdi = GD::Image->new( $settings->{to}->{x}, $settings->{to}->{y} );
	$gdi->trueColor( 1 );

	# TODO enable colour allocation on demand ?
	# TODO persist ?
	$self->dc3->parse_particles(
		sub {
			my ( $def, $id ) = @_;

			for ( qw/r g b / ) {
				confess "Cannot translate particle $id - doesn't have a $_ value" unless defined( $def->{$_} );
			}
			my $colour = $gdi->colorAllocate( $def->{r}, $def->{g}, $def->{b} );
			$colour_defs->{$id} = $colour;
			return;
		}
	);

	$self->dc3->parse_cube(
		sub {
			my ( $x, $y, $z, $id ) = @_;
			$gdi->setPixel( $x, $y, $colour_defs->{$id} );
			return;
		},
		$settings
	);

	open( my $ofh, '>:raw', $path ) or die "Failed to open output file [$settings->{ofn}] : $!";
	print $ofh $gdi->png();
	close( $ofh );
	return;
}

1;
