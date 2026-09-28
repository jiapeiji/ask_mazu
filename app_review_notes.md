# App Store Connect — App Review Notes 模板

> 复制下面 6 段到 **App Store Connect → 你的 App → App Review Information → Notes** 字段
> (录屏作为 Attachment 单独上传,不放 Notes 里)

---

## 1. App Purpose & Target Audience

```
Ask Mazu is a cultural recreation app that simulates the traditional
Mazu temple ritual of throwing moon blocks (poa) to seek Mazu's
guidance on daily decisions. It is designed for overseas Chinese
(diaspora in North America, Singapore, Malaysia, Hong Kong, Taiwan,
Australia) who want a digital connection to Chinese folk religious
tradition.

Problem: Overseas Chinese lack easy access to traditional Mazu
divination rituals in their daily life.

Value: Provides a daily ritual for reflection and decision-making,
preserves Chinese folk culture digitally, and offers emotional
comfort through cultural continuity.

Target audience: Overseas Chinese (ages 18-65) with interest in
Chinese folk religion and culture. No age-inappropriate content.
```

---

## 2. Setup Instructions & Test Credentials

```
Setup:
1. Launch app
2. Enter a name (2-10 Chinese characters or 2-20 English chars)
3. Enter a city (2-30 chars)
4. Tap "入殿问事" (Enter Temple) to complete onboarding
5. Main screen shows 6 question categories + custom question field
6. Tap "投掷杯筊" (Throw Blocks) to begin

Test credentials: No login required. App works offline after
onboarding. Subscription unlocks unlimited throws + 60-stick library.

For testing the subscription:
- Sandbox Apple ID: use the Apple ID configured in App Store Connect
  → Users and Access → Sandbox Testers
- The 3-day free trial starts on first launch
- After subscription, ambient temple sound and unlimited throws unlock
- To test account deletion: Settings → Data → Delete All Data →
  Confirm (this is required by Apple Guideline 5.1.1)
```

---

## 3. External Services, Tools, and Platforms

```
External services used:

CORE:
- Apple In-App Purchase (IAP) — subscription billing only
- Apple StoreKit 2 — for IAP receipt validation

STATIC ASSET HOSTING (no user data sent):
- GitHub Pages — static privacy policy hosting
  (https://jiapeiji.github.io/ask_mazu/privacy.html)

FLUTTER PACKAGES (all local, no network):
- audioplayers 5.2.1 — local audio playback (block land sound, ding)
- video_player 2.9.1 — local video playback (throw animation)
- lunar 1.7.7 — local lunar calendar calculation
- shared_preferences 2.2.2 — local settings storage
- hive 2.2.3 — local NoSQL storage (user profile, throw records)
- in_app_purchase 3.1.11 — Apple IAP wrapper

NO third-party SDKs for:
- Analytics (no Firebase / Google Analytics / Mixpanel)
- Advertising (no ad networks)
- Push notifications (no FCM / APNs)
- Social login (no Google / Apple / Facebook login)
- Cloud sync (no server-side data storage)
- AI services (no LLM / ML APIs)

App is fully offline-functional after initial IAP verification.
The only network activity is:
1. IAP purchase verification with Apple servers (on subscription)
2. GitHub Pages privacy policy load (one-time, when user opens
   Settings → Privacy Policy)
```

---

## 4. Regional Differences

```
App functions consistently across all regions. The only variation is
UI text language (Simplified Chinese, Traditional Chinese, English),
which follows the user's system language setting (user can also
manually switch in Settings → Language).

No geo-restriction. No content blocking. No regional feature
differences. The same fortune stick library and divination logic
is available to all users globally.
```

---

## 5. Highly Regulated Industry / Third-Party Material

```
CULTURAL / RELIGIOUS CONTENT:
This is a folk culture recreation app, not a religious counseling
service. All fortune stick content is from public-domain classical
Chinese literature (including 《观音签》 and 《妈祖灵签》 classical
texts, which pre-date modern copyright). No professional religious
counseling is provided. The app does not collect donations or
religious contributions.

NO THIRD-PARTY PROTECTED MATERIAL is used:
- All 60 fortune stick texts are original adaptations of
  public-domain Chinese classical poetry
- All illustrations, audio, and video assets are original works
  created specifically for this app
- The Mazu cultural reference is in the public domain
  (Mazu's historical period: 960-987 AD)

NO REGULATORY REQUIREMENTS apply:
- No medical / health claims
- No financial / investment advice
- No educational content requiring accreditation
- No gambling or lottery mechanics (IAP subscription unlocks
  unlimited throws but does not constitute gambling)
```

---

## 6. Account Deletion (Apple Guideline 5.1.1)

```
This app supports account deletion as required by Guideline 5.1.1.

Path: Settings → Data → Delete All Data → Confirm

What is deleted:
- User profile (name, city, createdAt)
- All throw history (60 days of records, unlimited for subscribers)
- All settings (language, theme, sound, vibration preferences)
- Subscription state (in-app purchase records on user's device
  are NOT deleted, but local cache is cleared)

After deletion, the app returns to its initial state and the user
must re-enter their name and city (onboarding flow).

The deletion is permanent and cannot be undone. A confirmation
dialog with clear warning text is shown before deletion.
```

---

## 录屏要求(作为 Attachment 上传,不放 Notes)

上传位置:**App Review Information → Attachment** (拖拽 .mov 文件)

录屏内容(3-5 分钟):
1. 启动 App(展示主屏)
2. 输入名字 + 城市,完成报家门
3. 主屏显示 6 个问题类别
4. 选择一个类别,点击"投掷杯筊"
5. 完整观看投掷视频动画 + 落地
6. 展示结果页(签文 + 解曰 + 现代解读)
7. 返回首页,切换语言(中文 → 英文)
8. 进入设置,展示各项功能
9. **关键**:进入设置 → 数据 → 删除全部数据 → 确认
10. 跳回 onboarding(显示数据已清除)

录屏设备要求:**真机** + **iOS 最新版**(模拟器录屏 Apple 不接受)
