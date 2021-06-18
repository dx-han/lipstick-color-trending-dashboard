
navsidebar_ui <- function(id) {
  price.interval <- c("All", "0-50", "0-100", "100-200", "200-300", "300+")
  age.level <- c("All", "Before 80s", "80s", "90s", "95s", "00s")
  ns <- NS(id)
  htmlTemplate(
    filename = "www/nav_side_bar.html",
    upload = uiOutput(ns("picUpload"))
  )
}


navsidebar_server <- function(input, output, session) {
  
  ns <- session$ns
}
