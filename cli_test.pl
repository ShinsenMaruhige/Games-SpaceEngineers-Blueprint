
use Moo::GenericRoleClass::CLI;
main();

sub main {
	my $cli = Moo::GenericRoleClass::CLI->new();
	my $c   = $cli->get_config( [qw/ infile mapfile action /] );
	die "yes";

}
