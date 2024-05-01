qui {
	if 1 == 1 {
		use ${repo}donor_live if ///
		    inrange(don_recov_dt,d(01jan1994),d(31dec2019)) & ///
			inlist(don_org1,"LKI","RKI") & ///
			inrange(don_age,18,85), clear 
	}
	if 2 == 2 {
		*hist pers_ssa_death_dt //data are no good after 2011
		replace pers_ssa_death_dt=. if pers_ssa_death_dt>d(31dec2011)
		g died = !missing(pers_ssa_deat)
	    qui sum pers_ssa_deat
	    replace pers_ssa_deat = r(max) if missing(pers_ssa_deat)
	    g years_mort=(pers_ssa_deat-don_recov_dt)/365.25
	}
	if 3 == 3 {
		stset years_mort, fail(died)
	}
	if 4 == 0 {
		g esrd = !missing()
	}
	if 6 == 6 {
		sts graph, ///
		    fail per(100) ///
			ylab(0(1)5) ///
			xlab(0(5)20)
	}
	if 7 == 0 {
		tab don_relations
	}
	if 8 == 8 {
		g don_female=don_gender=="F"
		replace don_age = don_age - 60
		recode don_race (8=0)(16=1)(2000=2)(24/1999 .=3),gen(don_racecat)
		noi stcox don_age don_female i.don_racecat, basesurv(s0_donor)
		keep s0_donor _t
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
	if 9 == 9 {
		
	}
}
