
# 表格读取
color <- data.table(read_xlsx("www/data/sample.xlsx", sheet="color")[1:15])
color.column.integer <- c("time_period")
color.column.float <- c("price_index","product_index","market_index","up_rate_index","repurchase_index","rate_rate_index","total_index","up_index")
color[,(color.column.integer):=lapply(.SD, as.integer), .SDcols=color.column.integer]
color[,(color.column.float):=lapply(.SD,round,2), .SDcols=color.column.float]
color$price_index <- as.integer(color$price_index * 10)
color$product_index <- as.integer(color$product_index * 10)
color$market_index <- as.integer(color$market_index * 10)
color$up_rate_index <- as.integer(color$up_rate_index * 10)
color$repurchase_index <- as.integer(color$repurchase_index * 10)
color$rate_rate_index <- as.integer(color$rate_rate_index * 10)
color$total_index <- as.integer(color$total_index * 10)
color$up_index <- as.integer(color$up_index * 10)
setorder(color, -total_index)

seword <- data.table(read_xlsx("www/data/sample.xlsx", sheet="se_word")[1:5])
seword.column.integer <- c("time_period")
seword.column.float <- c("hot_index","up_index")
seword[,(seword.column.integer):=lapply(.SD, as.integer), .SDcols=seword.column.integer]
seword[,(seword.column.float):=lapply(.SD,round,2), .SDcols=seword.column.float]
seword$hot_index <- as.integer(seword$hot_index * 10)
seword$up_index <- as.integer(seword$up_index * 10)

item <- data.table(read_xlsx("www/data/sample.xlsx", sheet="item")[1:5])
item.column.float <- c("sales_index")
item[,(item.column.float):=lapply(.SD,round,2), .SDcols=item.column.float]
item$sales_index <- as.integer(item$sales_index * 10)


# 颜色HSB色块
hsb.rgb <- c()
hsb.range <- c()
hue.block <- c(300, 310, 320, 330, 340, 350, 0, 10, 20)
bright.block <- c(30, 65)
for (hue in hue.block) {
  for (bright in bright.block) {
    curr.hsb <- data.table(hue + 5, 0.65, (bright + 17.5) / 100)
    curr.rgb <- convert_colour(curr.hsb, "hsb", "rgb")
    hsb.rgb <- append(hsb.rgb, paste0("rgb(", as.integer(curr.rgb$r), ",", as.integer(curr.rgb$g), ",", as.integer(curr.rgb$b), ")"))
    hsb.range <- append(hsb.range, paste(hue + 5, 0.3, 1.0, bright / 100, (bright + 35) / 100, sep = ","))
  }
}
hsb.hue.bar <- data.table(hue_category = 1:length(hsb.rgb), hsb_rgb = hsb.rgb, hsb_range = hsb.range)

