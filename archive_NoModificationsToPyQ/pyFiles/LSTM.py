import pyFiles.utils as utils
from keras.models import Sequential
from keras.layers import Dense, Dropout, LSTM
import pandas as pd, numpy as np

# Define model outside function so it lives as a variable
LSTMmodel = Sequential()

# For the redefinition/resetting of LSTMmodel created
@utils.define_in_q
def pyq_redefineLSTMModel():
    print('\n*** Defining/Resetting LSTM Model ***\n')
    global LSTMmodel
    LSTMmodel = Sequential()

# Not exposed to q
def appendLSTMModel(train_set):
    LSTMmodel.add(LSTM(units=50, return_sequences=True, input_shape=(train_set.shape[1],1)))
    LSTMmodel.add(LSTM(units=50))
    LSTMmodel.add(Dense(1))
    LSTMmodel.compile(loss='mean_squared_error', optimizer='adam')
    return 0

@utils.define_in_q
def pyq_createLSTMModel(x_train, y_train, x_valid, epo=1):
    # Create numpy arrays and resize it for training dataset
    np_xtrain = np.array(x_train)
    np_xtrain_rs = np.reshape(np_xtrain, (np_xtrain.shape[0], np_xtrain.shape[1], 1))
    np_ytrain = np.array(y_train)
    # Create numpy arrays and resize it for validation dataset
    np_xvalid = np.array(x_valid)
    np_xvalid_rs = np.reshape(np_xvalid, (np_xvalid.shape[0], np_xvalid.shape[1], 1))
    # Append to LSTM Model
    appendLSTMModel(np_xvalid_rs)
    # Train LSTM Model
    LSTMmodel.fit(np_xtrain_rs, np_ytrain, epochs=epo, batch_size=1, verbose=2)
    # Predict with x_valid dataset
    closing_price = LSTMmodel.predict(np_xvalid_rs)
    # Cannot return model in the output, not compatible w pyQ
    return closing_price

@utils.define_in_q
def pyq_predictLSTMModel(inputs, lookforward=5):
    np_inputs = np.array(inputs)
    reshape_tuple = (np_inputs.shape[0], np_inputs.shape[1], 1)
    rolling_intervals = np_inputs.shape[1]
    for i in range(lookforward):
        predictions = LSTMmodel.predict(np.reshape(np_inputs[-rolling_intervals:], reshape_tuple))
        np_inputs = np.append(np_inputs, predictions)
    return np_inputs[-lookforward:]

