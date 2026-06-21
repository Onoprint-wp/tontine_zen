#!/bin/bash
# ============================================================
# SCRIPT MASTER – TONTINE ZEN LIGHT (Linux / macOS / Git Bash)
# ============================================================
# Stack : Stitch → GitHub → Antigravity + Android Studio → Supabase → Vercel
# ============================================================

echo "🚀 TONTINE ZEN LIGHT - BUILD MASTER"

# --- 1. Vérification des outils ---
echo "🔍 Vérification des prérequis..."

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé."
    exit 1
fi

# Vérifier Supabase
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI n'est pas installée."
    exit 1
fi

# Vérifier Vercel
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI n'est pas installée."
    exit 1
fi

echo "✅ Tous les outils sont présents."

# --- 2. Récupération du code ---
echo "📥 Récupération des dernières modifications..."
git pull origin main

# --- 3. Installation des dépendances ---
echo "📦 Installation des dépendances..."
flutter pub get

# --- 4. Migration Supabase ---
echo "🗄️  Mise à jour de la base de données..."
supabase db push

# --- 5. Build ---
echo "🏗️  Construction de l'application web..."
flutter build web --release

# --- 6. Déploiement ---
echo "🚀 Déploiement sur Vercel..."
vercel --prod --yes

echo "✅ Build et déploiement terminés !"
echo "🌐 URL : https://tontine-zen-light.vercel.app"
