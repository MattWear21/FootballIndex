####PORTFOLIO SCRAPE
library(RSelenium)

rD <- rsDriver()
remDr <- rD[["client"]]

#navigate to your portfolio
remDr$navigate("https://www.footballindex.co.uk/stockmarket/portfolio")

transaction_history <- data.frame(player_name = as.character(),
                                  day = as.character(), 
                                  date = as.character(), 
                                  time = as.character(), 
                                  type = as.character(), 
                                  quantity = as.integer(), 
                                  value = as.double(), 
                                  stringsAsFactors = FALSE)

#13 pages

for (i in 1:13) {
  
  transactionElem <- remDr$findElements(using='css', value="[class='row-flex row-flex-center transaction ng-scope']")

  for (j in 1:length(transactionElem)) {
    
    transaction <- transactionElem[[j]]$getElementText()
    pos <- gregexpr("[\n]", transaction)
    day <- substr(transaction, 1, 3)
    date <- substr(transaction, 5, 12)
    #date <- as.Date(date, "%d/%m/%y")
    time <- substr(transaction, 16, 23)
    type <- substr(transaction, pos[[1]][1]+1, pos[[1]][2]-1)
    player_name <- substr(transaction, pos[[1]][2]+1, pos[[1]][3]-1)
    quantity <- as.integer(substr(transaction, pos[[1]][3]+1, pos[[1]][4]-1))
    value <- substr(transaction, pos[[1]][4]+1, nchar(transaction))
    value <- as.double(gsub('\\£', '', value))
    n <- nrow(transaction_history) + 1
    
    transaction_history[n, "player_name"] <- player_name
    transaction_history[n, "day"] <- day
    transaction_history[n, "date"] <- date
    transaction_history[n, "time"] <- time
    transaction_history[n, "type"] <- type
    transaction_history[n, "quantity"] <- quantity
    transaction_history[n, "value"] <- value
    
  }
    
  backiconElem <- remDr$findElements(using='css', value="[class='back-icon']")
  backiconElem[[1]]$clickElement()
  Sys.sleep(3)
  
}

remDr$close()
rD[["server"]]$stop() 
