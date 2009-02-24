package Plagger::Plugin::Filter::RemoveIDFromTwitterRSS;
use strict;
use base qw( Plagger::Plugin );

use Encode;

use utf8;
use DateTime;
use DateTime::Format::Strptime;
use DateTime::Format::HTTP;

sub register {
    my ($self, $context) = @_;
    $context->register_hook(
        $self,
        'update.entry.fixup' => \&filter,
    );
}

sub filter {
    my ($self, $context, $args) = @_;
    my $entry_title = $args->{entry}->title_text;
    $entry_title =~ s/\r|\n//g;
    $entry_title =~ s/^.+?: //o;

    $args->{entry}->title($entry_title);
    $args->{entry}->body($entry_title);
}

1;

__END__

=head1 NAME

Plagger::Plugin::Filter::RemoveIDFromTwitterRSS - .

=head1 SYNOPSIS

  - module: Filter::RemoveIDFromTwitterRSS

=head1 DESCRIPTION

This filter remove ID and CR/LF from Twitter rss.

=head1 AUTHOR

riywo

=head1 SEE ALSO

L<Plagger>

=cut
