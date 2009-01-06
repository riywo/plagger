package Plagger::Plugin::Filter::RemoveTags;
use strict;
use base qw( Plagger::Plugin );

sub register {
    my ( $self, $context ) = @_;
    $context->register_hook( $self, 'update.feed.fixup' => \&filter, );
}

sub filter {
    my ( $self, $c, $args ) = @_;

    foreach my $entry ( $args->{feed}->entries ) {
        $c->log( info => "remove tags");
        my @tags = ();
        $entry->tags(\@tags);
    }
}

1;

__END__

=head1 NAME

Plagger::Plugin::Filter::RemoveTags - remove tags from entry

=head1 SYNOPSIS

  - module: Filter::RemoveTags

=head1 AUTHOR

riywo

=head1 SEE ALSO

L<Plagger>

=cut
