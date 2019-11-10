import dash
import dash_core_components as dcc
import dash_html_components as html
import plotly.graph_objs as go
from dash.dependencies import Input, Output, State
from multiprocessing import Process
import os, signal, sys
import pyFiles.utils as utils
from pyq import q
import pandas as pd

app = dash.Dash()

## Create the sliders 
sliderScrollStyle = {'paddingTop':7.5,'paddingBottom':30,'paddingRight':40,'paddingLeft':40}
sliderScroll = dcc.Slider(id='predSlider', min=1, max=10, step=1, marks={i:i for i in range(1,11)}, value=1)

## Create a global variable for purposes of storing predictions value
predictions = pd.DataFrame(columns=['Date', 'Nominal Price'])

## Create a global variable for storing the stock symbol
stockSym = ''

## Create the graphPlot for purposes of plotting the requisite 
trace = []
graphPlot = dcc.Graph(id='my_graph', figure = {'data':trace})

## Create quit button here for termination of dashboards within q console
qButtonStyle = {'float':'right','padding':5, 'paddingRight':10, 'paddingLeft':10, 'marginRight':10}
qButton = html.Button(id='quitButton', n_clicks=0, children='Quit', style=qButtonStyle)

## Dummy H1 tag just for purposes of providing an avenue to Quit the dashboard
dummyQuit = html.H1(id='dummyQuit')

app.layout = html.Div([
    html.Div(qButton),
    html.H1('LSTM Predictions Plot:', style={'marginLeft':15}),
    html.H2('No of Days for Lookforward Predictions:', style={'marginLeft':15}),
    html.P(html.Div(sliderScroll, style=sliderScrollStyle)),
    html.Div(dummyQuit, style={'display':'none'}),
    html.P(graphPlot)
 ])

@app.callback(Output('my_graph', 'figure'), [Input('predSlider', 'value')])
def update_graph(predDays):
    global trace, predictions, stockSym
    if 2 < len(trace): trace.pop()
    # Generate the scatter plot
    predVal = go.Scatter(x=predictions['Date'][:predDays], y=predictions['Nominal Price'][:predDays], mode='lines+markers', name='Predictions')
    trace.append(predVal)
    return {'data': trace, 'layout': {'title': stockSym}}

# For purposes of killing the dashboard process since it would be stuck, so the q can be returned to normalcy
@app.callback(Output('dummyQuit', 'children'), [Input('quitButton', 'n_clicks')], [State('dummyQuit', 'children')])
def shutdownFromDash(n_clicks, dummyQuit):
    global server
    if n_clicks:
        print('\nExiting Dashboards ......\n')
        os.kill(server.pid, signal.SIGKILL)
    return ''

# .py.quitDash() to exit dashboard visualisations in q session
@utils.define_in_q
def quitDash():
    global server
    print('\nExiting Dashboards ......\n')
    os.kill(server.pid, signal.SIGKILL)
    
# .py.runDash() to trigger dashboard visualisations via dash-plotly
@utils.define_in_q
def runDash(): 
    global app, server
    server = Process(target=app.run_server)
    server.start()

# .py.populateBaseTrace() to populate the trace with Original and Validation Values
@utils.define_in_q
def populateBaseTrace(dtRange, nomPx, validPx):
    global trace, graphPlot
    trace = []
    origVal = go.Scatter(x=dtRange, y=nomPx, mode='lines', name='Original')
    trace.append(origVal)
    validVal = go.Scatter(x=dtRange, y=validPx, mode='lines+markers', name='Validation')
    trace.append(validVal)

# .py.populatePredTrace() to populate the trace with Predictions Value (It should only be populated if there's two values, else pop it)
@utils.define_in_q
def populatePredTrace(dtRange, predPx):
    global trace, sliderScroll, predictions
    if 2 < len(trace): trace.pop()
    
    ## Ensure sliderScroll is calibrated against the count of predictions
    sliderScroll.marks = {i:i for i in range(1, max(2, 1+len(predPx)))}
    sliderScroll.max = max(1, len(predPx))

    # Populate a global pandas dataframe variable with their corresponding values for the eventual interactions
    predictions['Date'] = dtRange
    predictions['Nominal Price'] = predPx

    # Append to the trace for plotting on the dcc.Graph
    predVal = go.Scatter(x=dtRange, y=predPx, mode='lines+markers', name='Predictions')
    trace.append(predVal)
    
@utils.define_in_q
def populateStockSym(stockSym_):
    global stockSym
    stockSym = str(stockSym_)
