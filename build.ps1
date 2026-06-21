# ============================================================
# SCRIPT MASTER – TONTINE ZEN LIGHT (Windows PowerShell)
# ============================================================
# Stack : Stitch → GitHub → Antigravity + Android Studio → Supabase → Vercel
# ============================================================

Write-Host "🚀 TONTINE ZEN LIGHT - BUILD MASTER (PowerShell)" -ForegroundColor Cyan

# --- 1. Vérification des outils ---
Write-Host "🔍 Vérification des prérequis..."
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Flutter n'est pas installé dans le PATH."
    exit 1
}
if (!(Get-Command supabase -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Supabase CLI n'est pas installée."
    exit 1
}
if (!(Get-Command vercel -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Vercel CLI n'est pas installée."
    exit 1
}
Write-Host "✅ Tous les outils sont présents." -ForegroundColor Green

# --- 2. Récupération du code ---
Write-Host "📥 Récupération des dernières modifications Git..."
git pull origin main

# --- 3. Installation des dépendances ---
Write-Host "📦 Installation des dépendances Flutter..."
flutter pub get

# --- 4. Migration Supabase ---
Write-Host "🗄️ Mise à jour de la base de données..."
supabase db push

# --- 5. Build ---
Write-Host "🏗️ Construction de l'application web..."
flutter build web --release

# --- 6. Déploiement ---
Write-Host "🚀 Déploiement sur Vercel..."
vercel --prod --yes

Write-Host "✅ Build et déploiement terminés !" -ForegroundColor Green
Write-Host "🌐 URL : https://tontine-zen-light.vercel.app" -ForegroundColor Yellow
