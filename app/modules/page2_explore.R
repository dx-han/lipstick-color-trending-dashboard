page2_explore_ui <- function(id) {
  ns <- NS(id)
  price.interval <- c("All", "0-100", "100-200", "200-300", "300+")
  age.level <- c("All", "Other", "80s", "90s", "95s", "00s")
  top <- c("TOP5", "TOP10", "TOP20", "TOP30")
  htmlTemplate(
    filename = "www/page2_explore.html",
    page2_explore_price_selector = radioButtons(ns("priceSelector"), label="Price Range", choices=price.interval, selected=price.interval[1], inline=TRUE),
    page2_explore_age_selector = radioButtons(ns("ageSelector"), label="Age Range", choices=age.level, selected=age.level[1], inline=TRUE),
    page2_explore_total_index_range_slider = sliderInput(ns("totalIndexRangeSlider"), label="Composite Index Range", min=500, max=1000, value=c(500,1000), step=5),
    page2_explore_up_index_range_slider = sliderInput(ns("upIndexRangeSlider"), label="Up Color Index Range", min=500, max=1000, value=c(500, 1000), step=5),
    page2_explore_color_dropdown = uiOutput(ns("uiColorDropdown")),
    page2_explore_color_distance = plotlyOutput(ns("colorDistance"), height="500px"),
    page2_explore_click_color_name = uiOutput(ns("uiClickColorName")),
    page2_explore_word_index_selector = radioButtons(ns("indexSelector"), label="Index", choices=c("Hot word","Up word"), selected="Hot word", inline=TRUE),
    page2_explore_word_table = dataTableOutput(ns("wordTable")),
    page2_explore_item_table = dataTableOutput(ns("itemTable")),
    page2_explore_brand_dropdown = uiOutput(ns("uiBrandDropdown")),
    page2_explore_item_origin_table = dataTableOutput(ns("itemOriginTable")),
    page2_explore_item_color_close_table = dataTableOutput(ns("itemColorCloseTable"))
  )
}


page2_explore_server <- function(input, output, session, color, seword, item) {
  
  ns <- session$ns
  # initialize reactive values ----
  this.reactive.values <- reactiveValues(color.table=NULL, item.origin.table=NULL, select.color=NULL)
  
  
  # color select dropdown ----
  output$uiColorDropdown <- renderUI({
    this.color.table <- color[time_period==max(color$time_period) 
                              & price_interval %in% input$priceSelector 
                              & age_level %in% input$ageSelector
                              , .(time_period, color_family_name, color_name, color_rgb, total_index, up_index)]
    this.color.table <- this.color.table[
      total_index %between% c(input$totalIndexRangeSlider[1], input$totalIndexRangeSlider[2])
      & up_index %between% c(input$upIndexRangeSlider[1], input$upIndexRangeSlider[2])
    ]
    this.reactive.values$color.table <- rgb.with.hsb(this.color.table)
    this.color.name <- c("None", unique(this.color.table[order(color_name)]$color_name))
    tagList(
      render_material_from_server(
        material_dropdown(ns("colorDropdown"), label = "Interested Color", choices = this.color.name, selected = this.color.name[1],  color = "#fff")
      )
    )
  })
  
  
  # HC color distance ----
  output$colorDistance <- renderPlotly({
    if (is.null(input$colorDropdown)) return()
    this.color.table <- this.reactive.values$color.table
    
    if (input$colorDropdown != "None") {
      this.select.dropdown <- str_replace_all(input$colorDropdown, "_shinymaterialdropdownspace_", " ")
      this.select.color <- this.color.table[color_name %in% this.select.dropdown]
      this.color.table$distance <- (this.color.table$hue - this.select.color$hue)**2 + (this.color.table$saturation - this.select.color$saturation)**2 + (this.color.table$bright - this.select.color$bright)**2
      this.color.table <- drop_na(this.color.table[order(distance)][1:6])
      select.color <- this.color.table[1]
    } else {
      select.color <- NULL
    }
    
    this.3d.color <- sapply(this.color.table$color_rgb, function(x) {
      x.split <- str_split(x, ",")
      rgb(str_sub(x.split[[1]][1],2), x.split[[1]][2], str_sub(x.split[[1]][3], 1, -2), maxColorValue = 255)
    })
    this.3d.color <- setNames(this.3d.color, this.color.table$color_name)
    this.color.table$color_hex <- this.3d.color
    
    plot_ly(this.color.table, type="scatter3d", mode="markers", x=~bright, y=~saturation, z=~hue, 
            text=~paste("hex:", color_hex, "<br>hsb:", color_hsb, "<br>Composite Index:", total_index, "<br>Up Color Index:", up_index), 
            color=~color_name, colors=this.3d.color, showlegend=F, source="color_distance") %>%
      layout(scene=list(
        xaxis=list(title="x-axis Bright", range=c(35,100), gridcolor="#e9e9e9", color="#e9e9e9"),
        yaxis=list(title="y-axis Saturation", range=c(35,100), gridcolor="#e9e9e9", color="#e9e9e9"),
        zaxis=list(title="z-axis Hue", range=c(0,50), gridcolor="#e9e9e9", color="#e9e9e9"),
        annotations=list(
          list(x=select.color$bright, y=select.color$saturation, z=select.color$hue, text=select.color$color_name, showarrow=T, opacity=0.7, arrowsize=1, arrowwidth=1, arrowcolor="#fff", font=list(color="#fff"))
      )),
        paper_bgcolor="#272733", plot_bgcolor="#272733"
      )
  })
  
  
  # click color name ----
  output$uiClickColorName <- renderUI({
    axis <- event_data("plotly_click", "color_distance")
    if (is.null(axis) || nrow(this.reactive.values$color.table) == 0) return(tags$h6("Please click color on the three-dimensional diagram first",style="color:#fff"))
    this.color <- this.reactive.values$color.table[bright %in% axis$x & saturation %in% axis$y & hue %in% axis$z]
    this.reactive.values$select.color <- this.color$color_name
    print(this.color$color_name)
    this.color.rgb <- paste0("rgb(",str_sub(unique(this.color$color_rgb),2,-2),")")
    tagList(
      tags$h6(
        HTML(paste0(
          this.reactive.values$select.color,"&nbsp;","<span style='height:10px;width:10px;background:",
          this.color.rgb,"';>&nbsp;&nbsp;&nbsp;&nbsp;</span>"
        )), class="white-text"
      )
    )
  })
  
  
  # HC word table ----
  output$wordTable <- renderDataTable({
    if (is.null(this.reactive.values$select.color) || nrow(this.reactive.values$color.table) == 0) return()
    this.seword <- seword[time_period == max(seword$time_period) & color_name %in% this.reactive.values$select.color]
    if (input$indexSelector == "Hot word") {
      this.seword.board <-  this.seword[order(-hot_index), .(word=se_keyword, index=hot_index)][index > 0]
      this.reactive.values$seword.board <- this.seword.board
      this.column <- c("Search Keyword", "Hot word index")
    } else {
      this.seword.board <-  this.seword[order(-up_index), .(word=se_keyword, index=up_index)][index > 0]
      this.reactive.values$seword.board <- this.seword.board
      this.column <- c("Search Keyword", "Up word index")
    }
    # min.index <- min(this.seword.board$index) - 1
    min.index <- 400
    this.seword.board$index.bar <- paste0('<div style="background:linear-gradient(-90deg, #DF3BFF 10%, #FB7373 90%) 0% 0% / 100% 100% no-repeat;border-radius:10px;width:',
                                          100/(1000-min.index)*(this.seword.board$index-min.index),
                                          '%;">',
                                          this.seword.board$index,
                                          '</div>')
    this.seword.board$k <- '<div style="background:linear-gradient(-90deg, #DF3BFF 10%, #FB7373 90%) 0% 0% / 100% 100% no-repeat;border-radius:10px;width:70%;">70.09</div>'
    
    datatable(
      this.seword.board[, .(word, index.bar)],
      class = "stripe compact hover nowrap",
      selection = list(mode = "none"),
      rownames = F,
      height = "60%",
      escape = F,
      colnames = this.column,
      options = list(searching=F, paging=F, ordering=F, info=F, scrollY="200px", scrollCollapse=T, autoWidth=F,
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
  
  
  # item table ----
  output$itemTable <- renderDataTable({
    if (is.null(this.reactive.values$select.color) || nrow(this.reactive.values$color.table) == 0) return()
    
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
      colnames = c( "Brand", "Product", "Sales Index"),
      options = list(searching = F, paging = F, ordering = F, info = F, scrollY = "200px", autoWidth = F,
                     columnDefs=list(list("width"="20%", targets=list(0)), list("width"="40%", targets=list(1)), list("width"="40%", targets=list(2)), list(width="5%",targets=list(1)), list(className="dt-left", targets = "_all")),
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