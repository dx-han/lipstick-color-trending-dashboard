# tmp <- page1t1[1]
# highchart() %>%
#   hc_chart(polar = TRUE, type = "line") %>%
#   hc_xAxis(categories = c("a", "b", "c", "d", "e", "f"), tickmarkPlacement = "on", lineWidth = 0) %>%
#   hc_yAxis(gridLineInterpolation = "polygon") %>%
#   hc_tooltip(pointFormat = "{point.key} 233 {point.y} 233 {series.name}") %>%
#   hc_legend(align = "center", layout = "horizontal") %>%
#   hc_add_series(name = "testa", data = c(1,2,3,4,2,1)) %>%
#   hc_add_series(name = "testb", data = c(2,1,4,3,1,2))
# 
# 
# output$colorBoard <- renderDataTable({
#   color.board.table <- tables$p1()$t1
#   # color.board.table <- page1t1
#   rgb.set <- sapply(unique(color.board.table$color_rgb), function(x) {
#     x.split <- str_split(x, ",")
#     paste0("rgb(", str_sub(x.split[[1]][1], 2), ",", x.split[[1]][2], ",", str_sub(x.split[[1]][3], 1, -2), ")")
#   })
#   datatable(
#     color.board.table[,.(color_name, total_index)],
#     options = list(searching = FALSE, paging = FALSE, ordering = FALSE, info = FALSE, scrollY = "350px",
#                    initComplete = JS(
#                      "function(settings, json) {",
#                      "$(this.api().table().header()).css({'background-color': '#272733', 'color': '#fff'});",
#                      "}"
#                    ),
#                    autoWidth = FALSE,
#                    rowCallback = JS('function(row, data) {
#                                          $(row).hover(function(){
#                                              var hover_index = $(this)[0]._DT_RowIndex;
#                                              Shiny.onInputChange("page1-hoverIndexJS", hover_index);
#                                         });
#                                     }'),
#                    columnDefs=list(list("width"="5%", targets = 0:1), list(className="dt-center", targets = "_all"))),
#     rownames = FALSE,
#     colnames = c("颜色", "指数"),
#     selection = list(mode = "single", selected = matrix(c(1, 1), ncol = 2), target = "cell"),
#     escape = FALSE,
#     class = "stripe compact hover nowrap"
#   ) %>%
#     formatStyle(
#       columns = "color_name", 
#       target = "row", 
#       backgroundColor = styleEqual(unique(color.board.table$color_name), rgb.set), 
#       color = "rgb(255,255,255,0.8)"
#     )
# })
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# nav.part <- bs4DashNavbar(
#   skin = "light",
#   status = NULL,
#   border = TRUE,
#   sidebarIcon = "bars",
#   compact = FALSE,
#   leftUi = NULL,
#   rightUi = NULL,
#   fixed = TRUE
# )
# 
# sidebar.part <- bs4DashSidebar(
#   skin = "light",
#   status = "primary",
#   title = "口红颜色流行趋势",
#   brandColor = "primary",
#   url = "#",
#   elevation = 3,
#   opacity = 0.8,
#   fixed = TRUE,
#   bs4SidebarMenu(
#     bs4SidebarMenuItem("颜色", tabName = "page1", icon = "palette"),
#     bs4SidebarMenuItem("搜索热词", tabName = "page2", icon = "search-dollar"),
#     bs4SidebarMenuItem("品牌产品", tabName = "page3", icon = "random")
#   )
# )
# 
# body.part <- bs4DashBody(
#   bs4TabItems(
#     bs4TabItem(tabName="page1", 123),
#     bs4TabItem(tabName="page2", 456),
#     bs4TabItem(tabName="page3", 789)
#   )
# )
# 
# 
# 
# ui = bs4DashPage(
#   sidebar_mini = TRUE,
#   title = "口红颜色流行趋势看板",
#   navbar = nav.part,
#   sidebar = sidebar.part,
#   body = body.part
# )
# 
# 
# tags$h5(paste0("当前选色:", str_split(input$react, "\n")[[1]][1]), style=paste0("color:", str_split(input$react, "\n")[[1]][2], ";-webkit-text-stroke:0.2px #272733")),
# 
# 


# output$cloudWord <- renderHighchart({
#   if (is.null(input$colorBoard_rows_selected)) return()
#   p1t2 <- tables$p1()$t2
#   this.hot.up.board <-  p1t2[time_period == max(p1t2$time_period)][color_name %in% table.select.value$color, .(word=se_word, freq=uv_index, rgb=color_rgb)]
#   this.color <- this.hot.up.board$rgb[1]
#   this.rgb <- paste0("rgb(", str_sub(str_split(this.color, ",")[[1]][1], 2), ",", str_split(this.color, ",")[[1]][2], ",", str_sub(str_split(this.color, ",")[[1]][3], 1, -2), ")")
#   hchart(this.hot.up.board, "wordcloud", hcaes(name = word, weight = freq)) %>%
#     hc_plotOptions(wordcloud = list(colorByPoint = F, color = this.rgb)) %>%
#     hc_tooltip(pointFormat = "词频:{point.weight}")
# })





# generate.color.pic.selected <- function(img.path, obj.rgb.color) {
#   # img <- image_read("www/img/lipstick.png")
#   img <- load.image("www/img/lipstick.png")
#   
#   origin.rgb.color <- data.table(159,65,66)
#   origin.lab.color <- convert_colour(origin.rgb.color, "rgb", "lab")
#   
#   obj.rgb.color <- data.table(193,102,96)
#   obj.lab.color <- convert_colour(obj.rgb.color, "rgb", "lab")
#   
#   diff.l <- obj.lab.color$l - origin.lab.color$l
#   diff.a <- obj.lab.color$a - origin.lab.color$a
#   diff.b <- obj.lab.color$b - origin.lab.color$b
#   
#   img <- img[,,1,1:3]
#   test <- img[120:121,10:11,1,1:3]
#   for (row in 1:nrow(img)) {
#     for (col in 1:nrow(img[row,,])) {
#       if (sum(img[row,col,1:3]) != 0) {
#         convert.lab.color <- convert_colour(data.table(img[row,col,1]*256, img[row,col,2]*256, img[row,col,3]*256), "rgb", "lab")
#         convert.rgb.color <- convert_colour(data.table(convert.lab.color$l + diff.l, convert.lab.color$a + diff.a, convert.lab.color$b + diff.b), "lab", "rgb")
#         img[row,col,1] <- convert.rgb.color$r / 256
#         img[row,col,2] <- convert.rgb.color$g / 256
#         img[row,col,3] <- convert.rgb.color$b / 256
#       }
#     }
#   }
#   
#   if (img[1,1,1:3] == c(0,0,0)) {
#     print(1)
#   } else {
#     print(2)
#   }
#   img[120,50,1:3]
#   convert_colour(img)
#   decode_colour(rainbow(10))
# }





# dt.with.pca <- dimension.reduction(this.color.table)
# rgb.set <- sapply(dt.with.pca$color_rgb, function(x) {
#   x.split <- str_split(x, ",")
#   paste0("rgb(", str_sub(x.split[[1]][1], 2), ",", x.split[[1]][2], ",", str_sub(x.split[[1]][3], 1, -2), ")")
# })
# browser()

# hchart(dt.with.pca, "scatter", hcaes(x=RC1, y=RC2, group=color_name), color = rgb.set) %>%
#   hc_chart(borderColor = "#363847", borderWidth=8, height="500px") %>%
#   hc_tooltip(enabled = T, headerFormat = "<b>{series.name}</b><br>", pointFormat = "") %>%
#   hc_legend(enabled = F) %>%
#   hc_xAxis(labels = list(enabled = F), lineWidth = 0, tickWidth = 0, title = list(enabled=F,text = "颜色使用HSB表示，经过平铺处理后映射到二维平面，两颜色距离越近表示两颜色越相似。")) %>%
#   hc_yAxis(gridLineWidth = 0, labels = list(enabled = F), title = list(enabled = F)) %>%
#   hc_add_event_series(series="scatter", event = "click")

# hchart(this.color.hue.bar, "bar", hcaes(group = hue_category, y = N), color = this.color.hue.bar$hsb_rgb) %>%
#   hc_tooltip(enabled = F) %>%
#   hc_legend(enabled = F) %>%
#   hc_xAxis(labels = list(enabled = F), lineWidth = 0, tickWidth = 0) %>%
#   hc_yAxis(gridLineWidth = 0, labels = list(enabled = F), title = list(enabled = F)) %>%
#   hc_plotOptions(
#     bar = list(
#       borderWidth = 0, borderRadius = 5, groupPadding = 0, dataLabels = list(enabled = T, color = "#fff", align = "right", style = list("textOutline"=0))
#     )
#   ) %>%
#   hc_add_event_series(series="bar", event = "click")


credentials <- data.frame(
  user = c("fanny", "victor"),
  password = c(scrypt::hashPassword("azerty"), scrypt::hashPassword("12345")),
  is_hashed_password = TRUE,
  comment = c("alsace", "auvergne"),
  stringsAsFactors = FALSE
)

# app
ui <- fluidPage(
  
  # authentication module
  auth_ui(
    id = "auth",
    # add image on top ?
    tags_top =
      tags$div(
        tags$h4("Demo", style = "align:center"),
        tags$img(
          src = "https://www.r-project.org/logo/Rlogo.png", width = 100
        )
      ),
    # add information on bottom ?
    tags_bottom = tags$div(
      tags$p(
        "For any question, please  contact ",
        tags$a(
          href = "mailto:someone@example.com?Subject=Shiny%20aManager",
          target="_top", "administrator"
        )
      )
    ),
    # change auth ui background ?
    # https://developer.mozilla.org/fr/docs/Web/CSS/background
    background  = "linear-gradient(rgba(0, 0, 255, 0.5),
                       rgba(255, 255, 0, 0.5)),
                       url('https://www.r-project.org/logo/Rlogo.png');",
    choose_language = TRUE
  ),
  
  # result of authentication
  verbatimTextOutput(outputId = "res_auth"),
  
  # classic app
  headerPanel('Iris k-means clustering'),
  sidebarPanel(
    selectInput('xcol', 'X Variable', names(iris)),
    selectInput('ycol', 'Y Variable', names(iris),
                selected=names(iris)[[2]]),
    numericInput('clusters', 'Cluster count', 3,
                 min = 1, max = 9)
  ),
  mainPanel(
    plotOutput('plot1')
  )
)

server <- function(input, output, session) {
  
  # authentication module
  auth <- callModule(
    module = auth_server,
    id = "auth",
    check_credentials = check_credentials(credentials)
  )
  
  output$res_auth <- renderPrint({
    reactiveValuesToList(auth)
  })
  
  # classic app
  selectedData <- reactive({
    
    req(auth$result)  # <---- dependency on authentication result
    
    iris[, c(input$xcol, input$ycol)]
  })
  
  clusters <- reactive({
    kmeans(selectedData(), input$clusters)
  })
  
  output$plot1 <- renderPlot({
    palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
              "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
    
    par(mar = c(5.1, 4.1, 0, 1))
    plot(selectedData(),
         col = clusters()$cluster,
         pch = 20, cex = 3)
    points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
  })
}

shinyApp(ui, server)




function (request) 
{
  query <- parseQueryString(request$QUERY_STRING)
  token <- query$token
  admin <- query$admin
  language <- query$language
  if (!is.null(language)) {
    lan <- use_language(language)
  }
  if (.tok$is_valid(token)) {
    is_forced_chg_pwd <- is_force_chg_pwd(token = token)
    if (is_forced_chg_pwd) {
      args <- get_args(..., fun = pwd_ui)
      args$id <- "password"
      args$lan <- lan
      pwd_ui <- fluidPage(theme = theme, tags$head(head_auth), 
                          do.call(pwd_ui, args), shinymanager_where("password"), 
                          shinymanager_language(lan$get_language()))
      return(pwd_ui)
    }
    if (isTRUE(enable_admin) && .tok$is_admin(token) & identical(admin, 
                                                                 "true") & !is.null(.tok$get_sqlite_path())) {
      navbarPage(title = "Admin", theme = theme, header = tagList(tags$style(".navbar-header {margin-left: 16.66% !important;}"), 
                                                                  fab_button(actionButton(inputId = ".shinymanager_logout", 
                                                                                          label = NULL, tooltip = lan$get("Logout"), 
                                                                                          icon = icon("sign-out")), actionButton(inputId = ".shinymanager_app", 
                                                                                                                                 label = NULL, tooltip = lan$get("Go to application"), 
                                                                                                                                 icon = icon("share"))), shinymanager_where("admin")), 
                 tabPanel(title = tagList(icon("home"), lan$get("Home")), 
                          value = "home", admin_ui("admin", lan), shinymanager_language(lan$get_language())), 
                 tabPanel(title = "Logs", logs_ui("logs", lan), 
                          shinymanager_language(lan$get_language())))
    }
    else {
      if (isTRUE(enable_admin) && .tok$is_admin(token) && 
          !is.null(.tok$get_sqlite_path())) {
        menu <- fab_button(actionButton(inputId = ".shinymanager_logout", 
                                        label = NULL, tooltip = lan$get("Logout"), 
                                        icon = icon("sign-out")), actionButton(inputId = ".shinymanager_admin", 
                                                                               label = NULL, tooltip = lan$get("Administrator mode"), 
                                                                               icon = icon("cogs")))
      }
      else {
        if (isTRUE(enable_admin) && .tok$is_admin(token) && 
            is.null(.tok$get_sqlite_path())) {
          warning("Admin mode is only available when using a SQLite database!", 
                  call. = FALSE)
        }
        menu <- fab_button(actionButton(inputId = ".shinymanager_logout", 
                                        label = NULL, tooltip = lan$get("Logout"), 
                                        icon = icon("sign-out")))
      }
      save_logs(token)
      if (is.function(ui)) {
        ui <- ui(request)
      }
      tagList(ui, menu, shinymanager_where("application"), 
              shinymanager_language(lan$get_language()), singleton(tags$head(tags$script(src = "shinymanager/timeout.js"))))
    }
  }
  else {
    args <- get_args(..., fun = auth_ui)
    deprecated <- list(...)
    if ("tag_img" %in% names(deprecated)) {
      args$tags_top <- deprecated$tag_img
      warning("'tag_img' (auth_ui, secure_app) is now deprecated. Please use 'tags_top'", 
              call. = FALSE)
    }
    if ("tag_div" %in% names(deprecated)) {
      args$tags_bottom <- deprecated$tag_div
      warning("'tag_div' (auth_ui, secure_app) is now deprecated. Please use 'tags_bottom'", 
              call. = FALSE)
    }
    args$id <- "auth"
    args$lan <- lan
    fluidPage(theme = theme, tags$head(head_auth), do.call(auth_ui, 
                                                           args), shinymanager_where("authentication"), shinymanager_language(lan$get_language()))
  }
}