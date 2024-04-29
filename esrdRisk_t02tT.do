startlog, name("../../esrdRisk/esrdRiskOutput/esrdRiskLogs/esrdRisk_t02tT") 
use "../../esrdRisk/esrdRiskData/esrdRisk_t0.dta",clear
merge 1:1 id using "../../esrdRisk/esrdRiskData/esrdRisk_tT.dta",nogen
drop if inrange(age_t0,99,99)&donor==1
isid pers_id
set more off
replace rSMGJcEdF_d=0  if !inrange(rSMGJcEdF_t,0,15)
replace rSMGJcEdF_t=15 if !inrange(rSMGJcEdF_t,0,15)
replace rSMGJcEdF_t=0.001 if rSMGJcEdF_t==0
replace rSMGJcEdF_t=n2e_t if rSMGJcEdF_x==1
replace rSMGJcEdF_d=n2e_d if rSMGJcEdF_x==1
tab rSMGJcEdF_d rSMGJcEdF_x,mi
replace age_tT=age_t0+rSMGJcEdF_t  
sum pers_id
assert don_age==age_t0 if age_t0<90
assert don_female==female
assert don_race_ethn==race
assert round(_N,1000)==round(15*7618,1000)
assert round(r(max)/10,10^3)==round(7*7618/10,10^3) 
replace pers_id=-1*pers_id 
stset rSMGJcEdF_t,f(rSMGJcEdF_d==1)

label data "Live Kidney Donors + NHANES III Nondonors, Unmatched time_tT + CMS"
save "../../esrdRisk/esrdRiskData/esrdRisk_t02tT.dta",replace

if 0 {
drop if healthy==0
program drop _all
capture log close
capture log using ///
"../../esrdRisk/esrdRiskOutput/esrdRiskTables/esrdRiskTab1.csv", replace
program table1case
gprint_justn, title(" ") byvar(case) restrict(1)
gprint_mean don_age, title("Age") byvar(case) cont printsd
gprint_mean don_agecat, title("AgeCategories") byvar(case) cat
gprint_mean don_female, title("Sex") byvar(case) cat
gprint_mean don_race_eth, title("Race/Ethnicity") byvar(case) cat
gprint_mean don_educat, title("Education") byvar(case) cat 
gprint_mean don_hyperten, title("Hypertension") byvar(case) cat
gprint_mean don_smoke, title("Smoker") byvar(case) cat
gprint_mean don_bmi, title("BMI") byvar(case) cont printsd
gprint_mean don_bmicat, title("BMIcategories") byvar(case) cat
gprint_mean don_bp_preop_syst, title("SBP") byvar(case) cont printsd
gprint_mean don_sbpcat, title("SBPcategories") byvar(case) cat
gprint_mean don_bp_preop_diast, title("DBP") byvar(case) cont printsd
gprint_mean don_dbpcat, title("DBPcategories") byvar(case) cat
gprint_mean creat, title("Creatinine") byvar(case) cont printsd
gprint_mean don_egfr, title("eGFR") byvar(case) cont printsd
gprint_mean don_egfrcat, title("eGFR") byvar(case) cat
gprint_mean don_yearcat, title("Year of Donation") byvar(case) cat
        end
            table1case
}
stcox i.rSMGJcEdF_x don_age don_female i.don_race don_egfr //acr //don_hyperten don_educat don_bmi don_bp_preop_syst

sts graph if rSMGJcEdF_x<3, ///
fail ///
by(rSMGJcEdF_x) ///
plot1opts(col(orange_red)) ///
plot2opts(col(green)) ///
scheme(s1color) ///
ylab(0(10)35, angle(360) format("%2.0f") grid gstyle(dot)) ///
tmax(15) ///
per(10000) ///
legend(off ///
ring(0) ///
col(1) ///
pos(11) ///
lab(1 "NonDonors") ///
lab(2 "Donors") ///
order(2 1)) ///
ti("ESRD events per 10,000", pos(11)) ///
yscale(alt) ///
yti(" ") ///
xti(Years) /// 
ytick(0(10)35) ///
ymtick(0(5)35, grid gstyle(dot)) ///
xlab(0(3)15) ///
xmtick(0(3)15) ///
text(2 14 "p=0.08") /// 
text(33 14.5 "33",col(orange_red)) /// 
text(21 14.5 "20",col(green)) ///
text(31 12.7 "Donors",col(orange_red)) ///
text(16 13.8 "Nondonors",col(green)) ///
risktable(, col(orange_red) order( ///
1 "Donors      "  ///
2 "Nondonors      ") ///
size(3) ///
title(" ", size(4))) ///
risktable(,col(green) group(#2)) 
graph export ///
 "../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tT15.png",replace
sts list if rSMGJcEdF_x<3,by(rSMGJcEdF_x) fail at(1 15)
sts test rSMGJcEdF_x if rSMGJcEdF_x<3
recode don_egfr (min/59=3)(60/89=2)(90/max=1) if !missing(don_egfr),gen(egfr)
label define Egfr 1 "Stage1,>90" 2 "Stage2,60-89" 3 "Stage3,30-59" 
label values egfr Egfr
tab egfr case
mkspline age18_49 50 age50_59 60 age60_90=age_t0
mkspline age18_50 50 age50_90=age_t0
mkspline egfr30_59 60 egfr60_89 90 egfr90_200=don_egfr
mkspline bmi15_24 25 bmi25_29 30 bmi30_60=don_bmi
mkspline bmi15_29 30 bmi30_39 40 bmi40_60=don_bmi
mkspline bmi15_30 30 bmi31_60=don_bmi
mkspline bmi15_25 25 bmi25_34 35 bmi35_60 =don_bmi
gen black=race==2
gen hisp=race==3
foreach var of varlist ///
age18_49 age50_59 age60_90 ///
age18_50 age50_90 ///
egfr30_59 egfr60_89 egfr90_200 ///
bmi15_24 bmi25_29 bmi30_60 ///
bmi15_29 bmi30_39 bmi40_60 ///
bmi15_30 bmi31_60 ///
bmi15_25 bmi25_34 bmi35_60 {
replace `var'=`var'/5
}
local age age18_49 age50_59 age60_90
local agesex `age' female
local agesexrace `agesex' black hisp
local agesexrace_egfrbmi age18_50 age50_90 female black hisp egfr30_59 egfr60_89 egfr90_200 bmi15_30 bmi31_60
local agesexrace_egfr `agesexrace' egfr30_59 egfr60_89 egfr90_200
local bmi bmi15_24 bmi25_29 bmi30_60
stcox case `agesexrace_egfr' bmi15_30 bmi31_60 if rSMGJcEdF_x<3 

if 0 {
stcox case if rSMGJcEdF_x<3 
est store A
stcox case `age' if rSMGJcEdF_x<3 
est store B
stcox case `agesex' if rSMGJcEdF_x<3 
est store C
stcox case `agesexrace' if rSMGJcEdF_x<3 
est store D
stcox case `agesexrace_egfr' if rSMGJcEdF_x<3 
est store E 
stcox case `agesexrace' i.egfr if rSMGJcEdF_x<3 
est store F
stcox case i.don_agecat female i.race i.egfr if rSMGJcEdF_x<3 
est store G
stcox case `agesexrace_egfr' (c.age18_49 c.age50_59 c.age60_90 female)#i.race if rSMGJcEdF_x<3 
est store H
stcox case `agesexrace_egfr' (c.age18_49 c.age50_59 c.age60_90 female)#i.race `bmi' if rSMGJcEdF_x<3 
est store I
stcox case `agesexrace_egfr' `bmi' if rSMGJcEdF_x<3 
est store J
stcox case `agesexrace_egfr' (c.age18_49 c.age50_59 c.age60_90 female)#i.race bmi15_29 bmi30_39 bmi40_60 if rSMGJcEdF_x<3 
est store K
stcox case `agesexrace_egfr' bmi15_29 bmi30_39 bmi40_60 if rSMGJcEdF_x<3 
est store L
stcox case `agesexrace_egfr' bmi15_30 bmi31_60 if rSMGJcEdF_x<3 
est store M
stcox case `agesexrace_egfrbmi' (c.age18_50#case c.age50_90#case female)#i.race if rSMGJcEdF_x<3 
est store N
stcox case `agesexrace_egfr' bmi15_24 bmi25_34 bmi35_60 if rSMGJcEdF_x<3 
est store O
est stat A B C D E F G H I J K L M N O
stcox case `agesexrace_egfr' (c.age18_49 c.age50_59 c.age60_90 female)#i.race `bmi' if rSMGJcEdF_x<3,tvc(case)
stcox case `agesexrace_egfr' bmi15_30 bmi31_60 if rSMGJcEdF_x<3,tvc(case)
lincom case, eform 
lincom case + 8.3*[tvc]case, eform  
capture program drop hr_graph  
program define hr_graph
syntax varname, title(string) [subtitle(string)]
preserve
gen t_r = round(_t,0.1)
gen risk_don = log(1)
gen risk_ll = log(1)
gen risk_ul = log(1)
forvalues i=0(.1)20 {
quietly lincom `varlist' + `i'*[tvc]`varlist'
quietly replace risk_don = log(r(estimate)) if abs(`i'-t_r)<0.001
local beta = log(r(estimate))
qui replace risk_ll=`beta'+invnormal(0.025)*r(se) if abs(`i'-t_r)<0.001
qui replace risk_ul=`beta'+invnormal(0.975)*r(se) if abs(`i'-t_r)<0.001
}

foreach v of varlist risk* {
replace `v' = exp(`v')
}
replace risk_ul = . if risk_ul > 9
graph twoway line risk* t_r if t_r <=15, sort ///
scheme(s1color) ///
lcolor (black black black) lpattern(solid dash dash) legend(off) ///
xtitle("Years since donation") ///
ti("Hazard Ratio, 95%CI",pos(11)) ///
ylab(0 "1" 1 "3" 2 "8" 3 "20" 4 "50" 5 "150" 6 "400" 7 "1000" 8 "3000" 9 "8000", ///
angle(360) format("%2.0f") grid gstyle(dot)) ///
title("`Risk of ESRD in Donors vs. Nondonors'") ///
subtitle("`Cox Regression'")
end  
hr_graph case, title("Hazard Ratio, 95%CI")
graph export "../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tTcoxtvar.png",replace  
}

merge 1:m pers_id ///
 using "../../esrd99/esrd99output/esrd99match/matched_nh3donors.dta", ///
 nogen keep(matched)
stset rSMGJcEdF_t if rSMGJcEdF_x<3,f(rSMGJcEdF_d==1)
sts graph , ///
fail ///
by(rSMGJcEdF_x) ///
plot1opts(col(orange_red)) ///
plot2opts(col(green)) ///
scheme(s1color) ///
ylab(0(10)35, angle(360) format("%2.0f") grid gstyle(dot)) ///
tmax(15) ///
per(10000) ///
legend(off ///
ring(0) ///
col(1) ///
pos(11) ///
lab(1 "NonDonors") ///
lab(2 "Donors") ///
order(2 1)) ///
ti("ESRD events per 10,000", pos(11)) ///
yscale(alt) ///
yti(" ") ///
xti(Years) /// 
ytick(0(10)35) ///
ymtick(0(5)35, grid gstyle(dot)) ///
xlab(0(3)15) ///
xmtick(0(3)15) ///
text(33 14.5 "33",col(orange_red)) ///
text(6 14.5 "5",col(green)) ///
text(31 12.7 "Donors",col(orange_red)) ///
text(2.7 9 "Nondonors",col(green)) ///
risktable(, col(orange_red) order( ///
1 " "  ///
2 " ") ///
size(3) ///
title(" ", size(4))) ///
risktable(,col(green) group(#2)) 
graph export "../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tTier.png",replace
sts list ,by(rSMGJcEdF_x) fail at(1 15)
stcox case if rSMGJcEdF_x<3 

//black
stset rSMGJcEdF_t if rSMGJcEdF_x<3&don_race_ethn==2,f(rSMGJcEdF_d==1)
sts graph , ///
fail ///
by(rSMGJcEdF_x) ///
plot1opts(col(orange_red)) ///
plot2opts(col(green)) ///
scheme(s1color) ///
ylab(0(20)60, angle(360) format("%2.0f") grid gstyle(dot)) ///
tmax(15) ///
per(10000) ///
legend(off ///
ring(0) ///
col(1) ///
pos(11) ///
lab(1 "NonDonors") ///
lab(2 "Donors") ///
order(2 1)) ///
ti("Black", pos(11)) ///
yscale(alt) ///
yti(" ") ///
xti(Years) /// 
ytick(0(20)60) ///
ymtick(0(20)60, grid gstyle(dot)) ///
xlab(0(6)15) ///
xmtick(0(3)15) /// text(33 14.5 "33",col(orange_red)) /// text(6 14.5 "5",col(green)) /// text(31 12.7 "Donors",col(orange_red)) /// text(2.7 9 "Nondonors",col(green)) ///
risktable(, col(orange_red) order( ///
1 " "  ///
2 " ") ///
size(3) ///
title(" ", size(4))) ///
risktable(,col(green) group(#2)) 
graph save "../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tTblack.gph",replace
sts list if rSMGJcEdF_x<3&don_race_ethn==2,by(rSMGJcEdF_x) fail at(1 15) //33 attRisk

//

//hispanic
stset rSMGJcEdF_t if rSMGJcEdF_x<3&don_race_ethn==3,f(rSMGJcEdF_d==1)
sts graph , ///
fail ///
by(rSMGJcEdF_x) ///
plot1opts(col(orange_red)) ///
plot2opts(col(green)) ///
scheme(s1color) ///
ylab(0(20)60, angle(360) format("%2.0f") grid gstyle(dot)) ///
tmax(15) ///
per(10000) ///
legend(off ///
ring(0) ///
col(1) ///
pos(11) ///
lab(1 "NonDonors") ///
lab(2 "Donors") ///
order(2 1)) ///
ti("Hispanic", pos(11)) ///
yscale(alt) ///
yti(" ") ///
xti(Years) /// 
ytick(0(20)60) ///
ymtick(0(20)60, grid gstyle(dot)) ///
xlab(0(6)15) ///
xmtick(0(3)15) /// text(33 14.5 "33",col(orange_red)) /// text(6 14.5 "5",col(green)) /// text(31 12.7 "Donors",col(orange_red)) /// text(2.7 9 "Nondonors",col(green)) ///
risktable(, col(orange_red) order( ///
1 " "  ///
2 " ") ///
size(3) ///
title(" ", size(4))) ///
risktable(,col(green) group(#2)) 
graph save "../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tThisp.gph",replace
sts list if rSMGJcEdF_x<3&don_race_ethn==3,by(rSMGJcEdF_x) fail at(1 15) //22 attRisk

//

//white
stset rSMGJcEdF_t if rSMGJcEdF_x<3&don_race_ethn==1,f(rSMGJcEdF_d==1)
sts graph , ///
fail ///
by(rSMGJcEdF_x) ///
plot1opts(col(orange_red)) ///
plot2opts(col(green)) ///
scheme(s1color) ///
ylab(0(20)60, angle(360) format("%2.0f") grid gstyle(dot)) ///
tmax(15) ///
per(10000) ///
legend(off ///
ring(0) ///
col(1) ///
pos(11) ///
lab(1 "NonDonors") ///
lab(2 "Donors") ///
order(2 1)) ///
ti("White", pos(11)) ///
yscale(alt) ///
yti(" ") ///
xti(Years) /// 
ytick(0(20)60) ///
ymtick(0(20)60, grid gstyle(dot)) ///
xlab(0(6)15) ///
xmtick(0(3)15) /// text(33 14.5 "33",col(orange_red)) /// text(6 14.5 "5",col(green)) /// text(31 12.7 "Donors",col(orange_red)) /// text(2.7 9 "Nondonors",col(green)) ///
risktable(, col(orange_red) order( ///
1 " "  ///
2 " ") ///
size(3) ///
title(" ", size(4))) ///
risktable(,col(green) group(#2)) 
graph save "../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tTwhite.gph",replace
sts list if rSMGJcEdF_x<3&don_race_ethn==1,by(rSMGJcEdF_x) fail at(1 15) //27 attRisk

//

graph combine ///
"../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tTblack.gph" ///
"../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tThisp.gph" ///
"../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tTwhite.gph" ///
, row(1) ti("ESRD events per 10,000") scheme(s1color)
graph export "../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tTrace.png",replace

if 0 {
stcox case if rSMGJcEdF_x<3,tvc(case)
lincom case, eform 
lincom case + 7.6*[tvc]case, eform  
capture program drop hr_graph  
program define hr_graph
syntax varname, title(string) [subtitle(string)]
preserve
gen t_r = round(_t,0.1)
gen risk_don = log(1)
gen risk_ll = log(1)
gen risk_ul = log(1)
forvalues i=0(.1)20 {
quietly lincom `varlist' + `i'*[tvc]`varlist'
quietly replace risk_don = log(r(estimate)) if abs(`i'-t_r)<0.001
local beta = log(r(estimate))
qui replace risk_ll=`beta'+invnormal(0.025)*r(se) if abs(`i'-t_r)<0.001
qui replace risk_ul=`beta'+invnormal(0.975)*r(se) if abs(`i'-t_r)<0.001
}
foreach v of varlist risk* {
replace `v' = exp(`v')
}
replace risk_ul = . if risk_ul > 9
graph twoway line risk* t_r if t_r <=15, sort ///
scheme(s1color) ///
lcolor (black black black) lpattern(solid dash dash) legend(off) ///
xtitle("Years since donation") ///
ti("Hazard Ratio, 95%CI",pos(11)) ///
ylab(0 "1" 1 "3" 2 "8" 3 "20" 4 "50" 5 "150" 6 "400" 7 "1000" 8 "3000" 9 "8000", ///
angle(360) format("%2.0f") grid gstyle(dot)) ///
title("`Risk of ESRD in Donors vs. Nondonors'") ///
subtitle("`Cox Regression'")
end  
hr_graph case, title("Hazard Ratio, 95%CI")
graph export "../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tTcoxtvar_ier.png",replace
}
 
use  "../../esrd99/esrd99output/esrd99match/matched_nh3donors2.dta" ///
 if case==0, clear
set more off
gen risk_t0=3
append using ///
    "../../esrd99/esrd99output/esrd99match/matched_nh3donors.dta" 
gen id=_n
merge m:1 pers_id using "../../esrdRisk/esrdRiskData/esrdRisk_t02tT.dta",nogen
duplicates drop id,force
replace age_tT=age_t0+rSMGJcEdF_t
replace risk_t0=2 if missing(risk_t0)&case==0
replace risk_t0=1 if case==1
label define Risk_t0 1 "donors" 2 "healthy nondonors" 3 "unscreened nondonors"
label values risk_t0 Risk_t0
tab risk_t0
stset rSMGJcEdF_t,f(rSMGJcEdF_d==1)
sts graph , ///
fail ///
by(risk_t0) ///
plot1opts(col(blue)) ///
plot2opts(col(orange_red)) ///
plot3opts(col(green)) ///
scheme(s1color) ///
ylab(0(20)60, angle(360) format("%2.0f") grid gstyle(dot)) ///
tmax(15) ///
per(10000) ///
legend(off ///
ring(0) ///
col(1) ///
pos(11) ///
lab(1 "NonDonors") ///
lab(2 "Donors") ///
order(3 1 2)) ///
ti("ESRD per 10,000", pos(11)) ///
yscale(alt) ///
yti(" ") ///
xti(Years) /// 
ytick(0(20)60) ///
ymtick(0(10)60, grid gstyle(dot)) ///
xlab(0(3)15) ///
xmtick(0(3)15) ///
text(60 15 "57",col(green)) ///
text(34 15 "33",col(blue)) ///
text(7 15 "5",col(orange_red)) ///
text(60 11.8 "Unscreened Nondonors",col(green)) ///
text(34 13.3 "Live Donors",col(blue)) ///
text(6.7 12.5 "Healthy Nondonors",col(orange_red)) ///
risktable(, col(blue) order( ///
3 "      "  ///
1 "       "  ///
2 "      ") ///
size(3) ///
title(" ", size(4))) ///
risktable(,col(green) group(#2)) ///
risktable(,col(orange_red) group(#3)) 
sts list,by(risk_t0) fail at(1 15)
graph export "../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t02tT15.png",replace
stset age_tT if age_tT>=20,entry(age_t0) f(rSMGJcEdF_d==1)
tab risk_t0 rSMGJcEdF_d
sts graph if age_tT>=20, ///
noorigin ///
fail ///
by(risk_t0) ///
plot1opts(col(blue)) ///
plot2opts(col(orange_red)) ///
plot3opts(col(green)) ///
scheme(s1color) ///
ylab(0(100)320, angle(360) format("%2.0f") grid gstyle(dot)) ///
tmax(80) ///
per(10000) ///
legend(off ///
ring(0) ///
col(1) ///
pos(11) ///
lab(1 "Donors") ///
lab(2 "Healthy Nondonors") ///
lab(3 "Unscreened Nondonors") ///
order(3 1 2)) ///
ti("ESRD per 10,000", pos(11)) ///
yscale(alt) ///
yti(" ") ///
xti(Age) /// 
ytick(0(50)320) ///
ymtick(0(50)320, grid gstyle(dot)) ///
xlab(20(10)80) ///
xmtick(20(10)80) ///
text(290 79 "317",col(green)) ///
text(77 78 "89",col(blue)) ///
text(6 78 "16",col(orange_red)) ///
text(315 69 "Unscreened nondonors",col(green)) ///
text(105 75 "Live donors",col(blue)) ///
text(30 70 "Healthy nondonors",col(orange_red)) ///
risktable(, col(blue) order( ///
3 "       "  ///
1 "       "  ///
2 "       ") ///
size(3) ///
title(" ", size(4))) ///
risktable(,col(orange_red) group(#2)) ///
risktable(,col(green) group(#3)) 
sts list if age_tT>=20,by(risk_t0) fail at(50 60 80)
graph export "../../esrdRisk/esrdRiskOutput/esrdRiskFigures/esrdRisk_t202tT80.png",replace
log close

