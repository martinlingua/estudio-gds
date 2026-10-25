-- Gestión del Estudio: instalación en Supabase
-- Pegar completo en SQL Editor > New query > Run. Se puede ejecutar más de una vez.
-- ANTES de ejecutar: cambiá los correos de la lista "acceso" (al final) por los reales.

-- 1) Lista de cuentas autorizadas
create table if not exists public.acceso (email text primary key);
alter table public.acceso enable row level security;   -- sin políticas: nadie la toca desde la app

-- 2) Datos: una fila por presupuesto, cliente o tarea (más una fila de configuración)
create table if not exists public.docs (
  coleccion  text        not null,
  id         text        not null,
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  updated_by text,
  primary key (coleccion, id)
);
alter table public.docs enable row level security;
alter table public.docs replica identity full;

-- 3) Pregunta "¿mi correo está autorizado?" (la usan la app y las políticas)
create or replace function public.soy_miembro()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.acceso a
    where lower(a.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
revoke all on function public.soy_miembro() from public, anon;
grant execute on function public.soy_miembro() to authenticated;

-- 4) Políticas: sólo cuentas autorizadas leen y escriben
drop policy if exists "docs_select" on public.docs;
drop policy if exists "docs_insert" on public.docs;
drop policy if exists "docs_update" on public.docs;
drop policy if exists "docs_delete" on public.docs;
create policy "docs_select" on public.docs for select to authenticated using (public.soy_miembro());
create policy "docs_insert" on public.docs for insert to authenticated with check (public.soy_miembro());
create policy "docs_update" on public.docs for update to authenticated using (public.soy_miembro()) with check (public.soy_miembro());
create policy "docs_delete" on public.docs for delete to authenticated using (public.soy_miembro());

-- 5) Auditoría: quién y cuándo tocó cada fila
create or replace function public.docs_audit()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  new.updated_by := auth.jwt() ->> 'email';
  return new;
end $$;
drop trigger if exists docs_audit on public.docs;
create trigger docs_audit before insert or update on public.docs
  for each row execute function public.docs_audit();

-- 6) Tiempo real (los cambios de otra persona aparecen sin recargar)
do $$ begin
  alter publication supabase_realtime add table public.docs;
exception when duplicate_object then null; end $$;

-- 7) Cuentas autorizadas: CAMBIAR por los correos reales (en minúscula)
insert into public.acceso (email) values
  ('macarena.gvl@gmail.com'),
  ('martin.lingua@gmail.com')
  ('gomezmf75@yahoo.com.ar')
  ('estudioconsultum@gmail.com')
on conflict do nothing;
