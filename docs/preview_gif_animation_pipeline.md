# GIF 动作素材处理说明

## 输出位置

- 完整可编辑素材：
  `D:\game1\素材\sample\preview_character\<动作名>\`
- Godot 运行时精简素材：
  `res://assets/sprites/player/preview_character/v1/<动作名>/`

完整素材的每个动作目录包含：

- `frames/frame_000.png`：透明 PNG 分帧；
- `<动作名>.png`：64×64 横向 Sprite Sheet；
- `<动作名>.gif`：透明动画预览；
- `<动作名>.aseprite`：单图层、保留逐帧时长和动画标签；
- `metadata.json`：帧数、逐帧时长、循环方式和脚底锚点。

Godot 目录只保留 Sprite Sheet 和 metadata，避免把数百张编辑分帧
重复提交到游戏仓库。

## 动作命名

| 目录 | 动作 |
|---|---|
| `jump` | 跳跃 |
| `slide` | 滑铲 |
| `dodge` | 闪避 |
| `hurt` | 受击 |
| `knockdown` | 击倒恢复 |
| `heal` | 回复技能 |
| `run_start` | 跑动起步 |
| `run_loop` | 跑动循环 |
| `run_stop` | 跑动收步 |

## 清理方式

`res://tools/process_preview_gifs.py` 会将 4 倍放大的 GIF 恢复到
原生像素尺寸，使用静态背景差分清除背景、水印和参考框，裁掉脚底
以下的镜像倒影，并按照 `(32, 58)` 脚底锚点统一到 64×64 画布。

转换是确定性的，不使用生成式补帧。角色、动作残影、跳跃位移和回复
特效会保留。跑步录屏中的起步、循环和收步会分别输出，其中循环只
保留首尾衔接的 20 帧。

## 游戏接入

- `run_start → run_loop → run_stop`：由移动状态自动切换；
- `dodge`：现有空格冲刺；
- `jump`：Q；
- `slide`：X；
- `hurt`：受到伤害；
- `heal`：生命值实际增加；
- `knockdown`：死亡/击倒表现。

跳跃与滑铲参数位于 `res://data/player/default_actions.tres`，以后可以
只修改 Data 调整速度、持续时间、冷却和无敌时间。

## Aseprite 验证

当前机器未检测到 Aseprite 命令行程序，因此转换工具依据官方
`.ase/.aseprite` 文件格式生成 RGBA 压缩 Cel、逐帧时长和标签，并
在写出后重新解压每一个 Cel 与 PNG 原帧逐像素校验。之后安装
Aseprite 时可直接打开这些文件继续编辑。
