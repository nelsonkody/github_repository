#Kody Nelson
#Quiz 2

library(stargazer)
library(fpp3)

load(file="ecns513-data07-investment-02to22qns.RData")

autoplot(investment.data)

investment.train <- filter_index(investment.data, .~"2020 Q4")
investment.test <- filter_index(investment.data, "2021 Q1" ~.)

fit <- investment.train  %>% model(ETS(invest))

report(fit)
#MAM'

model1 <-  investment.train %>% model(ETS(invest ~ error("M") + trend("A") +
                                            season("M")))

forecast.train <- forecast (model1, h= 8)
autoplot(forecast.train, level = 80) + autolayer(investment.test, invest) +
  labs(y = "Investment in Billions of 2012 dollars", x = "Quarter",
       title = "Test Forecast for Investment")


logfit <- investment.train  %>% model(ETS(log(invest)))
report(logfit)

model1log <-  investment.train %>% model(ETS(invest ~ error("M") + trend("N") +
                                            season("M")))

forecast.train.log <- forecast (model1, h= 8)

autoplot(forecast.train.log, level = 80) + autolayer(investment.test, invest) +
  labs(y = "Log Investment in Billions of 2012 dollars", x = "Quarter",
       title = "Test Forecast for Investment Using Log of Invesetment")

fit.decomp <- investment.train%>%
  model(decomposition_model(
    STL(invest~trend(window = 7)+ season(window= Inf)),  #decompose series
    RW (season_adjust~drift()),                       #model deseas.data and fore
    SNAIVE(season_year)                              #re-seasonalize
  ))

forecast.decomp <- fit.decomp %>% forecast(h=8)

fit.decomp %>% forecast(h=8)%>% autoplot(level = 80, investment.test)+
  labs(y ="Investment in Billions of 2012 dollars", x = "Quarter",
       title = "Test Forecast for Investment Using Decomp Method")

accuracy(forecast.train, investment.test)
accuracy(forecast.train.log, investment.test)
accuracy(forecast.decomp, investment.test)

autoplot(forecast.train, level = NULL, color = "red") + autolayer(forecast.train.log, level = NULL, color="blue") +
  autolayer(forecast.decomp, level = NULL, color= "green") + autolayer(investment.test, invest, color = "black")+
  labs(y ="Investment in Billions of 2012 dollars", x = "Quarter",
       title = "Test Forecast for Investment with Various Methods(colors)")

investment.test.table <- full_join(investment.test, forecast.train, by="quarter") %>%
  select(-.model, -invest.y)%>% 
  rename(invest = invest.x, MAMForecast = .mean)

investment.test.table1 <- full_join(investment.test.table, forecast.train.log, by="quarter") %>%
  select(c(-.model, -invest.y)) %>%
  rename(MNMForecast = .mean, invest = invest.x)

investment.test.table2 <- full_join(investment.test.table, forecast.decomp, by="quarter") %>%
  select(c(-.model, -invest.y)) %>%
  rename(MNMForecast = .mean, invest = invest.x)

investment.table.final <- investment.test.table2

stargazer(as.data.frame(investment.table.final), summary =FALSE, type = "text",
          digits =1)

model.final <- investment.data %>% model(ETS(invest ~ error("M") + trend("A") +
                                            season("M")))

forecast.final <- forecast (model.final, h= 8)

investment.zoom <- filter_index (investment.data, "2020 Q1" ~.)

autoplot(forecast.final, level = 80, color = "blue") +
  autolayer(investment.zoom, invest) + 
  labs(y ="Investment in Billions of 2012 dollars", x = "Quarter",
  title = "Forecast for Investment Using MAM Model")

