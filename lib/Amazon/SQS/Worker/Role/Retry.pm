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
