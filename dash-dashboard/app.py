# -*- coding: utf-8 -*-
from datetime import timedelta

import dash
import dash_core_components as dcc
import dash_html_components as html
import plotly.graph_objs as go

app = dash.Dash()

app.css.append_css({
    'external_url': 'https://codepen.io/chriddyp/pen/bWLwgP.css'
})

app.layout = html.Div([
    html.Div([
        html.Label('Select plot'),
        dcc.Dropdown(
            id='data_dropdown',
            options=[{'label': 'scatter', 'value': 'Data 1'}, {'label': 'histogram', 'value': 'Data 2'}],
            value='Data 1'
        ),
    ], className="two columns"),
    html.Div([dcc.Graph(id='example_graph')], className="ten columns"),
], className="row")

@app.callback(
    dash.dependencies.Output('example_graph', 'figure'),
    [dash.dependencies.Input('data_dropdown', 'value')])
def update_figure(selected_data):
    x = [0,1,2,3]
    y = [2, 1, 4, 3]

    plot_func = None
    if selected_data == 'Data 1':
        plot_func = go.Scatter
    if selected_data == 'Data 2':
        plot_func = go.Bar
    traces = [plot_func(x=x, y=y)]

    return {
        'data': traces,
        'layout': {
            'title':selected_data,
            'xaxis':{'title': 'Numbers'},
            'yaxis':{'title': 'Numbers'},
        }
    }

if __name__ == '__main__':
    app.run_server(debug=True)