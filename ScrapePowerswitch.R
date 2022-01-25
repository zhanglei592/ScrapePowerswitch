library(rvest)
library(tidyverse)
library(RSelenium) 
library(httr)


pages <- read.csv("data/WebsitesList.csv")

driver <-  RSelenium::rsDriver(browser = "chrome",port = 4234L,chromever = "97.0.4692.71")

remote_driver <- driver[["client"]] 

rank_info <- data.frame()

for (i in 1:nrow(pages)){
  
  i <- 1
  row <- pages[i,]
  page <- row$Link
  
  remote_driver$navigate(paste0(page,"?page=10"))
  Sys.sleep(10)
  
  page_source <- remote_driver$getPageSource()[[1]] %>% read_html()
  
  company <- page_source %>% 
    html_nodes("figure.retailer-logo.dn.dib-tablet.ma0") %>% 
    html_nodes("img") %>% 
    html_attr("alt")
  
  price <- page_source %>% 
    html_nodes('div.result-individual-eyc.flex.fd-column.w100.order-1.order-2-tablet') %>% 
    html_nodes("h2") %>% 
    html_text()
  
  plan <- page_source %>% 
    html_nodes("div.w100.flex.ai-flex-end.mb2") %>% 
    html_nodes("h6") %>% 
    html_text()
  
  plan_tb <- page_source %>% 
    html_nodes("div.result-tile") %>% 
    html_nodes("tbody.w100") %>% 
    html_table()%>% 
    map(~.x %>% toJSON()) %>% 
    unlist()

  page_info <- data.frame("company"=company, "price"=price, "plan"=plan, "plan_tb" = plan_tb) %>% 
    mutate("region" = row$Region ) %>% 
    select(region, company, price, plan, plan_tb)
  
  rank_info <- rbind(rank_info, page_info)
}

rank_info %>% write_csv("data/rank_info.csv")

# Close the remote driver
remote_driver$close()
driver$server$stop()
system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
