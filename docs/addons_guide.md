# Godot 插件使用指南

本项目中的第三方插件统一存放在 `res://addons/`。

## 使用原则

1. 插件可以安装，但未接入游戏前保持禁用。
2. 新功能优先复用现有项目系统；只有插件能明显降低复杂度时才接入。
3. 接入运行时插件前，先用独立测试场景验证 Godot 版本兼容性。
4. 不允许插件直接覆盖 `project.godot`、`.gitignore`、项目 README、图标或现有数据资源。
5. 每次只启用当前任务需要的插件，测试通过后再提交插件配置。
6. 场景、音频、输入和相机插件不得与现有系统并行接管同一职责。

## 插件清单

| 插件 | 版本 | 类型 | 用途 | 项目中的调用条件 |
| --- | --- | --- | --- | --- |
| Animated Sprite to Player (`AS2P`) | 未声明 | 编辑器工具 | 将 `AnimatedSprite2D` 中的 `SpriteFrames` 动画转换成 `AnimationPlayer` 动画 | 已有完整逐帧动画，并且需要属性轨道或统一 AnimationPlayer 工作流时使用 |
| Dialogue Manager | 3.10.5 | 编辑器 + 运行时 | 非线性对话、选项、条件、跳转和本地化 | 制作主大厅 NPC、剧情或随机事件对话时使用 |
| gdfxr | 2.1 | 编辑器工具 | 生成和导入复古电子音效 | 缺少正式音频时，为攻击、受击、按钮和升级制作占位音效 |
| Godot State Charts | 0.22.5 | 编辑器 + 运行时 | 分层状态机、并行状态、守卫条件和状态调试 | Boss 阶段或敌人/角色状态复杂到现有枚举状态难以维护时使用 |
| Input Helper | 4.7.0 | 运行时单例 | 检测键鼠/手柄设备和管理输入显示 | 增加手柄支持、动态按键提示或输入重映射界面时使用 |
| Kanban Tasks | 2.2.0 | 编辑器工具 | 编辑器内任务看板 | 仅用于开发任务管理，不进入游戏运行逻辑 |
| Importality | 0.3.0 | 编辑器导入器 | 导入 Aseprite、Krita、Pencil2D、Piskel 和 Pixelorama 文件 | 需要把源美术直接转换为图集、SpriteFrames 或 AnimationPlayer 场景时使用 |
| Phantom Camera | 0.11.0.3 | 编辑器 + 运行时 | 2D/3D 相机跟随、缓动、限制、震屏和镜头切换 | 制作 Boss 镜头、过场、震屏或复杂跟随时使用 |
| Scene Manager | 2.0.0 | 运行时单例 | 异步加载、加载界面、淡入淡出和场景切换 | 正式统一“标题 → Hub → 战斗 → Hub”流程时使用 |
| Sound Manager | 1.2.0 | 运行时单例 | 音效池、音乐交叉淡化、环境音、总线音量和静音 | 统一接入 BGM、Boss 音乐、战斗音效和设置菜单时使用 |
| YARD | 1.2.0 | 编辑器 + 运行时 | 扫描、登记和查询 Resource 数据 | 基因、敌人、Build 等数据量增大且现有数据目录查询不足时使用 |

## 项目适配规则

### 角色动画

- 当前模块化角色使用部件节点和脚本动画，不因为安装 AS2P 就改写。
- Importality 用于导入 Aseprite/Krita 等源文件；AS2P 只负责后续动画格式转换。
- `AnimatedSprite2D` 是 Godot 内置节点，不属于任何插件。

### 状态系统

- 简单移动、攻击和冲刺继续使用现有 Player 状态逻辑。
- Godot State Charts 优先用于多阶段 Boss、复杂敌人 AI 或互相并行的异常状态。
- 接入前必须先做一个独立敌人测试场景，避免一次性重写现有 Player。

### 相机

- 当前 `Camera2D` 和 Hub 摄像机限制继续保留。
- 接入 Phantom Camera 时，先迁移单个测试场景。
- 同一时刻只能有一套相机系统控制主摄像机，不能让原 Camera2D 与 Phantom Camera 同时跟随。

### 场景切换

- 现有场景流程在 Scene Manager 接入前保持不变。
- 接入时统一封装标题、Hub、战斗和返回 Hub 的入口。
- 禁止同时调用 Scene Manager 和 `SceneTree.change_scene_to_file()` 完成同一次切换。

### 音频

- 当前 `Music`、`SFX` 总线继续作为项目基线。
- Sound Manager 不得直接覆盖现有 `default_bus_layout.tres`。
- 正式接入时需要把插件的 Music、Sound effects、UI sounds、Ambient sounds 映射到项目设置菜单。
- gdfxr 只生成资源，Sound Manager 负责运行时播放，两者职责不同。

### 输入

- 现有 InputMap 动作名称保持不变。
- Input Helper 只提供设备识别、提示切换和重映射辅助，不重命名现有动作。

### 数据

- 当前 GeneData、EnemyData 和 Build 数据文件仍是数据源。
- YARD 只能作为索引和查询层，不能另建一套重复数据。

## 启用流程

1. 在 `项目 → 项目设置 → 插件` 中只启用目标插件。
2. 检查 `project.godot` 是否新增了预期的插件和 Autoload。
3. 创建独立测试场景验证插件核心功能。
4. 运行项目和相关 smoke tests。
5. 确认没有覆盖现有输入、音频、场景或数据配置。
6. 再把插件接入正式系统并提交。

## 已知风险

- AS2P 没有声明版本，正式使用前必须验证 Godot 4.7.1 兼容性。
- Importality 自带说明警告新版 Godot 可能出现空 SpriteFrames，使用前应做单独导入测试。
- Phantom Camera 和 Scene Manager 都会增加 Autoload，未使用时不应启用。
- Sound Manager 默认总线名称与项目现有总线不完全一致，必须显式适配。
- 示例项目、临时文件和插件仓库根目录资源不得放在游戏项目根目录。
- 插件附带的 C# 文件不代表项目需要切换到 Godot .NET；当前项目继续使用标准 Godot 和 GDScript。

## 启用记录

### 2026-07-30：主菜单转场与音效替换

本次启用：

- Scene Manager 2.0.0
  - 原因：为“主菜单 → 原初之种主大厅”提供统一转场。
  - 配置：增加 `SceneManager` Autoload。
  - 兼容修正：切换前重新读取当前 SceneTree 场景，避免 Autoload
    早于初始场景就绪时出现空场景释放错误。
  - 接入位置：`res://scripts/ui/title_screen.gd`。
  - 当前效果：深绿色圆形溶解、后台加载和防止重复点击。
  - 回退方式：将 `start_game()` 恢复为
    `SceneTree.change_scene_to_file()`，然后移除 Autoload 和插件启用项。
- Sound Manager 1.2.0
  - 原因：统一菜单和战斗音效播放池。
  - 配置：增加 `SoundManager` Autoload。
  - 项目适配：插件的声音、UI 和环境音播放器统一路由到现有
    `SFX` 总线；音乐继续使用 `Music`，没有创建重复总线。
  - 生命周期修正：项目退出时主动停止播放器、释放流与 Tween，
    防止自动化测试残留音频资源。
  - 接入位置：`res://scripts/ui/title_screen.gd` 和
    `res://scripts/audio/game_audio_director.gd`。
  - 回退方式：恢复 GameAudioDirector 自有播放器池，移除 Autoload。
- gdfxr 2.1
  - 原因：生成可版本管理的菜单和战斗音效资源。
  - 配置：只启用编辑器插件，不增加 Autoload。
  - 生成工具：`res://tools/generate_gdfxr_audio.gd`。
  - 输出目录：`res://assets/audio/generated/`。
  - 已生成：菜单悬浮、菜单确认、进入游戏、攻击、冲刺、受击、
    死亡、进化和 Boss 阶段音效。
  - 回退方式：给 AudioCueData 指定其他 AudioStream 即可替换，
    不需要修改播放核心。

本次没有启用其他插件，也没有修改现有输入动作、基础分辨率或
`Music/SFX` 设置接口。

### 2026-07-30：返回转场与 Hub 镜头缩小

- 没有启用新插件。
- 继续复用 Scene Manager 2.0.0：
  - 通用 PauseMenu 的返回按钮改为圆形溶解转场。
  - 同时覆盖“战斗 → Hub”和“Hub → 标题”。
  - 返回过程中禁用按钮并防止重复触发。
- 继续复用 Sound Manager 1.2.0：
  - 返回转场播放已有的进入游戏转场音效。
- Hub 使用现有 Camera2D 完成一次性入场镜头动画：
  - 起始缩放为 `2.0×`。
  - 平滑缩小到 `1.45×`，显示更大的大厅范围。
  - 没有启用 Phantom Camera，因为当前需求只需要一次简单缩放，
    同时启用两套相机控制会增加冲突风险。
- 战斗场景继续保持 `2.0×`，避免显示单个战斗房间边界外区域。

### 2026-07-31：大厅镜头稳定与近战音效分层

- 没有启用新插件。
- 继续复用 gdfxr 2.1：
  - 重新生成辨识度更高的短促挥刀风声。
  - 新增独立的近战命中音效 `attack_impact.res`。
  - 生成脚本仍为 `res://tools/generate_gdfxr_audio.gd`。
- 继续复用 Sound Manager 1.2.0：
  - 挥刀时播放武器配置的 `attack_cue`。
  - 只有投射物实际造成伤害时才播放 `impact_cue`。
  - 播放器继续使用项目现有 `SFX` 总线。
- 音效接口：
  - `WeaponData` 增加可替换的攻击和命中 AudioCueData。
  - `Projectile` 通过 `impact_confirmed` 信号报告有效命中。
  - 后续替换正式音频只需修改武器 Data，不需要改音频核心代码。
- 大厅 Camera2D 停用原生位置平滑，改为按照当前 zoom 对世界坐标
  做屏幕像素量化，避免 `1.45×` 缩放和像素吸附共同造成角色抖动。
- 回退方式：
  - 删除武器 Data 中的 cue 引用即可回到全局默认攻击音效。
  - 关闭 `camera_pixel_stabilization_enabled` 可停用大厅像素稳定。
