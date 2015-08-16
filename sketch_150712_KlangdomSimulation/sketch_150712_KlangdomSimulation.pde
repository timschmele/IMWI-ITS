import controlP5.*;

ControlP5 cp5;
int myColor = color(0,0,0);
int width = 700;
int height = 700;
int counter = 0;

//Coordinates
int aziValue = 0;
float heightS = 0;

float r = 200;  //radius

float x = 1*r;
float y = 0;
float z = 0;

float v = 1;  //Hypothenuse


//Slider options
float leftDist = float(width)/10;
float sliderWidth = float(width)-leftDist;

//Loudspeaker
int lsAmount = 10;
float lsDist = 360/float(lsAmount);
Table ls;
FloatList distances;
int[] tri = new int[4];


float rotY = 0;
float rotX = 0;
float ro = 0;
boolean toggle = true;

void setup(){
  println(aziValue);
  size(width, height,P3D);
  noStroke();
  cp5 = new ControlP5(this);
  distances = new FloatList();
  
  cp5.addSlider("Azimuth")
    .setPosition(leftDist,50)
    .setRange(0,360)
    .setSize(500,20);
      
      
  cp5.addSlider("heightS")
    .setPosition(leftDist,100)
    .setRange(-1, 1)
    .setSize(500,20);
    
  cp5.addSlider("rotationX")
    .setPosition(leftDist,150)
    .setRange(0,25)
    .setSize(200,20).hide();
  
  cp5.addSlider("rotationY")
    .setPosition(leftDist+250,150)
    .setRange(0,25)
    .setSize(200,20).hide();
    
  cp5.addToggle("rotationToggle")
    .setPosition( leftDist , 15 )
    .setSize( 100, 20)
    .setState(true);
    
 //store position of the Loudspeakers in a table
  ls = new Table();
  ls.addColumn("x");
  ls.addColumn("y");
  ls.addColumn("z");
  
  
  for ( float j = -1; j<=1; j=j+0.25){//j is the height
   
    float vls = cos(asin(abs(j)));// v for loudspeaker position
    for( int i = 0; i<lsAmount; i = i+1){
      ls.addRow();
      ls.setFloat(counter, "x", cos(radians(aziValue+lsDist*i))*r*vls);
      ls.setFloat(counter, "y", j*r);
      ls.setFloat(counter, "z", sin(radians(aziValue+lsDist*i))*r*vls);
      counter = counter + 1;
    
    
      //println("loudspeaker "+i+": ("+ls.getFloat(i, "x")+"|"+ls.getFloat(i, "y")+"|"+ls.getFloat(i, "z")+")");
    }
  }
  
}

void draw(){
  background(myColor);
  
  
  pushMatrix();
  translate(width/2, height/1.5);
  
  if (toggle==true){
    rotateY(sin(radians(ro))*0.25);
    rotateX(cos(radians(ro))*0.07);
    ro = ro+ PI/5;
    if (ro>360){ro = 0;}
  }else{
    rotateY(sin(radians(ro))*0.25);
    rotateX(cos(radians(ro))*0.07);
  }
  
  
    for ( int i = 0; i<counter; i = i+1 ){
      
      float d = sqrt(
                    pow((ls.getFloat(i, "x")-x), 2)+  
                    pow((ls.getFloat(i, "y")-y), 2)+
                    pow((ls.getFloat(i, "z")-z), 2));
      distances.append(d);
      
      
      stroke(0, 100, 255);
      strokeWeight(6*map(ls.getFloat(i, "z"),-200,200, 0.5,1.5));
  
      for (int j = 0; j<3;j=j+1){
        if(tri[j] == i ) {
          stroke(255);
          strokeWeight(1);
          line(x,y,z, ls.getFloat(i, "x"), ls.getFloat(i, "y"), ls.getFloat(i, "z"));
          stroke(map(distances.get(tri[j]), 0,100, 255,0), map(distances.get(tri[j]), 0,100, 50,0)+100, 255);
         
        }
        
      }
      strokeWeight(6*map(ls.getFloat(i, "z"),-200,200, 0.5,1.5));
      point(ls.getFloat(i, "x"),ls.getFloat(i, "y"), ls.getFloat(i, "z"));
      
     
  }
  
  //loudspeaker next to Target
  
  for (int i = 0; i<4; i=i+1){
    tri[i] = distances.minIndex();
    //distances.remove(distances.minIndex());
    distances.set(distances.minIndex(), distances.max());
  }
  /*if (mousePressed){
    println(distances.min());
  }*/
  distances.clear();
  
  
  stroke(255, 255, 255);
  strokeWeight(4*map(z, -200,200, 0.5,1.5));
  point(x,y, z);
  
  
  
  popMatrix();
  
  
}

void Azimuth(float azi){
  aziValue = int(azi);

  x = cos(radians(aziValue))*r*v;
  y = heightS*r;
  z = sin(radians(aziValue))*r*v;
  
  println("Target point: T("+x+"|"+y+"|"+z+")");
  
  
  
}

void heightS(float h){
  heightS = h;
  x = cos(radians(aziValue))*r*v;
  y = heightS*r;
  z = sin(radians(aziValue))*r*v;
  v = cos(asin(abs(heightS)));
  //println(v);
  //println(degrees(asin(abs(heightS))));
  
  println("Target point: T("+x+"|"+y+"|"+z+")");
  
  
} 
  
void rotationX(float rot){
  rotX = rot ;
  //println(rotationX);
}

void rotationY(float rote){
  rotY = rote;
}

public void rotationToggle(boolean status){
  println(status);
  toggle = status;
}
  
