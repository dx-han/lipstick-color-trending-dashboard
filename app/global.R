
# --- import packages ---

# shiny
library(shiny)
library(shinyjs)
library(shinymaterial)


# data manipulation
library(data.table)
library(tidyverse)
library(readxl)


# vis
library(highcharter)
library(DT)
library(farver) # color convert
library(plotly)


# load methodology
source("methodology/data_handler.R")
source("methodology/utils.R")


# load modules
source("modules/nav_side_bar.R")
source("modules/page1_trend.R")
source("modules/page1_analysis.R")
source("modules/page2_explore.R")
