#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
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


shinyUI(navbarPage("Welcome", theme = shinytheme("flatly"),
## Tab 1 - Interfcae
  tabPanel("Smart Wake", tags$head(includeScript("./js/ga-shinyapps-io.js")),
           fluidRow(column(2),
                    column(8,tags$div(sliderInput("targetLight", label = h3("Choose the level of sunlight:"),
                                                  min = 1, max = 10, step = 1, value = 5),
                                      tags$span(style="color:grey",("5 is recommended")),
                                      br(), tags$hr(),align="center"),
                    column(2))),
           fluidRow(column(3),
                    column(6, tags$div(plotOutput("myplot"),align="center")),
                    column(3)),
           hr(),
           fluidRow(column(4),
                    column(4, tags$div(timeInput("sleepTime", label = h4("Bed time:"),
                                                 value = strptime("23:00:00", "%T")),align = "center")),
                    column(4)),
           hr(),
           fluidRow(column(4),
                    column(4, tags$div(timeInput("startTime", label = h4("Earliest time:"),
                                        value = strptime("06:00:00", "%T")),align = "center")),
                     column(4)),
           fluidRow(column(4),
                    column(4, tags$div(timeInput("endTime", label = h4("Latest time:"),
                                        value = strptime("10:00:00", "%T")),align = "center")),
                    column(4)),
           hr(),

           fluidRow(column(4),
                    column(4, tags$div(h4("The best wake up time:"),
                                       tags$span(style="color:darkred",
                                                 tags$strong(tags$h3(textOutput("resultTime"))))
                                       ,align = "center")),
                    column(4))
           ),
                   
############################### ~~~~~~~~2~~~~~~~~ ##############################
## Tab 2 - About 
          tabPanel("About",
                   fluidRow(column(2,p("")),
                      column(8,includeMarkdown("./about/about.md")),
                      column(2,p(""))
                    )),
############################### ~~~~~~~~2~~~~~~~~ ##############################
## Tab 3 - feedback
tabPanel("Feedback",
         fluidRow(column(2,p("")),
                  column(8,tags$div(textInput("hehe", label = "How do you feel this morning?"),
                         align = "center")),
                  column(2,p(""))
                  ),
         fluidRow(column(2,p("")),
                  column(8,tags$div(textInput("hehe2", label = "What else do you want to tell us?"),
                         align = "center")),
                  column(2,p(""))
         ),
fluidRow(column(4,p("")),
         column(4,tags$div(actionButton("hehe3", label = "Submission"),
                           align = "center")),
         column(4,p(""))
         )),
############################### ~~~~~~~~F~~~~~~~~ ##############################
## Footer
   tags$hr(),
   tags$br(),
   tags$span(style="color:grey", 
  tags$footer(("© 2016 - Puxin & Yuheng"),
              ("Built with"), tags$a(
                href="http://www.r-project.org/",
                target="_blank",
                "R"),
              ("&"), tags$a(
                href="http://shiny.rstudio.com",
                target="_blank",
                "Shiny."),
              
              align = "center"),
  
  tags$br()
   )

)

)



