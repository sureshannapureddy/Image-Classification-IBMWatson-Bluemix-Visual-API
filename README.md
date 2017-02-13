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
   
## Create custom classifier

Before uploading images to the classifier, we need to verify that each zip file is no more than 100 MB and 10 000 images per .zip file, no less than 10 images per size.

du -h food-101/images/*.zip

Each zip file is around 25MB (well balanced dataset - have the same number of images per class). Each zip file should not be above 100MB, otherwise we would have to divide them into multiple zip files.

Create the classifier under the name food-101. For creation, the service accepts a maximum of 300 MB so we can only upload up to 10 classes per update.

DATA=`pwd`/food-101/images
FIRST_CLASSES=`ls train/*.zip | awk 'NR >=1 && NR <=10 {split($0,a,"."); split(a[1],a,"/"); printf " -F " a[2] "_positive_examples=@" $0 }' -  `
echo $FIRST_CLASSES

returns what we need : -F apple_pie_positive_examples=@food-101/images/apple_pie.zip -F baby_back_ribs_positive_examples=@food-101/images/baby_back_ribs.zip -F baklava_positive_examples=@food-101/images/baklava.zip -F beef_carpaccio_positive_examples=@food-101/images/beef_carpaccio.zip -F beef_tartare_positive_examples=@food-101/images/beef_tartare.zip -F beet_salad_positive_examples=@food-101/images/beet_salad.zip -F beignets_positive_examples=@food-101/images/beignets.zip -F bibimbap_positive_examples=@food-101/images/bibimbap.zip -F bread_pudding_positive_examples=@food-101/images/bread_pudding.zip -F breakfast_burrito_positive_examples=@food-101/images/breakfast_burrito.zip


### Let’s upload them

curl -X POST $FIRST_CLASSES -F "name=food-101" "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classifiers?api_key=$API_KEY&version=2016-05-20" > response.json



## List existing classifiers

curl -X GET "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classifiers?api_key=$API_KEY&version=2016-05-20"

which gives

{"classifiers": [
{
    "classifier_id": "food101_1404391194",
    "name": "food-101",
    "status": "training"
}
]}

or parse response.json to get the classifier ID :

{
"classifier_id": "food101_1404391194",
"name": "food-101",
"owner": "de67af8c-862c-4002-88a8-259653c880c4",
"status": "training",
"created": "2016-12-21T15:32:10.458Z",
"classes": [
    {"class": "beef_carpaccio"},
    {"class": "baklava"},
    {"class": "baby_back_ribs"},
    {"class": "apple_pie"},
    {"class": "bibimbap"},
    {"class": "beignets"},
    {"class": "beet_salad"},
    {"class": "beef_tartare"},
    {"class": "breakfast_burrito"},
    {"class": "bread_pudding"}
]
}

CLASSIFIER=`cat response.json | python -c "import json,sys;obj=json.load(sys.stdin);print obj['classifier_id'];"`

You can retrieve more info about the classifier :

curl -X GET "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classifiers/$CLASSIFIER?api_key=$API_KEY&version=2016-05-20"

{
    "classifier_id": "food101_1404391194",
    "name": "food-101",
    "owner": "de67af8c-862c-4002-88a8-259653c880c4",
    "status": "ready",
    "created": "2016-12-21T15:32:10.458Z",
    "classes": [
        {"class": "beef_carpaccio"},
        {"class": "baklava"},
        {"class": "baby_back_ribs"},
        {"class": "apple_pie"},
        {"class": "bibimbap"},
        {"class": "beignets"},
        {"class": "beet_salad"},
        {"class": "beef_tartare"},
        {"class": "breakfast_burrito"},
        {"class": "bread_pudding"}
    ]
}

## Update custom classifier

service accepts a maximum of 256 MB , retrained timestamp will be updated with the last retraining update, below program will make sure that the server is in ready state to retrain the classifier.

[UpdateClassifier.sh](https://github.com/sureshannapureddy/Image-Classification/blob/master/UpdateClassifier.sh)

## Delete custom classifier

curl -X DELETE "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classifiers/$CLASSIFIER?api_key=$API_KEY&version=2016-05-20"

## Classify an image with the custom classifier

curl -X POST -F "images_file=@test/apple_pie/1011328.jpg" "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify?api_key=$API_KEY&classifier_ids=$CLASSIFIER&version=2016-05-20"

It is possible to request multiple classifiers at the same time, by separating classifier IDs with a comma. The default classifier is ‘Default’.


## Compute accuracy of Watson Visual API

let's create a python script [accuracy_watson.py]() to compute Watson top-1 and top-5 accuracy.
