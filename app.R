#Author: Devan Scholefield
source("Script.R")
library(shiny)
library(shinydashboard)
#library(shinydashboardPlus)

ui <- dashboardPage(
    dashboardHeader(title = "NCAA Basketball Matchup Stats", titleWidth = 500),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Matchup Utility", tabName = "dashboard", icon = icon("dashboard")),
            menuItem("Methodology", tabName= "methodology", icon=icon("calculator")),
            menuItem("Simulation", tabName = "simulation", icon = icon("server"))
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "dashboard",
                    fluidRow(
                        column(5,
                               selectInput(
                                   inputId = "Away",
                                   label = h3("Away Team"),
                                   choices = c(NCAA$TEAM, sort(unique(BT2021Data$TEAM)))),
                               align="center"),
                        column (2, h3("")),
                        column(5,
                               selectInput(
                                   inputId = "Home",
                                   label = h3("Home Team"),
                                   choices = c(NCAA$TEAM, sort(unique(BT2021Data$TEAM)))
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
            tabItem(tabName = "methodology",
                    withMathJax(includeMarkdown("Methodology.Rmd"))
            ),
            tabItem(tabName ="simulation",
                    fluidRow(
                        column(5,
                               selectInput(
                                   inputId = "SimAway",
                                   label = h3("Away Team"),
                                   choices = c(NCAA$TEAM, sort(unique(BT2021Data$TEAM)))),
                               align="center"),
                        column (2, h3("")),
                        column(5,
                               selectInput(
                                   inputId = "SimHome",
                                   label = h3("Home Team"),
                                   choices = c(NCAA$TEAM, sort(unique(BT2021Data$TEAM)))
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
                    
            )
        )
    )
)

server <- function(input, output) {
    
    FGAPG <- TeamRankingsStatPull("FGA/G")
    NCAAFGA <- FGAPG %>% summarise_if(is.numeric, mean)
    NCAAFGA <- mutate(NCAAFGA, "Team" = "NCAA")
    NCAAFGA <- relocate(NCAAFGA, Team)
    FGAPG <- rbind(FGAPG, NCAAFGA)
    NCAABT2021Data <- rbind(BT2021Data, NCAA)
    
    output$imgAway <- renderUI({
        if (input$Away %in% Logos$TEAM){
            TeamLogoAway <- subset(Logos, input$Away == Logos$TEAM)
            img(src = TeamLogoAway$LOGO, height="50%", width="50%") 
        }
        else{
            img(src = "https://cdn.freebiesupply.com/logos/large/2x/ncaa-basketball-logo-png-transparent.png", height="50%", width="50%", align="left")
        }
    })
    
    output$SimimgAway <- renderUI({
        if (input$SimAway %in% Logos$TEAM){
            TeamLogoSimAway <- subset(Logos, input$SimAway == Logos$TEAM)
            img(src = TeamLogoSimAway$LOGO, height="50%", width="50%") 
        }
        else{
            img(src = "https://cdn.freebiesupply.com/logos/large/2x/ncaa-basketball-logo-png-transparent.png", height="50%", width="50%", align="left")
        }
    })
    
    output$imgHome <- renderUI({
        if (input$Home %in% Logos$TEAM){
            TeamLogoHome <- subset(Logos, input$Home == Logos$TEAM)
            img(src = TeamLogoHome$LOGO, height="50%", width="50%") 
        }
        else{
            img(src = "https://cdn.freebiesupply.com/logos/large/2x/ncaa-basketball-logo-png-transparent.png", height="50%", width="50%", align="right")
        }
    })
    
    output$SimimgHome <- renderUI({
        if (input$SimHome %in% Logos$TEAM){
            TeamLogoSimHome <- subset(Logos, input$SimHome == Logos$TEAM)
            img(src = TeamLogoSimHome$LOGO, height="50%", width="50%") 
        }
        else{
            img(src = "https://cdn.freebiesupply.com/logos/large/2x/ncaa-basketball-logo-png-transparent.png", height="50%", width="50%", align="right")
        }
    })
    
    output$Log5 <- renderPrint({
        NCAABT2021Data <- rbind(BT2021Data, NCAA)
        TeamHome <- filter(NCAABT2021Data, TEAM == input$Home)
        TeamAway <- filter(NCAABT2021Data, TEAM == input$Away)
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
        NCAABT2021Data <- rbind(BT2021Data, NCAA)
        TeamAway <- filter(NCAABT2021Data, TEAM == input$Away)
        TeamHome <- filter(NCAABT2021Data, TEAM == input$Home)
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
        NCAABT2021Data <- rbind(BT2021Data, NCAA)
        TeamAway <- filter(NCAABT2021Data, TEAM == input$Away)
        TeamHome <- filter(NCAABT2021Data, TEAM == input$Home)
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
        
        TeamHome <- filter(NCAABT2021Data, TEAM == input$SimHome)
        TeamAway <- filter(NCAABT2021Data, TEAM == input$SimAway)
        TeamHomeFGAPG <- filter(FGAPG, Team == input$SimHome)
        TeamAwayFGAPG <- filter(FGAPG, Team == input$SimAway)
        #Expected number of possessions
        EHomePoss <- (TeamHomeFGAPG$`2020`*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamHome$ADJ_T
        EAwayPoss <- (TeamAwayFGAPG$`2020`*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamAway$ADJ_T
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
        TeamHome <- filter(NCAABT2021Data, TEAM == input$SimHome)
        TeamAway <- filter(NCAABT2021Data, TEAM == input$SimAway)
        TeamHomeFGAPG <- filter(FGAPG, Team == input$SimHome)
        TeamAwayFGAPG <- filter(FGAPG, Team == input$SimAway)
        #Expected number of possessions
        EHomePoss <- (TeamHomeFGAPG$`2020`*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamHome$ADJ_T
        EAwayPoss <- (TeamAwayFGAPG$`2020`*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamAway$ADJ_T
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
        TeamHome <- filter(NCAABT2021Data, TEAM == input$SimHome)
        TeamAway <- filter(NCAABT2021Data, TEAM == input$SimAway)
        TeamHomeFGAPG <- filter(FGAPG, Team == input$SimHome)
        TeamAwayFGAPG <- filter(FGAPG, Team == input$SimAway)
        #Expected number of possessions
        EHomePoss <- (TeamHomeFGAPG$`2020`*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamHome$ADJ_T
        EAwayPoss <- (TeamAwayFGAPG$`2020`*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamAway$ADJ_T
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
        TeamHome <- filter(NCAABT2021Data, TEAM == input$SimHome)
        TeamAway <- filter(NCAABT2021Data, TEAM == input$SimAway)
        TeamHomeFGAPG <- filter(FGAPG, Team == input$SimHome)
        TeamAwayFGAPG <- filter(FGAPG, Team == input$SimAway)
        #Expected number of possessions
        EHomePoss <- (TeamHomeFGAPG$`2020`*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamHome$ADJ_T
        EAwayPoss <- (TeamAwayFGAPG$`2020`*(ExpTempo(TeamHome, TeamAway, NCAA)))/TeamAway$ADJ_T
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




