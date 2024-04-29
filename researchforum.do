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
	}
	if 2 {
		stset end, ///
		    enter(nx) ///
			origin(nx) ///
			fail(died) ///
			scale(365.25)
		sts graph if don_age > 60, ///
		    by(risk) ///
		    fail ///
			tmax(15) ///
			per(100) ///
			ylab(0(10)70, ///
			    format(%2.0f) ///
			) ///
			risktable ///
			legend( ///
			   on ///
			   order(3 2 1) ///
			   lab(3 "General") lab(2 "Healthy") lab(1 "Donors") ///
			) ///
			ti("Years") ///
			xti("") ///
			yti("%", orientation(horizontal))
	}
}
