library(rvest)
library(tidyverse)
library(RSelenium) 
library(httr)


rank_info <- data.frame()

pages <- read.csv("./WebsitesList.csv")

driver <-  RSelenium::rsDriver(browser = "chrome",port = 4234L,chromever = "92.0.4515.107")

remote_driver <- driver[["client"]] 

#
for (page in pages[3]){
  
  remote_driver$navigate(paste0(page,"?page=10"))
  web<- read_html(paste0(page,"?page=10"))
  tag_info <- web %>%
    html_nodes("div.result-table") %>%
    html_text()
}





a <- read_html(remote_driver$getPageSource()[[2]])
  
plan <- a %>% html_nodes("div:nth-of-type(n+4) h6") %>% html_text()
price <- a %>% html_nodes(".border-r-2-right-bottom-tablet h2") %>% html_text()
head(plan)