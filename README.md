# kaggle-whale-public

Basic Approach
--------------

The solution is based on [Anil's approach and code](https://www.kaggle.com/c/noaa-right-whale-recognition/forums/t/17555/try-this),
using the human-generated annotations of bonnet and blowhole in the training data to train a localizer.
Crops of the head region are generated using the annotations and a classifier is trained on these smaller images.
For prediction, the output of the localizer is used to crop the test images.

Modifications to Anil's Localizer
---------------------------------

Some tweaks were made to allow the localizer to run on a GTX770 (4GB RAM). The 1st convolutional layer filter size and stride were both increased to 4. A corresponding deconvolutional layer was also added. The inital number of filters was also decreased to 64.

Classifier
----------

To allow easier experimentation and modification, the classifier was implemented using Lasagne. The network design follows Anil's model.

Data Augmentation
-----------------

Augmentation of the training data was critical to combat overfitting.
Input images were randomly cropped to introduce variations in position and zoom.
Random gamma adjustment was also found to be beneficial.
The same augmentations were used during prediction and 64 predictions were averaged.

Localizer Ensembling
--------------------

A substaintial amount of error was determined to be caused by failures of the localizer model.
To reduce this, the localizer was run multiple times and the predictions combined.
Initially, 8 sets of predictions were combined by finding the average position of points which formed tight clusters.
Later, 17 sets of predictions were combined by simpler and more efficient gaussian filtering.

Alternative Whale Detection
---------------------------

Late in the competition, a method for whale detection [shared on the forums by the user KA](https://www.kaggle.com/c/noaa-right-whale-recognition/forums/t/18251/another-whale-detector) was incorporated.
This method provided a line segment running from head to tail of the whale.
This was used for precropping, in an attempt to improve the results of the localizer network.
While this did seem to give better results, it introduced a new source of error in cases when the initial whale detection failed. The single-submission performance using this method was worse (~2.5 vs ~1.7 on the public LB), but it did add diversity to the final ensemble.

Data
----

It is assumed that all competition data is located in the `data` subdirectory.

Usage
-----

Multiple steps are necessary to use this code. Intermediate results (localizer outputs) are provided as a time-saving measure.
Trained classifier snapshots can be provided but are not included due to the file size (~100MB).

1. Generate localizer predictions
  - Install `Neon` and python prerequisites as specified in `whale-2015/README.md`.
  - Run `whale-2015/run_localizer.sh` to generate 17 sets of localizer predictions in `./data/testpoints`.
  - Run the notebook `Filter Testpoints.ipynb` to produce filtered testpoints from the 1st 8 sets.
  - Run the notebook `Filter Testpoints B.ipynb` to produce filtered testpoints from all 17 sets.
2. Use `whale-2015/crop.py` to produce cropped test images using the filtered testpoints
  -    `python crop.py ../data/testpoints/testpoints1_filtered.json ../data/testpoints/testpoints2_filtered.json ../data/test ../data/testcrop384 384 1`
  -    `python crop.py ../data/testpoints/testpoints1_filteredB.json ../data/testpoints/testpoints2_filteredB.json ../data/test ../data/testcrop384_B 384 1`
3. Train classifier and make predictions
  - Run the notebook `Lasagne Classifier - Train and Predict.ipynb` to train a model and produce predictions. Adjust `DATA_DIR` to use different test crops, and `SEED` to change the random seed.
4. Alternative whale detection
  - Run the notebook `KA Whale Detector Preprocessing.ipynb`
  - Run the notebook `KA Whale Detector Cropping.ipynb` sections I and II.
  - Use the produced files `detcrop_pointsN.json` and cropped images in `./data/detcrop_train` to train a localizer model.
  - Run section III of the notebook to convert the localizer outputs.
  - Produce test crops using `det_testpointsN.json`.

Six submissions produced by these models were included in the final ensemble. They were generated as follows:

1. `submission_01032016_1.csv` (public LB 1.90): `testpointsN_filtered.json` and `SEED=1`.
2. `submission_01032016_2.csv` (public LB 1.87): `testpointsN_filtered.json` and `SEED=2`.
3. `submission_01062016_2.csv` (public LB 1.68): `testpointsN_filtered_B.json` and `SEED=1`.
4. `submission_01072016_1.csv` (public LB 1.63): `testpointsN_filtered_B.json` and `SEED=2`.
5. `submission_01062016_1.csv` (public LB 2.57): `detcrop_testpointsN.json` and `SEED=1`.
6. `submission_01072016_2.csv` (public LB 2.09): A blend of `submission_01072016_1.csv` and `submission_01062016_1.csv` - run `Blend Submissions.ipynb` to generate.