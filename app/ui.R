ui <- htmlTemplate(
            filename="www/index.html",
            nav_side_bar=navsidebar_ui("navside"),
            page1_board=page1_board_ui("pageonebrand"),
            page1_trend=page1_trend_ui("pageonetrend"),
            page1_analysis=page1_analysis_ui("pageoneanalysis"),
            page2_explore=page2_explore_ui("pagetwoexplore"),
            page3_instruction=page3_instruction_ui("pagethreeinstruction")
)


# Wrap your UI with secure_app
# ui <- secure_app(ui, enable_admin=T, theme=shinytheme("flatly"), background="url('img/bg2.png') center/2020px no-repeat")


# auth_ui(
#     id="auth",
#     background="url('img/bg2.png') center/2020px no-repeat"
# ),

# ui <- fluidPage(
#     bootstrapPage(
#         htmlTemplate(
#             filename="www/index.html",
#             nav_side_bar=navsidebar_ui("navside"),
#             page1_board=page1_board_ui("pageonebrand"),
#             page1_trend=page1_trend_ui("pageonetrend"),
#             page1_analysis=page1_analysis_ui("pageoneanalysis"),
#             page2_explore=page2_explore_ui("pagetwoexplore"),
#             page3_instruction=page3_instruction_ui("pagethreeinstruction")
#         )
#     )
# )