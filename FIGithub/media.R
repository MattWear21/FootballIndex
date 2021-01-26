#media_divs: time series of all media winners and their dividend amount
#today_media_players: only todays players who scored above zero
#today_media_data: all top 200 players (eligible for media divs) and their media scores for today


library(RSelenium)
rD <- rsDriver()
remDr <- rD[["client"]]

#MEDIA BUZZ
#Historic data kept in media_data table
  
remDr$navigate("https://www.footballindex.co.uk/stockmarket/buzz")
  
#scroll down once
  
# remDr$executeScript(paste("scroll(0,",10000,");"))
  
today_media_players <- data.frame(player_name = as.character(), 
                                  media_score = as.double(), 
                                  mb_divs = as.double(),
                                  stringsAsFactors = FALSE)
  
today <- Sys.Date()
today <- format(today, format="%d/%m/%Y")
webElemMediaName <- remDr$findElements(using = 'css', "[class = 'ng-binding ng-isolate-scope']")
webElemMediaScore <- remDr$findElements(using = 'css', "[class = 'col score text-center ng-binding']")
  
for (i in 1:length(webElemMediaName)) {
  elemMediaName <- webElemMediaName[[i]]
  elemMediaScore <- webElemMediaScore[[i]]
    
  name <- elemMediaName$getElementText()[[1]]
  score <- elemMediaScore$getElementText()[[1]]
  
  today_media_players[i, 1] <- name
  today_media_players[i, 2] <- as.double(score)
}

#merge todays media with historical media data
top200players <- top200
today_media_data <- merge(x = top200players, y = today_media_players, by="player_name", all.x = TRUE)
today_media_data[is.na(today_media_data)] <- 0
today_media_data$mb_divs <- 0

#ADD DIVIDEND FOR TOP MEDIA PLAYER

today_media_players[1,"player_name"]
today_media_players[1,"media_score"]
today_media_data[which(today_media_data$player_name == today_media_players[1,"player_name"]),"mb_divs"] <- 0.05
media_divs <- rbind(data.frame(date=today, player_name=today_media_players[1,1], media_divs=0.05), media_divs)

# today <- as.character(Sys.Date())
# names(media_data)[length(names(media_data))] <- as.character(today)
#media <- rbind(media, today_media_data)


remDr$close()
rD[["server"]]$stop() 

