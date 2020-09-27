use inc::Module::Install;

# Define metadata
name 'Games-SpaceEngineers-Blueprint';
all_from 'lib/Games/SpaceEngineers/BluePrint.pm';

# Specific dependencies
requires 'XML::LibXML';
requires 'XML::LibXML::PrettyPrint';
requires 'Convert::Color';

WriteMakefile();
