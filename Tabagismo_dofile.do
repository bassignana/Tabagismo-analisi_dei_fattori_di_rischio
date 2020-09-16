clear all
set linesize 132
set scrollbufsize 500000

use b960632 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/26 anni/stata11/bcs96x.dta"

*tengo solo gli ID delle persone che non hanno mai fumato a 26 anni(b960632 == 1 ) o di cui non so con certezza se hanno mai fumato (b960632 == .)
keep if b960632 == 1 | b960632 == .

*merge
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/29_anni.dta"
*drop di tutti gli ID degli individui che hanno smesso di fumare prima dei 26 anni perchè, conseguentemente, violano l'assunzione che non abbiano mai fumato prima dei 26 anni
drop if agequit < 26 
*qui, come prima, tengo per ora gli id per cui non sono sicuro di quando hanno iniziato a fumare 
drop _merge

*merge
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/34_anni.dta"
*escludo, come in precedenza tutti gli individui di cui ho la certezza che abbiano già fumato prima dei 26 anni
drop if b7agequt < 26 & b7agequt != -1
drop _merge

*merge
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/38_anni.dta"
*da questo dataset non posso escludere nessuno con sicurezza
drop _merge

*merge
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/42_anni.dta"
*in questo dataset posso rimuovere quelli che sicuramente hanno iniziato prima dei 26 anni
drop if B9AGESTR < 26 & B9AGESTR != -1
drop _merge

*merge
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/46_anni.dta"
*posso rimuovere quelli che sicuramente hanno iniziato prima dei 26 anni
drop if B10AGESTR < 26 & B10AGESTR != -1
drop _merge

save "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/tot_marged_provv.dta", replace
use "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/tot_marged_provv.dta"

*una volta raccolte tutte le informazioni, posso cercare di tenere più osservazioni possibile 
drop B10PSMOK
keep if B9AGESTR > 0 | B10AGESTR > 0 | b960632 == 1 | smoking == 1 | bd7smoke == 1 | bd8smoke == 1 | B9SMOKIG == 1 | B9AGESTR >= 26 | B10SMOKIG == 1 | B10AGESTR >= 26

*inizio a generare le variabili outcome per poi eliminare le osservazioni per le quali non è possibile generarle

*
gen failure_26 = 0
*generando la prima variabile outcome
generate failure_29 = 0
replace failure_29 = 1 if smoking != 1 & smoking !=.
order failure_29, before(b7exsmer)
sort failure_29

*generando la seconda variabile outcome
generate failure_34 = 0
replace failure_34 = 1 if bd7smoke != 0 & bd7smoke !=.
order failure_34, before(b8smokig)
sort failure_29 failure_34

*generando la terza variabile outcome
generate failure_38 = 0
replace failure_38 = 1 if bd8smoke != 0 & bd8smoke !=.
order failure_38, before(B9SMOKIG)
sort failure_29 failure_34 failure_38

*generando la quarta variabile outcome
generate failure_42 = 0
replace failure_42 = 1 if B9SMOKIG != 1 & B9SMOKIG !=.
order failure_42, before(B10SMOKIG)
sort failure_29 failure_34 failure_38 failure_42

*generando la quinta variabile outcome
generate failure_46 = 0
replace failure_46 = 1 if B10SMOKIG != 1 & B10SMOKIG !=.
order failure_46, after(B10AGESTR)
sort failure_29 failure_34 failure_38 failure_42 failure_46

drop if b960632 ==. & smoking ==. & bd7smoke ==. & bd8smoke ==. & B9SMOKIG ==. & B10SMOKIG ==.

*rimuovo gli ID per cui so quando hanno smesso di fumare ma non ho la certezza che abbiano iniziato dopo i 26 anni
drop if failure_34 == 1 & smoking ==.
drop if failure_38 == 1 & bd8smoke ==.
drop if failure_42 == 1 & B9SMOKIG ==.
drop if failure_46 == 1 & B10SMOKIG ==.

keep failure_29 failure_34 failure_38 failure_42 failure_46 bcsid
save "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/tot_marged_provv.dta", replace
********************************************************
*BIG 5

use bcsid c5c1 c5c3 c5e1 c5e10 c5e13 c5g20 c5h27 c5h13 c5o10 c5h22 c5b5 c5b1 c5b7 c5b9 c5d1 c5g16 c5g13 c5m25 c5d7 c5g23 c5g15 c5g2 c5g3 c5h17 c5h11 c5g11 c5h6 c5j3a c5j3b c5j30b c5j29b c5j28b c5j26b c5j18b c5j15b c5h18 c5j15a using "/Users/tommasobassignana/Desktop/dataset survival analysis/16 anni/stata/stata11_se/bcs7016x.dta"

global extra c5c1 c5c3 c5e1 c5e10 c5e13 c5g20 c5h27 
global agreb c5h13 c5o10 c5h22 c5b5 c5b1 c5b7 c5b9 c5d1 c5g16 
global conti c5g13 c5m25 c5d7 c5g23 c5g15
global neuro c5g2 c5g3 c5h17 c5h11 c5g11 
global open c5h6 c5j3a c5j3b c5j30b c5j29b c5j28b c5j26b c5j18b c5j15b c5h18 c5j15a


foreach var of varlist c5b1 - c5b9{
	replace `var' = 0 if `var' == 2
	}

foreach var of varlist c5j3b - c5j30b{
	replace `var' = 0 if `var' == 2
	}

foreach var of varlist $extra{
	drop if `var' < 0
	}
gen extraversion  = c5c1 + c5c3 + c5e1 + c5e10 + c5e13 + c5g20 + c5h27

foreach var of varlist $agreb{
	drop if `var' < 0
	}
gen agreeableness  = c5h13 + c5o10 + c5h22 + c5b5 + c5b1 + c5b7 + c5b9 + c5d1 + c5g16 

foreach var of varlist $conti{
	drop if `var' < 0
	}
gen conscientiousness = c5g13 + c5m25 + c5d7 + c5g23 + c5g15

foreach var of varlist $neuro{
	drop if `var' < 0
	}
gen neuroticism = c5g2 + c5g3 + c5h17 + c5h11 + c5g11 

foreach var of varlist $open{
	drop if `var' < 0
	}
gen openness = c5h6 + c5j3a + c5j3b + c5j30b + c5j29b + c5j28b + c5j26b + c5j18b + c5j15b + c5h18 + c5j15a

keep extraversion bcsid agreeableness conscientiousness neuroticism openness

*merge con il dataset precedentemente creato
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/tot_marged_provv.dta",nogenerate
drop if extraversion ==.
save "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/big5data.dta", replace
********************************************************
*loading delle variabili necessarie per creare le feature per sesso, etnia e stato di fumatore dei genitori
use d003 bcsid using"/Users/tommasobassignana/Desktop/dataset survival analysis/0 anni/stata11/f699a.dta"
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/big5data.dta", nogenerate
keep if extraversion !=.
save "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/variables.dta", replace

use bcsid e258 e259 e247 using"/Users/tommasobassignana/Desktop/dataset survival analysis/0 anni/stata11/f699b.dta"
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/variables.dta", nogenerate
keep if extraversion !=.
save "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/variables.dta", replace

use bcsid sex10 a12_1 e9_3 e10_1 e11_3 e12_1 e13_1 bcsid a12_2 a12_3 a12_1 using "/Users/tommasobassignana/Desktop/dataset survival analysis/10 anni/stata11_se/sn3723.dta"
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/variables.dta", nogenerate
keep if extraversion !=.
save "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/variables.dta", replace

*cleaning for female 
*0 per i maschi
gen female = 0 
replace female = 1 if sex10 ==2 | d003 ==2
replace female =. if sex10 ==. & d003 ==.
drop sex10 d003 

*cleaning for smoking habits of parents
*0 se non hanno mai fumato
generate smoking_hh = 0
*1 se il tempo passato a fumare da uno dei genitori è positivo
replace smoking_hh = 1 if e9_3 !=. | e11_3 !=.
*1 se la madre ha mai fumato
replace smoking_hh = 1 if e10_1 == 1
*1 se il padre ha mai fumato 
replace smoking_hh = 1 if e12_1 == 1
*1 se un altro componente stabile della familia fuma regolarmente
replace smoking_hh = 1 if e13_1 == 1
replace smoking_hh =. if e9_3 ==. & e11_3 ==. & e12_1 ==. & e10_1 ==. & e13_1 ==.
*1 se viene dichiarato il tipo di sigaretta fumata da uno dei genitori
replace smoking_hh = 1 if e258 >=2 | e259 >= 2
drop e258 e259 e9_3 e11_3 e10_1 e12_1 e13_1

*cleaning for ethnicity 
generate etnia = .
*UK
replace etnia = 1 if a12_1 == 1 | a12_2 == 1 | a12_3 == 1 | e247 == 1
*Irish
replace etnia = 2 if a12_1 == 2 | a12_2 == 2 | a12_3 == 2
*EU
replace etnia = 3 if a12_1 == 3 | a12_2 == 3 | a12_3 == 3 | e247 == 2
*west indian
replace etnia = 4 if a12_1 == 4 | a12_2 == 4 | a12_3 == 4 | e247 == 3
*indian
replace etnia = 5 if a12_1 == 5 | a12_2 == 5 | a12_3 == 5
*asian
replace etnia = 6 if e247 == 4
*mixed UK+other
replace etnia = 7 if e247 == 6 | e247 == 7 | e247 == 8 | e247 == 10 | e247 == 11
*other 
replace etnia = 8 if a12_1 >= 6 | a12_2 >= 6 | a12_3 >= 6 | e247 == 14
*. devo per forza farlo
replace etnia =. if a12_1 == . & a12_2 == . & a12_3 == . & e247 == .

drop a12_1 a12_2 a12_3 e247
save "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/variables.dta", replace

*46 anni (per ragioni di dataset manipulation si è diviso per scaglioni di età la generazione di 3 diverse variabili)

*unemployment
*empl46 = 1 se l'attività lavorativa è stata continuativa, 0 altrimenti
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/46_anni_3var.dta", nogenerate
gen empl46 = 1
replace empl46 = 0 if B10CJCONT == 2
replace empl46 = 0 if B10CJCONT == -1
replace empl46 = . if B10CJCONT == .
drop B10CJCONT

*relationships and children
rename B10UFDVDY year_divorce 
gen time_divorce = year_divorce - 1970
replace time_divorce = . if time_divorce < 0
gen dummy_div = 0
replace dummy_div = 1 if time_divorce > 0 
replace dummy_div = 0 if time_divorce ==. 
rename BD10TOTCE tot_ch_46 
rename BD10NCDIE tot_ch_d_46
*tot_ch_46 totale dei figli avuti in totale fino all'ultimo follow up
*tot_ch_d_46 totale dei figli morti in totale al tempo dell'ultimo follow up
*dummy_div = 0 se non si ha mai avuto un divorzio
*time_divorce tempo dello studio in cui è avvenuto il divorzio

*42 anni 
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/42_anni_3var.dta", nogenerate
gen empl42 = 1
replace empl42 = 0 if B9CJCONT == 2
replace empl42 = 0 if B9CJCONT == -1
replace empl42 = . if B9CJCONT == .
drop B9CJCONT
*childrens
rename B9DCHMNY tot_ch_d_42

*38 anni 
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/38_anni_3var.dta", nogenerate
gen empl38 = 1
replace empl38 = 0 if b8cjsame == 2
replace empl38 = 0 if b8cjsame == -1
replace empl38 = . if b8cjsame == .
drop b8cjsame
*childrens
gen tot_ch_d_38 = 0
replace tot_ch_d_38 = 1 if b8livh11 == 2
replace tot_ch_d_38 = 1 if b8livh21 == 2
replace tot_ch_d_38 = 1 if b8livh31 == 2
drop b8livh11 b8livh21 b8livh31

*34 anni
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/34_anni_3var.dta", nogenerate
gen empl34 = 1
replace empl34 = 0 if b7unempy >= 1 & b7unempy <= 8
drop b7unempy b7sepa b8cpdiv
*childrens
gen tot_ch_d_34 = 0

*30 anni
merge 1:1 bcsid using "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/30_anni_3var.dta", nogenerate
gen empl30 = 1
replace empl30 = 0 if unempy >= 1 & unempy <= 8
drop unempy
*childrens
gen tot_ch_d_30 = 0

*26 anni 
gen empl26 = 1
*childrens
gen tot_ch_d_26 = 0

*tempo in anni dello studio dove si è verificato il periodo di unemployment
gen time_unempl = .
replace time_unempl = 18 if empl46 == 0
replace time_unempl = 14 if empl42 == 0
replace time_unempl = 10 if empl38 == 0
replace time_unempl = 6 if empl34 == 0
replace time_unempl = 2 if empl30 == 0
*dummy = 1 se si sono verificati periodi di disoccupazione in qualsiasi periodo
gen dummy_unempl = 0
replace dummy_unempl = 1 if time_unempl !=.

*tempo in anni dello studio dove si è verificato il decesso di un figlio 
gen time_child_death = .
replace time_child_death = 18 if tot_ch_d_46 > 0
replace time_child_death = 14 if tot_ch_d_42 > 0
replace time_child_death = 10 if tot_ch_d_38 > 0
replace time_child_death = 6 if tot_ch_d_34 > 0
replace time_child_death = 2 if tot_ch_d_30 > 0
*dummy = 1 se è avvenuto il decesso di un figlio in qualsiasi periodo
gen dummy_child_death = 0
replace dummy_child_death = 1 if time_child_death !=.

*extra cleaning 
keep if extraversion !=.
drop if failure_29 ==. & failure_34 ==. & failure_38 ==. & failure_42 ==. & failure_46 ==.

*make variables for the wide format

*external variables
*unemployment rate
gen unempRate26 = 8.1
gen unempRate30 = 5.46
gen unempRate34 = 4.75
gen unempRate38 = 5.69
gen unempRate42 = 7.97
gen unempRate46 = 4.9

*GDP
gen GDP26 = 1243709
gen GDP30 = 1418176
gen GDP34 = 1582486
gen GDP38 = 1702252
gen GDP42 = 1706942
gen GDP46 = 1865410

*Household Mortage Rate

gen HhMRate26 = 7.72
gen HhMRate30 = 6.53
gen HhMRate34 = 4.88
gen HhMRate38 = 6.42
gen HhMRate42 = 3.57
gen HhMRate46 = 2.43

*other variables
*age 
gen age26 = 28
gen age30 = 32
gen age34 = 36
gen age38 = 40
gen age42 = 44
gen age46 = 48


*child death dummy per periodi
gen child_death26 = 0 
gen child_death30 = 0
replace child_death30 = 1 if tot_ch_d_30 > 0
gen child_death34 = 0
replace child_death34 = 1 if tot_ch_d_34 > 0
gen child_death38 = 0
replace child_death38 = 1 if tot_ch_d_38 > 0
gen child_death42 = 0
replace child_death42 = 1 if tot_ch_d_42 > 0
gen child_death46 = 0
replace child_death46 = 1 if tot_ch_d_46 > 0

*divorce dummy per periodi 
gen div26 = 0 
gen div30 = 0
replace div30 = 1 if time_divorce <= 30 & time_divorce !=.
gen div34 = 0
replace div34 = 1 if time_divorce <= 34 & time_divorce > 30
gen div38 = 0
replace div38 = 1 if time_divorce <= 38 & time_divorce > 34
gen div42 = 0
replace div42 = 1 if time_divorce <= 42 & time_divorce > 38
gen div46 = 0
replace div42 = 1 if time_divorce <= 47 & time_divorce > 42

*dummy_figli = 1 se si hanno mai avuto figli 
gen dummy_figli = 0
replace dummy_figli = 1 if tot_ch_46 > 0

*draining = 1 se l'avere un figlio risulta molto dispendioso dal punto di vista fisico e/o emotivo
gen draining = 0
replace draining = 1 if kidphys == 1 | kidemot == 1

drop year_divorce kidphys kidemot tot_ch_d_42 tot_ch_46 tot_ch_d_46 time_divorce tot_ch_d_38 tot_ch_d_34 tot_ch_d_30 tot_ch_d_26 time_unempl time_child_death

*from wide to long 
rename failure_29 failure_30
reshape long failure_ empl age zage HhMRate GDP unempRate child_death div, i(bcsid)

save "/Users/tommasobassignana/Desktop/dataset survival analysis/datasets to link/variables.dta", replace

*from long to duration format
snapspan bcsid _j failure_ dummy_unempl dummy_child_death dummy_div, gen(date0)
rename _j date1
*drop if date1 == 26

*stset
stset date1,origin(date1) id(bcsid) failure(failure_ == 1)
********************************************************

*NON PARAMETRIC ANALYSIS

*grafico delle KM estimate
global dummy female smoking_hh dummy_div dummy_unempl dummy_figli draining dummy_child_death


sts graph, by(smoking_hh) ci risktable(, order(1 "smoking_hh=0" 2 "smoking_hh=1") failevents) 
sts graph, by(dummy_unempl) ci risktable(, order(1 "dummy_unempl=0" 2 "dummy_unempl=1") failevents) 
sts graph, by(dummy_child_death) ci risktable(, order(1 "dummy_child_death=0" 2 "dummy_child_death=1") failevents) 
*failures in parentesi e vicino alle parentesi dovrebbe esserci il numero di soggetti a rischio in quel tempo 


*teoricamente identiche, posso però confrontare empiricamente questi due diversi stimatori
sts generate kmS = s /* obtain K-M survivor estimate */
sts generate naH = na /* obtain N-A cumulative hazard estimate */
gen naS = exp(-naH) /* calculate N-A survivor estimate */
gen kmH = -log(kmS)/* calculate K-M cumulative hazard estimate */
label var kmS "K-M" 
label var naS "N-A" 
label var kmH "K-M" 
label var naH "N-A"
*plottiamo la comparazione tra le due survivor functions
line kmS naS _t, c(J J) sort
*plottiamo la comparazione tra le due cumulative hazard functions
line naH kmH _t, c(J J) sort
*i risultati dimostrano che i due approcci sono presochè simili in questo caso


*stima del tempo di sopravvivenza medio 
foreach var of varlist $dummy{
	stci, by(`var') rmean
}

*test per l'uguaglianza delle funzioni di sopravvivenza tra due o più gruppi 

foreach var of varlist $dummy{
	sts test `var', logrank
}
*H0 uguaglianza 
*dato che p value grande non posso rifiutare H0
********************************************************
*SEMI_PARAMETRIC ANALYSIS
* model building
global big5 extraversion conscientiousness openness neuroticism agreeableness
global VTD age unempRate GDP HhMRate   

stcox   smoking_hh $big5 dummy_child_death female empl, tvc($VTD) texp(ln(_t))
stcox   smoking_hh $big5 dummy_child_death female empl, tvc($VTD) texp(exp(_t))
stcox   smoking_hh $big5 dummy_child_death female empl, tvc($VTD) texp((_t))

foreach var of varlist $dummy{
	stcox   smoking_hh $big5 dummy_child_death female empl if `var' == 0
	
	stcox   smoking_hh $big5 dummy_child_death female empl if `var' == 1
}


stcox   smoking_hh $big5 dummy_child_death female empl
*verifica dell'assunzione di proporzionalità
estat phtest, detail
*goodness of fit
predict cs, csnell
stset cs, fail(failure_)
sts gen H = na
line H cs cs, sort ytitle("") legend(cols(1))
drop H cs
*leverage point
stcox   smoking_hh $big5 dummy_child_death female empl

predict ld, ldisplace
scatter ld _t, yline(0) mlabel(bcsid) msymbol(i)
