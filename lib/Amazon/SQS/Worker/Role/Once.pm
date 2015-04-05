package Amazon::SQS::Worker::Role::Once;
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
        $self->delete_message($message->ReceiptHandle);
        $self->handle_job(decode_json($message->MessageBody));
    }
    catch {
        $self->logger->error("Failed processsing a message "
                . $message->ReceiptHandle . ": $_")
            if $self->logger;
    };

    sigprocmask(SIG_SETMASK, $sigset)
        or die "Could not restore signals: $!";
}

1;

__END__

=encoding utf-8

=head1 NAME

Amazon::SQS::Worker::Role::Once - A behavior to process a message only once

=head1 SYNOPSIS

In your worker:

    package Your::Worker;
    use Moo;
    with qw(
        Amazon::SQS::Worker::Role::Common
        Amazon::SQS::Worker::Role::Once
    );

    sub handle_job { ... }

=head1 DESCRIPTION

Amazon::SQS::Worker::Role::Once provices a behavior to process a message from Amazon SQS only once, not more than once.

=head1 METHODS

=head2 work_on_message

Accepts a L<Amazon::SQS::Simple::Message> object and calls C<handle_job> while blocking signals.

=head1 LICENSE

Copyright (C) yowcow.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

yowcow E<lt>yowcow@cpan.org<gt>

=cut

