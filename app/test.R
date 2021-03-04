# library(tidyverse)
# library(gapminder)
# 
# data(gapminder, package = "gapminder")
# 
# gapminder <- gapminder %>% 
#   filter(year == max(year)) %>% 
#   select(country, pop, continent)
# 
# hc <- hchart(gapminder, "packedbubble", hcaes(name = country, value = pop, group = continent))
# 
# q95 <- as.numeric(quantile(gapminder$pop, .95))
# 
# hc %>% 
#   hc_tooltip(
#     useHTML = TRUE,
#     pointFormat = "<b>{point.name}:</b> {point.value}"
#   ) %>% 
#   hc_plotOptions(
#     packedbubble = list(
#       maxSize = "150%",
#       zMin = 0,
#       layoutAlgorithm = list(
#         gravitationalConstant =  0.05,
#         splitSeries =  TRUE, # TRUE to group points
#         seriesInteraction = TRUE,
#         dragBetweenSeries = TRUE,
#         parentNodeLimit = TRUE
#       ),
#       dataLabels = list(
#         enabled = TRUE,
#         format = "{point.name}",
#         filter = list(
#           property = "y",
#           operator = ">",
#           value = q95
#         ),
#         style = list(
#           color = "black",
#           textOutline = "none",
#           fontWeight = "normal"
#         )
#       )
#     )
#   )
# 
# 
# 
# library(shiny)
# 
# if (interactive()) {
#   shinyApp(
#     ui = fluidPage(
#       wellPanel("mouseOver and click points for additional information"),
#       uiOutput("click_ui"),
#       highchartOutput("plot_hc")
#     ),
#     server = function(input, output) {
#       df <- data.frame(x = 1:5, y = 1:5, otherInfo = letters[11:15])
# 
#       output$plot_hc <- renderHighchart({
#         highchart() %>%
#           hc_add_series(data=this.color.board, "packedbubble",  hcaes(name = color_name, value = total_index, group = color_name)) %>%
#           hc_legend(enabled=F) %>%
#           hc_tooltip(pointFormat="<b>{point.name}:</b> {point.value}") %>%
#           hc_add_event_series(series="packedbubble", event = "click")
#       })
# 
#       output$click_ui <- renderUI({
#         # if (is.null(input$plot_hc_click)) {
#         #   return()
#         # }
#         print(input$plot_hc_click)
# 
#         wellPanel("Coordinates of clicked point: ", input$plot_hc_click$name)
#       })
#     }
#   )
# }

# library(shiny)
# 
# if (interactive()) {
#   shinyApp(
#     ui = fluidPage(
#       wellPanel("mouseOver and click points for additional information"),
#       uiOutput("click_ui"),
#       uiOutput("mouseOver_ui"),
#       highchartOutput("plot_hc")
#     ),
#     server = function(input, output) {
#       df <- data.frame(x = 1:5, y = 1:5, otherInfo = letters[11:15])
#       
#       output$plot_hc <- renderHighchart({
#         highchart() %>%
#           hc_add_series(df, "scatter") %>%
#           hc_add_event_point(event = "click") %>%
#           hc_add_event_point(event = "mouseOver")
#       })
#       
#       observeEvent(input$plot_hc, print(paste("plot_hc", input$plot_hc)))
#       
#       output$click_ui <- renderUI({
#         if (is.null(input$plot_hc_click)) {
#           return()
#         }
#         
#         wellPanel("Coordinates of clicked point: ", input$plot_hc_click$x, input$plot_hc_click$y)
#       })
#       
#       output$mouseOver_ui <- renderUI({
#         if (is.null(input$plot_hc_mouseOver)) {
#           return()
#         }
#         
#         wellPanel("Coordinates of mouseOvered point: ", input$plot_hc_mouseOver$x, input$plot_hc_mouseOver$y)
#       })
#     }
#   )
# }
# fig <- plot_ly()
# fig <- fig %>% add_trace(
#   x = c("2017-01-01", "2017-02-10", "2017-03-20"), 
#   y = c("A", "B", "C"), 
#   z = c(1, 1000, 100000), 
#   name = "z", 
#   type = "scatter3d"
# )
# fig <- fig %>% layout(
#   scene = list(
#     aspectratio = list(
#       x = 1,
#       y = 1,
#       z = 1
#     ),
#     camera = list(
#       center = list(
#         x = 0,
#         y = 0,
#         z = 0
#       ),
#       eye = list(
#         x = 1.96903462608,
#         y = -1.09022831971,
#         z = 0.405345349304
#       ),
#       up = list(
#         x = 0,
#         y = 0,
#         z = 1
#       )
#     ),
#     dragmode = "turntable",
#     xaxis = list(
#       title = "",
#       type = "date"
#     ),
#     yaxis = list(
#       title = "",
#       type = "category"
#     ),
#     zaxis = list(
#       title = "",
#       type = "log"
#     ),
#     annotations = list(list(
#       showarrow = F,
#       x = "2017-01-01",
#       y = "A",
#       z = 0,
#       text = "Point 1",
#       xanchor = "left",
#       xshift = 10,
#       opacity = 0.7
#     ), list(
#       x = "2017-02-10",
#       y = "B",
#       z = 4,
#       text = "Point 2",
#       textangle = 0,
#       ax = 0,
#       ay = -75,
#       font = list(
#         color = "black",
#         size = 12
#       ),
#       arrowcolor = "black",
#       arrowsize = 3,
#       arrowwidth = 1,
#       arrowhead = 1
#     )
#     )),
#   xaxis = list(title = "x"),
#   yaxis = list(title = "y")
# )
# 
# fig

# library(shiny)
# library(shinydashboard)
# library(DT)
# library(shinyjs)
# library(sodium)
# 
# loginpage <- div(id = "loginpage", style = "width: 500px; max-width: 100%; margin: 0 auto; padding: 20px;",
#                  wellPanel(
#                    tags$h2("LOG IN", class = "text-center", style = "padding-top: 0;color:#333; font-weight:600;"),
#                    textInput("userName", placeholder="Username", label = tagList(icon("user"), "Username")),
#                    passwordInput("passwd", placeholder="Password", label = tagList(icon("unlock-alt"), "Password")),
#                    br(),
#                    div(
#                      style = "text-align: center;",
#                      actionButton("login", "SIGN IN", style = "color: white; background-color:#3c8dbc;
#                                  padding: 10px 15px; width: 150px; cursor: pointer;
#                                  font-size: 18px; font-weight: 600;"),
#                      shinyjs::hidden(
#                        div(id = "nomatch",
#                            tags$p("Oops! Incorrect username or password!",
#                                   style = "color: red; font-weight: 600;
#                                             padding-top: 5px;font-size:16px;",
#                                   class = "text-center"))),
#                      br(),
#                      br(),
#                      tags$code("Username: myuser  Password: mypass"),
#                      br(),
#                      tags$code("Username: myuser1  Password: mypass1")
#                    ))
# )
# 
# credentials = data.frame(
#   username_id = c("myuser", "myuser1"),
#   passod   = sapply(c("mypass", "mypass1"),password_store),
#   permission  = c("basic", "advanced"),
#   stringsAsFactors = F
# )
# 
# 
# header <- dashboardHeader( title = "Simple Dashboard", uiOutput("logoutbtn"))
# 
# sidebar <- dashboardSidebar(uiOutput("sidebarpanel"))
# body <- dashboardBody(shinyjs::useShinyjs(), uiOutput("body"))
# ui<-dashboardPage(header, sidebar, body, skin = "blue")
# 
# 
# server <- function(input, output, session) {
# 
#   login = FALSE
#   USER <- reactiveValues(login = login)
# 
#   observe({
#     if (USER$login == FALSE) {
#       if (!is.null(input$login)) {
#         if (input$login > 0) {
#           Username <- isolate(input$userName)
#           Password <- isolate(input$passwd)
#           if(length(which(credentials$username_id==Username))==1) {
#             pasmatch  <- credentials["passod"][which(credentials$username_id==Username),]
#             pasverify <- password_verify(pasmatch, Password)
#             if(pasverify) {
#               USER$login <- TRUE
#             } else {
#               shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
#               shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
#             }
#           } else {
#             shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
#             shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
#           }
#         }
#       }
#     }
#   })
# 
#   output$logoutbtn <- renderUI({
#     req(USER$login)
#     tags$li(a(icon("fa fa-sign-out"), "Logout",
#               href="javascript:window.location.reload(true)"),
#             class = "dropdown",
#             style = "background-color: #eee !important; border: 0;
#                     font-weight: bold; margin:5px; padding: 10px;")
#   })
# 
#   output$sidebarpanel <- renderUI({
#     if (USER$login == TRUE ){
#       sidebarMenu(
#         menuItem("Main Page", tabName = "dashboard", icon = icon("dashboard"))
#       )
#     }
#   })
# 
#   output$body <- renderUI({
#     if (USER$login == TRUE ) {
#       tabItem(tabName ="dashboard", class = "active",
#               fluidRow(
#                 box(width = 12, dataTableOutput('results'))
#               ))
#     }
#     else {
#       loginpage
#     }
#   })
# 
#   output$results <-  DT::renderDataTable({
#     datatable(iris, options = list(autoWidth = TRUE,
#                                    searching = FALSE))
#   })
# 
# }
# 
# runApp(list(ui = ui, server = server), launch.browser = TRUE)





# library(shiny)
# library(bcrypt)
# library(shinyjs)
# 
# if (!dir.exists('www/')) {
#   dir.create('www')
# }
# 
# download.file(
#   url = 'https://cdn.jsdelivr.net/npm/js-cookie@2/src/js.cookie.min.js',
#   destfile = 'www/js.cookie.js'
# )
# 
# addResourcePath("js", "www")
# 
# # This would usually come from your user database. But we want to keep it simple.
# password_hash <- bcrypt::hashpw('secret123') # Never store passwords as clear text
# sessionid <- "OQGYIrpOvV3KnOpBSPgOhqGxz2dE5A9IpKhP6Dy2kd7xIQhLjwYzskn9mIhRAVHo" # Our not so random sessionid
# 
# 
# jsCode <- '
#   shinyjs.getcookie = function(params) {
#     var cookie = Cookies.get("id");
#     if (typeof cookie !== "undefined") {
#       Shiny.onInputChange("jscookie", cookie);
#     } else {
#       var cookie = "";
#       Shiny.onInputChange("jscookie", cookie);
#     }
#   }
#   shinyjs.setcookie = function(params) {
#     Cookies.set("id", escape(params), { expires: 0.5 });  
#     Shiny.onInputChange("jscookie", params);
#   }
#   shinyjs.rmcookie = function(params) {
#     Cookies.remove("id");
#     Shiny.onInputChange("jscookie", "");
#   }
# '
# 
# server <- function(input, output) {
#   
#   status <- reactiveVal(value = NULL)
#   # check if a cookie is present and matching our super random sessionid  
#   observe({
#     js$getcookie()
#     if (!is.null(input$jscookie) && input$jscookie == sessionid) {
#       status(paste0('in with sessionid ', input$jscookie))
#     }
#     else {
#       status('out')
#     }
#   })
#   
#   observeEvent(input$login, {
#     if (input$username == 'admin' & bcrypt::checkpw(input$password, hash = password_hash)) {
#       # generate a sessionid and store it in your database, but we keep it simple in this example...
#       # sessionid <- paste(collapse = '', sample(x = c(letters, LETTERS, 0:9), size = 64, replace = TRUE))
#       js$setcookie(sessionid)
#     } else {
#       status('out, cause you don\'t know the password secret123 for user admin.')
#     }
#   })
#   
#   observeEvent(input$logout, {
#     status('out')
#     js$rmcookie()
#   })
#   
#   output$output <- renderText({
#     paste0('You are logged ', status())}
#   )
# }
# 
# ui <- fluidPage(
#   tags$head(
#     # you must copy https://raw.githubusercontent.com/js-cookie/js-cookie/master/src/js.cookie.js to www/
#     tags$script(src = "www/js.cookie.js")
#   ),
#   useShinyjs(),
#   extendShinyjs(text = jsCode, functions=c("getcookie","setcookie","rmcookie")),
#   sidebarLayout(
#     sidebarPanel(
#       textInput('username', 'User', placeholder = 'admin'),
#       passwordInput('password', 'Password', placeholder = 'secret123'),
#       actionButton('login', 'Login'),
#       actionButton('logout', 'Logout')
#     ),
#     mainPanel(
#       verbatimTextOutput('output')
#     )
#   )
# )
# 
# shinyApp(ui = ui, server = server)




# credentials <- data.frame(
#   user = c("shiny", "shinymanager"), # mandatory
#   password = c("azerty", "12345"), # mandatory
#   start = c("2019-04-15"), # optinal (all others)
#   expire = c(NA, "2020-12-31"),
#   admin = c(FALSE, TRUE),
#   comment = "Simple and secure authentification mechanism 
#   for single ‘Shiny’ applications.",
#   stringsAsFactors = FALSE
# )
# 
# library(shiny)
# library(shinymanager)
# 
# ui <- fluidPage(
#   tags$h2("My secure application"),
#   verbatimTextOutput("auth_output")
# )
# 
# # Wrap your UI with secure_app
# ui <- secure_app(ui)
# 
# 
# server <- function(input, output, session) {
#   
#   # call the server part
#   # check_credentials returns a function to authenticate users
#   res_auth <- secure_server(
#     check_credentials = check_credentials(credentials)
#   )
#   
#   output$auth_output <- renderPrint({
#     reactiveValuesToList(res_auth)
#   })
#   
#   # your classic server logic
#   
# }
# 
# shinyApp(ui, server)




# library(shiny)
# library(shinymanager)
# 
# ui <- fluidPage(
#   tags$h2("Change password module"),
#   actionButton(
#     inputId = "ask", label = "Ask to change password"
#   ),
#   verbatimTextOutput(outputId = "res_pwd")
# )
# 
# server <- function(input, output, session) {
#   
#   observeEvent(input$ask, {
#     insertUI(
#       selector = "body",
#       ui = tags$div(
#         id = "module-pwd",
#         pwd_ui(id = "pwd")
#       )
#     )
#   })
#   
#   output$res_pwd <- renderPrint({
#     reactiveValuesToList(pwd_out)
#   })
#   
#   pwd_out <- callModule(
#     module = pwd_server,
#     id = "pwd",
#     user = reactiveValues(user = "me"),
#     update_pwd = function(user, pwd) {
#       # store the password somewhere
#       list(result = TRUE)
#     }
#   )
#   
#   observeEvent(pwd_out$relog, {
#     removeUI(selector = "#module-pwd")
#   })
# }
# 
# shinyApp(ui, server)




library(shiny)
library(shinymanager)

# data.frame with credentials info
# credentials <- data.frame(
#   user = c("fanny", "victor"),
#   password = c("azerty", "12345"),
#   comment = c("alsace", "auvergne"),
#   stringsAsFactors = FALSE
# )
# 
# # you can hash the password using scrypt
# # and adding a column is_hashed_password
# # data.frame with credentials info
# # credentials <- data.frame(
# #   user = c("fanny", "victor"),
# #   password = c(scrypt::hashPassword("azerty"), scrypt::hashPassword("12345")),
# #   is_hashed_password = TRUE,
# #   comment = c("alsace", "auvergne"),
# #   stringsAsFactors = FALSE
# # )
# 
# # app
# ui <- fluidPage(
# 
#   # authentication module
#   auth_ui(
#     id = "auth",
#     # add image on top ?
#     tags_top =
#       tags$div(
#         tags$h4("Demo", style = "align:center"),
#         tags$img(
#           src = "https://www.r-project.org/logo/Rlogo.png", width = 100
#         )
#       ),
#     # add information on bottom ?
#     tags_bottom = tags$div(
#       tags$p(
#         "For any question, please  contact ",
#         tags$a(
#           href = "mailto:someone@example.com?Subject=Shiny%20aManager",
#           target="_top", "administrator"
#         )
#       )
#     ),
#     # change auth ui background ?
#     # https://developer.mozilla.org/fr/docs/Web/CSS/background
#     background  = "linear-gradient(rgba(0, 0, 255, 0.5),
#                        rgba(255, 255, 0, 0.5)),
#                        url('https://www.r-project.org/logo/Rlogo.png');",
#     choose_language = TRUE
#   ),
# 
#   # result of authentication
#   verbatimTextOutput(outputId = "res_auth"),
# 
#   # classic app
#   headerPanel('Iris k-means clustering'),
#   sidebarPanel(
#     selectInput('xcol', 'X Variable', names(iris)),
#     selectInput('ycol', 'Y Variable', names(iris),
#                 selected=names(iris)[[2]]),
#     numericInput('clusters', 'Cluster count', 3,
#                  min = 1, max = 9)
#   ),
#   mainPanel(
#     plotOutput('plot1')
#   )
# )
# 
# server <- function(input, output, session) {
# 
#   # authentication module
#   auth <- callModule(
#     module = auth_server,
#     id = "auth",
#     check_credentials = check_credentials(credentials)
#   )
# 
#   output$res_auth <- renderPrint({
#     reactiveValuesToList(auth)
#   })
# 
#   # classic app
#   selectedData <- reactive({
# 
#     req(auth$result)  # <---- dependency on authentication result
# 
#     iris[, c(input$xcol, input$ycol)]
#   })
# 
#   clusters <- reactive({
#     kmeans(selectedData(), input$clusters)
#   })
# 
#   output$plot1 <- renderPlot({
#     palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
#               "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
# 
#     par(mar = c(5.1, 4.1, 0, 1))
#     plot(selectedData(),
#          col = clusters()$cluster,
#          pch = 20, cex = 3)
#     points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
#   })
# }
# 
# shinyApp(ui, server)
