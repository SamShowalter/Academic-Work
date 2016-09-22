clear
*NOTE: Do-file requires you to tap any key on the keyboard to
*page through regression and estout output in STATA. 
*Program will pause until you have done so. 

*Utilizing raw dataset for project
use  I:\15161-ECON385A\SAMUELSHOWALTER_2018\Final_Project\Volunteerism_Education_Dataset.dta

*Refining data to remove niu, nonresponse, unnecessary, and ill-formatted data
drop if vlstatus == 99
drop if marst == 2
drop if earnweek == 2884.61
drop if classwkr == 0
drop if classwkr == 29
drop if classwkr == 14
drop if famsize > 8

*dropping niu earnweek obs. and recoding earnweek=0 for unemployment
drop if earnweek == 9999.99 & empstat == 10
drop if earnweek == 9999.99 & empstat == 12
recode earnweek (9999.99 = 0) if empstat == 21
recode earnweek (9999.99  = 0) if empstat == 22

*Dropping niu union obs. and recoding union=1 for unemployment
drop if union == 0 & empstat == 10
drop if union == 0 & empstat == 12
recode union (0 = 1) if empstat == 21
recode union (0 = 1) if empstat == 22


*Dropping vlhallorg nonresponse for vlstatus=1 and recoding vlhallorg=0 for non-volunteers
drop if vlstatus == 1 & vlhallorg == 99999
recode vlhallorg (99999 = 0) if vlstatus == 2

*Combining empstat unemployment types into general unemployment
recode empstat (22 = 21)

*Recoding educ to create "Grade 4 or below" base case
recode educ (010 = 002)
recode educ (91=92)

*Creating four race dummies
generate White = 0
replace White = 1 if race==100
generate Black = 0
replace Black = 1 if race==200
generate Asian = 0
replace Asian = 1 if race==651
generate Hispanic = 1
replace Hispanic = 0 if hispan==000

*Creating employment dummy
generate Employed = 1
replace Employed = 0 if empstat == 21

*Creating work sector dummies
generate Private_Sector = 0
replace Private_Sector = 1 if classwkr == 22
replace Private_Sector = 1 if classwkr == 23
generate Government_Sector = 0
replace Government_Sector = 1 if classwkr == 25
replace Government_Sector = 1 if classwkr == 27
replace Government_Sector = 1 if classwkr == 28

*Creating non-linear variables for age and famsize
generate Age_Squared = age^2
generate Famsize_Squared = famsize^2

*Regression with i.educ and install of estout
regress vlhallorg i.educ i.sex age Age_Squared Black White Hispanic Asian earnweek famsize Famsize_Squared i.marst Employed i.diffany hrswork Private_Sector Government_Sector i.year i.region

*Creating degree attainment dummies for education
generate ElementaryS_Attainment = 0
replace ElementaryS_Attainment = 1 if educ == 20
generate MiddleS_Attainment = 0 
replace MiddleS_Attainment = 1 if educ == 30
replace MiddleS_Attainment = 1 if educ == 40
replace MiddleS_Attainment = 1 if educ == 50
replace MiddleS_Attainment = 1 if educ == 60
replace MiddleS_Attainment = 1 if educ == 71
generate HSDiploma = 0
replace HSDiploma = 1 if educ == 73
replace HSDiploma = 1 if educ == 81
generate Associates_Degree = 0
replace Associates_Degree = 1 if educ == 91
replace Associates_Degree = 1 if educ == 92
generate Bachelors_Degree = 0
replace Bachelors_Degree = 1 if educ == 111
generate Masters_Degree = 0
replace Masters_Degree = 1 if educ == 123
generate Professional_Degree = 0
replace Professional_Degree = 1 if educ == 124
generate Doctorate_Degree = 0
replace Doctorate_Degree = 1 if educ == 125

*Regression with degree attainment dummies
regress vlhallorg ElementaryS_Attainment MiddleS_Attainment HSDiploma Associates_Degree Bachelors_Degree Masters_Degree Professional_Degree Doctorate_Degree i.sex age Age_Squared Black White Hispanic Asian earnweek famsize Famsize_Squared i.marst Employed i.diffany hrswork Private_Sector Government_Sector i.year i.region

* get pretty reg results package
ssc install estout, replace
* educ recode for March CPS
gen educyears=0
replace educyears = 6  if educ<=020
replace educyears = 8  if educ==030
replace educyears = 9  if educ==040
replace educyears = 10  if educ==050
replace educyears = 11  if educ==060
replace educyears = 11  if educ==071
replace educyears = 12  if educ==073
replace educyears = 13  if educ==081
replace educyears = 14  if educ==091
replace educyears = 14  if educ==092
replace educyears = 16  if educ==111
replace educyears = 18  if educ==123
replace educyears = 18  if educ==124
replace educyears = 20  if educ==125
tabulate educyears

*Regression with educyears
regress vlhallorg educyears i.sex age Age_Squared Black White Hispanic Asian earnweek famsize Famsize_Squared i.marst Employed i.diffany hrswork Private_Sector Government_Sector i.year i.region

*Summarize Statistics for variables included in regressions
summarize vlhallorg i.educ age Black White Hispanic Asian earnweek Employed hrswork Private_Sector Government_Sector famsize i.marst i.sex i.diffany i.union, separator(15) vsquish

*Sets up complex design
svyset [pweight=wtsupp]

*All regressions, stored in eststo (after estout download). Robust SE used.
ssc install estout, replace
eststo: regress vlhallorg educyears i.sex age Age_Squared Black White Hispanic Asian earnweek famsize Famsize_Squared i.marst Employed i.diffany hrswork Private_Sector Government_Sector i.year i.union i.region, robust
eststo: regress vlhallorg ElementaryS_Attainment MiddleS_Attainment HSDiploma Associates_Degree Bachelors_Degree Masters_Degree Professional_Degree Doctorate_Degree i.sex age Age_Squared Black White Hispanic Asian earnweek famsize Famsize_Squared i.marst Employed i.diffany hrswork Private_Sector Government_Sector i.union i.year i.region, robust
eststo: regress vlhallorg i.educ i.sex age Age_Squared Black White Hispanic Asian earnweek famsize Famsize_Squared i.marst Employed i.diffany hrswork Private_Sector Government_Sector i.year i.union i.region, robust

*Final Model with probability weighting
eststo: svy: regress vlhallorg i.educ i.sex age Age_Squared Black White Hispanic Asian earnweek famsize Famsize_Squared i.marst Employed i.diffany hrswork Private_Sector Government_Sector i.union i.year i.region

*Formatting Edits to create tables
label variable famsize "Family Size"
label variable MiddleS_Attainment "Middle School"
label variable ElementaryS_Attainment "Elementary School"
label variable MiddleS_Attainment "Middle School"
label variable HSDiploma "HS Diploma"
label variable Associates_Degree "Associates Degree"
label variable Bachelors_Degree "Bachelors Degree"
label variable Masters_Degree "Masters Degree"
label variable Professional_Degree "Professional Degree"
label variable Doctorate_Degree "Doctorate Degree"
label variable hrswork "Weekly Hours Worked"
label variable educyears "Education (years)"
label variable Age_Squared "Age Squared"
label variable Famsize_Squared "Famsize Squared"
label variable Private_Sector "Private Sector"
label variable Government_Sector "Government Sector"
label variable earnweek "Weekly Earnings"


*Display functions to add tables into final paper (sorry for long codeline)
esttab, se varwidth(25) label nomtitles nobaselevels r2 ar2 nogaps rename(2.diffany Disabled 71.educ Grade_12 73.educ HSDiploma 81.educ Some_College 92.educ Associates_Degree 111.educ Bachelors_Degree 123.educ Masters_Degree 124.educ Professional_Degree 125.educ Doctorate_Degree)title(OLS and PWLS Volunteerism Regressions) drop(81.educ 92.educ 111.educ 123.educ 124.educ 125.educ 2010.year 2011.year 2012.year 2013.year 12.region 33.region 21.region 22.region 31.region 32.region 33.region 41.region 42.region) order(educyears 20.educ ElementaryS_Attainment 30.educ MiddleS_Attainment 40.educ 50.educ 60.educ Grade_12 HSDiploma Some_College 81.educ 92.educ 111.educ 123.educ 124.educ 125.educ Associates_Degree Bachelors_Degree Masters_Degree Professional_Degree Doctorate_Degree) addnotes(Four year dummies and eight region dummies included in regression, but omitted.) 






