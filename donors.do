qui {
	if 1 == 1 {
		use ${repo}donor_live if ///
		    inrange(don_recov_dt,d(01jan1994),d(31dec2019)) & ///
			inlist(don_org1,"LKI","RKI") & ///
			inrange(don_age,18,85), clear 
	}
	if 2.1 == 0 {
		*hist pers_ssa_death_dt //data are no good after 2011
		replace pers_ssa_death_dt=. if pers_ssa_death_dt>d(31dec2011)
		g died = !missing(pers_ssa_dt)
	    qui sum pers_ssa_dt
		//GPT-4 fixed this: The line g died = !missing(pers_ssa_deat) might be a typo. You likely meant pers_ssa_death_dt.
	    replace pers_ssa_dt = r(max) if missing(pers_ssa_deat)
	    g years_mort=(pers_ssa_deat-don_recov_dt)/365.25
	}
	if 2.2 == 2.2 {
		format pers_esrd_first_service_dt %td
		hist pers_esrd_first_service_dt  //data are no good after 2019
		replace pers_esrd_first_service_dt=. if !inrange(pers_esrd_first_service_dt,d(01jan1994),d(31dec2019))  
		g esrd = !missing(pers_esrd_first_service_dt)
	    qui sum pers_esrd_first_service_dt
	    replace pers_esrd_first_service_dt = r(max) if missing(pers_esrd_first_service_dt)
	    g years_esrd=(pers_esrd_first_service_dt-don_recov_dt)/365.25
	}
	if 3.1 == 0 {
		stset years_mort, fail(died)
	}
	if 3.2 == 3.2 {
		stset years_esrd, fail(esrd)
	}
	if 4.1 == 0 {
		sts graph, ///
		    fail per(100) ///
			ylab(0(1)5) ///
			xlab(0(5)20)
	}
	if 4.2 == 4.2 {
		sts graph, ///
		    fail per(10000) ///
			ylab(0(20)100) ///
			xlab(0(5)30)
	}
	if 7 == 0 {
		tab don_relations
	}
	if 8.1 == 0 {
		g don_female=don_gender=="F"
		replace don_age = don_age - 60
		recode don_race (8=0)(16=1)(2000=2)(24/1999 .=3),gen(don_racecat)
		noi stcox don_age don_female i.don_racecat, basesurv(s0_donor)
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
	}
	if 8.2 == 8.2 {
		g don_female=don_gender=="F"
		replace don_age = don_age - 60
		recode don_race (8=0)(16=1)(2000=2)(24/1999 .=3),gen(don_racecat)
		noi stcox don_age don_female i.don_racecat, basesurv(s0e_donor)
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
