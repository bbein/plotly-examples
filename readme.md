# plotly - Dash - Shiny - Example

## How to install plotly for jupyter-lab

plotly has a great [readme](https://github.com/plotly/plotly.py) on how to get plotly and how to get it working in jupyter-notebooks and jupyter-lab. There are a lot of exact dependencies that have to be installed.

Here are the current steps for a Unix system (for windows look at the plotly readme)

```
conda create -n plotlywidget python=3.7
source activate plotlywidget
conda install nodejs
conda install -c plotly plotly=3.6.1
conda install "notebook>=5.3" "ipywidgets>=7.2"
conda install jupyterlab=0.35 "ipywidgets>=7.2"
export NODE_OPTIONS=--max-old-space-size=4096
jupyter labextension install @jupyter-widgets/jupyterlab-manager@0.38 --no-build
jupyter labextension install plotlywidget@0.7.1 --no-build
jupyter labextension install @jupyterlab/plotly-extension@0.18.1 --no-build
jupyter labextension install jupyterlab-chart-editor@1.0 --no-build
jupyter lab build
```

## Install dash

After plotly is working in jupyter-lab we can add dash to the same environment

```
pip install dash
```