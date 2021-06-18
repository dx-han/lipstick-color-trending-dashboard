ui <- htmlTemplate(
            filename="www/index.html",
            nav_side_bar=navsidebar_ui("navside"),
            page1_trend=page1_trend_ui("pageonetrend"),
            page1_analysis=page1_analysis_ui("pageoneanalysis"),
            page2_explore=page2_explore_ui("pagetwoexplore")
)
