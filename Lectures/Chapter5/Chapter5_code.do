/****************************************/
/* Example code for ECON21030 Chapter 4 */
/* Written by Peter Hull, 4/8/20 (v1)   */
/****************************************/

clear all
set seed 42
set more off 

use census00, clear /* cleaned 2000 Census data, from Angrist, Chernozhukov, and Fernandez-Val (2006). Available at https://economics.mit.edu/faculty/angrist/data1/data/angchefer06 */
keep if educ!=. & logwk!=.

summ educ [aw=perwt]
local educ_mn = r(mean)
summ logwk [aw=perwt]
local logwk_mn = r(mean)

reg logwk educ [aw=perwt]
local cons = _b[_cons]
local slope = _b[educ]

preserve
collapse (mean) logwk (sum) perwt [aw=perwt], by(educ)

twoway (scatter logwk educ), ///
	xlab(8(2)20) ylab(5.5(0.5)7.5) ///
	ytitle("Log weekly wage") xtitle("Years of schooling")
*graph export stata2pre.png, replace

twoway (scatter logwk educ) (lfit logwk educ [aw=perwt]), ///
	xlab(8(2)20) ylab(5.5(0.5)7.5) xline(`educ_mn', lcolor(black) lpattern(dash)) yline(`logwk_mn', lcolor(black) lpattern(dash)) ///
	ytitle("Log weekly wage") xtitle("Years of schooling")
*graph export stata2.png, replace
restore

reg logwk educ black [aw=perwt]

reg educ black [aw=perwt]
predict educ_r, resid
reg logwk black [aw=perwt]
predict logwk_r, resid

reg logwk educ_r [aw=perwt]
reg logwk_r educ_r [aw=perwt]

gen college = (educ >= 16)

summ college [aw=perwt]
local college_mn = r(mean)
summ logwk [aw=perwt]
local logwk_mn = r(mean)

preserve

collapse (mean) logwk (sum) perwt [aw=perwt], by(college)

twoway (scatter logwk college) (lfit logwk college [aw=perwt]), ///
	xlab(0(0.2)1) ylab(5.5(0.5)7.5) xline(`college_mn', lcolor(black) lpattern(dash)) yline(`logwk_mn', lcolor(black) lpattern(dash)) ///
	ytitle("Log weekly wage") xtitle("College completion")
*graph export stata4.png, replace

restore

gen college_age=college*age

reg logwk college [aw=perwt]
reg logwk college age [aw=perwt]
reg logwk college age college_age [aw=perwt]
reg logwk age if college [aw=perwt]
reg logwk age if !college [aw=perwt]

sample 10
reg logwk college [aw=perwt]
reg logwk college age [aw=perwt]
reg logwk college age college_age [aw=perwt]
reg logwk age if college [aw=perwt]
reg logwk age if !college [aw=perwt]



******* Make Mincer graphs ******

use cps_data.dta, clear

keep if uhrsworkt > 10

gen logwage = ln(hourwage)

collapse (mean) logwage (sum) asecwt [aw=asecwt], by(age)

keep if age >= 21 & age <= 50

twoway (scatter logwage age) , ///
	ytitle("Log weekly wage") xtitle("Age")
	
graph export logwages.png, replace

	
twoway (scatter logwage age) (lfit logwage age [aw = asecwt]), ///
	ytitle("Log weekly wage") xtitle("Age")
	
graph export logwages-linear.png, replace

	
twoway (scatter logwage age) (qfit logwage age [aw = asecwt]), ///
	ytitle("Log weekly wage") xtitle("Age")		
	
graph export logwages-quadratic.png, replace

**** Make graphs about overfitting

use cps_data.dta, clear

keep if uhrsworkt > 10

gen logwage = ln(hourwage)

gen insample = 0
replace insample = 1 in 1/10000 


collapse (mean) logwage (sum) asecwt [aw=asecwt], by(age insample)

keep if age >= 21 & age <= 50




gen agesq = age^2

forvalues a=3/30{
 gen age`a' = age^`a'
}




reg logwage age [aw=asecwt] if insample, r
reg logwage age agesq [aw=asecwt] if insample, r






reg logwage age agesq [aw = asecwt] if insample, r
predict p2

reg logwage age agesq age3-age20 [aw = asecwt] if insample, r
predict p20


twoway (scatter logwage age) (line p2 age), ///
	ytitle("Log weekly wage") xtitle("Age")

graph export quadfit-insample.png, replace

	
twoway (scatter logwage age) (line p2 age) if insample == 0, ///
	ytitle("Log weekly wage") xtitle("Age")

graph export quadfit-outsample.png, replace



twoway (scatter logwage age) (line p20 age), ///
	ytitle("Log weekly wage") xtitle("Age")

graph export p20fit-insample.png, replace
	
	
twoway (scatter logwage age) (line p20 age) if insample == 0, ///
	ytitle("Log weekly wage") xtitle("Age")

graph export p20fit-outsample.png, replace



twoway (scatter logwage age) (line p20 age), ///
	ytitle("Log weekly wage") xtitle("Age")

	
twoway (scatter logwage age) (line p20 age) if insample == 0, ///
	ytitle("Log weekly wage") xtitle("Age")



reg logwage age agesq age3 if insample, r
predict cubic


reg logwage age agesq age3-age8 if insample, r
predict octic

reg logwage age agesq age3-age12 if insample, r
predict p12




twoway (scatter logwage age) (qfit logwage age [aw = asecwt]) if insample, ///
	ytitle("Log weekly wage") xtitle("Age")

	

	
twoway (scatter logwage age) (lfit logwage age [aw = asecwt]) if insample, ///
	ytitle("Log weekly wage") xtitle("Age")

	
twoway (scatter logwage age) (lfit logwage age [aw = asecwt]) if insample == 0, ///
	ytitle("Log weekly wage") xtitle("Age")
	


twoway (scatter logwage age) (line cubic age) if insample, ///
	ytitle("Log weekly wage") xtitle("Age")

	
twoway (scatter logwage age) (line octic age) if insample, ///
	ytitle("Log weekly wage") xtitle("Age")
	

	
twoway (scatter logwage age) (line octic age) if insample == 0, ///
	ytitle("Log weekly wage") xtitle("Age")
	
	
twoway (scatter logwage age) (line p12 age), ///
	ytitle("Log weekly wage") xtitle("Age")

twoway (scatter logwage age) (line p20 age), ///
	ytitle("Log weekly wage") xtitle("Age")

	
twoway (scatter logwage age) (line p20 age) if insample == 0, ///
	ytitle("Log weekly wage") xtitle("Age")
	
	
twoway (scatter logwage age) (line p20 age), ///
	ytitle("Log weekly wage")
	