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

