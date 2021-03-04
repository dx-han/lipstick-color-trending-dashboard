
# --- import packages ---

# login
# library(shinymanager)
# library(keyring)

# shiny
library(shiny)
library(shinyjs)
library(shinymaterial)


# data manipulation
library(data.table)
library(tidyverse)
library(readxl)
# library(reticulate)
# library(shinythemes)


# vis
library(highcharter)
library(DT)
library(farver) # color convert
library(plotly)


# algo
# library(psych) # clustering
#stringr’, ‘broom’, ‘igraph

# load methodology
source("methodology/data_handler.R")
source("methodology/utils.R")


# load modules
source("modules/nav_side_bar.R")
source("modules/page1_board.R")
source("modules/page1_trend.R")
source("modules/page1_analysis.R")
source("modules/page2_explore.R")
source("modules/page3_instruction.R")

# set_labels(
#   language = "en",
#   "Please authenticate" = "口红流行趋势洞察看板",
#   "Username:" = "请输入用户名:",
#   "Password:" = "请输入密码:",
#   "Login" = "登陆",
#   "Username or password are incorrect" = "用户名或密码错误"
# )

# get_labels()

# 深 272733
# 浅 363847
