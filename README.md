# MFML - Final Project

Final project for the course Mathematical Foundation of Machine Learning (Spring 2018).

## Feature importance via wavelet decomposition of RF

In this work, we utilize the wavelet decomposition of RF [1](#[1]) to produce a more robust Feature Importance.

We will compare the results of several feature importance method using 5-fold CV over two datasets:

1. Classification problem: Human Activity Recognition Using Smartphones Data ([link to data](https://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)).
2. Regression problem: Abalone age prediction ([link to data](https://archive.ics.uci.edu/ml/datasets/Abalone)).

We will also get to test the new exciting [SHAP](https://github.com/slundberg/shap) (SHapley Additive exPlanations) project. SHAP is a unified approach to explain the output of any machine learning model.

## Reference 

<a name="1">[1]</a>[ O. Elisha and S. Dekel, Wavelet decompositions of Random Forests - smoothness analysis, sparse
approximation and applications, JMLR 17 (2016).](http://www.jmlr.org/papers/volume17/15-203/15-203.pdf)