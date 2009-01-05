package Plagger::Plugin::Publish::Tumblr;
use strict;
use base qw( Plagger::Plugin );

use Encode;
use Time::HiRes qw(sleep);
use WWW::Tumblr;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'publish.entry' => \&publish_entry,
        'plugin.init'   => \&initialize,
    );
}

sub initialize {
    my($self, $context) = @_;

    $self->{tumblr} = WWW::Tumblr->new;
    $self->{tumblr}->email($self->conf->{username});
    $self->{tumblr}->password($self->conf->{password});
}

sub publish_entry {
    my($self, $context, $args) = @_;
    
    my $title = $args->{entry}->{title};
    $title = encode_utf8($title);
    my $body = $args->{entry}->{body};
    $body = encode_utf8($body);
    my $link = $args->{entry}->{link};
    
    my $type = $self->conf->{type} || 'regular';
    
    $context->log(info => "Tumblr($type) posting '$title'");
    if($type eq 'text'){
        my $post = $body . "<div><a href=\"" . $link . "\">" . $title . "</a></div>";
        $self->{tumblr}->write(
            type => 'regular',
            title => $title,
            body => $post,
            );
    }
    elsif($type eq 'quote'){
        my $source = "<a href=\"" . $link . "\">" . $title . "</a>";
        $self->{tumblr}->write(
            type => 'quote',
            quote => $body,
            source => $source,
            );
    }
    elsif($type eq 'link'){
        $self->{tumblr}->write(
            type => 'link',
            name => $title,
            url => $link,
            description => $body,
            );
    }
    
    my $sleeping_time = $self->conf->{interval} || 5;
    $context->log(info => "sleep $sleeping_time.");
    sleep( $sleeping_time );
}

1;
