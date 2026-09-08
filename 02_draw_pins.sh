#!/usr/bin/env bash

# I create an image the same size as `map.png`, and draw the pins for the
# coordinates contained within `pubs.txt` and save to `pins.png`.
# You need ImageMagick for this.

COORDS_FILE="pubs.txt"

# Diameter of circular pins in pixels
PIN_SIZE=80
# List available fonts with `magick -list font | grep Font:`
PIN_FONT="BaskervilleF-Bold-Italic"

# x and y limits of the inset in pixel coordinates.
# Source is on the main map, dest is the blown up inset
INSET_SOURCE_XLIM=(3998 4527)
INSET_SOURCE_YLIM=(4348 4881)
INSET_DEST_XLIM=(6225 7676)
INSET_DEST_YLIM=(5584 7035)


w=$(magick identify -ping -format '%w' map.png)
h=$(magick identify -ping -format '%w' map.png)
res="${w}x${h}"
mid_x=$(((w / 2)))
mid_y=$(((h / 2)))

pin_radius=$(((PIN_SIZE / 2)))
small_pin_radius=$(((PIN_SIZE / 8)))
font_size=$(((2 * PIN_SIZE / 3)))
echo "pin_radius=${pin_radius} font_size=${font_size}"

echo "Computing positions from '$COORDS_FILE'..."
magick_args="-size $res xc:transparent -fill black"
magick_args_text="-fill white -font $PIN_FONT -gravity center -pointsize $font_size"
i=1
while IFS= read -r line; do
	x=$(echo "$line" | cut -f3)
	y=$(echo "$line" | cut -f4)

	# If the coordinates are within the inset, adjust position to within the blown up map
	if [[ $x -ge ${INSET_SOURCE_XLIM[0]} ]]\
		&& [[ $x -le ${INSET_SOURCE_XLIM[1]} ]]\
		&& [[ $y -ge ${INSET_SOURCE_YLIM[0]} ]]\
		&& [[ $y -le ${INSET_SOURCE_YLIM[1]} ]]
	then
		# Draw small points on the original positions
		magick_args="${magick_args} -draw 'circle $x,$y $x,$(((y+small_pin_radius)))'"

		x_frac=$(bc -l <<< "($x - ${INSET_SOURCE_XLIM[0]}) / (${INSET_SOURCE_XLIM[1]} - ${INSET_SOURCE_XLIM[0]})")
		y_frac=$(bc -l <<< "($y - ${INSET_SOURCE_YLIM[0]}) / (${INSET_SOURCE_YLIM[1]} - ${INSET_SOURCE_YLIM[0]})")
		x=$(bc -l <<< "${INSET_DEST_XLIM[0]} + $x_frac * (${INSET_DEST_XLIM[1]} - ${INSET_DEST_XLIM[0]})")
		y=$(bc -l <<< "${INSET_DEST_YLIM[0]} + $y_frac * (${INSET_DEST_YLIM[1]} - ${INSET_DEST_YLIM[0]})")
	fi

	# Ensure coordinates are integers
	x=$(printf "%.0f" $x)
	y=$(printf "%.0f" $y)

	magick_args="${magick_args} -draw 'circle $x,$y $x,$(((y+pin_radius)))'"
	magick_args_text="${magick_args_text} -annotate +$(((x - mid_x)))+$(((y - mid_y))) '$i'"

	i=$(((i + 1)))
done < "$COORDS_FILE"

echo "Creating image..."
echo "${magick_args} ${magick_args_text} pins.png" | xargs magick
echo "Saved to 'pins.png'"
