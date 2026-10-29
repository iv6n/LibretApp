begin;
select plan(4);
insert into auth.users (id, instance_id, aud, role, email) values
('00000000-0000-0000-0000-000000000101','00000000-0000-0000-0000-000000000000','authenticated','authenticated','client@example.test');
insert into public.farms (id, name) values ('00000000-0000-0000-0000-000000000102','Test farm');
insert into public.farm_memberships (id,farm_id,user_id,role,client_animal_ids) values
('00000000-0000-0000-0000-000000000103','00000000-0000-0000-0000-000000000102','00000000-0000-0000-0000-000000000101','client','["animal-a"]');
insert into public.feature_records (uuid,farm_id,kind,payload,created_at,updated_at) values
('00000000-0000-0000-0000-000000000104','00000000-0000-0000-0000-000000000102','health','{"animalUuid":"animal-a"}',now(),now());
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-000000000101","role":"authenticated"}',true);
select is((select count(*)::integer from public.feature_records),1,'client can read assigned animal');
delete from public.feature_records where uuid='00000000-0000-0000-0000-000000000104';
select is((select count(*)::integer from public.feature_records),1,'client cannot delete readable record');
update public.feature_records set payload='{"animalUuid":"animal-a","changed":true}' where uuid='00000000-0000-0000-0000-000000000104';
select is((select payload ? 'changed' from public.feature_records where uuid='00000000-0000-0000-0000-000000000104'),false,'client cannot update readable record');
select throws_ok($$insert into public.feature_records (uuid,farm_id,kind,payload,created_at,updated_at) values
('00000000-0000-0000-0000-000000000105','00000000-0000-0000-0000-000000000102','health','{}',now(),now())$$,'42501',null,'client cannot create records');
select * from finish();
rollback;
