#Beta IPO Notifier

library(RSelenium)
library(notifier)
library(beepr)

rD <- rsDriver(browser=c("firefox"))
remDr <- rD[["client"]]

remDr$navigate("https://www.footballindex.co.uk/player/adil-aouchiche")

while(TRUE) {
  titleElem <- remDr$findElements(using='id', "sell")
  buyButtonText <- titleElem[[1]]$getElementText()[[1]]
  if(buyButtonText != "£") {
    buyElem <- remDr$findElements(using='id', "buy")
    buyElem[[1]]$clickElement()
    maxbuyElem <- remDr$findElements(using='id', "secondButton")
    maxbuyElem[[1]]$clickElement()
  
    beep()
    print("******He's IPO'd!!!*******")
    Sys.sleep(1)
    beep()
    print("******He's IPO'd!!!*******")
    Sys.sleep(1)
    beep()
    print("******He's IPO'd!!!*******")
    break
  } else {
    print("Not yet")
  }
  Sys.sleep(1)
}

remDr$close()
rD[["server"]]$stop() 
