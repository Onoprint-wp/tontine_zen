---
name: flutter-ui
description: "Expert en développement d'interfaces Flutter. À utiliser pour la création de nouveaux écrans, widgets ou pour appliquer le Design System du projet."
---

# Flutter UI Developer Skill

## Contexte du Projet
Tu développes l'interface de "TONTINE ZEN LIGHT".

## Design System du Projet
-   **Couleurs** : Utiliser `AppColors.primary` (bleu profond), `AppColors.success` (vert), `AppColors.warning` (or).
-   **Typographie** : Utiliser `AppFonts.primary` (Inter) pour le corps du texte et `AppFonts.display` (Montserrat) pour les titres.
-   **Composants** :
    -   Pour afficher le score de réputation, utilise le widget personnalisé `ReputationScore(score: 85)`.
    -   Pour afficher une tontine, utilise le widget `TontineCard()`.

## Procédure pour un Nouvel Écran
1.  Créer le fichier dans `/lib/screens/`.
2.  Utiliser un `Scaffold` avec une `AppBar` transparente.
3.  Importer les widgets personnalisés depuis `/lib/widgets/`.
4.  Ajouter une animation d'entrée avec le package `flutter_animate`.
