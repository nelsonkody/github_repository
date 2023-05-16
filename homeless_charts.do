cd "/Users/Kody/Desktop/Adv_Econometrics/research/data"

clear 
use master_file2

collapse (mean) natavg_vc=vac_rate (rawsum) nat_beds=beds nat_hpop=homeless, by(year)

//Connected line graph shoing national homelessness and vacancy rates over time
twoway connected nat_hpop year, yaxis(1)|| connected natavg_vc year, yaxis(2)
twoway connected nat_beds year
save nat_data, replace
//Outlier in hpop for 2021, Covid relatated data inconsistincy, drop 2021
drop if year == 2021
save nat_data_2021drop, replace

//re-visualize
clear 
use nat_data_2021drop
twoway connected nat_hpop year, yaxis(1)|| connected natavg_vc year, yaxis(2)

///
//estout series

clear
use master_drop21

//store fixed effects^2
eststo: quietly xtreg lhomeless c.vac_rate  c.vac_rate##c.vac_rate lpop unemp beds, fe

//store Fixed Effects
eststo: quietly xtreg lhomeless vac_rate lpop unemp beds, fe

//store OLS
eststo: quietly regress lhomeless vac_rate lpop unemp beds

clear
use master_file2

// store FE^2 with 21
eststo: quietly xtreg lhomeless c.vac_rate  c.vac_rate##c.vac_rate lpop unemp beds, fe


//store OLS with21
eststo: quietly regress lhomeless vac_rate lpop unemp beds


//table of regression results to choose best model
esttab est1 est2 est3 est4 est5 using "/Users/Kody/Desktop/Adv_Econometrics/research", ar2 label replace





//summary statistics

summarize homeless vac_rate unemp beds 


