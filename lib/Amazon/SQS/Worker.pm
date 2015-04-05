package Amazon::SQS::Worker;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

our $DEBUG = 0;


1;
__END__

=encoding utf-8

=head1 NAME

Amazon::SQS::Worker - Worker for Amazon SQS

=head1 SYNOPSIS

Define you worker:

    package Your::Worker;
    use Moo;
    with qw(
        Amazon::SQS::Worker::Role::Common
        Amazon::SQS::Worker::Role::Retry
    );
    use namespace::clean;
    use strictures => 2;
    use Amazon::SQS::Worker::Exception;

    sub BUILD {
        my $self = shift;
        $self->aws_access_key('your-aws-access-key');
        $self->aws_secret_key('your-aws-secret-key');
        $self->arn('your-arn');
    }

    # Handle a message
    sub handle_job {
        my ($self, $message) = @_;

        # For failure that requires a retry
        die Amazon::SQS::Worker::Exception::Retry->throw('A failure has occurred');

        # For failure that doesn't require a retry
        die Amazon::SQS::Worker::Exception::Once->throw('A failure has occurred');
    }

=head1 DESCRIPTION

Amazon::SQS::Worker provides behaviors to run workers that use Amazon SQS as a job queue.

=head1 SEE ALSO

L<Amazon::SQS::Worker::Exception>
L<Amazon::SQS::Worker::Logger>
L<Amazon::SQS::Worker::Role::Common>
L<Amazon::SQS::Worker::Role::Once>
L<Amazon::SQS::Worker::Role::Retry>

=head1 LICENSE

Copyright (C) yowcow.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

yowcow E<lt>yowcow@cpan.org<gt>

=cut

