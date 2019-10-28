// Call quandl to get dataset, or from cache if pulled identical one earlier
.utils.getDataSet: {[params]

    / Get cache directory, primarily to prevent the repeated API calls for which certain data providers have set limits
    cacheFile: .Q.dd[hsym `:cache; exec `$ "_" sv (stockSymbol except "/"; string viewPeriod; string[.z.d] except "."; "Data") from params];

    / If cacheFile exists, read the q binary files from there, else utilise the pyq Function to pull it from quandl, then set it under the cache dir
    $[not type key cacheFile;
        [tab: `Date xasc @[flip .py.getStockData params[`stockSymbol`viewPeriod]; `Date; `date$]; cacheFile set tab];
        tab: get cacheFile
    ];

    / Filter to Date and Nominal Price columns, key it to Date
    1! `Date`NominalPrice xcol (`Date, `$"Nominal Price") # tab

 };

// Create hash from params specified
.utils.createHash: {[params] md5 raze/[string params]};

// Generate the next N amount of working days 
.utils.genWorkingDays: {dt: $[.py.checkHKWorkingDays enlist "." vs string x 1; x 1; ()]; @/[x; 0 1; (,;+); (dt;1)]};

// Generate rolling intervals for LSTM Model Predictions for example
.utils.rollIntervals: {x #' (1 rotate)\[count[y] - x + 1; y]};