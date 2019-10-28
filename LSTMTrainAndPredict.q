// Generate the parameters dictionary for the various computations below
params: `stockSymbol`viewPeriod`division`rollingIntervals`epochs`predLookFwd!("HKEX/01618"; 365; .8; 50; 2; 5);

// Note that this script can only contain one LSTM ML model at any one time >>> Global variable
// Get dataset using the params specified above
dataset: .utils.getDataSet[params];

// Create a hash from the above params, so it becomes unique identifier for the transformation of columns
nomPxID: params[`nomHash]: (.utils.createHash @ params; `NominalPrice);
.ml.MinMaxScaler[dataset; enlist nomPxID];

// MinMaxScale the dataset
scaledDataset: update NominalPrice: .ml.MinMaxTxf[nomPxID; NominalPrice] from dataset;

// Generate the entire model in totality (predictions with original values)
show combinedData: .ml.genBaseModel[dataset;scaledDataset;params]; -1 "";

// Generate N days of predictions
show .ml.predictNDays[params `predLookFwd; params; scaledDataset]; -1 "";

