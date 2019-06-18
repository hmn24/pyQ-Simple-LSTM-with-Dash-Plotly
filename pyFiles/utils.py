from pyq import q 
import traceback, inspect, quandl
import pandas as pd, numpy as np
from datetime import datetime, timedelta, date
import workalendar.asia as AsiaCalendar 

# For python functions not requiring any arguments, simply use pyq_3rdCheck[] as an example
def define_in_q(fn):
    def wrapper(*args, **kwargs):
        try:
            if len(inspect.signature(fn).parameters) == 0:
                return fn()
            else:    
                return fn(*args, **kwargs)
        except Exception as err:
            traceback.print_exc()
            raise err
    setattr(q, fn.__name__, wrapper)
    return wrapper

# All pyq functions should have pyq at the start to differentiate from normal q functions
# pyq_1stCheck is for one to test out differences in q/python types and/or transformation
@define_in_q
def pyq_1stCheck(dummy):
    print('Python print output is:')
    print(dummy)
    print('Python type is:')
    print(type(dummy))
    print('')
    return dummy

@define_in_q
def pyq_2ndCheck(no_one, no_two):
    return no_one + no_two

# Check that python empty argument functions are working as intended, i.e. pyq_3rdCheck[]
@define_in_q
def pyq_3rdCheck():
    return 0

@define_in_q
def pyq_4thCheck(bool):
    if bool: print('Boolean Check')

@define_in_q
def pyq_5thCheck(dt):
    print(date(dt))

# Specify api_key within quandl to ensure proper access
quandl.ApiConfig.api_key = 'ymqPSwzsysCvze9UBYcm'

@define_in_q
def pyq_getStockData(stockquote, diff=7, enddt=datetime.today().date()):
    print('Pulling data from quandl')
    # Connect to quandl to get stock data 
    tab = quandl.get(str(stockquote), start_date=enddt - timedelta(days=int(diff)), end_date=enddt).reset_index()
    return tab.to_dict('series')

@define_in_q
def pyq_getShape(matrix):
    print(np.array(matrix).shape)

# Define the HongKong Calendar as a global variable
HKCalendar = AsiaCalendar.HongKong()

# Has to be in yyyy-mm-dd format
@define_in_q
def pyq_checkHKWorkingDays(dt):
    yy, mm, dd = [int(str(i)) for i in dt]
    return HKCalendar.is_working_day(date(yy, mm, dd))
