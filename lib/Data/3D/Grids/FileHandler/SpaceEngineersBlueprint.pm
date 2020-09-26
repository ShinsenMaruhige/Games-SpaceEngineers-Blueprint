package Data::3D::Grids::FileHandler::SpaceEngineersBlueprint;
our $VERSION = '0.08';
##~ DIGEST : 2425cb58eee7ec571ec381ac0725fd70
use Moo;
use XML::LibXML;
use Carp qw/confess/;
extends qw/Data::3D::Grids::FileHandler/;
with qw/Games::SpaceEngineers::BluePrint::Role::XMLHandler/;

ACCESSORS: {
	has colour_map => (
		is      => 'rw',
		lazy    => 1,
		default => sub { return {}; }
	);

}

=head3 read
=cut

sub read {

	my ( $self, $path, $settings ) = @_;
	confess( "Not Implemented yet" );

}

sub write {

	my ( $self, $path, $settings ) = @_;
	confess "Output file name not defined" unless $path;
	my $colour_defs   = {};
	my $particle_defs = {};

	# TODO persist ?
	$self->d3g->parse_particles(
		sub {
			my ( $def, $id ) = @_;
			$def                               = $self->translate_particle( $def );
			$particle_defs->{$id}->{component} = $self->get_xml_component( $def );
			$particle_defs->{$id}->{colour}    = $self->get_colour_proto( $def );
			return;
		}
	);
	my $root_element = XML::LibXML::Element->new( 'CubeBlocks' );
	$self->d3g->parse_cube(
		sub {
			my ( $x, $y, $z, $id ) = @_;
			my $this_block = $particle_defs->{$id}->{component}->cloneNode( 1 );
			$self->set_position(
				$this_block,
				{
					'x' => $x,
					'y' => $y,
					'z' => $z,
				}
			);
			$self->set_colour( $this_block, $particle_defs->{$id}->{colour} );

			# TODO handle orientation intelligently
			$self->set_orientation( $this_block );
			$root_element->addChild( $this_block );
			return;
		},
		$settings
	);
	my $grid_string = $self->render_xml( $root_element );
	my $fullstring  = $self->render_in_template( {grid_string => $grid_string} );
	open( my $ofh, '>:raw', $path ) or die "Failed to open output file : $!";
	print $ofh $fullstring;
	close( $ofh );
	return;

}

=head3 translate_particle
	Rewrite candidate - turn some internal format into something else - typically colour definitions into corresponding blocks
=cut

sub translate_particle {

	my ( $self, $def ) = @_;
	return $def;

}

sub _translate_rgb_particle {

	my ( $self, $def ) = @_;

	my $return = {
		%{$self->colour_map()->{defaults}},
		'r' => $def->{r},
		'g' => $def->{g},
		'b' => $def->{b},

	};
	my $key_string = "$def->{r},$def->{g},$def->{b}";

	if ( my $replaced = $self->colour_map()->{$key_string} ) {
		my $ref = ref( $replaced );
		if ( $ref ) {
			if ( $ref eq 'HASH' ) {
				$def->{SubtypeName} = $replaced->{SubtypeName};
			} else {
				confess "Invalid colour map structure - [$ref] instead of HASH";
			}
		} else {
			$return->{SubtypeName} = $replaced;
		}
	}

	confess "No SubtypeName could be set for this definition - no default?" unless $return->{SubtypeName};
	return $return; #return!

}

1;
