$ONTEXT
AGRIVOPT - Agrivoltaics revenue optimisation model

This linear optimisation model aims at maximising the combined revenue of solar power
and crop yield on a predefined land area.
Data on PV technology and solar radiation is optained from PVGIS (https://ec.europa.eu/jrc/en/pvgis)


Developed by Dana Kirchem at the Code4Green Hackathon 2020
$OFFTEXT

* Activate end of line comments and set comment character to '//'
$oneolcom
$eolcom //
$onempty   // Allow for empty data definitions

*======= Sets defining the model structure =====================================
Sets
t                        time step (days)
         /t000*t365/      //model can be run for maximum a full year
*sun(t)                   hours of daily sunshine (h) //not necessary when daily energy production is already given as input
crop                     crop types
*panel                    solar panels

*======= Input data ============================================================
*------- PV data ---------------------------------------------------------------
param_PV                  PV related parameters /
         energy           Average daily energy production from the given PV system (kWh per day)
*NP                       Nominal power of the PV system (kWp)
*PV(t)                    PV system power from radiation (W)
*loss                     PV System losses (%)
         PV_size          size (i.e. land requirement) of each solar panel (m2)
         capex_PV         capital cost for installed PV (€)
         opex_PV          operational and maintenance cost for installed PV(€)
         price_PV         market price for PV (€ per kWh)
/

*------ Crop data --------------------------------------------------------------
param_crop                crop related parameters /
         plant_cycle      times at which each crop can be harvested (months)
         size_crop        land requirement of each individual crop type (m2)
         fertilizer       amount of fertilizer that crop requires
         water            amount of water that crop requires per time step t
         price_crop       market price for crop (€ per kg)
         crop_loss        losses of planted crop that cannot be harvested (%)
/

*------ Land data --------------------------------------------------------------
param_land               land related parameters /
landsize                 total size of land available (m2 or ha)
landvalue                soil quality indicator (e.g. amount of nutrients in the soil)
/

*------ Climate data -----------------------------------------------------------
param_climate         climate related parameters /
percipitation         percipitation in time step t
temperature           temperature in time t
/
;

Parameters
p_PV(param_PV, t)                PV related input data
p_crop(crop, param_crop, t)      Crop related input data
p_land(param_land)               Land related input data
ts_climate(param_climate, t)     Time series climate data
;

*======= Variables =============================================================
*------ Objective variable -----------------------------------------------------
Positive variable
revenue_tot               Total revenue of the farmer
;

*------ Decision variables -----------------------------------------------------
Positive variables
solarpanels               Number of solar panels that should be installed on the field
amount_crop(crop)         Amount of crop that should be purchased of each crop type (kg)
*amount_water             Amount of water used on land (m3) //try to incorporate, but maybe future feature
;

*------ Declaration of equations -----------------------------------------------
Equations
 // Objective function
revenue                  revenue function

 // Constraints
max_solar                Maximum number of solar panels that can be installed on a field
max_crop(t)              Maximum amount of crop that can be planted on the field
;

*------ Formulation of equations -----------------------------------------------

*------ Objective function -----------------------------------------------------
* Maximise the solar energy produced, the potential harvest yield
revenue ..

revenue_tot =E= sum (t,
                     (solarpanels * p_PV('energy', t) * p_PV('price_PV', t))                            //sum of value of produced solar power of each installed panel in each time step
                +
                     sum(crop, amount_crop(crop) * (1-p_crop(crop,'crop_loss',t) * p_crop(crop,'price_crop',t) * p_crop(crop,'plant_cycle', t)) //sum of value of harvest from each crop
                )
;

*------ Constraints ------------------------------------------------------------
* Land size of the field limits the amount of solar panels that can be installed
max_solar ..

p_land('landsize') =G= sum(t, solarpanels * p_PV('PV_size', t))
;

* Land size limits the amount of crop that can be planted in different time steps
max_crop(t) ..

p_land('landsize') =G= sum(crop, amount_crop(crop) * p_crop(crop, 'size_crop', t)) //this doesn't take into account the plant cycle yet, revise
;


* Further constraints, which would need to be implemented:

* Solar power is limited by the available solar radiation (hours of sunshine per day?)
* Crop growth is limited by water requirements of the crop
* Limited water availability
* crop growth is limited by percipitation in the area
* crop growth depends on average, minimum, maximum temperature
* crop growth is limited by nutrients in the soil (soil quality, pH values),could be approx by land value data
* crop growth depends on shading by solar panels
* harvest is constrained by the time the crop needs to grow, minimum time of each crop on the field

;


*============= SOLVE ===========================================================

model agrivOPT / all /;

*limits?

solve agrivOPT maximizing revenue using lp;

*============ Output ===========================================================
* Outputs of the model should be:

* number of solar panels that should be installed
* type of crop that should be planted in each time step
* total revenue of farmer
* revenue of solar energy
* revenue of harvest

