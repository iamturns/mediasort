#!/bin/bash

###
 # Mediasort v0.0.1 - Manage filenames and metadata of your media files
 # https://github.com/turnbullm/mediasort
 ##

for filename in *
do

  echo "$filename"

  ###
  # Fetch parts from filename
  ###

  extension="${filename##*.}"

  year=$( echo "$filename" | cut -c 1-4 )
  month=$( echo "$filename" | cut -c 5-6 )
  day=$( echo "$filename" | cut -c 7-8 )
  hour=$( echo "$filename" | cut -c 10-11 )
  minute=$( echo "$filename" | cut -c 12-13 )
  second=$( echo "$filename" | cut -c 14-15 )

  # Keywords as array (remove date, extension)
  keywords=$( echo "$filename" | cut -c 17- )
  keywords=$( echo "$keywords" | rev | cut -c 5- | rev )
  IFS=',' read -a keywords <<< "$keywords"

  ###
  # Set exif date time
  ###

  if [ "$extension" == "jpg" ]; then

    exif_date="$year:$month:$day $hour:$minute:$second"

    exiv2 -M "set Exif.Image.DateTime $exif_date" "$filename"
    exiv2 -M "set Exif.Image.DateTimeOriginal $exif_date" "$filename"
    exiv2 -M "set Exif.Photo.DateTimeOriginal $exif_date" "$filename"
    exiv2 -M "set Exif.Photo.DateTimeDigitized $exif_date" "$filename"

  fi

  ###
  # Set keywords
  ###

  if [ "$extension" == "jpg" ]; then

    # Clear existing keywords
    exiv2 -M "del Iptc.Application2.Keywords" "$filename"

    for index in "${!keywords[@]}"
    do

      keyword="${keywords[index]}"

      # Trim
      keyword=$( echo "$keyword" | sed -e 's/^ *//' -e 's/ *$//' )

      # Add keyword
      exiv2 -M "add Iptc.Application2.Keywords $keyword" "$filename"

    done

  fi

  ###
  # Set file created date
  ###

  touch_date="$year$month$day$hour$minute.$second"

  touch -a -m -t "$touch_date" "$filename"

  setfile_date="$month/$day/$year $hour:$minute:$second"

  xcrun SetFile -d "$setfile_date" "$filename"

done