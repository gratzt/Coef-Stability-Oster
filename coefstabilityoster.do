
///////////////////////////////////////////////////////////////

// Adjust treatment coeff
// Calculates the adjusted coeffecient values of a treatment variable based on the 
// proportion of selction derived from observables. Follows section 3.2. of Emily Oster's 2019 article
// "Unobservable Selection and Coefficient Stability: Theory and Evidence". 
// To be run after a regression command. Bootstapping standard errors is allowed.  

//  Argugments
//  1) Treatment Variable 
//  2) List of observed controls
//	3) The theoretical R squared value(Rmax) from a regression with unobservables included in main model e.g. 1
//	4) The degree of selection on unobservables relative to observables e.g. reasonable bounds are [0,1]
//	5) Bootstrap the standard errors? "Yes" or "No"
//  6) Number of replications for bootstrapping
//  7) Set seed
//	8) Cluster standard errrors: Yes or No


cap program drop coefstability
program define coefstability
	cap drop tempsamp
	gen tempsamp = e(sample)
	// Extract values from full model without hypothetical unobservables
	local rtilda = e(r2)
	local depvar = e(depvar)
	if "`8'" == "Yes" {
		local cluvar = e(clustvar)
		local clunum = e(N_clust)
		}
	matrix coefs = e(b)
	matrix temp = coefs[1,"`1'"]
	local betatilda = temp[1,1]
	
	// Model with only treatement
	qui reg `depvar' `1' if tempsamp == 1
	local rcirc = e(r2)
	matrix coefs = e(b)
	matrix temp = coefs[1,"`1'"]
	local betacir = temp[1,1]
	
	display ""
	display "Unadjusted Beta, Full Model:    `betatilda'"
	display ""
	display "R - Squared:    `rtilda'"
	display ""
	display "Unadjusted Beta, Model with Treatment only:    `betacir'"
	display ""
	display "R - Squared:    `rcirc'"
	display ""
	
	local badjusted=`betatilda' - `4'*((`3'-`rtilda')/(`rtilda'-`rcirc'))*(`betacir'-`betatilda')
	display "Adjusted Beta with Rmax = `3' and Delta = `4':    `badjusted'"
	display ""

    local denum = ((`3'-`rtilda')/(`rtilda'-`rcirc'))*(`betacir'-`betatilda')
	local solveddelta = `betatilda' / `denum'

	if "`5'" == "Yes" {
	quietly {
		// Define arguements from program betaadjust in a way betaddjust_se can use.
		tempfile preboot
		save `preboot'
		
			keep if tempsamp == 1
			tempfile bdata
			save `bdata'
			
			if `6' > 400 {
				set matsize `6'
			}
			
			matrix storebetas = J(1,`6',.)
			set seed `7'
			
			forvalues y = 1/`6' {
				use `bdata', clear
				if "`8'" == "No" {
					bsample _N
				}
				if "`8'" == "Yes" {
					bsample `clunum', cluster(`cluvar')
				}
				
				 qui regress `depvar' `1' `2'
					local rtilda = e(r2)
					local depvar = e(depvar)
					matrix coefs = e(b)
					matrix temp = coefs[1,"`1'"]
					local betatilda = temp[1,1]
		
				 qui regress `depvar' `1'
					local rcirc = e(r2)
					matrix coefs = e(b)
					matrix temp = coefs[1,"`1'"]
					local betacir = temp[1,1]	
				
				matrix storebetas[1, `y'] = `betatilda' - `4'*((`3'-`rtilda')/(`rtilda'-`rcirc'))*(`betacir'-`betatilda')
				
			}
		
		use `preboot', clear
	
	matrix tostore = storebetas'
	svmat tostore	
	qui summ tostore1
	}
	
	display "Standard Error :    `r(sd)'"
	display ""
	local lci = `badjusted' - 1.96 * `r(sd)'
	local hci = `badjusted' + 1.96 * `r(sd)'
    display "95% Confidence Interval:    `lci' to `hci'"	
	display ""
	drop tostore1 tempsamp
	
	}
	display "Adjusted Beta Set to Zero: Delta Solved for"
	display "Delta:    `solveddelta'"
	
end




