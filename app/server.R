
server = function(input, output, session) {
  callModule(navsidebar_server, id="navside")
  callModule(page1_trend_server, id="pageonetrend", color)
  callModule(page1_analysis_server, id="pageoneanalysis", color, seword, item)
  callModule(page2_explore_server, id="pagetwoexplore", color, seword, item)
}
