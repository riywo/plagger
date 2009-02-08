package Plagger::Plugin::CustomFeed::2chBoard;
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
    
    my $bbs = WWW::2ch->new(url => $self->conf->{url},
                            cache => $self->conf->{cache});
    $bbs->load_setting;
    $bbs->load_subject;
    
    my $date_format = '%Y/%m/%d %H:%M:%S';
    my @list = ();
    my $count = $self->conf->{count} || 3;

    my $feed = Plagger::Feed->new;
    $feed->type('2ch');
    
    foreach my $dat ($bbs->subject->threads) {
        $dat->load;
        my @reslist = ();

        foreach my $res (reverse $dat->reslist) {
            my $body = decode('shiftjis', $res->body_text);
            next if $body =~ />\d/;
            next if length($body) < 5;
            next if length($body) > 110;
            $body =~ s/\n//g;
            
            my $date = decode('shiftjis', $res->date);
            next if $date !~ /^\d\d\d\d/;
            $date =~ s/ID.*$//;
            $date =~ s/\(.*?\)//;
            $date =~ s/\.\d+//;
            $context->log(debug => "$date");
            $date = Plagger::Date->strptime($date_format, $date);
            $date->set_time_zone('Asia/Tokyo');
            my $data = {
                title => decode('shiftjis', $dat->title),
                date => $date,
                link => $res->permalink,
                body => $body,
            };
            push(@reslist, $data);
            last if $#reslist+1 >= $count;
        }
        push(@list, @reslist);
    }
    
    my @sort = sort {DateTime->compare($b->{date}, $a->{date})} @list;
    $#sort = $count;
    foreach my $res (@sort) {
#        $context->log(debug => "$res->{body}");
        my $entry = Plagger::Entry->new;
        $entry->title($res->{title});
        $entry->link($res->{link});
        $entry->date($res->{date});
        $entry->body($res->{body} . $res->{link});
        $feed->add_entry($entry);
    }
    
    $context->update->add($feed);
}

1;

__END__

=head1 NAME

Plagger::Plugin::CustomFeed::2chBoard - 2ch res

=head1 SYNOPSIS

  - module: CustomFeed::2chBoard
    - config
        uri: http://live23.2ch.net/liveanb/
        cache: /home/user/cache/2chtest
        count: 5

=head1 DESCRIPTION

This plugin gets 2ch thread and makes feed from latest responses.

=head1 AUTHOR

riywo

=head1 SEE ALSO

L<Plagger>

=cut
