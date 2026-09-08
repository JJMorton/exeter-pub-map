#!/usr/bin/env bash

# Compine `map.png` with `pins.png` to create `map-with-pins.png`
# You need ImageMagick for this.

echo "Overlaying 'pins.png' on 'map.png'"
magick map.png pins.png -composite map-with-pins.png
echo "Saved to 'map-with-pins.png'"

