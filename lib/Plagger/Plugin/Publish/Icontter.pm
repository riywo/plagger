package Plagger::Plugin::Publish::Icontter;
use strict;
use base qw( Plagger::Plugin );

use Encode;
use WWW::Mechanize;
use Image::Magick;
use utf8;
use List::Util qw/max/;
use bytes ();
use DateTime;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'plugin.init'      => \&initialize,
        'publish.feed'    => \&publish_feed,
    );
}

sub initialize {
    my($self, $context) = @_;
    $self->{mech} = WWW::Mechanize->new;
    $self->{mech}->get('http://twitter.com');
    $self->{mech}->submit_form(
        form_number => 2,
        fields      => {
            'session[username_or_email]' => $self->conf->{username},
            'session[password]' => $self->conf->{password}});
    $self->{base_file} = $self->conf->{basefile};
    my $dt = DateTime->now(time_zone => 'local');
    my $date = $dt->strftime('%Y%m%d%H%M%S');
    $self->{upload_file} = $self->conf->{basefile};
    $self->{upload_file} =~ s/^(.+?)(\..{3})$/$1${date}$2/;
#    qx{rm -fr "$1"_*};
}

sub publish_feed {
    my($self, $context, $args) = @_;
    return unless $self->{mech};
    
    my @case = (
        {
            reg => '^アイコン戻|^アイコンもど',
            prc => sub{$self->{upload_file} = $self->{base_file};}
        },
        {
            reg => '^帰宅',
            prc => sub{$self->annotate($self->{base_file}, 'pink', '帰宅', 'しました');},
        },
        {
            reg => '^俺爆発|^おれ爆発',
            prc => sub{$self->annotate($self->{base_file}, 'red', '爆発');},
        },
        {
            reg => '^おはよう',
            prc => sub{$self->annotate($self->{base_file}, 'pink', '起床');},
        },
        {
            reg => '^おやすみ',
            prc => sub{$self->annotate($self->{base_file}, 'blue', '睡眠');},
        },
        {
            reg => '(.+?)なう[\.．。！]{0,1}$',
            prc => sub{$self->annotate($self->{base_file}, 'white', $1);},
        },
        {
            reg => '^ダメだ',
            prc => sub{$self->swirl($self->{base_file});
                       $self->annotate($self->{upload_file}, 'yellow', 'ダメ', '人間');},
        }
    );

    LABEL: foreach my $entry (reverse $args->{feed}->entries){
        my $post = $entry->title_text;
        $post =~ s/@.+? //g;

        foreach my $check (@case){
            my $reg = $check->{reg};
            if($post =~ /${reg}/){
                $check->{prc}->();
                $self->{mech}->get('http://twitter.com/account/picture');
                $self->{mech}->submit_form(
                    form_number => 1,
                    fields => {'profile_image[uploaded_data]' => $self->{upload_file}}
                );
                $context->log(debug => "Upload " . $self->{upload_file});
                last LABEL;
            }
        }
    }
}

sub annotate {
    my($self, $src, $f_color, @line) = @_;
    my $image = Image::Magick->new;
    $image->Read($src);
    my $max_length = max (map {(length($_) + bytes::length($_))/2} @line)/2;
    $" = '\n';
    my $text = "@line";

    my $sazanami = '/usr/share/fonts/truetype/sazanami/sazanami-gothic.ttf';
    my $mona = '/usr/share/fonts/truetype/mona/mona.ttf';
    my $kochi = '/usr/share/fonts/truetype/kochi/kochi-gothic.ttf';
    my $font = $kochi;

    my ($width, $height) = $image->Get('width', 'height');
    my $pointsize = int(($width-30)/$max_length);
    my $y = $height-30-($pointsize*$#line);
    my $b_color = 'black';
    my $f_width = int((7/90)*$pointsize);
    my $b_width = int((14/90)*$pointsize);
    $image->Annotate(text => $text, stroke => $b_color, fill => $b_color,
                     font => $font, pointsize => $pointsize, strokewidth => $b_width,
                     x => 15, y => $y, encoding =>'UTF-8');
    $image->Annotate(text => $text, stroke => $f_color, fill => $f_color,
                     font => $font, pointsize => $pointsize, strokewidth => $f_width,
                     x => 15, y => $y, encoding =>'UTF-8');
    $image->Write($self->{upload_file});

    undef $image;
}

sub swirl {
    my($self, $src) = @_;
    my $image = Image::Magick->new;
    $image->Read($src);
    $image->Swirl(degrees => 400);
    $image->Write($self->{upload_file});
    undef $image;
}

sub copy {
    my($self, $src) = @_;
    my $image = Image::Magick->new;
    $image->Read($src);
    $image->Write($self->{upload_file});
    undef $image;
}


1;
__END__

=head1 NAME

Plagger::Plugin::Publish::Icontter

=head1 SYNOPSIS

  - module: Publish::Icontter
    config:
      basefile: /path/to/image
      username: twitterid
      password: twitterpassword

=head1 DESCRIPTION

Icontter

=head1 AUTHOR

riywo

=head1 SEE ALSO

L<Plagger>

=cut
