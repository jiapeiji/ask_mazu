# App Store Connect — App Review Notes 模板(V1.2)

> 复制下面 6 段到 **App Store Connect → 你的 App → App Review Information → Notes** 字段
> (录屏作为 Attachment 单独上传,不放 Notes 里)

---

## 1. App Purpose & Target Audience

```
Ask Mazu is a cultural-heritage and daily-reflection app for overseas
Chinese. It simulates the traditional Mazu temple ritual of throwing
moon blocks (poa) — but reframed as a mindfulness practice: the user
writes a daily reflection, throws the blocks to receive Mazu's feedback
as a poetic reply, and saves both into a personal journal.

This is NOT a fortune-telling or divination app. There are no
predictive categories (career / love / wealth), no lottery mechanics,
no zodiac, no horoscope, no omen reading. The throw is a ritual for
reflection, not a prediction of the future.

Problem: Overseas Chinese (diaspora) lack a quiet daily ritual that
honors their cultural roots. Most are far from temples.

Value: Provides a daily mindfulness practice grounded in Mazu culture;
preserves Chinese folk heritage through a digital chapter-reading
section; offers emotional comfort through cultural continuity.

Target audience: Overseas Chinese (ages 18-65) interested in Chinese
folk religion and culture. No age-inappropriate content.
```

---

## 2. Setup Instructions & Test Credentials

```
Setup:
1. Launch app
2. Onboarding shows a single field: enter a nickname (2-10 Chinese
   characters or 2-20 English chars)
3. Tap "完成 · 进入反思" (Complete · Enter Reflection) to finish
   onboarding
4. Main screen "今日" tab shows:
   - Greeting with date / lunar date
   - Today's reflection prompt (e.g. "今日有什么事让你挂心?")
   - Mood selector (5 emoji chips: 平和 / 低落 / 迷茫 / 充实 / 烦躁)
     — user must select one to continue
   - Optional "写下此刻的想法" text input
   - "掷杯筊 · 问妈祖" button (disabled until mood selected)
5. Tap the throw button → 4.76s throw animation video + ding sound
6. Result page shows Mazu's reply (sign poem + "保存 · 写入日记" button)
7. Tap save → entry added to Records tab → returns to Today tab showing
   "今日已记录 · 明日再见" (recorded today, see you tomorrow)

Other tabs:
- 记录 (Records): journal stream with streak counter
- 妈祖 (Mazu): placeholder for V1.2 — full cultural chapters ship in V2

Test credentials: No login required. No subscription. App is fully
free and works offline.

To test account deletion (Apple Guideline 5.1.1):
Settings → 数据 → 删除全部数据 → Confirm
```

---

## 3. External Services, Tools, and Platforms

```
External services used:

NONE for payment — V1.2 is fully free. The V1 In-App Purchase / StoreKit
integration has been completely removed.

STATIC ASSET HOSTING (no user data sent):
- GitHub Pages — static privacy policy hosting
  (https://jiapeiji.github.io/ask_mazu/privacy.html)

FLUTTER PACKAGES (all local, no network calls):
- audioplayers 5.2.1 — local audio playback (block land, result ding,
  ambient temple loop)
- video_player 2.14.1 — local video playback (3 throw animations)
- lunar 1.7.7 — local lunar calendar calculation
- shared_preferences 2.2.2 — local settings storage
- hive 2.2.3 — local NoSQL storage (nickname, journal records)
- path_provider 2.1.1 — local file path resolution
- flutter_riverpod 2.4.9 — local state management
- go_router 12.1.1 — local navigation

NO third-party SDKs for:
- Analytics (no Firebase / Google Analytics / Mixpanel)
- Advertising (no ad networks)
- Push notifications (no FCM / APNs)
- Social login (no Google / Apple / Facebook login)
- Cloud sync (no server-side data storage)
- AI services (no LLM / ML APIs)

App is fully offline-functional. Zero network activity required after
install. The privacy policy page is loaded on-demand only when the user
opens Settings → Privacy Policy.
```

---

## 4. Regional Differences

```
App functions consistently across all regions. The only variation is
UI text language (Simplified Chinese, Traditional Chinese, English),
which follows the user's system language setting (user can also
manually switch in Settings → Language).

No geo-restriction. No content blocking. No regional feature
differences. The same reflection prompts and Mazu content are available
to all users globally.

Localization coverage: Simplified Chinese (zh-CN), Traditional Chinese
(zh-TW), English (en-US fallback).
```

---

## 5. Highly Regulated Industry / Third-Party Material

```
CULTURAL / HERITAGE CONTENT:
This app is a cultural-heritage reflection tool, not a religious
counseling service and not a divination / fortune-telling app.

- No predictive claims. No "吉凶" / "上上" judgment.
- No category-based predictions (no career / love / wealth / health
  / study / family buckets — all removed in V1.2).
- No zodiac, horoscope, or omen reading.
- The throw ritual is presented as a reflective practice, with Mazu's
  reply framed as a poetic response — not as a prediction.

SIGN POEM TEXTS:
All 60 fortune stick texts are original adaptations of public-domain
classical Chinese poetry (including classical Mazu poetry forms that
pre-date modern copyright). No copyrighted material is used.

ILLUSTRATIONS / AUDIO / VIDEO:
All visual and audio assets are original works created specifically
for this app. No third-party protected material.

NO REGULATORY REQUIREMENTS apply:
- No medical / health claims
- No financial / investment advice
- No educational content requiring accreditation
- No gambling or lottery mechanics
- No fortune-telling / divination services (re-positioned in V1.2
  as a reflection tool)
- No in-app purchase / subscription (removed in V1.2)
```

---

## 6. Account Deletion (Apple Guideline 5.1.1)

```
This app supports account deletion as required by Guideline 5.1.1.

Path: Settings → 数据 → 删除全部数据 → Confirm

What is deleted:
- User profile (nickname only — no email, no password, no Apple ID
  collected)
- All journal entries (reflections + mood + Mazu replies)
- All settings (language, theme, sound, vibration preferences)

Note: V1.2 has NO subscription state — In-App Purchase was removed.
There is no server-side data to delete; everything lives on the user's
device.

After deletion, the app returns to its initial state and the user
must re-enter their nickname via the onboarding flow.

The deletion is permanent and cannot be undone. A confirmation dialog
with clear warning text is shown before deletion.
```

---

## 录屏要求(作为 Attachment 上传,不放 Notes)

上传位置:**App Review Information → Attachment** (拖拽 .mov 文件)

录屏内容(3-5 分钟):
1. 启动 App(展示今日 tab 主屏)
2. Onboarding 单步:输入昵称,完成
3. 今日 tab:看到反思 prompt + 心情选择器 + 输入框 + 投掷按钮(禁用)
4. 点一个心情 chip → 投掷按钮变可点
5. 可选:写一段反思
6. 点"掷杯筊 · 问妈祖" → 观看完整 4.76s 投掷视频
8. 展示结果页(签诗 + 用户反思小卡片 + 保存按钮)
9. 点"保存 · 写入日记" → 跳回今日 tab 显示"今日已记录"
10. 切到记录 tab:展示日记流 + 连续天数 banner
11. 切到妈祖 tab:展示占位页"V2 上线"
12. 进入设置,展示各项功能
13. **关键**:进入设置 → 数据 → 删除全部数据 → 确认 → 跳回 onboarding

录屏设备要求:**真机** + **iOS 最新版**(模拟器录屏 Apple 不接受)