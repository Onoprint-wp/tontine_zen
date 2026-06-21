# Guide d'Installation de Flutter sur Windows (Version 3.44.2)

Ce guide vous explique comment configurer le SDK Flutter version **3.44.2-stable** que vous avez téléchargé, et l'ajouter à votre système pour lancer le projet **Tontine Zen Light**.

---

## 1. Déplacer le SDK Flutter (Recommandé)
Le dossier se trouve actuellement dans vos téléchargements. Pour éviter toute suppression accidentelle, il est recommandé de le déplacer :
1. Déplacez le dossier `flutter` situé dans :
   `C:\Users\PcGamerCm\Downloads\flutter_windows_3.44.2-stable\flutter`
2. Vers un emplacement permanent à la racine de votre disque, par exemple :
   * **`C:\flutter`** (ou `C:\src\flutter`)
   * *⚠️ Évitez de le mettre dans un dossier avec des espaces ou des accents comme `C:\Program Files\`.*

---

## 2. Ajouter Flutter aux variables d'environnement (PATH)
Pour pouvoir exécuter la commande `flutter` dans votre terminal :

1. Dans la barre de recherche Windows, tapez **"environnement"** et sélectionnez **Modifier les variables d'environnement système**.
2. Cliquez sur le bouton **Variables d'environnement...** (en bas à droite).
3. Dans la section **Variables utilisateur** (tableau du haut), cherchez la variable nommée **Path** et double-cliquez dessus.
4. Cliquez sur le bouton **Nouveau** à droite.
5. Saisissez le chemin complet vers le dossier `bin` de votre dossier Flutter. Par exemple :
   * Si vous l'avez déplacé : **`C:\flutter\bin`**
   * Si vous le laissez dans les téléchargements : **`C:\Users\PcGamerCm\Downloads\flutter_windows_3.44.2-stable\flutter\bin`**
6. Cliquez sur **OK** sur toutes les fenêtres ouvertes pour valider.

---

## 3. Vérifier l'installation
1. Fermez et réouvrez VS Code (ou ouvrez un nouveau terminal PowerShell).
2. Tapez la commande suivante pour vérifier que Flutter 3.44.2 est bien reconnu :
   ```cmd
   flutter --version
   ```
3. Exécutez le diagnostic pour vérifier les configurations :
   ```cmd
   flutter doctor
   ```

---

## 4. Configurer VS Code et Android Studio
* **VS Code** : Une fois l'extension Flutter de Dart Code installée, si elle vous demande le chemin du SDK, indiquez-lui le dossier racine de Flutter (ex: `C:\flutter`).
* **Android Studio** : Allez dans *Settings > Plugins*, installez le plugin **Flutter**, puis indiquez le même dossier racine dans les réglages du SDK.
