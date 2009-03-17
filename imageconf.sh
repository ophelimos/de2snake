#!/bin/sh
bmp2mif $1 $2
bmp2mif image.colour.mif image.colour.rif
grep -v "@" image.colour.rif
grep -v "@" image.colour.rif | tr " " ","
