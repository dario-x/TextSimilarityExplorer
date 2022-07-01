library(rsconnect)
library(shiny)
#for plotting graph
library(visNetwork)
#for generating docterm matrix
library(superml)
library(lsa)
#for getting connected components
library(igraph)
#for data manipulation
library(dplyr)
#for making interactive charts
library(plotly)
#for changing color style
library(RColorBrewer)
#for manipulating strings
library(stringr)
#for error checking
library(berryFunctions)


#host the app
rsconnect::setAccountInfo(name='GIT HUB USER NAME',
                          token='TOKEN',
                          secret='Secret')

rsconnect::deployApp('Local FILE PATH')


