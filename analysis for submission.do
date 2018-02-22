/* analysis for apsa2015 */

clear all
set more off 

*cd "C:\Users\bradym\Dropbox\ASPA2015"
*cd "C:\Users\brady\Dropbox\ASPA2015"
cd "/Users/bradym/Dropbox/ASPA 2015"

/*
*Only need to run this commented section building the separate H and S files once 

use "Votes and Awards 6-3-2016.dta"
drop if senate==1

gen votesap=.
replace votesap=1 if support==1 & vote==1
replace votesap=1 if support==0 & vote==-1
replace votesap=0 if support==1 & vote==-1
replace votesap=0 if support==0 & vote==1
tab votesap


gen rolltime=.
replace rolltime=voteview if cong==111 & senate==0
replace rolltime=voteview+1647 if cong==112 & senate==0
replace rolltime=voteview+3249 if cong==113 & senate==0
su rolltime

gen lnmoney=ln(money+1)
gen money10k=money/10000
gen money100k=money/100000
gen absdw1=abs(dwnom1)

gen dem=party
recode dem 100=1 200=0 328=1

sort cong voteview
merge cong voteview using "hdemrep111-113.dta"
tab _merge /*no problems */
drop _merge

gen votewithdemmaj=.
replace votewithdemmaj=1 if demmaj==1 & vote==1
replace votewithdemmaj=1 if demmaj==0 & vote==-1
replace votewithdemmaj=0 if demmaj==1 & vote==-1
replace votewithdemmaj=0 if demmaj==0 & vote==1

tab votewithdemmaj

**the commented code below gens the DV for the "fake obama" votes
* this had to be changed with new master file since the obama votes somehow lost the old state code, so now searching based upon name.

gen placeholder=.
forval i=1/4451	{
	qui su vote if name=="OBAMA      " & rolltime==`i'
	qui replace placeholder=r(mean) if rolltime==`i'
	}

tab placeholder 

recode placeholder 0=.
gen vote2=vote
recode vote2 0=.
	
gen voteobama=.
replace voteobama=1 if placeholder==1 & vote2==1
replace voteobama=1 if placeholder==-1 & vote2==-1
replace voteobama=0 if placeholder==1 & vote2==-1
replace voteobama=0 if placeholder==-1 & vote2==1


save housedata_full6-3-16_temp.dta, replace /*everything above this save can be commented out once run*/


use "Votes and awards 6-3-2016.dta"
drop if senate==0

*use "senate_votes_and_awards.dta

gen votesap=.
replace votesap=1 if support==1 & vote==1
replace votesap=1 if support==0 & vote==-1
replace votesap=0 if support==1 & vote==-1
replace votesap=0 if support==0 & vote==1
tab votesap


gen rolltime=.
replace rolltime=voteview if cong==111 & senate==1
replace rolltime=voteview+696 if cong==112 & senate==1
replace rolltime=voteview+1182 if cong==113 & senate==1
su rolltime

gen lnmoney=ln(money+1)
gen absdw1=abs(dwnom1)
gen money10k=money/10000
gen money100k=money/100000
gen dem=party
recode dem 100=1 200=0 328=1


sort cong voteview
merge cong voteview using "sdemrep111-113.dta"
tab _merge /*no problems */
drop _merge

gen votewithdemmaj=.
replace votewithdemmaj=1 if demmaj==1 & vote==1
replace votewithdemmaj=1 if demmaj==0 & vote==-1
replace votewithdemmaj=0 if demmaj==1 & vote==-1
replace votewithdemmaj=0 if demmaj==0 & vote==1

tab votewithdemmaj


gen placeholder=.
forval i=1/1839	{
	qui su vote if name=="OBAMA      " & rolltime==`i'
	qui replace placeholder=r(mean) if rolltime==`i'
	}
	
	
recode placeholder 0=.
gen vote2=vote
recode vote2 0=.
	
gen voteobama=.
replace voteobama=1 if placeholder==1 & vote2==1
replace voteobama=1 if placeholder==-1 & vote2==-1
replace voteobama=0 if placeholder==1 & vote2==-1
replace voteobama=0 if placeholder==-1 & vote2==1

save senatedata_full6-3-16.dta, replace


*** Need to add back in census, election, and Jake's variables on hopsitals and whatnot after rerunning

use housedata_full6-3-16_temp.dta, clear
sort idno rolltime 
merge 1:1 idno rolltime using "housedata_full3-30-16.dta"
tab _merge
drop _merge
save housedata_full6-3-16.dta, replace
*/


****************************************************************
/*analysis*/

**** HOUSE analysis

use housedata_full6-3-16.dta, clear

xtset idno rolltime

* gen non logged money measure
gen money10m=money/10000000

* gen grape's health care demand action
gen MedicalFac=hospitals + medicalcenters + homehealthservices + fqhc

* make electoral win margin
gen voteshare=.
replace voteshare=dv if dem==1
replace voteshare=100-dv if dem==0

* gen electoral safety
gen marginality=abs(voteshare-50)

* identify whether rc in question was close
gen votewinmargin=abs(yeas-nays)
gen closevote=0
replace closevote=1 if votewinmargin<=20

*gen whether rc was a pty line vote with 50/50 threshhold
gen demvotes=demyeas+demnays
gen repvotes=repyeas+repnays
gen majdemyea=0
replace majdemyea=1 if demyeas/demvotes>=.5
gen majdemnay=0
replace majdemnay=1 if demnays/demvotes>=.5
gen majrepyea=0
replace majrepyea=1 if repyeas/repvotes>=.5
gen majrepnay=0
replace majrepnay=1 if repnays/repvotes>=.5

gen ptyvote50=0
replace ptyvote50=1 if majdemyea==1 & majrepnay==1
replace ptyvote50=1 if majdemnay==1 & majrepyea==1

*wash and repeat for a 90/90 threshhold
gen majdemyea90=0
replace majdemyea90=1 if demyeas/demvotes>=.9
gen majdemnay90=0
replace majdemnay90=1 if demnays/demvotes>=.9
gen majrepyea90=0
replace majrepyea90=1 if repyeas/repvotes>=.9
gen majrepnay90=0
replace majrepnay90=1 if repnays/repvotes>=.9

gen ptyvote90=0
replace ptyvote90=1 if majdemyea90==1 & majrepnay90==1
replace ptyvote90=1 if majdemnay90==1 & majrepyea90==1

* gen whether member voted with their pty
gen votewithpty=.
replace votewithpty=1 if dem==1 & vote==1 & majdemyea==1
replace votewithpty=1 if dem==1 & vote==-1 & majdemnay==1
replace votewithpty=1 if dem==0 & vote==1 & majrepyea==1
replace votewithpty=1 if dem==0 & vote==-1 & majrepnay==1

* need to fix the alt DV of whether vote as with demmaj - this section should do that
drop votewithdemmaj
gen votewithdemmaj=.
replace votewithdemmaj=1 if vote==1 & majdemyea==1
replace votewithdemmaj=1 if vote==-1 & majdemnay==1
replace votewithdemmaj=0 if vote==1 & majdemnay==1
replace votewithdemmaj=0 if vote==-1 & majdemyea==1

* House dem analysis - final models in consult with jake

* gen altdw1 for dems to ease interp
gen altdwnom1=.
su dwnom1 if dem==1
replace altd=abs(dwnom1-r(max)) if dem==1
su altd

* gen a categorical for dwnom1 to help with visuals and diagnostic
gen ideotype=.
su dwnom1 if dem==1, d
replace ideotype=1 if dwnom1<-.469 & dem==1
replace ideotype=2 if dwnom1>-.469 & dwnom1<-.288 & dem==1
replace ideotype=3 if dwnom1>=-.288 & dem==1
su dwnom1 if dem==0, d
replace ideotype=4 if dwnom1<=.375 & dem==0
replace ideotype=5 if dwnom1>.375 & dwnom1<.606 & dem==0
replace ideotype=6 if dwnom1>=.606 & dwnom1!=. & dem==0
label define ideo 1 "SL" 2 "L" 3 "WL" 4 "WC" 5 "C" 6 "SC"
label values ideotype ideo 
tab ideotype

tab dem votesap if (passage==1 | agree==1) & cong<113, row
tab dem voteobama if (passage==1 | agree==1) & cong<113, row
tab dem votewithdem if (passage==1 | agree==1) & cong<113, row

* given that amendment votes are also inadvertently included in the agreeto typology create a dummy to single out the specific votes for analysis
gen analyze=0
replace analyze=1 if passage==1
replace analyze=1 if agreeto==1 & amendment1==0 & amendment2==0
tab analyze
tab analyze if votesap==1
tab analyze if voteobama==1

/*
** look at full model with threeway interacion incl. party.  (if models conditioned on party, have to exclude cong for convergence) this approach seems to get some sig results.
logit votesap c.lnmoney##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)
*model fitness
estat class
lroc

*** run margins for dems and dwnom values in the dem range (essentially replciates dem panel of original figure but for new model)
margins, at(lnmoney=(0(1)23) dwnom1=(-.65 -.35 .05) dem=1 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate forbornpct dpres MedicalFac age65pct manufpct unemployedpct medianinc ) l(90)

marginsplot, scheme(s1color) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) /// 
    title("Democrats") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23) xtitle("ln(ARRA$)") /// 
	plot1opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot3opts(mc(red) lc(red)) /// 
	ci1opts(lc(blue)) ci2opts(lc(green)) ci3opts(lc(red)) /// 
	name(g1)
	
marginsplot, scheme(s1mono) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) ///
    title("Democrats") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23) xtitle("ln(ARRA$)") ///  
	plot1opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot3opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci1opts(lc(gs1)) ci2opts(lc(gs5)) ci3opts(lc(gs9)) /// 
	name(bw1)
	
graph display g1
graph save "hdemmargins_color.gph", replace
graph export "hdemmargins_color.emf", as(emf) replace

graph display bw1
graph save "hdemmargins_bw.gph", replace
graph export "hdemmargins_bw.emf", as(emf) replace
	
margins, at(lnmoney=(0(1)23) dwnom1=(.25 .5 .8) dem=0 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate dpres MedicalFac age65pct manufpct unemployedpct medianinc forbornpct) l(90)

marginsplot, scheme(s1color) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) /// 
    title("Republicans") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23) xtitle("ln(ARRA$)") /// 
	plot3opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot1opts(mc(red) lc(red)) /// 
	ci3opts(lc(blue)) ci2opts(lc(green)) ci1opts(lc(red)) /// 
	name(g2)

marginsplot, scheme(s1mono) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) ///
	title("Republicans") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23) xtitle("ln(ARRA$)")  /// 
	plot3opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot1opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci3opts(lc(gs1)) ci2opts(lc(gs5)) ci1opts(lc(gs9)) /// 
	name(bw2)	
	
graph display g2
graph save "hgopmargins_bw.gph", replace
graph export "hgopmargins_color.emf", as(emf) replace

graph display bw2
graph save "hgopmargins_bw.gph", replace
graph export "hgopmargins_bw.emf", as(emf) replace

*combine house margins graphs
grc1leg g1 g2, scheme(s1color) note("90% confidence intervals")
graph save "housemargins_color.gph", replace
graph export "housemargins_color.emf", as(emf) replace

grc1leg bw1 bw2, scheme(s1mono) note("90% confidence intervals")
graph save "housemargins_bw.gph", replace
graph export "housemargins_bw.emf", as(emf) replace

*/
*check for robustness with awards
/*
logit votesap c.awards##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)
outreg2 using "house awards", word auto(2) replace
*logit votesap c.awards##c.dwnom1 clarity vetothreat i.cong Cardinal Approps dpres hospital unemployedpct medianinc forbornpct latinopct blackpct if (passage==1 |agreeto==1) & dem==0 & senate==0, cluster(idno)
*outreg2 using "house awards", word auto(2)

estat class
lroc

* Note that some key coeffs in the awards model change direction and sig.  Need to look at margins again:
margins, at(awards=(0(100)1400) dwnom1=(-.65 -.35 .05) dem=1 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate dpres MedicalFac age65pct manufpct unemployedpct medianinc forbornpct) l(90)

marginsplot, scheme(s1color) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) /// 
    title("Democrats") ytitle("Predicted pr(Vote with Obama)") xlabel(0(200)1400) xtitle("# of ARRA Awards") /// 
	plot1opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot3opts(mc(red) lc(red)) /// 
	ci1opts(lc(blue)) ci2opts(lc(green)) ci3opts(lc(red)) /// 
	name(a1)
	
marginsplot, scheme(s1mono) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) ///
    title("Democrats") ytitle("Predicted pr(Vote with Obama)") xlabel(0(200)1400) xtitle("# of ARRA Awards")  ///  
	plot1opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot3opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci1opts(lc(gs1)) ci2opts(lc(gs5)) ci3opts(lc(gs9)) /// 
	name(a_bw1)
	
graph display a1
graph save "hdemmargins-awards_color.gph", replace
graph export "hdemmargins-awards_color.emf", as(emf) replace

graph display a_bw1
graph save "hdemmargins-awards_bw.gph", replace
graph export "hdemmargins-awards_bw.emf", as(emf) replace
	
margins, at(awards=(0(100)1700) dwnom1=(.25 .5 .8) dem=0 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate dpres MedicalFac age65pct manufpct unemployedpct medianinc forbornpct) l(90)

marginsplot, scheme(s1color) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) /// 
    title("Republicans") ytitle("Predicted pr(Vote with Obama)") xlabel(0(200)1700) xtitle("# of ARRA Awards") /// 
	plot3opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot1opts(mc(red) lc(red)) /// 
	ci3opts(lc(blue)) ci2opts(lc(green)) ci1opts(lc(red)) /// 
	name(a2)

marginsplot, scheme(s1mono) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) ///
	title("Republicans") ytitle("Predicted pr(Vote with Obama)") xlabel(0(200)1700)  xtitle("# of ARRA Awards") /// 
	plot3opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot1opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci3opts(lc(gs1)) ci2opts(lc(gs5)) ci1opts(lc(gs9)) /// 
	name(a_bw2)	
	
graph display a2
graph save "hgopmargins-awards_bw.gph", replace
graph export "hgopmargins_color-awards.emf", as(emf) replace

graph display a_bw2
graph save "hgopmargins-awards_bw.gph", replace
graph export "hgopmargins-awards_bw.emf", as(emf) replace

*combine house margins graphs
grc1leg a1 a2, scheme(s1color) note("90% confidence intervals")
graph save "housemargins-awards_color.gph", replace
graph export "housemargins-awards_color.emf", as(emf) replace

grc1leg a_bw1 a_bw2, scheme(s1mono) note("90% confidence intervals")
graph save "housemargins-awards_bw.gph", replace
graph export "housemargins-awards_bw.emf", as(emf) replace
*check RE models for robustness


xtlogit votesap c.lnmoney##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, re
outreg2 using "RE", word replace
estimates store reefects
*xtlogit votesap c.lnmoney##c.dwnom1 clarity vetothreat i.cong Cardinal Approps dpres hospital unemployedpct medianinc forbornpct latinopct blackpct if (passage==1 |agreeto==1) & dem==1 & senate==0, re
*outreg2 using "houseRE", word
*estimates store regop

**** Robustness with other DVs

*obama vote
logit voteobama c.lnmoney##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)

* demmaj
logit votewithdem c.lnmoney##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)
margins, at(lnmoney=(0(1)23) dwnom1=(-.65 -.35 .05) dem=1 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate forbornpct dpres MedicalFac age65pct manufpct unemployedpct medianinc ) l(90)

marginsplot, scheme(s1color) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) /// 
    title("Democrats") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23) xtitle("ln(ARRA$)") /// 
	plot1opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot3opts(mc(red) lc(red)) /// 
	ci1opts(lc(blue)) ci2opts(lc(green)) ci3opts(lc(red)) /// 
	name(b1)
	
marginsplot, scheme(s1mono) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) ///
    title("Democrats") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23) xtitle("ln(ARRA$)") ///  
	plot1opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot3opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci1opts(lc(gs1)) ci2opts(lc(gs5)) ci3opts(lc(gs9)) /// 
	name(b_bw1)
	
graph display b1
graph save "vw_hdemmargins_color.gph", replace
graph export "vw_hdemmargins_color.emf", as(emf) replace

graph display b_bw1
graph save "vw_hdemmargins_bw.gph", replace
graph export "vw_hdemmargins_bw.emf", as(emf) replace
	
margins, at(lnmoney=(0(1)23) dwnom1=(.25 .5 .8) dem=0 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate dpres MedicalFac age65pct manufpct unemployedpct medianinc forbornpct) l(90)

marginsplot, scheme(s1color) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) /// 
    title("Republicans") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23) xtitle("ln(ARRA$)") /// 
	plot3opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot1opts(mc(red) lc(red)) /// 
	ci3opts(lc(blue)) ci2opts(lc(green)) ci1opts(lc(red)) /// 
	name(b2)

marginsplot, scheme(s1mono) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) ///
	title("Republicans") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23) xtitle("ln(ARRA$)")  /// 
	plot3opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot1opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci3opts(lc(gs1)) ci2opts(lc(gs5)) ci1opts(lc(gs9)) /// 
	name(b_bw2)	
	
graph display b2
graph save "vw_hgopmargins_bw.gph", replace
graph export "vw_hgopmargins_color.emf", as(emf) replace

graph display b_bw2
graph save "vw_hgopmargins_bw.gph", replace
graph export "vw_hgopmargins_bw.emf", as(emf) replace

*combine house margins graphs
grc1leg b1 b2, scheme(s1color) note("90% confidence intervals")
graph save "vw_housemargins_color.gph", replace
graph export "vw_housemargins_color.emf", as(emf) replace

grc1leg b_bw1 b_bw2, scheme(s1mono) note("90% confidence intervals")
graph save "vw_housemargins_bw.gph", replace
graph export "vw_housemargins_bw.emf", as(emf) replace


*/



*check FE model for robustness

*xtlogit votesap c.lnmoney##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, fe
*** The FE models won't run because too many parameters and effective # of obs



* try manually with member fixed effects
*logit votesap c.lnmoney##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct i.idno if analyze==1


**FE wont converge under many different specs; the manual doesn't either...
**It does converge on obamvotes
*logit voteobama c.lnmoney##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong i.idno if analyze==1

* unfortunately without the fe model it is impossible to run a hausman test -- still robustness check is good to note


***** Other figures
/*

collapse (mean) lnmoney awards cong, by(dem rcdate)
egen lnmoneyavg=mean(lnmoney), by(dem rcdate)
sort rcdate
twoway (line lnmoneyavg rcdate if dem==0 & cong<113, lc(red)) (line lnmoneyavg rcdate if dem==1 & cong<113, lc(blue)), nodraw name(a1) xtitle("Roll Call Date") title("ARRA Receipts") ytitle("Average ln(ARRA Receipts)") scheme(s1color) legend(label(1 "Republicans") label(2 "Democrats"))
twoway (line lnmoneyavg rcdate if dem==0 & cong<113, l(solid)) (line lnmoneyavg rcdate if dem==1 & cong<113, l(dash)), nodraw name(b1) xtitle("Roll Call Date") title("ARRA Receipts") ytitle("Average ln(ARRA Receipts)") scheme(s1mono) legend(label(1 "Republicans") label(2 "Democrats"))

egen awardsavg=mean(awards), by(dem rcdate)
sort rcdate
twoway (line awardsavg rcdate if dem==0 & cong<113, lc(red)) (line awardsavg rcdate if dem==1 & cong<113, lc(blue)), nodraw name(a2) xtitle("Roll Call Date") title("ARRA Awards") ytitle("Average ARRA Awards") scheme(s1color) legend(label(1 "Republicans") label(2 "Democrats"))
twoway (line awardsavg rcdate if dem==0 & cong<113, l(solid)) (line awardsavg rcdate if dem==1 & cong<113, l(dash)), nodraw name(b2) xtitle("Roll Call Date") title("ARRA Awards") ytitle("Average ARRA Awards") scheme(s1mono) legend(label(1 "Republicans") label(2 "Democrats"))
grc1leg a1 a2, scheme(s1color)
graph export "C:\Users\brady\Dropbox\ASPA2015\houseaverages_color.emf", as(emf) replace
grc1leg  b1 b2, scheme(s1mono)
graph export "C:\Users\brady\Dropbox\ASPA2015\houseaverages_bw.emf", as(emf) replace
 */

/*
 keep if analyze==1 & cong<113
 egen votetime=group(rolltime)
 egen votetime2=group(rolltime) if sapid!=.

 
 gen demXdw1=dem*dwnom1
 gen demXmoney=dem*lnmoney
 gen moneyXdw1=lnmoney*dwnom1
 gen demXmoneyXdw1=dem*dwnom1*lnmoney
/*
 forval i=3/3248	{
	display "rolltime=`i'"
	qui su votesap if rolltime==`i'
	if r(N)==0	{
		continue
		}
	else {
		qui capture logit votesap lnmoney dwnom1 dem demXmoney demXdw1 demXmoneyXdw1 Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if rolltime==`i'
			if _rc!=0	{
			qui	gen perfect`i'=1 if rolltime==`i'
			continue
			}
		else	{
			qui gen b_lnmoney`i'=_b[lnmoney] if rolltime==`i'
			qui gen se_lnmoney`i'=_se[lnmoney] if rolltime==`i'
			qui gen max_lnmoney`i'=_b[lnmoney]+(1.64*_se[lnmoney]) if rolltime==`i'
			qui gen min_lnmoney`i'=_b[lnmoney]-(1.64*_se[lnmoney]) if rolltime==`i'
			qui gen b_dw1`i'=_b[dwnom1] if rolltime==`i'
			qui gen se_dw1`i'=_se[dwnom1] if rolltime==`i'
			qui gen max_dw1`i'=_b[dwnom1]+(1.64*_se[dwnom1]) if rolltime==`i'
			qui gen min_dw1`i'=_b[dwnom1]-(1.64*_se[dwnom1]) if rolltime==`i'
			qui gen b_dem`i'=_b[dem] if rolltime==`i'
			qui gen se_dem`i'=_se[dem] if rolltime==`i'
			qui gen max_dem`i'=_b[dem]+(1.64*_se[dem]) if rolltime==`i'
			qui gen min_dem`i'=_b[dem]-(1.64*_se[dem]) if rolltime==`i'
			qui gen b_demXmoney`i'=_b[demXmoney] if rolltime==`i'
			qui gen se_demXmoney`i'=_se[demXmoney] if rolltime==`i'
			qui gen max_demXmoney`i'=_b[demXmoney]+(1.64*_se[demXmoney]) if rolltime==`i'
			qui gen min_demXmoney`i'=_b[demXmoney]-(1.64*_se[demXmoney]) if rolltime==`i'
			qui gen b_demXdw1`i'=_b[demXdw1] if rolltime==`i'
			qui gen se_demXdw1`i'=_se[demXdw1] if rolltime==`i'
			qui gen max_demXdw1`i'=_b[demXdw1]+(1.64*_se[demXdw1]) if rolltime==`i'
			qui gen min_demXdw1`i'=_b[demXdw1]-(1.64*_se[demXdw1]) if rolltime==`i'
			qui gen b_demXmoneyXdw1`i'=_b[demXmoneyXdw1] if rolltime==`i'
			qui gen se_demXmoneyXdw1`i'=_se[demXmoneyXdw1] if rolltime==`i'
			qui gen max_demXmoneyXdw1`i'=_b[demXmoneyXdw1]+(1.64*_se[demXmoneyXdw1]) if rolltime==`i'
			qui gen min_demXmoneyXdw1`i'=_b[demXmoneyXdw1]-(1.64*_se[demXmoneyXdw1]) if rolltime==`i'
			}
		}
	}
 */
 
/*
			 gen b_lnmoney=.
			 gen se_lnmoney=.
			 gen max_lnmoney=.
			 gen min_lnmoney=.
			 gen b_dw1=.
			 gen se_dw1=.
			 gen max_dw1=.
			 gen min_dw1=.
			 gen b_dem=.
			 gen se_dem=.
			 gen max_dem=.
			 gen min_dem=.
			 gen b_demXmoney=.
			 gen se_demXmoney=.
			 gen max_demXmoney=.
			 gen min_demXmoney=.
			 gen b_demXdw1=.
			 gen se_demXdw1=.
			 gen max_demXdw1=.
			 gen min_demXdw1=.
			 gen b_demXmoneyXdw1=.
			 gen se_demXmoneyXdw1=.
			 gen max_demXmoneyXdw1=.
			 gen min_demXmoneyXdw1=.
			 gen perfect=.

forval i=1/159	{
	display "votetime2=`i'"
	qui capture logit votesap lnmoney dwnom1 dem demXmoney demXdw1 demXmoneyXdw1 Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if votetime2==`i'
			if _rc!=0	{
			qui	replace perfect=1 if rolltime==`i'
			continue
			}
		else	{
			qui replace b_lnmoney=_b[lnmoney] if votetime2==`i'
			qui replace se_lnmoney=_se[lnmoney] if votetime2==`i'
			qui replace max_lnmoney=_b[lnmoney]+(1.64*_se[lnmoney]) if votetime2==`i'
			qui replace min_lnmoney=_b[lnmoney]-(1.64*_se[lnmoney]) if votetime2==`i'
			qui replace b_dw1=_b[dwnom1] if votetime2==`i'
			qui replace se_dw1=_se[dwnom1] if votetime2==`i'
			qui replace max_dw1=_b[dwnom1]+(1.64*_se[dwnom1]) if votetime2==`i'
			qui replace min_dw1=_b[dwnom1]-(1.64*_se[dwnom1]) if votetime2==`i'
			qui replace b_dem=_b[dem] if votetime2==`i'
			qui replace se_dem=_se[dem] if votetime2==`i'
			qui replace max_dem=_b[dem]+(1.64*_se[dem]) if votetime2==`i'
			qui replace min_dem=_b[dem]-(1.64*_se[dem]) if votetime2==`i'
			qui replace b_demXmoney=_b[demXmoney] if votetime2==`i'
			qui replace se_demXmoney=_se[demXmoney] if votetime2==`i'
			qui replace max_demXmoney=_b[demXmoney]+(1.64*_se[demXmoney]) if votetime2==`i'
			qui replace min_demXmoney=_b[demXmoney]-(1.64*_se[demXmoney]) if votetime2==`i'
			qui replace b_demXdw1=_b[demXdw1] if votetime2==`i'
			qui replace se_demXdw1=_se[demXdw1] if votetime2==`i'
			qui replace max_demXdw1=_b[demXdw1]+(1.64*_se[demXdw1]) if votetime2==`i'
			qui replace min_demXdw1=_b[demXdw1]-(1.64*_se[demXdw1]) if votetime2==`i'
			qui replace b_demXmoneyXdw1=_b[demXmoneyXdw1] if votetime2==`i'
			qui replace se_demXmoneyXdw1=_se[demXmoneyXdw1] if votetime2==`i'
			qui replace max_demXmoneyXdw1=_b[demXmoneyXdw1]+(1.64*_se[demXmoneyXdw1]) if votetime2==`i'
			qui replace min_demXmoneyXdw1=_b[demXmoneyXdw1]-(1.64*_se[demXmoneyXdw1]) if votetime2==`i'
			}
	}
*/			 
 *Trying to think through loop to calculate new dollars and awards since last vote -- I think this can be done with gen and lag commands available with xtset:

drop if votetime2==.


**run for altcoding of abstentions COMMENT OUT IF NOT CHECKING THIS!!!
gen votesap_ay=.
replace votesap=1 if vote==0


*egen sapvotes=count(idno) if votesap!=., by(idno) 
egen sapvotes=count(idno) if votesap_ay!=., by(idno) 

*drop if votesap==.
 egen id2=group(idno)
 egen voteorder=group(votetime2)
xtset idno votetime2

gen lagmoney=L.lnmoney if votesap!=. /*don't replace lag if no vote -- need to figure out how to fill these in*/
gen lagdollars=L.money if votesap!=.
*replace lagmoney=0 if lagmoney==. & votesap!=. & votetime2==1 /*should fix so first real vote is zero so the difference calc is correct for the first vote */
** Now generate the same for awards:
gen lagawards=L.awards if votesap!=.
*replace lagawards=0 if lagawards==. & votesap!=. & votetime2==1 

*use loop below to set first lag at zero so that all money is new money for the first vote
gen firstsapvote=.
forval i=1/549	{
	display "id2=`i'"
	qui su votetime2 if id2==`i'
	qui replace firstsapvote=r(min) if id2==`i'
	qui replace lagmoney=0 if id2==`i' & votetime2==r(min)
	qui replace lagdollars=0 if id2==`i' & votetime2==r(min)
	qui replace lagawards=0 if id2==`i' & votetime2==r(min)
}

*loop below expands the lag forward through missed votes and replaces the lags for awards and money with the expanded one for the first vote after a gap (so new money since last vote is correct)


forval i=1/549	{
	display "id2=`i'"
	forval j=1/159	{
	/*display "vote=`j'"*/
		qui count if id2==`i' & votetime2==`j'
		if r(N)==0	{
			continue
			}
		else	{
			qui su votesap if id2==`i' & votetime2==`j'
			local novote=r(N)
			qui su lagmoney if id2==`i' & votetime2==`j'
			local nolag=r(N)
				if `nolag'==0 & `novote'==0	{
					qui replace lagmoney=L.lagmoney if id2==`i' & votetime2==`j'
					qui replace lagdollars=L.lagdollars if id2==`i' & votetime2==`j'
					qui replace lagawards=L.lagawards if id2==`i' & votetime2==`j'
					qui su lagmoney if id2==`i' & votetime2==`j'+1
						if r(N)==1	{
							qui replace lagawards=L.lagawards if id2==`i' & votetime2==`j'+1
							qui replace lagmoney=L.lagmoney if id2==`i' & votetime2==`j'+1
							qui replace lagdollars=L.lagdollars if id2==`i' & votetime2==`j'+1
							}
						else	{
							continue
							}
					}
				if `nolag'==0 & `novote'==1	{
					qui su votetime2 if id2==`i' & votetime2<`j'
					local max=r(max)
					qui su lnmoney if id2==`i' & votetime2==`max'
					qui replace lagmoney=r(mean) if id2==`i' & votetime2==`j'
					qui su money if id2==`i' & votetime2==`max'
					qui replace lagdollars=r(mean) if id2==`i' & votetime2==`j'
					qui su awards if id2==`i' & votetime2==`max'
					qui replace lagawards=r(mean) if id2==`i' & votetime2==`j'
					}
				else	{
					continue
					}
				}
		}
	}

*id2=53 is weird case because of skipped votes/gaps so had to adjust code to deal with similar cases this then screwed up folks without gaps but multiple missed votes ultimately leading to the compound loops.  No doubt more efficient way to do this, but unsure how.  I think this works now

gen newmoney=lnmoney-lagmoney
su newmoney

gen newdollars=ln(((money-lagdollars)+1))
su newdollars

gen newawards=awards-lagawards
su lagawards

** this works and the replace treats the money on the first vote as all new money. The problem with this approach is that I've chosen to include the first vote for each member which is a balloon effect of sorts

** there is one weird instance of negative dollars (maybe a grant was returned or rescinded?) probably best to reset to zero:

replace newmoney=0 if newmoney<0
replace newdollars=0 if lagdollars>money & lagdollars!=. /*does same for the 3 weird ones*/
su newdollars


** save so long loop doesn't need to run again ONLY IF USING ABSTENTIONS
save "newmoney analysis abstentions.dta", replace

** save so long loop doesn't need to run again
save "newmoney analysis.dta", replace
*/


*start looking at some results



use "newmoney analysis.dta", clear

** start with dome descriptives:

label define vote 1 "Vote w/ SAP" 0 "Vote against SAP"
label values votesap vote
label define pty 1 "Democrats" 0 "Republicans"
label values dem pty


graph bar (mean) newdollars newawards , over(votesap) over(dem) scheme(s1color) blabel(bar, pos(inside) c(white) format(%9.1f)) ytitle("Mean New Awards/ln(New$)") note("N=66,817 individual votes on 159 speicific final passage votes where an SAP applied." "There are 548 unique members members across the 111th and 112th Congresses" " with 277 unique Democrats and 271 unique Republicans)") 
*graph export "simplebar.emf", as(emf) replace
graph bar (mean) newdollars newawards , over(votesap) over(dem) scheme(s1mono) blabel(bar, pos(inside) c(white) format(%9.1f)) ytitle("Mean New Awards/ln(New$)") note("N=66,817 individual votes on 159 speicific final passage votes where an SAP applied." "There are 548 unique members members across the 111th and 112th Congresses" " with 277 unique Democrats and 271 unique Republicans)") 
*graph export "simplebar_bw.emf", as(emf) replace
ttest newawards, by(dem)
ttest newdollars, by(dem)
ttest newdollars, by(votesap)
ttest newawards, by(votesap)
ttest newawards if dem==1, by(votesap)
ttest newdollars if dem==1, by(votesap)
ttest newdollars if dem==0, by(votesap)
ttest newawards if dem==0, by(votesap)


* first just new vars
logit votesap newdollars, vce(cluster idno)
estat class
logit votesap newawards, vce(cluster idno)
estat class

** basic but with interactions
*logit votesap c.newdollars##c.dwnom1##i.dem, vce(cluster idno)
*estat class
*logit votesap c.newawards##c.dwnom1##i.dem, vce(cluster idno)
estat class

***full model from earlier work and make newdollars table
logit votesap c.newdollars##c.dwnom1##i.dem, vce(cluster idno)
outreg2 using "newdollars", word auto(2) addstat(Pseudo R-squared, `e(r2_p)', Number of clusters, `e(N_clust)') replace
estat class
logit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)
outreg2 using "newdollars", word auto(2) addstat(Pseudo R-squared, `e(r2_p)', Number of clusters, `e(N_clust)')
estat class
*lroc

***make figures to visualize interaction then look at a few robustness checks

margins, at(newdollars=(0(1)22) dwnom1=(-.65 -.35 .05) dem=1 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate forbornpct dpres MedicalFac age65pct manufpct unemployedpct medianinc ) l(90)

marginsplot, scheme(s1color) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) /// 
    title("Democrats") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(2)23) xtitle("ln(New ARRA$)") /// 
	plot1opts(mc(magenta) lc(magenta)) plot2opts(mc(purple) lc(purple)) plot3opts(mc(lavender) lc(lavender)) /// 
	ci1opts(lc(magenta)) ci2opts(lc(purple)) ci3opts(lc(lavender)) /// 
	name(n1)
	
marginsplot, scheme(s1mono) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) ///
    title("Democrats") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(2)23) xtitle("ln(New ARRA$)") ///  
	plot1opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot3opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci1opts(lc(gs1)) ci2opts(lc(gs5)) ci3opts(lc(gs9)) /// 
	name(nbw1)
	
graph display n1
graph save "hdemnewmoney_color.gph", replace
*graph export "hdemnewmoney_color.emf", as(emf) replace

graph display nbw1
graph save "hdemnewmoney_bw.gph", replace
*graph export "hdemnewmoney_bw.emf", as(emf) replace

margins, at(newdollars=(0(1)23) dwnom1=(.25 .5 .8) dem=0 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate dpres MedicalFac age65pct manufpct unemployedpct medianinc forbornpct) l(90)

marginsplot, scheme(s1color) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) /// 
    title("Republicans") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(2)23) xtitle("ln(New ARRA$)") /// 
	plot3opts(mc(magenta) lc(magenta)) plot2opts(mc(purple) lc(purple)) plot1opts(mc(lavender) lc(lavender)) /// 
	ci3opts(lc(magenta)) ci2opts(lc(purple)) ci1opts(lc(lavender)) /// 
	name(n2)

marginsplot, scheme(s1mono) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) ///
	title("Republicans") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(2)23) xtitle("ln(New ARRA$)")  /// 
	plot3opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot1opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci3opts(lc(gs1)) ci2opts(lc(gs5)) ci1opts(lc(gs9)) /// 
	name(nbw2)	
	
graph display n2
graph save "hgopnewmoney_bw.gph", replace
*graph export "hgopnewmoney_color.emf", as(emf) replace

graph display nbw2
graph save "hgopnewmoney_bw.gph", replace
*graph export "hgopnewmoney_bw.emf", as(emf) replace

*combine house margins graphs
grc1leg n1 n2, scheme(s1color) note("90% confidence intervals")
graph save "housenewmoney_color.gph", replace
*graph export "housenewmoney_color.emf", as(emf) replace

grc1leg n1 n2, scheme(s1color) note("90% confidence intervals") ycommon
graph save "housenewmoney_color_samescale.gph", replace
*graph export "housenewmoney_color_samescale.emf", as(emf) replace


grc1leg nbw1 nbw2, scheme(s1mono) note("90% confidence intervals")
graph save "housenewmoney_bw.gph", replace
*graph export "housenewmoney_bw.emf", as(emf) replace

grc1leg nbw1 nbw2, scheme(s1mono) note("90% confidence intervals") ycommon
graph save "housenewmoney_bw_samescale.gph", replace
*graph export "housenewmoney_bw_samescale.emf", as(emf) replace

*** other robustness checks

* does it work for newawards?
logit votesap c.newawards##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)
*YES

*Does it work for new money if controlling for amount of money already received?
logit votesap c.newdollars##c.dwnom1##i.dem lnmoney clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)
*YES

*Note there are a lot of balloon newmoney values when someone is new. 
hist newmoney, bin(30)

*Does it work if we eliminate those first votes?
logit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if firstsapvote!=votetime2, vce(cluster idno) 
*YES!

*Still a lot of outliers in terms of new money because of big outlays.  
su newmoney if firstsapvote!=votetime2

* does it work if limit to the lowest 90% of newdollars?
logit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if newdollars<17, vce(cluster idno) 
*YES!

* does it work if close vote replaced by partyvote50?
logit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat ptyvote50 rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct, vce(cluster idno) 
*Yes!

* does it work for a FE?
*xtlogit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct, fe
* For obvious reasons this won't converge with all the covariates, so try the barebones model with only vote controls and make table for reference/comparison
xtlogit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong , fe
estimates store fixed
outreg2 using "fixed and random", word auto(2) addstat(Number of groups, `e(N_g)') replace
*Yes!

*Now try with random effects
xtlogit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong , re
estimates store random_simple
outreg2 using "fixed and random", word auto(2) addstat(Number of groups, `e(N_g)') 
*Yes!

*Now try running random effects with the full slate of controls
xtlogit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct, re
estimates store random_complex
outreg2 using "fixed and random", word auto(2) addstat(Number of groups, `e(N_g)') 
*Yes!

*tryit one more way with handrolled interaction terms
gen newXdw1=newdollars*dwnom1
gen demXnew=dem*newdollars
gen demXnewXdw1=dem*newdollars*dwnom1

xtlogit votesap newdollars newXdw1 demXnew demXnewX clarity vetothreat closevote rcdate i.cong, fe
estimates store fixed_alt
xtlogit votesap newdollars newXdw1 demXnew demXnewX clarity vetothreat closevote rcdate i.cong, re
estimates store random_alt

hausman fixed_alt random_alt
*** hausman doesn't work here wants a suest, but not sure how to fit that...

****** Make table and figs for awards
*logit votesap c.newawards##c.dwnom1##i.dem, vce(cluster idno)
*outreg2 using "newawards", word auto(2) addstat(Pseudo R-squared, `e(r2_p)', Number of clusters, `e(N_clust)') replace
*estat class

** Actually the simple model with awards backs up and doesn't readily converge... just jump to full model

logit votesap c.newawards##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)
outreg2 using "newawards", word auto(2) addstat(Pseudo R-squared, `e(r2_p)', Number of clusters, `e(N_clust)') replace

* problem with this is that awards do seem to be busted by the balloon of the first vote so try again without these
logit votesap c.newawards##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if firstsapvote!=votetime2, vce(cluster idno)

* still a lot of outliers so truncate to new awards <35, which is 99% of all obs (also works on threshold of 20 and even 10 (the 90% of all obs threshhold)
logit votesap c.newawards##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if newawards<=35, vce(cluster idno)
outreg2 using "newawards", word auto(2) addstat(Pseudo R-squared, `e(r2_p)', Number of clusters, `e(N_clust)') 
estat class /*pct classified is 77.4% */
*lroc /* = .84*/

***make figures to visualize interaction then look at a few robustness checks

margins, at(newawards=(0(5)35) dwnom1=(-.65 -.35 .05) dem=1 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate forbornpct dpres MedicalFac age65pct manufpct unemployedpct medianinc ) l(90)

marginsplot, scheme(s1color) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) /// 
    title("Democrats") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(5)35) xtitle("New Awards") /// 
	plot1opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot3opts(mc(red) lc(red)) /// 
	ci1opts(lc(blue)) ci2opts(lc(green)) ci3opts(lc(red)) /// 
	name(w1)
	
marginsplot, scheme(s1mono) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) ///
    title("Democrats") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(5)35) xtitle("New Awards") ///  
	plot1opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot3opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci1opts(lc(gs1)) ci2opts(lc(gs5)) ci3opts(lc(gs9)) /// 
	name(wbw1)
	
graph display w1
graph save "hdemnewawards_color.gph", replace
graph export "hdemnewawards_color.emf", as(emf) replace

graph display wbw1
graph save "hdemnewawards_bw.gph", replace
graph export "hdemnewawards_bw.emf", as(emf) replace
	
margins, at(newawards=(0(5)35) dwnom1=(.25 .5 .8) dem=0 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate dpres MedicalFac age65pct manufpct unemployedpct medianinc forbornpct) l(90)

marginsplot, scheme(s1color) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) /// 
    title("Republicans") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(5)35) xtitle("New Awards") /// 
	plot3opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot1opts(mc(red) lc(red)) /// 
	ci3opts(lc(blue)) ci2opts(lc(green)) ci1opts(lc(red)) /// 
	name(w2)

marginsplot, scheme(s1mono) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) ///
	title("Republicans") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(5)35) xtitle("New Awards")  /// 
	plot3opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot1opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci3opts(lc(gs1)) ci2opts(lc(gs5)) ci1opts(lc(gs9)) /// 
	name(wbw2)	
	
graph display w2
graph save "hgopnewawards_bw.gph", replace
graph export "hgopnewawards_color.emf", as(emf) replace

graph display wbw2
graph save "hgopnewawards_bw.gph", replace
graph export "hgopnewawards_bw.emf", as(emf) replace

*combine house margins graphs
grc1leg w1 w2, scheme(s1color) note("90% confidence intervals")
graph save "housenewawards_color.gph", replace
graph export "housenewawards_color.emf", as(emf) replace

grc1leg w1 w2, scheme(s1color) note("90% confidence intervals") ycommon
graph save "housenewawards_color_samescale.gph", replace
graph export "housenewawards_color_samescale.emf", as(emf) replace

grc1leg wbw1 wbw2, scheme(s1mono) note("90% confidence intervals")
graph save "housenewawards_bw.gph", replace
graph export "housenewawards_bw.emf", as(emf) replace

grc1leg wbw1 wbw2, scheme(s1mono) note("90% confidence intervals") ycommon
graph save "housenewawards_bw_samescale.gph", replace
graph export "housenewawards_bw_samescale.emf", as(emf) replace
/*
 
 egen sapvotes=count(votesap), by(idno cong)
 egen obamavotes=count(voteobama), by(idno cong)
 egen demvotes=count(votewithdem), by(idno cong)
 
 collapse (max) lnmoney dem awards sapvotes obamavotes /// 
                demvotes senate dwnom1 dwnom2 dem /// 
				Cardinal Approps Party Leadership fr noppon dpres MedicalFac rules /// 
				latino HouseRulesMember SAPTarget SAPTargetSen Cardinal PartyLeadership Approps /// 
				age65 black highsch manuf rural transportation unemployed urban veterans population medianinc forborn ///
				age65pct blackpct highschpct manufpct transportationpct unemployedpct urbanpct veteranspct forbornpct /// 
				dv dvp /// 
          (sum) votesap voteobama votewithdem ///
		   , by(cong idno)
		   
gen pctsap=votesap/sapvotes
gen pctobama=voteobama/obamavotes
gen pctdem=votewithdem/demvotes

reg pctsap c.lnmoney##c.dwnom1##i.dem
*/

****************************************************************

***ADAPT NEWMONEY/AWARD APPROACH TO OBAMA VOTES
/*
 keep if analyze==1 & cong<113
 egen votetime=group(rolltime)
 egen votetime2=group(rolltime) if voteobama!=.

		 
 *Trying to think through loop to calculate new dollars and awards since last vote -- I think this can be done with gen and lag commands available with xtset:

drop if votetime2==.
egen obamavotes=count(idno) if voteobama!=., by(idno) 
*drop if votesap==.
 egen id2=group(idno)
 egen voteorder=group(votetime2)
xtset idno votetime2

gen lagmoney=L.lnmoney if voteobama!=. /*don't replace lag if no vote -- need to figure out how to fill these in*/
gen lagdollars=L.money if voteobama!=.
*replace lagmoney=0 if lagmoney==. & voteobama!=. & votetime2==1 /*should fix so first real vote is zero so the difference calc is correct for the first vote */
** Now generate the same for awards:
gen lagawards=L.awards if voteobama!=.
*replace lagawards=0 if lagawards==. & voteobama!=. & votetime2==1 

*use loop below to set first lag at zero so that all money is new money for the first vote
gen firstobamavote=.
forval i=1/550	{
	display "id2=`i'"
	qui su votetime2 if id2==`i'
	qui replace firstobamavote=r(min) if id2==`i'
	qui replace lagmoney=0 if id2==`i' & votetime2==r(min)
	qui replace lagdollars=0 if id2==`i' & votetime2==r(min)
	qui replace lagawards=0 if id2==`i' & votetime2==r(min)
}

*loop below expands the lag forward through missed votes and replaces the lags for awards and money with the expanded one for the first vote after a gap (so new money since last vote is correct)


forval i=1/550	{
	display "id2=`i'"
	forval j=1/141	{
	/*display "vote=`j'"*/
		qui count if id2==`i' & votetime2==`j'
		if r(N)==0	{
			continue
			}
		else	{
			qui su voteobama if id2==`i' & votetime2==`j'
			local novote=r(N)
			qui su lagmoney if id2==`i' & votetime2==`j'
			local nolag=r(N)
				if `nolag'==0 & `novote'==0	{
					qui replace lagmoney=L.lagmoney if id2==`i' & votetime2==`j'
					qui replace lagdollars=L.lagdollars if id2==`i' & votetime2==`j'
					qui replace lagawards=L.lagawards if id2==`i' & votetime2==`j'
					qui su lagmoney if id2==`i' & votetime2==`j'+1
						if r(N)==1	{
							qui replace lagawards=L.lagawards if id2==`i' & votetime2==`j'+1
							qui replace lagmoney=L.lagmoney if id2==`i' & votetime2==`j'+1
							qui replace lagdollars=L.lagdollars if id2==`i' & votetime2==`j'+1
							}
						else	{
							continue
							}
					}
				if `nolag'==0 & `novote'==1	{
					qui su votetime2 if id2==`i' & votetime2<`j'
					local max=r(max)
					qui su lnmoney if id2==`i' & votetime2==`max'
					qui replace lagmoney=r(mean) if id2==`i' & votetime2==`j'
					qui su money if id2==`i' & votetime2==`max'
					qui replace lagdollars=r(mean) if id2==`i' & votetime2==`j'
					qui su awards if id2==`i' & votetime2==`max'
					qui replace lagawards=r(mean) if id2==`i' & votetime2==`j'
					}
				else	{
					continue
					}
				}
		}
	}

*id2=53 is weird case because of skipped votes/gaps so had to adjust code to deal with similar cases this then screwed up folks without gaps but multiple missed votes ultimately leading to the compound loops.  No doubt more efficient way to do this, but unsure how.  I think this works now

gen newmoney=lnmoney-lagmoney
su newmoney

gen newdollars=ln(((money-lagdollars)+1))
su newdollars

gen newawards=awards-lagawards
su lagawards

** this works and the replace treats the money on the first vote as all new money. The problem with this approach is that I've chosen to include the first vote for each member which is a balloon effect of sorts

** there is one weird instance of negative dollars (maybe a grant was returned or rescinded?) probably best to reset to zero:

replace newmoney=0 if newmoney<0
replace newdollars=0 if lagdollars>money & lagdollars!=. /*does same for the 3 weird ones*/
su newdollars

** save so long loop doesn't need to run again
save "newmoney analysis_obama.dta", replace
*/


use "newmoney analysis_obama.dta", clear

** start with dome descriptives:

***** to minimze code changes NOTE I renamed voteobama to votesap for the analysis below*********************

rename votesap old_votesap
gen votesap=voteobama

label define vote 1 "Vote w/ SAP" 0 "Vote against SAP"
label values votesap vote
label define pty 1 "Democrats" 0 "Republicans"
label values dem pty
graph bar (mean) newdollars newawards , over(votesap) over(dem) scheme(s1color) ytitle("Mean New Awards/ln(New$)") note("N=66,817 individual votes on 159 speicific final passage votes where an SAP applied." "There are 548 unique members members across the 111th and 112th Congresses" " with 277 unique Democrats and 271 unique Republicans)") 
graph export "simplebar.emf", as(emf) replace
graph bar (mean) newdollars newawards , over(votesap) over(dem) scheme(s1mono) ytitle("Mean New Awards/ln(New$)") note("N=66,817 individual votes on 159 speicific final passage votes where an SAP applied." "There are 548 unique members members across the 111th and 112th Congresses" " with 277 unique Democrats and 271 unique Republicans)") 
graph export "simplebar_bw.emf", as(emf) replace
ttest newawards, by(dem)
ttest newdollars, by(dem)
ttest newdollars, by(votesap)
ttest newawards, by(votesap)
ttest newawards if dem==1, by(votesap)
ttest newdollars if dem==1, by(votesap)
ttest newdollars if dem==0, by(votesap)
ttest newawards if dem==0, by(votesap)

* first just new vars
logit votesap newdollars, vce(cluster idno)
estat class
logit votesap newawards, vce(cluster idno)
estat class

** basic but with interactions
logit votesap c.newdollars##c.dwnom1##i.dem, vce(cluster idno)
estat class
logit votesap c.newawards##c.dwnom1##i.dem, vce(cluster idno)
estat class

***full model from earlier work and make newdollars table
logit votesap c.newdollars##c.dwnom1##i.dem, vce(cluster idno)
outreg2 using "newdollars", word auto(2) addstat(Pseudo R-squared, `e(r2_p)', Number of clusters, `e(N_clust)') replace
estat class
logit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)
outreg2 using "newdollars", word auto(2) addstat(Pseudo R-squared, `e(r2_p)', Number of clusters, `e(N_clust)')
estat class
*lroc

***make figures to visualize interaction then look at a few robustness checks

margins, at(newdollars=(0(1)22) dwnom1=(-.65 -.35 .05) dem=1 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate forbornpct dpres MedicalFac age65pct manufpct unemployedpct medianinc ) l(90)

marginsplot, scheme(s1color) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) /// 
    title("Democrats") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(2)23) xtitle("ln(New ARRA$)") /// 
	plot1opts(mc(magenta) lc(magenta)) plot2opts(mc(purple) lc(purple)) plot3opts(mc(lavender) lc(lavender)) /// 
	ci1opts(lc(magenta)) ci2opts(lc(purple)) ci3opts(lc(lavender)) /// 
	name(n1)
	
marginsplot, scheme(s1mono) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) ///
    title("Democrats") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(2)23) xtitle("ln(New ARRA$)") ///  
	plot1opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot3opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci1opts(lc(gs1)) ci2opts(lc(gs5)) ci3opts(lc(gs9)) /// 
	name(nbw1)
	
graph display n1
graph save "hdemnewmoney_color_vb.gph", replace
*graph export "hdemnewmoney_color_vb.emf", as(emf) replace

graph display nbw1
graph save "hdemnewmoney_bw_vb.gph", replace
*graph export "hdemnewmoney_bw_vb.emf", as(emf) replace
	
margins, at(newdollars=(0(1)23) dwnom1=(.25 .5 .8) dem=0 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate dpres MedicalFac age65pct manufpct unemployedpct medianinc forbornpct) l(90)

marginsplot, scheme(s1color) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) /// 
    title("Republicans") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(2)23) xtitle("ln(New ARRA$)") /// 
	plot3opts(mc(magenta) lc(magenta)) plot2opts(mc(purple) lc(purple)) plot1opts(mc(lavender) lc(lavender)) /// 
	ci3opts(lc(magenta)) ci2opts(lc(purple)) ci1opts(lc(lavender)) /// 
	name(n2)

marginsplot, scheme(s1mono) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) ///
	title("Republicans") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(2)23) xtitle("ln(New ARRA$)")  /// 
	plot3opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot1opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci3opts(lc(gs1)) ci2opts(lc(gs5)) ci1opts(lc(gs9)) /// 
	name(nbw2)	
	
graph display n2
graph save "hgopnewmoney_bw_vb.gph", replace
*graph export "hgopnewmoney_color_vb.emf", as(emf) replace

graph display nbw2
graph save "hgopnewmoney_bw_vb.gph", replace
*graph export "hgopnewmoney_bw_vb.emf", as(emf) replace

*combine house margins graphs
grc1leg n1 n2, scheme(s1color) note("90% confidence intervals")
graph save "housenewmoney_color_vb.gph", replace
*graph export "housenewmoney_color_vb.emf", as(emf) replace

grc1leg n1 n2, scheme(s1color) note("90% confidence intervals") ycommon
graph save "housenewmoney_color_samescale_vb.gph", replace
*graph export "housenewmoney_color_samescale_vb.emf", as(emf) replace


grc1leg nbw1 nbw2, scheme(s1mono) note("90% confidence intervals")
graph save "housenewmoney_bw_vb.gph", replace
graph export "housenewmoney_bw_vb.emf", as(emf) replace

grc1leg nbw1 nbw2, scheme(s1mono) note("90% confidence intervals") ycommon
graph save "housenewmoney_bw_samescale_vb.gph", replace
graph export "housenewmoney_bw_samescale_vb.emf", as(emf) replace

*** other robustness checks

* does it work for newawards?
logit votesap c.newawards##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)
*YES

*Does it work for new money if controlling for amount of money already received?
logit votesap c.newdollars##c.dwnom1##i.dem lnmoney clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)
*YES

*Note there are a lot of balloon newmoney values when someone is new. 
hist newmoney, bin(30)

*Does it work if we eliminate those first votes?
logit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if firstsapvote!=votetime2, vce(cluster idno) 
*YES!

*Still a lot of outliers in terms of new money because of big outlays.  
su newmoney if firstsapvote!=votetime2

* does it work if limit to the lowest 90% of newdollars?
logit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if newdollars<17, vce(cluster idno) 
*YES!

* does it work if close vote replaced by partyvote50?
logit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat ptyvote50 rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct, vce(cluster idno) 
*Yes!

* does it work for a FE?
*xtlogit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct, fe
* For obvious reasons this won't converge with all the covariates, so try the barebones model with only vote controls and make table for reference/comparison
xtlogit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong , fe
estimates store fixed
outreg2 using "fixed and random", word auto(2) addstat(Number of groups, `e(N_g)') replace
*Yes!

*Now try with random effects
xtlogit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong , re
estimates store random_simple
outreg2 using "fixed and random", word auto(2) addstat(Number of groups, `e(N_g)') 
*Yes!

*Now try running random effects with the full slate of controls
xtlogit votesap c.newdollars##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct, re
estimates store random_complex
outreg2 using "fixed and random", word auto(2) addstat(Number of groups, `e(N_g)') 
*Yes!

*tryit one more way with handrolled interaction terms
gen newXdw1=newdollars*dwnom1
gen demXnew=dem*newdollars
gen demXnewXdw1=dem*newdollars*dwnom1

xtlogit votesap newdollars newXdw1 demXnew demXnewX clarity vetothreat closevote rcdate i.cong, fe
estimates store fixed_alt
xtlogit votesap newdollars newXdw1 demXnew demXnewX clarity vetothreat closevote rcdate i.cong, re
estimates store random_alt

hausman fixed_alt random_alt
*** hausman doesn't work here wants a suest, but not sure how to fit that...

****** Make table and figs for awards
*logit votesap c.newawards##c.dwnom1##i.dem, vce(cluster idno)
*outreg2 using "newawards", word auto(2) addstat(Pseudo R-squared, `e(r2_p)', Number of clusters, `e(N_clust)') replace
*estat class

** Actually the simple model with awards backs up and doesn't readily converge... just jump to full model

logit votesap c.newawards##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if analyze==1 & senate==0, vce(cluster idno)
outreg2 using "newawards", word auto(2) addstat(Pseudo R-squared, `e(r2_p)', Number of clusters, `e(N_clust)') replace

* problem with this is that awards do seem to be busted by the balloon of the first vote so try again without these
logit votesap c.newawards##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if firstsapvote!=votetime2, vce(cluster idno)

* still a lot of outliers so truncate to new awards <35, which is 99% of all obs (also works on threshold of 20 and even 10 (the 90% of all obs threshhold)
logit votesap c.newawards##c.dwnom1##i.dem clarity vetothreat closevote rcdate i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct forbornpct manufpct unemployedpct medianinc latinopct blackpct if newawards<=35, vce(cluster idno)
outreg2 using "newawards", word auto(2) addstat(Pseudo R-squared, `e(r2_p)', Number of clusters, `e(N_clust)') 
estat class /*pct classified is 77.4% */
*lroc /* = .84*/

***make figures to visualize interaction then look at a few robustness checks

margins, at(newawards=(0(5)35) dwnom1=(-.65 -.35 .05) dem=1 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate forbornpct dpres MedicalFac age65pct manufpct unemployedpct medianinc ) l(90)

marginsplot, scheme(s1color) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) /// 
    title("Democrats") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(5)35) xtitle("New Awards") /// 
	plot1opts(mc(magenta) lc(magenta)) plot2opts(mc(purple) lc(purple)) plot3opts(mc(lavender) lc(lavender)) /// 
	ci1opts(lc(magenta)) ci2opts(lc(purple)) ci3opts(lc(lavender)) /// 
	name(w1)
	
marginsplot, scheme(s1mono) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) ///
    title("Democrats") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(5)35) xtitle("New Awards") ///  
	plot1opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot3opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci1opts(lc(gs1)) ci2opts(lc(gs5)) ci3opts(lc(gs9)) /// 
	name(wbw1)
	
graph display w1
graph save "hdemnewawards_color.gph", replace
*graph export "hdemnewawards_color.emf", as(emf) replace

graph display wbw1
graph save "hdemnewawards_bw.gph", replace
*graph export "hdemnewawards_bw.emf", as(emf) replace
	
margins, at(newawards=(0(5)35) dwnom1=(.25 .5 .8) dem=0 closevote=1 clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) rcdate dpres MedicalFac age65pct manufpct unemployedpct medianinc forbornpct) l(90)

marginsplot, scheme(s1color) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) /// 
    title("Republicans") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(5)35) xtitle("New Awards") /// 
	plot3opts(mc(magenta) lc(magenta)) plot2opts(mc(purple) lc(purple)) plot1opts(mc(lavender) lc(lavender)) /// 
	ci3opts(lc(magenta)) ci2opts(lc(purple)) ci1opts(lc(lavender)) /// 
	name(w2)

marginsplot, scheme(s1mono) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) ///
	title("Republicans") ytitle("Predicted pr(Vote with Obama/SAP)") xlabel(0(5)35) xtitle("New Awards")  /// 
	plot3opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot1opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci3opts(lc(gs1)) ci2opts(lc(gs5)) ci1opts(lc(gs9)) /// 
	name(wbw2)	
	
graph display w2
graph save "hgopnewawards_bw.gph", replace
*graph export "hgopnewawards_color.emf", as(emf) replace

graph display wbw2
graph save "hgopnewawards_bw.gph", replace
*graph export "hgopnewawards_bw.emf", as(emf) replace

*combine house margins graphs
grc1leg w1 w2, scheme(s1color) note("90% confidence intervals")
graph save "housenewawards_color.gph", replace
*graph export "housenewawards_color.emf", as(emf) replace

grc1leg w1 w2, scheme(s1color) note("90% confidence intervals") ycommon
graph save "housenewawards_color_samescale.gph", replace
*graph export "housenewawards_color_samescale.emf", as(emf) replace
/*
grc1leg wbw1 wbw2, scheme(s1mono) note("90% confidence intervals")
graph save "housenewawards_bw.gph", replace
*graph export "housenewawards_bw.emf", as(emf) replace

grc1leg wbw1 wbw2, scheme(s1mono) note("90% confidence intervals") ycommon
graph save "housenewawards_bw_samescale.gph", replace
*graph export "housenewawards_bw_samescale.emf", as(emf) replace

*************************************************************************************************************************
 
**** OLD STUFF
/*
logit votesap c.lnmoney clarity vetothreat i.cong if (passage==1 |agreeto==1) & dem==1 & senate==0 & cong<113, vce(cluster idno)
outreg2 using "housedems", word auto(2) replace
logit votesap c.lnmoney##c.dwnom1 clarity vetothreat i.cong Cardinal Approps PartyLeadership fr noppon if (passage==1 |agreeto==1) & dem==1 & senate==0 & cong<113, vce(cluster idno)
outreg2 using "housedems", word auto(2)
logit votesap c.lnmoney##c.dwnom1 clarity vetothreat i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct manufpct unemployedpct medianinc /*forbornpct?? left out by jake*/ latinopct blackpct if (passage==1 |agreeto==1) & dem==1 & senate==0, vce(cluster idno)
outreg2 using "housedems", word auto(2)
sum votesap c.lnmoney##c.dwnom1 clarity vetothreat i.cong Cardinal Approps PartyLeadership fr noppon dpres MedicalFac age65pct manufpct unemployedpct medianinc if dem==1

margins, at(lnmoney=(0(1)23) dwnom1=(-.65 -.35 .05) clarity=1 cong=111 Cardinal=0 Approps=0 PartyLeadership=0 fr=0 noppon=0 (means) dpres MedicalFac age65pct manufpct unemployedpct medianinc ) l(90)

marginsplot, scheme(s1color) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) /// 
    title("Democrats") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23) /// 
	plot1opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot3opts(mc(red) lc(red)) /// 
	ci1opts(lc(blue)) ci2opts(lc(green)) ci3opts(lc(red)) /// 
	name(g1)

marginsplot, scheme(s1mono) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) ///
    title("Democrats") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23)  ///  
	plot1opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot3opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci1opts(lc(gs1)) ci2opts(lc(gs5)) ci3opts(lc(gs9)) /// 
	name(bw1)

graph display g1
graph save "hdemmargins_color.gph", replace
graph export "hdemmargins_color.emf", as(emf) replace

graph display bw1
graph save "hdemmargins_bw.gph", replace
graph export "hdemmargins_bw.emf", as(emf) replace

estat class
lroc

** House gop analysis

logit votesap c.lnmoney clarity vetothreat i.cong if (passage==1 |agreeto==1) & dem==0 & senate==0 & cong<113, cluster(idno)
outreg2 using "housegop", word auto(2) replace
logit votesap c.lnmoney##c.dwnom1 clarity vetothreat i.cong Cardinal Approps if (passage==1 |agreeto==1) & dem==0 & senate==0 & cong<113, cluster(idno)
outreg2 using "housegop", word auto(2)
logit votesap c.lnmoney##c.dwnom1 clarity vetothreat i.cong Cardinal Approps dpres hospital unemployedpct medianinc forbornpct latinopct blackpct if (passage==1 |agreeto==1) & dem==0 & senate==0, cluster(idno)
outreg2 using "housegop", word auto(2)
*sum dwnom1 lnmoney if dem==0
margins, at(lnmoney=(0(1)23) dwnom1=(.15 .5 .95)) l(90)

marginsplot, scheme(s1color) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) /// 
    title("Republicans") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23) /// 
	plot3opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot1opts(mc(red) lc(red)) /// 
	ci3opts(lc(blue)) ci2opts(lc(green)) ci1opts(lc(red)) /// 
	name(g2)

marginsplot, scheme(s1mono) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) ///
	title("Republicans") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)23)  /// 
	plot3opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot1opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci3opts(lc(gs1)) ci2opts(lc(gs5)) ci1opts(lc(gs9)) /// 
	name(bw2)	
	
graph display g2
graph save "hgopmargins_bw.gph", replace
graph export "hgopmargins_color.emf", as(emf) replace

graph display bw2
graph save "hgopmargins_bw.gph", replace
graph export "hgopmargins_bw.emf", as(emf) replace

*combine house margins graphs
grc1leg g1 g2, scheme(s1color) note("90% confidence intervals")
graph save "housemargins_color.gph", replace
graph export "housemargins_color.emf", as(emf) replace

grc1leg bw1 bw2, scheme(s1mono) note("90% confidence intervals")
graph save "housemargins_bw.gph", replace
graph export "housemargins_bw.emf", as(emf) replace

estat class
lroc

** Senate gop analysis

logit votesap c.lnmoney clarity vetothreat i.cong if (passage==1 |agreeto==1) & dem==0 & senate==1 & cong<113, cluster(idno)
outreg2 using "sengop", word auto(2) replace
logit votesap c.lnmoney##c.dwnom1 clarity vetothreat i.cong Approps if (passage==1 |agreeto==1) & dem==0 & senate==1 & cong<113, cluster(idno)
outreg2 using "sengop", word auto(2)
logit votesap c.lnmoney##c.dwnom1 clarity vetothreat i.cong Approps hospital unemployedpct medianinc forbornpct blackpct if (passage==1 |agreeto==1) & dem==0 & senate==1, cluster(idno)
outreg2 using "sengop", word auto(2)
*sum dwnom1 lnmoney if dem==0
margins, at(lnmoney=(0(1)24) dwnom1=(.1 .5 .9)) l(90)

marginsplot, scheme(s1color) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) /// 
    title("Republicans") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)24) /// 
	plot3opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot1opts(mc(red) lc(red)) /// 
	ci3opts(lc(blue)) ci2opts(lc(green)) ci1opts(lc(red)) /// 
	name(h2)

marginsplot, scheme(s1mono) legend(order(6 "Extreme DW1 score" 5 "Average DW1 score" 4 "Moderate DW1 score")) ///
	title("Republicans") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)24)  /// 
	plot3opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot1opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci3opts(lc(gs1)) ci2opts(lc(gs5)) ci1opts(lc(gs9)) /// 
	name(hbw2)	
	
graph display h2
graph save "sgopmargins_bw.gph", replace
graph export "sgopmargins_color.emf", as(emf) replace

graph display hbw2
graph save "sgopmargins_bw.gph", replace
graph export "sgopmargins_bw.emf", as(emf) replace

*combine house margins graphs
grc1leg h1 h2, scheme(s1color) note("90% confidence intervals")
graph save "senmargins_color.gph", replace
graph export "senmargins_color.emf", as(emf) replace

grc1leg hbw1 hbw2, scheme(s1mono) note("90% confidence intervals")
graph save "senmargins_bw.gph", replace
graph export "senmargins_bw.emf", as(emf) replace

***** SENATE analysis

/*
use "senatedata_full3-30-16.dta", clear

xtset idno rolltime

* gen non logged money measure
gen money10m=money/10000000

* make electoral win margin
gen voteshare=.
replace voteshare=dv if dem==1
replace voteshare=100-dv if dem==0

* gen electoral safety
gen marginality=abs(voteshare-50)

* identify whether rc in question was close
gen votewinmargin=abs(yeas-nays)
gen closevote=0
replace closevote=1 if votewinmargin<=20

*gen whether rc was a pty line vote with 50/50 threshhold
gen demvotes=demyeas+demnays
gen repvotes=repyeas+repnays
gen majdemyea=0
replace majdemyea=1 if demyeas/demvotes>=.5
gen majdemnay=0
replace majdemnay=1 if demnays/demvotes>=.5
gen majrepyea=0
replace majrepyea=1 if repyeas/repvotes>=.5
gen majrepnay=0
replace majrepnay=1 if repnays/repvotes>=.5

gen ptyvote50=0
replace ptyvote50=1 if majdemyea==1 & majrepnay==1
replace ptyvote50=1 if majdemnay==1 & majrepyea==1

*wash and repeat for a 90/90 threshhold
gen majdemyea90=0
replace majdemyea90=1 if demyeas/demvotes>=.9
gen majdemnay90=0
replace majdemnay90=1 if demnays/demvotes>=.9
gen majrepyea90=0
replace majrepyea90=1 if repyeas/repvotes>=.9
gen majrepnay90=0
replace majrepnay90=1 if repnays/repvotes>=.9

gen ptyvote90=0
replace ptyvote90=1 if majdemyea90==1 & majrepnay90==1
replace ptyvote90=1 if majdemnay90==1 & majrepyea90==1

* gen whether member voted with their pty
gen votewithpty=.
replace votewithpty=1 if dem==1 & vote==1 & majdemyea==1
replace votewithpty=1 if dem==1 & vote==-1 & majdemnay==1
replace votewithpty=1 if dem==0 & vote==1 & majrepyea==1
replace votewithpty=1 if dem==0 & vote==-1 & majrepnay==1

* need to fix the alt DV of whether vote as with demmaj - this section should do that
drop votewithdemmaj
gen votewithdemmaj=.
replace votewithdemmaj=1 if vote==1 & majdemyea==1
replace votewithdemmaj=1 if vote==-1 & majdemnay==1
replace votewithdemmaj=0 if vote==1 & majdemnay==1
replace votewithdemmaj=0 if vote==-1 & majdemyea==1

** Senate Dem analysis
logit votesap c.lnmoney clarity vetothreat i.cong if (passage==1 |agreeto==1) & dem==1 & senate==1 & cong<113, cluster(idno)
outreg2 using "sendems", word auto(2) replace
logit votesap c.lnmoney##c.dwnom1 clarity vetothreat i.cong Approps if (passage==1 |agreeto==1) & dem==1 & senate==1 & cong<113, cluster(idno)
outreg2 using "sendems", word auto(2)
logit votesap c.lnmoney##c.dwnom1 clarity vetothreat i.cong Approps hospital unemployedpct medianinc forbornpct blackpct if (passage==1 |agreeto==1) & dem==1 & senate==1, cluster(idno)
outreg2 using "sendems", word auto(2)
sum dwnom1 lnmoney if dem==1
margins, at(lnmoney=(0(1)24) dwnom1=(-.65 -.35 -.05)) l(90)

marginsplot, scheme(s1color) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) /// 
    title("Democrats") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)24) /// 
	plot1opts(mc(blue) lc(blue)) plot2opts(mc(green) lc(green)) plot3opts(mc(red) lc(red)) /// 
	ci1opts(lc(blue)) ci2opts(lc(green)) ci3opts(lc(red)) /// 
	name(h1)

marginsplot, scheme(s1mono) legend(order(4 "Extreme DW1 score" 5 "Average DW1 score" 6 "Moderate DW1 score")) ///
    title("Democrats") ytitle("Predicted pr(Vote with Obama)") xlabel(0(2)24)  ///  
	plot1opts(mc(gs1) lc(gs1) m(D) l(solid)) plot2opts(mc(gs5) lc(gs5) m(T) l(dash)) plot3opts(mc(gs9) lc(gs9) m(O) l(dot)) /// 
	ci1opts(lc(gs1)) ci2opts(lc(gs5)) ci3opts(lc(gs9)) /// 
	name(hbw1)

graph display h1
graph save "sdemmargins_color.gph", replace
graph export "sdemmargins_color.emf", as(emf) replace

graph display hbw1
graph save "sdemmargins_bw.gph", replace
graph export "sdemmargins_bw.emf", as(emf) replace

/*

 *** collapsing analysis
 egen sapvotes=count(votesap), by(idno cong)
 egen obamavotes=count(voteobama), by(idno cong)
 egen demvotes=count(votewithdem), by(idno cong)
 
   
 
 
 collapse (max) money10m lnmoney dem awards sapvotes obamavotes /// 
                demvotes senate dwnom1 dwnom2 /// 
				hospitals medicalcenters homehealthservices fqhc hospneed medcenneed totfac facsurplneed homehealthneed fqhcneed capacity peopleperfac rules /// 
				latino HouseRulesMember SAPTarget SAPTargetSen Cardinal PartyLeadership Approps /// 
				age65 black highsch manuf rural transportation unemployed urban veterans population medianinc ///
				age65pct blackpct highschpct manufpct transportationpct unemployedpct urbanpct veteranspct /// 
				dv dvp noppon dpres fr /// 
          (sum) votesap voteobama votewithdem ///
		   , by(cong idno)
		   
gen pctsap=votesap/sapvotes
