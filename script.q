// Construct the sample data for the running of LSTM Model
/ This is already done in ascending order
tab: `Date xasc @[flip pyq_getStockData ("HKEX/01618";365); `Date; `date$];

// Filter to Date and Nominal Price columns, key it to Date
dataset: 1! `Date`NominalPrice xcol (`Date, `$"Nominal Price") # tab;

// Split into training and testing sets - 80% division mark
division: floor ceiling 0.8* ceiling count dataset;
train: select from dataset where i < division;
valid: select from dataset where i >= division;

// Define q's MinMaxScaler function
/ Define a dictionary to store the Min-Max value for inverse-transform
MinMaxInverseTxf: ()!();
MinMaxTxf: ()!()
MinMaxScaler: {[data;id] 
    mi: min data; ma: max data;
    @[`MinMaxInverseTxf; id; :; {x + z * y - x}[mi;ma;]]; 
    @[`MinMaxTxf; id; :; {(z - x) % y - x}[mi;ma;]]; 
    (data - mi) % ma - mi
 };

// MinMaxScale the dataset
scaled_dataset: update NominalPrice: MinMaxScaler[NominalPrice;`NominalPrice] from dataset;

// Define function to get rolling intervals for LSTM Model Predictions
rollIntervals: {x #' (1 rotate)\[count[y] - x + 1; y]}

// To get the x_train and y_train based on rolling_intervals specified
roll_int: 60;
nomPx: exec NominalPrice from division # scaled_dataset;
x_train: rollIntervals[roll_int; nomPx];
y_train: roll_int _ nomPx;

// Reshape x_train to get the correct shape -> which we won't need to do properly in q since it has been done as intended
/ x_train_rshape: (count x_train; count flip x_train) # raze x_train;

// Create and scale-transform validation set
inputs: (count[scaled_dataset] - roll_int + count valid ) _ dataset;
scaled_inputs: update NominalPrice: MinMaxTxf[`NominalPrice;NominalPrice] from inputs;

// Obtain Validation Nompx
nomPx_valid: exec NominalPrice from scaled_inputs;
x_valid: rollIntervals[roll_int; nomPx_valid];

// Run LSTM Model to get the closing_price predicted
closing_price: pyq_createLSTMModel (x_train; y_train; x_valid; 2);

// Create side-by-side predictions of Predictions beside NominalPrice of Validation Dataset
show valid_pred: update Predictions: MinMaxInverseTxf[`NominalPrice;closing_price] from valid;

// Join the dataset of train and valid_pred
show combined_dataset: train uj valid;
