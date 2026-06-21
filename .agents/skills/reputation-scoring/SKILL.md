---
name: reputation-scoring
description: "Spécialiste de la logique et du calcul du score de réputation (0-100) basé sur l'assiduité des paiements."
---

# Reputation Scoring Skill

## Formule et Règles d'Affaires
- **Base** : Tout nouvel utilisateur démarre avec un score de 70.
- **Paiement à l'heure** : +2 points (plafonné à 100).
- **Retard < 48h** : -5 points.
- **Défaut de paiement constaté** : -20 points.
- **Litige résolu à l'amiable** : Récupération partielle (+5 points).
- **Audit** : Toute modification de score doit générer un enregistrement d'audit dans la table `reputation_audit`.
