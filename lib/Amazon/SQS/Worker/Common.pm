package Amazon::SQS::Worker::Common;
use Moo::Role;
use strictures 2;

use Amazon::SQS::Simple;
use JSON::XS qw(encode_json);
use POSIX qw(:signal_h);

has aws_access_key => (is => 'ro', required => 1);
has aws_secret_key => (is => 'ro', required => 1);
has arn            => (is => 'ro', required => 1);
has client         => (
    is      => 'rw',
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
    default => sub { },
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
        if is_debug() and $self->logger;

    $self->queue->ReceiveMessage(
        WaitTimeSeconds     => $self->wait_time_seconds,
        MaxNumberOfMessages => $self->max_messages,
    );
}

sub delete_message {
    my ($self, $receipt_handle) = @_;

    $self->logger->debug("Deleting a message: $receipt_handle")
        if is_debug() and $self->logger;

    $self->queue->DeleteMessage($receipt_handle);
}

sub send_message {
    my ($self, $data) = @_;

    $self->logger->debug('Sending a message...')
        if is_debug() and $self->logger;

    $self->queue->SendMessage(encode_json($data));
}

sub work {
    my $self  = shift;
    my $class = ref($self);

    $self->logger->debug("Hello, $class is starting up to work now")
        if is_debug() and $self->logger;

    while (1) {
        my @messages = $self->fetch_messages;

        $self->logger->debug('Got ' . scalar(@messages) . ' message(s).')
            if is_debug() and $self->logger;

        $self->work_on_message($_) for @messages;

        sleep($self->work_interval) if $self->work_interval;
    }
}

1;
