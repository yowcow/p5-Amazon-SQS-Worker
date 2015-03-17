package Amazon::SQS::Worker::Once;
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
        $self->logger->error("Failed processsing a message " . $message->ReceiptHandle . ": $_")
            if $self->logger;
    };

    sigprocmask(SIG_SETMASK, $sigset)
        or die "Could not restore signals: $!";
}

1;
