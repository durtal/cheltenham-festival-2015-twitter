#' function to clean tweets
#' 
#' requires stringr to be loaded
#' 
#' cleans tweets into more useable format, removes unrecognised characters,
#' control characters, links, digits, double spaces, whitespaces from start and
#' end of tweets, and converts everything to lower case
#' 
#' @param tweets the text(tweets) to be cleaned
#' @param concat_terms terms/phrases you may wish to be concatenated
#' @param rename_odds replace digits that are likely betting odds, dates, or
#' times (eg, 3/1, 3.55, 3-1, 4:50) and replaces them with the word 'odds'
#' @param rm_punct remove punctuation
tweet_cleaner <- function(tweets, concat_terms, rename_odds = FALSE, rm_punct = FALSE) {
    
    # remove emoticons/unrecognised characters
    tweets <- iconv(tweets, from = "latin1", to = "ASCII", sub = "")
    # remove control characters
    tweets <- stringr::str_replace_all(tweets, "[[:cntrl:]]", " ")
    # remove links
    tweets <- stringr::str_replace_all(tweets, "(http[^ ]*)|(www\\.[^ ]*)", " ")
    # convert tweets to lower case
    tweets <- tolower(tweets)
    
    # if concat_terms is provided, loop through and concatenate
    if(exists(concat_terms)) {
        concat_terms <- tolower(concat_terms)
        for(term in seq_along(concat_terms)) {
            tweets <- stringr::str_replace_all(tweets,
                                               stringr::str_replace_all(concat_terms[term], "\\s+", " ?"),
                                               stringr::str_pad(concat_terms[term], width = 25, side = "both"))
            tweets <- stringr::str_replace_all(tweets,
                                               stringr::str_replace_all(concat_terms[term], "\\s+", " ?"),
                                               stringr::str_replace_all(concat_terms[term], "\\s+|[[:punct:]]", ""))
        }
    }
    
    # replace numerical odds (and times) with 'odds'
    if(rename_odds) {
        tweets <- stringr::str_replace_all(tweets, "[[:digit:]]+[[:punct:]]+[[:digit:]]+", "odds")
    }
    
    # remove punctuation
    if(rm_punct) {
        tweets <- stringr::str_replace_all(tweets, "[[:punct:]]", " ")
    }
    
    # remove digits
    tweets <- stringr::str_replace_all(tweets, "[[:digit:]]+", "")
    # remove space from start/end of tweets
    tweets <- stringr::str_trim(tweets, side = "both")
    # remove double spaces from tweets
    tweets <- stringr::str_replace_all(tweets, "\\s+", " ")
    
    return(tweets)
}

#' find tweets
#' 
#' locates terms/phrases in tweets, returning indices
#' 
#' @param tweets the tweets to be searched
#' @param searchfor terms/phrases to be searched for
#' @param counts will duplicate indices if more than one term from searchfor is
#' found in that tweet
findtweets <- function(tweets, searchfor, counts = FALSE) {
    
    # make terms lower case, replace spaces/punctuation with " ?" for flexible searches
    searchfor <- tolower(stringr::str_replace_all(searchfor, "\\s+|[[:punct:]]", " ?"))
    # if counts for number of terms per tweet then counts = TRUE
    if(counts) {
        # for each term in the searchfor argument, return the indices of the tweets
        # in which the term appears
        indices <- as.vector(unlist(sapply(searchfor, function(x) {
            grep(x, tweets, ignore.case = TRUE)
        })))
    } else {
        # otherwise a TRUE/FALSE index is returned
        indices <- grepl(paste0(searchfor, collapse = "|"), tweets)
    }
    
    return(indices)
}

#' find and concatenate terms
#' 
#' @param tweets the tweets to be searched
#' @param concat_terms terms/phrases you wish to concatenate
find_n_concat <- function(tweets, concat_terms) {
    
    # make terms to be concatenated lower case
    concat_terms <- tolower(concat_terms)
    # loop through terms, replace spaces with a " ?" for flexible searches
    # pad term with a space either side - isolating term - remove any punctuation
    # or spaces in terms
    for(term in concat_terms) {
        tweets <- stringr::str_replace_all(tweets,
                                           stringr::str_replace_all(term, "\\s+", " ?"),
                                           stringr::str_pad(term, width = 30, side = "both"))
        tweets <- stringr::str_replace_all(tweets,
                                           stringr::str_replace_all(term, "\\s+", " ?"),
                                           stringr::str_replace_all(term, "\\s+|[[:punct:]]", ""))
    }
    # replace double spaces with single spaces
    tweets <- stringr::str_replace_all(tweets, "\\s+", " ")
    
    return(tweets)
}

#' sentiment score
#' 
#' will look for words in tweets that in dictionaries of positive and negative 
#' words, heavily borrowed code from Jeffrey Breen
#' 
#' @param tweets the tweets to be scored
#' @param pos_words positive dictionary
#' @param neg_words negative dictionary
#' @param .progress progress bar
senti_score <- function(tweets, pos_words, neg_words, .progress = "none") {
    
    scores <- plyr::laply(tweets, function(tweet, pos_words, neg_words) {
        # split words
        word_list <- stringr::str_split(tweet, "\\s+")
        words <- unlist(word_list)
        # check for matches in tweets to positive and negative dictionaries
        pos_matches <- match(words, pos_words)
        neg_matches <- match(words, neg_words)
        # ignore NA values
        pos_matches <- !is.na(pos_matches)
        neg_matches <- !is.na(neg_matches)
        # calculate score per tweet
        score <- sum(pos_matches) - sum(neg_matches)
        
        return(score)
    }, pos_words, neg_words, .progress = .progress)
    
    return(scores)
}