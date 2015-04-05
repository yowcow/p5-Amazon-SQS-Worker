package Amazon::SQS::Worker::Role::Common;
use Moo::Role;
use strictures 2;

use Amazon::SQS::Simple;
use Amazon::SQS::Worker;
use Amazon::SQS::Worker::Logger;
use JSON::XS qw(encode_json);
use POSIX qw(:signal_h);

has aws_access_key => (is => 'rw');
has aws_secret_key => (is => 'rw');
has arn            => (is => 'rw');
has client         => (
    is      => 'lazy',
    default => sub {
        my $self = shift;
        Amazon::SQS::Simple->new($self->aws_access_key,
            $self->aws_secret_key);
    },
);
has block_sigset => (
    is      => 'rw',
    default => sub { POSIX::SigSet->new(SIGHUP, SIGINT, SIGQUIT, SIGCHLD) },
);
has logger => (
    is      => 'rw',
    default => sub { 'Amazon::SQS::Worker::Logger' },
);
has wait_interval => (
    is      => 'rw',
    default => sub { 10 },
);
has wait_time_seconds => (
    is      => 'rw',
    default => sub { 20 },
);
has max_messages => (
    is      => 'rw',
    default => sub { 10 },
);

sub is_debug { $Amazon::SQS::Worker::DEBUG }

sub queue {
    my $self = shift;
    $self->client->GetQueue($self->arn);
}

sub fetch_messages {
    my $self = shift;

    $self->logger->debug('Fetching messages...')
        if is_debug()
        and $self->logger;

    $self->queue->ReceiveMessage(
        WaitTimeSeconds     => $self->wait_time_seconds,
        MaxNumberOfMessages => $self->max_messages,
    );
}

sub delete_message {
    my ($self, $receipt_handle) = @_;

    $self->logger->debug("Deleting a message: $receipt_handle")
        if is_debug()
        and $self->logger;

    $self->queue->DeleteMessage($receipt_handle);
}

sub send_message {
    my ($self, $data) = @_;

    $self->logger->debug('Sending a message...')
        if is_debug()
        and $self->logger;

    $self->queue->SendMessage(encode_json($data));
}

sub work {
    my $self  = shift;
    my $class = ref($self);

    $self->logger->debug("Hello, $class is starting up to work now")
        if is_debug()
        and $self->logger;

    while (1) {
        my @messages = $self->fetch_messages;

        $self->logger->debug('Got ' . scalar(@messages) . ' message(s).')
            if is_debug()
            and $self->logger;

        $self->work_on_message($_) for @messages;

        sleep($self->work_interval) if $self->work_interval;
    }
}

1;

__END__

=head1 NAME

Amazon::SQS::Worker::Role::Common - common behaviors

=head1 SYNOPSIS

In your worker:

    package Your::Worker;
    use Moo;
    with qw(
        Amazon::SQS::Worker::Role::Common
    );

=head1 DESCRIPTION

Amazon::SQS::Worker::Role::Common provides common behaviors for workers.

=head1 ACCESSORS

=head2 aws_access_key

Your AWS access key

=head2 aws_secret_key

Your AWS secret key

=head2 arn

Your ARN

=head2 client

A L<Amazon::SQS::Simple> object.

=head2 block_sigset

A L<POSIX::SigSet> object.

=head2 logger

A logger object, default L<Amazon::SQS::Simple::Logger>.

=head2 wait_interval

A number of seconds to wait per Amazon SQS call to fetch messages.

=head2 wait_time_seconds

A number of seconds to keep long-polling request connected.

=head2 max_messages

Max. number of messages to fetch per call.

=head1 METHODS

=head2 queue

Creates a L<Amazon::SQS::Simple::Queue> object.

=head2 fetch_messages

Fetches messages from Amazon SQS via L<Amazon::SQS::Simple::Queue> object.

=head2 delete_message($receipt_handle)

Deletes a message on Amazon SQS by receipt handle.

=head2 send_message

Stores given message on Amazon SQS in JSON format.

=head2 work

Run a loop to watch Amazon SQS for a message, and calls C<work_on_message> for each fetched message.

=head2 is_debug

Returns C<$Amazon::SQS::Worker::BEBUG>.

=head1 LICENSE

Copyright (C) yowcow.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

yowcow E<lt>yowcow@cpan.org<gt>

=cut

