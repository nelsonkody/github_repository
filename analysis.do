cd "/Users/Kody/Desktop/Adv_Econometrics/research/data"

clear

use master_file2

xtset state_code year

xtreg lhomeless vac_rate lpop unemp beds, fe

save master_file, replace

//Scatter graph visualising vac_rate's exponential relationship on homelessness

 scatter lhomeless vac_rate if State == "NY" || qfit lhomeless vac_rate if State == "NY"


generate vac_ratesq = vac_rate^2

twoway scatter lhomeless vac_rate, if year==2008

xtset state_code year

xtreg lhomeless c.vac_rate  c.vac_rate##c.vac_rate lpop unemp beds, fe


//margins plot showing relationship of vaccancy rates on homeless populations
//for every percent change 0-15

margins, dydx(vac_rate) at(vac_rate = (0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15))

marginsplot

summarize homeless vac_rate unemp beds

ssc install estout


xtreg lhomeless c.vac_rate  c.vac_rate##c.vac_rate lpop unemp beds, fe

estimates store m1, title(Fixed Effects)

estout m1, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant)  /// 
 stats (r2 df_r)
 
esttab using "/Users/Kody/Desktop/Adv_Econometrics/research"

///2021 observation need to be dropped!

clear

use master_file2

drop if year == 2021

label variable unemp "Unemployment"

label variable population "Population"

label variable vac_rate "Vaccancy Rate"

label variable homeless "Homeless Count"

label variable lhomeless "Log of Homeless Count"

label variable beds "Shelter Beds"

save master_drop21, replace

//analysis

clear
use master_drop21

xtset state_code year

xtreg lhomeless c.vac_rate  c.vac_rate##c.vac_rate lpop unemp beds, fe

estimates store m1, title(Fixed Effects) 

margins, dydx(vac_rate) at(vac_rate = (0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15))

marginsplot

summarize homeless vac_rate unemp beds

/*
The findings from this graph suggest a strong effect of vacancy rates on homelessness at the lower limit moving towards 6%. A change in vacancy rate from 1%-2% is associated with 3.08 percentage point decrease in regional homeless populations, all else constant. Alternatively, moving away from the breakeven point towards complete market saturation (0%) can increase homeless populations by 12.38%, all else constant.

*/


