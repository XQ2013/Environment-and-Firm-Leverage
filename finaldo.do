*************************************************
/* Environment& firm leverage*/
/* using compustat& KLD data source*/
*************************************************


//Merge data

use "/Users/xiqia/Downloads/45884abe6bf48e82.dta"
 
gen cusip6N=substr(cusip,1,6)
 
rename fyear year
 
drop if cusip==""
duplicates drop cusip year, force
 
save "/Users/tangyubing/Desktop/45884abe6bf48e82.dta", replace
 
use "/Users/tangyubing/Desktop/45884abe6bf48e82.dta"
 
gen cusip6N= substr(cusip,1,6)
duplicates drop cusip year, force
drop if cusip==""
joinby year cusip6N using "/Users/tangyubing/Desktop/45884abe6bf48e82.dta", unmatched(none)
 
drop if missing (at)
 
drop if real(sic)>5999 & real(sic)<7000


drop if real(sic)>4899 & real(sic)<5000


keep if fic=="USA"

drop if sale<=0


save "C:\Users\xiqia\Downloads\kld.dta", replace
 
 
 
use "C:\Users\xiqia\Downloads\kld.dta", clear
//// generating new variables


//table1
//environment index
gen envindex=env_str_a+env_str_b+env_str_c+env_str_d+env_str_x


//prefferd stocks
//=pstkrv(if missing=pstkl; if still missing=pstk)
gen preferredstocks=pstkrv
replace preferredstocks=pstkl if (preferredstocks==.)
replace preferredstocks=pstk if (preferredstocks==.)


//leverage
// Market Leverage= Long-term debt/(total debt+market vaule of equity)
gen marketleverage=dltt/[at-ceq+(prcc_f*csho)] 
gen bookleverage=dltt/at // Long-term debt/book value of total assets




//Control variables
gen totalassets=at //Total book value of assets 
gen totalsales= sale //Sales (millionsofdollars)
gen markettobook=(prcc_f*csho)/(seq+txdb+itcb-preferredstocks)	//Market value of equity/bookvalueofequity
gen fatota=ppent/at // Fixed assets/total assets= property,plant&Equip/Assets_total
gen roa=ni/at // Return to assets =Total income/ Average of total assets
gen dividend = (dvc>0)     //Dividend dummythatequalsoneifdividendispaid//
gen assetstosales=sale/at 
gen rdtosale=xrd/sale  // R&D expenses/total sales( if missing=0)
replace rdtosale=0 if (rdtosale==.)	// R&D expenses/total sales( if missing=0)
gen sgaexpensestosale=xsga/sale 	// selling, general and administrative expenses/ total sales


//other firm charactristics
//Sales growth(percent)
bys cusip (year):gen n=_n
by cusip:gen gr=[sale/sale[_n-3]]^(1/3)-1


gen lexpenses=xlr/emp  // Labor Expenses per workers= Labor Expenses/ # of employees
gen prexpenses=xpr/emp // Pension and retirement expenses per workers


//table2,3

//envirionment Index :envindex
// Long-term debt/(totaldebt+marketvalue of equity)t-1
by cusip:gen nmarketleverage= dltt/[at[_n-1]-ceq[_n-1]+(prcc_f[_n-1]*csho[_n-1])]
//Long-term debt/total book value of assets t-1
by cusip:gen nbookleverage=dltt/at[_n-1] 
//Market valueofequity/bookvalueofequity: markettobook
//log of sales
gen logsales= log(sale)
//Fixed assets/totalassets: fatota
//Return on assets: roa
// R&D expenditures/totalsales: rdtosale 
// Selling, general,andadministrative expenses/total sales:sgaexpensestosale
// Dividend dummy :dividend
//Total sales/ total assets
gen salestoassets = at/sale 


//table 4
//Change in environment index between year t-1 and year t
by cusip:gen denvindexa=envindex-envindex[_n-1]
//Change in environment index between year t-2 andyear t-1
by cusip:gen denvindexb=envinde[_n-2]-envindex[_n-1]
//Change in environment index between year t-3 andyear t-2
by cusip:gen denvindexc=envinde[_n-3]-envindex[_n-2]
//Change inlong-termdebt/(totaldebt+marketvalueofequity) between year t-1 and year t
by cusip:gen dmarketleveragea=marketleverage-marketleverage[_n-1]
//Change inlong-termdebt/(totaldebt+marketvalueofequity) between year t-2 andyear t-1
by cusip:gen dmarketleverageb=marketleverage[_n-1]-marketleverage[_n-2]
//Change inlong-termdebt/(totaldebt+marketvalueofequity) between year t-3 andyear t-2 
by cusip:gen dmarketleveragec=marketleverage[_n-2]-marketleverage[_n-3]

//Change inmarketvalueofequity/bookvalueofequity between year t-1 andyear t
by cusip:gen dbookleverage=bookleverage-bookleverage[_n-1]
//Change inlogofsalesbetweenyear t-1 and year t 
by cusip:gen dlogsales=logsales-logsales[_n-1]
//Change infixedassets/totalassets between year t-1 and year t
by cusip:gen dfatota=fatota-fatota[_n-1]
//Change inreturnonassetsbetweenyear t-1 and year t
by cusip:gen droa=roa-roa[_n-1]
//Change inR&Dexpenditures/totalsales between year t-1 andyear t 
by cusip:gen drdtosale =rdtosale -rdtosale[_n-1]
//Change inselling,general,andadministrativeexpenses/total sales betweenyear t-1 andyear t 
by cusip:gen dsgaexpensestosale=sgaexpensestosale-sgaexpensestosale[_n-1]
//Change dividenddummy that equals one if dividend is paid between year t-1 and year t 
by cusip:gen ddividend=dividend-dividend[_n-1]
//Change intotalsales/totalassetsbetweenyear t-1 andyear t
by cusip:gen dsalestoassets=salestoassets-salestoassets[_n-1]



//table 5
// Tobin'sQ=(book value of assets- book value of equity+market value of equity)/assets
gen tobinsq=(at-seq+prcc_f*csho)/at           


//drop missing data
drop if ( envindex==.)
drop if missing(marketleverage)
drop if missing(bookleverage)
drop if missing(gr)

//export data
ssc install savesome

savesome cusip n sic envindex preferredstocks marketleverage bookleverage totalassets totalsales 	///
markettobook fatota roa dividend assetstosales rdtosale sgaexpensestosale gr lexpenses prexpenses ///
nmarketleverage nbookleverage logsales salestoassets denvindexa denvindexb denvindexc dmarketleveragea ///
dmarketleverageb dmarketleveragec dbookleverage dlogsales dfatota droa drdtosale dsgaexpensestosale ///
ddividend dsalestoassets using finaldata

use "C:\Users\xiqia\Downloads\finaldata.dta", clear



//relation testing

//table 1 
//Summary statisticsonfirmcharacteristics
ssc install psmatch2

//index>0;index=0
table envindex
summarize marketleverage bookleverage totalassets totalsales markettobook fatota roa ///	 
 dividend assetstosales rdtosale sgaexpensestosale  gr lexpenses prexpenses

gen groupa=(envindex>0)
gen sic2N=substr(sic,1,2)

psmatch2 groupa totalassets, out(bookleverage) logit  noreplacement
encode sic2N,gen(sic2n)
gen pscore1 = sic2n*10+_pscore
psmatch2 groupa , out(marketleverage) logit pscore(pscore) noreplacement caliper(0.5)
drop if missing(_weight)

by _nn, sort : summarize marketleverage bookleverage totalassets totalsales markettobook fatota roa ///	 
 dividend assetstosales rdtosale sgaexpensestosale  gr lexpenses prexpenses

mvtest means	marketleverage		, by(_nn)
mvtest means	bookleverage		, by(_nn)
mvtest means	totalassets		, by(_nn)
mvtest means	totalsales		, by(_nn)
mvtest means	markettobook		, by(_nn)
mvtest means	fatota		, by(_nn)
mvtest means	roa		, by(_nn)
mvtest means	dividend		, by(_nn)
mvtest means	assetstosales		, by(_nn)
mvtest means	rdtosale		, by(_nn)
mvtest means	sgaexpensestosale		, by(_nn)
mvtest means	gr		, by(_nn)
mvtest means	lexpenses		, by(_nn)
mvtest means	prexpenses		, by(_nn)
	

median 	marketleverage		, by(_nn)
median 	bookleverage		, by(_nn)
median 	totalassets		, by(_nn)
median 	totalsales		, by(_nn)
median 	markettobook		, by(_nn)
median 	fatota		, by(_nn)
median 	roa		, by(_nn)
median 	dividend		, by(_nn)
median 	assetstosales		, by(_nn)
median 	rdtosale		, by(_nn)
median 	sgaexpensestosale		, by(_nn)
median 	gr		, by(_nn)
median 	lexpenses		, by(_nn)
median 	prexpenses		, by(_nn)



 
//table 2
//Relation between leverage and the environment index
use "C:\Users\xiqia\Downloads\finaldata.dta", clear
 
encode cusip, gen (m)
xtset m n


//model 1: dv: market leverage ratio; iv: all control+ lag
xtreg marketleverage nbookleverage markettobook logsales fatota roa rdtosale sgaexpensestosale	///
dividend salestoassets
est store model1

//model 2: dv: market leverage ratio; iv: all control+lag+index
xtreg marketleverage envindex nbookleverage markettobook logsales fatota roa rdtosale sgaexpensestosale	///
dividend salestoassets
est store model2

//model 3: dv: book leverage ratio; iv: all control+ lag +index
xtreg bookleverage envindex nbookleverage markettobook logsales fatota roa rdtosale sgaexpensestosale	///
dividend salestoassets
est store model3


//model 4: dv: market leverage ratio; iv: all control
xtreg marketleverage envindex markettobook logsales fatota roa rdtosale sgaexpensestosale	///
dividend salestoassets
est store model4

//model 5: dv: market leverage ratio; iv: all control+index
xtreg marketleverage envindex markettobook logsales fatota roa rdtosale sgaexpensestosale	///
dividend salestoassets
est store model5

//model 6: dv: book leverage ratio; iv: all control+index
xtreg bookleverage envindex markettobook logsales fatota roa rdtosale sgaexpensestosale	///
dividend salestoassets
est store model6


ssc install estout, replace
esttab model1 model2 model3 model4 model5 model6

//table 3
set matsize 10000
//model 7: dv: market leverage ratio; iv: all control+ lag
xtreg marketleverage nbookleverage markettobook logsales fatota roa rdtosale sgaexpensestosale	///
dividend salestoassets i.m,fe
est store model7

////model 8: dv: market leverage ratio; iv: all control+lag+index
xtreg marketleverage envindex nbookleverage markettobook logsales fatota roa rdtosale sgaexpensestosale	///
dividend salestoassets
est store model8
