#!/bin/bash

echo "Prefixing filenames"

filecount=1
for filename in *
do

  suffix="$filename"
  if [[ $filename == _torename_* ]]; then
    # Do not reapply _torename_, file already contains it
    suffix=$( echo "$filename" | cut -c 16- )
  fi

  # Pad up to 4 (0000, 0001, etc)
  filecount_padded=$( printf "%0*d\n" 4 $filecount )

  filename_new=$(printf "_torename_%s_%s" "$filecount_padded" "$suffix")

  mv "$filename" "$filename_new"

  filecount=$[$filecount+1]

done

echo "Keywords > filename (if available)"

for filename in *.jpg
do

  filename_prefix=$( echo "$filename" | cut -c 1-15 )
  keywords=$( exiv2 -Pv -g "Iptc.Application2.Keywords" "$filename" )

  if [ "$keywords" != "" ]; then

    keywords=$( echo "$keywords" | tr '\n' ',' )
    keywords=$( echo "$keywords" | sed 's/,/, /' )
    keywords=$( echo "$keywords" | rev | cut -c 3- | rev )

    filename_new="$filename_prefix$keywords.jpg"

  else

    filename_new="$filename_prefix.jpg"

  fi

  mv "$filename" "$filename_new"

done

echo "Date taken > filename (if available)"

for filename in *.jpg
do
    echo "$filename"
    exiv2 -F -r '%Y%m%d_%H%M%S :basename:' "$filename"
done

echo "Date created > filename"

for filename in _torename_*
do

    created=$( stat -f "%Sm" -t "%Y%m%d_%H%M%S" "$filename" )
    filename_new="$created $filename"

    mv "$filename" "$filename_new"

done

for filename in *
do

    date_prefix=$( echo "$filename" | cut -c 1-15 )
    filename_extension="${filename##*.}"
    filename_new="$date_prefix"
    filename_orig=$( echo "$filename" | cut -c 32- )
    possible_duplicate_date_prefix=$( echo "$filename_orig" | cut -c 1-15 )

    if [ "$date_prefix" == "$possible_duplicate_date_prefix" ]; then
        filename_orig=$( echo "$filename_orig" | cut -c 17- )
    fi

    if [[ ! $filename_orig ]] ; then
        filename_new="$date_prefix $filename_orig"
    else
        filename_new="$date_prefix.$filename_extension"
    fi

    if [[ -e $filename_new ]] ; then
        filename_new="_$RANDOM $filename_new"
    fi

    mv "$filename" "$filename_new"

done