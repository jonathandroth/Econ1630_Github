/****************************************/
/* Example code for ECON21030 Chapter 3 */
/* Written by Peter Hull, 4/1/21 (v1)   */
/****************************************/

clear all 
set seed 1234
set more off
set matsize 5000

matrix sims=J(5000,1,.)
foreach N in 1 2 5 10 {
	forval j=1/5000 {
		qui {
			clear
			set obs `N'
			gen X = runiform()
			summ X
			matrix sims[`j',1]=r(mean)
		}
	}
	clear
	svmat sims
	hist sims, xlabel(0(0.2)1) normal xtitle("Sample mean")
	graph export sims`N'.png, replace
}

matrix sims=J(5000,1,.)
foreach N in 1 10 100 1000 {
	forval j=1/5000 {
		qui {
			clear
			set obs `N'
			gen X = runiform()
			summ X
			matrix sims[`j',1]=r(mean)
		}
	}
	clear
	svmat sims
	summ sims
	local mean = r(mean)
	hist sims, xlabel(0(0.2)1) xline(`mean') xtitle("Sample mean")
	graph export sims`N'_2.png, replace
}


matrix sims=J(5000,1,.)
foreach N in 1 2 5 100 {
	forval j=1/5000 {
		qui {
			clear
			set obs `N'
			gen W = 0.1*rnormal()
			gen Q = rbeta(0.3,0.5)
			gen X = W+Q
			summ X
			matrix sims[`j',1]=(r(mean)-0.3/(0.3+0.5))*sqrt(`N')
		}
	}
	clear
	svmat sims
	summ sims
	local mean = r(mean)
	drop if sims<-1 | sims>1
	hist sims, xlabel(-1(0.5)1) xline(`mean') xtitle("Sample mean") normal
	graph export sims`N'_3.png, replace
}
