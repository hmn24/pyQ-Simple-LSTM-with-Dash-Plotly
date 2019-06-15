import pyFiles.utils as utils
import quandl
from datetime import datetime, timedelta
from keras.models import Sequential
from keras.layers import Dense, Dropout, LSTM
import pandas as pd, numpy as np

# Specify api_key within quandl to ensure proper access
quandl.ApiConfig.api_key = ''

@utils.define_in_q
def pyq_getStockData(stockquote, diff=7, enddt=datetime.today().date()):
    # Connect to quandl to get stock data 
    tab = quandl.get(str(stockquote), start_date=enddt - timedelta(days=int(diff)), end_date=enddt).reset_index()
    return tab.to_dict('series')

@utils.define_in_q
def pyq_getShape(matrix):
    print(np.array(matrix).shape)

@utils.define_in_q
def pyq_createLSTMModel(x_train, y_train, x_valid, epo=1):
    # Create numpy arrays and resize it for training dataset
    np_xtrain = np.array(x_train)
    np_xtrain_rs = np.reshape(np_xtrain, (np_xtrain.shape[0], np_xtrain.shape[1], 1))
    np_ytrain = np.array(y_train)
    # Create numpy arrays and resize it for validation dataset
    np_xvalid = np.array(x_valid)
    np_xvalid_rs = np.reshape(np_xvalid, (np_xvalid.shape[0], np_xvalid.shape[1], 1))
    # Create and Append to LSTM Model
    model = Sequential()
    model.add(LSTM(units=50, return_sequences=True, input_shape=(np_xtrain_rs.shape[1],1)))
    model.add(LSTM(units=50))
    model.add(Dense(1))
    # Train the model
    model.compile(loss='mean_squared_error', optimizer='adam')
    model.fit(np_xtrain_rs, np_ytrain, epochs=epo, batch_size=1, verbose=2)
    # Predict with x_valid dataset
    closing_price = model.predict(np_xvalid_rs)
    # Cannot return model in the output, not compatible w pyQ
    return closing_price
