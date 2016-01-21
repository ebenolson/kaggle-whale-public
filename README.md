# kaggle-whale-public

Basic Approach
--------------

The solution is based on [Anil's approach and code](https://www.kaggle.com/c/noaa-right-whale-recognition/forums/t/17555/try-this),
using the human-generated annotations of bonnet and blowhole in the training data to train a localizer.
Crops of the head region are generated using the annotations and a classifier is trained on these smaller images.
For prediction, the output of the localizer is used to crop the test images.

Modifications to Anil's Localizer
---------------------------------

Some small tweaks were made to allow the localizer to run on a GTX770 (4GB RAM).

Classifier
----------

To allow easier experimentation and modification, the classifier was implemented using Lasagne. The model design follows Anil's code.

Data Augmentation
-----------------

Augmentation of the training data was critical to decreasing overfitting.
Input images were randomly cropped to introduce variations in position and zoom.
Random gamma adjustment was also found to be beneficial.

Localizer Ensembling
--------------------

A substaintial amount of error was determined to be caused by failures of the localizer model.
To combat this, the localizer was run multiple times and the predictions combined.
Initially, 8 sets of predictions were combined by finding the average position of points which formed tight clusters.
Later, 17 sets of predictions were combined by simpler and more efficient gaussian filtering.

Alternative Whale Detection
---------------------------

Late in the competition, a method for whale detection [shared on the forums by the user KA](https://www.kaggle.com/c/noaa-right-whale-recognition/forums/t/18251/another-whale-detector) was incorporated.
This method provided a line segment running from head to tail of the whale.
This was used for precropping, in an attempt to improve the results of the localizer network.

Data
----

It is assumed that all competition data is located in the `data` subdirectory.

Usage
-----

Multiple steps are necessary to use this code. Intermediate results (localizer outputs) are provided as a time-saving measure.
Trained classifier snapshots can be provided but are not included due to the file size (~100MB).
