#HISTORIC PB DATA IN TABLE performance_data
##MONDAY 27TH START THIS DATA TABLE AGAIN - SETTING NA TO 0 IS FALSE

library(RSelenium)
rD <- rsDriver()
remDr <- rD[["client"]]
  
remDr$navigate("https://www.footballindex.co.uk/stockmarket/performance")
  
#scroll down a few times (MAY NEED CHECKING, CHECK ON SATURDAY)
  
  # for(i in 1:8){      
  #   remDr$executeScript(paste("scroll(0,",i*10000,");"))
  #   Sys.sleep(3)
  # }
  
today_matchday_players <- data.frame(player_name = as.character(), 
                                     match_score = as.double(), 
                                     date=as.character(),
                                     pb_divs = as.double(),
                                     stringsAsFactors = FALSE)
  
#today <- as.character(Sys.Date())
webElemMatchName <- remDr$findElements(using = 'css', "[class = 'ng-binding ng-isolate-scope']")
webElemMatchScore <- remDr$findElements(using = 'css', "[class = 'col score text-center ng-binding']")
  
for (i in 1:length(webElemMatchName)) {
  elemMatchName <- webElemMatchName[[i]]
  elemMatchScore <- webElemMatchScore[[i]]
    
  name <- elemMatchName$getElementText()[[1]]
  score <- elemMatchScore$getElementText()[[1]]
    
  today_matchday_players[i, 1] <- name
  today_matchday_players[i, 2] <- as.double(score)
  today_matchday_players[i, 3] <- today
}
  
#merge todays data to historical data
players_merge <- all_FI_players %>%
  select(player_name, price, team)
today_performance_data <- merge(x = players_merge, y = today_matchday_players, by = "player_name", all.x = TRUE)
#performance_data <- rbind(performance_data, today_performance_data)

#Add correct dividend amount to each player
today_matchday_players$pb_divs <- 0

#playerPositions <- pbscores %>%
#  select(player_name, Position)

#today_matchday_players <- merge(x=today_matchday_players, y=playerPositions, by="player_name", all.x=TRUE)

today_matchday_players$date <- as.Date(today_matchday_players$date, "%d/%m/%Y")

today_matchday_players[which(today_matchday_players$player_name=="Charles Aranguiz"),"pb_divs"] <- 0.18
today_matchday_players[which(today_matchday_players$player_name=="Jonathan Tah"),"pb_divs"] <- 0.12
today_matchday_players[which(today_matchday_players$player_name=="Robert Lewandowski"),"pb_divs"] <- 0.12

# addPBDivs <- function(day) {
#   #Takes single, double or treble
#   if(day=="single") {
#     topForward <- 0.02
#     topMidfielder <- 0.02
#     topDefender <- 0.02
#     starPlayer <- 0.01
#   }
# }


remDr$close()
rD[["server"]]$stop() 
