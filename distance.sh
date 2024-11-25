#!/usr/bin/env bash
# calculate distance between two gps coordinates

distance () {
  lat_1="$(bc -l <<< "$1 * 0.0174532925")" # deg2rad  pi/180
  lon_1="$(bc -l <<< "$2 * 0.0174532925")"
  lat_2="$(bc -l <<< "$3 * 0.0174532925")"
  lon_2="$(bc -l <<< "$4 * 0.0174532925")"
  delta_lat=$(bc <<<"$lat_2 - $lat_1")
  delta_lon=$(bc <<<"$lon_2 - $lon_1")

  distance=$(bc -l <<< "s($lat_1) * s($lat_2) + c($lat_1) * c($lat_2) * c($delta_lon)")
  distance=$(bc -l <<< "3.141592653589793 / 2 - a($distance / sqrt(1 - $distance * $distance))") # acos
  distance="$(bc -l <<< "57.2957795 * $distance")" # rad2deg 
  distance=$(bc -l <<< "$distance * 60 * 1.15078")
  printf "%.3f\n" $distance
}

distance2 () {
  bc -l <<<"rad=0.0174532922222222
  d1= s($1*rad) * s($3*rad) + c($1*rad) * c($3*rad) * c($4*rad - $2*rad)
  d2=3.1415926 / 2 - a( d1 / sqrt(1 - d1 * d1) )
  print 57.2957795 * d2 * 60 * 1.15078.\"\n\""
}

distance 50.2615588 28.6666776 49.9106591 28.5900312
distance2 50.2615588 28.6666776 49.9106591 28.5900312
