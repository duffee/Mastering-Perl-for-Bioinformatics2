package DrawGraphics;

use Moose::Role;

#
# A Role that takes locations of restriction enzyme recognition sites in
# DNA sequence data and displays them.
#

use strict;
use warnings;
use Carp;
use GD;

#
# Method to output graphics in PNG and JPG format
#

sub _drawmap_graphics {
    my($self) = @_;

    my $format = $self->graphictype;
    if (! $format eq 'jpg' || ! $format eq 'png') {
        croak "Unknown format '", $format, "' given to drawmap method\n";
    }

    # Get text version of graphic
    my @maptext = split( /\n+/, $self->_drawmap_text);

    # Now make a graphic from the text version

    #
    # Layout information: fonts, margins, image size
    #
    # Use built-in GD fixed-width font 'gdMediumBoldFont' (could use TrueType fonts)
    #
    # Font character size in pixels
    my ($fontwidth, $fontheight) = (gdMediumBoldFont->width, gdMediumBoldFont->height);

    # Margins top, bottom, right, left, and between lines
    my ($tmarg, $bmarg, $rmarg, $lmarg, $linemarg) = (10, 10, 10, 10, 5);

    # Image width is length of line times width of a character, plus margins
    my ($imagewidth) = (length($maptext[0]) * $fontwidth) + $lmarg + $rmarg;

    # Image height is height of font plus margin times number of lines, plus margins
    my ($imageheight) =
               (($fontheight + $linemarg) * (scalar @maptext)) + $tmarg + $bmarg;

    my $image = new GD::Image($imagewidth, $imageheight);

    # First one becomes background color
    my $white = $image->colorAllocate(255, 255, 255);
    my $black = $image->colorAllocate(0, 0, 0);
    my $red   = $image->colorAllocate(255, 0, 0);

    # Origin at upper left hand corner
    my ($x, $y) = ($lmarg, $tmarg);

    #
    # Draw the lines on the image
    #
    foreach my $line (@maptext) {
        chomp $line;
        # Draw annotation in red
        if($line =~ / /) { #annotation has spaces
            $image->string(gdMediumBoldFont, $x, $y, $line, $red);
            # Draw sequence in black
        }
        else{ #sequence
            $image->string(gdMediumBoldFont, $x, $y, $line, $black);
        }
        $y += ($fontheight + $linemarg);
    }

    if ($format eq 'jpg') {
        return $image->jpg;
    }
    else {
        return $image->png;
    }
}

=head1 AUTHOR

James Tisdall

=head1 COPYRIGHT

Copyright (c) 2003, James Tisdall

=cut

1;
