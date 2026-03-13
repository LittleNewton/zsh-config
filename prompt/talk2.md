# date: 2026-03-13 21:11:10

pkg_manager 目录下，是我自定义的几个不存在于 apt index 里的包，每个包的安装脚本定义在 ./pkg_manager/module 里。

然而，我发现有些时候把安装路径改为 ~/.local/bin 会更加方便，而不是 /usr/local/bin

请你实现重构，
比如：
ltnt_install all / or pkg_name --dest system|user

system 就是 /usr/local/bin，这也是默认值。
user 就是 ~/.local/bin