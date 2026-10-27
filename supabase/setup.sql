-- Rode este arquivo uma vez no Supabase: SQL Editor > New query > colar > Run.

-- Cada "documento" guarda um bloco de dados do painel:
--   cardapio -> público (o cliente lê pelo QR Code)
--   estoque, movs -> só a equipe logada
create table if not exists public.documentos (
  id text primary key,
  dados jsonb not null,
  atualizado timestamptz not null default now()
);

alter table public.documentos enable row level security;

grant select on public.documentos to anon;
grant select, insert, update on public.documentos to authenticated;

drop policy if exists "publico le cardapio" on public.documentos;
create policy "publico le cardapio" on public.documentos
  for select to anon using (id = 'cardapio');

drop policy if exists "equipe le tudo" on public.documentos;
create policy "equipe le tudo" on public.documentos
  for select to authenticated using (true);

drop policy if exists "equipe grava" on public.documentos;
create policy "equipe grava" on public.documentos
  for insert to authenticated with check (true);

drop policy if exists "equipe atualiza" on public.documentos;
create policy "equipe atualiza" on public.documentos
  for update to authenticated using (true) with check (true);

-- Fotos dos produtos e do estoque (leitura pública, envio só pela equipe)
insert into storage.buckets (id, name, public)
values ('fotos', 'fotos', true)
on conflict (id) do update set public = true;

drop policy if exists "equipe envia fotos" on storage.objects;
create policy "equipe envia fotos" on storage.objects
  for insert to authenticated with check (bucket_id = 'fotos');

drop policy if exists "equipe apaga fotos" on storage.objects;
create policy "equipe apaga fotos" on storage.objects
  for delete to authenticated using (bucket_id = 'fotos');
