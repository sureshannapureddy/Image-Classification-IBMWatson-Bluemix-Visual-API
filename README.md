# Image-Classification
Visual accuracy of a custom classifier of IBM Watson Bluemix Visual API


we will compute its accuracy

# Steps to Follow :
## Sample Dataset
   1.Download [Food 101 dataset](https://www.vision.ee.ethz.ch/datasets_extra/food-101/) for classification.
   
   2.Resize all images to 320 max dimension because IBM Watson Visual Recognition accepts images not more than 320x320.
   
   3.Create train and test directories
   
   4.Zip train images to upload to Watson
   
## Standard classifier
The standard classifier comes with a huge dictionary of labels, for which models have been trained by IBM. let’s give a try on one of our test images :

$API_KEY is your IBM API KEY.

curl -X POST -F "images_file=@test/apple_pie/1011328.jpg" "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify?api_key=$API_KEY&version=2016-05-20"
   
## Create a custom classifier


## Compute accuracy of Watson Visual API

let's create a python script [accuracy_watson.py]() to compute Watson top-1 and top-5 accuracy :
