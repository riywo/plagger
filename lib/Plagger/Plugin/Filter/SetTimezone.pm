package Plagger::Plugin::Filter::SetTimezone;
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
    $args->{entry}->date->set_time_zone($self->conf->{timezone});
}

1;

__END__

=head1 NAME

Plagger::Plugin::Filter::SetTimezone - .

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
