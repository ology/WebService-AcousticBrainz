package WebService::AcousticBrainz;

# ABSTRACT: Access to the AcousticBrainz API

our $VERSION = '0.0602';

use strictures 2;
use Carp qw(croak);
use Mojo::UserAgent ();
use Mojo::JSON qw(decode_json);
use Mojo::URL ();
use Moo;
use Try::Tiny;
use namespace::clean;

=head1 SYNOPSIS

  use WebService::AcousticBrainz;

  my $w = WebService::AcousticBrainz->new;

  my $r = $w->fetch(
    mbid     => 'c51f788f-f2ac-4d4e-aa72-205f002b8752',
    endpoint => 'low-level',
    query    => { n => 2 }, # optional
  );

=head1 DESCRIPTION

C<WebService::AcousticBrainz> provides access to the L<https://acousticbrainz.org/data> API.

=head1 ATTRIBUTES

=head2 base

The base URL.  Default: https://acousticbrainz.org

=cut

has base => (
    is      => 'rw',
    default => sub { 'https://acousticbrainz.org' },
);

=head2 ua

The user agent.

=cut

has ua => (
    is      => 'rw',
    default => sub { Mojo::UserAgent->new() },
);

=head1 METHODS

=head2 new

  $w = WebService::AcousticBrainz->new;

Create a new C<WebService::AcousticBrainz> object.

=head2 fetch

  $r = $w->fetch(%arguments);

Fetch the results given a B<mbid> (MusicBrainz recording ID), B<endpoint> and
optional B<query> arguments.

=cut

sub fetch {
    my ( $self, %args ) = @_;

    croak 'No mbid provided' unless $args{mbid};
    croak 'No endpoint provided' unless $args{endpoint};

    my $url = Mojo::URL->new($self->base)
        ->path('/api/v1/' . $args{mbid} . '/'. $args{endpoint});
    $url->query(%{ $args{query} }) if $args{query};

    my $tx = $self->ua->get($url);

    my $data = _handle_response($tx);

    return $data;
}

sub _handle_response {
    my ($tx) = @_;

    my $data;

    my $res = $tx->result;

    if ( $res->is_success ) {
        my $body = $res->body;
        try {
            $data = decode_json($body);
        }
        catch {
            croak $body, "\n";
        };
    }
    else {
        croak "Connection error: ", $res->message;
    }

    return $data;
}

1;
__END__

=head1 SEE ALSO

The F<t/*> tests

The F<eg/*> programs

L<https://acousticbrainz.org/data>

L<https://acousticbrainz.readthedocs.io/api.html>

L<Moo>

L<Mojo::UserAgent>

L<Mojo::JSON>

L<Try::Tiny>

=cut
