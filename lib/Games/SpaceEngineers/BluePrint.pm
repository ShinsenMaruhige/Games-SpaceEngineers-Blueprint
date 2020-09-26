package Games::SpaceEngineers::BluePrint;
our $VERSION = '0.04';

##~ DIGEST : 6ed83702a662dc7a597c893f4dcb00ab

use Moo;

sub add_cube {
	my ( $self, $x, $y, $z, $rgb ) = @_;
	my $cube = XML::LibXML::Element->new( 'MyObjectBuilder_CubeBlock' );
	$cube->setAttribute( 'xsi:type', 'MyObjectBuilder_CubeBlock' );

	my $subtype = XML::LibXML::Element->new( 'SubtypeName' );
	$subtype->appendText( Meese::SpaceEngineers::Blueprint::SQL::get_unless_got( $m, $$rgb[0], $$rgb[1], $$rgb[2] ) );
	$cube->addChild( $subtype );

	my $min = XML::LibXML::Element->new( 'Min' );
	$min->setAttribute( 'x', $x );
	$min->setAttribute( 'y', $y );
	$min->setAttribute( 'z', $z );
	$cube->addChild( $min );

	my $orientation = XML::LibXML::Element->new( 'BlockOrientation' );
	$orientation->setAttribute( 'Forward', 'Forward' );
	$orientation->setAttribute( 'Up',      'Up' );
	$cube->addChild( $orientation );

	my $colour = XML::LibXML::Element->new( 'ColorMaskHSV' );

	my ( $h, $s, $v ) = Meese::SpaceEngineers::Img::rgb_to_hsv( $rgb );
	$colour->setAttribute( 'x', $h );
	$colour->setAttribute( 'y', $s );
	$colour->setAttribute( 'z', $v );
	$cube->addChild( $colour );

	my $share = XML::LibXML::Element->new( 'ShareMode' );
	$share->appendText( 'None' );
	$cube->addChild( $share );

	my $deform = XML::LibXML::Element->new( 'DeformationRatio' );
	$deform->appendText( '0' );
	$cube->addChild( $deform );
	return $cube;
}
