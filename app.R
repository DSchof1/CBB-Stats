source("Data Pull/pull_data.R")
source("Math Functions/functions.R")
source("Schedule Component/Schedule For Date.R")
source("Schedule Component/Schedule Filler.R")
source("Schedule Component/excel_download.R")
source("Schedule Component/schedule_download_component.R")
source("Schedule Component/likely_dates_preload.R")
source("Schedule Component/schedule_games_component.R")
library(shiny)
library(shinydashboard)
library(markdown)
library(rmarkdown)
library(shinyalert)
library(shinyjs)
#library(shinydashboardPlus)

ui <- dashboardPage(
  dashboardHeader(title = "NCAA Basketball Matchup Stats", titleWidth = 500),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Schedule", tabName = "schedule", icon = icon("calendar")),
      menuItem("Simulation", tabName = "simulation", icon = icon("server")),
      menuItem("Simulation Methodology", tabName = "simulation_methodology", icon = icon("cogs")),
      menuItem("Matchup Utility", tabName = "dashboard", icon = icon("tachometer-alt")),
      menuItem("Log5 Methodology", tabName= "log5_methodology", icon=icon("calculator"))
    )
  ),
  dashboardBody(
    useShinyjs(),
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
                column(5,
                       selectInput(
                         inputId = "Away",
                         label = h3("Away Team"),
                         choices = c(NCAA$TEAM, sort(unique(master_data[master_data$TEAM != "NCAA",]$TEAM)))),
                       align="center"),
                column (2, h3("")),
                column(5,
                       selectInput(
                         inputId = "Home",
                         label = h3("Home Team"),
                         choices = c(NCAA$TEAM, sort(unique(master_data[master_data$TEAM != "NCAA",]$TEAM)))
                       ),
                       align="center")
              ),
              
              br(),
              
              fluidRow(
                column(5,
                       htmlOutput(outputId = "imgAway"), align="center"),
                
                column(2,
                       selectInput(
                         inputId = "vsat",
                         label = "",
                         choices = c("vs", "at")),
                       align="center"),
                
                column(5,
                       htmlOutput(outputId = "imgHome"), align="center")
              ),
              
              br(),
              
              fluidRow(
                column(12,
                       textOutput("Log5"),
                       align="center")
              ),
              
              br(),
              
              br(),
              
              fluidRow(
                column(12,
                       h4("The predicted final score is:"),
                       align = "center")
              ),
              
              fluidRow(
                column(5,
                       verbatimTextOutput("TeamAwayScore"),
                       align="center"),
                column(2, 
                       textOutput("Dash"),
                       align="center"),
                column(5,
                       verbatimTextOutput("TeamHomeScore"),
                       align="center")
              ),
              tags$style(type='text/css', "#Dash { width:100%; margin-top:-10px; font-size: 40px;
                                 font-style: bold;}")
      ),
      tabItem(tabName = "log5_methodology",
              withMathJax(includeMarkdown("Methodologies/Methodology.Rmd"))
      ),
      tabItem(tabName = "simulation_methodology",
              withMathJax(includeMarkdown("Methodologies/Binomial Methodology.Rmd"))
      ),
      tabItem(tabName ="simulation",
              fluidRow(
                column(5,
                       selectInput(
                         inputId = "SimAway",
                         label = h3("Away Team"),
                         choices = c(NCAA$TEAM, sort(unique(master_data[master_data$TEAM != "NCAA",]$TEAM)))),
                       align="center"),
                column (2, h3("")),
                column(5,
                       selectInput(
                         inputId = "SimHome",
                         label = h3("Home Team"),
                         choices = c(NCAA$TEAM, sort(unique(master_data[master_data$TEAM != "NCAA",]$TEAM)))
                       ),
                       align="center")
              ),
              
              br(),
              
              fluidRow(
                column(5,
                       htmlOutput(outputId = "SimimgAway"), align="center"),
                
                column(2,
                       selectInput(
                         inputId = "Simvsat",
                         label = "",
                         choices = c("vs", "at")),
                       align="center"),
                
                column(5,
                       htmlOutput(outputId = "SimimgHome"), align="center")
              ),
              
              br(),
              
              fluidRow(
                column(12,
                       plotOutput("NormCurves"),
                       align="center")
              ),
              
              br(),
              
              fluidRow(
                column(12,
                       textOutput("Probs"),
                       align="center")
              ),
              
              br(),
              
              br(),
              
              fluidRow(
                column(12,
                       actionButton("SimButton", "Simulate!"),
                       align="center")
              ),
              
              br(),
              
              fluidRow(
                column(8, offset = 2,
                       verbatimTextOutput("SimScore"),
                       align="center"),
              ),
              
              fluidRow(column(12,
                              textOutput("RegOT"),
                              align="center")
              )
              
      ),
      tabItem(tabName ="schedule",
              excel_download,
              htmlOutput(outputId = "sched_games")
              )
    )
    ,tags$style(
    ".landing_popup .confirm {background-color: #2874A6 !important;}
    #excel_dl_button {
    display: flex;
    align-items: center;
    justify-content: center;}
    #team_display_schedule {
    display: flex;
    align-items: center;}
                "),
    tags$head(tags$style(HTML("/*body*/.content-wrapper, .right-side {background-color: #FFFFFF}
                              .content-wrapper { overflow: auto; }")))
  )
)

server <- function(input, output) {
  
  shinyalert(title = "Updates as of April 14th 2025!",
             closeOnClickOutside = TRUE,
             html = TRUE,
             text = paste0("<h4>Post-Madness, We Sleep in May</h4>
             <h4>What’s New</h4><br>
              <ul style='text-align:left;'>
                <li>Congrats to Florida on winning their 3rd National Championship!</li>
                <li>Small changes under the hood for organization</li>
              </ul>
              <h4>What's Coming (maybe eventually)</h4>
              <ul style='text-align:left;'>
                <li>Revision of the underlying math, as well as a new method that can work with preseason data before actual stats are available</li>
                <li>Some small corrections to the distributions in the simulation charts, they should be discrete, not continuous</li>
                <li>Stats for previously played games</li>
              </ul>
              "),
             className = "landing_popup")
  
  output$sched_games <- renderUI({
    schedule_display(schedule_game_data())
  })
  
  observe({
    input$selected_date
    if(grepl("There are no scheduled games on this date.",schedule_display(schedule_game_data())[[1]], fixed = TRUE)){
      disable(id = "expected_excel_dl")
      }
    else{
      enable(id = "expected_excel_dl")
      }
  })
  
  schedule_game_data <- reactive({
    if(input$selected_date %in% c(day0,day1,day2,day3,day4)){
      dataset_for_schedule <- list(day0_data,day1_data,day2_data,day3_data,day4_data)[match(as.character(input$selected_date),c(day0,day1,day2,day3,day4))][[1]]
    }
    else{
      dataset_for_schedule <- expected_values(schedule_builder(input$selected_date))
    }
    return(dataset_for_schedule)
  })
  
  day_data_excel <- reactive({
    if(input$selected_date %in% c(day0,day1,day2,day3,day4)){
      dl_dataset <- list(day0_data_excel,day1_data_excel,day2_data_excel,day3_data_excel,day4_data_excel)[match(as.character(input$selected_date),c(day0,day1,day2,day3,day4))]
    }
    else{
      dl_dataset <- expected_excel_format(expected_values(schedule_builder(input$selected_date)))
    }
    return(dl_dataset)
  })
  
  output$expected_excel_dl <- downloadHandler(
    filename = function(){paste0(input$selected_date, ".xlsx")},
    content = function(file){
      write.xlsx(day_data_excel(), file = file, colNames=FALSE)
    }
  )
  
  
  output$imgAway <- renderUI({
    if (input$Away %in% Logos$TEAM){
      TeamLogoAway <- subset(Logos, input$Away == Logos$TEAM)
      img(src = TeamLogoAway$LOGO, height="50%", width="50%") 
    }
    else{
      img(src = "https://cdn.freebiesupply.com/logos/large/2x/ncaa-basketball-logo-png-transparent.png", height="50%", width="50%", align="center")
    }
  })
  
  output$SimimgAway <- renderUI({
    if (input$SimAway %in% Logos$TEAM){
      TeamLogoSimAway <- subset(Logos, input$SimAway == Logos$TEAM)
      img(src = TeamLogoSimAway$LOGO, height="50%", width="50%") 
    }
    else{
      img(src = "https://cdn.freebiesupply.com/logos/large/2x/ncaa-basketball-logo-png-transparent.png", height="50%", width="50%", align="center")
    }
  })
  
  output$imgHome <- renderUI({
    if (input$Home %in% Logos$TEAM){
      TeamLogoHome <- subset(Logos, input$Home == Logos$TEAM)
      img(src = TeamLogoHome$LOGO, height="50%", width="50%") 
    }
    else{
      img(src = "https://cdn.freebiesupply.com/logos/large/2x/ncaa-basketball-logo-png-transparent.png", height="50%", width="50%", align="center")
    }
  })
  
  output$SimimgHome <- renderUI({
    if (input$SimHome %in% Logos$TEAM){
      TeamLogoSimHome <- subset(Logos, input$SimHome == Logos$TEAM)
      img(src = TeamLogoSimHome$LOGO, height="50%", width="50%") 
    }
    else{
      img(src = "https://cdn.freebiesupply.com/logos/large/2x/ncaa-basketball-logo-png-transparent.png", height="50%", width="50%", align="center")
    }
  })
  
  output$Log5 <- renderPrint({
    TeamHome <- filter(master_data, TEAM == input$Home)
    TeamAway <- filter(master_data, TEAM == input$Away)
    BarthagHomeAdj <- as.numeric(1 - (1/(1+((TeamHome$ADJOE*1.01)/(TeamHome$ADJDE*0.99))^11.5)))
    BarthagAwayAdj <- as.numeric(1 - (1/(1+((TeamAway$ADJOE*0.99)/(TeamAway$ADJDE*1.01))^11.5)))
    
    
    
    if(input$vsat == "vs"){
      
      if (Log5(TeamAway$BARTHAG, TeamHome$BARTHAG) > Log5(TeamHome$BARTHAG, TeamAway$BARTHAG)){
        return(cat(paste0(input$Away, " is the favourite and has an approximately ", round(Log5(TeamAway$BARTHAG, TeamHome$BARTHAG)*100,2), "% chance to beat ", input$Home, ".")))
      }
      else if (Log5(TeamHome$BARTHAG, TeamAway$BARTHAG) > Log5(TeamAway$BARTHAG, TeamHome$BARTHAG)){
        return(cat(paste0(input$Home, " is the favourite and has an approximately ", round(Log5(TeamHome$BARTHAG, TeamAway$BARTHAG)*100,2), "% chance to beat ", input$Away, ".")))
      }
      else if (Log5(TeamHome$BARTHAG, TeamAway$BARTHAG) == Log5(TeamAway$BARTHAG, TeamHome$BARTHAG)){
        return(cat(paste0(input$Home, " and ", input$Away, " have an equal probability of beating each other.")))
      }
      else{
        return(cat(paste0("There was an error, please report this")))
      }
    }
    
    else if (input$vsat == "at"){
      if (Log5(BarthagAwayAdj, BarthagHomeAdj) > Log5(BarthagHomeAdj, BarthagAwayAdj)){
        return(cat(paste0(input$Away, " is the favourite and has an approximately ", round(Log5(BarthagAwayAdj, BarthagHomeAdj)*100,2), "% chance to beat ", input$Home, ".")))
      }
      else if (Log5(BarthagHomeAdj, BarthagAwayAdj) > Log5(BarthagAwayAdj, BarthagHomeAdj)){
        return(cat(paste0(input$Home, " is the favourite and has an approximately ", round(Log5(BarthagHomeAdj, BarthagAwayAdj)*100,2), "% chance to beat ", input$Away, ".")))
      }
      else if (Log5(BarthagHomeAdj, BarthagAwayAdj) == Log5(BarthagAwayAdj, BarthagHomeAdj)){
        return(cat(paste0(input$Home, " and ", input$Away, " have an equal probability of beating each other.")))
      }
      else{
        return(cat(paste0("There was an error, please report this")))
      }
    }
    
    else{
      return(cat(paste0("There was an error, please report this")))
    }
    
  })
  
  output$TeamAwayScore <- renderPrint({
    TeamAway <- filter(master_data, TEAM == input$Away)
    TeamHome <- filter(master_data, TEAM == input$Home)
    if(input$vsat == "vs"){
      return(cat(paste0(round(GameScoreVS(TeamAway,TeamHome,NCAA),2))))
    }
    else if (input$vsat =="at"){
      return(cat(paste0(round(GameScoreAtAwayTeam(TeamHome,TeamAway,NCAA),2))))
    }
    else{
      return(cat(paste0("There was an error, please report this")))
    }
  })
  
  output$Dash <- renderText({"-"
  })
  
  output$TeamHomeScore <- renderPrint({
    TeamAway <- filter(master_data, TEAM == input$Away)
    TeamHome <- filter(master_data, TEAM == input$Home)
    if(input$vsat == "vs"){
      return(cat(paste0(round(GameScoreVS(TeamHome,TeamAway,NCAA),2))))
    }
    else if (input$vsat =="at"){
      return(cat(paste0(round(GameScoreAtHomeTeam(TeamHome,TeamAway,NCAA),2))))
    }
    else{
      return(cat(paste0("There was an error, please report this")))
    }
  })
  
  output$NormCurves <- renderPlot({
    
    TeamHome <- filter(master_data, TEAM == input$SimHome)
    TeamAway <- filter(master_data, TEAM == input$SimAway)
    #Expected number of possessions
    EHomePoss <- (as.numeric(TeamHome$`FGA/G`)*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamHome$ADJ_T
    EAwayPoss <- (as.numeric(TeamAway$`FGA/G`)*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamAway$ADJ_T
    #Expected effective field goal percentage
    EHomeEFG <- ((TeamHome$EFG_O/NCAA$EFG_O)*(TeamAway$EFG_D/NCAA$EFG_D)*TeamHome$EFG_O)/100
    EAwayEFG <- ((TeamAway$EFG_O/NCAA$EFG_O)*(TeamHome$EFG_D/NCAA$EFG_D)*TeamAway$EFG_O)/100
    #Standard deviation of expected points scored against opponent
    HomeSD <- sqrt(EHomePoss*EHomeEFG*(1-EHomeEFG))*2
    AwaySD <- sqrt(EAwayPoss*EAwayEFG*(1-EAwayEFG))*2
    
    if(input$Simvsat == "vs"){
      #Expected (mean) scores
      EHomeScore <- GameScoreVS(TeamHome, TeamAway, NCAA)
      EAwayScore <- GameScoreVS(TeamAway, TeamHome, NCAA)
      
      NormPlot <- ggplot(data.frame(x = c(40, 120)), aes(x)) + 
        stat_function(fun = dnorm, args = list(mean = EHomeScore, sd = HomeSD),
                      aes(colour=paste0(input$SimHome))) +
        stat_function(fun = dnorm, args = list(mean = EAwayScore, sd = AwaySD),
                      aes(colour=paste0(input$SimAway))) +
        labs(x = "Points", y = "Probability") +
        theme(legend.position = "bottom") +
        scale_x_continuous(breaks = seq(40, 120, by = 10)) +
        scale_colour_manual("", values = c("blue", "red"))
      
      return(NormPlot)
      
    }
    
    else if (input$Simvsat == "at"){
      #Expected (mean) scores
      EHomeScore <- GameScoreAtHomeTeam(TeamHome, TeamAway, NCAA)
      EAwayScore <- GameScoreAtAwayTeam(TeamHome, TeamAway, NCAA)
      
      NormPlot <- ggplot(data.frame(x = c(40, 120)), aes(x)) + 
        stat_function(fun = dnorm, args = list(mean = EHomeScore, sd = HomeSD),
                      aes(colour=paste0(input$SimHome))) +
        stat_function(fun = dnorm, args = list(mean = EAwayScore, sd = AwaySD),
                      aes(colour=paste0(input$SimAway))) +
        labs(x = "Points", y = "Probability") +
        theme(legend.position = "bottom") +
        scale_x_continuous(breaks = seq(40, 120, by = 10)) +
        scale_colour_manual("", values = c("blue", "red"))
      
      return(NormPlot)
      
    }
    
    else{
      return(cat(paste0("There was an error, please report this")))
    }
    
  })
  
  output$Probs <- renderPrint({
    TeamHome <- filter(master_data, TEAM == input$SimHome)
    TeamAway <- filter(master_data, TEAM == input$SimAway)
    #Expected number of possessions
    EHomePoss <- (as.numeric(TeamHome$`FGA/G`)*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamHome$ADJ_T
    EAwayPoss <- (as.numeric(TeamAway$`FGA/G`)*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamAway$ADJ_T
    #Expected effective field goal percentage
    EHomeEFG <- ((TeamHome$EFG_O/NCAA$EFG_O)*(TeamAway$EFG_D/NCAA$EFG_D)*TeamHome$EFG_O)/100
    EAwayEFG <- ((TeamAway$EFG_O/NCAA$EFG_O)*(TeamHome$EFG_D/NCAA$EFG_D)*TeamAway$EFG_O)/100
    #Standard deviation of expected points scored against opponent
    HomeSD <- sqrt(EHomePoss*EHomeEFG*(1-EHomeEFG))*2
    AwaySD <- sqrt(EAwayPoss*EAwayEFG*(1-EAwayEFG))*2
    
    if(input$Simvsat == "vs"){
      #Expected (mean) scores
      EHomeScore <- GameScoreVS(TeamHome, TeamAway, NCAA)
      EAwayScore <- GameScoreVS(TeamAway, TeamHome, NCAA)
      
      if(EHomeScore > EAwayScore){
        z <- (EHomeScore - EAwayScore)/(sqrt(HomeSD^2 + AwaySD^2))
        z <- pnorm(z)
        return(cat(paste0(input$SimHome, " is expected to win ", round(z*100,2), "% of some X-number of games played against ", input$SimAway)))
      }
      else if (EAwayScore > EHomeScore){
        z <- (EAwayScore - EHomeScore)/(sqrt(HomeSD^2 + AwaySD^2))
        z <- pnorm(z)
        return(cat(paste0(input$SimAway, " is expected to win ", round(z*100,2), "% of some X-number of games played against ", input$SimHome)))
      }
      else if (EHomeScore == EAwayScore){
        return(cat(paste0(input$SimHome, " and ", input$SimAway, " are expected to win an equal number of times in some X-number of games")))
      }
      else{
        return(cat("There was an error, please report this"))
      }
      
    }
    
    else if (input$Simvsat == "at"){
      #Expected (mean) scores
      EHomeScore <- GameScoreAtHomeTeam(TeamHome, TeamAway, NCAA)
      EAwayScore <- GameScoreAtAwayTeam(TeamHome, TeamAway, NCAA)
      
      if(EHomeScore > EAwayScore){
        z <- (EHomeScore - EAwayScore)/(sqrt(HomeSD^2 + AwaySD^2))
        z <- pnorm(z)
        return(cat(paste0(input$SimHome, " is expected to win ", round(z*100,2), "% of some X-number of games played against ", input$SimAway)))
      }
      else if (EAwayScore > EHomeScore){
        z <- (EAwayScore - EHomeScore)/(sqrt(HomeSD^2 + AwaySD^2))
        z <- pnorm(z)
        return(cat(paste0(input$SimAway, " is expected to win ", round(z*100,2), "% of some X-number of games played against ", input$SimHome)))
      }
      else if (EHomeScore == EAwayScore){
        return(cat(paste0(input$SimHome, " and ", input$SimAway, " are expected to win an equal number of times in some X-number of games")))
      }
      else{
        return(cat(paste0("There was an error, please report this")))
      }
    }
    
    else{
      return(cat(paste0("There was an error, please report this")))
    }
    
  })
  
  Sim <- eventReactive(input$SimButton, {
    TeamHome <- filter(master_data, TEAM == input$SimHome)
    TeamAway <- filter(master_data, TEAM == input$SimAway)
    #Expected number of possessions
    EHomePoss <- (as.numeric(TeamHome$`FGA/G`)*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamHome$ADJ_T
    EAwayPoss <- (as.numeric(TeamAway$`FGA/G`)*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamAway$ADJ_T
    #Expected effective field goal percentage
    EHomeEFG <- ((TeamHome$EFG_O/NCAA$EFG_O)*(TeamAway$EFG_D/NCAA$EFG_D)*TeamHome$EFG_O)/100
    EAwayEFG <- ((TeamAway$EFG_O/NCAA$EFG_O)*(TeamHome$EFG_D/NCAA$EFG_D)*TeamAway$EFG_O)/100
    #Standard deviation of expected points scored against opponent
    HomeSD <- sqrt(EHomePoss*EHomeEFG*(1-EHomeEFG))*2
    AwaySD <- sqrt(EAwayPoss*EAwayEFG*(1-EAwayEFG))*2
    
    if(input$Simvsat == "vs"){
      #Expected (mean) scores
      EHomeScore <- GameScoreVS(TeamHome, TeamAway, NCAA)
      EAwayScore <- GameScoreVS(TeamAway, TeamHome, NCAA)
      
      HomeSimScore <- rnorm(1, EHomeScore, HomeSD)
      AwaySimScore <- rnorm(1, EAwayScore, AwaySD)
      
      ScoreList <- list(HomeSimScore=HomeSimScore, AwaySimScore=AwaySimScore)
      
      return(ScoreList)
    }
    else if (input$Simvsat == "at"){
      #Expected (mean) scores
      EHomeScore <- GameScoreAtHomeTeam(TeamHome, TeamAway, NCAA)
      EAwayScore <- GameScoreAtAwayTeam(TeamHome, TeamAway, NCAA)
      
      HomeSimScore <- rnorm(1, EHomeScore, HomeSD)
      AwaySimScore <- rnorm(1, EAwayScore, AwaySD)
      
      ScoreList <- list(HomeSimScore=HomeSimScore, AwaySimScore=AwaySimScore)
      
      return(ScoreList)
    }
    
    else{
      ScoreList <- list(HomeSimScore="There was an error, please report this", AwaySimScore="There was an error, please report this")
    }
    
  })
  
  output$SimScore <- renderPrint({
    TeamHome <- filter(master_data, TEAM == input$SimHome)
    TeamAway <- filter(master_data, TEAM == input$SimAway)
    #Expected number of possessions
    EHomePoss <- (as.numeric(TeamHome$`FGA/G`)*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamHome$ADJ_T
    EAwayPoss <- (as.numeric(TeamAway$`FGA/G`)*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamAway$ADJ_T
    #Expected effective field goal percentage
    EHomeEFG <- ((TeamHome$EFG_O/NCAA$EFG_O)*(TeamAway$EFG_D/NCAA$EFG_D)*TeamHome$EFG_O)/100
    EAwayEFG <- ((TeamAway$EFG_O/NCAA$EFG_O)*(TeamHome$EFG_D/NCAA$EFG_D)*TeamAway$EFG_O)/100
    #Standard deviation of expected points scored against opponent
    HomeSD <- sqrt(EHomePoss*EHomeEFG*(1-EHomeEFG))*2
    AwaySD <- sqrt(EAwayPoss*EAwayEFG*(1-EAwayEFG))*2
    Combined <- Sim()
    AScore <- round(Combined$AwaySimScore)
    HScore <- round(Combined$HomeSimScore)
    if(input$Simvsat == "vs" | input$Simvsat == "at"){
      if(AScore != HScore){
        return(cat(paste0(input$SimAway, "  ", AScore, "         -         ", HScore, "  ", input$SimHome)))
      }
      #Account for OT in tie
      else if(AScore == HScore){
        i = 0
        while (AScore == HScore) {
          if(input$Simvsat == "vs"){
            AScore <- AScore + round(rnorm(1,GameScoreVS(TeamAway, TeamHome, NCAA),AwaySD)/8)
            HScore <- HScore + round(rnorm(1,GameScoreVS(TeamHome, TeamAway, NCAA),HomeSD)/8)
          }
          else if(input$Simvsat == "at"){
            AScore <- AScore + round(rnorm(1,GameScoreAtAwayTeam(TeamHome, TeamAway, NCAA),AwaySD)/8)
            HScore <- HScore + round(rnorm(1,GameScoreAtHomeTeam(TeamHome, TeamAway, NCAA),HomeSD)/8)
          }
          i=i+1
        }
        assign("NumOTs", i, envir=globalenv())
        return(cat(paste0(input$SimAway, "  ", AScore, "         -         ", HScore, "  ", input$SimHome)))
      }
    }
    else{
      return(cat("There was an error, please report this"))
    }
    
  })
  
  output$RegOT <- renderText({
    Combined <- Sim()
    AScore <- round(Combined$AwaySimScore)
    HScore <- round(Combined$HomeSimScore)
    if(AScore != HScore){
      return("Final Score in Regulation")
    }
    else if(AScore == HScore){
      
      i <- as.integer(NumOTs)
      if(i == 1){
        return(paste0("Final Score in Single Overtime"))
      }
      else if(i == 2){
        return(paste0("Final Score in Double Overtime"))
      }
      else if(i == 3){
        return(paste0("Final Score in Triple Overtime"))
      }
      else if(i == 4){
        return(paste0("Final Score in Quadruple Overtime"))
      }
      else if(i == 5){
        return(paste0("Final Score in Quintuple Overtime"))
      }
      else if(i == 6){
        return(paste0("Final Score in Sextuple Overtime"))
      }
      else if(i == 7){
        return(paste0("Final Score in Septuple Overtime"))
      }
      else if(i == 8){
        return(paste0("Final Score in Octuple Overtime"))
      }
      else if(i == 9){
        return(paste0("Final Score in Nonuple Overtime"))
      }
      else if(i == 10){
        return(paste0("Final Score in Decuple Overtime"))
      }
      else{
        return("There was an error, please report this")
      }
    }
    else{
      return("There was an error, please report this")
    }
  })
  
}

shinyApp(ui, server)




