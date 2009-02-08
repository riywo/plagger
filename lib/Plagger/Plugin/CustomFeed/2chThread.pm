package Plagger::Plugin::CustomFeed::2chThread;
use strict;
use base qw( Plagger::Plugin );

use WWW::2ch;
use Encode;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'subscription.load' => $self->can('load'),
        );
}

sub load {
    my($self, $context) = @_;
    
    my $feed = Plagger::Feed->new;
    $feed->aggregator(sub { $self->aggregate(@_) });
    $context->subscription->add($feed);
}

sub aggregate {
    my ($self, $context, $args) = @_;
    
    my $bbs = WWW::2ch->new(url => $self->conf->{url}[0],
                            cache => $self->conf->{cache}[0]);
    $context->log(info => $self->conf->{url}[0]);
    
    $bbs->load_setting;
    $bbs->load_subject;
    
    my $dat = $bbs->subject->threads->[0];
    $context->log(debug => 'Title: ' . decode('shiftjis', $dat->title));
    $dat->load;
    my $res = $dat->reslist->[$#{$dat->reslist}];
    $context->log(debug => 'Res: ' . decode('shiftjis', $res->date));
    $context->log(debug => 'Res: ' . decode('shiftjis', $res->body_text));
    
    my $feed = Plagger::Feed->new;
    $feed->type('2ch');

#    foreach my $res (@{$res->{entry}}){
        my $entry = Plagger::Entry->new;
#        $entry->date($dt);
        $entry->body(decode('shiftjis', $res->body_text));
#        $entry->author($id);
        $entry->title(decode('shiftjis', $res->body_text));
#        $entry->link($line->{url});
        
        $feed->add_entry($entry);
#    }
    $context->update->add($feed);
}

1;

__END__

=head1 NAME

Plagger::Plugin::CustomFeed::Twitter - Scraping Twitter HTML.

=head1 SYNOPSIS

  - module: CustomFeed::Twitter
    - config
        uri:
          - http://twitter.com/user/favorites

=head1 DESCRIPTION

This plugin scrapes twitter HTML.
L<http://www.tumblr.com/>.

=head1 AUTHOR

riywo

=head1 SEE ALSO

L<Plagger>

=cut
