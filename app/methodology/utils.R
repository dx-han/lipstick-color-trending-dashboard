
add.hue.category <- function(dt, hsb.hue.bar) {
  hue.category <- sapply(dt$color_rgb, function(x) {
    x.split <- str_split(x, ",")
    x.rgb <- data.table(as.integer(str_sub(x.split[[1]][1], 2)), as.integer(x.split[[1]][2]), as.integer(str_sub(x.split[[1]][3], 1, -2)))
    x.hsb <- convert_colour(x.rgb, "rgb", "hsb")
    if (x.hsb$h >= 300 && x.hsb < 310) {
      if (x.hsb$b < 0.65) return(1)
      else return(2)
    } else if (x.hsb$h >= 310 && x.hsb$h < 320) {
      if (x.hsb$b < 0.65) return(3)
      else return(4)
    } else if (x.hsb$h >= 320 && x.hsb$h < 330) {
      if (x.hsb$b < 0.65) return(5)
      else return(6)
    } else if (x.hsb$h >= 330 && x.hsb$h < 340) {
      if (x.hsb$b < 0.65) return(7)
      else return(8)
    } else if (x.hsb$h >= 340 && x.hsb$h < 350) {
      if (x.hsb$b < 0.65) return(9)
      else return(10)
    } else if (x.hsb$h >= 350 && x.hsb$h < 360) {
      if (x.hsb$b < 0.65) return(11)
      else return(12)
    } else if (x.hsb$h >= 0 && x.hsb$h < 10) {
      if (x.hsb$b < 0.65) return(13)
      else return(14)
    } else {
      if (x.hsb$b < 0.65) return(15)
      else return(16)
    }
  })
  dt$hue_category <- hue.category
  dt <- merge(dt, hsb.hue.bar, by = "hue_category", all.x = T)
  return(dt)
}


rgb.with.hsb <- function(dt) {
  hue <- c()
  hue.adjusted <- c()
  saturation <- c()
  bright <- c()
  for (x in dt$color_rgb) {
    x.split <- str_split(x, ",")
    x.rgb <- data.table(as.integer(str_sub(x.split[[1]][1], 2)), as.integer(x.split[[1]][2]), as.integer(str_sub(x.split[[1]][3], 1, -2)))
    x.hsb <- convert_colour(x.rgb, "rgb", "hsb")
    hue <- append(hue, x.hsb$h)
    if (x.hsb$h < 30) {
      x.hsb$h <- x.hsb$h + 360
    }
    hue.adjusted <- append(hue.adjusted, x.hsb$h)
    saturation <- append(saturation, x.hsb$s)
    bright <- append(bright, x.hsb$b)
  }
  dt$hue <- hue
  dt$saturation <- saturation
  dt$bright <- bright
  dt$color_hsb <- paste(as.integer(dt$hue), as.integer(dt$saturation*100), as.integer(dt$bright*100), sep=",")
  dt$hue <- hue.adjusted
  dt$hue <- as.integer(dt$hue - min(dt$hue))
  dt$saturation <- as.integer(dt$saturation * 100)
  dt$bright <- as.integer(dt$bright * 100)
  return(dt)
}


find_sim_color <- function(dt, this.item.name, this.color.name) {
  dt <- dimension.reduction(dt)
  this.RC1 <- dt[std_name %in% this.item.name & color_name %in% this.color.name]$RC1
  this.RC2 <- dt[std_name %in% this.item.name & color_name %in% this.color.name]$RC2
  other.dt <- dt[!color_name %in% this.color.name]
  other.dt$distance <- (other.dt$RC1 - this.RC1)**2 + (other.dt$RC2 - this.RC2)**2
  return(other.dt[order(distance)])
}


dimension.reduction <- function(dt) {
  hue <- c()
  saturation <- c()
  bright <- c()
  for (x in dt$color_rgb) {
    x.split <- str_split(x, ",")
    x.rgb <- data.table(as.integer(str_sub(x.split[[1]][1], 2)), as.integer(x.split[[1]][2]), as.integer(str_sub(x.split[[1]][3], 1, -2)))
    x.hsb <- convert_colour(x.rgb, "rgb", "hsb")
    if (x.hsb$h < 30) {
      x.hsb$h <- x.hsb$h + 360
    }
    hue <- append(hue, x.hsb$h)
    saturation <- append(saturation, x.hsb$s)
    bright <- append(bright, x.hsb$b)
  }
  hue <- (hue - min(hue)) / (max(hue) - min(hue))
  saturation <- (saturation - min(saturation)) / (max(saturation) - min(saturation))
  bright <- (bright - min(bright)) / (max(bright) - min(bright))

  res <- principal(data.table(hue=hue, saturation=saturation, bright=bright), 2)
  score <- data.table(res$scores)
  dt <- cbind(dt, score)
  return(dt)
}
