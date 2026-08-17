# 问妈祖 / Ask Mazu

> 海外华人的日常仪式 —— 投掷杯筊，问事求签。

## 简介

问妈祖是一个面向海外华人 + 华裔 + 东南亚华人的 iOS / Android App。模拟妈祖庙投掷杯筊的传统仪式，提供 60 支妈祖签文，让用户通过日常小决策的仪式化指引获得情感连接。

## 项目结构

```
ask_mazu/
├── lib/
│   ├── main.dart                    # 启动入口
│   ├── app.dart                     # App 入口
│   ├── core/                        # 核心
│   │   ├── theme/                   # 主题（妈祖红/米白/金）
│   │   ├── router/                  # GoRouter 路由
│   │   ├── constants/               # 常量
│   │   └── utils/                   # 工具（农历、文案模板）
│   ├── data/                        # 数据
│   │   ├── models/                  # 模型（签文/记录/用户）
│   │   ├── repositories/            # 仓储
│   │   └── sources/                 # 数据源（Hive）
│   ├── features/                    # 功能页
│   │   ├── onboarding/              # 报家门
│   │   ├── home/                    # 主界面
│   │   ├── throw/                   # 投掷页（核心物理动画）
│   │   ├── result/                  # 结果页（圣/笑/阴）
│   │   ├── signs/                   # 签文库
│   │   ├── history/                 # 问事记录
│   │   ├── settings/                # 设置
│   │   └── shared/                  # 共享 widget
│   ├── services/                    # 服务
│   │   ├── physics/                 # 杯筊物理
│   │   ├── audio/                   # 音效
│   │   └── usage/                   # 限次逻辑
│   └── providers/                   # Riverpod providers
├── assets/
│   ├── data/
│   │   └── signs.json               # 60 支签文
│   ├── audio/                       # 音效（待添加）
│   ├── images/                      # 图片（待添加）
│   └── animations/                  # Lottie 动画（待添加）
└── pubspec.yaml
```

## 快速开始

```bash
# 1. 安装依赖
flutter pub get

# 2. 运行
flutter run

# 3. 构建 iOS
flutter build ios --release
```

## 当前进度

- [x] 项目骨架 + 主题 + 路由
- [x] 数据模型 + Hive 适配器
- [x] 仓储层（签文/记录/用户/限次）
- [x] 60 支签文 JSON 数据
- [x] 报家门页
- [x] 主界面（投掷入口）
- [x] 投掷页（物理动画）
- [x] 结果页（圣/笑/阴 + 名字呼出）
- [x] 签文库
- [x] 问事记录
- [x] 设置页
- [ ] 音效（待添加）
- [ ] 字体（NotoSerifSC）
- [ ] App 图标
- [ ] iOS 上架准备
- [ ] Apple 内购

## 核心特性

### 1. 报家门（首次启动）
- 名字 + 城市
- 后续自动带入 + 结果页呼出

### 2. 投掷杯筊（核心交互）
- 物理动画（自定义 2D）
- 随机抛出 + 落地翻转
- 音效同步
- 物理结果直接判定（不作弊）

### 3. 签文系统
- 60 支核心签（八等分布）
- 圣杯按等级加权随机
- 阴杯强制匹配下等签
- 同一天同一问题给同一签（一日一签）

### 4. 名字呼出
- 5 套圣杯文案
- 3 套笑杯文案
- 3 套阴杯文案
- 随机抽取

### 5. 限次 + 订阅
- 免费版：3 次/天 + 30 支签
- 订阅版：无限 + 完整 60 支

## 技术栈

- **Flutter** 3.x
- **Dart** 3.x
- **Riverpod** 状态管理
- **GoRouter** 路由
- **Hive** 本地存储
- **google_fonts** 字体
- **audioplayers** 音效
- **chinese_calendar** 农历

## 文档

详细文档见 `ask-mazu/` 目录：
- `PRD-v0.1.md` - 产品需求文档
- `签文系统.md` - 签文框架
- `60支签文-完整版.md` - 60 支签文详细
- `线框图.md` - 页面线框
- `技术方案.md` - 技术方案

## License

Private
