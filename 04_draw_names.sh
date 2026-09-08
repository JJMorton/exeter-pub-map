#!/usr/bin/env bash

# Creates a 'tile' for each place in `pubs.txt` with the assigned number,
# the name of the pub, and a rating scale.
# You need ImageMagick for this.

PIN_FONT="BaskervilleF-Bold-Italic"
NAME_FONT="LobsterTwo-BoldItalic"
COORDS_FILE="pubs.txt"
OUTDIR=names

mkdir $OUTDIR 2> /dev/null

echo "Reading from '$COORDS_FILE'..."
i=1
while IFS= read -r line; do
	name=$(echo "$line" | cut -f5)
	fp=$(printf "$OUTDIR/name-%02d.png" $i)
	magick -size 1783x320 xc:transparent\
		-fill black -stroke none -draw 'circle 150,160 30,160'\
		-fill white -stroke none -pointsize 120 -font "$PIN_FONT"  -gravity center -annotate -741+0 "$i"\
		-fill black -stroke none -pointsize 120 -font "$NAME_FONT" -gravity west   -annotate +560+0 "$name"\
		rating_glass.png -geometry 200x320+330+0 -composite\
		"$fp"
	echo "($i) ${name} $fp"
	i=$(((i+1)))
done < "$COORDS_FILE"

echo "Combining images..."
magick montage -background none -tile 5x0 names/name-*.png -geometry +0+0 -border 0 names.png
echo "Created 'names.png'"

