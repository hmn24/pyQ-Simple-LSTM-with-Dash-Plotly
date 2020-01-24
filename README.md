# pyQ-Simple-LSTM-with-Dash-Plotly

Using of quandl data &amp; LSTM Model within pyQ to generate sample predictions, with k4unit tests to check python functions are working as intended

## To run this script:
```
1) Ensure pyQ and the necessary libraries within python are installed (such as workalendar and keras)

2) Have 64bit q 

3) q startup.q

4) The anaconda's pyq library's __init__.py 
would need to be modified at the following lines under the directory $CONDA_PREFIX/lib/python3.7/site-packages/pyq:

    def __setattr__(self, attr, value):
        self("{.Q.dd[`.py;x] set y}", attr, value)

    def __delattr__(self, attr):
        k = K._k
        k(0, "delete %s from `.py" % attr)

5) k4 unit test is utilised to test if python functions are working as intended

   Link: https://github.com/simongarland/k4unit

6) The relevant logic can be searched within script.q to look at the various variables defined

7) Note that there are various python functions that can be called within the q process 

8) Note that the dashboard started up can be permanently SIGKILL-ed through the Quit on the resulting dashboard popup...
One can continue to run kdb+ codes in the q console despite the dashboard (Flask) application running in the background
```


## Pending Work:
```
1) Multivariate LSTM model

```
