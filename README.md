# Doumi · 你的同人本管理书架

## 文件

| 文件 | 作用 |
|---|---|
| index.html | 网页本体（所有内容先自动保存在本机） |
| supabase.js | 云端同步用的程序库 |
| sw.js | 离线缓存：断网也能打开网页 |
| config.js | 可选：预先填好 Supabase 地址和 key（也可以直接在网页“设置 → 云端同步”里填） |
| check.html | 自检页 |
| setup.sql | 建表 SQL（网页里也能一键复制），在 Supabase 的 SQL Editor 里运行一次 |

## 开启云端同步

1. 网页里打开 设置 → 云端同步（右侧的小按钮）
2. 点“复制建表 SQL”，到 Supabase 后台 SQL Editor 粘贴运行
3. 填 Project URL 和 Publishable key，点“保存并测试连接”
4. 注册 / 登录账号；其他设备登录同一账号即可同步

按钮绿色 = 已同步；灰色 = 未连接 / 未登录 / 离线（离线时内容照常存在本机，联网后自动上传）。
