# 美术替换说明

`generated/` 保存当前原型使用的像素图集：

- `player_forms-v2.png`：原始、深渊、机械三种玩家形态参考动画。
- `enemies_bosses-v2.png`：近战敌人、孢子射手、基因吞噬体、机械熔铸核心。
- `region_tiles-v2.png`：原生、深渊、机械三个区域的瓦片和环境物件。

## 角色与敌人

角色动画由 `ActorVisualData` 配置，路径为 `data/art/`。可替换：

- `atlas_texture`
- `frame_regions`
- 各状态的帧编号
- 播放速度、缩放和偏移

`PixelActorPresenter` 负责待机、移动、攻击、受击、死亡、进化与 Boss 阶段动画。资源缺失时自动显示原程序化图形。

## 地图

区域美术由 `RegionVisualData` 配置。正式制作地图时可指定：

- `tile_set`
- `environment_scene`
- `background_texture`

当前 `source_atlas` 和 `source_region` 保存生成图集及区域范围，方便重新切片。

## 音频

音效使用 `AudioCueData`，音乐使用 `MusicTrackData`。将 WAV、OGG 等资源拖入对应 Data 的 `stream` 字段即可替换；留空时使用程序合成回退，不需要修改事件连接代码。

生成方式：OpenAI 内置图像生成工具；原始色键图经官方技能中的 `remove_chroma_key.py` 去背后保存到项目。
