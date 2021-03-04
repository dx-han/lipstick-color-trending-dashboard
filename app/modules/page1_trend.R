
page1_trend_ui <- function(id) {
  ns <- NS(id)
  price.interval <- c("整体", "0-100", "100-200", "200-300", "300+")
  age.level <- c("整体", "80前", "80后", "90后", "95后", "00后")
  index <- c("综合指数TOP10", "窜升指数TOP10")
  color.family <- c("全部", unique(color$color_family_name))
  htmlTemplate(
    filename = "www/page1_trend.html",
    page1_trend_price_selector = checkboxGroupInput(ns("priceSelector"), label="价格带", choices=price.interval, selected="整体", inline=TRUE),
    page1_trend_age_selector = checkboxGroupInput(ns("ageSelector"), label="人群代际", choices=age.level, selected="整体", inline=TRUE),
    page1_trend_index_selector = radioButtons(ns("indexSelector"), label="选择指数", choices=index, selected="综合指数TOP10", inline=TRUE),
    page1_trend_color_family_selector = radioButtons(ns("colorFamilySelector"), label="选择色系", choices=color.family, selected="全部", inline=TRUE),
    page1_trend_color_table = dataTableOutput(ns("colorTable")),
    page1_trend_color_trend = highchartOutput(ns("colorTrend"))
  )
}


page1_trend_server <- function(input, output, session, color) {
  
  this.reactive.values <- reactiveValues(color.table=NULL)
  
  # DT color table ----
  output$colorTable <- renderDataTable({
    if (input$indexSelector == "综合指数TOP10") {
      this.color.table <- color[time_period==max(color$time_period) 
                                & price_interval == "整体"
                                & age_level == "整体"
                                , .(time_period, color_family_name, color_name, color_rgb, index=total_index)][order(-index)]
    } else {
      this.color.table <- color[time_period==max(color$time_period) 
                                & price_interval == "整体"
                                & age_level == "整体"
                                , .(time_period, color_family_name, color_name, color_rgb, index=up_index)][order(-index)]
    }
    if (input$colorFamilySelector != "全部") {
      this.color.table <- this.color.table[color_family_name %in% input$colorFamilySelector]
    }
    
    this.reactive.values$color.table <- this.color.table
    
    # this.color.table <- drop_na(this.color.table[order(-index)][1:30])
    rgb.set <- sapply(this.color.table$color_rgb, function(x) {
      x.split <- str_split(x, ",")
      paste0("rgb(", str_sub(x.split[[1]][1], 2), ",", x.split[[1]][2], ",", str_sub(x.split[[1]][3], 1, -2), ")")
    })
    
    datatable(
      this.color.table[, .(color_name)],
      class = "hover nowrap",
      selection = list(mode = "multiple", selected = c(1), target = "row"),
      rownames = T,
      colnames = c(""),
      options = list(
        searching=F, paging=F, ordering=F, info=F, scrollY="350px", scrollCollapse=T, autoWidth=F,
        columnDefs=list(list(className="dt-center", targets="_all"))
      )
    ) %>%
      formatStyle(
        columns = "color_name", 
        target = "row", 
        backgroundColor = styleEqual(this.color.table$color_name, rgb.set), 
        color = "rgb(255, 255, 255, 0.8)"
      )
  })
  
  
  # DT color trend ----
  output$colorTrend <- renderHighchart({
    
    this.color.name <- this.reactive.values$color.table[input$colorTable_rows_selected]$color_name
    
    if (input$indexSelector == "综合指数TOP10") {
      this.color.trend <- color[price_interval %in% input$priceSelector 
                                & age_level %in% input$ageSelector
                                & color_name %in% this.color.name
                                , .(time_period, color_family_name, color_name, color_rgb, price_interval, age_level, index=total_index)][order(time_period)]
    } else {
      this.color.trend <- color[price_interval %in% input$priceSelector 
                                & age_level %in% input$ageSelector
                                & color_name %in% this.color.name
                                , .(time_period, color_family_name, color_name, color_rgb, price_interval, age_level, index=up_index)][order(time_period)]
    }
    
    this.color.trend$group <- paste0("名称 ", this.color.trend$color_name, "<br>价格段 ", this.color.trend$price_interval, "<br>年龄段 ", this.color.trend$age_level)
    # time.period <- sort(unique(this.color.trend$time_period))
    this.color.trend$time_period <- as.character(sort(this.color.trend$time_period))
    
    # browser()
    
    rgb.set <- sapply(this.color.trend[, .(color_rgb=first(color_rgb)), by="group"]$color_rgb, function(x) {
      x.split <- str_split(x, ",")
      paste0("rgb(", str_sub(x.split[[1]][1], 2), ",", x.split[[1]][2], ",", str_sub(x.split[[1]][3], 1, -2), ")")
    })
    
    hchart(this.color.trend, "spline", hcaes(x = time_period, y = index, group = group), color=rgb.set) %>%
      hc_chart(backgroundColor = "#272733") %>%
      hc_tooltip(enabled=T, headerFormat="时间 {point.key}<br>{series.name}<br>", pointFormat="指数 {point.y}") %>%
      hc_xAxis(title=list(enabled=F)) %>%
      hc_yAxis(gridLineWidth = 0, title = list(enabled = F)) %>%
      hc_legend(enabled = F, align = "left", verticalAlign = "middle", layout = "vertical", itemStyle = list(color = "#fff"))
  })
  
}