$ONTEXT
AGRIVOPT - Agrivoltaics revenue optimisation model

This linear optimisation model aims at maximising the combined revenue of solar power
and crop yield on a predefined land area.
Data on PV technology and solar radiation is optained from PVGIS (https://ec.europa.eu/jrc/en/pvgis)


Developed by Dana Kirchem at the Code4Green Hackathon 2020
$OFFTEXT

* =============================================================================
* --- Load Input Data ---------------------------------------------------------
* =============================================================================

$gdxin  'inputData.gdx'
$loaddc crop
$loaddc p_PV
$loaddc p_land
$loaddc ts_climate
$gdxin
