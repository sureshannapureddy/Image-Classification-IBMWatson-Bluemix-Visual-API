import glob
import json,sys
import os
import pathlib
import os
from os.path import join, dirname

import collections
from watson_developer_cloud import VisualRecognitionV3

visual_recognition = VisualRecognitionV3('2016-05-20', api_key=os.environ.get('API_KEY'))

top_1_accuracy = 0
top_5_accuracy = 0
likelyhood = 0
nb_test_images=100
image_count=1
path  = "test/"
nb_samples = 0

for root, dirs, files in os.walk(path):
    for dir in dirs :
        dirpath = path+dir
        true_class = dir
        for file_name in glob.glob(dirpath+'/*'):
            print(file_name)

            with open(join(dirname(__file__), str(file_name)), 'rb') as image_file:
                input_data=json.dumps(visual_recognition.classify(images_file=image_file, threshold=0.1,
                                                             classifier_ids=[os.environ.get('CLASSIFIER')]), indent=2)
                obj1=json.loads(input_data)
                print(input_data)
                for doc in obj1["images"]:
                    nb_samples = nb_samples + 1
                    sorted_json = sorted(doc["classifiers"][0]["classes"], key=lambda k: (float(k["score"])),reverse=True)
                    if sorted_json[0]["class"] == true_class:
                        top_1_accuracy+=1
                        likelyhood+= sorted_json[0]["score"]
                    for count in range(5):
                        if sorted_json[count]["class"] == true_class:
                            top_5_accuracy += 1
                            print("True Class in top 5, position: ", count, ", class : ",sorted_json[count]["class"], "Score :  ",sorted_json[count]["score"])
                print("########    Results of the class : ", true_class ," sample ", nb_samples, "     ########")
                print("------------------------------------------------------------------")
                print("Top 1 Accuracy : ",top_1_accuracy * 1.0 / nb_samples ,"  Top 5 Accuracy : ",top_5_accuracy * 1.0 / nb_samples,"  Likely Hood :  " ,likelyhood)
                print("------------------------------------------------------------------")
