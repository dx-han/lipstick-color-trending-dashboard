
page1_ui <- function(id) {
  ns <- NS(id)
  htmlTemplate(
    filename = "www/page1.html",
    color_series_selector =  uiOutput(ns("uiSeriesSelector")),
    color_radio_selector = material_radio_button(ns("isTotalUpColor"), "选择指数", choices = c("综合指数Top10", "窜升指数Top10"), selected = "综合指数Top10"),
    color_board = dataTableOutput(ns("colorBoard")),
    color_trend = highchartOutput(ns("colorTrend"), height = "30%"),
    color_hue_bar = highchartOutput(ns("colorHueBar")),
    color_show = uiOutput(ns("colorShow")),
    current_color = uiOutput(ns("currentColor")),
    current_color_img = imageOutput(ns("lipstickImage")),
    compare_with_another_color_selector = uiOutput(ns("uiAnotherColorSelector")),
    color_radar1 = highchartOutput(ns("colorRadar1"), height = "50%"),
    color_radar2 = highchartOutput(ns("colorRadar2"), height = "50%"),
    radio_selector = material_radio_button(ns("isHotUpWord"), "选择计算逻辑", choices = c("热词", "窜升词"), selected = "热词"),
    word_board = dataTableOutput(ns("wordBoard"), height = "60%"),
    word_trend = highchartOutput(ns("wordTrend"), height = "60%"),
    item_board = dataTableOutput(ns("itemBoard"), height = "60%")
  )
}


page1_server <- function(input, output, session, tables) {
  
  ns <- session$ns
  
  
  # initialize reactive values ----
  table.select.value <- reactiveValues(color = NULL, word = NULL, item = NULL, word.board = NULL, p1t1.with.hue.category = NULL, color.set = NULL)
  
  
  # observe color from color board ----
  observeEvent(input$loadColor, {
    print(paste0("clicked", input$loadColor))
    table.select.value$color <- str_split(input$loadColor, "\n")[[1]][1]
    output$currentColor <- renderUI({
      tagList(
        tags$h5(table.select.value$color, style="color: #fff")
      )
    })
    # Lipstick color ----
    output$lipstickImage <- renderImage({
      print(paste0("draw",input$loadColor))
      
      str.rgb <- str_split(input$loadColor, "rgb")[[1]][2]
      rgb.value <- c(as.integer(str_sub(str_split(str.rgb,",")[[1]][1],2)), as.integer(str_split(str.rgb,",")[[1]][2]), as.integer(str_sub(str_split(str.rgb,",")[[1]][3],1,-2)))
      generate.color.pic.selected(rgb.value)
      list(src="www/img/lipstick_ready.png", contentType="image/png", width=100, height=50, alt="22")
    }, deleteFile=FALSE)
    
    session$sendCustomMessage("colorToDetail", "True")
    
    # Another color selector
    output$uiAnotherColorSelector <- renderUI({
      if (nrow(tables$p1()$t1) == 0) return()
      p1t1 <- tables$p1()$t1
      this.color.board <- p1t1[time_period == max(p1t1$time_period)]
      # other.color <- this.color.board$color_name[this.color.board$color_name != table.select.value$color]
      other.color <- this.color.board$color_name
      print(paste0("选择待比较颜色",other.color))
      tagList(
        render_material_from_server(
          material_dropdown(ns("anotherColorSelector"), label = "选择待比较颜色", choices = other.color, selected = other.color[1], color = "#fff")
        )
      )
    })
  })
  
  
  # observe word from word board ----
  observeEvent(input$wordBoard_rows_selected, {
    table.select.value$word <- table.select.value$word.board[input$wordBoard_rows_selected]$word
  })
  
  
  # Color series selector ----
  output$uiSeriesSelector <- renderUI({
    if (nrow(tables$p1()$t1) == 0) return()
    p1t1 <- tables$p1()$t1
    this.color.board <- p1t1[time_period == max(p1t1$time_period)]
    color.series <- c("全部", unique(this.color.board$color_series))
    print(paste0("选择色系",color.series))
    tagList(
      render_material_from_server(
        material_dropdown(ns("seriesSelector"), label = "选择色系", choices = color.series, selected = color.series[1], color = "#fff")
      )
    )
  })
  
  
  # DT color board ----
  output$colorBoard <- renderDataTable({
    if (nrow(tables$p1()$t1) == 0) return()
    if (is.null(input$seriesSelector)) return()
    p1t1 <- tables$p1()$t1
    if (input$seriesSelector == "全部") {
      this.color.board <- p1t1[time_period == max(p1t1$time_period)]
    } else {
      this.color.board <- p1t1[time_period == max(p1t1$time_period)][color_series %in% input$seriesSelector]
    }
    rgb.set <- sapply(this.color.board$color_rgb, function(x) {
      x.split <- str_split(x, ",")
      paste0("rgb(", str_sub(x.split[[1]][1], 2), ",", x.split[[1]][2], ",", str_sub(x.split[[1]][3], 1, -2), ")")
    })
    
    datatable(
      this.color.board[, .(color_name)],
      class = "stripe hover nowrap",
      selection = c("none"),
      rownames = F,
      colnames = c(""),
      options = list(
        searching = F, paging = F, ordering = F, info = F, scrollY = "250px", scroller = F, autoWidth = F,
        columnDefs = list(list(width="1%", targets = 0), list(className="dt-center", targets = "_all")),
        initComplete = JS(
          "function(settings, json) {",
          "$(this.api().table().header()).css({'background-color': '#272733', 'color': '#fff'});",
          "}"
        )
      )
    ) %>%
      formatStyle(
          columns = "color_name", 
          target = "row", 
          backgroundColor = styleEqual(this.color.board$color_name, rgb.set), 
          color = "rgb(255, 255, 255, 0.8)"
        )
  })
  
  
  # HC color trend ----
  output$colorTrend <- renderHighchart({
    if (nrow(tables$p1()$t1) == 0) return()
    if (is.null(input$seriesSelector)) return()
    p1t1 <- tables$p1()$t1
    if (input$seriesSelector == "全部") {
      if (input$isTotalUpColor == "综合指数Top10") {
        total.color.name <- p1t1[time_period == max(p1t1$time_period)][order(-total_index)][1:10]$color_name
        
        this.color.trend <- p1t1[color_name %in% total.color.name][order(time_period), .(color_name=color_name, index=total_index, time_period=time_period, color_rgb=color_rgb)]
      } else {
        total.color.name <- p1t1[time_period == max(p1t1$time_period)][order(-up_index)][1:10]$color_name
        this.color.trend <- p1t1[color_name %in% total.color.name][order(time_period), .(color_name=color_name, index=up_index, time_period=time_period, color_rgb=color_rgb)]
      }
    } else {
      if (input$isTotalUpColor == "综合指数Top10") {
        total.color.name <- p1t1[time_period == max(p1t1$time_period) & color_series %in% input$seriesSelector][order(-total_index)][1:10]$color_name
        
        this.color.trend <- p1t1[color_name %in% total.color.name][order(time_period), .(color_name=color_name, index=total_index, time_period=time_period, color_rgb=color_rgb)]
      } else {
        total.color.name <- p1t1[time_period == max(p1t1$time_period) & color_series %in% input$seriesSelector][order(-up_index)][1:10]$color_name
        this.color.trend <- p1t1[color_name %in% total.color.name][order(time_period), .(color_name=color_name, index=up_index, time_period=time_period, color_rgb=color_rgb)]
      }
    }
    rgb.set <- sapply(sort(unique(this.color.trend$color_name)), function(x) {
      x <- this.color.trend[color_name == x]$color_rgb[1]
      x.split <- str_split(x, ",")
      paste0("rgb(", str_sub(x.split[[1]][1], 2), ",", x.split[[1]][2], ",", str_sub(x.split[[1]][3], 1, -2), ")")
    })
    time.period <- sort(unique(this.color.trend$time_period))
    
    hchart(this.color.trend, "spline", hcaes(x = time_period, y = index, group = color_name), color=rgb.set) %>%
      hc_chart(height = "80%", backgroundColor = "#272733") %>%
      hc_xAxis(categories = time.period, title = list(enabled = F), labels = list(enabled = T, style=list(color="#fff"))) %>%
      hc_yAxis(gridLineWidth = 0, title = list(enabled = F)) %>%
      hc_legend(enabled = T, align = "left", verticalAlign = "bottom", itemStyle = list(color = "#fff")) %>%
      hc_title(text = "颜色指数趋势", style = list(color = "#fff"), align = "left")
  })
  
  
  # HC color hue bar ----
  output$colorHueBar <- renderHighchart({
    if (nrow(tables$p1()$t1) == 0) return()
    p1t1 <- tables$p1()$t1
    table.select.value$p1t1.with.hue.category <- add.hue.category(p1t1, hsb.hue.bar)
    
    hsb.hue.bar.agg <- merge(hsb.hue.bar, table.select.value$p1t1.with.hue.category[, .(N=n_distinct(color_name)), by=hue_category], by = "hue_category", all.x = T)[!is.na(N)]
    hchart(hsb.hue.bar.agg, "bar", hcaes(group = hue_category, y = N), color = hsb.hue.bar.agg$hsb_rgb) %>%
      hc_tooltip(enabled = F) %>%
      hc_legend(enabled = F) %>%
      hc_xAxis(labels = list(enabled = F), lineWidth = 0, tickWidth = 0) %>%
      hc_yAxis(gridLineWidth = 0, labels = list(enabled = F), title = list(enabled = F)) %>%
      hc_plotOptions(
        bar = list(
          borderWidth = 0, borderRadius = 5, groupPadding = 0, dataLabels = list(enabled = F, color = "#fff")
        )
      ) %>%
      hc_add_event_series(series="bar", event = "click")
  })
  
  
  # DT color show ----
  output$colorShow <- renderUI({
    if (is.null(input$colorHueBar_click)) return()
    this.color <- table.select.value$p1t1.with.hue.category[hue_category %in% input$colorHueBar_click$name]
    table.select.value$color.set <- paste0(unique(sapply(paste0(this.color$color_rgb, "#", this.color$color_name), function(x) {
      x.split <- str_split(x, "#")
      color.split <- str_split(x.split[[1]][1], ",")
      paste0(rgb(str_sub(color.split[[1]][1], 2), color.split[[1]][2], str_sub(color.split[[1]][3], 1, -2), maxColorValue=255), x.split[[1]][2])
    })), collapse=",")
    print(paste0("palette",table.select.value$color.set))
    
    htmlTemplate(
      filename = "www/page1_palette.html",
      color_set = table.select.value$color.set,
      hsb_range = unique(this.color$hsb_range)
    )
  })
  
  
  # HC color radar1 ----
  output$colorRadar1 <- renderHighchart({
    if (is.null(table.select.value$color) || is.null(input$anotherColorSelector)) return()
    p1t1 <- tables$p1()$t1
    this.radar.table <- p1t1[time_period == max(p1t1$time_period)][color_name %in% table.select.value$color]
    this.radar.color <- paste0("rgb(", str_sub(str_split(this.radar.table$color_rgb, ",")[[1]][1], 2), ",", str_split(this.radar.table$color_rgb, ",")[[1]][2], ",", str_sub(str_split(this.radar.table$color_rgb, ",")[[1]][3], 1, -2), ")")
    print(paste0("another color ",input$anotherColorSelector))
    another.radar.table <- p1t1[time_period == max(p1t1$time_period)][color_name %in% input$anotherColorSelector]
    print(paste0("another color table ",another.radar.table$color_rgb))
    another.radar.color <- paste0("rgb(", str_sub(str_split(another.radar.table$color_rgb, ",")[[1]][1], 2), ",", str_split(another.radar.table$color_rgb, ",")[[1]][2], ",", str_sub(str_split(another.radar.table$color_rgb, ",")[[1]][3], 1, -2), ")")
    
    # this.radar.table <- page1t1[time_period %in% "202006" & price_tag == "100以下" & age_level == "90后" & color_name == "酒红" & time_period == max(page1t1$time_period)]
    highchart() %>%
      hc_chart(height = "70%", polar = T, type = "line", backgroundColor = "#272733") %>%
      hc_add_series(name = table.select.value$color, color = this.radar.color, data = as.numeric(
        this.radar.table[, .(
          size_index, pay_amt_index, purchase_index
        )]
      )) %>%
      hc_add_series(name = input$anotherColorSelector, color = another.radar.color, data = as.numeric(
        another.radar.table[, .(
          size_index, pay_amt_index, purchase_index
        )]
      )) %>%
      hc_xAxis(categories = c(
        "市场占有度指数", "产品丰富度指数", "价格指数"
        ),
        tickmarkPlacement = "on", lineWidth = 0, labels = list(style=list(color="#fff")), gridLineColor = "#616161") %>%
      hc_yAxis(gridLineInterpolation = "polygon", gridLineColor = "#616161") %>%
      hc_legend(enabled = T, align = "middle", layout = "horizontal", verticalAlign = "top", itemStyle = list(color = "#fff")) %>%
      hc_tooltip(headerFormat = "{series.name}<br>{point.x}", pointFormat = ": {point.y}")
  })
  
  
  # HC color radar2 ----
  output$colorRadar2 <- renderHighchart({
    if (is.null(table.select.value$color) || is.null(input$anotherColorSelector)) return()
    p1t1 <- tables$p1()$t1
    this.radar.table <- p1t1[time_period == max(p1t1$time_period)][color_name %in% table.select.value$color]
    this.radar.color <- paste0("rgb(", str_sub(str_split(this.radar.table$color_rgb, ",")[[1]][1], 2), ",", str_split(this.radar.table$color_rgb, ",")[[1]][2], ",", str_sub(str_split(this.radar.table$color_rgb, ",")[[1]][3], 1, -2), ")")
    another.radar.table <- p1t1[time_period == max(p1t1$time_period)][color_name %in% input$anotherColorSelector]
    another.radar.color <- paste0("rgb(", str_sub(str_split(another.radar.table$color_rgb, ",")[[1]][1], 2), ",", str_split(another.radar.table$color_rgb, ",")[[1]][2], ",", str_sub(str_split(another.radar.table$color_rgb, ",")[[1]][3], 1, -2), ")")
    
    highchart() %>%
      hc_chart(height = "70%", polar = T, type = "line", backgroundColor = "#272733") %>%
      hc_add_series(name = table.select.value$color, color = this.radar.color, data = as.numeric(
        this.radar.table[, .(
          repurchase_index, like_index, pro_cnt_index
        )]
      )) %>%
      hc_add_series(name = input$anotherColorSelector, color = another.radar.color, data = as.numeric(
        another.radar.table[, .(
          repurchase_index, like_index, pro_cnt_index
        )]
      )) %>%
      hc_xAxis(categories = c(
        "复购指数", "评价指数", "流行潜力指数"
      ),
      tickmarkPlacement = "on", lineWidth = 0, labels = list(style=list(color="#fff")), gridLineColor = "#616161") %>%
      hc_yAxis(gridLineInterpolation = "polygon", gridLineColor = "#616161") %>%
      hc_legend(enabled = T, align = "middle", layout = "horizontal", verticalAlign = "top", itemStyle = list(color = "#fff")) %>%
      hc_tooltip(headerFormat = "{series.name}<br>{point.x}", pointFormat = ": {point.y}")
  })
  
  
  # DT word board ----
  output$wordBoard <- renderDataTable({
    if (is.null(input$loadColor)) return()
    p1t2 <- tables$p1()$t2
    if (input$isHotUpWord == "热词") {
      this.hot.up.board <-  p1t2[time_period == max(p1t2$time_period)][order(-total_index)][color_name %in% table.select.value$color, .(word=se_word, index=total_index, rgb=color_rgb)]
      table.select.value$word.board <- this.hot.up.board
      this.column <- c("热词", "指数")
    } else {
      this.hot.up.board <-  p1t2[time_period == max(p1t2$time_period)][order(-growth_index)][color_name %in% table.select.value$color, .(word=se_word, index=growth_index, rgb=color_rgb)]
      table.select.value$word.board <- this.hot.up.board
      this.column <- c("窜升词", "指数")
    }
    rgb.set <- sapply(this.hot.up.board$rgb, function(x) {
      x.split <- str_split(x, ",")
      paste0("rgb(", str_sub(x.split[[1]][1], 2), ",", x.split[[1]][2], ",", str_sub(x.split[[1]][3], 1, -2), ")")
    })
    
    datatable(
      this.hot.up.board[, .(word, index)],
      class = "stripe compact hover nowrap",
      selection = list(mode = "single", selected = c(1), target = "row"),
      rownames = F,
      height = "60%",
      colnames = this.column,
      options = list(searching = F, paging = F, ordering = F, info = F, scrollY = "300px", autoWidth = F,
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
  
  
  # HC word trend ----
  output$wordTrend <- renderHighchart({
    if (is.null(table.select.value$word)) return()
    p1t2 <- tables$p1()$t2
    this.word.trend <- p1t2[color_name %in% table.select.value$color & se_word %in% table.select.value$word]
    time.period <- unique(this.word.trend$time_period)
    
    this.word.color <- paste0("rgb(", str_sub(str_split(this.word.trend$color_rgb, ",")[[1]][1], 2), ",", str_split(this.word.trend$color_rgb, ",")[[1]][2], ",", str_sub(str_split(this.word.trend$color_rgb, ",")[[1]][3], 1, -2), ")")
    
    hchart(this.word.trend, "spline", hcaes(x = time_period, y = total_index, group = se_word), color = this.word.color) %>%
      hc_chart(height = "80%", backgroundColor = "#272733") %>%
      hc_xAxis(categories = time.period, title = list(enabled = F), labels = list(enabled = T, style=list(color="#fff"))) %>%
      hc_yAxis(gridLineWidth = 0, title = list(enabled = F)) %>%
      hc_legend(enabled = T, align = "left", verticalAlign = "bottom", itemStyle = list(color = "#fff")) %>%
      hc_title(text = "当前搜索词指数趋势", style = list(color = "#fff"), align = "left")
  })
  
  
  # DT item board ----
  output$itemBoard <- renderDataTable({
    if (is.null(table.select.value$color)) return()

    p1t3 <- tables$p1()$t3
    this.item.board <- p1t3[time_period == max(p1t3$time_period)][color_name %in% table.select.value$color][order(-total_index)]
    
    datatable(
      this.item.board[, .(brand, std_name, total_index)],
      class = "stripe compact hover",
      selection = list(mode = "single", selected = c(1), target = "row"),
      rownames = F,
      height = "60%",
      colnames = c( "品牌", "单品名称", "指数"),
      options = list(searching = F, paging = F, ordering = F, info = F, scrollY = "300px", autoWidth = F,
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
