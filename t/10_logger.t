use strict;
use warnings;
use Test::More;
use Test::Pretty;
use Amazon::SQS::Worker::Logger;

can_ok 'Amazon::SQS::Worker::Logger', 'debug';
can_ok 'Amazon::SQS::Worker::Logger', 'info';
can_ok 'Amazon::SQS::Worker::Logger', 'warn';
can_ok 'Amazon::SQS::Worker::Logger', 'error';

done_testing;
