-- ============================================================
-- SCHEMA INITIAL – TONTINE ZEN LIGHT
-- ============================================================

-- Extensions nécessaires
create extension if not exists "uuid-ossp";

-- 1. Table public.profiles (Synchronisée avec auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  phone text unique not null,
  full_name text not null,
  avatar_url text,
  trust_score int not null default 70 check (trust_score >= 0 and trust_score <= 100),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Table reputation_audit (Historique des scores de réputation)
create table public.reputation_audit (
  id uuid default gen_random_uuid() primary key,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  old_score int not null,
  new_score int not null,
  reason text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Table tontines (Groupes d'épargne)
create table public.tontines (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  amount numeric not null check (amount > 0),
  frequency text not null check (frequency in ('daily', 'weekly', 'monthly')),
  max_members int not null check (max_members >= 2),
  status text not null default 'pending_signatures' check (status in ('pending_signatures', 'active', 'completed')),
  creator_id uuid references public.profiles(id) on delete set null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. Table memberships (Liaison membres & rôles)
create table public.memberships (
  id uuid default gen_random_uuid() primary key,
  tontine_id uuid references public.tontines(id) on delete cascade not null,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  role text not null default 'member' check (role in ('treasurer', 'member')),
  joined_at timestamp with time zone default timezone('utc'::text, now()) not null,
  signed_contract_at timestamp with time zone,
  unique (tontine_id, profile_id)
);

-- 5. Table payment_rounds (Cycles de cotisation)
create table public.payment_rounds (
  id uuid default gen_random_uuid() primary key,
  tontine_id uuid references public.tontines(id) on delete cascade not null,
  round_number int not null,
  beneficiary_id uuid references public.profiles(id) on delete set null not null,
  start_date timestamp with time zone not null,
  end_date timestamp with time zone not null,
  status text not null default 'open' check (status in ('open', 'closed')),
  unique (tontine_id, round_number)
);

-- 6. Table payments (Suivi comptable)
create table public.payments (
  id uuid default gen_random_uuid() primary key,
  round_id uuid references public.payment_rounds(id) on delete cascade not null,
  payer_id uuid references public.profiles(id) on delete cascade not null,
  status text not null default 'pending' check (status in ('pending', 'paid', 'late')),
  confirmed_at timestamp with time zone,
  confirmed_by uuid references public.profiles(id) on delete set null,
  unique (round_id, payer_id)
);

-- 7. Table disputes (Signalements administratifs)
create table public.disputes (
  id uuid default gen_random_uuid() primary key,
  tontine_id uuid references public.tontines(id) on delete cascade not null,
  reporter_id uuid references public.profiles(id) on delete cascade not null,
  accused_id uuid references public.profiles(id) on delete cascade not null,
  description text not null,
  status text not null default 'open' check (status in ('open', 'under_review', 'resolved')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ============================================================
-- TRIGGERS DE SYNCHRONISATION AUTH
-- ============================================================

-- Fonction pour copier les utilisateurs de auth.users vers public.profiles
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, phone, full_name, avatar_url, trust_score)
  values (
    new.id,
    coalesce(new.phone, new.email),
    coalesce(new.raw_user_meta_data->>'full_name', 'Utilisateur Zen'),
    coalesce(new.raw_user_meta_data->>'avatar_url', ''),
    70
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger après création dans auth.users
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================================
-- SECURITE RLS (Row Level Security)
-- ============================================================

alter table public.profiles enable row level security;
alter table public.reputation_audit enable row level security;
alter table public.tontines enable row level security;
alter table public.memberships enable row level security;
alter table public.payment_rounds enable row level security;
alter table public.payments enable row level security;
alter table public.disputes enable row level security;

-- Politiques pour profiles
create policy "Autoriser la lecture des profils par tous les authentifiés" 
  on public.profiles for select using (auth.role() = 'authenticated');

create policy "Autoriser l'utilisateur à modifier son propre profil" 
  on public.profiles for update using (auth.uid() = id);

-- Politiques pour reputation_audit
create policy "Autoriser la lecture de son propre historique de score" 
  on public.reputation_audit for select using (auth.uid() = profile_id);

-- Politiques pour tontines
create policy "Autoriser l'affichage des tontines dont l'utilisateur est membre ou créateur" 
  on public.tontines for select using (
    auth.uid() = creator_id or
    exists (
      select 1 from public.memberships
      where memberships.tontine_id = id and memberships.profile_id = auth.uid()
    )
  );

create policy "Autoriser la création de tontine aux authentifiés" 
  on public.tontines for insert with check (auth.role() = 'authenticated' and creator_id = auth.uid());

create policy "Autoriser les créateurs à modifier leur tontine" 
  on public.tontines for update using (auth.uid() = creator_id);

-- Politiques pour memberships
create policy "Autoriser les membres d'une tontine à voir les adhésions" 
  on public.memberships for select using (
    exists (
      select 1 from public.memberships m
      where m.tontine_id = tontine_id and m.profile_id = auth.uid()
    ) or
    exists (
      select 1 from public.tontines t
      where t.id = tontine_id and t.creator_id = auth.uid()
    )
  );

create policy "Autoriser les authentifiés à rejoindre une tontine" 
  on public.memberships for insert with check (auth.role() = 'authenticated' and profile_id = auth.uid());

create policy "Autoriser le membre ou le trésorier à modifier l'adhésion" 
  on public.memberships for update using (
    auth.uid() = profile_id or
    exists (
      select 1 from public.memberships m
      where m.tontine_id = tontine_id and m.profile_id = auth.uid() and m.role = 'treasurer'
    )
  );

-- Politiques pour payment_rounds
create policy "Autoriser les membres à voir les tours de leur tontine" 
  on public.payment_rounds for select using (
    exists (
      select 1 from public.memberships
      where memberships.tontine_id = tontine_id and memberships.profile_id = auth.uid()
    )
  );

create policy "Autoriser le trésorier à gérer les tours" 
  on public.payment_rounds for all using (
    exists (
      select 1 from public.memberships
      where memberships.tontine_id = tontine_id and memberships.profile_id = auth.uid() and memberships.role = 'treasurer'
    )
  );

-- Politiques pour payments
create policy "Autoriser les membres à voir le tableau des cotisations" 
  on public.payments for select using (
    exists (
      select 1 from public.payment_rounds r
      join public.memberships m on m.tontine_id = r.tontine_id
      where r.id = round_id and m.profile_id = auth.uid()
    )
  );

create policy "Autoriser le trésorier à gérer les paiements" 
  on public.payments for all using (
    exists (
      select 1 from public.payment_rounds r
      join public.memberships m on m.tontine_id = r.tontine_id
      where r.id = round_id and m.profile_id = auth.uid() and m.role = 'treasurer'
    )
  );

-- Politiques pour disputes
create policy "Autoriser l'affichage des litiges aux parties concernées" 
  on public.disputes for select using (auth.uid() = reporter_id or auth.uid() = accused_id);

create policy "Autoriser les authentifiés à signaler un litige" 
  on public.disputes for insert with check (auth.role() = 'authenticated' and reporter_id = auth.uid());

-- ============================================================
-- AUTOMATISATION DU REPUTATION SCORING (DATABASE TRIGGER)
-- ============================================================

-- Fonction pour mettre à jour automatiquement le score lors d'un paiement
create or replace function public.process_payment_reputation()
returns trigger as $$
declare
  current_score int;
  target_score int;
  score_diff int;
  change_reason text;
begin
  -- Seulement si le statut du paiement change
  if (TG_OP = 'UPDATE' and old.status <> new.status) then
    
    -- Récupérer le score actuel du payeur
    select trust_score into current_score from public.profiles where id = new.payer_id;
    
    if new.status = 'paid' then
      score_diff := 2;
      change_reason := 'Paiement de cotisation confirmé à l''heure';
    elsif new.status = 'late' then
      score_diff := -5;
      change_reason := 'Cotisation payée en retard';
    else
      return new;
    end if;

    -- Calculer le nouveau score (borné entre 0 et 100)
    target_score := current_score + score_diff;
    if target_score > 100 then
      target_score := 100;
    elsif target_score < 0 then
      target_score := 0;
    end if;

    -- Mettre à jour le profil de l'utilisateur
    update public.profiles
    set trust_score = target_score
    where id = new.payer_id;

    -- Enregistrer dans la table d'audit
    insert into public.reputation_audit (profile_id, old_score, new_score, reason)
    values (new.payer_id, current_score, target_score, change_reason);

  end if;
  return new;
end;
$$ language plpgsql security definer;

-- Trigger après mise à jour dans public.payments
create or replace trigger on_payment_status_updated
  after update on public.payments
  for each row execute procedure public.process_payment_reputation();

