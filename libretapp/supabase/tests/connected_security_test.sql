begin;
select plan(19);

insert into auth.users(id, instance_id, aud, role, phone, phone_confirmed_at)
values ('22000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000000','authenticated','authenticated','525555000001',now()),
       ('22000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000000','authenticated','authenticated','525555000002',now());
insert into public.backup_snapshots(id,user_id,object_path,sha256,size_bytes,schema_version,app_version,verified)
values ('22000000-0000-0000-0000-000000000003','22000000-0000-0000-0000-000000000001',
  '22000000-0000-0000-0000-000000000001/22000000-0000-0000-0000-000000000003.libretbackup',repeat('a',64),100,11,'test',false);
insert into storage.objects(bucket_id,name) values('libret-backups',
  '22000000-0000-0000-0000-000000000001/22000000-0000-0000-0000-000000000003.libretbackup');

set local role authenticated;
select set_config('request.jwt.claims','{"sub":"22000000-0000-0000-0000-000000000002","role":"authenticated"}',true);
select is((select count(*) from public.backup_snapshots),0::bigint,'second account cannot list another owner');
select is((select count(*) from storage.objects where bucket_id='libret-backups'),0::bigint,'second account cannot download another owner object');
select throws_ok($$insert into storage.objects(bucket_id,name) values('libret-backups',
  '22000000-0000-0000-0000-000000000001/22000000-0000-0000-0000-000000000004.libretbackup')$$,
  '42501',null,'second account cannot upload to another owner folder');
with deleted as (delete from storage.objects where bucket_id='libret-backups' returning id)
select is(count(*),0::bigint,'second account cannot delete another owner object') from deleted;
select throws_ok($$insert into public.backup_snapshots(user_id,object_path,sha256,size_bytes,schema_version,app_version)
  values('22000000-0000-0000-0000-000000000001','other',repeat('a',64),100,11,'test')$$,
  '42501',null,'second account cannot upload for another owner');
with deleted as (delete from public.backup_snapshots returning id)
select is(count(*),0::bigint,'second account cannot delete another owner') from deleted;
select throws_ok($$select public.reserve_sms('attacker',repeat('a',64))$$,'42501',null,'clients cannot bypass quotas');
select set_config('request.jwt.claims','{"sub":"22000000-0000-0000-0000-000000000001","role":"authenticated"}',true);
select is((select count(*) from public.backup_snapshots),1::bigint,'owner can list reservation');
select is((select count(*) from storage.objects where bucket_id='libret-backups'),1::bigint,'owner can read own object');
select lives_ok($$update public.backup_snapshots set verified=true$$,'owner can verify own copy');
reset role;
insert into public.account_deletions(user_id,session_id) values('22000000-0000-0000-0000-000000000001','22000000-0000-0000-0000-000000000099');
set local role authenticated;
select is((select count(*) from public.backup_snapshots),0::bigint,'previously issued token cannot list during deletion');
select is((select count(*) from storage.objects where bucket_id='libret-backups'),0::bigint,'previous token cannot download during deletion');
select ok(not public.account_is_active(),'deleting account is inactive');
select throws_ok($$insert into public.backup_snapshots(id,user_id,object_path,sha256,size_bytes,schema_version,app_version)
  values('22000000-0000-0000-0000-000000000004','22000000-0000-0000-0000-000000000001',
  '22000000-0000-0000-0000-000000000001/22000000-0000-0000-0000-000000000004.libretbackup',repeat('a',64),100,11,'test')$$,
  '42501',null,'previously issued token cannot upload during deletion');
reset role;
delete from auth.users where id='22000000-0000-0000-0000-000000000001';
set local role authenticated;
select ok(not public.account_is_active(),'old token denied after user deletion');
reset role;

select ok((public.reserve_sms('connected-first',repeat('b',64))->>'allowed')::boolean,'first SMS reservation allowed');
select ok(not (public.reserve_sms('connected-first',repeat('b',64))->>'allowed')::boolean,'signed hook replay cannot send twice');
select ok(not (public.reserve_sms('connected-resend',repeat('b',64))->>'allowed')::boolean,'60 second cooldown enforced in database');
select is((select count(*) from public.sms_send_attempts where phone_hash=repeat('b',64)),1::bigint,'rejected requests consume no additional reservation');
select * from finish();
rollback;
