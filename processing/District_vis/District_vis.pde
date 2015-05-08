PShape country;
PShape region;
PShape district; 
Table table;
HashMap<String, Float> cur_vis = new HashMap<String, Float>();
HashMap<String, Float> next_vis = new HashMap<String, Float>();
int table_row = 0;

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
  println(table.getRowCount() + " total rows in  data");
  //Drawing variables
  frameRate(60);
  fill(0);
  stroke(120);
  strokeWeight(1);
}

void drawDistrict(String r, String d, color c){
  region = country.getChild(r);
  district = region.getChild(d);
  if(district!=null){
    district.disableStyle();
    pushStyle();
      fill(c);
      shape(district, -50, -200);
    popStyle();
  }else{
    println(region + ":" + district + " not found.");
  }
}

void nextData(){
  cur_vis = next_vis;
  
}


void draw(){
  shape(country, -50, -200);
  drawDistrict("Bihar", "Gaya", color(102, 0, 0));
}
