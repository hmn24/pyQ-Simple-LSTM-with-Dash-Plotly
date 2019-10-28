from pyq import q 
import traceback, inspect, quandl
import pandas as pd, numpy as np
from datetime import datetime, timedelta, date
import workalendar.asia as AsiaCalendar 

# For python functions not requiring any arguments, simply use pyq_3rdCheck[] as an example
def define_in_q(fn):
    params = len(inspect.signature(fn).parameters)
    def wrapper(*args, **kwargs):
        try:
            if params == 0:
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
def firstCheck(dummy):
    print('Python print output is:' + str(dummy))
    print('Python type is: ' + str(type(dummy)))
    return dummy

@define_in_q
def secondCheck(no_one, no_two):
    return no_one + no_two

# Check that python empty argument functions are working as intended, i.e. pyq_3rdCheck[]
@define_in_q
def thirdCheck():
    return 0

@define_in_q
def fourthCheck(bool):
    if bool: print('Boolean Check')

# This has to be fed in with the standard python dt argument, in q, this means we need to
# enlist "." vs string .z.d
@define_in_q
def fifthCheck(dt):
    yy, mm, dd = [int(str(i)) for i in dt]
    return date(yy, mm, dd)

# Specify api_key within quandl to ensure proper access
quandl.ApiConfig.api_key = ''

@define_in_q
def getStockData(stockquote, diff=7, enddt=datetime.today().date()):
    print('*** Pulling data from quandl ***')
    # Connect to quandl to get stock data 
    tab = quandl.get(str(stockquote), start_date=enddt - timedelta(days=int(diff)), end_date=enddt).reset_index()
    return tab.to_dict('series')

@define_in_q
def getShape(matrix):
    print(np.array(matrix).shape)

# Define the HongKong Calendar as a global variable
HKCalendar = AsiaCalendar.HongKong()

# Has to be in yyyy-mm-dd format
@define_in_q
def checkHKWorkingDays(dt):
    yy, mm, dd = [int(str(i)) for i in dt]
    return HKCalendar.is_working_day(date(yy, mm, dd))
