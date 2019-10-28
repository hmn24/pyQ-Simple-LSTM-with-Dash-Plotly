// Define unitTest functions to check if pyQ are working correctly
.ut.loadUnitTest: {[path]
    .ut.unitTestPath: .Q.dd[path; key[path] where key[path] like "k4unit"]; // Set unit test path
    system "l ", 1_ string .Q.dd[.ut.unitTestPath;`k4unit.q]; // Load Testing Script 
 };

.ut.runUnitTest: {[unit]
    `KUltd @ .Q.dd[.ut.unitTestPath; unit];   // Load the corresponding pyQ testing section
    `KUrt[]; // Run the unit test 
    `KUstr[]; // Save unit test results for restrospective viewing
    if[not exec all ok from `KUTR; '"Unit Tests Failed!"]; // Report if unit test failed 
 };