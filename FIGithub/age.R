####Get FI Players age

library(RSelenium)
library(rvest)
library(stringr)
#start RSelenium
rD <- rsDriver()
remDr <- rD[["client"]]

#TOP 200
#navigate to your page
remDr$navigate("https://www.footballindex.co.uk/stockmarket/team")

#get the name and price elements
webElem <- remDr$findElements(using = 'css', "[class = 'ng-binding ng-isolate-scope']")
n <- length(webElem) 

FIAge <- data.frame(player_name = as.character(), 
                     birth = as.character(),
                     stringsAsFactors = FALSE)

#loop through top 200 players
for (i in 1:n) {
  elem <- webElem[[i]]
  name <- elem$getElementText()[[1]]
  elem$clickElement()
  Sys.sleep(2)
  bdayElem <- remDr$findElements(using = 'css', "[class='fame-info-desc ng-binding']")
  bday <- bdayElem[[4]]$getElementText()[[1]]
  
  FIAge[i, 1] <- name
  FIAge[i, 2] <- bday

  elem$clickElement()
}

#loop through squad players

lastpage <- remDr$findElements(using = 'css', "[ng-if='ctrl.showLast']")
pages <- as.double(lastpage[[2]]$getElementText()[[1]])

squad_age <- data.frame(player_name = as.character(), 
                        birth = as.character(),
                        stringsAsFactors = FALSE)
squad_age_init <- data.frame(player_name = as.character(), 
                             birth = as.character(),
                             stringsAsFactors = FALSE)

for (j in 123:pages) {
  
  url <- str_c("https://www.footballindex.co.uk/stockmarket/squad/", j, "/")
  remDr$navigate(url)
  remDr$setImplicitWaitTimeout(milliseconds = 10000)
  webElemSquad <- remDr$findElements(using = 'css', "[class = 'ng-binding ng-isolate-scope']")
  n <- length(webElemSquad) 
  
  #loop through squad players
  for (i in 1:n) {
    elemSquad <- webElemSquad[[i]]
    
    name <- elemSquad$getElementText()[[1]]
    elemSquad$clickElement()
    Sys.sleep(2)
    bdayElem <- remDr$findElements(using = 'css', "[class='fame-info-desc ng-binding']")
    bday <- bdayElem[[4]]$getElementText()[[1]]
    
    squad_age_init[i, 1] <- name
    squad_age_init[i, 2] <- bday
    
    print(name)
    print(bday)
    
    elemSquad$clickElement()
  }
  
  squad_age <- rbind(squad_age, squad_age_init)
  
}


remDr$close()
rD[["server"]]$stop() 


FI_Age_RAW <- rbind(FIAge, squad_age)
FI_Age_CLEAN <- FI_Age_RAW

nonNAages <- FI_Age_CLEAN[complete.cases(FI_Age_CLEAN), ]
nonNAages$age <- age_calc(nonNAages$birth, units="years")

playersAge <- merge(x=understat_FI_merge, y=nonNAages, by="player_name", all.x=T)
playersAge <- playersAge %>%
  select(player_name, team_name, age, price, games, goals, assists, xG, xA, xGChain, xGBuildup) %>%
  arrange(age)
