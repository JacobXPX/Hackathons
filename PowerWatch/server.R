suppressPackageStartupMessages(c(
  library(shinythemes),
  library(shiny),
  library(jsonlite),
  library(httr),
  library(dplyr),
  library(ggplot2),
  library(grid),
  library(png),
  library(lubridate)
))

########################################################################################## data preparation

httr::set_config( config( ssl_verifypeer = 0L ) )
CA <- authenticate("pux215", <SECRET>, type = "basic")

# basic url
topUrl <- "https://pi-core.ad.lehigh.edu/piwebapi"

# get the buliding list and feature list
searchUrl <- "https://pi-core.ad.lehigh.edu/piwebapi/search/query?q=afelementtemplate:elec*"
response <- GET(searchUrl, CA)
searchResult <- fromJSON(toJSON(content(response)))
buildingList <- searchResult$Items$Name
featureList <- searchResult$Items$Attributes[[1]]$Name

############################## choose the faeture to do data analysis
numRecord <- 365
featureId <- match( "Daily Energy", featureList)

# get data for 6 buildings
records <- data.frame(Timestamp = character(0) , Value = numeric(0), building = character(0))
for (buildings in 1:length(buildingList)){
  webId <- searchResult$Items$Attributes[[buildings]]$WebID[[featureId]]
  recordUrl <- paste0(topUrl,'/streams/',webId,'/recorded?startTime=-',as.character(numRecord),'d')
  response <- GET(recordUrl, CA)
  value <- fromJSON(toJSON(content(response)))
  if(is.null(value$Items) == FALSE){
    tmp <- value$Items %>% select(1,2) %>% mutate(building = rep(buildingList[[buildings]],nrow(value$Items)))
    records <- rbind(records,tmp)
  }
}
records <- records %>% mutate(Timestamp = substr(as.character(Timestamp),1,10),
                              Value = as.numeric(as.character(Value)))%>%
  mutate(Timestamp = as.Date(Timestamp,"%Y-%m-%d"),
         month = month(Timestamp, label = T, abbr = T),
         weekday = weekdays(Timestamp,abbreviate = F))
for(i in 1:nrow(records)){
  if((records$Value[i] < 0 | records$Value[i] > 10^4) & !is.na(records$Value[i])){
    records$Value[i] <- NA
  }
  if (i > 1){
    if(is.na(records$Value[i]) & (records$building[i]==records$building[i-1])){
      records$Value[i] <- mean(records$Value[i-1:i+1], na.rm = T)
    }
  }
  records$Building[i] <- strsplit(records$building[i],"_")[[1]][1]
}


############################### choose the faeture to do real time
numRecord2 <- 16
featureId2 <- match( "Watts Total", featureList)

# get data for 6 buildings
records2 <- data.frame(Timestamp = character(0) , Value = numeric(0), building = character(0))
for (buildings in 1:length(buildingList)){
  webId <- searchResult$Items$Attributes[[buildings]]$WebID[[featureId2]]
  recordUrl <- paste0(topUrl,'/streams/',webId,'/recorded?startTime=-',as.character(numRecord2),'h')
  response <- GET(recordUrl, CA)
  value <- fromJSON(toJSON(content(response)))
  if(is.null(value$Items) == FALSE){
    tmp <- value$Items %>% select(1,2) %>% mutate(building = rep(buildingList[[buildings]],nrow(value$Items)))
    records2 <- rbind(records2,tmp)
  }
}
# treat time
records2 <- records2 %>% mutate(Timestamp = substr(as.character(Timestamp),1,13),
                                Value = as.numeric(as.character(Value)))
records2$Timestamp <- as.character(strptime(records2$Timestamp,"%Y-%m-%dT%H"))
for(i in 1:nrow(records2)){
  if((records2$Value[i] < 0 | records2$Value[i] > 10^7) & !is.na(records2$Value[i])){
    records2$Value[i] <- NA
  }
  if (i > 1){
    if(is.na(records2$Value[i]) & (records2$building[i]==records2$building[i-1])){
      records2$Value[i] <- mean(records2$Value[i-1:i+1], na.rm = T)
    }
  }
  records2$Building[i] <- strsplit(records2$building[i],"_")[[1]][1]
}
records2  <- records2 %>% group_by(Building, Timestamp) %>% summarize(Value = mean(Value,na.rm=T))
records2$hours <- rep(1:16,6)
records2 <- records2 %>% select(Value,hours,Building) %>% mutate(Value = Value/1000)
records2 <- as.data.frame(records2)

image <- readPNG("./data/map.png")
g <- rasterGrob(image, interpolate=TRUE)

#################################################################################### interactive

shinyServer(function(input, output) {
  
  ################################ write reactive plot function of analysis
  anaPlot <- reactive({
    # get the input data
    chosenSet <- input$chosenSet
    timeBucket <- input$timeBucket
    # choose the building
    Records <- records%>%filter(Building %in% chosenSet)
    if (timeBucket == "Monthly Usage"){
      # month
      monthData <- Records %>% group_by(month, Building) %>% summarize(Value = mean(Value, na.rm = T))
      ananlysisPlot <- ggplot(monthData, aes(x = month, y = Value, fill = Building, group = Building)) +
        geom_bar(stat = "identity") + scale_fill_brewer(palette = "Paired") + 
        labs(y = "Daily Energy (Kwh)")
    }else if (timeBucket == "Weekly Usage"){
    # weekday
    m <- c("Monday", "Tueday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday")
    weekdayData <- Records %>% group_by(weekday, Building) %>% summarize(Value = mean(Value, na.rm = T))
    weekdayData$weekday <- factor(m, levels = m)
    ananlysisPlot <- ggplot(weekdayData, aes(x = weekday, y = Value, fill = Building, group = Building)) +
      geom_bar(stat = "identity") + scale_fill_brewer(palette = "Paired") + 
      labs(y = "Daily Energy (Kwh)")
    }else{
    # day
    ananlysisPlot <- ggplot(Records, aes(x = Timestamp, y = Value, color = Building)) +
      geom_line() + geom_smooth() + 
      labs(y = "Daily Energy (Kwh)", x = "days")}
    print(ananlysisPlot)
  })
  
  
  ################################ write reactive plot function of realtime visualization
  rtPlot <- reactive({
    # get the input data
    hourChoice <- input$time
    recordsRealTime <- records2 %>% filter(hours == hourChoice)
    buildingOrder <- c(4,6,1,2,5,3)
    temp <- recordsRealTime[buildingOrder,]
    rownames(temp) <- rownames(recordsRealTime)
    points <- data.frame(xx = c(33, 32.3, 55.9, 50.6, 57.3, 62.6), 
                         yy = c(89.5, 86, 63.5, 61, 8.5, 3.6))
    mergedPoint <- cbind(points,temp)
    realTPlot <- qplot(10:10, 10:10) +
      annotation_custom(g, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf) +
      geom_point(data = mergedPoint, 
                 aes(x = xx, y = yy, size = Value, color = Value), 
                 alpha = 0.6)  + scale_color_distiller (palette = "OrRd",trans = "reverse")+
      ylim(0,100) + xlim(0,100)+
      theme(text = element_blank(),
            rect = element_blank(),
            legend.position="none",
            strip.background  = element_blank()) + 
      coord_fixed(ratio = 0.65) + scale_size_area(max_size = 30)
    print(realTPlot)
  })

  ################################ output analysis plot with using reactive plot function
  output$Plot <- renderPlot({anaPlot()}, height=500)
  output$realTimePlot <- renderPlot({rtPlot()}, height=750)
  
  
})
