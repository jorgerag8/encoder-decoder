# neural-to-behavior

## Goal

Model for predicting the behavior of mice in a free-roam environment using a transformer architecture. 
Our approach is inspired by a study that investigated the continuous behavior of mice in an operant box, where lever pressing behavior was recorded and 
correlated with neural activity. 

## Methodology

By using a transformer model, we are able to effectively process time-series data that captures the dynamic and 
sequential nature of the mice's behavior and neural activity. More specifically, our model consists of an encoder-decoder transformer architecture, 
where the encoder processes the time-series data of the mice's neural activity, and the decoder predicts the subsequent sequence of neural activity. 
This prediction is then translated into concrete behavioral predictions using a sigmoid classifier. By training our model on a large dataset of behavioral
and neural recordings, we aim to gain insights into the relationship between neural activity and behavior in mice, and to develop more accurate 
predictions of their behavior in different situations.

## Data

We used two data sources from 33 different experiment trials: i) analog dataset, and ii) photometry dataset. The analog dataset consists of a timestamp (with milliseconds precision) and a variable that shows whether the mouse was holding the lever press down. The photometry dataset consists of a timestamp (with milliseconds precision) and a variable that measures the intensity of neural activity of the mouse at that timestamp.

In order to train the model, we summarized and joined both datasets. First, we summarized the analog dataset so that each data point consists of the duration (in milliseconds) of a particular lever press and its order inside one trial. Second, we added the aggregated neural activity intensity during each lever press. Finally, we normalized the aggregated neural activity intensity by dividing it by the duration of the lever press. Therefore, each data point in the dataset consists of i) the order of a lever press in a trial, ii) the duration of the lever press, and iii) the normalized neural activity intensity related to the lever press.

The 33 experiment trials are unevenly distributed with eight mice, the minimum number of trials per mouse was two, and the maximum was eight. Therefore, to ensure that each mouse had at least one trial in both the training and test sets, we randomly selected one trial for each mouse as the test set and the rest consisted of the training set. With this partition methodology, the training set consists of 7,657 data points and the test set of 1,980 data points.
