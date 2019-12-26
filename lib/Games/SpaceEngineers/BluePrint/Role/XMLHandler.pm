package Games::SpaceEngineers::BluePrint::Role::XMLHandler;
our $VERSION = '0.02';

##~ DIGEST : ff5b2c58f984d755d90bb5ecef41f588
# ABSTRACT: Moose role for constructing SE blueprint XML using XML::LibXML with guard rails
use Moo::Role;
use Carp qw/confess/;
use XML::LibXML;
use XML::LibXML::PrettyPrint;
sub get_xml_component {
	my ( $self, $p ) = @_;
	my $eparams = {%{$p}};
	for ( qw/ SubtypeName/ ) {
		confess "Missing element [$_]" unless defined($eparams->{$_});
	}

	# 'The Thing'
	my $this_block = XML::LibXML::Element->new( 'MyObjectBuilder_CubeBlock' );
	my $subtype_block = XML::LibXML::Element->new( 'SubtypeName' );
	$subtype_block->appendText($p->{SubtypeName});
	$this_block->addChild( $subtype_block );

	#The actual block type, e.g. heavy armor, refinery etc
	my $component = XML::LibXML::Element->new( 'SubtypeName' );

	$this_block->setAttribute( 'xsi:type', 'MyObjectBuilder_CubeBlock' );





	#Wild mass guessing suggests this is to do with owner attributes,e.g. who owns a turret
	SHARE: {
		next;
		my $share = XML::LibXML::Element->new( 'ShareMode' );
		$share->appendText( $p->{ShareMode} || 'None' );
		$this_block->addChild( $share );
	}

	#This could get *really* interesting
	DEFORMATION: {
		next;
		my $deform = XML::LibXML::Element->new( 'DeformationRatio' );
		$deform->appendText( '0' );
		$this_block->addChild( $deform );
	}
	return $this_block;
}


sub set_position { 
	my ($self,$this_block,$p) = @_;

	for ( qw/x y z / ) {
		confess "Missing element [$_]" unless defined($p->{$_});
	}
	
	my $min = XML::LibXML::Element->new( 'Min' );
	for ( qw/x y z/ ) {
		$min->setAttribute( $_, $p->{$_} );
	}
	$this_block->addChild( $min );
	return $this_block;

}


sub set_orientation { 

	my ($self,$this_block,$p) = @_;
	$p ||= {};
	my $orientation = XML::LibXML::Element->new( 'BlockOrientation' );
	
	$orientation->setAttribute( 'Forward', $p->{Forward} || 'Forward' );
	$orientation->setAttribute( 'Up',      $p->{Up}      || 'Up' );
	$this_block->addChild( $orientation );
	return $this_block;

}

sub set_colour { 
	my ($self,$this_block,$colour_proto) = @_;
	my $this_colour = $colour_proto->cloneNode(1);
	$this_block->addChild( $this_colour );
}

# because colour order matters and has to come after position ?!!?!
sub get_colour_proto { 
	my ($self,$p) = @_;

	my $colour_block = XML::LibXML::Element->new( 'ColorMaskHSV' );

	# TODO re-find how to pass a hash slice in key order
	my ( $h, $s, $v ) = $self->rgb_to_hsv( $p->{r}, $p->{g}, $p->{b} );

	#yes really, xyz
	$colour_block->setAttribute( 'x', substr($h || 0,undef,4) );
	$colour_block->setAttribute( 'y', substr($s|| 0,undef,4) );
	$colour_block->setAttribute( 'z', substr($v|| 0,undef,4 ));
	return $colour_block;
	
}

sub rgb_to_hsv {
	my ( $self, $r, $g, $b ) = @_;

	# TODO cache ?
	require Convert::Color;
	my $color = Convert::Color->new( sprintf( 'rgb8:%s,%s,%s', $r, $g, $b ) );
	my ( $h, $s, $v ) = $color->as_hsv->hsv() or die $!;
	warn "$h, $s, $v becoming";
	$h = $h / 360;       # hue in SE is percentage of 360 apparently
	$s = ( $s * 2 ) - 1; # and we think that saturation is on a -1 to 1 scale
	warn "\t$h, $s, $v";
	return ( $h, $s, $v );

}

sub render_xml {
	my ( $self, $xml_obj ) = @_;
	XML::LibXML::PrettyPrint->new( indent_string => '', new_line => '' )->pretty_print( $xml_obj );

}



=head3 render_in_template
	because spending time with XML is not a fun Saturday - but this probably should get converted
=cut

sub render_in_template {
	my ( $self, $p ) = @_;
	confess "Can't do anything without a grid_string parameter" unless $p->{grid_string};
	my $ep = {%{$p}};
	$ep->{name}         ||= 'Generated Blueprint';
	$ep->{owner_name}   ||= 'Not Applicable';
	$ep->{EntityId}     ||= int( rand( 148783961165331809 ) );
	$ep->{OwnerSteamId} ||= 77777777777777777;

	my $string = qq#<?xml version="1.0"?>
<Definitions xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<ShipBlueprints>
		<ShipBlueprint>
			<Id Type="MyObjectBuilder_ShipBlueprintDefinition" Subtype="$ep->{name}" />

			<DisplayName>$ep->{owner_name}</DisplayName>
			<CubeGrids>
				<CubeGrid>
					<EntityId>$ep->{EntityId}</EntityId>
					<PersistentFlags>CastShadows InScene</PersistentFlags>
          <PositionAndOrientation>
            <Position x="0" y="0" z="0" />
            <Forward x="-0" y="-0" z="-1" />
            <Up x="0" y="1" z="0" />
            <Orientation>
              <X>0</X>
              <Y>0</Y>
              <Z>0</Z>
              <W>1</W>
            </Orientation>
          </PositionAndOrientation>
					<GridSizeEnum>Large</GridSizeEnum>
						$p->{grid_string}
					<DisplayName>$ep->{name}</DisplayName>
          <DestructibleBlocks>true</DestructibleBlocks>
          <CreatePhysics>false</CreatePhysics>
          <EnableSmallToLargeConnections>false</EnableSmallToLargeConnections>
          <IsRespawnGrid>false</IsRespawnGrid>
          <LocalCoordSys>0</LocalCoordSys>
          <TargetingTargets />
        </CubeGrid>
			</CubeGrids>
			<WorkshopId>0</WorkshopId>
			<OwnerSteamId>$ep->{OwnerSteamId}</OwnerSteamId>
			<Points>0</Points>
		</ShipBlueprint>
	</ShipBlueprints>
</Definitions>#;
	return $string;

}

1;
