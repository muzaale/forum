qui {
	if 0 { //Switch "off" to zero once macros defined
		global repo https://github.com/muzaale/forum/raw/main/
		global data1 esrdRisk_t0.dta
		global data2 esrdRisk_t02tT.dta
		global data3 esrdRisk_tT.dta
		cls 
		clear 
		noi di "What is your work directory?" _request(workdir)
		if "$workdir" == "" {
			noi di "You've not provided a work directory"
			exit 340600
		}
		else {
			set obs 10
			gen x=_n
			cd "$workdir"
			save test.dta, replace 
			capture confirm file test.dta 
			rm test.dta
			if _rc == 0 {
				noi di "You're good to go!"
			}
			else {
				noi di "Unable to change to that directory. Please review"
			}
		}
	}
	if 1 { //Dataset with rigorous simulations
		use ${repo}esrdRisk_t02tT.dta, clear 
		codebook rSM*
		g nx=rSMGJcEdF_t0 
		g end=rSMGJcEdF_tT 
		g risk=rSMGJcEdF_x 
		g status=rSMGJcEdF_d 
		g died=status==2
		stset end, ///
		    enter(nx) ///
			origin(nx) ///
			fail(died) ///
			scale(365.25)
	}
	if 0 { //Nonparametric
		sts graph if don_age > 60, ///
		    by(risk) ///
		    fail ///
			tmax(15) ///
			per(100) ///
			ylab(0(10)70, ///
			    format(%2.0f) ///
			) ///
			risktable(, ///
			    color(green) ///
			    order( ///
				    3 "General" ///
					2 "Healthy" ///
					1 "Donors" ///
				) ///
				title("# at Risk") ///
			) ///
			risktable(, color(stc3) group (#3)) ///
			risktable(, color(stc2) group (#2)) ///
			risktable(, color(stc1) group(#1)) ///
			legend( ///
			   on ///
			   order(3 2 1) ///
			   lab(3 "General") ///
			   lab(2 "Healthy") ///
			   lab(1 "Donors") ///
			   ring(0) pos(11) ///
			) ///
			ti("Mortality", pos(11)) ///
			xti("Years") ///
			yti("%", orientation(horizontal))
		graph export risk.png, replace 
	}
	if 1 { //Semiparametric
		noi stcox i.risk
		lincom _b[1.risk]
		local donor=r(estimate)
		local donor_lb=r(estimate)
		local donor_ub=r(estimate)
		lincom _b[2.risk]
		local healthy=r(estimate)
		local healthy_lb=r(lb)
		local healthy_ub=r(ub)
		lincom _b[3.risk]
		local general=r(estimate)
		local general_lb=r(lb)
		local general_ub=r(ub)
		postfile pp risk hr lb ub using np.dta, replace 
		post pp (1) (`donor') (`donor_lb') (`donor_ub')
		post pp (2) (`healthy') (`healthy_lb') (`healthy_ub')
		post pp (3) (`general') (`general_lb') (`general_ub')
		postclose pp
        use np, clear 
		twoway ///
		    (scatter hr risk) ///
			(rcap lb ub risk, ///
			    legend(off) ///
			    xlab(1(1)3 ///
			        1 "    Donors" ///
				    2 "Healthy" ///
				    3 "General     " ///
			    ) ///
				ylab( ///
				    0 "1" ///
				    1.6094379 "5" ///
					3.2188758  "25" ///
					4.8283137 "125" ) ///
				yti("Hazard Ratio", orientation(horizontal)) ///
				xti("") ///
				ti("15-Year Risk of ESRD", pos(11)) ///
			) 
		graph export hr.png, replace 
	}
}
