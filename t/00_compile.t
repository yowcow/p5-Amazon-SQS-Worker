use strict;
use Test::More 0.98;

use_ok $_ for qw(
    Amazon::SQS::Worker
    Amazon::SQS::Worker::Common
    Amazon::SQS::Worker::Once
);

done_testing;

