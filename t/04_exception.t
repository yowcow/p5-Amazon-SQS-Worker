use strict;
use warnings;
use Test::More;
use Test::Pretty;
use Amazon::SQS::Worker::Exception;

subtest 'Test A::S::W::Exception::Once' => sub {
    my $e = Amazon::SQS::Worker::Exception::Once->throw('Hoge');

    is $e->message, 'Hoge';
    is $e->file, __FILE__;
    is $e->package, 'main';
    like $e->line, qr|^\d+$|;
    like $e->as_string, qr|Amazon::SQS::Worker::Exception::Once was thrown|;
    ok !$e->do_retry;
    is "$e", $e->as_string;
};

subtest 'Test A::S::W::Exception::Retry' => sub {
    my $e = Amazon::SQS::Worker::Exception::Retry->throw('Hoge');

    is $e->message, 'Hoge';
    is $e->file, __FILE__;
    is $e->package, 'main';
    like $e->line, qr|^\d+$|;
    like $e->as_string, qr|Amazon::SQS::Worker::Exception::Retry was thrown|;
    ok $e->do_retry;
    is "$e", $e->as_string;
};

done_testing;
