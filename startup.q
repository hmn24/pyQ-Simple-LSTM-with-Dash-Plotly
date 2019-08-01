// -- Python Scripts Section -- 
p)import pyFiles.utils
p)import pyFiles.LSTM

// Define pyq functions with a projection, so no enlist is required for monadic functions
@[`.py; system "f .py"; '; (),];

// Define the console size
system "c 10 200";

// -- Unit Test Section --
// Define the unitTestPath for the loading of pyQ script
.util.unitTestPath: .Q.dd[`:.; key[`:.] where key[`:.] like "k4unit"];

// Define the test script to ensure that pyq functions defined are all working properly 
\l k4unit/k4unit.q

// Load the corresponding pyQ testing section
KUltd .Q.dd[.util.unitTestPath;`pyQ];

// Run the unit test and save it down for restrospective viewing
-1 "\n*** Running Unit Tests: ***\n";
KUrt[];
-1 "\n*** Completed and Saving Unit Tests: ***";
KUstr[];
-1 $[exec all ok from KUTR; "\n*** Unit Tests Passed ***\n"; "\n*** Unit Tests Failed ***\n"];

// -- Machine Learning (LSTM) Section --
\l script.q


