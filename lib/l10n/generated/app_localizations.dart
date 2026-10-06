import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'问妈祖'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get commonConfirm;

  /// No description provided for @homeDiscipleSuffix.
  ///
  /// In zh, this message translates to:
  /// **'弟子'**
  String get homeDiscipleSuffix;

  /// No description provided for @homeCityPrefix.
  ///
  /// In zh, this message translates to:
  /// **'现居 '**
  String get homeCityPrefix;

  /// No description provided for @homeAskTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日欲问何事？'**
  String get homeAskTitle;

  /// No description provided for @homeCatDaily.
  ///
  /// In zh, this message translates to:
  /// **'今日运势'**
  String get homeCatDaily;

  /// No description provided for @homeCatCareer.
  ///
  /// In zh, this message translates to:
  /// **'事业'**
  String get homeCatCareer;

  /// No description provided for @homeCatLove.
  ///
  /// In zh, this message translates to:
  /// **'感情'**
  String get homeCatLove;

  /// No description provided for @homeCatFamily.
  ///
  /// In zh, this message translates to:
  /// **'家庭'**
  String get homeCatFamily;

  /// No description provided for @homeCatHealth.
  ///
  /// In zh, this message translates to:
  /// **'健康'**
  String get homeCatHealth;

  /// No description provided for @homeCatWealth.
  ///
  /// In zh, this message translates to:
  /// **'财运'**
  String get homeCatWealth;

  /// No description provided for @homeCatCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get homeCatCustom;

  /// No description provided for @homeThrowBtn.
  ///
  /// In zh, this message translates to:
  /// **'投 掷 杯 筊'**
  String get homeThrowBtn;

  /// No description provided for @homeCustomPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'想问点什么？'**
  String get homeCustomPlaceholder;

  /// No description provided for @homeCustomTitle.
  ///
  /// In zh, this message translates to:
  /// **'自定义问题'**
  String get homeCustomTitle;

  /// No description provided for @homeCustomHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入您想问的事~'**
  String get homeCustomHint;

  /// No description provided for @paywallTitle.
  ///
  /// In zh, this message translates to:
  /// **'解锁妈祖全部指引'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'感谢与妈祖同行'**
  String get paywallSubtitle;

  /// No description provided for @paywallFeatureUnlimited.
  ///
  /// In zh, this message translates to:
  /// **'每日无限次投掷'**
  String get paywallFeatureUnlimited;

  /// No description provided for @paywallFeatureAllSigns.
  ///
  /// In zh, this message translates to:
  /// **'完整 60 支签文'**
  String get paywallFeatureAllSigns;

  /// No description provided for @paywallFeatureAmbient.
  ///
  /// In zh, this message translates to:
  /// **'庙宇环境音 · 沉浸仪式感'**
  String get paywallFeatureAmbient;

  /// No description provided for @paywallPriceCardTitle.
  ///
  /// In zh, this message translates to:
  /// **'月度订阅'**
  String get paywallPriceCardTitle;

  /// No description provided for @paywallPriceCardPrice.
  ///
  /// In zh, this message translates to:
  /// **'\$0.99 / 月'**
  String get paywallPriceCardPrice;

  /// No description provided for @paywallPriceCardNote.
  ///
  /// In zh, this message translates to:
  /// **'自动续期 · 可随时在 iOS 设置中取消'**
  String get paywallPriceCardNote;

  /// No description provided for @paywallSubscribeBtn.
  ///
  /// In zh, this message translates to:
  /// **'立即订阅'**
  String get paywallSubscribeBtn;

  /// No description provided for @paywallRestoreBtn.
  ///
  /// In zh, this message translates to:
  /// **'恢复购买'**
  String get paywallRestoreBtn;

  /// No description provided for @paywallSubscribeSuccess.
  ///
  /// In zh, this message translates to:
  /// **'订阅成功！感谢支持 🙏'**
  String get paywallSubscribeSuccess;

  /// No description provided for @paywallRestoreSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已恢复购买'**
  String get paywallRestoreSuccess;

  /// No description provided for @paywallRestoreEmpty.
  ///
  /// In zh, this message translates to:
  /// **'未找到可恢复的购买'**
  String get paywallRestoreEmpty;

  /// No description provided for @paywallTermsPrefix.
  ///
  /// In zh, this message translates to:
  /// **'继续即代表同意'**
  String get paywallTermsPrefix;

  /// No description provided for @paywallTermsLink.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get paywallTermsLink;

  /// No description provided for @paywallPrivacyLink.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get paywallPrivacyLink;

  /// No description provided for @paywallPriceLoading.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get paywallPriceLoading;

  /// No description provided for @paywallPriceError.
  ///
  /// In zh, this message translates to:
  /// **'暂不可用'**
  String get paywallPriceError;

  /// No description provided for @paywallPendingHint.
  ///
  /// In zh, this message translates to:
  /// **'等待系统确认…'**
  String get paywallPendingHint;

  /// No description provided for @paywallCanceledHint.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get paywallCanceledHint;

  /// No description provided for @paywallErrorProduct.
  ///
  /// In zh, this message translates to:
  /// **'无法获取产品信息，请稍后重试'**
  String get paywallErrorProduct;

  /// No description provided for @paywallErrorPurchase.
  ///
  /// In zh, this message translates to:
  /// **'订阅失败：{message}'**
  String paywallErrorPurchase(String message);

  /// No description provided for @paywallErrorRestore.
  ///
  /// In zh, this message translates to:
  /// **'恢复失败：{message}'**
  String paywallErrorRestore(String message);

  /// No description provided for @paywallErrorGeneric.
  ///
  /// In zh, this message translates to:
  /// **'操作失败：{message}'**
  String paywallErrorGeneric(String message);

  /// No description provided for @paywallRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get paywallRetry;

  /// No description provided for @onbMazu.
  ///
  /// In zh, this message translates to:
  /// **'妈祖'**
  String get onbMazu;

  /// No description provided for @onbTagline.
  ///
  /// In zh, this message translates to:
  /// **'海外华人之日常仪式'**
  String get onbTagline;

  /// No description provided for @onbNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'弟子如何称呼？'**
  String get onbNameLabel;

  /// No description provided for @onbNameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入您的名字'**
  String get onbNameHint;

  /// No description provided for @onbNameErrorEmpty.
  ///
  /// In zh, this message translates to:
  /// **'请输入名字'**
  String get onbNameErrorEmpty;

  /// No description provided for @onbNameErrorShort.
  ///
  /// In zh, this message translates to:
  /// **'名字至少 2 个字'**
  String get onbNameErrorShort;

  /// No description provided for @onbCityLabel.
  ///
  /// In zh, this message translates to:
  /// **'现居何处？'**
  String get onbCityLabel;

  /// No description provided for @onbCityHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入城市'**
  String get onbCityHint;

  /// No description provided for @onbCityErrorEmpty.
  ///
  /// In zh, this message translates to:
  /// **'请输入城市'**
  String get onbCityErrorEmpty;

  /// No description provided for @onbCityErrorShort.
  ///
  /// In zh, this message translates to:
  /// **'城市至少 2 个字'**
  String get onbCityErrorShort;

  /// No description provided for @onbSubmit.
  ///
  /// In zh, this message translates to:
  /// **'入 殿 问 事'**
  String get onbSubmit;

  /// No description provided for @onbFootnote.
  ///
  /// In zh, this message translates to:
  /// **'名字与城市仅用于结果中称呼，可在设置中修改'**
  String get onbFootnote;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设 置'**
  String get settingsTitle;

  /// No description provided for @settingsSectionProfile.
  ///
  /// In zh, this message translates to:
  /// **'报 家 门'**
  String get settingsSectionProfile;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语 言'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionSound.
  ///
  /// In zh, this message translates to:
  /// **'声 音'**
  String get settingsSectionSound;

  /// No description provided for @settingsSectionView.
  ///
  /// In zh, this message translates to:
  /// **'查 看'**
  String get settingsSectionView;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In zh, this message translates to:
  /// **'关 于'**
  String get settingsSectionAbout;

  /// No description provided for @settingsSectionDebug.
  ///
  /// In zh, this message translates to:
  /// **'调 试'**
  String get settingsSectionDebug;

  /// No description provided for @settingsProfileUnset.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get settingsProfileUnset;

  /// No description provided for @settingsEditProfileTitle.
  ///
  /// In zh, this message translates to:
  /// **'修改报家门'**
  String get settingsEditProfileTitle;

  /// No description provided for @settingsEditProfileName.
  ///
  /// In zh, this message translates to:
  /// **'名字'**
  String get settingsEditProfileName;

  /// No description provided for @settingsEditProfileCity.
  ///
  /// In zh, this message translates to:
  /// **'城市'**
  String get settingsEditProfileCity;

  /// No description provided for @settingsLanguageZhCn.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get settingsLanguageZhCn;

  /// No description provided for @settingsLanguageZhTw.
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get settingsLanguageZhTw;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageChanged.
  ///
  /// In zh, this message translates to:
  /// **'语言已切换'**
  String get settingsLanguageChanged;

  /// No description provided for @settingsSoundBlockTitle.
  ///
  /// In zh, this message translates to:
  /// **'木块落地音'**
  String get settingsSoundBlockTitle;

  /// No description provided for @settingsSoundBlockDesc.
  ///
  /// In zh, this message translates to:
  /// **'投掷时木块落地的回响'**
  String get settingsSoundBlockDesc;

  /// No description provided for @settingsSoundAmbientTitle.
  ///
  /// In zh, this message translates to:
  /// **'庙宇环境音'**
  String get settingsSoundAmbientTitle;

  /// No description provided for @settingsSoundAmbientActive.
  ///
  /// In zh, this message translates to:
  /// **'在结果页循环播放'**
  String get settingsSoundAmbientActive;

  /// No description provided for @settingsSoundAmbientLocked.
  ///
  /// In zh, this message translates to:
  /// **'订阅后可用'**
  String get settingsSoundAmbientLocked;

  /// No description provided for @settingsSoundHapticTitle.
  ///
  /// In zh, this message translates to:
  /// **'震动反馈'**
  String get settingsSoundHapticTitle;

  /// No description provided for @settingsSoundHapticDesc.
  ///
  /// In zh, this message translates to:
  /// **'投掷完成时轻微震动'**
  String get settingsSoundHapticDesc;

  /// No description provided for @settingsViewHistory.
  ///
  /// In zh, this message translates to:
  /// **'问事记录'**
  String get settingsViewHistory;

  /// No description provided for @settingsAboutMazu.
  ///
  /// In zh, this message translates to:
  /// **'关于妈祖'**
  String get settingsAboutMazu;

  /// No description provided for @settingsPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get settingsTerms;

  /// No description provided for @settingsAboutApp.
  ///
  /// In zh, this message translates to:
  /// **'关于此 App'**
  String get settingsAboutApp;

  /// No description provided for @settingsSectionData.
  ///
  /// In zh, this message translates to:
  /// **'数据'**
  String get settingsSectionData;

  /// No description provided for @settingsDeleteAllData.
  ///
  /// In zh, this message translates to:
  /// **'删除全部数据'**
  String get settingsDeleteAllData;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除全部数据？'**
  String get settingsDeleteConfirmTitle;

  /// No description provided for @settingsDeleteConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'此操作不可撤销。您的名字、城市、问事记录和设置都会被清除，App 会回到初始状态。'**
  String get settingsDeleteConfirmBody;

  /// No description provided for @settingsDeleteDone.
  ///
  /// In zh, this message translates to:
  /// **'数据已清除'**
  String get settingsDeleteDone;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @historyTitle.
  ///
  /// In zh, this message translates to:
  /// **'问 事 记 录'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无问事记录'**
  String get historyEmpty;

  /// No description provided for @historyLoadError.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String historyLoadError(String error);

  /// No description provided for @historyResultSaint.
  ///
  /// In zh, this message translates to:
  /// **'圣杯'**
  String get historyResultSaint;

  /// No description provided for @historyResultLaugh.
  ///
  /// In zh, this message translates to:
  /// **'笑杯'**
  String get historyResultLaugh;

  /// No description provided for @historyResultYin.
  ///
  /// In zh, this message translates to:
  /// **'阴杯'**
  String get historyResultYin;

  /// No description provided for @historyNoSign.
  ///
  /// In zh, this message translates to:
  /// **'未得签文'**
  String get historyNoSign;

  /// No description provided for @historyAsk.
  ///
  /// In zh, this message translates to:
  /// **'问：{question}'**
  String historyAsk(String question);

  /// No description provided for @historySignTitle.
  ///
  /// In zh, this message translates to:
  /// **'{level}签 · 第 {id} 签「{title}」'**
  String historySignTitle(String level, String id, String title);

  /// No description provided for @signsTitle.
  ///
  /// In zh, this message translates to:
  /// **'签 文 库'**
  String get signsTitle;

  /// No description provided for @signsLoadError.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String signsLoadError(String error);

  /// No description provided for @signsDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'第 {id} 签'**
  String signsDetailTitle(String id);

  /// No description provided for @signsDetailInterpretation.
  ///
  /// In zh, this message translates to:
  /// **'解 曰'**
  String get signsDetailInterpretation;

  /// No description provided for @signsDetailAllusion.
  ///
  /// In zh, this message translates to:
  /// **'典 故'**
  String get signsDetailAllusion;

  /// No description provided for @signsDetailModern.
  ///
  /// In zh, this message translates to:
  /// **'现代解读'**
  String get signsDetailModern;

  /// No description provided for @throwHint.
  ///
  /// In zh, this message translates to:
  /// **'叩 · 叩'**
  String get throwHint;

  /// No description provided for @saintTemplate1.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，妈祖允你所问，此签为【{signTitle}】。'**
  String saintTemplate1(String name, String signTitle);

  /// No description provided for @saintTemplate2.
  ///
  /// In zh, this message translates to:
  /// **'{name} 居士，慈航显应，所示如签。'**
  String saintTemplate2(String name);

  /// No description provided for @saintTemplate3.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，妈祖慈怀允示。签曰【{signTitle}】，望善体天心。'**
  String saintTemplate3(String name, String signTitle);

  /// No description provided for @saintTemplate4.
  ///
  /// In zh, this message translates to:
  /// **'{name} 居士，慈帆已张，顺风可期。签中所示，请细参详。'**
  String saintTemplate4(String name);

  /// No description provided for @saintTemplate5.
  ///
  /// In zh, this message translates to:
  /// **'{name} 居士，慈母允儿所请。签曰【{signTitle}】，愿你此去顺遂。'**
  String saintTemplate5(String name, String signTitle);

  /// No description provided for @saintTemplate6.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，圣杯一掷已明。签中所示，顺势而进可也。'**
  String saintTemplate6(String name);

  /// No description provided for @saintTemplate7.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，慈帆高挂，顺风正起。签曰【{signTitle}】，当进则进。'**
  String saintTemplate7(String name, String signTitle);

  /// No description provided for @saintTemplate8.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，妈祖含笑点头，所示如签。心定则事成。'**
  String saintTemplate8(String name);

  /// No description provided for @laughTemplate1.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，问事心要诚，妈祖未允。请闭目静思片刻再请示。'**
  String laughTemplate1(String name);

  /// No description provided for @laughTemplate2.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，妈祖含笑不语。此问尚有未明之处，请细思后重新请示。'**
  String laughTemplate2(String name);

  /// No description provided for @laughTemplate3.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，妈祖含笑。此问或太急、或太泛，请缓一缓再问。'**
  String laughTemplate3(String name);

  /// No description provided for @laughTemplate4.
  ///
  /// In zh, this message translates to:
  /// **'{name} 居士，香火未透，妈祖示以笑杯。静心三息，再来。'**
  String laughTemplate4(String name);

  /// No description provided for @laughTemplate5.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，问事如磨刀，太急则钝。妈祖笑你急了些，请从容再来。'**
  String laughTemplate5(String name);

  /// No description provided for @laughTemplate6.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，妈祖摇头笑曰：此问时机未到。请择日再请示。'**
  String laughTemplate6(String name);

  /// No description provided for @laughTemplate7.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，妈祖笑而不答，必有缘由。静心自省，答案或在心中。'**
  String laughTemplate7(String name);

  /// No description provided for @laughTemplate8.
  ///
  /// In zh, this message translates to:
  /// **'{name} 居士，妈祖笑杯示以未允。心未定时，再请示亦难应。'**
  String laughTemplate8(String name);

  /// No description provided for @yinTemplate1.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，妈祖示意此事不宜，宜缓行。'**
  String yinTemplate1(String name);

  /// No description provided for @yinTemplate2.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，此事有违天时。妈祖示意退一步，海阔天空。'**
  String yinTemplate2(String name);

  /// No description provided for @yinTemplate3.
  ///
  /// In zh, this message translates to:
  /// **'{name} 居士，心急则不达。妈祖示意缓行，待时来运转。'**
  String yinTemplate3(String name);

  /// No description provided for @yinTemplate4.
  ///
  /// In zh, this message translates to:
  /// **'{name} 居士，妈祖明示此事不妥。强为之，必有后患。'**
  String yinTemplate4(String name);

  /// No description provided for @yinTemplate5.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，妈祖不允，必有深意。切莫逆天行事，宜守不宜攻。'**
  String yinTemplate5(String name);

  /// No description provided for @yinTemplate6.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，妈祖垂怜，示以阴杯，是为你好。暂避锋芒，谋定后动。'**
  String yinTemplate6(String name);

  /// No description provided for @yinTemplate7.
  ///
  /// In zh, this message translates to:
  /// **'{name} 居士，妈祖摇头示警。眼前路不通，请耐心等候天时。'**
  String yinTemplate7(String name);

  /// No description provided for @yinTemplate8.
  ///
  /// In zh, this message translates to:
  /// **'{name} 弟子，阴杯示凶，非绝路。妈祖点你：转个弯，路在前方。'**
  String yinTemplate8(String name);

  /// No description provided for @resultSaint.
  ///
  /// In zh, this message translates to:
  /// **'圣杯'**
  String get resultSaint;

  /// No description provided for @resultLaugh.
  ///
  /// In zh, this message translates to:
  /// **'笑杯'**
  String get resultLaugh;

  /// No description provided for @resultYin.
  ///
  /// In zh, this message translates to:
  /// **'阴杯'**
  String get resultYin;

  /// No description provided for @resultShareBtn.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get resultShareBtn;

  /// No description provided for @resultRetrySaint.
  ///
  /// In zh, this message translates to:
  /// **'再问一次'**
  String get resultRetrySaint;

  /// No description provided for @resultRetryLaugh.
  ///
  /// In zh, this message translates to:
  /// **'重新组织问题'**
  String get resultRetryLaugh;

  /// No description provided for @resultRetryYin.
  ///
  /// In zh, this message translates to:
  /// **'改日再问'**
  String get resultRetryYin;

  /// No description provided for @shareTitle.
  ///
  /// In zh, this message translates to:
  /// **'分享妈祖所示'**
  String get shareTitle;

  /// No description provided for @shareWechat.
  ///
  /// In zh, this message translates to:
  /// **'微信'**
  String get shareWechat;

  /// No description provided for @shareMoments.
  ///
  /// In zh, this message translates to:
  /// **'朋友圈'**
  String get shareMoments;

  /// No description provided for @shareCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get shareCopy;

  /// No description provided for @shareSave.
  ///
  /// In zh, this message translates to:
  /// **'存图'**
  String get shareSave;

  /// No description provided for @shareCopied.
  ///
  /// In zh, this message translates to:
  /// **'文案已复制到剪贴板'**
  String get shareCopied;

  /// No description provided for @shareSavedToAlbum.
  ///
  /// In zh, this message translates to:
  /// **'已保存到相册\"AskMazu\"文件夹'**
  String get shareSavedToAlbum;

  /// No description provided for @shareImageGenFail.
  ///
  /// In zh, this message translates to:
  /// **'生成图片失败，请重试'**
  String get shareImageGenFail;

  /// No description provided for @shareOpFail.
  ///
  /// In zh, this message translates to:
  /// **'操作失败: {error}'**
  String shareOpFail(String error);

  /// No description provided for @shareAlbumPermFail.
  ///
  /// In zh, this message translates to:
  /// **'没有相册权限，请到设置中开启'**
  String get shareAlbumPermFail;

  /// No description provided for @shareSubject.
  ///
  /// In zh, this message translates to:
  /// **'妈祖所示'**
  String get shareSubject;

  /// No description provided for @shareSignPrefix.
  ///
  /// In zh, this message translates to:
  /// **'🙏 妈祖所示 · '**
  String get shareSignPrefix;

  /// No description provided for @shareFooter.
  ///
  /// In zh, this message translates to:
  /// **'—— 来自「问妈祖 Ask Mazu」'**
  String get shareFooter;

  /// No description provided for @shareMomentsHint.
  ///
  /// In zh, this message translates to:
  /// **'（请在分享面板选\"朋友圈\"）'**
  String get shareMomentsHint;

  /// No description provided for @aboutMazuTitle.
  ///
  /// In zh, this message translates to:
  /// **'关于妈祖'**
  String get aboutMazuTitle;

  /// No description provided for @privacyTitle.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacyTitle;

  /// No description provided for @tosTitle.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get tosTitle;

  /// No description provided for @aboutAppVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get aboutAppVersion;

  /// No description provided for @aboutAppBuildTime.
  ///
  /// In zh, this message translates to:
  /// **'构建时间'**
  String get aboutAppBuildTime;

  /// No description provided for @aboutAppPlatform.
  ///
  /// In zh, this message translates to:
  /// **'平台'**
  String get aboutAppPlatform;

  /// No description provided for @aboutAppFooter.
  ///
  /// In zh, this message translates to:
  /// **'用 ❤️ 与 🙏 制作'**
  String get aboutAppFooter;

  /// No description provided for @aboutCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制全文'**
  String get aboutCopy;

  /// No description provided for @aboutCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制全文'**
  String get aboutCopied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
