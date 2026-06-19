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
