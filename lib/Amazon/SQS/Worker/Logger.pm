package Amazon::SQS::Worker::Logger;
use strict;
use warnings;

sub debug { print "Debug: $_[1]\n" }
sub info  { print "Info: $_[1]\n" }
sub warn  { print "Warn: $_[1]\n" }
sub error { print "Error: $_[1]\n" }

1;
