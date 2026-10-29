-- =====================================================================
--  Doumi · Supabase 初始化脚本（安全版）
--
--  用法：Supabase 后台 → SQL Editor → New query → 粘贴全部内容 → Run
--
--  这个脚本只"新建"、不"删除"：
--    · 不删除任何表、数据、文件或权限规则
--    · 已经存在的东西会自动跳过，所以重复运行也不会出错、不会覆盖
--    · 全部步骤放在一个事务里：中途任何一步出错，整份脚本都不会生效
--  运行完成后，最下面会显示一张"检查结果"表，每一项都应该是 true。
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 第 1 步：建数据表
--   每一行是一个用户的一条记录：一个 IP、一本本子或一项设置。
--   user_id  这行数据属于谁（默认就是当前登录的用户）
--   doc_id   记录编号，例如 ip_xxx、book_xxx、meta_rates
--   body     记录内容（JSON）
--   用户账号被删除时，他的记录会随之删除（on delete cascade）。
-- ---------------------------------------------------------------------
create table if not exists public.shelf_docs (
  user_id    uuid        not null default auth.uid()
                         references auth.users (id) on delete cascade,
  doc_id     text        not null
                         check (doc_id ~ '^(ip|book|meta)_[A-Za-z0-9_.:-]{1,120}$'),
  body       jsonb       not null
                         check (jsonb_typeof(body) = 'object'),
  updated_at timestamptz not null default now(),
  primary key (user_id, doc_id)
);

comment on table public.shelf_docs is 'Doumi：每个用户的 IP、本子和设置';

-- ---------------------------------------------------------------------
-- 第 2 步：开启行级权限（RLS）
--   开启后，没有规则允许的读写一律被拒绝；
--   未登录的访客（anon）没有任何规则，所以什么都读不到、写不了。
-- ---------------------------------------------------------------------
alter table public.shelf_docs enable row level security;

-- ---------------------------------------------------------------------
-- 第 3 步：建图片存储桶 covers
--   private：图片不公开，只能凭登录身份换取临时访问地址
--   单张最大 10 MB，只接受常见图片格式
--   （如果 covers 已经存在，这一步会跳过，不改动原有设置）
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'covers', 'covers', false, 10485760,
  array['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml']
)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 第 4 步：权限规则——"每个人只能读写自己的东西"
--   数据表：user_id 必须等于当前登录用户
--   图片：只能放在、读取、删除以自己用户 id 命名的文件夹里
--   规则已存在（同名）就跳过，不会删除或覆盖。
-- ---------------------------------------------------------------------
do $$
declare
  r record;
begin
  for r in
    select * from (values
      -- 表所在模式, 表名,       规则名,                   操作,     条件
      ('public',  'shelf_docs', 'shelf: read own',     'select', 'using (auth.uid() = user_id)'),
      ('public',  'shelf_docs', 'shelf: insert own',   'insert', 'with check (auth.uid() = user_id)'),
      ('public',  'shelf_docs', 'shelf: update own',   'update', 'using (auth.uid() = user_id) with check (auth.uid() = user_id)'),
      ('public',  'shelf_docs', 'shelf: delete own',   'delete', 'using (auth.uid() = user_id)'),
      ('storage', 'objects',    'covers: read own',    'select', 'using (bucket_id = ''covers'' and (storage.foldername(name))[1] = auth.uid()::text)'),
      ('storage', 'objects',    'covers: upload own',  'insert', 'with check (bucket_id = ''covers'' and (storage.foldername(name))[1] = auth.uid()::text)'),
      ('storage', 'objects',    'covers: delete own',  'delete', 'using (bucket_id = ''covers'' and (storage.foldername(name))[1] = auth.uid()::text)')
    ) as t (schema_name, table_name, policy_name, command, rule)
  loop
    if not exists (
      select 1 from pg_policies
      where schemaname = r.schema_name
        and tablename  = r.table_name
        and policyname = r.policy_name
    ) then
      execute format(
        'create policy %I on %I.%I for %s to authenticated %s',
        r.policy_name, r.schema_name, r.table_name, r.command, r.rule
      );
    end if;
  end loop;
end
$$;

-- ---------------------------------------------------------------------
-- 第 5 步：开启实时同步
--   一台设备改了数据，其他设备马上收到通知（仍然受第 4 步的权限限制）。
--   已经开启过就跳过。
-- ---------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'shelf_docs'
  ) then
    alter publication supabase_realtime add table public.shelf_docs;
  end if;
end
$$;

commit;

-- ---------------------------------------------------------------------
-- 第 6 步：检查结果（只读，不改动任何东西）
--   每一项的"结果"都应该是 true。
-- ---------------------------------------------------------------------
select '1. 数据表 shelf_docs 已建好'    as "检查项", to_regclass('public.shelf_docs') is not null as "结果"
union all
select '2. 数据表已开启行级权限',
       coalesce((select relrowsecurity from pg_class where oid = to_regclass('public.shelf_docs')), false)
union all
select '3. 数据表权限规则 4 条',
       (select count(*) from pg_policies where schemaname = 'public' and tablename = 'shelf_docs' and policyname like 'shelf: %') = 4
union all
select '4. 图片桶 covers 已建好且不公开',
       exists (select 1 from storage.buckets where id = 'covers' and public = false)
union all
select '5. 图片权限规则 3 条',
       (select count(*) from pg_policies where schemaname = 'storage' and tablename = 'objects' and policyname like 'covers: %') = 3
union all
select '6. 实时同步已开启',
       exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'shelf_docs');
