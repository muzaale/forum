qui {
	if 1 == 1  {
		cls
        global repo "https://github.com/muzaale/forum/raw/main/" 
		import delimited "${repo}mort_survival.csv", clear 
        rename (_d _t _t0)(d t t0)
        stset t, fail(d)
        //sts graph, fail per(100)  
	}
	if 2 ==2 {
		set seed 340600
		g x=rbinomial(1,.5)
		//nonparametric
		stcox x, basesurv(s0_nondonor)
		//sts graph, fail per(100) by(x)
		keep s0_nondonor _t
		save s0_nondonor, replace 
	}
	if 3.1 == 3.1 {
		import excel "${repo}/cox_coef_mort.xlsx", sheet("Sheet1") clear
		drop A C E G J L N AE AH AM AW
		ds 
		mkmat `r(varlist)', matrix(b_nondonor)
	}
	if 3.2 == 3.2 {
		use b_donor, replace 
		ds 
		mkmat `r(varlist)', matrix(b_donor )
	}
	if 4.1 == 4.1 {
		matrix SV_nondonor = ///
		    ( ///
			0 , /// dm
			0 , /// insulin
			0 , /// dm pill
			0 , /// htn
			0 , /// htn don't know
			0 , /// htn pill 
			0 , /// smoke
			0 , /// income 5k
			0 , /// 10k
			0 , /// 15k
			0 , /// 20k
			0 , /// 25k
			0 , /// 35k
			0 , /// 45k
			1 , /// 55k
			0 , /// 65k
			0 , /// >20k
			0 , /// <20k
			0 , /// 14
			0 , /// 15
			0 , /// refused
			0 , /// don't know
			0 , /// male
			0 , /// mexican (race/ethnicity)
			0 , /// other hisp
			0 , /// black
			0 , /// other
			0 , /// excellent (health status); good is ref?
			0 , /// very good
			0 , /// fail 
			0 , /// poor
			0 , /// refused 
			0 , /// 8
			0 , /// don't know
			0 , /// education: k8
			0 , /// some hs
			0 , /// diploma or equi
			0 , /// some coll or associate
			0 , /// > high schol
			0 , /// refused 
		  -20 , /// age; all these are centered
			0 , /// sbp
			0 , /// dbp
			0 , /// bmi 
			0 , /// egfr 
			0 , /// uacr
			0   /// hba1c or ghb ///
			)
	}
	if 4.2 == 4.2 {
		matrix SV_donor = ///
		    ( ///
		  -20 , /// age; all these are centered
			0 , /// female 
			0 , /// white 
			0 , /// black
			0 , /// hisp
			0   /// other 
			)
	}
	if 5.1 == 5.1 {
		matrix risk_score_nondonor = SV_nondonor * b_nondonor'
		noi matrix list risk_score_nondonor
		noi di exp(risk_score_nondonor[1,1])
	}
	if 5.2 == 5.2 {
		matrix risk_score_donor = SV_donor * b_donor'
		noi matrix list risk_score_donor
		noi di exp(risk_score_donor[1,1])
	}
	if 6 == 6 {
		//nonparametric
		use s0_nondonor, clear
		append using s0_donor
		g f0_nondonor = (1 - s0_nondonor) * 100 
		g f0_donor = (1 - s0_donor) * 100 
		//semiparametric
		g f1_nondonor = f0_nondonor * exp(risk_score_nondonor[1,1])
		g f1_donor = f0_donor * exp(risk_score_donor[1,1]) 
	}
	if 7 == 7 {
		//visualization
		line f1_donor _t, ///
		    sort connect(step step) || ///
		line f1_nondonor _t, ///
		    sort connect(step step) ///
			legend( ///
			    ring(0) ///
				pos(11) ///
				lab(1 "Donor") ///
				lab(2 "Nondonor") ///
			) ///
			ylab(0(5)40) xlab(0(5)30) ///
			yti("") ///
			ti("Clinical Scenario, %", pos(11)) ///
			xti("Years") ///
			note("60yo, female, white, BMI=27kg/m2, SBP=120mmHg,"  ///
			     "no hypertension, no history of smoking" ///
				 "eGFR=90ml/min, uACR=10mg/g" ///
                  ,size(1.5) ///
		)
		graph export aim1.png, replace 
	}
}

