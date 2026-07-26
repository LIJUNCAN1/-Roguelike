# GeneData 配置规范

每个基因使用独立 `.tres`，核心字段如下：

```text
id
display_name
description
rarity
category
tags
series_id
series_name
evolution_links
effects
```

## 稀有度

`COMMON`、`UNCOMMON`、`RARE`、`EPIC`、`LEGENDARY`。

## 分类

`COMBUSTION`、`PROLIFERATION`、`SURVIVAL`、`ADAPTATION`、`ABYSS`、`MECHANICAL`、`ELEMENTAL`、`SUMMONING`。

## 标签

标签使用稳定的英文 `StringName`，例如：

```text
projectile
fire
area
multishot
healing
control
```

标签用于后续 Build 共鸣检测，不应写成玩家可见描述。

## 进化关联

`evolution_links` 保存可能关联的 `EvolutionData.id`，供图鉴和进化提示读取。实际进化条件仍由 `EvolutionData` 配置，避免 GeneData 直接控制进化逻辑。

## 新增基因

1. 创建独立 `GeneEffect` Data。
2. 创建独立 `GeneData`。
3. 填写分类、稀有度、标签和进化关联。
4. 将基因加入奖励池或其他内容池。
5. 不修改 `GeneManager`、奖励房或图鉴核心代码。
