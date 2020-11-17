/*
 * Enumération de a Machine à Etats (Finite State Machine)
 *
 *
 */
 
public enum FSM {
  INITIAL,
  ECOUTE_INIT,/* Etat Initial */
  ATTENTE_DOLLAR,
  ATTENTE_COL_POS,
  SUPPRIMER,
  AFFICHER_FORMES, 
  DEPLACER_FORMES_SELECTION,
  DEPLACER_FORMES_DESTINATION
}
