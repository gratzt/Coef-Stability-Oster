# Coef-Stability-Oster
Implements a test of coefficient stability under different assumptions of sorting on unobservables.

Omitted variable bias constrains interpretation of coefficients of interest. In Oster's (2019) paper, she developes a methodology for dealing with omitted variable bias and how it effects coeficeint stability. Researchers may use Oster's methodolgy to examine the extent to which different assumptions regarding omitted variable bias effect results. For more information on the the methodolgy please see Oster's paper cited below.  

The code here implements Oster's 'Restricted Estimator' (see section 3.2 of the below citation), with or without  bootstrapped standard errors. The package is meant to be used as a post-estimation regression command. The program takes 8 arguments:  

    1) Treatment Variable 
    2) List of observed controls
    3) The theoretical R-squared value(Rmax)
    4) The degree of selection on unobservables relative to observables, reasonable bounds are [0,1]
    5) Whether or not to bootstrap the standard errors: "Yes" or "No"
    6) Number of replications for bootstrapping
    7) Numeric to set the seed for bootstrapping
    8) Whether or not standard errors should be clustered: "Yes" or "No"

 
Below implements the program on the built-in Stata dataset auto.

~~~

clear
do "./Coef-Stability-Oster/coefstabilityoster.do"

sysuse auto
split make, gen(newvar)
rename newvar1 company

** Simple OLS
reg mpg gear_ratio, vce(cluster company)

** Full model
reg mpg gear_ratio price weight length displacement, vce(cluster company)

** Calculate adjusted beta without standard errors
coefstability "gear_ratio" "price weight length displacement" 0.75 0.5 "No"

** Calculate adjusted beta with standard errors
reg mpg gear_ratio price weight length displacement, vce(cluster company)
coefstability "gear_ratio" "price weight length displacement" 0.75 0.5 "Yes" 100 0 "Yes"

~~~

Output from the last command yields:

~~~

Unadjusted Beta, Full Model:    1.314793651862817

R - Squared:    .670529484533429

Unadjusted Beta, Model with Treatment only:    7.812835398404356

R - Squared:    .379674514895322

Adjusted Beta with Rmax = 0.75 and Delta = 0.5:    .4270613092394781

Standard Error :    1.8247806983949

95% Confidence Interval:    -3.149508859614526 to 4.003631478093482

Adjusted Beta Set to Zero: Delta Solved for
Delta:    .7405349499700937

~~~

The coefficient of interest, the gear ratio in this instance, is 1.314 in our full model. If we assume a theoretical max R-squared value of 0.75 and 50% of the amount of sorting on observables applying to unobserved variables, the coefficient of the gear ratio is attenuated. The new adjusted coefficient on the gear ratio is 0.427 with a standard error of 1.825. "Adjusted Beta Set to Zero: Delta Solved for" indicates that if 74.1% of the observed sorting on covariates in the full model applied to unobservables there would be no main effect of the gear ratio i.e. the gear ratio coefficient would be zero.  

Oster, E. (2019). Unobservable selection and coefficient stability: Theory and evidence. Journal of Business & Economic Statistics, 37(2), 187-204.
