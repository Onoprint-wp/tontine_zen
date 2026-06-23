-- ============================================================
-- SIMULATION COMPLÈTE DE SCÉNARIO MÉTIER – TONTINE ZEN LIGHT
-- ============================================================
-- Ce script simule la création de membres, d'une tontine,
-- la signature du contrat, le suivi d'un tour de cotisation,
-- et l'application automatique des scores de réputation (Trust Score).
-- ============================================================

-- 1. Nettoyage préalable (pour permettre de rejouer le script)
delete from auth.users where id in (
  'a0000000-0000-0000-0000-000000000001',
  'a0000000-0000-0000-0000-000000000002',
  'a0000000-0000-0000-0000-000000000003'
);

-- 2. Création de 3 utilisateurs fictifs dans auth.users
-- (Le trigger 'on_auth_user_created' va automatiquement créer leurs profils dans public.profiles)
insert into auth.users (id, phone, email, encrypted_password, email_confirmed_at, phone_confirmed_at, raw_user_meta_data)
values 
  ('a0000000-0000-0000-0000-000000000001', '+237600000001', 'ariel@tontine.com', '', now(), now(), '{"full_name": "Ariel Kamga"}'),
  ('a0000000-0000-0000-0000-000000000002', '+237600000002', 'Bernice Noubissi', '', now(), now(), '{"full_name": "Bernice Noubissi"}'),
  ('a0000000-0000-0000-0000-000000000003', '+237600000003', 'Cedric Fotso', '', now(), now(), '{"full_name": "Cedric Fotso"}');

-- 3. Création de la tontine par Ariel (le créateur)
insert into public.tontines (id, name, amount, frequency, max_members, status, creator_id)
values (
  'b0000000-0000-0000-0000-000000000001',
  'Tontine Zen Leaders Mboa',
  10000, -- 10 000 FCFA
  'weekly', -- Hebdomadaire
  5,
  'pending_signatures',
  'a0000000-0000-0000-0000-000000000001'
);

-- 4. Ajout des adhésions (memberships)
-- Ariel est trésorier, Bernice et Cedric sont membres
insert into public.memberships (tontine_id, profile_id, role)
values 
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'treasurer'),
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'member'),
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003', 'member');

-- 5. Simulation des signatures électroniques du contrat OHADA
update public.memberships
set signed_contract_at = now()
where tontine_id = 'b0000000-0000-0000-0000-000000000001';

-- Activer la tontine maintenant que tout le monde a signé
update public.tontines
set status = 'active'
where id = 'b0000000-0000-0000-0000-000000000001';

-- 6. Création du Tour 1 (Payment Round)
-- Ariel est désigné comme bénéficiaire du pot du premier tour
insert into public.payment_rounds (id, tontine_id, round_number, beneficiary_id, start_date, end_date, status)
values (
  'c0000000-0000-0000-0000-000000000001',
  'b0000000-0000-0000-0000-000000000001',
  1,
  'a0000000-0000-0000-0000-000000000001',
  now(),
  now() + interval '7 days',
  'open'
);

-- 7. Initialisation des paiements du Tour 1
-- Les membres doivent cotiser (statut initial : 'pending')
insert into public.payments (id, round_id, payer_id, status)
values 
  ('d0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'pending'),
  ('d0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'pending'),
  ('d0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003', 'pending');

-- 8. SIMULATION DES COTISATIONS & EFFETS DE RÉPUTATION
-- A. Ariel (Trésorier) paie sa propre cotisation à l'heure
update public.payments
set status = 'paid', confirmed_at = now(), confirmed_by = 'a0000000-0000-0000-0000-000000000001'
where id = 'd0000000-0000-0000-0000-000000000001';

-- B. Bernice paie sa cotisation avec du retard
update public.payments
set status = 'late', confirmed_at = now(), confirmed_by = 'a0000000-0000-0000-0000-000000000001'
where id = 'd0000000-0000-0000-0000-000000000002';
