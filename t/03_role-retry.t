package MyWorker::FailWithRetry;
use Moo;
with qw(
    Amazon::SQS::Worker::Role::Common
    Amazon::SQS::Worker::Role::Retry
);
use strictures 2;
use namespace::clean;
use Amazon::SQS::Worker::Exception;

sub handle_job {
    die Amazon::SQS::Worker::Exception::Retry->throw('Hoge');
}

package MyWorker::FailWithNoRetry;
use Moo;
with qw(
    Amazon::SQS::Worker::Role::Common
    Amazon::SQS::Worker::Role::Retry
);
use strictures 2;
use namespace::clean;
use Amazon::SQS::Worker::Exception;

sub handle_job {
    die Amazon::SQS::Worker::Exception::Once->throw('Fuga');
}

package main;
use strict;
use warnings;
use Carp ();
use Test::Mock::Guard;
use Test::More;
use Test::Pretty;

subtest 'Test work_on_message and dies with retry' => sub {
    my $guard = mock_guard(
        'Amazon::SQS::Simple::Queue' => {
            DeleteMessage => sub {
                my ($queue, $receipt_handle) = @_;

                Carp::croak 'Message should not be deleted';
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
    my $w = MyWorker::FailWithRetry->new(
        {   aws_access_key => 'my-access-key',
            aws_secret_key => 'my-secret-key',
            arn            => 'arn:aws:sqs:hoge:user:queue',
        }
    );
    $w->work_on_message($message);

    is $guard->call_count('Amazon::SQS::Simple::Queue' => 'DeleteMessage'), 0;
};

subtest 'Test work_on_message and dies with no-retry' => sub {
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
    my $w = MyWorker::FailWithNoRetry->new(
        {   aws_access_key => 'my-access-key',
            aws_secret_key => 'my-secret-key',
            arn            => 'arn:aws:sqs:hoge:user:queue',
        }
    );
    $w->work_on_message($message);

    is $guard->call_count('Amazon::SQS::Simple::Queue' => 'DeleteMessage'), 1;
};

done_testing;
