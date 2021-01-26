## FIRST SCRAPE TOOK PLACE ON 26TH JANUARY 2019

library(RSelenium)
library(rvest)
library(stringr)
#start RSelenium
rD <- rsDriver(browser=c("firefox"))
remDr <- rD[["client"]]

#TOP 200
#navigate to your page
remDr$navigate("https://www.footballindex.co.uk/stockmarket/team")

#footie index
today <- Sys.Date()
today <- format(today, format="%d/%m/%Y")
footieindexElem <- remDr$findElements(using='css', "[class='pull-right']")
indextext <- footieindexElem[[1]]$getElementText()
footieIndex <- gsub( " .*$", "", indextext )
footieIndex <- as.numeric(gsub("\\,", "", footieIndex))
historic_footie_index <- rbind(historic_footie_index, data.frame(date=today, footie_index=footieIndex))

#scroll down 8 times, waiting for the page to load at each time

#get the name and price elements
webElem <- remDr$findElements(using = 'css', "[class = 'ng-binding ng-isolate-scope']")
prices <- remDr$findElements(using='css', "[class = 'sell-buy-wrapperv2']")
teamName <- remDr$findElements(using='css', "[class = 'col club visible-desktop text-center']")
n <- length(webElem) 

top200 <- data.frame(player_name = as.character(), 
                     price = as.double(), 
                     team = as.character(),
                     date = as.character(),
                     stringsAsFactors = FALSE)

#loop through top 200 players
for (i in 1:n) {
  elem <- webElem[[i]]
  elem2 <- prices[[i]]
  elemTeam <- teamName[[i]]
  
  name <- elem$getElementText()[[1]]
  price <- elem2$getElementText()[[1]]
  team <- elemTeam$getElementText()[[1]]
  
  price <- price %>%
    str_replace_all("[\r\n]" , "") %>%
    str_sub(gregexpr(price, pattern ='£')[[1]][1]+1, gregexpr(price, pattern ='B')[[1]][1]-2)
  
  top200[i, 1] <- name
  top200[i, 2] <- as.double(price)
  top200[i, 3] <- team
  top200[i, 4] <- today
}

#SQUAD PLAYERS
remDr$navigate("https://www.footballindex.co.uk/stockmarket/squad/1/")

lastpage <- remDr$findElements(using = 'css', "[ng-if='ctrl.showLast']")
pages <- as.double(lastpage[[2]]$getElementText()[[1]])

squad_players <- data.frame(player_name = as.character(), 
                            price = as.double(), 
                            team = as.character(),
                            date = as.character(),
                            stringsAsFactors = FALSE)
squad_players_init <- data.frame(player_name = as.character(), 
                                 price = as.double(), 
                                 team = as.character(),
                                 date = as.character(),
                                 stringsAsFactors = FALSE)

#loop through all pages of squad players
for (j in 1:pages) {
  
  url <- str_c("https://www.footballindex.co.uk/stockmarket/squad/", j, "/")
  remDr$navigate(url)
  #Sys.sleep(3)  
  remDr$setTimeout(type = "implicit", milliseconds = 5000)
  webElemSquad <- remDr$findElements(using = 'css', "[class = 'ng-binding ng-isolate-scope']")
  pricesSquad <- remDr$findElements(using='css', "[class = 'sell-buy-wrapperv2']")
  teamSquad <- remDr$findElements(using='css', "[class = 'col club visible-desktop text-center']")
  n <- length(webElemSquad) 
  
  #loop through squad players
  for (i in 1:n) {
    elemSquad <- webElemSquad[[i]]
    elem2Squad <- pricesSquad[[i]]
    elemSquadTeam <- teamSquad[[i]]
    
    name <- elemSquad$getElementText()[[1]]
    price <- elem2Squad$getElementText()[[1]]
    team <- elemSquadTeam$getElementText()[[1]]
    
    price <- price %>%
      str_replace_all("[\r\n]" , "") %>%
      str_sub(gregexpr(price, pattern ='£')[[1]][1]+1, gregexpr(price, pattern ='B')[[1]][1]-2)
    
    squad_players_init[i, 1] <- name
    squad_players_init[i, 2] <- as.double(price)
    squad_players_init[i, 3] <- team
    squad_players_init[i, 4] <- today
    
    print(name)
    print(price)
    print(team)
  }
  
  squad_players <- rbind(squad_players, squad_players_init)

}

#data frame containing all players in FI
all_FI_players <- rbind(top200, squad_players)
#remove duplicates
all_FI_players <- all_FI_players[!duplicated(all_FI_players$player_name), ]
#todays prices data frame
today_prices <- all_FI_players
#collection of historic price data
# historic_prices <- all_FI_players %>%
#   select(player_name, team)

#update historic prices dataframe
#historic_prices <- merge(x = historic_prices, y = today_prices, by="player_name", all.y=TRUE)
historic_prices <- rbind(historic_prices, today_prices)
#rename last column
# today <- as.character(Sys.Date())
# names(historic_prices)[length(names(historic_prices))] <- as.character(today)

write.csv(today_prices, "today_FI_prices.csv")


remDr$close()
rD[["server"]]$stop() 

all_FI_players <- all_FI_players %>%
  mutate(top5 = ifelse(team %in% FI_teams, 1, 0))
FI_TOP_5_LEAGUES <- all_FI_players %>%
  filter(top5==1)
