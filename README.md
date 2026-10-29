# 同人本棚 · 账号版

同人本收纳网页。用邮箱注册账号后，手机、电脑打开同一个网址登录，看到的是同一个书架。

## 仓库里应该有这 6 个文件（都放在最外层，名字一个字母都不能差）

| 文件 | 作用 |
|---|---|
| index.html | 网页本体 |
| config.js | 填 Supabase 的 Project URL 和 Publishable key |
| supabase.js | 登录与同步用的程序库 |
| sw.js | 离线缓存 |
| check.html | 自检页：打开 `你的网址/check.html` 逐项检查哪里没生效 |
| README.md | 说明 |

setup.sql 不用放进仓库，它是在 Supabase 的 SQL Editor 里运行一次的。

## 网址

用 Settings → Pages 里 “Visit site” 给出的 `https://用户名.github.io/仓库名/` 打开，不是 github.com 的仓库页面。
