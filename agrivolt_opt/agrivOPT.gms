Sets
t                        time step (h or days?)
*sun(t)                   hours of daily sunshine (h) //not necessary when daily energy production is already given as input
crop                     crop types
panel                    solar panels



*------- Input data ------------
Parameters
*------- PV data ---------------
energy(panel,t)          Average daily energy production from the given PV system (kWh per day)
*NP                       Nominal power of the PV system (kWp)
*PV(t)                    PV system power from radiation (W)
*loss                     PV System losses (%)
PV_size(panel)           size (i.e. land requirement) of each solar panel (m2)
capex_PV                 capital cost for installed PV (€)
opex_PV                  operational and maintenance cost for installed PV(€)
price_PV                 market price for PV (€ per kWh)


*------ Crop data -------------
plant_cycle(crop,t)      times at which each crop can be harvested (months)
size_crop(crop)
water(crop,t)            amount of water that crop requires per time step t
price_crop(crop)         market price for crop (€ per kg)
crop_loss(crop)          losses of planted crop that cannot be harvested (%)


*------ Climate data ----------
percipitation(t)         percipitation in time step t
temperature(t)           temperature in time t


*------ Land data ----------
landsize                 total size of land available
landvalue                soil quality indicator (e.g. amount of nutrients in the soil)

;

*------ Variables ----------------
*------ Objective variable -------
Positive variable
revenue_tot               Total revenue of the farmer
;

*------ Decision variables -------
Positive variables
solarpanels               Number of solar panels that should be installed on the field
amount_crop(crop)         Amount of crop that should be purchased of each crop type (kg)
*amount_water             Amount of water used on land (m3) //try to incorporate, but maybe future feature
;

*------ Declaration of equations ----
Equations
*------ Objective function ----------
revenue                   revenue function
*------ Constraints -----------------

;

*------ Formulation of equations ---
*------ Objective function ---------
* Maximise the solar energy produced, the potential harvest yield
revenue ..

revenue_tot =E= sum (t,
                     sum(panel, solarpanels * E_d(panel, t) * price_PV)        //sum of value of produced solar power of each installed panel in each time step
                +
                     sum(crop, amount_crop(crop) * (1-crop_loss) * price_crop(crop) * plant_cycle(crop, t)) //sum of value of harvest from each crop
                )
;

*------ Constraints -----------
* Land size of the field limits the amount of solar panels that can be installed
landsize =G= sum(panel, solarpanels * PV_size(panel))

* Land size limits the amount of crop that can be planted
landsize =G= sum(crop, amount_crop(crop) * size_crop(crop)) //this oesn't take into account the plant cycle yet, revise

* solar power is limited by the available solar radiation (hours of sunshine per day?)
* crop growth is limited by water requirements of the crop
* limited water availability
* crop growth is limited by percipitation in the area
* crop growth depends on average, minimum, maximum temperature
* crop growth is limited by nutrients in the soil (soil quality, pH values),could be approx by land value data
* crop growth depends on shading by solar panels
* harvest is constrained by the time the crop needs to grow, minimum time of each crop on the field

;


*----------- SOLVE -----------------

model agrivOPT / all /;

*limits?

solve agreste maximizing revenue using lp;

*------ Output ---------------
* number of solar panels that should be installed
* type of crop that should be planted in each time step
* total revenue of farmer
* revenue of solar energy
* revenue of harvest

