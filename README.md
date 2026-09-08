# Exeter Pub Map

This is a map of pubs in Exeter, originally created in November 2025.
It is designed for A0 poster format.

## Poster creation pipeline

To create the poster, begin with:
- `map.png`: the unlabelled map,
- `links.txt`: a list of links to places on Google Maps,
- `rating_glass.png`: the empty glass that goes next to each pub name.

First create the labelled map:
1. Run `./01_convert_links.sh` to convert the links to a tabulated file of coordinates (lat/long and pixel) and names, saved in `pubs.txt`.
2. Run `./02_draw_pins.sh` to draw the pub pins to their own image, `pins.png`.
3. Run `./03_add_pins.sh` to overlay the pins on top of the map, creating `map-with-pins.png`.

Now create the list of pubs, which will go at the bottom of the poster:
- Run `./04_draw_names.sh`, which renders all the pubs as their own image in `names/`, then tiles them together to produce `names.png`.

Finally, in GIMP:
1. Open `poster.xcf`, and replace the `map-with-pins.png` and `names.png` layers as appropriate.
2. `File > Export...` and save as `poster.png` in this directory.

## The map image

I created the unlabelled map image `map.png` using [Snazzy Maps](https://snazzymaps.com).
On the website, I removed most elements from the map, and made water a distinctive red colour to be easily separable, the style can be found [here](https://snazzymaps.com/style/664697/poster-red-rivers).
To overcome the resolution limit of this website, I exported a few maps of different areas and manually stitched them together.
Finally, I recoloured the resulting map in GIMP.
The combined & edited layers are in `map_src/`, and the original map tiles are in `map_src/tiles/`.
