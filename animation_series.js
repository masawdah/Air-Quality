// create a counter/series over a day of year 213
var doyList = ee.List.sequence(61, 205, 7);

// create sentinal 5P collection
var collection = ee.ImageCollection('COPERNICUS/S5P/NRTI/L3_NO2')
  .select('NO2_column_number_density')
  .filterDate('2020-03-01', '2020-07-30')
  .filterBounds(polygon);

// composite each 7 days together and reduce them by median/mean
var ndviCompList = doyList.map(function(startDoy) {

  startDoy = ee.Number(startDoy);
  

  return collection
    .filter(ee.Filter.calendarRange(startDoy, startDoy.add(6), 'day_of_year'))
    .reduce(ee.Reducer.median());
});

// to test if they working
print(collection)
print(ndviCompList)

// create new collection from the compsites list
var collection1 = ee.ImageCollection.fromImages(ndviCompList);
print(collection1 )


// Define a mask to clip the the collection for all portugal
var mask = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017')
  .filter(ee.Filter.eq('country_na', 'Portugal'));
  
// visulization parameters
var band_viz = {
  min: 0,
  max: 0.0002,
  palette: ['black', 'blue', 'purple', 'cyan', 'green', 'yellow', 'red']
};

// function convert it to RGB image and apply the mask/clip
var visFun = function(img) {
  return img.visualize(band_viz).clip(lisbon);
};

// abbply the previous function on the latest collection 
var ndviColVis = collection1.map(visFun);

// define the border of animation 
var border = lisbon.geometry();

// Define GIF visualization parameters.
var gifParams = {
  'region': border,
  'dimensions': 800,
  'crs': 'EPSG:3857',
  'framesPerSecond': 1
};

// create a link for the animation 
print(ndviColVis.getVideoThumbURL(gifParams));





