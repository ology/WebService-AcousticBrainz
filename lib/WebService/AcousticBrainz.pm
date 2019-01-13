package WebService::AcousticBrainz;

# ABSTRACT: Access to the AcousticBrainz API

our $VERSION = '0.0300';

use Moo;
use strictures 2;
use namespace::clean;

use Carp;
use Mojo::UserAgent;
use Mojo::JSON::MaybeXS;
use Mojo::JSON qw( decode_json );
use Mojo::URL;

=head1 SYNOPSIS

  use WebService::AcousticBrainz;
  my $w = WebService::AcousticBrainz->new;
  my $r = $w->fetch(
    mbid     => '96685213-a25c-4678-9a13-abd9ec81cf35',
    endpoint => 'low-level',
    query    => { n => 2 },
  );

=head1 DESCRIPTION

C<WebService::AcousticBrainz> provides access to the L<https://acousticbrainz.org/data> API.

=head1 ATTRIBUTES

=head2 base

The base URL.  Default: https://acousticbrainz.org/api/v1

=cut

has base => (
    is      => 'rw',
    default => sub { Mojo::URL->new('https://acousticbrainz.org/api/v1') },
);

=head2 ua
 
The user agent.
=cut

has ua => (
    is      => 'rw',
    default => sub { Mojo::UserAgent->new() },
);

=head1 METHODS

=head2 new()

  $x = WebService::AcousticBrainz->new;

Create a new C<WebService::AcousticBrainz> object.

=head2 fetch()

  $r = $w->fetch(%arguments);

Fetch the results given the B<mbid> (MusicBrainz ID), B<endpoint> and optional
B<query> arguments.

=cut

sub fetch {
    my ( $self, %args ) = @_;

    my $query;
    if ( $args{query} ) {
        $query = join '&', map { "$_=$args{query}->{$_}" } keys %{ $args{query} };
    }

    my $url = $self->base . '/'. $args{mbid} . '/'. $args{endpoint};
    $url .= '?' . $query
        if $query;
warn(__PACKAGE__,' ',__LINE__," MARK: ",$url,"\n");

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
        if ( $body =~ /{/ ) {
            $data = decode_json( $res->body );
        }
        else {
            croak $body, "\n";
        }
    }
    else {
        croak "Connection error: ", $res->message;
    }

    return $data;
}

1;
__END__

=head1 SEE ALSO

L<Moo>

L<Mojo::UserAgent>

L<Mojo::JSON>

L<Mojo::JSON::MaybeXS>

L<https://acousticbrainz.org/data>

=cut
