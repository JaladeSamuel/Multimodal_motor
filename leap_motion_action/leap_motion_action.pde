import de.voidplus.leapmotion.*;
import fr.dgac.ivy.*;


LeapMotion leap;
Ivy bus;

void setup() {
  size(800, 500);
  background(255);
  // ...

  leap = new LeapMotion(this); 
  
  try{
    bus = new Ivy("sender", " sender_processing is ready", null);
    bus.start("127.255.255.255:2010");
  }
  catch (IvyException ie){}
}

float[] position_leap; 
float force; 
int msg_sent = 0;

void leapOnInit() {
  println("Leap Motion Init");
}
void leapOnConnect() {
  println("Leap Motion Connect");
}
void leapOnDisconnect() {
  println("Leap Motion Disconnect");
}

void draw()
{
  background(205);
  int fps = leap.getFrameRate();
  
  for (Hand hand : leap.getHands ()) {
    
    force = hand.getPinchStrength();
    PVector handPosition = hand.getPosition();
    position_leap = handPosition.array();
    
    if(force > 0.6 && msg_sent == 0){
      
      float x_leap = position_leap[0]-385;
      float y_leap = position_leap[1]-250;
      
      if(x_leap < -180 && y_leap < -77){
        try{
          bus.sendMsg("Demo_Processing Command=case1");
        }
        catch (IvyException ie){}
        println("case1");
        msg_sent = 1;
      }
      
      if(x_leap > 210 && y_leap < -85){
        try{
          bus.sendMsg("Demo_Processing Command=case2");
        }
        catch (IvyException ie){}
        println("case2");
        msg_sent = 1;
      }
      
      if(x_leap < -180 && y_leap > 70){
        try{
          bus.sendMsg("Demo_Processing Command=case3");
        }
        catch (IvyException ie){}
        println("case3");
        msg_sent = 1;
      }
      
      if(x_leap > 200 && y_leap > 70){
        try{
          bus.sendMsg("Demo_Processing Command=case4");
        }
        catch (IvyException ie){}
        println("case4");
        msg_sent = 1;
      }
      
      println("x=",position_leap[0]-385," y=",position_leap[1]-250);//," z=",position_leap[2]-44);
    }
    
    // Drawing the leap motion animation
    hand.draw();
    
  }  
}

void keyPressed() {
  msg_sent = 0; 
}
