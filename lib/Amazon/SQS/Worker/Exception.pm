package Amazon::SQS::Worker::Exception;

package Amazon::SQS::Worker::Exception::Common;
use Moo::Role;
use strictures 2;

has message => (is => 'ro', required => 1);
has file    => (is => 'ro', required => 1);
has package => (is => 'ro', required => 1);
has line    => (is => 'ro', required => 1);

sub throw {
    my ($class, $message) = @_;
    my @caller = caller;
    $class->new(
        {   message => $message,
            package => $caller[0],
            file    => $caller[1],
            line    => $caller[2],
        }
    );
}

sub as_string {
    my $self = shift;
    sprintf(
        "%s '%s' in %s at %s(%s)",
        ref($self),
        $self->message,
        $self->package,
        $self->file,
        $self->line,
    );
}

package Amazon::SQS::Worker::Exception::Once;
use Moo;
with 'Amazon::SQS::Worker::Exception::Common';
use namespace::clean;
use strictures 2;
use overload '""' => sub { shift->as_string };

sub do_retry { 0 }

package Amazon::SQS::Worker::Exception::Retry;
use Moo;
with 'Amazon::SQS::Worker::Exception::Common';
use namespace::clean;
use strictures 2;
use overload '""' => sub { shift->as_string };

sub do_retry { 1 }

1;

__END__

=head1 NAME

Amazon::SQS::Worker::Exception - exceptions for workers

=head1 SYNOPSIS

    die Amazon::SQS::Worker::Exception::Once->throw('No retry');

    die Amazon::SQS::Worker::Exception::Retry->throw('Do retry');

=head1 DESCRIPTION

=head1 METHODS

=head2 throw($message)

Creates a new exception instance.

=head2 as_string

Returns detailed exception information.

=head2 do_retry

Returns 0 if not to do retry, or 1 if to do retry.

=head1 LICENSE

Copyright (C) yowcow.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

yowcow E<lt>yowcow@cpan.org<gt>

=cut

