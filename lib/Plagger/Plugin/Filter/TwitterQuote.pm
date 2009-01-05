package Plagger::Plugin::Filter::TwitterQuote;
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
    $body =~ /^(.+?): (.+)/o;
    my $id = $1;
    my $quote = encode_utf8($2);
    my $title = "Twitter / " . $id;
    
    $args->{entry}->title($title);
    $args->{entry}->body($quote);
}

1;
