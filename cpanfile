requires 'perl', '5.008001';
requires 'namespace::clean';
requires 'strictures' => 2;
requires 'Amazon::SQS::Simple';
requires 'Exporter';
requires 'JSON::XS';
requires 'Log::Minimal';
requires 'Moo';
requires 'Try::Tiny';

on 'test' => sub {
    requires 'Test::Deep';
    requires 'Test::Exception';
    requires 'Test::Mock::Guard';
    requires 'Test::More', '0.98';
    requires 'Test::Pretty';
};

