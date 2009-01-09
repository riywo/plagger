package Plagger::Plugin::CustomFeed::Twitter;
use strict;
use base qw( Plagger::Plugin );

use URI;
use Web::Scraper;

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

    my $uri = new URI($self->conf->{uri}[0]);
    $context->log(info => $self->conf->{uri}[0]);
    my $entry = scraper {
        process 'span.entry-content', post => 'TEXT';
        process 'a.entry-date', url => '@href';
        process 'span.published', date => '@title';
        process 'div>strong>a', id => 'TEXT';
    };
    my $res = scraper {
        process 'td.status-body', 'entry[]' => $entry;
    }->scrape($uri);

#    print $res->{entry}[0]->{post};

    my $feed = Plagger::Feed->new;
    $feed->type('twitter');

    foreach my $line (@{$res->{entry}}){
        $context->log(debug => $line->{post});
        my $entry  = Plagger::Entry->new;
        my $post = $line->{id}. ": ". $line->{post};

        my $dt = eval { Plagger::Date->parse_dwim($line->{date}) };
        $entry->date($dt) if $dt;
        $entry->body($post);
        $entry->author($line->{id});
        $entry->title($post);
        $entry->link($line->{url});
        
        $feed->add_entry($entry);
    }
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
