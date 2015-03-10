# COLLECT RUNNERS FROM THE RACING POST THE NIGHT BEFORE

# load libraries
library(rvest)
library(stringr)

### 
# base url
tomorrow <- Sys.Date() + 1

RP_url <- sprintf(fmt = "http://www.racingpost.com/horses2/cards/meeting_of_cards.sd?r_date=%s&crs_id=11&type=0&tab=lc_", tomorrow)
htmlfile <- RP_url %>%
    html()
# collect runners index
r_id <- htmlfile %>% 
    html_nodes("td:nth-child(1) b") %>%
    html_text() %>%
    as.numeric()
# collect runners names
r_name <- htmlfile %>%
    html_nodes(".h b") %>%
    html_text() %>%
    str_replace_all("Â", "")
# collect race times
race_time <- htmlfile %>%
    html_nodes(".raceTime a") %>%
    html_text()
# collect race name
race_name <- htmlfile %>%
    html_nodes(".uppercase a") %>%
    html_text()
# number of runners per race
race_runners <- htmlfile %>%
    html_nodes(".raceTitle p:nth-child(1)") %>%
    html_text() %>%
    str_extract_all("[[:digit:]]+ ?runners") %>%
    unlist() %>%
    str_replace_all(" runners", "") %>%
    as.numeric()

# create dataframe
day_one <- data.frame(date = Sys.Date() + 1, 
                      time = rep(race_time, race_runners),
                      race = rep(race_name, race_runners),
                      runners = rep(race_runners, race_runners),
                      horse_id = r_id,
                      horse = r_name)
day_one$G1 <- grepl(pattern = "Grade 1", x = day_one$race, ignore.case = TRUE)

rm(RP_url, htmlfile, r_id, r_name, race_name, race_runners, race_time, tomorrow)
save(day_one, file = "data/day_one.RData")
