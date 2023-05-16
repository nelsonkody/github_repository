#Kody Nelson
#Forecasting Yellowstone Visitation

library(fpp3)
library(imputeTS)
library(stargazer)

ys.data <- read.csv("ecns513-finaldata-yellowstone.csv")

# create ts object and set index to month
ys.ts <- as_tsibble(mutate(month = yearmonth(date),
                           ys.data), index = month)

#sesonally adjusted imputations for missing values 4/1/2020 and 5/1/2020
ys.ts.i <- na_seasplit(ys.ts)


#Visualizes visitation over time series
autoplot(ys.ts.i, yellowstone, color = "darkblue")+labs(title = "Yellowstone Visitation",
                                    y = "Monthly Visitors in Thousands",
                                    x = "Month")

#Visualizes visitation per month over time
gg_subseries(ys.ts.i, yellowstone)+
  labs(title = "Yellowstone Visitation by Month",
       x= "Month", y ="Visitation in Thousands")


#Predicting model for full data set
model1 <- ys.ts.i %>% model(ARIMA(yellowstone))
report(model1)

#Setting training and test set for model testing
ys.train <- filter_index(ys.ts.i, .~ "2021 Dec")
ys.test <- filter_index(ys.ts.i, "2022 Jan" ~.)

#model building
fit.ets <- ys.train %>% model(ETS(yellowstone))
fit.ets.logs <- ys.train %>% model(ETS(log(yellowstone)))
fit.arima <- ys.train %>% model(ARIMA(yellowstone))
fit.arima.logs <- ys.train %>% model(ARIMA(log(yellowstone)))

#accuracy of the four previous models
report(fit.ets)
report(fit.ets.logs)
report(fit.arima)
report(fit.arima.logs)

#accuracy of forecasts on test set
accuracy(forecast(fit.ets, h=12), ys.ts.i)
accuracy(forecast(fit.ets.logs, h=12), ys.ts.i)
accuracy(forecast(fit.arima, h=12), ys.ts.i)
accuracy(forecast(fit.arima.logs, h=12), ys.ts.i)

#arima model found to be most accurate
gg_tsresiduals(fit.arima.logs)
augment(fit.arima.logs)%>%PACF(.innov)%>% autoplot()+labs(title="PACF")

#Ljung - Box test
augment(fit.arima.logs) %>% features(.innov, ljung_box, lag = 10, dof = 2)

#averages fits of the two best models
combo.model <- ys.train%>%
  model(larima=ARIMA(log(yellowstone)),
        arima=ARIMA(yellowstone))%>%
  mutate(combination = (larima+arima)/2)

accuracy(forecast(combo.model, h=12), ys.ts.i)

#table for comparing model accuracy
rmse.table <- data.frame (
  Model = c("ETS", "L-ETS", "ARIMA", "L-ARIMA", "COMBO"),
  RMSE = c("476", "386", "195", "269", "231")
)
rmse.table

#generating forecast objects for each model
forecast.ets<- forecast(fit.ets, h=12)
forecast.lets <- forecast(fit.ets.logs, h=12)
forecast.arima <- forecast(fit.arima, h=12)
forecast.larima<- forecast(fit.arima.logs, h=12)
forecast.combo <- forecast(combo.model, h=12)

#generate filter for clearer graph
ys.zoom <- filter_index(ys.ts.i, "2018 Jan" ~ "2021 Dec")

#Plot of forecasts
autoplot(ys.zoom, yellowstone, color= "black")+
  autolayer(forecast.ets, color = "green", level = NULL)+
  autolayer(forecast.lets, color = "blue", level = NULL)+
  autolayer(forecast.arima, color = "red", level = NULL)+
  autolayer(forecast.larima, color = "orange", level = NULL)+
  autolayer(forecast.combo, color = "pink", level = NULL)+
  labs(y = "Visitation in Thousands", x = "Year", title = "Test Forecasts")

#Plot of Forecasts against test set data
autoplot(ys.test, yellowstone, color= "black")+
  autolayer(forecast.ets, color = "green", level = NULL)+
  autolayer(forecast.lets, color = "blue", level = NULL)+
  autolayer(forecast.arima, color = "red", level = NULL)+
  autolayer(forecast.larima, color = "orange", level = NULL)+
  autolayer(forecast.combo, color = "pink", level = NULL)+
  labs(y = "Visitation in Thousands", x = "Year", title = "Test Forecasts")

#Generate models for full data set
full.ys.ets<- ys.ts.i %>% model(ETS(yellowstone))
full.ys.lets <- ys.ts.i %>% model(ETS(log(yellowstone)))
full.ys.arima <- ys.ts.i %>% model(ARIMA(yellowstone))
full.ys.larima <- ys.ts.i %>% model(ARIMA(log(yellowstone)))
full.ys.combo <- ys.ts.i%>%
  model(larima=ARIMA(log(yellowstone)),
        arima=ARIMA(yellowstone))%>%
  mutate(combination = (larima+arima)/2)

#Generate forecasts for future
full.fc.ets <- forecast(full.ys.ets, h = 12)
full.fc.lets <- forecast(full.ys.lets, h =12)
full.fc.arima <- forecast(full.ys.arima, h = 12)
full.fc.larima <- forecast(full.ys.larima, h =12)
full.fc.combo <- forecast(full.ys.combo, h =12)

#Plot of Forecasts into the future
autoplot(full.fc.larima, color= "orange", level= NULL)+
  autolayer(full.fc.ets, color = "green", level = NULL)+
  autolayer(full.fc.lets, color = "blue", level = NULL)+
  autolayer(full.fc.arima, color = "red", level = NULL)+
  autolayer(full.fc.combo, color = "pink", level = NULL)+
  labs(y = "Visitation in Thousands", x = "Year", 
       title = "Future Forecasts")

#Generate simulations for combo model
set.seed(1234)

combo.fc.futures <- full.ys.combo%>%
  generate(h=12, times=1000)%>%
  as_tibble()%>%
  group_by(month, .model)%>%
  summarize(dist=distributional::dist_sample(list(.sim)),
            groups="keep")%>%
  ungroup()%>%
  as_fable(index=month, key = .model, distribution = dist,
           response = "Visitation")

#Plot simulations
autoplot(combo.fc.futures, level = 80)+
  labs(title = "Combination Model Forecast", x = "Month", 
       y = "Visitation in Thousands")

#Plot of choice model
combo.fc.futures %>% filter(.model=="combination")%>%
  autoplot(level=80)+
  autolayer(ys.zoom, yellowstone, color= "black")

#Forecast Table
table.fc <- combo.fc.futures %>% filter(.model == "combination")%>%
  mutate(means = mean(dist), 
         pi80 = hilo(dist, 80))%>%
  unpack_hilo(c("pi80"))
table.fc
table.fc.df <- as.data.frame(table.fc)
stargazer(table.fc.df[,c("month", "means", "pi80_lower", "pi80_upper")],
          summary= FALSE, type = "text", digits = 1,
          digit.separator = "",
          covariate.labels = c("h", "Month", "Fcast", "80 low",
                               "80 high"))

#Returns 2023 annual visitation
sum(table.fc$means)
#Testing with previous data
sum(ys.zoom$yellowstone) / 4

#Finding sums of prediciton intervals
sum(table.fc$pi80_lower)
sum(table.fc$pi80_upper)











