################################################################################
# DAILY OVERVIEW SCRIPT

################################################################################

# load libraries
library(ggplot2)
library(RcappeR) # for ggplot2 theme
library(wesanderson) # for palette

# load data
load("data/clean_tweets.RData")
# add a date_time variable to identify unique races
allrunners$date_time <- paste(allrunners$date, allrunners$time)

# palette
pal <- wes_palette(name = "Darjeeling")[c(1,2,4,5)]

################################################################################
# create list of runners
rnrs <- sapply(unique(subset(allrunners, G1)$date_time), function(x) {
    subset(allrunners, date_time == x)$horse
})

# count number of tweets that mention one of runners from 13 championship races
racecounts <- lapply(rnrs, function(x) length(findtweets(racing$text, x, counts = TRUE)))
racecounts <- plyr::ldply(racecounts)
names(racecounts) <- c("race", "count")
racecounts$.id <- factor(rep(paste0("day", 1:4), times = c(4,3,3,3)))
# plot counts per race
ggplot(racecounts, aes(x = race, fill = .id, y = count)) +
    geom_bar(stat="identity", alpha = .65) +
    theme_rcapper() +
    scale_fill_manual(values = pal, guide = FALSE) +
    theme(axis.text.x=element_text(angle=45, vjust=1, hjust=1)) +
    labs(x = "Race", y = "Count", title = "No. of tweets that belong* to each Race\n(*mention a runner)")
