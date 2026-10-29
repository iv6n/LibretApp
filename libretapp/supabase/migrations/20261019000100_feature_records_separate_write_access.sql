-- Prepared for a future cloud release. The offline pilot does not deploy SQL.
begin;
drop policy if exists feature_records_scoped_access on public.feature_records;
create policy feature_records_scoped_select on public.feature_records
for select to authenticated using (
  public.has_farm_role(farm_id, array['owner','manager','veterinarian','worker'])
  or exists (
    select 1 from public.farm_memberships m
    where m.farm_id = feature_records.farm_id and m.user_id = auth.uid()
      and m.active and m.role = 'client'
      and feature_records.payload->>'animalUuid' in
        (select jsonb_array_elements_text(m.client_animal_ids))
  )
);
create policy feature_records_staff_insert on public.feature_records
for insert to authenticated with check (
  public.has_farm_role(farm_id, array['owner','manager','veterinarian','worker'])
);
create policy feature_records_staff_update on public.feature_records
for update to authenticated using (
  public.has_farm_role(farm_id, array['owner','manager','veterinarian','worker'])
) with check (
  public.has_farm_role(farm_id, array['owner','manager','veterinarian','worker'])
);
create policy feature_records_staff_delete on public.feature_records
for delete to authenticated using (
  public.has_farm_role(farm_id, array['owner','manager','veterinarian','worker'])
);
create function public.feature_record_identity_immutable() returns trigger
language plpgsql set search_path = public as $$
begin
  if new.uuid <> old.uuid or new.farm_id <> old.farm_id or new.kind <> old.kind then
    raise exception 'A record identity, farm and kind cannot change' using errcode = '23514';
  end if;
  return new;
end;
$$;
revoke all on function public.feature_record_identity_immutable() from public;
create trigger feature_record_identity_immutable before update on public.feature_records
for each row execute function public.feature_record_identity_immutable();
commit;
