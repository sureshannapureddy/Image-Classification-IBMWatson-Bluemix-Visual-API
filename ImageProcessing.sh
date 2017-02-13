#!/bin/bash

#Download the Food 101 dataset

wget http://data.vision.ee.ethz.ch/cvl/food-101.tar.gz
tar xvzf food-101.tar.gz

#Create the dataset - resize all images to 320

for file in food-101/images/*; do
  mogrify "$file/*.jpg[!320x320>]"
done

#Create the dataset - create train and test directories

cd food-101
mkdir train test
for SPLIT in train test ;
do
  while read -r line
  do
      name="$line"
      DIRNAME="$SPLIT/"`dirname $name`
      if [ ! -d "$DIRNAME" ]; then
        echo "mkdir $DIRNAME"
        mkdir $DIRNAME
      fi
      cp "images/$line.jpg" "$SPLIT/$line.jpg"
      echo "Name read from file - $name"
  done < meta/$SPLIT.txt
done

# Create the dataset - keep the first 100 images per class
for folder in train/*;
do
  count=0
  for file in $folder/*;
  do
    count=$((count+1))
    if [ $count -gt 100 ]
      then
        rm $file
    fi
done done


# Create the dataset - zip train images to prepare upload to Watson
for file in train/*; do
  echo "zipping $file" ; zip -r "$file.zip" "$file"; rm -r $file;
done
