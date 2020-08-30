use strict;
use warnings;
use Data::Cartesian::3D::Class::SQLite;
use Data::Cartesian::3D::Class::FileHandler::GDImage;
use Data::Cartesian::3D::Class::FileHandler::SpaceEngineersBlueprint;
use Data::Dumper;
main(@ARGV);

sub main {

    my ( $img_path, $blueprint_path ) = @_;
    my $start   = int(time);
    my $db_path = './etc/template.sqlite' . int(time);
    `cp ./etc/template.sqlite $db_path`;
    my $dc3 = Data::Cartesian::3D::Class::SQLite->new( { dbfile => $db_path } );
  IMG: {
        my $dc3i = Data::Cartesian::3D::Class::FileHandler::GDImage->new(
            { dc3 => $dc3 } );
        $dc3i->read($img_path);
        $dc3->done();
    }
  TRANSFORM: {
    }
  BLUEPRINT: {
        my $dc3i =
          Data::Cartesian::3D::Class::FileHandler::SpaceEngineersBlueprint
          ->new( { dc3 => $dc3 } );
        $dc3i->write($blueprint_path);
        $dc3->done();
    }
    print "took " . ( int(time) - $start ) . " seconds $/";

}
