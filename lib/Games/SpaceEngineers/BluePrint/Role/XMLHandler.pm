package Games::SpaceEngineers::BluePrint::Role::XMLHandler;
our $VERSION = '0.02';

##~ DIGEST : ff5b2c58f984d755d90bb5ecef41f588
# ABSTRACT: Moose role for constructing SE blueprint XML using XML::LibXML with guard rails
use Moo::Role;
use Carp qw/confess/;
use Convert::Colour;

sub get_xml_component {
	my ( $self, $p ) = @_;
	my $eparams = {%{$p}};
	for ( qw/x y z SubtypeName/ ) {
		confess "Missing element [$_]" unless $eparams->{$_};
	}

	# 'The Thing'
	my $grid_def = XML::LibXML::Element->new( 'MyObjectBuilder_CubeBlock' );
	$subtype->appendText( $p->{SubtypeName} );

	#The actual block type, e.g. heavy armor, refinery etc
	my $component = XML::LibXML::Element->new( 'SubtypeName' );

	$grid_def->setAttribute( 'xsi:type', 'MyObjectBuilder_CubeBlock' );

	POSITION: {
		my $min = XML::LibXML::Element->new( 'Min' );
		for ( qw/x y z/ ) {
			$min->setAttribute( $_, $p->{$_} );
		}
		$grid_def->addChild( $min );
	}

	ORIENTATION: {

		my $orientation = XML::LibXML::Element->new( 'BlockOrientation' );
		$orientation->setAttribute( 'Forward', $eparams->{Forward} || 'Forward' );
		$orientation->setAttribute( 'Up',      $eparams->{Up}      || 'Up' );
		$grid_def->addChild( $orientation );
	}

	COLOUR: {
		my $colour = XML::LibXML::Element->new( 'ColorMaskHSV' );

		# TODO re-find how to pass a hash slice in key order
		my ( $h, $s, $v ) = Meese::SpaceEngineers::Img::rgb_to_hsv( $p->{r}, $p->{g}, $p->{b} );

		#yes really, xyz
		$colour->setAttribute( 'x', $h );
		$colour->setAttribute( 'y', $s );
		$colour->setAttribute( 'z', $v );
		$grid_def->addChild( $colour );
	}

	#Wild mass guessing suggests this is to do with owner attributes,e.g. who owns a turret
	SHARE: {
		my $share = XML::LibXML::Element->new( 'ShareMode' );
		$share->appendText( $p->{ShareMode} || 'None' );
		$grid_def->addChild( $share );
	}

	#This could get *really* interesting
	DEFORMATION: {
		my $deform = XML::LibXML::Element->new( 'DeformationRatio' );
		$deform->appendText( '0' );
		$grid_def->addChild( $deform );
	}
	return $grid_def;
}

sub rgb_to_hsv {
	my ( $self, $r, $g, $b ) = @_;

	# TODO cache ?
	my $color = Convert::Color->new( sprintf( 'rgb8:%s,%s,%s', $r, $g, $b ) );
	my ( $h, $s, $v ) = $color->as_hsv->hsv() or die $!;
	$h = $h / 360; # hue in SE is percentage of 360 apparently
	return ( $h, $s, $v );

}

sub render_xml {
	my ( $self, $xml_obj ) = @_;
	XML::LibXML::PrettyPrint->new( indent_string => "", new_line => '' )->pretty_print( $xml_obj );

}

=head3 render_in_template
	because spending time with XML is not a fun Saturday - but this probably should get converted
=cut

sub render_in_template {
	my ( $self, $p ) = @_;
	confess "Can't do anything without a grid parameter" unless $p->{grid};
	my $ep = {%{$p}};
	$ep->{name}         ||= 'Generated Blueprint';
	$ep->{owner_name}   ||= 'Not Applicable';
	$ep->{EntityId}     ||= int( rand( 148783961165331809 ) );
	$ep->{OwnerSteamId} ||= 77777777777777777;

	my $string = qq#<?xml version="1.0"?>
<Definitions xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<ShipBlueprints>
		<ShipBlueprint>
			<Id>
				<TypeId>MyObjectBuilder_ShipBlueprintDefinition</TypeId>
				<SubtypeId>$ep->{name}</SubtypeId>
			</Id>
			<DisplayName>$ep->{owner_name}</DisplayName>
			<CubeGrids>
				<CubeGrid>
					<EntityId>$ep->{EntityId}</EntityId>
					<PersistentFlags>CastShadows InScene</PersistentFlags>
					<PositionAndOrientation>
						<Position x="14.898984909057617" y="2.6750001907348633" z="-11.799983978271484" />
						<Forward x="1" y="-0" z="-0" />
						<Up x="0" y="1" z="0" />
					</PositionAndOrientation>
					<GridSizeEnum>Large</GridSizeEnum>
					<CubeBlocks>
						$p->{grid}
					</CubeBlocks>
					<DisplayName>$ep->{name}</DisplayName>
					<DestructibleBlocks>true</DestructibleBlocks>
					<CreatePhysics>false</CreatePhysics>
					<EnableSmallToLargeConnections>false</EnableSmallToLargeConnections>
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
