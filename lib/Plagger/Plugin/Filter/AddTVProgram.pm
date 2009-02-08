package Plagger::Plugin::Filter::AddTVProgram;
use strict;
use base qw( Plagger::Plugin );

use Encode;

use utf8;
use DateTime;
use DateTime::Format::Strptime;
use DateTime::Format::HTTP;
use XML::Feed;

sub register {
    my ($self, $context) = @_;
    $context->register_hook(
        $self,
        'update.entry.fixup' => \&filter,
    );
}

sub filter {
    my ($self, $context, $args) = @_;
    my %channel = (
        'NHK' => 'nhk',
        'NHK教育' => 'nhked',
        '日本テレビ' => 'ntv',
        'TBS' => 'tbs',
        'フジテレビ' => 'fuji',
        'テレビ朝日' => 'asahi',
        'テレビ東京' => 'tx',
    );
    
    my $date = $args->{entry}->date;
    my $zone = DateTime::TimeZone->new( name => 'GMT' );
    my $posttime = DateTime::Format::HTTP->parse_datetime($date, $zone);
    $posttime->set_time_zone('Asia/Tokyo');

    my $tv = XML::Feed->parse(URI->new('http://tv.nikkansports.com/tv.php?mode=04&site=007&lhour=1&category=g&template=rss&area=008&pageCharSet=UTF8'));
    
    foreach my $entry ($tv->entries){
        my $title = $entry->{entry}->{title};
        next if $title !~ /\d\d:\d\d/;
        
        $title =~ /^.*?\d\d:\d\d.(\d\d:\d\d)\s(.*?)\s(.*)/;
        next if $channel{$2} ne $self->conf->{channel};
        
        my $start = DateTime::Format::HTTP->parse_datetime($entry->{entry}->{pubDate});
        my $strp = DateTime::Format::Strptime->new(pattern => '%H:%M');
        my $end = DateTime::Format::HTTP->parse_datetime($entry->{entry}->{pubDate});
        $end->set(hour => $strp->parse_datetime($1)->hour);
        $end->set(minute => $strp->parse_datetime($1)->minute);
        
        if($start <= $posttime && $posttime <= $end){
            my $name = $3;
            $name =~ s/\[.+?\]//g if $name !~ /^[.+?]$/;
            my $body = $args->{entry}->{body};
            $args->{entry}->body('【' . $name . '】 '. $body);
            last;
        }
    }
}

1;

__END__

=head1 NAME

Plagger::Plugin::Filter::AddTVProgram - Add TV Program name.

=head1 SYNOPSIS

  - module: Filter::AddTVProgram
    config:
      channel: nhk

=head1 DESCRIPTION

This plugin adds current tv program name.
L<http://www.tumblr.com/>.

=head1 AUTHOR

riywo

=head1 SEE ALSO

L<Plagger>

=cut
