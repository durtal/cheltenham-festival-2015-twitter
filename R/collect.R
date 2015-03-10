setwd("C:/Users/TomHeslop/Desktop/Cheltenham-Festival-2015-Twitter/R")

library(streamR)
load("../data/my_auth.RData")

load("../data/day_one.RData")
# load("../data/day_two.RData")
# load("../data/day_three.RData")
# load("../data/day_four.RData")

horses <- subset(day_one, G1)$horse
# horses <- subset(day_two, G1)$horse
# horses <- subset(day_three, G1)$horse
# horses <- subset(day_four, G1)$horse
horses <- as.character(horses)
horses <- c(horses, "cheltenham", "cheltfest", "ladbrokes", "paddypower", "willhillbet", "betvictor", "coral", "betfair")

filterStream(file.name = "../data/day_one.json", track = horses, timeout = 25200, oauth = my_oauth)
# filterStream(file.name = "../data/day_two.json", track = horses, timeout = 25200, oauth = my_oauth)
# filterStream(file.name = "../data/day_three.json", track = horses, timeout = 25200, oauth = my_oauth)
# filterStream(file.name = "../data/day_four.json", track = horses, timeout = 25200, oauth = my_oauth)
