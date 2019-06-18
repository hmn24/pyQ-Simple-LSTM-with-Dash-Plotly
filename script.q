// Define q's MinMaxScaler function
/ Define a dictionary to store the Min-Max value for inverse-transform
.utils.MinMaxInverseTxf: ()!();
.utils.MinMaxTxf: ()!()
.utils.MinMaxScaler: {[data;id] 
    mi: min data; ma: max data;
    @[`.utils.MinMaxInverseTxf; id; :; {x + z * y - x}[mi;ma;]]; 
    @[`.utils.MinMaxTxf; id; :; {(z - x) % y - x}[mi;ma;]]; 
    (data - mi) % ma - mi
 };

// Generate function that can generate the N amount of working days
.utils.genWorkingDays: {dt: $[pyq_checkHKWorkingDays enlist "." vs string x 1; x 1; ()]; @/[x; 0 1; (,[;dt];1+)]};

// Define function to get rolling intervals for LSTM Model Predictions
.utils.rollIntervals: {x #' (1 rotate)\[count[y] - x + 1; y]};


// Generate the parameters dictionary for the various computations below
params: `stockSymbol`viewPeriod`rollingIntervals`epochs`predLookFwd!("HKEX/01618"; 365; 60; 5; 5);

// Get cache directory, primarily to prevent the repeated API calls for which certain data providers have set limits
cacheFile: .Q.dd[hsym `:cache; exec `$ "_" sv (stockSymbol except "/"; string viewPeriod; string[.z.d] except "."; "Data") from params];

// If cacheFile exists, read the q binary files from there, else utilise the pyq Function to pull it from quandl
// Construct the sample data for the running of LSTM Model
$[not type key cacheFile;
    [tab: `Date xasc @[flip pyq_getStockData params[`stockSymbol`viewPeriod]; `Date; `date$]; cacheFile set tab];
    [-1 "\n*** Reading from cacheFile ***\n"; tab: get cacheFile]
 ];

// Filter to Date and Nominal Price columns, key it to Date
dataset: 1! `Date`NominalPrice xcol (`Date, `$"Nominal Price") # tab;

// Split into training and testing sets - 80% division mark
division: floor ceiling 0.8* ceiling count dataset;
train: select from dataset where i < division;
valid: select from dataset where i >= division;

// MinMaxScale the dataset
scaled_dataset: update NominalPrice: .utils.MinMaxScaler[NominalPrice;`NominalPrice] from dataset;

// To get the x_train and y_train based on rolling_intervals specified
roll_int: params[`rollingIntervals];
nomPx: exec NominalPrice from division # scaled_dataset;
x_train: .utils.rollIntervals[roll_int; nomPx];
y_train: roll_int _ nomPx;

// Create and scale-transform validation set
inputs: (count[scaled_dataset] - roll_int + count valid ) _ dataset;
scaled_inputs: update NominalPrice: .utils.MinMaxTxf[`NominalPrice;NominalPrice] from inputs;

// Obtain Validation Nompx
nomPx_valid: exec NominalPrice from scaled_inputs;
x_valid: .utils.rollIntervals[roll_int; nomPx_valid];

// Define the LSTM Model
pyq_redefineLSTMModel[];

// Run LSTM Model to get the closing_price predicted
closing_price: pyq_createLSTMModel (x_train; y_train; x_valid; params `epochs);

// Create side-by-side predictions of Predictions beside NominalPrice of Validation Dataset
valid_pred: update Predictions: .utils.MinMaxInverseTxf[`NominalPrice;closing_price] from valid;

// Calculate RMSE of valid_pred
{-1 "\n *** RMSE of valid_pred is: ", raze .Q.f[2; 100*x], "% ***\n"} RMSE: exec first sqrt avg xexp[Predictions - NominalPrice;2] from valid_pred;

// Join the dataset of train and valid_pred
show -5# combined_dataset: train uj valid_pred;

// Get subset data to do 5 working days look-forward predictions
subset_data: 0! neg[roll_int] # scaled_dataset;

// Generate the correct shape for pyQ for the lookforward variable
lookforward: (0N;roll_int) # exec NominalPrice from subset_data;

// Generate the list of working days based off the preLookFwd parameter
pred_dts: first .utils.genWorkingDays/[params[`predLookFwd] > count first @; ((); last[subset_data][`Date] + 1)];

// Get the list of price predictions based off the preLookFwd parameter
pred_px: .utils.MinMaxInverseTxf[`NominalPrice; pyq_predictLSTMModel (lookforward; params `predLookFwd)];
/ One can play around with different lookforward predictions such as >> MinMaxInverseTxf[`NominalPrice; pyq_predictLSTMModel (lookforward; 14)]

// Generate the predictions table 
-1 raze "\n *** Lookahead Predictions for the next ", string[params `predLookFwd], " working days: ***\n";
show predTab: ([Date: pred_dts] NominalPrice: pred_px);


