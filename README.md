# nix-colorscheme

为 Home Manager 管理的应用生成 Gruvbox 深浅配色。支持自动切换的应用使用系统或应用的原生机制，没有后台同步服务。darktable 使用固定配色。

## 使用

Flake 仅导出 `homeModules.default`，使用消费方提供的 Nixpkgs，没有自己的输入或锁文件：

```nix
inputs.colorscheme.url = "github:roife/nix-colorscheme";
```

Linux KDE 示例（通过 Home Manager 的 `extraSpecialArgs` 传入 `inputs`）：

```nix
{ inputs, ... }: {
  imports = [
    inputs.colorscheme.homeModules.default
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  programs.firefox = {
    enable = true;
    profiles.work = {
      id = 0;
      isDefault = true;
      # 使用已有配置档时，填写实际 path。
    };
  };

  colorscheme = {
    plasma.enable = true;
    chromium.enable = true;
    konsole.enable = true;
    digikam.enable = true;
    darktable.enable = true;
    firefox = {
      enable = true;
      profiles = [ "work" ];
    };
  };
}
```

各应用默认关闭，没有全局开关或模式选项。模块不负责安装应用；Firefox 需要单独启用 `programs.firefox`，使用系统 Firefox 时可设置 `programs.firefox.package = null`。

macOS 支持 darktable、Firefox 和鼠须管，不需要 plasma-manager：

```nix
colorscheme.squirrel.enable = true;
```

## 应用行为

| 应用 | 配置与使用条件 |
| --- | --- |
| KDE Plasma | 安装两套配色和仅包含配色设置的全局主题，启用原生昼夜切换；需要 Plasma 6.5+，时段在系统设置中管理 |
| Konsole | 生成 `NixGruvboxLight`、`NixGruvboxDark` 两套配色和同名配置档，启用原生跟随；需要 Konsole 26.08+ |
| Chromium | 使用 Breeze GTK，由 KDE 的 `kde-gtk-config` 同步颜色；首次在浏览器外观设置中选择“使用 GTK”和“设备”明暗模式 |
| digiKam | 使用“默认”主题跟随 KDE，同时提供 ID 与 KDE 一致的两套主题文件 |
| Firefox | 将 CSS 合并到指定配置档的 `userChrome`，启用样式表，通过 `prefers-color-scheme` 切换；应用后重启浏览器，并选择系统自动主题 |
| 鼠须管 | 写入 `~/Library/Rime/squirrel.custom.yaml` 的深浅配色，重新部署一次后跟随 macOS |
| darktable | 写入 `user.css` 并启用用户样式，默认深色；应用后重启，不支持自动切换 |

Plasma、Konsole、Chromium、digiKam 仅支持 Linux，并要求导入 plasma-manager。系统需要提供 KDE 桌面及相关组件；模块检查平台和模块依赖，不检测桌面会话或组件版本。Chromium 的 GTK 设置也会影响其他 GTK 应用；启动环境中的 `GTK_THEME` 会覆盖主题设置。桌面组件首次配置后建议重新登录。

## 自定义

Firefox 必须显式列出配置档名称，不扫描磁盘。所列名称会合并进 `programs.firefox.profiles`；未预先声明的名称也会成为 Home Manager 配置档。请为已有配置档填写实际路径，并在管理多个配置档时设置唯一的 ID 和默认配置档。样式表启用由 Home Manager 根据 `userChrome` 自动处理。

Konsole 通过 plasma-manager 的 `programs.konsole.profiles` 生成 `NixGruvboxLight`、`NixGruvboxDark` 配置档，默认字体为 `Monospace`。可以在同一配置档上声明字体和其他偏好，它们会在生成 INI 前合并：

```nix
programs.konsole.profiles = lib.genAttrs [ "NixGruvboxLight" "NixGruvboxDark" ] (_: {
  font = { name = "Sarasa Mono SC"; size = 11; };
  extraConfig.Scrolling.ScrollBarPosition = 2;
});
```

上例需要在模块参数中引入 `lib`。配置档名称固定，以匹配 Konsole 的原生深浅切换设置。

```nix
colorscheme.darktable = {
  enable = true;
  variant = "light"; # 默认 "dark"
  extraCss = "/* 附加 CSS */";
};

colorscheme.squirrel.extraPatch = {
  # 其他 squirrel.custom.yaml patch 设置。
};
```

darktable 保留图像评估区域的中性灰色；已有 CSS 应合并到 `extraCss`。`darktablerc-common` 中的用户样式开关会与其他模块声明的文本合并。鼠须管配色键由本模块管理，其他设置通过 `extraPatch` 合并。

## 结构

`flake.nix` 负责应用开关、平台检查和 plasma-manager 接入。`common.nix` 保存配色和共用的生成函数，`apps/` 每个文件负责一个应用。没有公开的配色或渲染库接口。

已使用真实 Home Manager 和 plasma-manager 模块检查 Linux、macOS 配置求值，并验证配置档名称匹配及无效配置的报错。尚未构建、激活或完成桌面图形界面验证。
