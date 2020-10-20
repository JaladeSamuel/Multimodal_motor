/*
 * Palette Graphique - prélude au projet multimodal 3A SRI
 * 4 objets gérés : cercle, rectangle(carré), losange et triangle
 * (c) 05/11/2019
 * Dernière révision : 28/04/2020
 */
 
import java.awt.Point;
import fr.dgac.ivy.*;

ArrayList<Forme> formes; // liste de formes stockées
FSM mae; // Finite Sate Machine
int indice_forme;
PImage sketch_icon;

Ivy bus;
PFont f;
String message= "";

float CONFIDENCE = 0.5; // valeur de confiance de sra

// action vocale ou gestuelle avec la leap motion 
boolean action_deplacer = false;
boolean action_creer = false; 

// figure sur dollar 
String figure_dollar = "";

// position vocale (clique souris sur la palette ou vocale(en haut...))
float position_x = 0;
float position_y = 0;

// couleur (clique souris sur la palette ou vocale)
String couleur = "";


void setup() {
  size(800,600);
  surface.setResizable(true);
  surface.setTitle("Palette multimodale");
  surface.setLocation(20,20);
  sketch_icon = loadImage("Palette.jpg");
  surface.setIcon(sketch_icon);
  
  formes= new ArrayList(); // nous créons une liste vide
  noStroke();
  mae = FSM.INITIAL;
  indice_forme = -1;

  // recevoir tous les messages 
  try{
    bus = new Ivy("Palette", " Palette is ready", null);
    bus.start("127.255.255.255:2010");
    
    //Leap motion
    bus.bindMsg("^leap_motion Command=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      { 
        message = args[0]; 
        if(message=="case1"){
          action_creer = true;
        }
        if(message=="case2"){
          action_deplacer = true;
        }  
      }        
    });

    //sra5
    bus.bindMsg("^sra5 Parsed=(.*) Confidence=(.*) NP=.*", new IvyMessageListener()
      {
        public void receive(IvyClient client,String[] args)
        {
          message = "Vous avez prononcé les concepts : " + args[0] + " avec un taux de confiance de " + args[1];
          
          if (float(args[1].replace(',', '.')) > CONFIDENCE){
            println(message);
            // TODO 
          }
          
        }        
      });
    
    //sra5 rejected
    bus.bindMsg("^sra5 Event=Speech_Rejected", new IvyMessageListener()
      {
        public void receive(IvyClient client,String[] args)
        {
          message = "Malheureusement, je ne vous ai pas compris"; 
          println(message);
        }        
      });
    
    //OneDollar
    bus.bindMsg("^OneDolarIvy Template=(.*) Confidence=(.*)", new IvyMessageListener()
      {
        public void receive(IvyClient client,String[] args)
        {
          message = "Dessin:" + args[0] + " et confiance:" + args[1];
          
          if (float(args[1].replace(',', '.')) > CONFIDENCE){
            println(message);
            // TODO
          }
        }        
      });

  } catch(IvyException e){ println(e); }
}

void draw() {
  background(0);
  //println("MAE : " + mae + " indice forme active ; " + indice_forme);
  switch (mae) {
    case INITIAL:  // Etat INITIAL
      background(255);
      fill(0);
      text("Etat initial (c(ercle)/l(osange)/r(ectangle)/t(riangle) pour créer la forme à la position courante)", 50,50);
      text("m(ove)+ click pour sélectionner un objet et click pour sa nouvelle position", 50,80);
      text("click sur un objet pour changer sa couleur de manière aléatoire", 50,110);
      break;
      
    case AFFICHER_FORMES:  // 
    case DEPLACER_FORMES_SELECTION: 
    case DEPLACER_FORMES_DESTINATION: 
      affiche();
      break;   
      
    default:
      break;
  }  
}

// fonction d'affichage des formes m
void affiche() {
  background(255);
  /* afficher tous les objets */
  for (int i=0;i<formes.size();i++) // on affiche les objets de la liste
    (formes.get(i)).update();
}

void mousePressed() { // sur l'événement clic
  Point p = new Point(mouseX,mouseY);
  
  switch (mae) {
    case AFFICHER_FORMES:
      for (int i=0;i<formes.size();i++) { // we're trying every object in the list
        // println((formes.get(i)).isClicked(p));
        if ((formes.get(i)).isClicked(p)) {
          (formes.get(i)).setColor(color(random(0,255),random(0,255),random(0,255)));
        }
      } 
      break;
      
   case DEPLACER_FORMES_SELECTION:
     for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
        if ((formes.get(i)).isClicked(p)) {
          indice_forme = i;
          mae = FSM.DEPLACER_FORMES_DESTINATION;
        }         
     }
     if (indice_forme == -1)
       mae= FSM.AFFICHER_FORMES;
     break;
     
   case DEPLACER_FORMES_DESTINATION:
     if (indice_forme !=-1)
       (formes.get(indice_forme)).setLocation(new Point(mouseX,mouseY));
     indice_forme=-1;
     mae=FSM.AFFICHER_FORMES;
     break;
     
    default:
      break;
  }
}


void keyPressed() {
  Point p = new Point(mouseX,mouseY);
  switch(key) {
    case 'r':
      Forme f= new Rectangle(p);
      formes.add(f);
      mae=FSM.AFFICHER_FORMES;
      break;
      
    case 'c':
      Forme f2=new Cercle(p);
      formes.add(f2);
      mae=FSM.AFFICHER_FORMES;
      break;
    
    case 't':
      Forme f3=new Triangle(p);
      formes.add(f3);
       mae=FSM.AFFICHER_FORMES;
      break;  
      
    case 'l':
      Forme f4=new Losange(p);
      formes.add(f4);
      mae=FSM.AFFICHER_FORMES;
      break;    
      
    case 'm' : // move
      mae=FSM.DEPLACER_FORMES_SELECTION;
      break;
  }
}
