// add boundaries
Map.addLayer(studyarea, {}, "Study area", true);

// create sentinel 5P collection for 2019
var no2_2019 = ee.ImageCollection('COPERNICUS/S5P/NRTI/L3_NO2')
  .select('NO2_column_number_density')
  .filterDate('2019-01-01', '2019-12-31')
  .filterBounds(studyarea)
  .mean();

// create sentinel 5P collection for 2010 - 1
var no2_2020_1 = ee.ImageCollection('COPERNICUS/S5P/NRTI/L3_NO2')
  .select('NO2_column_number_density')
  .filterDate('2020-01-01', '2020-03-17')
  .filterBounds(studyarea)
  .mean();

// create sentinel 5P collection for 2010 - 2
var no2_2020_2 = ee.ImageCollection('COPERNICUS/S5P/NRTI/L3_NO2')
  .select('NO2_column_number_density')
  .filterDate('2020-03-18', '2020-05-02')
  .filterBounds(studyarea)
  .mean();

// create sentinel 5P collection for 2010 - 3
var no2_2020_3 = ee.ImageCollection('COPERNICUS/S5P/NRTI/L3_NO2')
  .select('NO2_column_number_density')
  .filterDate('2020-05-03', '2020-06-22')
  .filterBounds(studyarea)
  .mean();
  
// create sentinel 5P collection for 2010 - 4
var no2_2020_4 = ee.ImageCollection('COPERNICUS/S5P/NRTI/L3_NO2')
  .select('NO2_column_number_density')
  .filterDate('2020-06-23', '2020-07-31')
  .filterBounds(studyarea)
  .mean();

// Export to drive
Export.image.toDrive({
  image: no2_2019,
  description: 'no2_2019',
  scale: 2000,
  region: poly,
  fileFormat: 'GeoTIFF',
});
Export.image.toDrive({
  image: no2_2020_1,
  description: 'no2_2020_1',
  scale: 2000,
  region: poly,
  fileFormat: 'GeoTIFF',
});
Export.image.toDrive({
  image: no2_2020_2,
  description: 'no2_2020_2',
  scale: 2000,
  region: poly,
  fileFormat: 'GeoTIFF',
});
Export.image.toDrive({
  image: no2_2020_3,
  description: 'no2_2020_3',
  scale: 2000,
  region: poly,
  fileFormat: 'GeoTIFF',
});
Export.image.toDrive({
  image: no2_2020_4,
  description: 'no2_2020_4',
  scale: 2000,
  region: poly,
  fileFormat: 'GeoTIFF',
});