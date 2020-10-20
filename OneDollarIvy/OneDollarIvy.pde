/*
 *  OneDollarIvy -> Demonstration with ivy middleware
 * v. 1.0
 * 
 * (c) Ph. Truillet, October 2020
 * Last Revision: 08/10/2020
 * 
 * $1 Dollar Recognizer - http://depts.washington.edu/aimgroup/proj/dollar/
*/

import fr.dgac.ivy.*;
import javax.swing.JOptionPane;

// Attributes
Ivy bus;
FSM mae;

float Infinity = 1e9;

// Recognizer class constants
int NumTemplates = 16;
int NumPoints = 64;
float SquareSize = 250.0;
float HalfDiagonal = 0.5 * sqrt(250.0 * 250.0 + 250.0 * 250.0);
float AngleRange = 45.0;
float AnglePrecision = 2.0;
float Phi = 0.5 * (-1.0 + sqrt(5.0)); // Golden Ratio

Recognizer recognizer;
Recorder recorder;
Result result;
String s_result;

PFont font;

void setup() {
  size(500, 250);
  result = null;
  s_result = "";
  
  recognizer = new Recognizer();
  recorder = new Recorder();
  
  smooth();
  font = loadFont("TwCenMT-Regular-16.vlw");
  textFont(font);
  
  // === ADD THREE TEMPLATES ===
  // triangle
  Point[] point1 = {  new Point(137,139),new Point(135,141),new Point(133,144),new Point(132,146),
                      new Point(130,149),new Point(128,151),new Point(126,155),new Point(123,160),
                      new Point(120,166),new Point(116,171),new Point(112,177),new Point(107,183),
                      new Point(102,188),new Point(100,191),new Point(95,195),new Point(90,199),
                      new Point(86,203),new Point(82,206),new Point(80,209),new Point(75,213),
                      new Point(73,213),new Point(70,216),new Point(67,219),new Point(64,221),
                      new Point(61,223),new Point(60,225),new Point(62,226),new Point(65,225),
                      new Point(67,226),new Point(74,226),new Point(77,227),new Point(85,229),
                      new Point(91,230),new Point(99,231),new Point(108,232),new Point(116,233),
                      new Point(125,233),new Point(134,234),new Point(145,233),new Point(153,232),
                      new Point(160,233),new Point(170,234),new Point(177,235),new Point(179,236),
                      new Point(186,237),new Point(193,238),new Point(198,239),new Point(200,237),
                      new Point(202,239),new Point(204,238),new Point(206,234),new Point(205,230),
                      new Point(202,222),new Point(197,216),new Point(192,207),new Point(186,198),
                      new Point(179,189),new Point(174,183),new Point(170,178),new Point(164,171),
                      new Point(161,168),new Point(154,160),new Point(148,155),new Point(143,150),
                      new Point(138,148),new Point(136,148) };
  recognizer.AddTemplate("triangle", point1);
   
  // rectangle
  Point[] point2 = {  new Point(78,149),new Point(78,153),new Point(78,157),new Point(78,160),
                      new Point(79,162),new Point(79,164),new Point(79,167),new Point(79,169),
                      new Point(79,173),new Point(79,178),new Point(79,183),new Point(80,189),
                      new Point(80,193),new Point(80,198),new Point(80,202),new Point(81,208),
                      new Point(81,210),new Point(81,216),new Point(82,222),new Point(82,224),
                      new Point(82,227),new Point(83,229),new Point(83,231),new Point(85,230),
                      new Point(88,232),new Point(90,233),new Point(92,232),new Point(94,233),
                      new Point(99,232),new Point(102,233),new Point(106,233),new Point(109,234),
                      new Point(117,235),new Point(123,236),new Point(126,236),new Point(135,237),
                      new Point(142,238),new Point(145,238),new Point(152,238),new Point(154,239),
                      new Point(165,238),new Point(174,237),new Point(179,236),new Point(186,235),
                      new Point(191,235),new Point(195,233),new Point(197,233),new Point(200,233),
                      new Point(201,235),new Point(201,233),new Point(199,231),new Point(198,226),
                      new Point(198,220),new Point(196,207),new Point(195,195),new Point(195,181),
                      new Point(195,173),new Point(195,163),new Point(194,155),new Point(192,145),
                      new Point(192,143),new Point(192,138),new Point(191,135),new Point(191,133),
                      new Point(191,130),new Point(190,128),new Point(188,129),new Point(186,129),
                      new Point(181,132),new Point(173,131),new Point(162,131),new Point(151,132),
                      new Point(149,132),new Point(138,132),new Point(136,132),new Point(122,131),
                      new Point(120,131),new Point(109,130),new Point(107,130),new Point(90,132),
                      new Point(81,133),new Point(76,133)};
  recognizer.AddTemplate("rectangle", point2);
       
  // circle
  Point[] point3 = {  new Point(127,141),new Point(124,140),new Point(120,139),new Point(118,139),
                      new Point(116,139),new Point(111,140),new Point(109,141),new Point(104,144),
                      new Point(100,147),new Point(96,152),new Point(93,157),new Point(90,163),
                      new Point(87,169),new Point(85,175),new Point(83,181),new Point(82,190),
                      new Point(82,195),new Point(83,200),new Point(84,205),new Point(88,213),
                      new Point(91,216),new Point(96,219),new Point(103,222),new Point(108,224),
                      new Point(111,224),new Point(120,224),new Point(133,223),new Point(142,222),
                      new Point(152,218),new Point(160,214),new Point(167,210),new Point(173,204),
                      new Point(178,198),new Point(179,196),new Point(182,188),new Point(182,177),
                      new Point(178,167),new Point(170,150),new Point(163,138),new Point(152,130),
                      new Point(143,129),new Point(140,131),new Point(129,136),new Point(126,139)};
  recognizer.AddTemplate("circle", point3);
  
  try {
    bus = new Ivy("OneDollarIvy", " OneDollarIvy is ready", null);
    bus.start("127.255.255.255:2010");
  }
  catch (IvyException ie) {}
    mae = FSM.INITIAL;
}

void draw() {
  // MAE à ajouter
  switch (mae) {
    case INITIAL:
      background(255);
      fill(0);
      text("Press (R) for gesture recognition\n (L) to learn gesture",50,50);  
      break;
      
    case RECOGNITION:
      background(255);
      textAlign(LEFT);
      fill(0);
      text(s_result, 10, 10);
            
      recorder.update();
      recorder.draw();
      
      if (recorder.hasPoints) {
        Point[] points = recorder.points;
        result = recognizer.Recognize(points);
        recorder.hasPoints = false;
      }

      if( result != null) {
        s_result = "Template: "+ result.Name + "\nScore: " + String.format("%.2f",result.Score) + "\nRatio: " + String.format("%.2f",result.Ratio);
        
        try {
          bus.sendMsg("OneDolarIvy Template=" + result.Name + " Confidence=" + String.format("%.2f",result.Score));
        }
        catch (IvyException ie) {}
        result=null;
       }
      break;
      
    case LEARNING: // have to register points 
      background(0,255,0);
      recorder.update();
      recorder.draw();
      
      if (recorder.hasPoints) {
        Point[] points = recorder.points;
        String template = JOptionPane.showInputDialog("Give a name to your template: ");
        recognizer.AddTemplate(template, points);
        recorder.hasPoints = false;
        mae = FSM.RECOGNITION;
      }
      break;
      
    case END:
      break;
      
    default:
      break;
  }
}

void keyPressed() {
  switch (key) {
    case 'r':
    case 'R':
      mae = FSM.RECOGNITION;
      break;
      
    case 'l':
    case 'L':
      mae = FSM.LEARNING;
      break;
  }
}
