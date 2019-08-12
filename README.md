# pyQ-Simple-LSTM-Model

Using of quandl data &amp; LSTM Model within pyQ to generate sample predictions, with k4unit tests to check python functions are working as intended

## To run this script:
```
1) Ensure pyQ and the necessary libraries within python are installed (such as workalendar and keras)

2) Have 64bit q 

3) q startup.q

4) If not using the archive version, the anaconda's pyq library's __init__.py 
would need to be replaced by this repo's __init__.py file for the script 
to work correctly, i.e. define python functions within the .py namespace

Corresponding directory: $CONDA_PREFIX/lib/python3.7/site-packages/pyq

Change the above based on python version used 

5) Simon Garland's k4 unit test is utilised to test if python functions are working as intended

6) The relevant logic can be searched within script.q to look at the various variables defined

7) Note that there are various python functions that can be called within the q process 
```


## Pending Work:
```
1) Multivariate LSTM model
```
