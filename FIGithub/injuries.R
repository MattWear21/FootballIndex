####FIND ALL INJURIES IN THE TOP 5 LEAGUES

library(rvest)
library(stringr)

getInjuries <- function() {

  leagueurl <- c("england-premier-league/", 
                 "spain-laliga/", 
                 "italy-serie-a/",
                 "germany-bundesliga/",
                 "france-ligue-1/")
  
  all_injuries <- data.frame(player_name=as.character(), return=as.character())
  
  for (i in leagueurl) {
  
    url <- paste("https://www.sportsgambler.com/team-news/", i, sep="")
    
    webpage <- read_html(url)
    
    injured_players <- webpage %>%
      html_nodes(xpath = "//td[(((count(preceding-sibling::*) + 1) = 4) and parent::*)]//a | //td[(((count(preceding-sibling::*) + 1) = 2) and parent::*)]//a") %>%
      html_text() %>%
      str_trim()
    
    m1 <- matrix(injured_players, ncol=2, byrow=TRUE)
    league_injuries <- as.data.frame(m1, stringsAsFactors=FALSE)
    
    all_injuries <- rbind(all_injuries, league_injuries)
  
  }
  
  names(all_injuries) <- c("player_name", "return")
  
  return(all_injuries)

}

injuries_top5 <- getInjuries()
