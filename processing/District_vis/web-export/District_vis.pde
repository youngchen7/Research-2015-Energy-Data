PShape country;
PShape region;
PShape district; 
Table table;
FloatDict cur_vis = new FloatDict();
FloatDict next_vis = new FloatDict();
TableRow new_row;
int table_row = 0;
int table_size;
int year = 1993;
int month = 1;
color dark = color(0, 0, 0);
color light = color(255, 255, 255);
int time_update = 0;
static final int update_interval = 300;

void setup(){
  //Set size
  size(950, 1000);
  //Load country
  country = loadShape ("Data/India.svg");
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

  //Drawing variables
  frameRate(60);
  fill(0);
  stroke(120);
  strokeWeight(2);
}

Float curve_vis(Float vis){
  return sqrt(vis/63.0)*63.0;
}

void drawDistrict(String r, String d, color c){
  region = country.getChild(r);
  if(region==null){
      //println("region " + r + " not found.");
      return;
  }
  district = region.getChild(d);
  if(district==null){
    //println("district " + d + " not found.");
    return;
  }
  //println(d + " " + r + " " + c);
  district.disableStyle();
  pushStyle();
    fill(c);
    shape(district, -50, -200);
  popStyle();

}


void draw(){
  shape(country, -50, -200);
  //Check if it's time to update the data (once every update_interval)
  int t_delta = millis() - time_update;
  if(t_delta > update_interval){
    time_update = millis(); 
    cur_vis = next_vis;
    println("Updating new data for " + month + "/" + year + " framerate: " + frameRate);
    while(new_row.getInt("year") == year && new_row.getInt("month") == month && table_row < table_size)
    {
      String r = new_row.getString("region");
      String d = new_row.getString("district");
      float vis = new_row.getFloat("vis");
      
      //println("loaded district " + d);
      
      next_vis.set(d + ":" + r, vis);
      
      //Update new_row with next row
      ++table_row;
      new_row = table.getRow(table_row);
      
    }
    //Move the date
    if(!(year == 2013 && month == 12)){
      ++month;
      if(month>12){
         month = 1;
         ++year;
      }
    }
  }
  
  //Always update the map
  for(String loc : cur_vis.keys()){
    String[] location = splitTokens(loc, ":");
    color from = lerpColor(dark, light, cur_vis.get(loc)/63.0);
    color to = lerpColor(dark, light, next_vis.get(loc)/63.0);
    color res = lerpColor(to, from, t_delta/update_interval);
    drawDistrict(location[1], location[0], res);
  }  
}

