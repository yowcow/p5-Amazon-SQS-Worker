package MyWorker::JobFails;
use Moo;
with qw(
    Amazon::SQS::Worker::Role::Common
    Amazon::SQS::Worker::Role::Once
);
use namespace::clean;
use strictures 2;

sub handle_job {
    my ($self, $data) = @_;
    die "Foo bar";
}

package MyWorker::JobOK;
use Moo;
with qw(
    Amazon::SQS::Worker::Role::Common
    Amazon::SQS::Worker::Role::Once
);
use namespace::clean;
use strictures 2;

sub handle_job {
    my ($self, $data) = @_;
    $self->logger->debug("OK");
}

package main;
use strict;
use warnings;
use Test::Mock::Guard;
use Test::More;
use Test::Pretty;

subtest 'Test work_on_message and dies' => sub {
    my $guard = mock_guard(
        'Amazon::SQS::Simple::Queue' => {
            DeleteMessage => sub {
                my ($queue, $receipt_handle) = @_;

                is $receipt_handle, 'my-receipt-handle';
            },
        },
    );

    my $message = Amazon::SQS::Simple::Message->new(
        {   Body          => qq|{"message":"Test"}|,
            MD5OfBody     => 'my-md5-string',
            MessageId     => 'my-message-id',
            ReceiptHandle => 'my-receipt-handle',
        },
    );
    my $w = MyWorker::JobFails->new(
        {   aws_access_key => 'my-access-key',
            aws_secret_key => 'my-secret-key',
            arn            => 'arn:aws:sqs:hoge:user:queue',
        }
    );
    $w->work_on_message($message);

    is $guard->call_count('Amazon::SQS::Simple::Queue' => 'DeleteMessage'), 1;
};

subtest 'Test work_on_message and lives' => sub {
    my $guard = mock_guard(
        'Amazon::SQS::Simple::Queue' => {
            DeleteMessage => sub {
                my ($queue, $receipt_handle) = @_;

                is $receipt_handle, 'my-receipt-handle';
            },
        },
    );

    my $message = Amazon::SQS::Simple::Message->new(
        {   Body          => qq|{"message":"Test"}|,
            MD5OfBody     => 'my-md5-string',
            MessageId     => 'my-message-id',
            ReceiptHandle => 'my-receipt-handle',
        },
    );
    my $w = MyWorker::JobOK->new(
        {   aws_access_key => 'my-access-key',
            aws_secret_key => 'my-secret-key',
            arn            => 'arn:aws:sqs:hoge:user:queue',
        }
    );
    $w->work_on_message($message);

    is $guard->call_count('Amazon::SQS::Simple::Queue' => 'DeleteMessage'), 1;
};

done_testing;
