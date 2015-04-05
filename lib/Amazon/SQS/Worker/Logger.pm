package Amazon::SQS::Worker::Logger;
use strict;
use warnings;

sub debug { print "Debug: $_[1]\n" }
sub info  { print "Info: $_[1]\n" }
sub warn  { print "Warn: $_[1]\n" }
sub error { print "Error: $_[1]\n" }

1;

__END__

=head1 NAME

Amazon::SQS::Worker::Logger - basic logger for workers

=head1 LICENSE

Copyright (C) yowcow.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

yowcow E<lt>yowcow@cpan.org<gt>

=cut

