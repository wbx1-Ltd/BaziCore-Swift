<div align="center"><a name="readme-top"></a>

# BaziCore

严谨、可配置、可验证的纯 Swift 八字（四柱）计算核心。<br/>
规则显式、边界可追踪、金标夹具验证、provider 分层。

[English](./README.md) · [报告问题][github-issues-link] · [更新日志][github-release-link]

<!-- SHIELD GROUP -->

[![][github-stars-shield]][github-stars-link]
[![][github-forks-shield]][github-forks-link]
[![][github-issues-shield]][github-issues-link]
[![][github-license-shield]][github-license-link]<br/>
[![][github-contributors-shield]][github-contributors-link]

</div>

<details>
<summary><kbd>目录</kbd></summary>

#### TOC

- [✨ 特性](#-特性)
- [🧩 架构](#-架构)
- [🗂️ 模块](#️-模块)
- [🧠 设计取向](#-设计取向)
- [📦 安装](#-安装)
- [🚀 用法](#-用法)
- [🔬 验证](#-验证)
- [⚡ 性能](#-性能)
- [🗺️ 路线图](#️-路线图)
- [📋 支持范围](#-支持范围)
- [📚 参考](#-参考)
- [📝 许可证](#-许可证)

####

<br/>

</details>

## ✨ 特性

| | 能力 | 说明 |
|-|------|------|
| 🎯 | **四柱排盘** | 年/月/日/时四柱，边界规则可配置 |
| 🧭 | **边界可追踪** | 立春、节令、子时、真太阳时的判断随结果一起返回 |
| 📚 | **命理表** | 藏干、十神、五行、纳音、空亡、神煞 —— 表驱动 |
| 🔁 | **运限计算** | 大运、流年、流月、小运与起运 |
| 🌙 | **历法 provider** | 通过 `LunarCore-Swift` 提供干支与节气数据 |
| ☀️ | **天文 provider** | 通过 `AstroCore-Swift` 提供真太阳时与精确节气 |
| 🧱 | **分层 provider** | 历法与天文引擎可替换，核心不绑定任何具体实现 |
| 🧪 | **金标夹具** | 自产基准，跨 17,000+ 张命盘（含各类边界）交叉验证 |
| 🧵 | **线程安全** | 目标全面遵循 `Sendable` |
| 🚫 | **表结构隔离** | 命理派生表不混入历法引擎 |

<div align="right">

[![][back-to-top]](#readme-top)

</div>

## 🧩 架构

`BaziCore` 站在历法与天文核心之上，把八字规则与中国农历转换、天文计算彻底分开。
每一块都是独立 product，可以按需单独引入。

```text
BaziCore                         规则 · 输入 · 柱模型 · 排盘核心
   │
   ├─ BaziCoreTables             藏干 · 十神 · 五行 · 纳音 · 空亡 · 神煞
   │
   ├─ BaziCoreLuck               大运 · 流年 · 流月 · 小运 · 起运      (依赖 Tables)
   │
   ├─ BaziCoreLunarCoreAdapter   干支与节气数据                       (经 LunarCore-Swift)
   │
   ├─ BaziCoreAstronomy          真太阳时与精确节气                   (经 AstroCore-Swift)
   │
   └─ BaziCoreTesting            金标夹具 schema · provider 一致性工具
```

<div align="right">

[![][back-to-top]](#readme-top)

</div>

## 🗂️ 模块

| 模块 | 依赖 | 职责 |
|------|------|------|
| `BaziCore` | — | 出生输入、规则集、柱模型、排盘核心 |
| `BaziCoreTables` | `BaziCore` | 藏干、十神、五行、纳音、空亡、神煞等表 |
| `BaziCoreLuck` | `BaziCore`、`BaziCoreTables` | 大运、流年、流月、小运与起运计算 |
| `BaziCoreLunarCoreAdapter` | `BaziCore`、`LunarCore` | 基于 `LunarCore-Swift` 的干支与节气数据 |
| `BaziCoreAstronomy` | `BaziCore`、`AstroCore` | 基于 `AstroCore-Swift` 的真太阳时与精确边界 |
| `BaziCoreTesting` | `BaziCore` | 金标夹具 schema 与 provider 一致性工具 |

<div align="right">

[![][back-to-top]](#readme-top)

</div>

## 🧠 设计取向

- **规则显式化**：立春、节令、子时、真太阳时都必须进入配置，绝不藏在默认值里。
- **结果可追踪**：边界判断与 provider 置信度随结果一起返回，每个值都能解释来由。
- **表结构隔离**：命理派生表不混入历法或天文引擎。
- **验证够彻底**：金标夹具由自身引擎生成，并跨 17,000+ 张、横跨一个多世纪的命盘交叉验证，覆盖闰日、时辰边界与所有节气临界。

<div align="right">

[![][back-to-top]](#readme-top)

</div>

## 📦 安装

### Swift Package Manager

添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/wbx1-Ltd/BaziCore-Swift.git", from: "1.0.0"),
]
```

然后在 target 中只引入需要的 product：

```swift
.target(
    name: "YourTarget",
    dependencies: [
        "BaziCore",                  // 核心规则与排盘
        "BaziCoreTables",            // 命理表
        "BaziCoreLuck",              // 运限计算
        "BaziCoreLunarCoreAdapter",  // 经 LunarCore 的干支与节气
        "BaziCoreAstronomy",         // 经 AstroCore 的真太阳时
    ]
),
```

或在 Xcode 中：**文件 → 添加包依赖…** → 粘贴上方 URL。

<div align="right">

[![][back-to-top]](#readme-top)

</div>

## 🚀 用法

从一个出生时刻排盘。排盘器需要一个节气 provider，`BaziCoreAstronomy` 提供高精度实现。

```swift
import BaziCore
import BaziCoreAstronomy

let moment = try CivilMoment(
    year: 1995, month: 6, day: 15, hour: 8, minute: 30,
    timeZoneIdentifier: "Asia/Shanghai"
)
let input = BirthInput(moment: moment, sexForLuckCycle: .female)

let calculator = BaziCalculator(solarTermProvider: AstronomicalSolarTermProvider())
let chart = try calculator.chart(for: input)

print(chart.fourPillars.chinese) // 乙亥 壬午 丁丑 甲辰
print(chart.dayMaster.chinese)   // 丁
```

每张盘都带 trace，任何值都能解释来由：

```swift
chart.trace.provider     // .astronomy
chart.trace.confidence   // .canonical
chart.trace.notes        // [.yearBoundaryLiChunExact, .birthBeforeLiChun, …]
```

从 `BaziCoreTables` 派生命理表与神煞：

```swift
import BaziCoreTables

let tenGod = TenGodEngine.tenGod(of: chart.fourPillars.year.stem, dayMaster: chart.dayMaster)
let naYin = NaYinTable.naYin(for: chart.fourPillars.day.cycle)
let shenSha = ShenShaCatalog.ziPingCommon.evaluate(chart: chart)
```

从 `BaziCoreLuck` 计算运限：

```swift
import BaziCoreLuck

let direction = LuckDirection.resolve(yearStem: chart.fourPillars.year.stem, sex: .female)
let childLimit = try ChildLimitEngine.compute(
    birth: moment, direction: direction, rule: .threeDaysPerYear,
    provider: AstronomicalSolarTermProvider()
)
let daYun = DaYunEngine.compute(
    monthPillar: chart.fourPillars.month.cycle, birthGregorianYear: 1995,
    childLimit: childLimit, direction: direction
)
```

启用真太阳时：设置规则并注入校正器：

```swift
var rules = BaziRuleSet.professionalDefault
rules.timeCorrection = .trueSolarTime

let calculator = BaziCalculator(
    ruleSet: rules,
    solarTermProvider: AstronomicalSolarTermProvider(),
    timeCorrectionProvider: TrueSolarTimeEngine()
)
let chart = try calculator.chart(for: BirthInput(
    moment: moment,
    location: CalculationLocation(longitude: 87.6)
))
```

<div align="right">

[![][back-to-top]](#readme-top)

</div>

## 🔬 验证

`BaziCoreTesting` 定义金标夹具 schema 与 provider 一致性工具，让每张盘都能对照
独立、有来源的基准做校验，而不是只信任单一引擎的输出。

| 策略 | 说明 |
|------|------|
| **金标夹具** | 预期结果以带版本的夹具存储，在 CI 中回放比对 |
| **Provider 一致性** | 同一输入经不同历法/天文 provider 必须给出一致结果 |
| **交叉验证** | 引擎输出跨 17,000+ 张命盘与完整节气范围比对，精确到秒 |
| **边界用例** | 立春、节令交界、子时跨界、真太阳时临界等场景 |

<div align="right">

[![][back-to-top]](#readme-top)

</div>

## ⚡ 性能

在 Apple Silicon、release 构建下实测。

| | 指标 | 结果 |
|-|------|------|
| 🏎️ | 四柱吞吐 | 约 25,000 盘/秒（暖态约 40 µs/盘） |
| 🔮 | 含完整运限 | 约 19,000 盘/秒（约 53 µs/盘） |
| ❄️ | 冷启动单盘 | 约 5 ms（首盘现算节气） |
| 🧠 | 内存 | 稳定约 8 MB —— 2 万到 20 万张持平，无泄漏 |
| ✅ | 验证 | 跨 1902–2099 的 17,000+ 张命盘交叉比对，零分歧 |

节气瞬时精确到秒；节气缓存有界、线程安全，不会无界增长。

<div align="right">

[![][back-to-top]](#readme-top)

</div>

## 🗺️ 路线图

计算层已完整实现、完成交叉验证，并随 `1.0.0` 发布。

- [x] 包结构、六模块拆分、CI（format / lint / test）
- [x] 出生输入与可配置规则集
- [x] 四柱排盘核心
- [x] 命理表（`BaziCoreTables`）
- [x] 历法与天文适配器（`LunarCore` / `AstroCore`）
- [x] 运限计算（`BaziCoreLuck`）
- [x] 金标夹具与交叉验证套件（`BaziCoreTesting`）
- [x] 首个正式发版（`1.0.0`）

<div align="right">

[![][back-to-top]](#readme-top)

</div>

## 📋 支持范围

| | 项目 | 范围 |
|-|------|------|
| 🖥️ | 平台 | iOS 15+ · macOS 12+ · tvOS 15+ · watchOS 8+ · visionOS 1+ |
| 🔧 | Swift | 6.0+ |
| 🌙 | 历法 provider | `LunarCore-Swift` 1.2.0+ |
| ☀️ | 天文 provider | `AstroCore-Swift` 2.0.0+ |

<div align="right">

[![][back-to-top]](#readme-top)

</div>

## 📚 参考

| 来源 | 用途 |
|------|------|
| [`LunarCore-Swift`](https://github.com/wbx1-Ltd/LunarCore-Swift) | 干支与节气数据 provider |
| [`AstroCore-Swift`](https://github.com/wbx1-Ltd/AstroCore-Swift) | 真太阳时与精确节气 |

<div align="right">

[![][back-to-top]](#readme-top)

</div>

## 📝 许可证

Copyright &copy; 2026-present [wbx1 Ltd.][profile-link].<br/>
本项目基于 [MIT](./LICENSE) 许可证发布。

<!-- LINK GROUP -->

[back-to-top]: https://img.shields.io/badge/-BACK_TO_TOP-151515?style=flat-square
[github-contributors-link]: https://github.com/wbx1-Ltd/BaziCore-Swift/graphs/contributors
[github-contributors-shield]: https://img.shields.io/github/contributors/wbx1-Ltd/BaziCore-Swift?color=c4f042&labelColor=black&style=flat-square
[github-forks-link]: https://github.com/wbx1-Ltd/BaziCore-Swift/network/members
[github-forks-shield]: https://img.shields.io/github/forks/wbx1-Ltd/BaziCore-Swift?color=8ae8ff&labelColor=black&style=flat-square
[github-issues-link]: https://github.com/wbx1-Ltd/BaziCore-Swift/issues
[github-issues-shield]: https://img.shields.io/github/issues/wbx1-Ltd/BaziCore-Swift?color=ff80eb&labelColor=black&style=flat-square
[github-license-link]: https://github.com/wbx1-Ltd/BaziCore-Swift/blob/main/LICENSE
[github-license-shield]: https://img.shields.io/github/license/wbx1-Ltd/BaziCore-Swift?color=white&labelColor=black&style=flat-square
[github-release-link]: https://github.com/wbx1-Ltd/BaziCore-Swift/releases
[github-stars-link]: https://github.com/wbx1-Ltd/BaziCore-Swift/stargazers
[github-stars-shield]: https://img.shields.io/github/stars/wbx1-Ltd/BaziCore-Swift?color=ffcb47&labelColor=black&style=flat-square
[profile-link]: https://github.com/wbx1-Ltd
