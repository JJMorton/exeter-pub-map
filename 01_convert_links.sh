#!/usr/bin/env bash

# I convert a list of google maps URLs in `links.txt` to a file containing the
# columns latitude, longitude, x, y and name, with x and y as pixel coordinates.
# You might want to manually edit the resulting file if the names from google
# maps are not satisfactory.

LINKS_FILE="links.txt"

# Anchor points (top left and bottom right) and the corresponding pixel coordinates on the map image
ANCHOR1_LATLONG=(-3.554267 50.741857)
ANCHOR1_PIXELS=(999 729)
ANCHOR2_LATLONG=(-3.502550 50.712839)
ANCHOR2_PIXELS=(8226 7140)


if [[ ! -f "$LINKS_FILE" ]]; then
	echo "File '$LINKS_FILE' does not exist"
	exit 1
fi

echo "Reading links from '$LINKS_FILE'..."
# Parse lat and long from google maps URLs
sed -e 's/^.*place\/\(.*\)\/@.*3d\(.*\)!4d\(.*\)!.*/\2\t\3\t\1/' "$LINKS_FILE" | sed -e 's/\+/ /g' | sed -e 's/ - .*//g' | sed -e 's/%26/\&/g' | sed -e 's/,.*//g' >> .tmp.txt

echo "Computing pixel coordinates..."
while IFS= read -r line; do
	lat=$(echo "$line" | cut -f1)
	lon=$(echo "$line" | cut -f2)
	name=$(echo "$line" | cut -f3)
	# Calculate pixel coordinates by linear interpolation
	# Do NOT ask why I've used a shell script for this :)))
	x_frac=$(bc -l <<< "($lon - ${ANCHOR1_LATLONG[0]}) / (${ANCHOR2_LATLONG[0]} - ${ANCHOR1_LATLONG[0]})")
	y_frac=$(bc -l <<< "($lat - ${ANCHOR1_LATLONG[1]}) / (${ANCHOR2_LATLONG[1]} - ${ANCHOR1_LATLONG[1]})")
	x=$(bc -l <<< "${ANCHOR1_PIXELS[0]} + $x_frac * (${ANCHOR2_PIXELS[0]} - ${ANCHOR1_PIXELS[0]})")
	y=$(bc -l <<< "${ANCHOR1_PIXELS[1]} + $y_frac * (${ANCHOR2_PIXELS[1]} - ${ANCHOR1_PIXELS[1]})")
	x=$(printf "%.0f" $x)
	y=$(printf "%.0f" $y)
	printf "%f\t%f\t%d\t%d\t%s\n" $lon $lat $x $y "$name"
done < .tmp.txt > pubs.txt

# Sort pubs by y coordinate on the image
sort -k 4,4 pubs.txt > .tmp.txt
mv .tmp.txt pubs.txt

echo "Saved coordinates and names to 'pubs.txt'"

