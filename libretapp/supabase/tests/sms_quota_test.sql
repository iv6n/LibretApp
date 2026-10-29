begin;
select plan(9);
truncate public.sms_send_attempts, public.sms_quota_alerts;

insert into public.sms_send_attempts(request_id,phone_hash,created_at,status)
select 'phone-' || n, repeat('d',64), now() - interval '2 minutes', 'failed'
from generate_series(1,4) n;
select ok((public.reserve_sms('phone-fifth',repeat('d',64))->>'allowed')::boolean,'fifth daily attempt allowed, including failed prior attempts');
update public.sms_send_attempts set created_at=now()-interval '2 minutes';
select ok(not (public.reserve_sms('phone-sixth',repeat('d',64))->>'allowed')::boolean,'sixth daily attempt blocked');
select ok(exists(select 1 from public.sms_quota_alerts where period like 'phone:%'),'80 percent phone quota warning persisted');

truncate public.sms_send_attempts, public.sms_quota_alerts;
insert into public.sms_send_attempts(request_id,phone_hash,created_at)
select 'global-' || n,lpad(to_hex(n),64,'0'),now()-interval '2 minutes' from generate_series(1,39) n;
select ok((public.reserve_sms('global-fortieth',repeat('e',64))->>'warning')::boolean,'80 percent daily warning returned before provider');
select ok(exists(select 1 from public.sms_quota_alerts where limit_count=50),'80 percent daily alert persisted');
insert into public.sms_send_attempts(request_id,phone_hash,created_at)
select 'global-fill-' || n,lpad(to_hex(100+n),64,'0'),now()-interval '2 minutes' from generate_series(1,10) n;
select ok(not (public.reserve_sms('global-fifty-first',repeat('f',64))->>'allowed')::boolean,'51st global daily send blocked');

truncate public.sms_send_attempts, public.sms_quota_alerts;
insert into public.sms_send_attempts(request_id,phone_hash,created_at)
select 'month-' || n,lpad(to_hex(n),64,'0'),
 date_trunc('month',now() at time zone 'America/Mexico_City') at time zone 'America/Mexico_City'
from generate_series(1,300) n;
select ok(not (public.reserve_sms('month-301',repeat('c',64))->>'allowed')::boolean,'301st monthly attempt blocked');
select is((select count(*) from public.sms_send_attempts),300::bigint,'blocked quota does not insert or send');
select throws_ok($$select public.reserve_sms('bad-hash','invalid')$$,'22023',null,'invalid quota hash rejected');
select * from finish();
rollback;
