

// create a counter/series over a day of year 213
var doyList = ee.List.sequence(1, 210, 7);

// define the border of study area & animation 
var border = metro.geometry();


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
  
  
  
// composite each 7 days together and reduce them by median/mean for 2020
var No2List20 = doyList.map(function(startDoy) {

  startDoy = ee.Number(startDoy);
  
  return collection20
    .filter(ee.Filter.calendarRange(startDoy, startDoy.add(6), 'day_of_year'))
    .reduce(ee.Reducer.median());
});

// composite each 7 days together and reduce them by median/mean for 2019
var No2List19 = doyList.map(function(startDoy) {

  startDoy = ee.Number(startDoy);
  
  return collection19
    .filter(ee.Filter.calendarRange(startDoy, startDoy.add(6), 'day_of_year'))
    .reduce(ee.Reducer.median());
});


// create new collection from the compsites list 2020
var collection1 = ee.ImageCollection.fromImages(No2List20);

// create new collection from the compsites list 2019
var collection2 = ee.ImageCollection.fromImages(No2List19);


  
// visulization parameters
var band_viz = {
  min: 0,
  max: 0.0002,
  palette: ['black', 'blue', 'purple', 'cyan', 'green', 'yellow', 'red']
};

// function convert it to RGB image and apply the mask/clip
var visFun = function(img) {
  return img.visualize(band_viz).clip(metro);
};

// abbply the previous function on the latest collection 2020
var No2CollVis20 = collection1.map(visFun);

// abbply the previous function on the latest collection 2019
var No2CollVis19 = collection2.map(visFun);


// Define GIF visualization parameters.

var font_color='white';
var gifParams = {
  'font_color' : font_color,
  'region': border,
  'dimensions': 800,
  'crs': 'EPSG:3857',
  'framesPerSecond': 1
};

// create a link for the animation 2020
var ani2020 = ui.Thumbnail(No2CollVis20, gifParams);
print (No2CollVis20)
// create a link for the animation 2019
var ani2019 = ui.Thumbnail(No2CollVis19, gifParams);
print (No2CollVis19)


// Export the animation GIF as MP4 video - 2020
Export.video.toDrive({
  collection: No2CollVis20,
  'crs': 'EPSG:3857',
  description: "No2-2020",    // Filename
  framesPerSecond: 1,             
  region: border,
  scale: 250,                     // Scale in m
  });


// Export the animation GIF as MP4 video - 2019
Export.video.toDrive({
  collection: No2CollVis19,
  'crs': 'EPSG:3857',
  description: "No2-2019",    // Filename
  framesPerSecond: 1,             
  region: border,
  scale: 250,                     // Scale in m
  });
  
  
  
// panel for animations
var panel = ui.Panel({
  layout: ui.Panel.Layout.flow('horizontal'),
  style: {width: '1000px',
  height: '100%',
  position: 'bottom-center'
    
  }
});

var panel1 = ui.Panel({
  layout: ui.Panel.Layout.flow('vertical'),
  style: {width: '500px',
  height: '100%',
  position: 'bottom-center'
    
  }
});

var panel2 = ui.Panel({
  layout: ui.Panel.Layout.flow('vertical'),
  style: {width: '500px',
  height: '100%',
  position: 'bottom-left'
    
  }
});
// Set Labels 
var label20 = ui.Label('No2 concentration - 2020');
var label19 = ui.Label('No2 concentration - 2019');


// Add animation to the panels
Map.add(panel);
panel.add(panel1);
panel.add(panel2)

panel1.add(ani2020);
panel1.add(label20);

panel2.add(ani2019);
panel2.add(label19);



