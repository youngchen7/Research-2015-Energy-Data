Table table;
int num_villages = 80;
int num_years = 21;
int v = 0;
int y = 1993;
int m = 1;
Float[] vis = new Float[num_villages];
Float[] next_vis = new Float[num_villages];
int counter = 20;
color dark = color(0, 0, 0);
color light = color(255, 255, 255);


TableRow getEntry(int vil, int year, int month) {
  return table.getRow(vil*num_years*12 + (year-1993)*12 + month -1);
}

Float curve_vis(Float vis){
  return sqrt(vis/63.0)*63.0;
}

void setup() {
  table = loadTable("Hardoi_processed.csv", "header");
  println(table.getRowCount() + " total rows in table");
  frameRate(60);
  size(520, 420);
}

void draw() {
  println("Month: " + m + ", Year: " + y);
  //If counter reaches 20, update.
  if (counter>=20) {
    counter = 0;
    //Update all current vis
      for (int v = 0; v < num_villages; v++) {
        vis[v] = curve_vis(getEntry(v, y, m).getFloat("Vis"));
      }
      if(!(y==2013 && m==12)){
        if (m==12) {
          m = 1;
          y++;
        } else {
          m++;
        }
      }
      //Update all  next vis
      for (int v = 0; v < num_villages; v++) {
        next_vis[v] = curve_vis(getEntry(v, y, m).getFloat("Vis"));
      }
    
  }
  //Draw for each village
  for (int v = num_villages-1 ; v >= 0; v--) {
    color interFrom = lerpColor(dark, light, vis[v]/63.0);
    color interTo = lerpColor(dark, light, next_vis[v]/63.0);
    color interp = lerpColor(interFrom, interTo, counter/20.0);
    fill(interp);
    pushMatrix();
    translate(v/8*50, v%8*50);
    rect(10, 10, 50, 50);
    popMatrix();
  }
  counter++;
}

