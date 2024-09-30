# Physical Long-Term Monthly Streamflow Forecasting (PLTMSF) Model Procedure

This model integrates the SWATPlus model and ARIMA model. Follow these steps:

1. Calibrate the SWATPlus model using SWATPlusCUP. Obtain the optimal parameters (saved as Calibration.cal in the SWATPlusCUP project directory). Evaluate the calibration and validation performance.

2. Identify similar years to the forecasting period using DetectSimiliarityYearUsingMeteInfo.ipynb. Save the results as "SimilarityYearsTNH.csv" in the project's result directory (TNH represents the station name abbreviation).

3. Prepare meteorological input data for the SWATPlus model using PrepareMeteInputForSWATPlus.ipynb. Use observed data for years preceding the forecast year and similar year data for the forecast year. Store results in "ClimateInputforSWATPlus" within the results directory.

4. Input the prepared meteorological data for the forecast year using the SWATPlus editor. Save the results as a scenario file.

5. Create a SWATPlus Toolbox project using the TxtInOut from step 4. Replace "Calibration.cal" in the chg row of file.fio in the Scenario's TxtInOut (both Default and Toolbox directories). Import observed streamflow data into the SWATPlus Toolbox.

6. Run the SWATPlus model via SWATPlus Toolbox, adjusting the simulation period as needed. Export forecasting results to the result/SWATPlusPredUsingSimYearData directory (e.g., "Channel_3_Monthly_River-Flow_TNH_pred2015.csv").

7. Develop an ARIMA model using BuildArimaModelTNH.ipynb to forecast the next 12 months' seasonal trend pattern. Use observed flow data from the forecast year. Store results in the result/ARIMAPredData directory (e.g., "seasonal_decompose_multiplicative_arima_pred_tnh_2015_2019.csv").

8. Refine the SWATPlus monthly flow predictions using ARIMA model forecasts. The correction factor is calculated based on the sum of ARIMA predictions during the flood season (May to November for TNH station) with the sum of SWATPlus predictions for the same period.

# Calibration, Validation, and Test Information

## Tangnaihai, Guide, and Xunhua Stations

1. Entire period: 1972-2019 (48 years, 576 months)
2. Calibration period: 1972-2009 (38 years, 456 months, 79.2% of total data)
3. Validation period: 2010-2014 (5 years, 60 months, 10.4% of total data)
4. Test period (Simulated prediction): 2015-2019 (5 years, 60 months, 10.4% of total data)
