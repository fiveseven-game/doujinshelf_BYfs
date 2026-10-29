# 同人本棚 · 账号版

同人本收纳网页。用邮箱注册账号后，手机、电脑打开同一个网址登录，看到的是同一个书架。

| 文件 | 作用 |
|---|---|
| index.html | 网页本体 |
| config.js | 填 Supabase 的 Project URL 和 Publishable key |
| supabase.js | 登录与同步用的程序库（本地一份，国内访问更稳） |
| sw.js | 离线缓存 |
| setup.sql | 在 Supabase 的 SQL Editor 里运行一次，建表和权限 |

数据存在你自己的 Supabase 项目里；权限规则保证每个账号只能读写自己的数据。
