// create a counter/series over a day of year 213
var doyList = ee.List.sequence(1, 210, 7);



// create sentinal 5P collection 2019/2020 to do a time series
var collectionAll = ee.ImageCollection('COPERNICUS/S5P/NRTI/L3_NO2')
  .select('NO2_column_number_density')
  .filterDate('2019-01-01', '2020-07-30')
  .filterBounds(metro);
  
  
// create sentinal 5P collection 2020
var collection20 = ee.ImageCollection('COPERNICUS/S5P/NRTI/L3_NO2')
  .select('NO2_column_number_density')
  .filterDate('2020-01-01', '2020-07-30')
  .filterBounds(metro);


// create sentinal 5P collection 2019
var collection19 = ee.ImageCollection('COPERNICUS/S5P/NRTI/L3_NO2')
  .select('NO2_column_number_density')
  .filterDate('2019-01-01', '2019-07-30')
  .filterBounds(metro);


// time series by year
var series1 = ui.Chart.image.doySeriesByYear(
    collectionAll,'NO2_column_number_density', metro, ee.Reducer.mean(), 500, ee.Reducer.mean(), 1, 210);

// time series by year for 2020
var chart20 = ui.Chart.image.series(collection20, metro, ee.Reducer.mean(), 30);

// time series by year for 2019
var chart19 = ui.Chart.image.series(collection19, metro, ee.Reducer.mean(), 30);

    
print (series1, chart20, chart19); 





