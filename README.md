# Doumi · 你的同人本管理书架

## 文件

| 文件 | 作用 |
|---|---|
| index.html | 网页本体（所有内容先自动保存在本机） |
| supabase.js | 云端同步用的程序库 |
| sw.js | 离线缓存：断网也能打开网页 |
| config.js | 可选：预先填好 Supabase 地址和 key（也可以直接在网页“设置 → 云端同步”里填） |
| check.html | 自检页 |
| manifest.webmanifest | 添加到桌面用的应用信息（名称、图标） |
| icon-192.png / icon-512.png / icon-maskable-512.png / apple-touch-icon.png | 桌面图标（Doumi 小猫） |
| setup.sql | 建表 SQL（网页里也能一键复制），在 Supabase 的 SQL Editor 里运行一次 |

## 开启云端同步

1. 网页里打开 设置 → 云端同步（右侧的小按钮）
2. 点“复制建表 SQL”，到 Supabase 后台 SQL Editor 粘贴运行
3. 填 Project URL 和 Publishable key，点“保存并测试连接”
4. 注册 / 登录账号；其他设备登录同一账号即可同步

按钮绿色 = 已同步；灰色 = 未连接 / 未登录 / 离线（离线时内容照常存在本机，联网后自动上传）。

## 分享卡片（微信、QQ、Threads 等）

- `share-card.png` 是分享链接时显示的卡片图（LOGO + Doumi + made by fs），和 `index.html` 放在同一个文件夹。
- 如果某个平台只显示文字、不显示卡片图，把 `index.html` 开头几行里的 3 处 `share-card.png` 改成完整网址，例如
  `https://你的用户名.github.io/仓库名/share-card.png`。
- 平台会缓存卡片，改完后可能要过一阵子、或换个链接（比如末尾加 `&v=2`）才会看到新卡片。
