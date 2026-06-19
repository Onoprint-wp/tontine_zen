---
name: test-generator
description: "Expert en génération de tests unitaires et d'intégration pour Flutter. À utiliser pour toute nouvelle fonctionnalité ou correction de bug."
---

# Test Generator Skill

## Procédure de Génération de Tests
1.  **Identifier la cible** : Déterminer la fonction ou le widget à tester.
2.  **Créer le fichier de test** : Créer un fichier dans `/test/` avec le nom `[nom_fichier]_test.dart`.
3.  **Écrire les tests** :
    -   Pour les **services** : Tester les méthodes CRUD avec un mock de Supabase.
    -   Pour les **widgets** : Utiliser `WidgetTester` pour vérifier le rendu et les interactions.
4.  **S'assurer** que le test couvre au moins le scénario nominal et un scénario d'erreur.
