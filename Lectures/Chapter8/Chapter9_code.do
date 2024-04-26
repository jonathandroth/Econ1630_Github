/****************************************/
/* Example code for ECON21030 Chapter 9 */
/* Written by Peter Hull, 5/23/20 (v1)  */
/****************************************/

clear all
set seed 42

set obs 75

gen r = rnormal()

gen ybar = 0.2*r*(r>0)+exp(5*r)/(1+exp(5*r))-0.5
gen y = ybar+0.1*rnormal()
replace y = . if r>-0.1 & r<0.1 
replace y = . if y>1
drop if r<-2 | r>2

scatter y r,  ///
	xline(0, lcolor(black) lpattern(dash)) ///
	graphregion(color(white)) ytitle("Outcome") xtitle("Running Variable") ///
	legend(order(1) label(1 "Data")) ylab(-1(0.5)1)
graph export rd_data.png, replace

scatter y r || lfit y r if r<0, lcolor(maroon) range(-2 0) || lfit y r if r>0, lcolor(maroon) range(0 2) ///
	sort xline(0, lcolor(black) lpattern(dash)) ///
	graphregion(color(white)) ytitle("Outcome") xtitle("Running Variable") ///
	legend(order(1 2) label(1 "Data") label(2 "Linear Fit")) ylab(-1(0.5)1)
graph export rd_linear.png, replace

scatter y r || qfit y r if r<0, lcolor(maroon) range(-2 0) || qfit y r if r>0, lcolor(maroon) range(0 2) ///
	sort xline(0, lcolor(black) lpattern(dash)) ///
	graphregion(color(white)) ytitle("Outcome") xtitle("Running Variable") ///
	legend(order(1 2) label(1 "Data") label(2 "Quadratic Fit")) ylab(-1(0.5)1)
graph export rd_quad.png, replace

scatter y r || lfit y r if r<0 & r>-0.75, lcolor(maroon) range(-0.75 0) || lfit y r if r>0 & r<0.75, lcolor(maroon) range(0 0.75) ///
	sort xline(0, lcolor(black) lpattern(dash)) ///
	graphregion(color(white)) ytitle("Outcome") xtitle("Running Variable") ///
	legend(order(1 2) label(1 "Data") label(2 "Local Linear Fit")) ylab(-1(0.5)1)
graph export rd_llin.png, replace

scatter y r || line ybar r, ///
	sort xline(0, lcolor(black) lpattern(dash)) ///
	graphregion(color(white)) ytitle("Outcome") xtitle("Running Variable") ///
	legend(label(1 "Data") label(2 "True CEF")) ylab(-1(0.5)1)
graph export rd_truth.png, replace

