package Amazon::SQS::Worker::Role::Retry;
use Moo::Role;
use strictures 2;

use JSON::XS qw(decode_json);
use POSIX qw(:signal_h);
use Try::Tiny;

sub work_on_message {
    my ($self, $message) = @_;
    my $sigset = POSIX::SigSet->new;

    sigprocmask(SIG_BLOCK, $self->block_sigset, $sigset)
        or die "Could not block signals: $!";

    try {
        $self->handle_job(decode_json($message->MessageBody));
        $self->delete_message($message->ReceiptHandle);
    }
    catch {
        my $exception = $_;

        $self->logger->error("Failed processsing message "
                . $message->ReceiptHandle . ": $exception")
            if $self->logger;

        $self->delete_message($message->ReceiptHandle)
            if ref($exception) and not $exception->do_retry;
    };

    sigprocmask(SIG_SETMASK, $sigset)
        or die "Could not restore signals: $!";
}

1;

__END__

=encoding utf-8

=head1 NAME

Amazon::SQS::Worker::Role::Retry - A behavior to process a message until gone

=head1 SYNOPSIS

In your worker:

    package Your::Worker;
    use Moo;
    with qw(
        Amazon::SQS::Worker::Role::Common
        Amazon::SQS::Worker::Role::Retry
    );

    sub handle_job {
        # For retry,
        die Amazon::SQS::Worker::Exception::Retry->throw('Need retry: ' . $@);

        # For no retry,
        die Amazon::SQS::Worker::Exception::Once->throw('No retry needed: ' . $@);
    }

=head1 DESCRIPTION

Amazon::SQS::Worker::Role::Retry provices a behavior to process a message from Amazon SQS until gone.

=head1 METHODS

=head2 work_on_message

Accepts a L<Amazon::SQS::Simple::Message> object and calls C<handle_job> while blocking signals.
This method does not delete a message when C<handle_job> throws C<Amazon::SQS::Worker::Exception::Retry>.
A message will be deleted from Amazon SQS when C<handle_job> finishes without exception,
or C<Amazon::SQS::Worker::Exception::Once> is thrown.

=head1 LICENSE

Copyright (C) yowcow.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

yowcow E<lt>yowcow@cpan.org<gt>

=cut

