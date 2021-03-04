
server = function(input, output, session) {
  # res_auth <- secure_server(
  #   check_credentials = check_credentials("db.sqlite", passphrase="lipstick")
  # )
  # auth <- callModule(auth_server, id="auth", check_credentials=check_credentials(credentials))
  # auth <- callModule(auth_server, id="auth", check_credentials=check_credentials("db.sqlite", passphrase=key_get("lipstick-shinymanager-key", "lipstick")))

  callModule(navsidebar_server, id="navside")
  callModule(page1_board_server, id="pageonebrand", color)
  callModule(page1_trend_server, id="pageonetrend", color)
  callModule(page1_analysis_server, id="pageoneanalysis", color, seword, item)
  callModule(page2_explore_server, id="pagetwoexplore", color, seword, item)
  callModule(page3_instruction_server, id="pagethreeinstruction")
  
}
