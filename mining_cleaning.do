clear

cd "/Users/Kody/Desktop/Adv_Econometrics/research"

//Research Question: Are decreasing vaccacny rates corelated with increasing homeless popultaions?


//importing unemployment data to clean
import delimited state_unemployment.csv
 
 //Dropping unwanted variables
drop totalcivilianlaborforceinstatear percentofstateareaspopulation totalemploy
mentinstatearea percentoflaborforceemployedinsta totalunemploymentinstatearea

drop fipscode

//renaming varibles to something more succinct
rename totalciviliannoninstitutionalpop population

rename percentoflaborforceunemployedins unemp

//cleaning data
destring population, replace ignore(",")

//Dropping unnessesary observations, averaging every months observation for the year
collapse (mean) unemp population, by (state year)

clear 

//importing vaccancy data to clean
import excel state_vaccancies, firstrow

replace State = subinstr(State, ".", "", .)

foreach v of var * {
	local x : var label `v'
	rename `v' unemp`x'
}

rename unempState State

//reshape data
reshape long unemp, i(State) j(year) 

clear 

//Misnamed data
use unemp
rename unemp vac_rate


//Mining data state homeless counts
clear

/* do-file code to read Excel spreadsheets */

/* loop thru each of the Sheets beginning with Sheet4 */
clear
local sheet = 2007
import excel state_homeless, sheet(2007) firstrow
keep State OverallHomeless2*
save homeless_master, replace
clear

//importing homeless count for each state by year(which is on different sheets)
forvalues  i = 2008/2022{

	import excel state_homeless, sheet(`i') firstrow
  
	keep State OverallHomeless2*
  
	merge 1:1 State using homeless_master
	drop _merge
	save homeless_master, replace
	clear
  
}

clear
use homeless_master
drop if State == "Total"
save homeless_master, replace


//reshape data
reshape long OverallHomeless, i(State) j(year) 

drop in 1/16
save homeless_master, replace

clear



////
//Data Mining for Bed counts

/* loop thru each of the Sheets beginning with Sheet4 */
clear
local sheet = 2007
import excel state_beds, sheet(2007) firstrow
keep State TotalYearRoundBeds*
rename TotalYearRoundBeds* beds_`sheet'
save beds_master, replace
clear

//importing beds count for each state by year(which is on different sheets)
forvalues  i = 2008/2022{

	import excel state_beds, sheet(`i') firstrow
  
	keep State TotalYearRoundBedsESTH*
	rename TotalYearRoundBedsESTH beds_`i'
  
	merge 1:1 State using beds_master
	drop _merge
	save beds_master, replace
	clear
  
}

use beds_master
drop in 1
drop if State == "Total"
drop if State == "MP"

reshape long beds_, i(State) j(year) 

save beds_master, replace

clear

///You need to merge data by State, yet some of the data has the name and
//not the two letter identifier
//All data is already in long format


use vac_rate


replace State = "AL" if (State == "Alabama")
replace State = "AK" if (State == "Alaska")
replace State = "AZ" if (State == "Arizona")
replace State = "AR" if (State == "Arkansas")
replace State = "CA" if (State == "California")
replace State = "CO" if (State == "Colorado")
replace State = "CT" if (State == "Connecticut")
replace State = "DE" if (State == "Delaware")
replace State = "FL" if (State == "Florida")
replace State = "GA" if (State == "Georgia")
replace State = "HI" if (State == "Hawaii")
replace State = "ID" if (State == "Idaho")
replace State = "IL" if (State == "Illinois")
replace State = "IN" if (State == "Indiana")
replace State = "IA" if (State == "Iowa")
replace State = "KS" if (State == "Kansas")
replace State = "KY" if (State == "Kentucky")
replace State = "LA" if (State == "Louisiana")
replace State = "ME" if (State == "Maine")
replace State = "MD" if (State == "Maryland")
replace State = "MA" if (State == "Massachusetts")
replace State = "MI" if (State == "Michigan")
replace State = "MN" if (State == "Minnesota")
replace State = "MS" if (State == "Mississippi")
replace State = "MO" if (State == "Missouri")
replace State = "MT" if (State == "Montana")
replace State = "NE" if (State == "Nebraska")
replace State = "NV" if (State == "Nevada")
replace State = "NH" if (State == "New Hampshire")
replace State = "NJ" if (State == "New Jersey")
replace State = "NM" if (State == "New Mexico")
replace State = "NY" if (State == "New York")
replace State = "NC" if (State == "North Carolina")
replace State = "ND" if (State == "North Dakota")
replace State = "OH" if (State == "Ohio")
replace State = "OK" if (State == "Oklahoma")
replace State = "OR" if (State == "Oregon")
replace State = "PA" if (State == "Pennsylvania")
replace State = "RI" if (State == "Rhode Island")
replace State = "SC" if (State == "South Carolina")
replace State = "SD" if (State == "South Dakota")
replace State = "TN" if (State == "Tennessee")
replace State = "TX" if (State == "Texas")
replace State = "UT" if (State == "Utah")
replace State = "VT" if (State == "Vermont")
replace State = "VA" if (State == "Virginia")
replace State = "WA" if (State == "Washington")
replace State = "WV" if (State == "West Virginia")
replace State = "WI" if (State == "Wisconsin")
replace State = "WY" if (State == "Wyoming")
replace State = "DC" if (State == "District of Columbia")

save vac_rate, replace

clear

use unemp_pop

rename statearea State

replace State = "AL" if (State == "Alabama")
replace State = "AK" if (State == "Alaska")
replace State = "AZ" if (State == "Arizona")
replace State = "AR" if (State == "Arkansas")
replace State = "CA" if (State == "California")
replace State = "CO" if (State == "Colorado")
replace State = "CT" if (State == "Connecticut")
replace State = "DE" if (State == "Delaware")
replace State = "FL" if (State == "Florida")
replace State = "GA" if (State == "Georgia")
replace State = "HI" if (State == "Hawaii")
replace State = "ID" if (State == "Idaho")
replace State = "IL" if (State == "Illinois")
replace State = "IN" if (State == "Indiana")
replace State = "IA" if (State == "Iowa")
replace State = "KS" if (State == "Kansas")
replace State = "KY" if (State == "Kentucky")
replace State = "LA" if (State == "Louisiana")
replace State = "ME" if (State == "Maine")
replace State = "MD" if (State == "Maryland")
replace State = "MA" if (State == "Massachusetts")
replace State = "MI" if (State == "Michigan")
replace State = "MN" if (State == "Minnesota")
replace State = "MS" if (State == "Mississippi")
replace State = "MO" if (State == "Missouri")
replace State = "MT" if (State == "Montana")
replace State = "NE" if (State == "Nebraska")
replace State = "NV" if (State == "Nevada")
replace State = "NH" if (State == "New Hampshire")
replace State = "NJ" if (State == "New Jersey")
replace State = "NM" if (State == "New Mexico")
replace State = "NY" if (State == "New York")
replace State = "NC" if (State == "North Carolina")
replace State = "ND" if (State == "North Dakota")
replace State = "OH" if (State == "Ohio")
replace State = "OK" if (State == "Oklahoma")
replace State = "OR" if (State == "Oregon")
replace State = "PA" if (State == "Pennsylvania")
replace State = "RI" if (State == "Rhode Island")
replace State = "SC" if (State == "South Carolina")
replace State = "SD" if (State == "South Dakota")
replace State = "TN" if (State == "Tennessee")
replace State = "TX" if (State == "Texas")
replace State = "UT" if (State == "Utah")
replace State = "VT" if (State == "Vermont")
replace State = "VA" if (State == "Virginia")
replace State = "WA" if (State == "Washington")
replace State = "WV" if (State == "West Virginia")
replace State = "WI" if (State == "Wisconsin")
replace State = "WY" if (State == "Wyoming")
replace State = "DC" if (State == "District of Columbia")
replace State = "LAC" if (State == "Los Angeles County")
replace State = "NYC" if (State == "New York city")

save unemp_pop, replace

clear

//Merging data sets into one master file
use unemp_pop

merge 1:1 State year using vac_rate

drop _merge

merge 1:1 State year using homeless_master

drop _merge

merge 1:1 State year using beds_master

drop _merge

save master_file2, replace

drop if year < 2007

//dropp unwanted data
drop if State == "AS" 
drop if State == "GU" 
drop if State == "LAC" 
drop if State == "MP" 
drop if State == "NYC" 
drop if State == "PR" 
drop if State == "VI"

//generate State codes
egen state_code = group(State)

generate lpop = log(population)

destring OverallHomeless, replace

generate lhomeless = log(OverallHomeless)
	
rename OverallHomeless homeless

rename beds_ beds

save master_file2, replace

