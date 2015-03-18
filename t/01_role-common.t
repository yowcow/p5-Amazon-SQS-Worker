package MyWorker;
use Moo;
with 'Amazon::SQS::Worker::Role::Common';
use namespace::clean;


package main;
use strict;
use warnings;
use Test::Mock::Guard;
use Test::More;
use Test::Pretty;
use t::lib::MyLogger;

no warnings 'once';
$Amazon::SQS::Worker::DEBUG = 1;

subtest 'Test accessors' => sub {
    my $w = MyWorker->new(
        {   aws_access_key => 'my-access-key',
            aws_secret_key => 'my-secret-key',
            arn            => 'arn:aws:sqs:hoge:user:queue',
        }
    );

    isa_ok $w->client, 'Amazon::SQS::Simple';
    isa_ok $w->queue,  'Amazon::SQS::Simple::Queue';
    isa_ok $w->block_sigset, 'POSIX::SigSet';
};

subtest 'Test fetch_messages' => sub {
    my $guard = mock_guard(
        'Amazon::SQS::Simple::Queue' => {
            ReceiveMessage => sub {
                my ($queue, %args) = @_;

                is_deeply \%args,
                    {
                    WaitTimeSeconds     => 20,
                    MaxNumberOfMessages => 10,
                    };
            },
        },
    );

    MyWorker->new(
        {   aws_access_key => 'my-access-key',
            aws_secret_key => 'my-secret-key',
            arn            => 'arn:aws:sqs:hoge:user:queue',
            logger         => t::lib::MyLogger->new,
        }
    )->fetch_messages;

    is $guard->call_count('Amazon::SQS::Simple::Queue' => 'ReceiveMessage'),
        1;
};

subtest 'Test delete_message' => sub {
    my $guard = mock_guard(
        'Amazon::SQS::Simple::Queue' => {
            DeleteMessage => sub {
                my ($queue, $rh) = @_;

                is $rh, 'hogehoge-handle';
            },
        },
    );

    MyWorker->new(
        {   aws_access_key => 'my-access-key',
            aws_secret_key => 'my-secret-key',
            arn            => 'arn:aws:sqs:hoge:user:queue',
            logger         => t::lib::MyLogger->new,
        }
    )->delete_message('hogehoge-handle');

    is $guard->call_count('Amazon::SQS::Simple::Queue' => 'DeleteMessage'), 1;
};

subtest 'Test send_message' => sub {
    my $guard = mock_guard(
        'Amazon::SQS::Simple::Queue' => {
            SendMessage => sub {
                my ($queue, $data) = @_;

                is $data, q|["hogehoge"]|;
            },
        },
    );

    MyWorker->new(
        {   aws_access_key => 'my-access-key',
            aws_secret_key => 'my-secret-key',
            arn            => 'arn:aws:sqs:hoge:user:queue',
            logger         => t::lib::MyLogger->new,
        }
    )->send_message([qw(hogehoge)]);

    is $guard->call_count('Amazon::SQS::Simple::Queue' => 'SendMessage'), 1;
};

done_testing;
