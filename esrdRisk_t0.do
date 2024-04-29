startlog, name("../../esrdRisk/esrdRiskOutput/esrdRiskLogs/esrdRisk_t0")    
use "../../nchsVisit/nh3oct17/nh3oct17input/nh3seqn.dta",clear
quietly sum seqn
assert round(r(max)/10,10^3)==round(7*7618/10,10^3)
use "../../esrd99/esrd99data/nondon_baseline+.dta",clear
use "../../esrd99/esrd99data/don_baseline+.dta",clear
use  "../../esrd99/esrd99output/esrd99match/nh3donors4match.dta",clear
assert round(_N,10^3)==round(15*7618,10^3)
replace pers_id=-1*pers_id
sort pers_id
tab donor
gen id=_n

label data "Live Kidney Donors + NHANES III Nondonors, Unmatched time_t0"

save "../../esrdRisk/esrdRiskData/esrdRisk_t0.dta",replace
log close

