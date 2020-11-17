/*
 * Palette Graphique - prélude au projet multimodal 3A SRI
 * 4 objets gérés : cercle, rectangle(carré), losange et triangle
 * (c) 05/11/2019
 * Dernière révision : 28/04/2020
 */
 
import java.awt.Point;
import fr.dgac.ivy.*;

ArrayList<Forme> formes; // liste de formes stockées
Forme temp_forme; // forme en attente d'affichage
FSM mae; // Finite Sate Machine
int indice_forme;
PImage sketch_icon;

Ivy bus;
PFont f;
String message= "";

float CONFIDENCE = 0.7; // valeur de confiance de sra
float CONFIDENCE_ONEDOLLAR = 0.8; // valeur de confiance de OneDollar

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
  mae = FSM.ECOUTE_INIT;
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
        switch (mae) {
          case ECOUTE_INIT:
            if(message=="case1"){
              mae=FSM.ATTENTE_DOLLAR;
            }
          case AFFICHER_FORMES: 
            if(message.equals("case1")) {
              mae=FSM.ATTENTE_DOLLAR;
            } else if (message.equals("case2")) {
              mae=FSM.SUPPRIMER;
            } else if (args[0].contains("case3")) {
              mae=FSM.DEPLACER_FORMES_SELECTION;
            }
            break;   
          default:
            break;
        }  
      }        
    });

    //sra5
    bus.bindMsg("^sra5 Parsed=(.*) Confidence=(.*) NP=.*", new IvyMessageListener()
      {
        public void receive(IvyClient client,String[] args)
        {
          message = "Vous avez prononcé les concepts : " + args[0] + " avec un taux de confiance de " + args[1];
          
          if(float(args[1].replace(',', '.')) > CONFIDENCE) {
            println(message);
            // GO Attente figure dollar
              switch (mae) {

                case ECOUTE_INIT :  // Etat INITIAL
                  if(args[0].contains("creer")) {
                    mae=FSM.ATTENTE_DOLLAR;
                  }
                  break;
                case ATTENTE_COL_POS:
                  String[] param = args[0].split(" ", 2); 
                  print("Param split " + param[0] + " " + param[1]+"\n");
                  
                  int x = 0;
                  int y = 0;
                  if(param[0].contains("couleur:aleatoire") && param[1].contains("pose")) { //Couleur aleatoire position donnee
                    float r1 = random(-50, 50);
                    float r2 = random(-50, 50);
                    temp_forme.setColor(color(random(0,255),random(0,255),random(0,255))); //couleur aleatoire
                    if(param[1].contains("haut")) {
                      x = int(400+r1);
                      y = int(100+r2);
                    } else if(param[1].contains("bas")) {
                      x = int(400+r1);
                      y = int(500+r2);
                    } else if(param[1].contains("droite")) {
                      x = int(700+r1);
                      y = int(100+r2);
                    } else {
                      x = int(100+r1);
                      y = int(300+r2);
                    }
                  } else if((!(param[0].contains("aleatoire"))) && param[1].contains("position:aleatoire")) { //Couleur donnee position aleatoire
                    x = (int)(Math.random() * (750 - 50 + 1) + 50);
                    y = (int)(Math.random() * (550 - 50 + 1) + 50);
                    if(param[0].contains("rouge")) {
                      temp_forme.setColor(color(255, 0, 0));
                    } else if(param[0].contains("vert")) {
                      temp_forme.setColor(color(0, 255, 0));
                    } else if(param[0].contains("bleu")) {
                      temp_forme.setColor(color(0, 0, 255));
                    } else {
                    
                    }
                  } else if(!(param[0].contains("aleatoire")) && !(param[0].contains("aleatoire"))) { //Couleur et pos donnees
                    if(param[0].contains("rouge")) {
                      temp_forme.setColor(color(255, 0, 0));
                    } else if(param[0].contains("vert")) {
                      temp_forme.setColor(color(0, 255, 0));
                    } else if(param[0].contains("bleu")) {
                      temp_forme.setColor(color(0, 0, 255));
                    } else {
                    
                    }
                    
                    float r1 = random(-50, 50);
                    float r2 = random(-50, 50);
                    if(param[1].contains("haut")) {
                      x = int(400+r1);
                      y = int(100+r2);
                    } else if(param[1].contains("bas")) {
                      x = int(400+r1);
                      y = int(500+r2);
                    } else if(param[1].contains("droite")) {
                      x = int(700+r1);
                      y = int(100+r2);
                    } else {
                      x = int(100+r1);
                      y = int(300+r2);
                    }
                    
                  } else if((param[0].contains("aleatoire")) && (param[0].contains("aleatoire"))){  //Couleur et pos aleatoire
                    print("Tout aléatoire");
                    temp_forme.setColor(color(random(0,255),random(0,255),random(0,255))); //couleur aleatoire
                    x = (int)(Math.random() * (750 - 50 + 1) + 50);
                    y = (int)(Math.random() * (550 - 50 + 1) + 50);
                  }
                  
                  Point p = new Point(x, y);
                  temp_forme.setLocation(p); //maj position
                  formes.add(temp_forme); //ajout de la nouvelle forme                  
                  mae=FSM.AFFICHER_FORMES;
                  break;
                  
                case AFFICHER_FORMES:
                  if(args[0].contains("creer")) {
                    mae=FSM.ATTENTE_DOLLAR;
                  } else if (args[0].contains("supprimer")) {
                    mae=FSM.SUPPRIMER;
                  } else if (args[0].contains("deplacer")) {
                    mae=FSM.DEPLACER_FORMES_SELECTION;
                  }
                  break;
                case DEPLACER_FORMES_DESTINATION: 
                  if(args[0].contains("en haut")) {
                    float r1 = random(-50, 50);
                    float r2 = random(-50, 50);
                    x = int(400+r1);
                    y = int(100+r2);
                    if(indice_forme !=-1){
                      (formes.get(indice_forme)).setLocation(new Point(x, y));
                      indice_forme=-1;
                    }
                    mae=FSM.AFFICHER_FORMES;
                  }else if(args[0].contains("en bas")) {
                    float r1 = random(-50, 50);
                    float r2 = random(-50, 50);
                    x = int(400+r1);
                    y = int(500+r2);
                    if(indice_forme !=-1){
                      (formes.get(indice_forme)).setLocation(new Point(x, y));
                      indice_forme=-1;
                    }
                    mae=FSM.AFFICHER_FORMES;
                  } else if(args[0].contains("a droite")) {
                    float r1 = random(-50, 50);
                    float r2 = random(-50, 50);
                    x = int(700+r1);
                    y = int(100+r2);
                    if(indice_forme !=-1){
                      (formes.get(indice_forme)).setLocation(new Point(x, y));
                      indice_forme=-1;
                    }
                    mae=FSM.AFFICHER_FORMES;
                  } else if(args[0].contains("a gauche")) {
                    float r1 = random(-50, 50);
                    float r2 = random(-50, 50);
                    x = int(100+r1);
                    y = int(300+r2);
                    if(indice_forme !=-1){
                      (formes.get(indice_forme)).setLocation(new Point(x, y));
                      indice_forme=-1;
                    }
                    mae=FSM.AFFICHER_FORMES;
                  } else if(args[0].contains("aleatoire")) {
                    x = (int)(Math.random() * (750 - 50 + 1) + 50);
                    y = (int)(Math.random() * (550 - 50 + 1) + 50);
                    if(indice_forme !=-1){
                      (formes.get(indice_forme)).setLocation(new Point(x, y));
                      indice_forme=-1;
                    }
                    mae=FSM.AFFICHER_FORMES;
                  }
                  break;
              }
          }
          
        }        
      }); //fin bind sra5
    
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
          
          if (float(args[1].replace(',', '.')) > 0.5){
            println(message);
            if(mae == FSM.ATTENTE_DOLLAR){
              Point p = new Point(0,0);
              
              if(args[0].contains("rectangle")) {
                Forme f = new Rectangle(p);
                temp_forme = f;
                
                mae = FSM.ATTENTE_COL_POS;
              } else if (args[0].contains("circle")) {
                Forme f2 = new Cercle(p);
                temp_forme = f2;
                
                mae = FSM.ATTENTE_COL_POS;
              } else if (args[0].contains("triangle")) {
                Forme f3 = new Triangle(p);
                temp_forme = f3;
                
                mae = FSM.ATTENTE_COL_POS;
              }
            }
          }
        }        
      });

  } catch(IvyException e){ println(e); }
}

void draw() {
  background(255);
  println("MAE : " + mae);
  switch (mae) {
    case INITIAL:  // Etat INITIAL
      background(255);
      fill(0);
      text("Etat initial (c(ercle)/l(osange)/r(ectangle)/t(riangle) pour créer la forme à la position courante)", 50,50);
      text("m(ove)+ click pour sélectionner un objet et click pour sa nouvelle position", 50,80);
      text("click sur un objet pour changer sa couleur de manière aléatoire", 50,110);
      break;
      
    case ECOUTE_INIT: // ECOUTE SRA
      background(255);
      fill(0);
      //print("ATTENTE D UNE ACTION\n");
      break;
    case ATTENTE_DOLLAR:
     // print("ATTENTE DOLLAR\n");
      break;
    case ATTENTE_COL_POS:
      //print("ATTENTE COULEUR et/ou POSITION\n");
      break;
    case AFFICHER_FORMES:  // 
    case DEPLACER_FORMES_SELECTION: 
    case DEPLACER_FORMES_DESTINATION: 
      break;   
      
    default:
      break;
  }  
   affiche();
}

// fonction d'affichage des formes m
void affiche() {
  background(255);
  switch (mae) {
    case ECOUTE_INIT:
      fill(0);
      text("En attente d'une commande vocale (sra5) : créer", 1,10);
      break;
    case ATTENTE_DOLLAR:
      fill(0);
      text("En attente d'un dessin de forme (oneDollar): Rectangle|Circle|Triangle", 1,10);
      break;
    case ATTENTE_COL_POS:
      fill(0);
      text("En attente d'une couleur et/ou position (sra5): ((bleu|vert|rouge|ne rien dire) || (en haut|en bas|a gauche|a droite|ne rien dire)) | aleatoire", 1,10);
      break;
    case SUPPRIMER:
      fill(0); 
      text("En attente d'un clic sur la forme que vous voulez supprimer", 1,10);
      break; 
    case DEPLACER_FORMES_SELECTION: 
      fill(0); 
      text("En attente d'un clic sur la forme que vous voulez deplacer", 1,10);
      break;
    case DEPLACER_FORMES_DESTINATION: 
      fill(0); 
      text("En attente d'un clic vers la destination ou commande vocale en haut|en bas|a droite|a gauche|aleatoire", 1,10);
      break;
    case AFFICHER_FORMES: 
      fill(0); 
      text("En attente d'une commande vocale (sra5) ou geste (leap motion) : Créer|Déplacer|Supprimer", 1,10);
      break;   
      
    default:
      break;
  }  
  //text("Etat initial", 1,10);
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
     
   case SUPPRIMER:
     for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
        if ((formes.get(i)).isClicked(p)) {
          indice_forme = i;
          formes.remove(indice_forme);
          mae = FSM.AFFICHER_FORMES;
        }         
     }
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
