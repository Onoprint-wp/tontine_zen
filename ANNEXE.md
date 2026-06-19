# Annexe : Agent Skills – TONTINE ZEN LIGHT

Ce document regroupe les compétences spécialisées (Agent Skills) définies pour guider l'IA Antigravity dans le développement de Tontine Zen Light.

Pour que ces compétences soient actives pour l'agent Antigravity, les fichiers correspondants sont configurés dans le dossier `.agents/skills/` à la racine du projet.

---

### 1. Backend Dev (`.agents/skills/backend-dev/SKILL.md`)
**Rôle :** L'Architecte Supabase (modélisation de données, SQL, services Darts).

```markdown
---
name: backend-dev
description: "Expert en développement backend avec Supabase et Flutter. À utiliser pour toute tâche liée à la création de modèles de données, de migrations SQL, ou de services d'API."
---

# Backend Developer Skill

## Contexte du Projet
Tu développes le backend de "TONTINE ZEN LIGHT", une application de gestion de tontine.

## Workflow de Création d'une Nouvelle Fonctionnalité
1.  **Définir le modèle de données** : Crée un fichier de migration SQL dans `/supabase/migrations/`.
2.  **Appliquer la migration** : Exécute la commande `supabase db push`.
3.  **Générer les types** : Exécute `supabase gen types typescript --local > lib/supabase_types.dart`.
4.  **Créer le service Dart** : Crée un fichier dans `/lib/services/` avec les méthodes CRUD nécessaires.

## Règles de Conception (Rules)
-   Toutes les tables doivent avoir un `id` UUID avec `gen_random_uuid()`.
-   Les clés étrangères doivent utiliser `ON DELETE CASCADE` lorsque c'est pertinent.

## Procédure pour une Migration
-   Le nom du fichier doit suivre le format : `[timestamp]_[description]_table.sql`.
-   Inclure toujours les commandes `CREATE TABLE` et les politiques RLS (Row Level Security) de Supabase.
```

---

### 2. Flutter UI (`.agents/skills/flutter-ui/SKILL.md`)
**Rôle :** Le Spécialiste de l'Interface (Design System, Montserrat/Inter, Widgets custom).

```markdown
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
```

---

### 3. Test Generator (`.agents/skills/test-generator/SKILL.md`)
**Rôle :** Le Garant de la Qualité (tests unitaires services/widgets).

```markdown
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
```

---

### 4. Doc Writer (`.agents/skills/doc-writer/SKILL.md`)
**Rôle :** Le Rédacteur Technique (README, guides, docs d'API).

```markdown
---
name: doc-writer
description: "Expert en documentation technique. À utiliser pour générer ou mettre à jour la documentation du projet (README, API, guides)."
---

# Documentation Writer Skill

## Règles de Documentation
-   Le `README.md` doit être mis à jour après chaque nouvelle fonctionnalité majeure.
-   Les nouvelles API doivent être documentées dans le fichier `API.md` avec la méthode, l'URL, les paramètres et les exemples de réponse.
-   Les guides utilisateur doivent être clairs, concis et adaptés au public cible (utilisateurs non techniques).

## Procédure pour un Nouveau Guide
1.  Créer un fichier `.md` dans le dossier `/docs/`.
2.  Structurer avec des titres (`#`, `##`) et des listes à puces.
3.  Inclure des captures d'écran si nécessaire (les placer dans `/docs/images/`).
4.  Ajouter un lien vers ce nouveau guide dans le `README.md`.
```

---

### 5. Deploy Master (`.agents/skills/deploy-master/SKILL.md`)
**Rôle :** Le DevOps Automatisé (workflows de release, build, vercel).

```markdown
---
name: deploy-master
description: "Expert en déploiement d'applications Flutter. À utiliser pour préparer un build de production ou pour exécuter le déploiement sur Vercel."
---

# Deployment Master Skill

## Workflow de Déploiement
1.  **Préparation** : Exécuter `flutter clean` et `flutter pub get`.
2.  **Build** : Exécuter `flutter build web --release`.
3.  **Déploiement** : Exécuter `vercel --prod` (si les variables d'environnement sont configurées).
4.  **Vérification** : Confirmer que l'URL de production est accessible.

## Règles de Déploiement
-   Ne jamais déployer depuis la branche `feature/*`, toujours depuis `main` après une revue de code.
-   Les variables d'environnement (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) doivent être configurées dans Vercel.
```
