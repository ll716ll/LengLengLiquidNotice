# GitHub 打包 DEB

这个项目使用 Theos，不是 Xcode 工程。

## 正确操作

1. 把整个 `LengLengLiquidNotice` 文件夹上传到 GitHub 仓库根目录。
2. 确认 `.github/workflows/` 里面只有 `build.yml`。
3. 打开 GitHub → Actions → `Build LengLengLiquidNotice DEB`。
4. 点 `Run workflow`。
5. 构建完成后打开对应的运行记录，在 `Artifacts` 下载 `LengLengLiquidNotice-DEB`。
6. Artifact 里面就是 `.deb`。

不要运行 `objective-c-xcode.yml`。那个是给 Xcode 工程用的，当前项目是 Theos tweak。

项目目标 Bundle 为 `com.tencent.xin`，因此 tweak 只针对微信进程。
