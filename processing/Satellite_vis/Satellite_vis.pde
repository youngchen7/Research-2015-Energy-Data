PShape country;
PImage india;
Table table;
FloatDict cur_vis = new FloatDict();
FloatDict next_vis = new FloatDict();
HashMap<String, PShape> district_map = new HashMap<String, PShape>();
TableRow new_row;
int table_row = 0;
int table_size;
int year = 1993;
int month = 1;
color dark = color(255, 255, 255, 0);
color light = color(255, 255, 255, 255);
int time_update = 0;
int draw_update = 0;
static final float update_interval = 300;
static final String[] month_names = {
  "January", "February", "March", "April", "May", "June", 
  "July", "August", "September", "October", "November", "December"
};

String[] mismatch_logs = new String[0];           

void setup() {
  //Set size
  size(900, 950);
  //Load country
  country = loadShape ("Data/India.svg");
  india = loadImage("India_satellite.jpg");
  country.disableStyle();
  println("India svg successfully loaded");
  println(country.getChildCount() + " regions found");
  //Load data
  table = loadTable("query_sat-stdist-month.csv", "header");
  println("Vis data successfully loaded");
  table_size = table.getRowCount(); 
  println(table_size + " total rows in  data");
  //Initialize new row to be checked
  new_row = table.getRow(table_row);
  println("Data starts at " + new_row.getInt("month") + "/" + new_row.getInt("year"));
  month = new_row.getInt("month");
  year = new_row.getInt("year");

  //Drawing variables
  //frameRate(60);
}

Float curve_vis(Float vis) {
  return sqrt(vis/63.0)*63.0;
}

void drawDistrict(String loc, color c) {
  //If this district hasn't been loaded before
  if (!district_map.containsKey(loc)) {
    println("Loading new district shape for " + loc);
    String[] location = splitTokens(loc, ":");
    PShape region = country.getChild(location[1]);
    if (region==null) {
      println("location " + location[0] + ":" + location[1] + " not found.");
      mismatch_logs = append(mismatch_logs, location[0] + ":" + location[1] + " (region)");
      district_map.put(loc, null);
      return;
    }
    PShape district = region.getChild(location[0]);
    if (district==null) {
      println("location " + location[0] + ":" + location[1] + " not found.");
      mismatch_logs = append(mismatch_logs, location[0] + ":" + location[1] + " (district)");
      district_map.put(loc, null);
      return;
    }
    district_map.put(loc, district);
    district_map.get(loc).disableStyle();
  }
  //Now we draw it
  //println(d + " " + r + " " + c);
  if (district_map.get(loc)!=null)
  {
    pushStyle();
    fill(c);
    noStroke();
    shape(district_map.get(loc), -60, -250);
    popStyle();
  }
}


void draw() {
  //Check if it's time to update the data (once every update_interval)
 
  float t_delta = millis() - time_update;
  if (t_delta > update_interval) {
    time_update = millis(); 
    cur_vis = next_vis.copy();
    println("Updating new data for " + month + "/" + year + " framerate: " + frameRate);
    while (new_row.getInt ("year") == year && new_row.getInt("month") == month )
    {
      String r = new_row.getString("region");
      String d = new_row.getString("district");
      float vis = new_row.getFloat("vis");

      //println("loaded district " + d);

      next_vis.set(d + ":" + r, vis);

      //Update new_row with next row
      ++table_row;
      if (table_row < table_size)
      {
        new_row = table.getRow(table_row);
      } else {
        saveStrings("mismatch.log", mismatch_logs);
        exit();
      }
    }
    println("Update finished in " + (millis() - time_update));
    //Move the date
    if (!(year == 2013 && month == 12)) {
      ++month;
      if (month>12) {
        month = 1;
        ++year;
      }
    }
  }

  //Always update the map
  draw_update = millis(); //Record the time it took
  image(india, 0, 0, 900, 950);
  noFill();
  stroke(120, 120);
  shape(country, -60, -250);
  stroke(255);
  fill(255);
  textSize(26);
  text("//" + month_names[month-1] + " " + year, 500, 800); 

  for (String loc : cur_vis.keys ()) {    
    color from = lerpColor(dark, light, cur_vis.get(loc)/63.0);
    color to = lerpColor(dark, light, next_vis.get(loc)/63.0);
    color res = lerpColor(from, to, (millis() - time_update)/update_interval);
    //println(t_delta/update_interval);
    drawDistrict(loc, res);
  }
  println("Draw finished in " + (millis() - draw_update));
}

