// 同人本棚 · 账号版配置
// 把下面两项换成你自己 Supabase 项目的值（Supabase 后台 → Project Settings → API Keys）
// 这两项本来就是给网页公开使用的，放在 GitHub 上是安全的；真正保护数据的是 setup.sql 里的权限规则。
// 注意：不要填 secret / service_role 密钥！
window.SHELF_CONFIG = {
  supabaseUrl: '',   // Project URL，例如 'https://abcdefghijklmn.supabase.co'
  supabaseKey: '',   // Publishable key（sb_publishable_ 开头）或 anon public key（eyJ 开头）
};
