# LengLengLiquidNotice

GitHub/Theos-ready iOS tweak project for a Dynamic-Island-style Liquid Glass WeChat message banner.

## What it does
- Hooks WeChat's common `CMessageMgr AsyncOnAddMsg:MsgWrap:` path when that selector exists.
- Also watches the iOS notification delegate as a fallback.
- Presents a rounded translucent/blurred banner near the top of the active WeChat scene.
- Shows avatar, unread badge, contact name, message preview and a chevron.
- Preferences are stored in `com.lengleng.liquidnotice`.

## Important compatibility note
WeChat is proprietary and its internal class/method names change between releases. The `CMessageMgr` hook is runtime-checked and simply skips itself if the selector is absent. If a specific WeChat build uses a different message pipeline, add the current selector to `HookCMessageMgr` after inspecting that build.

This is an in-app overlay. It does not attempt to modify SpringBoard or create a real system Live Activity, so it is safer to test and it does not require a private SpringBoard framework.

## Build
1. Put this repository in a GitHub repo.
2. Build it with Theos on a macOS runner or your existing Theos GitHub Action.
3. Set `THEOS_PACKAGE_SCHEME=rootless` for modern rootless jailbreaks if your setup requires it.
4. Install the generated `.deb`, respring/restart the target app, then enable the tweak in PreferenceLoader.

## Visual tuning
The main visual values are in `LLNView.m`: card size/position, blur, corner radius, shadow, typography and animation.
