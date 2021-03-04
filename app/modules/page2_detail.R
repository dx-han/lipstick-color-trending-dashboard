
page2_ui <- function(id) {
  ns <- NS(id)
  htmlTemplate(
    filename = "www/page2.html",
    palette_color_selector = uiOutput(ns("uiWhichColorSelector")),
    palette_distance_similarity = highchartOutput(ns("distanceSimilarity"), height = "700px"),
    palette_color_name = uiOutput(ns("uiColorName")),
    palette_word_selector = uiOutput(ns("uiWordSelector")),
    palette_word_board = uiOutput(ns("uiWordBoard")),
    palette_color_item_board = uiOutput(ns("uiItemBoard")),
    palette_item_color_name = uiOutput(ns("uiBrandColorName")),
    palette_item_brand_selector = uiOutput(ns("uiBrandSelector")),
    palette_item_selector_board = dataTableOutput(ns("itemSelectorBoard")),
    palette_item_color_sim_board = dataTableOutput(ns("itemColorSimBoard"))
  )
}


page2_server <- function(input, output, session, tables) {
  
  ns <- session$ns
  
  
  # Initialize reactive values ----
  p2.color.word.item <- reactiveValues(
    top.color.board=NULL, brand.item.board=NULL, sim.item.board=NULL
  )
  
  
  # Color selector ----
  output$uiWhichColorSelector <- renderUI({
    radioButtons(ns("whichColorSelector"), "颜色综合指数筛选", choices = c("Top5", "Top10", "Top20", "Top30"), selected = "Top5", inline = TRUE)
  })
  
  
  # Left observe color from color similarity scatter ----
  observeEvent(input$whichColorSelector, {
    p1t1 <- tables$p1()$t1
    if (input$whichColorSelector == "Top5") {
      this.color.board <- na.omit(p1t1[time_period == max(p1t1$time_period)][order(-total_index)][1:5])
    } else if (input$whichColorSelector == "Top10") {
      this.color.board <- na.omit(p1t1[time_period == max(p1t1$time_period)][order(-total_index)][1:10])
    } else if (input$whichColorSelector == "Top20") {
      this.color.board <- na.omit(p1t1[time_period == max(p1t1$time_period)][order(-total_index)][1:20])
    } else if (input$whichColorSelector == "Top30") {
      this.color.board <- na.omit(p1t1[time_period == max(p1t1$time_period)][order(-total_index)][1:30])
    }
    print(this.color.board)
    p2.color.word.item$top.color.board <- this.color.board
  })
  
  
  # Left HC distance similarity ----
  output$distanceSimilarity <- renderHighchart({
    if (is.null(p2.color.word.item$top.color.board)) return()
    # dt <- page1t1[time_period %in% "202006" & price_tag == "100以下" & age_level == "90后"]
    dt.with.pca <- dimension.reduction(p2.color.word.item$top.color.board)
    rgb.set <- sapply(dt.with.pca$color_rgb, function(x) {
      x.split <- str_split(x, ",")
      paste0("rgb(", str_sub(x.split[[1]][1], 2), ",", x.split[[1]][2], ",", str_sub(x.split[[1]][3], 1, -2), ")")
    })
    
    hchart(dt.with.pca, "scatter", hcaes(x=RC1, y=RC2, group=color_name), color = rgb.set) %>%
      hc_tooltip(enabled = T, headerFormat = "<b>{series.name}</b><br>", pointFormat = "") %>%
      hc_legend(enabled = F) %>%
      hc_xAxis(labels = list(enabled = F), lineWidth = 0, tickWidth = 0, title = list(text = "颜色使用HSB表示，经过平铺处理后映射到二维平面，两颜色距离越近表示两颜色越相似。")) %>%
      hc_yAxis(gridLineWidth = 0, labels = list(enabled = F), title = list(enabled = F)) %>%
      hc_add_event_series(series="scatter", event = "click")
  })
  
  
  # Right observe color react ----
  observeEvent(input$distanceSimilarity_click, {
    color.name <- input$distanceSimilarity_click$name
    
    output$uiColorName <- renderUI({
      tagList(
        tags$h5(color.name, style="color: #fff")
      )
    })
    
    output$uiWordSelector <- renderUI({
      tagList(
        material_radio_button(ns("isHotUpWord"), "选择计算逻辑", choices = c("热词", "窜升词"), selected = "热词")
      )
    })
    
    output$uiWordBoard <- renderUI({
      tagList(
        dataTableOutput(ns("wordBoard"))
      )
    })
    
    output$uiItemBoard <- renderUI({
      tagList(
        dataTableOutput(ns("itemBoard"))
      )
    })
    
    output$uiBrandColorName <- renderUI({
      tagList(
        tags$h5(color.name, style="color: #fff")
      )
    })
    
    output$uiBrandSelector <- renderUI({
      if (nrow(tables$p2()$t5) == 0) return()
      p2t5 <- tables$p2()$t5
      this.item.brand.item.board.brand <- unique(p2t5[time_period == max(p2t5$time_period) & color_name %in% color.name]$brand)
      tagList(
        render_material_from_server(
          material_dropdown(ns("itemBrandSelector"), label = "品牌", choices = this.item.brand.item.board.brand, selected = this.item.brand.item.board.brand[1],  color = "#fff")
        )
      )
    })
  })
  
  
  # Right observe item to find other items with similar color ----
  observeEvent(input$itemSelectorBoard_rows_selected, {
    p2t5 <- tables$p2()$t5
    this.item.name <- p2.color.word.item$brand.item.board[input$itemSelectorBoard_rows_selected]$std_name
    p2.color.word.item$sim.item.board <- find_sim_color(p2t5, this.item.name)
  })
  
  
  # Right Tab1 DT word board ----
  output$wordBoard <- renderDataTable({
    if (is.null(input$distanceSimilarity_click)) return()
    p1t2 <- tables$p1()$t2
    color.name <- input$distanceSimilarity_click$name
    if (input$isHotUpWord == "热词") {
      this.up.hot.board <- p1t2[time_period == max(p1t2$time_period)][color_name %in% color.name][order(-total_index)][, .(word=se_word, index=total_index, rgb=color_rgb)]
      p2.color.word.item$word.board <- this.up.hot.board
      this.up.hot.board.column <- c("热词", "指数")
    } else {
      this.up.hot.board <- p1t2[time_period == max(p1t2$time_period)][color_name %in% color.name][order(-growth_index)][, .(word=se_word, index=growth_index, rgb=color_rgb)]
      p2.color.word.item$word.board <- this.up.hot.board
      this.up.hot.board.column <- c("窜升词", "指数")
    }
    
    datatable(
      this.up.hot.board[, .(word, index)],
      class = "stripe compact hover nowrap",
      selection = c("none"),
      rownames = F,
      colnames = this.up.hot.board.column,
      options = list(searching = F, paging = F, ordering = F, info = F, scrollY = "200px", scroller = F, autoWidth = F,
                     columnDefs=list(list("width"="5%", targets = 0:1), list(className="dt-center", targets = "_all")),
                     initComplete = JS(
                       "function(settings, json) {",
                       "$(this.api().table().header()).css({'background-color': '#272733', 'color': '#fff'});",
                       "}"
                     )
      )
    ) %>% 
      formatStyle(
        columns = "word",
        target = "row",
        backgroundColor = "#272733",
        color = "rgb(255,255,255,0.8)"
      )
  })
  
  
  # Right Tab1 DT item board ----
  output$itemBoard <- renderDataTable({
    if (is.null(input$distanceSimilarity_click)) return()
    
    p1t3 <- tables$p1()$t3
    color.name <- input$distanceSimilarity_click$name
    this.item.board <- p1t3[time_period == max(p1t3$time_period)][color_name %in% color.name][order(-total_index)]
  
    datatable(
      this.item.board[, .(brand, std_name, total_index)],
      class = "stripe compact hover",
      selection = c("none"),
      rownames = F,
      colnames = c("品牌", "单品名称", "指数"),
      options = list(searching = F, paging = F, ordering = F, info = F, scrollY = "350px", scroller = F, autoWidth = F,
                     columnDefs=list(list("width"="5%", targets = 0:2), list(className="dt-center", targets = "_all")),
                     initComplete = JS(
                       "function(settings, json) {",
                       "$(this.api().table().header()).css({'background-color': '#272733', 'color': '#fff'});",
                       "}"
                     )
      )
    ) %>% 
      formatStyle(
        columns = "std_name",
        target = "row",
        backgroundColor = "#272733",
        color = "rgb(255,255,255,0.8)"
      )
  })
  
  
  # Right Tab2 DT item table ----
  output$itemSelectorBoard <- renderDataTable({
    if (is.null(input$itemBrandSelector)) return()
    p2t5 <- tables$p2()$t5
    this.brand.item.board <- p2t5[time_period == max(p2t5$time_period)][order(-total_index)][brand %in% input$itemBrandSelector & color_name %in% input$distanceSimilarity_click]
    p2.color.word.item$brand.item.board <- this.brand.item.board
    datatable(
      this.brand.item.board[, .(img_url, std_name, total_index)],
      class = "stripe compact hover",
      selection = list(mode = "single", selected = c(1)),
      rownames = F,
      escape = F,
      colnames = c("", "单品名称", "指数"),
      options = list(searching = F, paging = F, ordering = F, info = F, scrollY = "200px", scroller = F, autoWidth = F,
                     columnDefs=list(list("width"="5%", targets = 0:2), list(className="dt-center", targets = "_all")),
                     initComplete = JS(
                       "function(settings, json) {",
                       "$(this.api().table().header()).css({'background-color': '#272733', 'color': '#fff'});",
                       "}"
                     )
      )
    ) %>%
      formatStyle(
        columns = "std_name",
        target = "row",
        backgroundColor = "#272733",
        color = "rgb(255,255,255,0.8)"
      )
  })
  
  
  # Right Tab2 DT compared item table ----
  output$itemColorSimBoard <- renderDataTable({
    if (is.null(p2.color.word.item$sim.item.board)) return()
    this.sim.item.board <- na.omit(p2.color.word.item$sim.item.board[1:5])
    print(this.sim.item.board)
    
    datatable(
      this.sim.item.board[, .(img_url, std_name, total_index)],
      class = "stripe compact hover",
      selection = list(mode = "none"),
      rownames = F,
      escape = F,
      colnames = c("", "单品名称", "指数"),
      options = list(searching = F, paging = F, ordering = F, info = F, scrollY = "200px", scroller = F, autoWidth = F,
                     columnDefs=list(list("width"="5%", targets = 0:2), list(className="dt-center", targets = "_all")),
                     initComplete = JS(
                       "function(settings, json) {",
                       "$(this.api().table().header()).css({'background-color': '#272733', 'color': '#fff'});",
                       "}"
                     )
      )
    ) %>%
      formatStyle(
        columns = "std_name",
        target = "row",
        backgroundColor = "#272733",
        color = "rgb(255,255,255,0.8)"
      )
  })
}
