// -- Python Scripts Section -- 
p)import pyFiles.utils
p)import pyFiles.LSTM

// Define pyq functions with a projection, so no enlist is required for monadic functions
@[`.py; system "f .py"; '; (),];

// Define the console size
system "c 10 200";

// Run Unit Test if need to check if pyQ working correctly
system "l core/unitTest.q";
.ut.loadUnitTest[`:.];
.ut.runUnitTest[`pyQ];

// -- Machine Learning (LSTM) Section --
system "l core/ml.q";
system "l core/utils.q";
system "l LSTMTrainAndPredict.q";

