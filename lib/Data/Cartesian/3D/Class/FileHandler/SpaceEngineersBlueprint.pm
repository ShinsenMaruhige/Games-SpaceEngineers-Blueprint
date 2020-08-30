package Data::Cartesian::3D::Class::FileHandler::SpaceEngineersBlueprint;
our $VERSION = '0.04';

##~ DIGEST : 6e37e68d744d70bbc7101f4acd50fa9c
use Moo;
use XML::LibXML;
use Carp qw/confess/;
with qw/Games::SpaceEngineers::BluePrint::Role::XMLHandler/;

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
    confess("Not Implemented yet");
}

sub write {
    my ( $self, $path, $settings ) = @_;
    confess "Output file name not defined" unless $path;

    my $colour_defs = {};
    use Data::Dumper;

    my $particle_defs = {};

    # TODO persist ?
    $self->dc3->parse_particles(
        sub {
            my ( $def, $id ) = @_;
            use Data::Dumper;

            $def = $self->translate_particle($def);

            $particle_defs->{$id}->{component} = $self->get_xml_component($def);
            $particle_defs->{$id}->{colour}    = $self->get_colour_proto($def);

            return;
        }
    );

    my $root_element = XML::LibXML::Element->new('CubeBlocks');

    $def = $self->translate_particle($def);

    $particle_defs->{$id}->{component} = $self->get_xml_component($def);
    $particle_defs->{$id}->{colour}    = $self->get_colour_proto($def);

    return;
} );

my $root_element = XML::LibXML::Element->new('CubeBlocks');

$self->dc3->parse_cube( sub {
          my ( $x, $y, $z, $id ) = @_;
          warn "parse $id";

          my $this_block = $particle_defs->{$id}->{component}->cloneNode(1);
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
          #$self->set_orientation($this_block);
          $root_element->addChild($this_block);

          my $this_block = $particle_defs->{$id}->{component}->cloneNode(1);
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
          $self->set_orientation($this_block);
          $root_element->addChild($this_block);

          return;
}, $settings );

my $grid_string = $self->render_xml($root_element);

my $fullstring = $self->render_in_template( {
          grid_string => $grid_string
} );
open( my $ofh, '>:raw', $path ) or die "Failed to open output file : $!";
print $ofh $fullstring;
close($ofh);

return;
}

=head3 translate_particle
	Rewrite candidate - turn some internal format into something else - typically colour definitions into corresponding blocks
=cut

sub translate_particle {
    my ( $self, $def ) = @_;

    return $def;
}

1;
