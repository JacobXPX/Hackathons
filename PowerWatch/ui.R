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
shinyUI(
  fluidPage(
             headerPanel(h1(
               
               tags$img(src = "https://s15.postimg.org/621fazpkb/Team_S.png", width = "200px", height = "200px"),
               "Power Watch", 
               style = "background:url(https://s11.postimg.org/n9q4yqclf/skyline_1566218_640.png);font-family: 'BlackChancery', sans-serif; 
                               font-weight: 100px; line-height: 100px;font-size: 60px;
                               color: #032951;")),

                   theme = shinytheme("flatly"),
             navlistPanel(widths = c(1.8,10.2),
############################################## tab 1 ############################## 
          tabPanel("History Analysis",
                   sidebarLayout( 
                     sidebarPanel(h3("Choose Target"),
                          checkboxGroupInput("chosenSet", label = "Choose the buildings:",
                                             c("Jordan", "Varsity", "Williams", "Bldg-C", "RauchChiller", "Sherman" ),
                                             selected = c("Jordan", "Varsity")),
                          selectInput("timeBucket", label = "Choose time bucket:",
                          choices = c("Monthly Usage", "Weekly Usage", "Daily Usage"), selected = "Daily Usage"),
                          width = 3),
                     mainPanel(h3("Energy Gragh"),
                               plotOutput("Plot"))
                   )
          ),
############################################## tab 1 ############################## 
          tabPanel("Real Time Visualization", 
                   fluidRow(column(3),
                            column(6,sliderInput("time", "Prediction Horizon:",
                                               min = 1, max = 16, value = 5, step = 1, width = 600
                            )),
                            column(3)
                   ),
                   fluidRow(column(1),
                            column(10,plotOutput("realTimePlot"),
                                   column(1)
                            )
                   )

          )

  )
)
)