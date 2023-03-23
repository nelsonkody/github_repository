//Lab_4

clear

cd "/Users/Kody/Desktop/Adv_Econometrics/Lab_4"

import delimited world_health, varnames(1)


replace seriescode = "malechildmort"  if seriescode == "SH.DYN.MORT.MA"

replace seriescode = "pop"  if seriescode == "SP.POP.TOTL"

replace seriescode = "gdp" if seriescode == "NY.GDP.MKTP.CD"

replace seriescode = "healthexppc" if seriescode == "SH.XPD.CHEX.PC.CD"

replace seriescode = "sani"  if seriescode == "SH.STA.BASS.ZS"

replace seriescode = "docsper1000"  if seriescode == "SH.MED.PHYS.ZS"


replace yr2010 = "" if yr2010 == ".."

destring yr2010, replace

drop seriesname
drop if countrycode == ""


reshape wide yr2010, i(countryname) j(seriescode) string

rename yr2010* *

drop v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16

generate gdppc = gdp / pop
label variable gdppc "GDP per Capita"

generate healthexppergdp = (healthexppc / gdppc) * 100
label variable healthexppergdp "Health Expenditure as a percentafe of GDP"

regress malechildmort gdppc healthexppergdp sani docsper1000
// 4i Sanitation, doctors per 1000, gdp are all negative but health expediture are positive, which is unexpected.

corr
//4j population and gdp are correlated, sanitazation rates and doctors per 1000, gdp per cap and sanitazion, 
