# Tontine Zen Light 🚀

Tontine Zen Light est une application communautaire de gestion de tontines (Fintech Sociale) conçue spécifiquement pour le marché camerounais. L'application repose sur la transparence (historique public), la réputation (Trust Score de 0 à 100) et la sécurité juridique (génération de contrat de tontine conforme au droit OHADA et signature électronique), sans manipulation directe des fonds.

---

## 🛠️ Stack Technique

- **Frontend (Mobile & Web)** : Flutter (Dart)
- **Base de données & Auth** : Supabase
- **Hébergement Web** : Vercel (déploiement automatique)
- **Versionnement** : GitHub

---

## 🔄 Workflow Quotidien

| Action | Commande | Depuis |
| :--- | :--- | :--- |
| **Démarrer une session** | `git pull origin main` | Antigravity / Android Studio |
| **Développer / Tester** | `flutter run` | Antigravity / Android Studio |
| **Pousser les modifs** | `git add . && git commit -m "..." && git push origin main` | Antigravity / Android Studio |
| **Vérifier l'état** | `git status` | Terminal |
| **Build final** | `flutter build web --release` | Android Studio / Terminal |
| **Déployer** | `vercel --prod` | Terminal |

---

## 🏗️ Script Master Unifié

Pour automatiser tout le flux de déploiement (prerequis, pull, db migration, build et deploy), exécutez le script à la racine :

```bash
chmod +x build.sh
./build.sh
```

---

## 📁 Architecture du Projet

```
tontine-zen-light/
├── lib/
│   ├── main.dart
│   ├── screens/         # Écrans (Dashboard, Tontines, Profil, etc.)
│   ├── widgets/         # Components réutilisables
│   ├── services/        # Supabase, Auth, API
│   ├── models/          # Modèles de données
│   └── utils/           # Constantes, validateurs
├── supabase/
│   ├── config.toml
│   └── migrations/      # Scripts SQL (migrations)
├── build.sh             # Script master unifié
└── README.md            # Ce fichier
```
