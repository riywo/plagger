package Plagger::Plugin::Filter::TwitterEcho;
use strict;
use base qw( Plagger::Plugin );

use Encode;

sub register {
    my ($self, $context) = @_;
    $context->register_hook(
        $self,
        'update.entry.fixup' => \&filter,
    );
}

sub filter {
    my ($self, $context, $args) = @_;
 
    my $body = $args->{entry}->{body};
    $body =~ s/\r|\n//g;
    $body =~ /^.+?:\s@.+?\s(.+)$/o;
    $args->{entry}->body($1 . " " . $args->{entry}->{link});
}

1;

__END__

=head1 NAME

Plagger::Plugin::Filter::TwitterEcho - Making Twitter Echo from Reply.

=head1 SYNOPSIS

  - module: Filter::TwitterEcho

=head1 DESCRIPTION

This plugin makes twitter reply feed to echo for bot.
L<http://www.tumblr.com/>.

=head1 AUTHOR

riywo

=head1 SEE ALSO

L<Plagger>

=cut
