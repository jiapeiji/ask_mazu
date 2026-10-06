// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '问妈祖';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '保存';

  @override
  String get commonClose => '关闭';

  @override
  String get commonConfirm => '确定';

  @override
  String get homeDiscipleSuffix => '弟子';

  @override
  String get homeCityPrefix => '现居 ';

  @override
  String get homeAskTitle => '今日欲问何事？';

  @override
  String get homeCatDaily => '今日运势';

  @override
  String get homeCatCareer => '事业';

  @override
  String get homeCatLove => '感情';

  @override
  String get homeCatFamily => '家庭';

  @override
  String get homeCatHealth => '健康';

  @override
  String get homeCatWealth => '财运';

  @override
  String get homeCatCustom => '自定义';

  @override
  String get homeThrowBtn => '投 掷 杯 筊';

  @override
  String get homeCustomPlaceholder => '想问点什么？';

  @override
  String get homeCustomTitle => '自定义问题';

  @override
  String get homeCustomHint => '请输入您想问的事~';

  @override
  String get paywallTitle => '解锁妈祖全部指引';

  @override
  String get paywallSubtitle => '感谢与妈祖同行';

  @override
  String get paywallFeatureUnlimited => '每日无限次投掷';

  @override
  String get paywallFeatureAllSigns => '完整 60 支签文';

  @override
  String get paywallFeatureAmbient => '庙宇环境音 · 沉浸仪式感';

  @override
  String get paywallPriceCardTitle => '月度订阅';

  @override
  String get paywallPriceCardPrice => '\$0.99 / 月';

  @override
  String get paywallPriceCardNote => '自动续期 · 可随时在 iOS 设置中取消';

  @override
  String get paywallSubscribeBtn => '立即订阅';

  @override
  String get paywallRestoreBtn => '恢复购买';

  @override
  String get paywallSubscribeSuccess => '订阅成功！感谢支持 🙏';

  @override
  String get paywallRestoreSuccess => '已恢复购买';

  @override
  String get paywallRestoreEmpty => '未找到可恢复的购买';

  @override
  String get paywallTermsPrefix => '继续即代表同意';

  @override
  String get paywallTermsLink => '用户协议';

  @override
  String get paywallPrivacyLink => '隐私政策';

  @override
  String get paywallPriceLoading => '加载中…';

  @override
  String get paywallPriceError => '暂不可用';

  @override
  String get paywallPendingHint => '等待系统确认…';

  @override
  String get paywallCanceledHint => '已取消';

  @override
  String get paywallErrorProduct => '无法获取产品信息，请稍后重试';

  @override
  String paywallErrorPurchase(String message) {
    return '订阅失败：$message';
  }

  @override
  String paywallErrorRestore(String message) {
    return '恢复失败：$message';
  }

  @override
  String paywallErrorGeneric(String message) {
    return '操作失败：$message';
  }

  @override
  String get paywallRetry => '重试';

  @override
  String get onbMazu => '妈祖';

  @override
  String get onbTagline => '海外华人之日常仪式';

  @override
  String get onbNameLabel => '弟子如何称呼？';

  @override
  String get onbNameHint => '请输入您的名字';

  @override
  String get onbNameErrorEmpty => '请输入名字';

  @override
  String get onbNameErrorShort => '名字至少 2 个字';

  @override
  String get onbCityLabel => '现居何处？';

  @override
  String get onbCityHint => '请输入城市';

  @override
  String get onbCityErrorEmpty => '请输入城市';

  @override
  String get onbCityErrorShort => '城市至少 2 个字';

  @override
  String get onbSubmit => '入 殿 问 事';

  @override
  String get onbFootnote => '名字与城市仅用于结果中称呼，可在设置中修改';

  @override
  String get settingsTitle => '设 置';

  @override
  String get settingsSectionProfile => '报 家 门';

  @override
  String get settingsSectionLanguage => '语 言';

  @override
  String get settingsSectionSound => '声 音';

  @override
  String get settingsSectionView => '查 看';

  @override
  String get settingsSectionAbout => '关 于';

  @override
  String get settingsSectionDebug => '调 试';

  @override
  String get settingsProfileUnset => '未设置';

  @override
  String get settingsEditProfileTitle => '修改报家门';

  @override
  String get settingsEditProfileName => '名字';

  @override
  String get settingsEditProfileCity => '城市';

  @override
  String get settingsLanguageZhCn => '简体中文';

  @override
  String get settingsLanguageZhTw => '繁體中文';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageChanged => '语言已切换';

  @override
  String get settingsSoundBlockTitle => '木块落地音';

  @override
  String get settingsSoundBlockDesc => '投掷时木块落地的回响';

  @override
  String get settingsSoundAmbientTitle => '庙宇环境音';

  @override
  String get settingsSoundAmbientActive => '在结果页循环播放';

  @override
  String get settingsSoundAmbientLocked => '订阅后可用';

  @override
  String get settingsSoundHapticTitle => '震动反馈';

  @override
  String get settingsSoundHapticDesc => '投掷完成时轻微震动';

  @override
  String get settingsViewHistory => '问事记录';

  @override
  String get settingsAboutMazu => '关于妈祖';

  @override
  String get settingsPrivacy => '隐私政策';

  @override
  String get settingsTerms => '用户协议';

  @override
  String get settingsAboutApp => '关于此 App';

  @override
  String get settingsSectionData => '数据';

  @override
  String get settingsDeleteAllData => '删除全部数据';

  @override
  String get settingsDeleteConfirmTitle => '删除全部数据？';

  @override
  String get settingsDeleteConfirmBody =>
      '此操作不可撤销。您的名字、城市、问事记录和设置都会被清除，App 会回到初始状态。';

  @override
  String get settingsDeleteDone => '数据已清除';

  @override
  String get commonDelete => '删除';

  @override
  String get historyTitle => '问 事 记 录';

  @override
  String get historyEmpty => '暂无问事记录';

  @override
  String historyLoadError(String error) {
    return '加载失败: $error';
  }

  @override
  String get historyResultSaint => '圣杯';

  @override
  String get historyResultLaugh => '笑杯';

  @override
  String get historyResultYin => '阴杯';

  @override
  String get historyNoSign => '未得签文';

  @override
  String historyAsk(String question) {
    return '问：$question';
  }

  @override
  String historySignTitle(String level, String id, String title) {
    return '$level签 · 第 $id 签「$title」';
  }

  @override
  String get signsTitle => '签 文 库';

  @override
  String signsLoadError(String error) {
    return '加载失败: $error';
  }

  @override
  String signsDetailTitle(String id) {
    return '第 $id 签';
  }

  @override
  String get signsDetailInterpretation => '解 曰';

  @override
  String get signsDetailAllusion => '典 故';

  @override
  String get signsDetailModern => '现代解读';

  @override
  String get throwHint => '叩 · 叩';

  @override
  String saintTemplate1(String name, String signTitle) {
    return '$name 弟子，妈祖允你所问，此签为【$signTitle】。';
  }

  @override
  String saintTemplate2(String name) {
    return '$name 居士，慈航显应，所示如签。';
  }

  @override
  String saintTemplate3(String name, String signTitle) {
    return '$name 弟子，妈祖慈怀允示。签曰【$signTitle】，望善体天心。';
  }

  @override
  String saintTemplate4(String name) {
    return '$name 居士，慈帆已张，顺风可期。签中所示，请细参详。';
  }

  @override
  String saintTemplate5(String name, String signTitle) {
    return '$name 居士，慈母允儿所请。签曰【$signTitle】，愿你此去顺遂。';
  }

  @override
  String saintTemplate6(String name) {
    return '$name 弟子，圣杯一掷已明。签中所示，顺势而进可也。';
  }

  @override
  String saintTemplate7(String name, String signTitle) {
    return '$name 弟子，慈帆高挂，顺风正起。签曰【$signTitle】，当进则进。';
  }

  @override
  String saintTemplate8(String name) {
    return '$name 弟子，妈祖含笑点头，所示如签。心定则事成。';
  }

  @override
  String laughTemplate1(String name) {
    return '$name 弟子，问事心要诚，妈祖未允。请闭目静思片刻再请示。';
  }

  @override
  String laughTemplate2(String name) {
    return '$name 弟子，妈祖含笑不语。此问尚有未明之处，请细思后重新请示。';
  }

  @override
  String laughTemplate3(String name) {
    return '$name 弟子，妈祖含笑。此问或太急、或太泛，请缓一缓再问。';
  }

  @override
  String laughTemplate4(String name) {
    return '$name 居士，香火未透，妈祖示以笑杯。静心三息，再来。';
  }

  @override
  String laughTemplate5(String name) {
    return '$name 弟子，问事如磨刀，太急则钝。妈祖笑你急了些，请从容再来。';
  }

  @override
  String laughTemplate6(String name) {
    return '$name 弟子，妈祖摇头笑曰：此问时机未到。请择日再请示。';
  }

  @override
  String laughTemplate7(String name) {
    return '$name 弟子，妈祖笑而不答，必有缘由。静心自省，答案或在心中。';
  }

  @override
  String laughTemplate8(String name) {
    return '$name 居士，妈祖笑杯示以未允。心未定时，再请示亦难应。';
  }

  @override
  String yinTemplate1(String name) {
    return '$name 弟子，妈祖示意此事不宜，宜缓行。';
  }

  @override
  String yinTemplate2(String name) {
    return '$name 弟子，此事有违天时。妈祖示意退一步，海阔天空。';
  }

  @override
  String yinTemplate3(String name) {
    return '$name 居士，心急则不达。妈祖示意缓行，待时来运转。';
  }

  @override
  String yinTemplate4(String name) {
    return '$name 居士，妈祖明示此事不妥。强为之，必有后患。';
  }

  @override
  String yinTemplate5(String name) {
    return '$name 弟子，妈祖不允，必有深意。切莫逆天行事，宜守不宜攻。';
  }

  @override
  String yinTemplate6(String name) {
    return '$name 弟子，妈祖垂怜，示以阴杯，是为你好。暂避锋芒，谋定后动。';
  }

  @override
  String yinTemplate7(String name) {
    return '$name 居士，妈祖摇头示警。眼前路不通，请耐心等候天时。';
  }

  @override
  String yinTemplate8(String name) {
    return '$name 弟子，阴杯示凶，非绝路。妈祖点你：转个弯，路在前方。';
  }

  @override
  String get resultSaint => '圣杯';

  @override
  String get resultLaugh => '笑杯';

  @override
  String get resultYin => '阴杯';

  @override
  String get resultShareBtn => '分享';

  @override
  String get resultRetrySaint => '再问一次';

  @override
  String get resultRetryLaugh => '重新组织问题';

  @override
  String get resultRetryYin => '改日再问';

  @override
  String get shareTitle => '分享妈祖所示';

  @override
  String get shareWechat => '微信';

  @override
  String get shareMoments => '朋友圈';

  @override
  String get shareCopy => '复制';

  @override
  String get shareSave => '存图';

  @override
  String get shareCopied => '文案已复制到剪贴板';

  @override
  String get shareSavedToAlbum => '已保存到相册\"AskMazu\"文件夹';

  @override
  String get shareImageGenFail => '生成图片失败，请重试';

  @override
  String shareOpFail(String error) {
    return '操作失败: $error';
  }

  @override
  String get shareAlbumPermFail => '没有相册权限，请到设置中开启';

  @override
  String get shareSubject => '妈祖所示';

  @override
  String get shareSignPrefix => '🙏 妈祖所示 · ';

  @override
  String get shareFooter => '—— 来自「问妈祖 Ask Mazu」';

  @override
  String get shareMomentsHint => '（请在分享面板选\"朋友圈\"）';

  @override
  String get aboutMazuTitle => '关于妈祖';

  @override
  String get privacyTitle => '隐私政策';

  @override
  String get tosTitle => '用户协议';

  @override
  String get aboutAppVersion => '版本';

  @override
  String get aboutAppBuildTime => '构建时间';

  @override
  String get aboutAppPlatform => '平台';

  @override
  String get aboutAppFooter => '用 ❤️ 与 🙏 制作';

  @override
  String get aboutCopy => '复制全文';

  @override
  String get aboutCopied => '已复制全文';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '問媽祖';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '儲存';

  @override
  String get commonClose => '關閉';

  @override
  String get commonConfirm => '確定';

  @override
  String get homeDiscipleSuffix => '弟子';

  @override
  String get homeCityPrefix => '現居 ';

  @override
  String get homeAskTitle => '今日欲問何事？';

  @override
  String get homeCatDaily => '今日運勢';

  @override
  String get homeCatCareer => '事業';

  @override
  String get homeCatLove => '感情';

  @override
  String get homeCatFamily => '家庭';

  @override
  String get homeCatHealth => '健康';

  @override
  String get homeCatWealth => '財運';

  @override
  String get homeCatCustom => '自訂';

  @override
  String get homeThrowBtn => '投 擲 杯 筊';

  @override
  String get homeCustomPlaceholder => '想問點什麼？';

  @override
  String get homeCustomTitle => '自訂問題';

  @override
  String get homeCustomHint => '請輸入您想問的事~';

  @override
  String get paywallTitle => '解鎖媽祖全部指引';

  @override
  String get paywallSubtitle => '感謝與媽祖同行';

  @override
  String get paywallFeatureUnlimited => '每日無限次投擲';

  @override
  String get paywallFeatureAllSigns => '完整 60 支籤文';

  @override
  String get paywallFeatureAmbient => '廟宇環境音 · 沉浸儀式感';

  @override
  String get paywallPriceCardTitle => '月度訂閱';

  @override
  String get paywallPriceCardPrice => '\$0.99 / 月';

  @override
  String get paywallPriceCardNote => '自動續訂 · 可隨時在 iOS 設定中取消';

  @override
  String get paywallSubscribeBtn => '立即訂閱';

  @override
  String get paywallRestoreBtn => '恢復購買';

  @override
  String get paywallSubscribeSuccess => '訂閱成功！感謝支持 🙏';

  @override
  String get paywallRestoreSuccess => '已恢復購買';

  @override
  String get paywallRestoreEmpty => '未找到可恢復的購買';

  @override
  String get paywallTermsPrefix => '繼續即代表同意';

  @override
  String get paywallTermsLink => '使用者協議';

  @override
  String get paywallPrivacyLink => '隱私政策';

  @override
  String get paywallPriceLoading => '載入中…';

  @override
  String get paywallPriceError => '暫時無法使用';

  @override
  String get paywallPendingHint => '等待系統確認…';

  @override
  String get paywallCanceledHint => '已取消';

  @override
  String get paywallErrorProduct => '無法取得產品資訊，請稍後重試';

  @override
  String paywallErrorPurchase(String message) {
    return '訂閱失敗：$message';
  }

  @override
  String paywallErrorRestore(String message) {
    return '恢復失敗：$message';
  }

  @override
  String paywallErrorGeneric(String message) {
    return '操作失敗：$message';
  }

  @override
  String get paywallRetry => '重試';

  @override
  String get onbMazu => '媽祖';

  @override
  String get onbTagline => '海外華人之日常儀式';

  @override
  String get onbNameLabel => '弟子如何稱呼？';

  @override
  String get onbNameHint => '請輸入您的名字';

  @override
  String get onbNameErrorEmpty => '請輸入名字';

  @override
  String get onbNameErrorShort => '名字至少 2 個字';

  @override
  String get onbCityLabel => '現居何處？';

  @override
  String get onbCityHint => '請輸入城市';

  @override
  String get onbCityErrorEmpty => '請輸入城市';

  @override
  String get onbCityErrorShort => '城市至少 2 個字';

  @override
  String get onbSubmit => '入 殿 問 事';

  @override
  String get onbFootnote => '名字與城市僅用於結果中稱呼，可在設定中修改';

  @override
  String get settingsTitle => '設 定';

  @override
  String get settingsSectionProfile => '報 個 名';

  @override
  String get settingsSectionLanguage => '語 言';

  @override
  String get settingsSectionSound => '聲 音';

  @override
  String get settingsSectionView => '查 看';

  @override
  String get settingsSectionAbout => '關 於';

  @override
  String get settingsSectionDebug => '調 試';

  @override
  String get settingsProfileUnset => '未設定';

  @override
  String get settingsEditProfileTitle => '修改報個名';

  @override
  String get settingsEditProfileName => '名字';

  @override
  String get settingsEditProfileCity => '城市';

  @override
  String get settingsLanguageZhCn => '简体中文';

  @override
  String get settingsLanguageZhTw => '繁體中文';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageChanged => '語言已切換';

  @override
  String get settingsSoundBlockTitle => '木塊落地音';

  @override
  String get settingsSoundBlockDesc => '投擲時木塊落地的迴響';

  @override
  String get settingsSoundAmbientTitle => '廟宇環境音';

  @override
  String get settingsSoundAmbientActive => '在結果頁循環播放';

  @override
  String get settingsSoundAmbientLocked => '訂閱後可用';

  @override
  String get settingsSoundHapticTitle => '震動回饋';

  @override
  String get settingsSoundHapticDesc => '投擲完成時輕微震動';

  @override
  String get settingsViewHistory => '問事記錄';

  @override
  String get settingsAboutMazu => '關於媽祖';

  @override
  String get settingsPrivacy => '隱私政策';

  @override
  String get settingsTerms => '使用者協議';

  @override
  String get settingsAboutApp => '關於此 App';

  @override
  String get settingsSectionData => '資料';

  @override
  String get settingsDeleteAllData => '刪除全部資料';

  @override
  String get settingsDeleteConfirmTitle => '刪除全部資料？';

  @override
  String get settingsDeleteConfirmBody =>
      '此操作無法撤銷。您的名字、城市、問事記錄和設定都會被清除，App 會回到初始狀態。';

  @override
  String get settingsDeleteDone => '資料已清除';

  @override
  String get commonDelete => '刪除';

  @override
  String get historyTitle => '問 事 記 錄';

  @override
  String get historyEmpty => '暫無問事記錄';

  @override
  String historyLoadError(String error) {
    return '載入失敗: $error';
  }

  @override
  String get historyResultSaint => '聖杯';

  @override
  String get historyResultLaugh => '笑杯';

  @override
  String get historyResultYin => '陰杯';

  @override
  String get historyNoSign => '未得籤文';

  @override
  String historyAsk(String question) {
    return '問：$question';
  }

  @override
  String historySignTitle(String level, String id, String title) {
    return '$level籤 · 第 $id 籤「$title」';
  }

  @override
  String get signsTitle => '籤 文 庫';

  @override
  String signsLoadError(String error) {
    return '載入失敗: $error';
  }

  @override
  String signsDetailTitle(String id) {
    return '第 $id 籤';
  }

  @override
  String get signsDetailInterpretation => '解 曰';

  @override
  String get signsDetailAllusion => '典 故';

  @override
  String get signsDetailModern => '現代解讀';

  @override
  String get throwHint => '叩 · 叩';

  @override
  String saintTemplate1(String name, String signTitle) {
    return '$name 弟子，媽祖允你所問，此籤為【$signTitle】。';
  }

  @override
  String saintTemplate2(String name) {
    return '$name 居士，慈航顯應，所示如籤。';
  }

  @override
  String saintTemplate3(String name, String signTitle) {
    return '$name 弟子，媽祖慈懷允示。籤曰【$signTitle】，望善體天心。';
  }

  @override
  String saintTemplate4(String name) {
    return '$name 居士，慈帆已張，順風可期。籤中所示，請細參詳。';
  }

  @override
  String saintTemplate5(String name, String signTitle) {
    return '$name 居士，慈母允兒所請。籤曰【$signTitle】，願你此去順遂。';
  }

  @override
  String saintTemplate6(String name) {
    return '$name 弟子，聖杯一擲已明。籤中所示，順勢而進可也。';
  }

  @override
  String saintTemplate7(String name, String signTitle) {
    return '$name 弟子，慈帆高掛，順風正起。籤曰【$signTitle】，當進則進。';
  }

  @override
  String saintTemplate8(String name) {
    return '$name 弟子，媽祖含笑點頭，所示如籤。心定則事成。';
  }

  @override
  String laughTemplate1(String name) {
    return '$name 弟子，問事心要誠，媽祖未允。請閉目靜思片刻再請示。';
  }

  @override
  String laughTemplate2(String name) {
    return '$name 弟子，媽祖含笑不語。此問尚有未明之處，請細思後重新請示。';
  }

  @override
  String laughTemplate3(String name) {
    return '$name 弟子，媽祖含笑。此問或太急、或太泛，請緩一緩再問。';
  }

  @override
  String laughTemplate4(String name) {
    return '$name 居士，香火未透，媽祖示以笑杯。靜心三息，再來。';
  }

  @override
  String laughTemplate5(String name) {
    return '$name 弟子，問事如磨刀，太急則鈍。媽祖笑你急了些，請從容再來。';
  }

  @override
  String laughTemplate6(String name) {
    return '$name 弟子，媽祖搖頭笑曰：此問時機未到。請擇日再請示。';
  }

  @override
  String laughTemplate7(String name) {
    return '$name 弟子，媽祖笑而不答，必有緣由。靜心自省，答案或在心中。';
  }

  @override
  String laughTemplate8(String name) {
    return '$name 居士，媽祖笑杯示以未允。心未定時，再請示亦難應。';
  }

  @override
  String yinTemplate1(String name) {
    return '$name 弟子，媽祖示意此事不宜，宜緩行。';
  }

  @override
  String yinTemplate2(String name) {
    return '$name 弟子，此事有違天時。媽祖示意退一步，海闊天空。';
  }

  @override
  String yinTemplate3(String name) {
    return '$name 居士，心急則不達。媽祖示意緩行，待時來運轉。';
  }

  @override
  String yinTemplate4(String name) {
    return '$name 居士，媽祖明示此事不妥。強行為之，必有後患。';
  }

  @override
  String yinTemplate5(String name) {
    return '$name 弟子，媽祖不允，必有深意。切莫逆天行事，宜守不宜攻。';
  }

  @override
  String yinTemplate6(String name) {
    return '$name 弟子，媽祖垂憐，示以陰杯，是為你好。暫避鋒芒，謀定後動。';
  }

  @override
  String yinTemplate7(String name) {
    return '$name 居士，媽祖搖頭示警。眼前路不通，請耐心等候天時。';
  }

  @override
  String yinTemplate8(String name) {
    return '$name 弟子，陰杯示凶，非絕路。媽祖點你：轉個彎，路在前方。';
  }

  @override
  String get resultSaint => '聖杯';

  @override
  String get resultLaugh => '笑杯';

  @override
  String get resultYin => '陰杯';

  @override
  String get resultShareBtn => '分享';

  @override
  String get resultRetrySaint => '再問一次';

  @override
  String get resultRetryLaugh => '重新組織問題';

  @override
  String get resultRetryYin => '改日再問';

  @override
  String get shareTitle => '分享媽祖所示';

  @override
  String get shareWechat => '微信';

  @override
  String get shareMoments => '朋友圈';

  @override
  String get shareCopy => '複製';

  @override
  String get shareSave => '存圖';

  @override
  String get shareCopied => '文案已複製到剪貼簿';

  @override
  String get shareSavedToAlbum => '已儲存到相簿\"AskMazu\"資料夾';

  @override
  String get shareImageGenFail => '產生圖片失敗，請重試';

  @override
  String shareOpFail(String error) {
    return '操作失敗: $error';
  }

  @override
  String get shareAlbumPermFail => '沒有相簿權限，請到設定中開啟';

  @override
  String get shareSubject => '媽祖所示';

  @override
  String get shareSignPrefix => '🙏 媽祖所示 · ';

  @override
  String get shareFooter => '—— 來自「問媽祖 Ask Mazu」';

  @override
  String get shareMomentsHint => '（請在分享面板選「朋友圈」）';

  @override
  String get aboutMazuTitle => '關於媽祖';

  @override
  String get privacyTitle => '隱私政策';

  @override
  String get tosTitle => '使用者協議';

  @override
  String get aboutAppVersion => '版本';

  @override
  String get aboutAppBuildTime => '建置時間';

  @override
  String get aboutAppPlatform => '平台';

  @override
  String get aboutAppFooter => '用 ❤️ 與 🙏 製作';

  @override
  String get aboutCopy => '複製全文';

  @override
  String get aboutCopied => '已複製全文';
}
