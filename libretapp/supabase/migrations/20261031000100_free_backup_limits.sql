-- Pilot limits for the Free storage quota. Existing larger snapshots remain
-- readable; the NOT VALID constraint applies to new reservations.
alter table public.backup_snapshots drop constraint if exists snapshot_size_max;
alter table public.backup_snapshots
  add constraint snapshot_size_max check (size_bytes <= 10485760) not valid;

update storage.buckets set file_size_limit = 10485760
where id = 'libret-backups';
