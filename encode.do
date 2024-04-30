qui {
	cls
	if "nondonor" == "nondonor" {
        use b_nondonor, clear 
        mkmat beta1 beta2 beta3 beta4 ///
            beta5 beta6 beta7 beta8 ///
	        beta9 beta10 beta11 beta12 ///
	        beta13 beta14 beta15 beta16, matrix(b_nondonor)
		use s0_nondonor, clear 
		append using b_donor
		append using s0_donor
		preserve 
		keep beta*
		drop if missing(beta1)
        mkmat beta1 beta2 beta3 beta4 ///
            beta5, matrix(b_donor)
		restore 
		//matrix list beta 
		matrix SV_nondonor = (60, 1, 1, 0, 0, 27, 0, 0, 1, 0, 120, 0, 0, 90, 10, 1) 
		matrix SV_donor = (60, 1, 1, 0, 0)
		matrix risk_score_nondonor = SV_nondonor * b_nondonor'
		matrix risk_score_donor = SV_donor * b_donor'
		matrix list risk_score_nondonor
		matrix list risk_score_donor 
		di exp(risk_score_nondonor[1,1])
		di exp(risk_score_donor[1,1])
		//15-year mortality for scenario 
        gen f0 = (1 - s0) * 100
        gen f1 = f0 * exp(risk_score[1,1])
        drop if _t > 15
        line f1 _t if donor==0, ///
		    sort connect(step step) || ///
		line f1 _t if donor ==1 , ///
		    sort connect(step step) ///
			legend( ///
			    ring(0) ///
				pos(11) ///
				lab(1 "Nondonor") ///
				lab(2 "Donor") ///
			) ///
			ylab(0(10)40) xlab(0(3)15) ///
			yti("") ///
			ti("Clinical Scenario, %", pos(11)) ///
			xti("Years") ///
			note("60yo, female, white, BMI=27kg/m2, graduate,"  ///
			     "SBP=120mmHg, no hypertension, no history of smoking" ///
				 "eGFR=90ml/min, uACR=10mg/g, healthy" ///
                  ,size(1.5) ///
		)
		graph export personalized.png, replace 
	}
}
