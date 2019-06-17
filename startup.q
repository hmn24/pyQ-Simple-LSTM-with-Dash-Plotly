// To load all the various python scripts
p)import pyFiles.utils
p)import pyFiles.LSTM

// Inner function to be defined for projection purposes, to be corrected for string types
.py.innerProjection: {x (), $[not[type y] & -10h = type first y; enlist y; y]};

// Define pyq functions with a projection, so no enlist is required for monadic functions
{x set .py.innerProjection value x} each system["f"] where system["f"] like "pyq_*";

// Define the console size
system "c 10 200";

// Load the script.q
system "l script.q"
