package t::lib::MyLogger;
use Moo;

sub debug { print "Debug: $_[1]\n" }
sub error { print "Error: $_[1]\n" }

1;
