/*
 * Enumération de a Machine à Etats (Finite State Machine)
 *
 *
 */
 
public enum FSM {
  INITIAL, /* Etat Initial */
  ECOUTE_INIT,
  ATTENTE_DOLLAR,
  ATTENTE_COL_POS,
  SUPPRIMER,
  AFFICHER_FORMES, 
  DEPLACER_FORMES_SELECTION,
  DEPLACER_FORMES_DESTINATION
}
