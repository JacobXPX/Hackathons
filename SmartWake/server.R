#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

suppressPackageStartupMessages(c(
  library(shinythemes),
  library(shiny),
  library(shinyTime),
  library(tm),
  library(stringr),
  library(markdown),
  library(stylo),
  library(ggplot2),
  library(grid),
  library(png),
  library(jsonlite),
  library(dplyr),
  library(lubridate),
  library(curl)))

# Load and prepare the data
jsonData <- fromJSON("http://apidev.accuweather.com/forecasts/v1/hourly/72hour/349727?apikey=PSUHackathon112016&details=true")
Data <- jsonData %>% select(DateTime, UVIndex)
datestring <- substr(Data$DateTime,1,19)
Data$DateTime <- strptime(datestring, "%Y-%m-%dT%H:%M:%S")
now <- Sys.time()

# Calculate needed data
for (i in 5:nrow(Data)){
  if (Data$UVIndex[i-1] == 0 && Data$UVIndex[i] > 0){
    sunrise <- i-2
    break
  }}
for (i in sunrise:nrow(Data)){
  if (Data$UVIndex[i-1] > 0 && Data$UVIndex[i] == 0){
    sunset <- i
    break
  }
}
t0 <- Data$DateTime[sunrise]
t1 <- Data$DateTime[sunset]
d <- yday(Data$DateTime[sunrise])/365
beta0 <- 1.0531
beta1 <- 17.7151
beta2 <- -18.307
s_bar <- beta0 + beta1 *d + beta2 *d^2
mu <- 6*s_bar / (hour(t1) -hour(t0))^2
c <- 1.5*s_bar

# plot sun
image <- readPNG("./about/sun.png")
g <- rasterGrob(image, interpolate=TRUE)
rect <- data.frame(xmin=1, xmax=2, ymin=-Inf, ymax=Inf)
Plot <- qplot(1:1, 1:1, geom="blank") +
  annotation_custom(g, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf) +
  geom_point()+
  theme(text = element_blank(),
        rect = element_blank(),
        strip.background  = element_blank())

# server
shinyServer(function(input, output) {

  output$myplot <- renderPlot({
    Plot +  geom_rect(data=rect, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),
                      color="white", fill = "black", alpha=0.6-log(1+input$targetLight*(exp(0.6)-1)/10))})
  
  
  output$resultTime <- renderPrint({
    t <- (hour(t1) + hour(t0))/2 - sqrt((c-c*(input$targetLight-1)/9)/mu)
    midnight  <- as.POSIXct(trunc(t0, units="days"))
    t <- midnight + (3600*t)
    if (input$startTime - input$endTime > 0){print("please check the time slot you set.")}else{
      if (is.na(t)) {t <- input$endTime}
        else {if (day(t) == day(now)) {if (t >input$startTime & t <input$endTime) t <- t
            else if (t < input$startTime) t <- input$startTime
            else t <- input$endTime
          }else
          {if (t > input$startTime + 24*3600 & t <input$endTime + 24*3600) t <- t
          else if (t < input$startTime +24*3600 ) t <- input$startTime + 24*3600
          else t <- input$endTime +24*3600
          }
        }
      if (as.numeric(t - (input$sleepTime + 24 *60*60)) < 6 & hour(input$sleepTime) < 6){
        t <- input$sleepTime + 6 *60*60
      }
      t <- as.character(t)
      t}
    })
})
