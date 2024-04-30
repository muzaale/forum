qui {
	cls
	if "nondonor" == "nondonor" {
        //parametric
		use b_nondonor, clear 
        mkmat beta1 beta2 beta3 beta4 ///
            beta5 beta6 beta7 beta8 ///
	        beta9 beta10 beta11 ///
            , matrix(b_nondonor)
		use b_donor, clear 
		mkmat beta1 beta2 beta3 beta4 ///
            beta5, matrix(b_donor)
		    //scenario
		matrix SV_nondonor = (40, 1, 1, 0, 0, 27, 120, 0, 0, 90, 10) 
		matrix SV_donor =    (40, 1, 1, 0, 0)
		matrix risk_score_nondonor = SV_nondonor * b_nondonor'
		matrix risk_score_donor = SV_donor * b_donor'
		matrix list risk_score_nondonor
		matrix list risk_score_donor 
		di exp(risk_score_nondonor[1,1])
		di exp(risk_score_donor[1,1])
		//nonparametric
		use s0_nondonor, clear 
		append using s0_donor 
        g f0_nondonor = (1 - s0_nondonor) * 100  
		g f0_donor = (1 - s0_donor) * 100 
		//semiparametric
        g f1_nondonor = f0_nondonor * exp(risk_score_nondonor[1,1])
		g f1_donor = f0_donor * exp(risk_score_donor[1,1]) 
        drop if _t > 15
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
			ylab(0(3)9) xlab(0(3)15) ///
			yti("") ///
			ti("Clinical Scenario, %", pos(11)) ///
			xti("Years") ///
			note("60yo, female, white, BMI=27kg/m2, SBP=120mmHg,"  ///
			     "no hypertension, no history of smoking" ///
				 "eGFR=90ml/min, uACR=10mg/g" ///
                  ,size(1.5) ///
		)
		graph export personalized.png, replace 
	}
}
