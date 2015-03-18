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
    ref($self)
        . ' was thrown in '
        . $self->package . ' at '
        . $self->file
        . ' line '
        . $self->line . ': "'
        . $self->message . '"';
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
