qui {
	/*
	1. Dimentionality reduction: [144784,253] -> b=[53,1] & V=[53,53]
	2. For both mortality & ESRD; thus 4 sets of donor parameters
	3. We then relay to `nondonor.do`' for the 4 sets of nondonor parameters
	*/
	if 1 == 1 {
		use ${repo}donor_live if ///
		    inrange(don_recov_dt,d(01jan1994),d(31dec2019)) & ///
			inlist(don_org1,"LKI","RKI") & ///
			inrange(don_age,18,90), clear 
	}
	if 2.1 == 2.1 { //mortality
		*hist pers_ssa_death_dt //data are no good after 2011
		replace pers_ssa_death_dt=. if pers_ssa_death_dt>d(31dec2011)
		g died = !missing(pers_ssa_death_dt)
	    qui sum pers_ssa_death_dt
		//GPT-4 fixed this: The line g died = !missing(pers_ssa_deat) might be a typo. You likely meant pers_ssa_death_dt.
	    replace pers_ssa_death_dt = r(max) if missing(pers_ssa_death_dt)
	    g years_mort=(pers_ssa_death_dt-don_recov_dt)/365.25
	}
	if 2.2 == 2.2 { ///esrd
		format pers_esrd_first_service_dt %td
		hist pers_esrd_first_service_dt  //data are no good after 2019
		replace pers_esrd_first_service_dt=. if !inrange(pers_esrd_first_service_dt,d(01jan1994),d(31dec2019))  
		g esrd = !missing(pers_esrd_first_service_dt)
	    qui sum pers_esrd_first_service_dt
	    replace pers_esrd_first_service_dt = r(max) if missing(pers_esrd_first_service_dt)
	    g years_esrd=(pers_esrd_first_service_dt-don_recov_dt)/365.25
	}
	if 3.1 == 3.1 { //mortality 
		stset years_mort, fail(died)
		sts graph, ///
		    fail per(100) ///
			ylab(0(1)5) ///
			xlab(0(5)20)
		g don_female=don_gender=="F"
		replace don_age = don_age - 60
		recode don_race (8=0)(16=1)(2000=2)(24/1999 .=3),gen(don_racecat)
		
		noi stcox don_age don_female i.don_racecat, basesurv(s0_donor)
		preserve  //debugged!
		keep s0_donor _t _st _t0 _d
		save s0_donor, replace 
		matrix define m = r(table)
		matrix beta = e(b)
		svmat beta 
		keep beta*
		drop if missing(beta1)
		save b_donor.dta, replace 
		matrix vcov = e(V)
		svmat vcov 
		keep vcov*
		drop if missing(vcov1)
		save V_donor.dta, replace 
		restore 
	}
	if 3.2 == 3.2 {
		stset years_esrd, fail(esrd)
		sts graph, ///
		    fail per(10000) ///
			ylab(0(20)100) ///
			xlab(0(5)30)
		noi stcox don_age don_female i.don_racecat, basesurv(s0e_donor)
		preserve 
		keep s0e_donor _t _st _t0 _d
		save s0e_donor, replace 
		matrix define me = r(table)
		matrix betae = e(b)
		svmat betae 
		keep betae*
		drop if missing(betae1)
		save be_donor.dta, replace 
		matrix vcove = e(V)
		svmat vcove 
		keep vcove*
		drop if missing(vcove1)
		save Ve_donor.dta, replace
	}
}
