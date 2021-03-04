
navsidebar_ui <- function(id) {
  price.interval <- c("整体", "0-50", "0-100", "100-200", "200-300", "300+")
  age.level <- c("整体", "80前", "80后", "90后", "95后", "00后")
  ns <- NS(id)
  htmlTemplate(
    filename = "www/nav_side_bar.html",
    upload = uiOutput(ns("picUpload"))
  )
  # price_period_selector = material_dropdown(ns("price"), "价格带", choices=price.interval, selected="整体"),
  # age_period_selector = material_dropdown(ns("cohort"), "人群代际", choices=age.level, selected="整体"),
}


navsidebar_server <- function(input, output, session) {
  
  ns <- session$ns
  
  # time.period <- unique(page1t1$time_period)
  
  
  # page1.table <- reactiveValues(t1=page1t1, t2=page1t2, t3=page1t3)
  # page2.table <- reactiveValues(t1=page2t1)
  
  
  # output$thisPrice <- renderUI({
  #   radioButtons(ns("price"), "价格带", choices=price.interval, selected="50-100")
  # })
  
  
  # output$thisCohort <- renderUI({
  #   radioButtons(ns("cohort"), "人群代际", choices=age.level, selected="90后")
  # })
  
  
  # output$picUpload <- renderUI({
  #   fileInput(ns("upload"), "", accept="image/*", buttonLabel = "上传", placeholder = "请上传图片并点击图片像素获取RGB值")
  # })
  
  
  # observeEvent(input$upload, {
  #   upload <- input$upload
  #   unique.name <- paste0(as.integer(Sys.time()), upload$name)
  #   file.copy(upload$datapath, file.path("www/img/tmp", upload$name))
  #   file.rename(file.path("www/img/tmp", upload$name), file.path("www/img/tmp", unique.name))
  #   session$sendCustomMessage("cpath", unique.name)
  # })
  
  
  # observe({
  #   page1.table$t1 <- page1t1[price_interval %in% input$price & age_level %in% input$cohort]
  #   page1.table$t2 <- page1t2
  #   page1.table$t3 <- page1t3
  #   page2.table$t1 <- page2t1
  #   # print(input$price)
  #   # print(input$cohort)
  # })

  
  # return(list(
  #   p1 = reactive(page1.table),
  #   p2 = reactive(page2.table)
  # ))
}
