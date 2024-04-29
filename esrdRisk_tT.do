startlog, name("../../esrdRisk/esrdRiskOutput/esrdRiskLogs/esrdRisk_tT")    
use "../../nchsVisit/nh3oct30/output1oct30/nh3don_cox.dta",clear
tab case healthy,mi
compare N2e_d N2e_t
gen rSMGJcEdF_t0=N2e_d*7618
gen rSMGJcEdF_tT=N2e_t*7618
format rSMGJcEdF_t0 %td
format rSMGJcEdF_tT %td
gen rSMGJcEdF_t=(rSMGJcEdF_tT-rSMGJcEdF_t0)/365.25
assert round(rSMGJcEdF_t,1/234.56789)==round(neph2esrd_t,1/234.56789)
rename neph2esrd_d rSMGJcEdF_d
replace rSMGJcEdF_d=0 if rSMGJcEdF_t<0
replace rSMGJcEdF_tT=rSMGJcEdF_t0+1 if rSMGJcEdF_t<=0
replace rSMGJcEdF_t=.001 if rSMGJcEdF_t<0
gen     rSMGJcEdF_x=1 if case==1
replace rSMGJcEdF_x=2 if case==0&healthy==1
replace rSMGJcEdF_x=3 if case==0&healthy==0
label define rSMGJcEdF0618 1 "rSM" 2 "GJc" 3 "EdF"
label values rSMGJcEdF_x rSMGJcEdF0618
gen age_t0=don_age
gen age_tT=age_t0+rSMGJcEdF_t
gen female=don_female
gen race=don_race_ethn
keep rSMGJcEdF* age_t* female race 
assert round(_N,10^3)==round(15*7618,10^3)
tab rSMGJcEdF_x 
gen id=_n

label data "Live Kidney Donors + Unmatched Nondonors, censored/ESRD/died"

compress
save "../../esrdRisk/esrdRiskData/esrdRisk_tT.dta",replace
log close

