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
