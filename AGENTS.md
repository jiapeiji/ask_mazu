# Ask Mazu (问妈祖)

海外华人 / 华裔 / 东南亚华人用的 iOS / Android App。模拟妈祖庙投掷杯筊的传统仪式，60 支妈祖签文。

产品背景 / 用户画像 / 商业目标见 `/Users/jiapeiji/.minimax/memory/user.md`。
跨项目 Flutter 踩坑（Xcode 缓存 / go_router reverse animation / lunar API 等）见 Mavis agent memory（`MEMORY.md`），**项目内不重复**。

---

## 核心流程：投掷 → 物理 → 签文匹配 → 结果

```
HomePage 选类+问题
   ↓ Navigator.push (PageRouteBuilder, 不走 go_router)
ThrowPage（postFrameCallback 启动）
   ↓ _physics.update() 60fps 模拟杯筊
   ↓ getResult() → saint/laugh/yin
matchForSaint (种子化)  OR  matchForYin (无种子)  OR  (laugh 无签)
   ↓ 记录到 QuestionRecord (Hive recordBox)
   ↓ 延迟 0.5s
Navigator.pushReplacement → ResultPage
```

**关键文件**：
- 投掷入口：`lib/features/home/home_page.dart`（`_onThrow`，L51）
- 物理+匹配：`lib/features/throw/throw_page.dart`（`_handleResult`，L74）
- 签文匹配规则：`lib/data/repositories/sign_repository.dart`
- 物理引擎：`lib/services/physics/block_physics.dart`
- 物理参数：`lib/core/constants/app_constants.dart`

---

## 签文匹配规则（最常被问的逻辑）

| 结果类型 | 调用 | 是否种子化 | 同类同时段同用户 → 签文 |
|---|---|---|---|
| 圣杯 saint | `matchForSaint` | ✅ | **同签** |
| 阴杯 yin | `matchForYin` | ❌ | **每次不同** |
| 笑杯 laugh | — | — | 无签，显示妈祖图 |

### 时段划分（`_timeSlot`，每天 4 段 × 6 小时）

| 时段 | 时间 |
|---|---|
| morning | 5:00 - 11:00 |
| noon | 11:00 - 17:00 |
| evening | 17:00 - 23:00 |
| night | 23:00 - 05:00 |

跨时段 / 跨日 → 必换签。**用户在 10:59 和 11:00 各投一次会拿到不同签**（这是 bug 报告高频点，已知设计）。

### 圣杯种子公式

```dart
final dateKey = '${date.year}${date.month}${date.day}';
final slot = _timeSlot(date);
final random = Random('$dateKey$slot$userId${category.name}'.hashCode);
return weighted[random.nextInt(weighted.length)];
```

- 同日同时段同用户同类别 → 同签
- **userId = `user.name ?? 'guest'`**：改名/退出登录/首次启动 → 签会变（**已知设计选择，不改**）
- `String.hashCode` 跨平台可能不同（iOS/Android 没事，将来上 Web 需替换为稳定 hash）

### 签池权重

| 等级 | 权重 | | 等级 | 权重 |
|---|---|---|---|---|
| 上上 | 10 | | 中下 | 10 |
| 上中 | 20 | | 下上 | 3 |
| 中上 | 30 | | 下中 | 1 |
| 中中 | 25 | | 下下 | 1 |

每签按权重重复塞进 `weighted` 列表，从里面抽。**中上 / 中中 合计 55%**，上签占 30%。

---

## 物理（杯筊）

`lib/services/physics/block_physics.dart`：

- 每次投掷 `throw_page.dart:57` 新建 `BlockPhysics()`，**无种子** → 物理结果（圣/笑/阴）每次都随机
- 两块杯筊初始 face 不同（flat / curved），随机初速度 + 角速度
- `getResult()` 根据最终角度判定（`_determineFace`：−π/2 ~ π/2 视为 flat）
- 调参在 `AppConstants`：`throwGravity / throwInitialSpeedMin/Max / throwInitialAngularMin/Max / throwAnimationDuration`

**用户视角**：连续投掷会看到不同结果（圣/笑/阴）和不同签文——**这是预期行为**（物理随机 + 阴杯无种子），不是 bug。客服场景下不要尝试"修复"。

---

## 模块速查

```
lib/
├── main.dart              # 启动入口：Hive init + 预热 user box（避免闪屏）
├── app.dart               # MaterialApp + router + theme
├── core/                  # 跨 feature 复用
│   ├── theme/             # AppColors（妈祖红 #??/米白/金）、AppTheme
│   ├── router/            # GoRouter 配置
│   ├── constants/         # AppConstants（物理参数/Hive box/订阅 ID）
│   ├── i18n/              # locale-aware 样式（letterSpacing / height）
│   └── utils/             # 农历 (LunarCalendar) + 签语模板 (ResultTemplates)
├── data/
│   ├── models/            # FortuneSign / QuestionRecord / UserProfile + 手写 Hive adapters
│   ├── repositories/      # Sign/Record/User/Settings 四仓
│   └── sources/local/     # （预留，目前空）
├── features/
│   ├── onboarding/        # 报家门（首次启动）
│   ├── home/              # 主屏（6 类卡片 + 自定义问题 + 投掷按钮）
│   ├── throw/             # 投掷页（物理动画）
│   ├── result/            # 结果页（圣/笑/阴）
│   ├── signs/             # 签文库
│   ├── history/           # 问事记录
│   ├── settings/          # 设置
│   └── shared/            # 共享 widget
├── services/
│   ├── physics/           # BlockPhysics
│   ├── audio/             # （占位，音效未实装）
│   ├── sound/             # SoundService（基础封装）
│   ├── subscription/      # （占位，IAP 未实装）
│   └── usage/             # 限次逻辑
├── l10n/                  # ARB 源 + 生成代码（不要手改 generated/）
└── providers/             # Riverpod 全局 providers（signsProvider / currentUserProvider / recordsProvider / remainingProvider / settingsProvider 等）
```

---

## 路由

定义在 `lib/core/router/app_router.dart`。

| 路径 | 页 | 备注 |
|---|---|---|
| `/` | (重定向 `/home`) | |
| `/onboarding` | OnboardingPage | user==null 时 redirect 进 |
| `/home` | HomePage | |
| `/throw` | ThrowPage | extra: `{category, question}`，**实际由 HomePage 用 Navigator.push 走**，不走 go_router |
| `/result` | ResultPage | extra: `{result, sign, category, question}`，NoTransitionPage |
| `/signs` | SignsLibraryPage | 签文库 |
| `/history` | HistoryPage | 问事记录 |
| `/settings` | SettingsPage | 从左往右滑入（按钮在左上） |

`routerProvider` 监听 `currentUserProvider` 变化触发 refresh（user 加载完 redirect 再跑，避免卡首页）。

---

## Hive 数据

box 名集中在 `AppConstants`：

- `user_box` → `UserProfile`（name + city + createdAt）
- `record_box` → `QuestionRecord`（问事记录：id / timestamp / question / category / result / signId / nameAtTime）
- `settings_box` → 主题/音效/震动/语言/首次启动
- `usage_box` → 今日剩余次数

Adapters **手写**在 `lib/data/models/hive_adapters.dart`，不依赖 build_runner（避免拖慢开发循环）。
新增 model → 写 TypeAdapter + 在 `main.dart` 注册。

---

## i18n

- 源：`lib/l10n/app_zh.arb` / `app_en.arb`（zh_TW 通过 `FortuneSign.i18n` 覆盖签文本身）
- 生成：`lib/l10n/generated/app_localizations*.dart`（**不要手改**）
- 配置：`l10n.yaml`
- 模型层 `FortuneSign` 支持 `i18n: { localeCode: {title, poem, interpretation, allusion, modernNotes} }`，缺失字段 fallback 到默认（zh_CN）
- 新增字符串 → 改 ARB → `flutter pub get` 自动触发生成 → 代码用 `AppLocalizations.of(context).xxx`

样式按 locale 适配用 `lib/core/i18n/locale_aware_style.dart`（`letterSpacingFor` / `heightFor`）。

---

## 资产结构

```
assets/
├── data/
│   └── signs.json         # 60 支签文（核心数据，不要手改——用 scripts/translate_signs_*.py）
├── audio/                 # 音效（待添加）
├── animations/            # Lottie
├── images/                # UI 切图
│   ├── home/              # 主屏切图
│   ├── result/            # 旧版结果页（保留）
│   └── result_new/        # 当前结果页切图
├── fonts/                 # ChillJinshuSong 等
└── design/                # 设计稿
```

切图命名：`{语义}@{2x|3x}.png`（如 `圣杯-bg@2x.png`），新增按 page 分子目录。

---

## 常用命令

```bash
# 跑（iOS 模拟器先 open -a Simulator）
flutter run

# 清理 Xcode 缓存（Dart 编译错误经常级联成 PhaseScriptExecution 假象）
flutter clean
rm -rf ios/Pods ios/Podfile.lock build .dart_tool ~/Library/Developer/Xcode/DerivedData/Runner-*

# 分析 + 测试
flutter analyze
flutter test
```

完整 Flutter 跨项目踩坑清单见 Mavis agent memory（`MEMORY.md` "Flutter 项目搭建踩坑" 条目）。

---

## 设计原则（产品定位）

- **仪式感 > 工具性**：妈祖给指示，不是 AI 给答案（不要加 "AI 解读" 这类功能）
- **稳定 > 随机**：圣杯同档同签，让用户感觉"妈祖今天的态度"
- **视觉 > 文字**：UI 按 750pt 设计稿还原，`result_page.dart` 顶部有调参速查
- **离线优先**：所有数据本地 + 60 支签内置，无后端依赖
- **限次 + 订阅**：免费每日 3 次 (`freeDailyLimit`)，签文库免费 30 支 (`freeSignsLimit`)，订阅全解锁
- **沉默运行**：soundService / haptic / ambient 都有开关，默认是用户**已经同意**了，不弹授权弹窗

---

## 待办 / 已知缺口

- [ ] 音效（`services/audio/` 目录空，sound service 也只占位）
- [ ] 订阅（`services/subscription/` 目录空，`isSubscribedProvider` 在 debug 默认 true，release 默认 false）
- [ ] iOS 上架 / App Store 审核（已加 Apple Developer 申请到未来可能问的事）
