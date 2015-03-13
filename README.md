Cheltenham Festival 2015 on Twitter
===================================

Repo containing tweets collecting using the [streamR](https://github.com/pablobarbera/streamR/) package that "belong" to the 2015 Cheltenham Festival.  Tweets were collected if they contained any of the runners in various grade 1 races on each of the days, or a few other key words, including 'cheltenham'.

In the **data** folder are four workspaces, one for each day, within each day there are two dataframes, one containing the races and runners on that day, the second containing the collected tweets.

In the **R** folder are a number of scripts, `collect.R` is the script used to collect the tweets, `collect_runners.R` is the script used to scrape runners for the next days races, `functions.R` script contains a number of functions to clean/prepare the tweets.
