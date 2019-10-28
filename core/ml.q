// Define dictionaries to store the Min-Max value for inverse-transform
.ml.MinMaxInverseTxf: ()!();
.ml.MinMaxTxf: ()!()

// MinMaxScaler function for scaling and inverse transform
.ml.MinMaxScaler: {[data;id]
    colOfInt: last last id; / Identify column of interest (hash;col)
    mi: ?[data; (); (); (min; colOfInt)]; 
    ma: ?[data; (); (); (max; colOfInt)];
    @[`.ml.MinMaxInverseTxf; id; :; mi+ (ma - mi)* ::]; 
    @[`.ml.MinMaxTxf; id; :; %[;ma - mi] -[;mi] ::];
 };

// Generate base model, returning combined dataset containing validation set predictions alongside actual values (depending on cutoff points)
.ml.genBaseModel: {[data;scaledDataset;params]
    / Get the division by which the dataset should be split into training/validation sets
    division: ceiling params[`division]* count scaledDataset;
    valid: select from data where i >= division;

    / To get the x_train and y_train based on rolling_intervals specified
    rollInt: params[`rollingIntervals];
    nomPx: exec NominalPrice from division # scaledDataset;
    x_train: .utils.rollIntervals[rollInt; nomPx];
    y_train: rollInt _ nomPx;

    / Obtain validation set values for Nompx
    nomPx_valid: exec NominalPrice from (count[scaledDataset] - rollInt + count valid) _ scaledDataset;
    x_valid: .utils.rollIntervals[rollInt; nomPx_valid];

    / Define/Reset the LSTM Model
    .py.redefineLSTMModel[];

    / Run LSTM Model to get the closing_price predicted
    closing_price: .py.createLSTMModel (x_train; y_train; x_valid; params `epochs);

    / Create side-by-side predictions of Predictions beside NominalPrice of Validation Dataset
    valid_pred: update Predictions: raze .ml.MinMaxInverseTxf[nomPxID; closing_price] from valid;

    / Calculate RMSE of valid_pred
    .ml.calcRMSE @ exec first sqrt avg xexp[Predictions - NominalPrice;2] from valid_pred;

    / Join the dataset of train and valid_pred and return it out
    data uj valid_pred
 };

//  RMSE Calculations
.ml.calcRMSE: {-1 "\n *** RMSE of valid_pred is: ", raze .Q.f[2; 100*x], "% ***\n"};

// Generate lookforward predictions
.ml.predictNDays: {[NDays;params;scaledData]  
    / Get the correspoding rollingIntervals
    rollInt: params[`rollingIntervals]; 

    / Generate the correct shape for pyQ after taking the last roll_int data
    lookforward: (0N; rollInt) # exec NominalPrice from (0! neg[rollInt] # scaledData);
    
    / Get the list of price predictions based off NDays specified
    predPx: .ml.MinMaxInverseTxf[params `nomHash; .py.predictLSTMModel (lookforward; NDays)];

    / Generate the list of working days based off NDays specified
    predWDates: first .utils.genWorkingDays/[NDays > count first ::; ((); exec 1+ last Date from scaledData)];

    / Generate the predictions table 
    ([Date: predWDates] NominalPrice: predPx)

 };


