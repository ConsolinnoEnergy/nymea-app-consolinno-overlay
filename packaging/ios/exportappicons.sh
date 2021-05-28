#!/bin/bash

INKSCAPE_BIN=/Applications/Inkscape.app/Contents/MacOS/inkscape

function exportImage() {
  size=$1
  scaleFactor=$2
  echo Exporting AppIcon with size $size and scale factor $scaleFactor
  if [ ${scaleFactor} -ne 1 ]; then
    finalSize=`printf "%.f" $(echo "$size * $scaleFactor" | bc -l)`
    echo final size is ${finalSize}
    $INKSCAPE_BIN AppIcon.svg -o Assets.xcassets/AppIcon.appiconset/AppIcon${size}x${size}@${scaleFactor}x.png -C -w $finalSize -h $finalSize
  else
    $INKSCAPE_BIN AppIcon.svg -o Assets.xcassets/AppIcon.appiconset/AppIcon${size}x${size}.png -C -w ${size} -h ${size}
  fi
}

SIZES=(
  "20:1"
  "20:2"
  "20:3"
  "29:1"
  "29:2"
  "29:3"
  "40:1"
  "40:2"
  "40:3"
  "60:2"
  "60:3"
  "76:1"
  "76:2"
  "83.5:2"
  "1024:1"
)

for size in "${SIZES[@]}" ; do
  pixels="${size%%:*}"
  scale="${size##*:}"
  exportImage $pixels $scale
done
