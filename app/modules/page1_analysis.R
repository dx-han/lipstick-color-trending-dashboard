page1_analysis_ui <- function(id) {
  ns <- NS(id)
  htmlTemplate(
    filename = "www/page1_analysis.html",
    page1_analysis_hue_bar = dataTableOutput(ns("colorHueBar")),
    page1_analysis_palette = uiOutput(ns("colorPalette")),
    page1_analysis_click_color_name = uiOutput(ns("clickColorName")),
    page1_analysis_other_color_dropdown = uiOutput(ns("otherColorDropdown")),
    page1_analysis_color_radar = highchartOutput(ns("colorRadar"), height="50%"),
    page1_analysis_word_index_selector = radioButtons(ns("indexSelector"), label="选择指数", choices=c("热词","窜升词"), selected="热词", inline=TRUE),
    page1_analysis_word_table = dataTableOutput(ns("wordTable")),
    page1_analysis_word_trend = highchartOutput(ns("wordTrend")),
    page1_analysis_item_table = dataTableOutput(ns("itemTable"))
  )
}

page1_analysis_server <- function(input, output, session, color, seword, item) {
  ns <- session$ns
  
  
  # initialize reactive values ----
  this.reactive.values <- reactiveValues(color.with.hue.bar=NULL, select.color=NULL, seword.board=NULL, hue.bar.table=NULL)
  
  
  # click color name ----
  output$clickColorName <- renderUI({
    if (is.null(input$loadColor)) return(tags$h6("请选择色号",style="color:#fff"))
    this.reactive.values$select.color <- str_split(input$loadColor, "\n")[[1]][1]
    print(str_split(input$loadColor, "\n")[[1]][1])
    print(str_split(input$loadColor, "\n")[[1]][2])
    tagList(
      tags$h6(
        HTML(paste0(
          str_split(input$loadColor, "\n")[[1]][1],"&nbsp;","<span style='height:10px;width:10px;background:",
          str_split(input$loadColor, "\n")[[1]][2],"';>&nbsp;&nbsp;&nbsp;&nbsp;</span>"
        )), class="white-text"
      )
    )
  })
  
  
  # HC color hue bar ----
  output$colorHueBar <- renderDataTable({
    this.color.hue.bar <- color[time_period == max(color$time_period) & price_interval == "整体" & age_level == "整体"]
    this.reactive.values$color.with.hue.bar <- add.hue.category(this.color.hue.bar, hsb.hue.bar)
    
    this.color.hue.bar <- merge(hsb.hue.bar, this.reactive.values$color.with.hue.bar[, .(N=n_distinct(color_name)), by=hue_category], by = "hue_category", all.x = T)[!is.na(N)]
    this.reactive.values$hue.bar <- this.color.hue.bar
    # browser()
    
    min.n <- min(this.color.hue.bar$N) - 1
    max.n <- max(this.color.hue.bar$N) + 1
    this.color.hue.bar$N_bar <- paste0('<div style="background:', 
                                       this.color.hue.bar$hsb_rgb, 
                                       ' 0% 0% / 100% 100% no-repeat;border-radius:5px;width:',
                                       80/(max.n-min.n)*(this.color.hue.bar$N-min.n),
                                       '%;"><p>',
                                       this.color.hue.bar$N,
                                       '</p></div>')
    this.reactive.values$hue.bar.table <- this.color.hue.bar
    
    datatable(
      this.color.hue.bar[, .(N_bar)],
      class = "stripe compact hover nowrap",
      selection = list(mode = "single", selected=c(1), target = "row"),
      rownames = F,
      height = "100%",
      escape = F,
      colnames = c(""),
      options = list(searching = F, paging = F, ordering = F, info = F, scrollY = "450px", autoWidth = F,
                     columnDefs=list(list(className="dt-right", targets = "_all")),
                     initComplete = JS(
                       "function(settings, json) {",
                       "$(this.api().table().header()).css({'background-color': '#272733', 'color': '#fff'});",
                       "}"
                     )
      )
    ) %>%
      formatStyle(
        columns = "N_bar",
        target = "row",
        backgroundColor = "#272733",
        color = "rgb(255,255,255,0.8)",
        lineHeight="300%"
      )
  })
  
  
  # DT color palette ----
  output$colorPalette <- renderUI({
    if (is.null(input$colorHueBar_rows_selected)) return(htmlTemplate(
      filename = "www/page1_palette.html"
    ))
    this.hue.category <- this.reactive.values$hue.bar.table[input$colorHueBar_rows_selected]$hue_category
    this.color <- this.reactive.values$color.with.hue.bar[hue_category %in% this.hue.category]
    color.set <- paste0(unique(sapply(paste0(this.color$color_rgb, "#", this.color$color_name), function(x) {
      x.split <- str_split(x, "#")
      color.split <- str_split(x.split[[1]][1], ",")
      paste0(rgb(str_sub(color.split[[1]][1], 2), color.split[[1]][2], str_sub(color.split[[1]][3], 1, -2), maxColorValue=255), x.split[[1]][2])
    })), collapse=",")

    session$sendCustomMessage("pageoneanalysis_hsb_range", unique(this.color$hsb_range))
    session$sendCustomMessage("pageoneanalysis_color_set", color.set)

    htmlTemplate(
      filename = "www/page1_palette.html"
    )
  })
  
  
  # dropdown choose other color ----
  output$otherColorDropdown <- renderUI({
    if (is.null(input$loadColor)) return()
    this.color <- color[time_period == max(color$time_period) & price_interval == "整体" & age_level == "整体"]
    this.color.name <- unique(this.color$color_name)
    this.other.color <- sort(this.color.name[which(this.color.name!=this.reactive.values$select.color)])
    tagList(
      render_material_from_server(
        material_dropdown(ns("anotherColorDropdown"), label = "选择待比较颜色", choices = this.other.color, selected = this.other.color[1], color = "#fff")
      )
    )
  })
  
  # HC color radar ----
  output$colorRadar <- renderHighchart({
    if (is.null(input$loadColor) || is.null(input$anotherColorDropdown)) return()
    this.radar.table <- color[time_period == max(color$time_period) & price_interval == "整体" & age_level == "整体"][color_name %in% this.reactive.values$select.color]
    this.radar.color <- paste0("rgb(", str_sub(str_split(this.radar.table$color_rgb, ",")[[1]][1], 2), ",", str_split(this.radar.table$color_rgb, ",")[[1]][2], ",", str_sub(str_split(this.radar.table$color_rgb, ",")[[1]][3], 1, -2), ")")
    format.dropdown.element <- str_replace_all(input$anotherColorDropdown, "_shinymaterialdropdownspace_", " ")
    another.radar.table <- color[time_period == max(color$time_period) & price_interval == "整体" & age_level == "整体"][color_name %in% format.dropdown.element]
    another.radar.color <- paste0("rgb(", str_sub(str_split(another.radar.table$color_rgb, ",")[[1]][1], 2), ",", str_split(another.radar.table$color_rgb, ",")[[1]][2], ",", str_sub(str_split(another.radar.table$color_rgb, ",")[[1]][3], 1, -2), ")")
    
    highchart() %>%
      hc_chart(height = "70%", polar = T, type = "line", backgroundColor = "#272733") %>%
      hc_add_series(name = this.reactive.values$select.color, color = this.radar.color, data = as.numeric(
        this.radar.table[, .(
          price_index, market_index, product_index, up_rate_index, repurchase_index
        )]
      )) %>%
      hc_add_series(name = format.dropdown.element, color = another.radar.color, data = as.numeric(
        another.radar.table[, .(
          price_index, market_index, product_index, up_rate_index, repurchase_index
        )]
      )) %>%
      hc_xAxis(categories = c(
        "销量指数", "销售额指数", "产品数指数", "流行潜力指数", "复购指数"
      ),
      tickmarkPlacement = "on", lineWidth = 0, labels = list(style=list(color="#fff")), gridLineColor = "#616161") %>%
      hc_yAxis(gridLineInterpolation = "polygon", gridLineColor = "#616161") %>%
      hc_legend(enabled = T, align = "right", layout = "horizontal", verticalAlign = "top", itemStyle = list(color = "#fff")) %>%
      hc_tooltip(headerFormat = "{series.name}<br>{point.x}", pointFormat = ": {point.y}")
  })
  
  # HC word table ----
  output$wordTable <- renderDataTable({
    if (is.null(input$loadColor)) return()
    this.seword <- seword[time_period == max(seword$time_period) & color_name %in% this.reactive.values$select.color]
    if (input$indexSelector == "热词") {
      this.seword.board <-  this.seword[order(-hot_index), .(word=se_keyword, index=hot_index)][index > 0]
      this.reactive.values$seword.board <- this.seword.board
      this.column <- c("描述词", "热词指数")
    } else {
      this.seword.board <-  this.seword[order(-up_index), .(word=se_keyword, index=up_index)][index > 0]
      this.reactive.values$seword.board <- this.seword.board
      this.column <- c("描述词", "窜升词指数")
    }
    # min.index <- min(this.seword.board$index) - 1
    min.index <- 400
    this.seword.board$index_bar <- paste0('<div style="background:linear-gradient(-90deg, #DF3BFF 10%, #FB7373 90%) 0% 0% / 100% 100% no-repeat;border-radius:10px;width:',
                                          100/(1000-min.index)*(this.seword.board$index-min.index),
                                          '%;">',
                                          this.seword.board$index,
                                          '</div>')

    datatable(
      this.seword.board[, .(word, index_bar)],
      class = "stripe compact hover nowrap",
      selection = list(mode = "single", selected = c(1), target = "row"),
      rownames = F,
      height = "60%",
      escape = F,
      colnames = this.column,
      options = list(searching = F, paging = F, ordering = F, info = F, scrollY = "300px", autoWidth = F,
                     columnDefs=list(list(width="5%",targets=list(0,1)), list(className="dt-left", targets = "_all")),
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
    if (is.null(input$wordTable_rows_selected)) return()
    this.word <- this.reactive.values$seword.board[input$wordTable_rows_selected]$word
    this.seword.trend <- seword[color_name %in% this.reactive.values$select.color & se_keyword %in% this.word]
    if (input$indexSelector == "热词") {
      this.seword.trend <- this.seword.trend[, .(time_period, se_keyword, index=hot_index)]
    } else {
      this.seword.trend <- this.seword.trend[, .(time_period, se_keyword, index=up_index)]
    }
    this.seword.trend <- this.seword.trend[order(time_period)]
    this.seword.trend$time_period <- as.character(this.seword.trend$time_period)
    time.period <- unique(this.seword.trend$time_period)
    
    hchart(this.seword.trend, "spline", hcaes(x = time_period, y = index, group = se_keyword), color=str_split(input$loadColor, "\n")[[1]][2]) %>%
      hc_chart(height = "", backgroundColor = "#272733") %>%
      hc_xAxis(title = list(enabled = F), labels = list(enabled = T, style=list(color="#fff"))) %>%
      hc_yAxis(gridLineWidth = 0, title = list(enabled = F)) %>%
      hc_legend(enabled = F, align = "left", verticalAlign = "bottom", itemStyle = list(color = "#fff")) %>%
      hc_title(text = "当前描述词指数趋势", style = list("color"="#fff", "fontSize"="15px"), align = "left")
  })
  
  
  # item table ----
  output$itemTable <- renderDataTable({
    if (is.null(input$loadColor)) return()
    
    this.item.table <- drop_na(item[color_name %in% this.reactive.values$select.color][order(-sales_index)][1:10])
    # min.index <- min(this.item.table$sales_index) - 1
    min.index <- 400
    this.item.table$sales_index_bar <- paste0('<div style="background:linear-gradient(-90deg, #DF3BFF 10%, #FB7373 90%) 0% 0% / 100% 100% no-repeat;border-radius:10px;width:',
                                          100/(1000-min.index)*(this.item.table$sales_index-min.index),
                                          '%;">',
                                          this.item.table$sales_index,
                                          '</div>')
    
    datatable(
      this.item.table[, .(brand, std_name, sales_index_bar)],
      class = "stripe compact hover",
      selection = list(mode = "none"),
      rownames = F,
      escape = F,
      height = "60%",
      colnames = c( "品牌", "单品名称", "销售额指数"),
      options = list(searching = F, paging = F, ordering = F, info = F, scrollY = "300px", scrollCollapse=T, autoWidth = F,
                     columnDefs=list(list(width="3%",targets=list(0,2)), list(width="5%",targets=list(1)), list(className="dt-left", targets = "_all")),
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
