page1_analysis_ui <- function(id) {
  ns <- NS(id)
  htmlTemplate(
    filename = "www/page1_analysis.html",
    page1_analysis_hue_bar = dataTableOutput(ns("colorHueBar")),
    page1_analysis_palette = uiOutput(ns("colorPalette")),
    page1_analysis_click_color_name = uiOutput(ns("clickColorName")),
    page1_analysis_other_color_dropdown = uiOutput(ns("otherColorDropdown")),
    page1_analysis_color_radar = highchartOutput(ns("colorRadar"), height="50%"),
    page1_analysis_word_index_selector = radioButtons(ns("indexSelector"), label="Index", choices=c("Hot word","Up word"), selected="Hot word", inline=TRUE),
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
    if (is.null(input$loadColor)) return(tags$h6("Select color",style="color:#fff"))
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
    this.color.hue.bar <- color[time_period == max(color$time_period) & price_interval == "All" & age_level == "All"]
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
      options = list(searching = F, paging = F, ordering = F, info = F, scrollY = "550px", autoWidth = F,
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
    this.color <- color[time_period == max(color$time_period) & price_interval == "All" & age_level == "All"]
    this.color.name <- unique(this.color$color_name)
    this.other.color <- sort(this.color.name[which(this.color.name!=this.reactive.values$select.color)])
    tagList(
      render_material_from_server(
        material_dropdown(ns("anotherColorDropdown"), label = "Select another color to compare", choices = this.other.color, selected = this.other.color[1], color = "#fff")
      )
    )
  })
  
  # HC color radar ----
  output$colorRadar <- renderHighchart({
    if (is.null(input$loadColor) || is.null(input$anotherColorDropdown)) return()
    this.radar.table <- color[time_period == max(color$time_period) & price_interval == "All" & age_level == "All"][color_name %in% this.reactive.values$select.color]
    this.radar.color <- paste0("rgb(", str_sub(str_split(this.radar.table$color_rgb, ",")[[1]][1], 2), ",", str_split(this.radar.table$color_rgb, ",")[[1]][2], ",", str_sub(str_split(this.radar.table$color_rgb, ",")[[1]][3], 1, -2), ")")
    format.dropdown.element <- str_replace_all(input$anotherColorDropdown, "_shinymaterialdropdownspace_", " ")
    another.radar.table <- color[time_period == max(color$time_period) & price_interval == "All" & age_level == "All"][color_name %in% format.dropdown.element]
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
        "Sales", "Sales volume", "Product quality", "Potential", "Repurchase"
      ),
      tickmarkPlacement = "on", lineWidth = 0, labels = list(style=list(color="#fff")), gridLineColor = "#616161") %>%
      hc_yAxis(gridLineInterpolation = "polygon", gridLineColor = "#616161") %>%
      hc_legend(enabled = T, align = "right", layout = "horizontal", verticalAlign = "top", itemStyle = list(color = "#fff")) %>%
      hc_tooltip(headerFormat = "{series.name}<br>{point.x}", pointFormat = ": {point.y}")
  })
}
