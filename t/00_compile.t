use strict;
use Test::More 0.98;

use_ok $_ for qw(
    Amazon::SQS::Worker
    Amazon::SQS::Worker::Role::Common
    Amazon::SQS::Worker::Role::Once
);

done_testing;

