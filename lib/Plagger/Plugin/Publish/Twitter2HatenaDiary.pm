package Plagger::Plugin::Publish::Twitter2HatenaDiary;
use strict;
use base qw( Plagger::Plugin );

use Encode;
#use WWW::HatenaDiary;
use WebService::Hatena::Diary;

use DateTime;
use DateTime::Format::HTTP;
use DateTime::TimeZone;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'plugin.init'      => \&initialize,
#        'publish.init'     => \&publish_init,
        'publish.entry'    => \&publish_entry,
#        'publish.finalize' => \&publish_finalize,
    );
}

sub initialize {
    my($self, $context) = @_;
    my $config = {
        username => $self->conf->{username},
        password => $self->conf->{password},
#        group => $self->conf->{group},
#        mech_opt => {
#            agent => Plagger::UserAgent->new,
#        },
    };
#    $self->{diary} = WWW::HatenaDiary->new($config);
    $self->{diary} = WebService::Hatena::Diary->new($config);
}

#sub publish_init {
#    my($self, $context, $args) = @_;
#    local $@;
#    eval { $self->{diary}->login };
#    if ($@) {
#        $context->log(error => $@);
#        delete $self->{diary};
#    }
#}

sub publish_entry {
    my($self, $context, $args) = @_;
    return unless $self->{diary};
    
    my $entry_title = $args->{entry}->title_text;
    $entry_title =~ s/\r|\n//g;
    $entry_title =~ s/^.+?: //o;
#    $entry_title =~ /^(.+?): (.+)$/o;
    my $post = $entry_title;

    my $date = $args->{entry}->date;
    my $zone = DateTime::TimeZone->new( name => 'GMT' );
    my $dt = DateTime::Format::HTTP->parse_datetime($date, $zone);
    $dt->set_time_zone('Asia/Tokyo');
    my $hh = sprintf("%02d", $dt->hour);
    my $mm = sprintf("%02d", $dt->minute);

    my $time = $hh . ":" . $mm;
    my $link = $args->{entry}->link;
    
    my $title = "[" . $link . ":title=" . $time . "] " . $post;
    $context->log(debug => "$title \n");

#    my $body = $self->templatize('template.tt', $args);
    my $uri = $self->{diary}->create({
        title => encode_utf8( $title ),
        content => "\n",
#        title => encode_utf8( $args->{entry}->title_text ),
#        body  => encode_utf8( $args->{entry}->body_text ),
    });
    $context->log(debug => "Post entry success: $uri");

    my $sleeping_time = $self->conf->{interval} || 3;
    $context->log(info => "sleep $sleeping_time.");
    sleep( $sleeping_time );
}

#sub publish_finalize {
#    my($self, $context, $args) = @_;
#    return unless $self->{diary};
#    $self->{diary}->{login}->logout;
#}

1;
__END__

=head1 NAME

Plagger::Plugin::Publish::Twitter2HatenaDiary - Publish to HatenaDiary from Twitter

=head1 SYNOPSIS

  - module: Publish::Twitter2HatenaDiary
    config:
      username: hatena-id
      password: hatena-password

=head1 DESCRIPTION

This plugin sends feed entries to your Hatena Diary from Twitter RSS.
Future works: split this plugin to Filter::TwitterHatenaDiary and Publish::HatenaDiarySimple

=head1 CONFIG

=over 4

=item username

Hatena username. Required.

=item password

Hatena password. Required.

=item interval

Optional.

=back

=head1 AUTHOR

Kazuhir Osawa (riywo modified)

=head1 SEE ALSO

L<Plagger>, L<WWW::HatenaDiary>

=cut
