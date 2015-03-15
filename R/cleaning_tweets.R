### Cleaning script
#
# 1. clean tweets
# 2. classify/subset tweets that belong to festival
# 3. convert created_at variable
# 4. save workspace


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
initialsearch <- scan("data/initial_search.txt", what = "character", sep = "\n")

### clean tweets
alltweets$text <- tweet_cleaner(tweets = alltweets$text, 
                                concat_terms = initialsearch,
                                rename_odds = TRUE,
                                rm_punct = TRUE)

### classify tweets
ind <- findtweets(tweets = alltweets$text, 
                  searchfor = initialsearch)
# subset tweets
alltweets <- alltweets[ind,]

racing_lexicon <- scan("data/racing_lexicon.txt", what = "character")
horses <- subset(allrunners, !G1)$horse
searchfor <- c(initialsearch, horses, racing_lexicon)
x <- findtweets(tweets = alltweets$text, searchfor = searchfor, counts = TRUE)
