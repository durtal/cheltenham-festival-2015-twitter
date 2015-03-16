################################################################################
# PREPARATION SCRIPT
#
# 1. clean tweets and descriptions
# 2. classify/subset tweets that belong to festival
# 3. convert created_at variable
# 4. sentiment analysis on tweets
# 5. save workspace
################################################################################

# load libraries
library(ggplot2)
library(RcappeR) # for ggplot2 theme
library(wesanderson) # for palette

################################################################################
# load data
load("data/day_one.RData")
load("data/day_two.RData")
load("data/day_three.RData")
load("data/day_four.RData")

# source functions for cleaning tasks
source("R/functions.R")

# create list of all four days tweets
alltweets <- list(day1 = day_one_tweets, 
                  day2 = day_two_tweets, 
                  day3 = day_three_tweets, 
                  day4 = day_four_tweets)
# use plyr to convert list back to dataframe, now with .id variable
alltweets <- plyr::ldply(alltweets)
# remove daily tweets
rm(day_one_tweets, day_two_tweets, day_three_tweets, day_four_tweets)

# create list of all four days runners
allrunners <- list(day1 = day_one,
                   day2 = day_two,
                   day3 = day_three,
                   day4 = day_four)
# use plyr to convert list back to dataframe, now with .id variable
allrunners <- plyr::ldply(allrunners)
# remove daily runners
rm(day_one, day_two, day_three, day_four)

# read in initial search terms
initialsearch <- scan("data/initial_search.txt", 
                      what = "character", 
                      sep = "\n")
# read in racing lexicon
racing_lexicon <- scan("data/racing_lexicon.txt", what = "character")
# read in positive lexicon
positive_lexicon <- scan("data/positive_words.txt", what = "character")
# read in negative lexicon
negative_lexicon <- scan("data/negative_words.txt", what = "character")

# create wes anderson palette
pal <- wes_palette(name = "Cavalcanti")

################################################################################
# 1. clean tweets
alltweets$text <- tweet_cleaner(tweets = alltweets$text, 
                                concat_terms = initialsearch,
                                rename_odds = TRUE,
                                rm_punct = TRUE)
# clean descriptions
alltweets$description <- tweet_cleaner(tweets = alltweets$description,
                                       rename_odds = TRUE,
                                       rm_punct = TRUE)

################################################################################
# 2. classify tweets
ind <- findtweets(tweets = alltweets$text, 
                  searchfor = initialsearch)
# subset tweets
racing <- alltweets[ind,]

# compare subsetted tweets and previous
compare <- rbind(alltweets[,1:2], racing[,1:2])
compare$after <- c(rep(FALSE, length(alltweets$text)),
                   rep(TRUE, length(alltweets$text)))
# plot comparison 
# (used http://durtal.github.io/cheltenham-festival-2015-twitter/classifying.html)
ggplot(compare) +
    geom_bar(aes(x=.id, fill=after), color="#000000", alpha=.65,
             position="dodge") +
    RcappeR::theme_rcapper() + 
    scale_fill_manual(values = pal) +
    labs(x="Festival Day", y="Count",
         title="No. of tweets (before and after initial classifying)")

# build up racing lexicon
horses <- subset(allrunners, !G1)$horse
searchfor <- c(initialsearch, horses, racing_lexicon)
rm(horses, ind)

# use racing lexicon on our tweets to determine number of horses/racing terms that
# feature in each of the tweets
x <- findtweets(racing$text, searchfor = searchfor, counts = TRUE)
counts <- as.data.frame(table(x))
table(counts$Freq)
# plot counts 
# (used http://durtal.github.io/cheltenham-festival-2015-twitter/classifying.html)
ggplot(counts, aes(x = factor(Freq))) +
    geom_bar(alpha = .65, fill = pal[[2]]) +
    theme_rcapper() +
    labs(x = "Terms Mentioned", y = "Count",
         title = "Distribution of number of terms from\n racing lexicon mentioned in tweets")

rm(x, counts)

################################################################################
# 3. convert created_at variable
racing$created_at <-  strptime(racing$created_at, "%a %b %d %H:%M:%S %z %Y")

################################################################################
# 4. sentiment analysis
racing$senti_score <- senti_score(tweets = racing$text,
                     pos_words = positive_lexicon,
                     neg_words = negative_lexicon,
                     .progress = "text")

rm(positive_lexicon, negative_lexicon, searchfor, pal, initialsearch, racing_lexicon)

################################################################################
# 5. save workspace
save.image("data/clean_tweets.RData")
