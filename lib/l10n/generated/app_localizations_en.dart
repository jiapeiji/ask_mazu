// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ask Mazu';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'OK';

  @override
  String get homeDiscipleSuffix => 'Devotee';

  @override
  String get homeCityPrefix => 'Living in ';

  @override
  String get homeAskTitle => 'What do you seek today?';

  @override
  String get homeCatDaily => 'Daily Fortune';

  @override
  String get homeCatCareer => 'Career';

  @override
  String get homeCatLove => 'Love';

  @override
  String get homeCatFamily => 'Family';

  @override
  String get homeCatHealth => 'Health';

  @override
  String get homeCatWealth => 'Wealth';

  @override
  String get homeCatCustom => 'Custom';

  @override
  String get homeThrowBtn => 'Throw the Blocks';

  @override
  String get homeCustomPlaceholder => 'Tap to ask a question';

  @override
  String homeStatusTrialActive(int days) {
    return '$days days left in your free trial';
  }

  @override
  String get homeStatusTrialLastDay =>
      'Today is the last day of your free trial';

  @override
  String get homeStatusTrialExpired =>
      'Unlock unlimited throws for just \$0.99/month';

  @override
  String homeStatusSubscribed(String date) {
    return 'Subscribed · renews $date';
  }

  @override
  String get homeStatusSubExpired => 'Subscription expired';

  @override
  String get homeStatusLinkSubscribe => 'Subscribe Now';

  @override
  String get homeStatusLinkManage => 'Manage';

  @override
  String get homeStatusLinkRenew => 'Renew Now';

  @override
  String get homeCustomTitle => 'Custom Question';

  @override
  String get homeCustomHint => 'What would you like to ask Mazu?';

  @override
  String get paywallTitle => 'Unlock Mazu\'s Full Guidance';

  @override
  String get paywallSubtitle => 'Thank you for walking with Mazu';

  @override
  String get paywallFeatureUnlimited => 'Unlimited daily throws';

  @override
  String get paywallFeatureAllSigns => 'Full 60-sign library';

  @override
  String get paywallFeatureAmbient => 'Temple ambience for immersion';

  @override
  String get paywallPriceCardTitle => 'Monthly Subscription';

  @override
  String get paywallPriceCardPrice => '\$0.99 / month';

  @override
  String get paywallPriceCardNote =>
      'Auto-renews · cancel anytime in iOS Settings';

  @override
  String get paywallSubscribeBtn => 'Subscribe Now';

  @override
  String get paywallRestoreBtn => 'Restore Purchase';

  @override
  String get paywallSubscribeSuccess => 'Subscribed! Thanks for the support 🙏';

  @override
  String get paywallRestoreSuccess => 'Purchase restored';

  @override
  String get paywallRestoreEmpty => 'No purchase to restore';

  @override
  String get paywallTermsPrefix => 'By continuing you agree to our';

  @override
  String get paywallTermsLink => 'Terms of Service';

  @override
  String get paywallPrivacyLink => 'Privacy Policy';

  @override
  String get paywallPriceLoading => 'Loading…';

  @override
  String get paywallPriceError => 'Unavailable';

  @override
  String get paywallPendingHint => 'Awaiting confirmation…';

  @override
  String get paywallCanceledHint => 'Canceled';

  @override
  String get paywallErrorProduct =>
      'Unable to load product info. Please retry.';

  @override
  String paywallErrorPurchase(String message) {
    return 'Purchase failed: $message';
  }

  @override
  String paywallErrorRestore(String message) {
    return 'Restore failed: $message';
  }

  @override
  String paywallErrorGeneric(String message) {
    return 'Operation failed: $message';
  }

  @override
  String get paywallRetry => 'Retry';

  @override
  String get onbMazu => 'Mazu';

  @override
  String get onbTagline => 'A daily ritual for overseas Chinese';

  @override
  String get onbNameLabel => 'What shall we call you?';

  @override
  String get onbNameHint => 'Enter your name';

  @override
  String get onbNameErrorEmpty => 'Please enter your name';

  @override
  String get onbNameErrorShort => 'Name must be at least 2 characters';

  @override
  String get onbCityLabel => 'Where do you live?';

  @override
  String get onbCityHint => 'Enter your city';

  @override
  String get onbCityErrorEmpty => 'Please enter your city';

  @override
  String get onbCityErrorShort => 'City must be at least 2 characters';

  @override
  String get onbSubmit => 'Enter the Temple';

  @override
  String get onbFootnote =>
      'Your name and city are only used in readings and can be changed anytime in Settings.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionProfile => 'Profile';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionSound => 'Sound';

  @override
  String get settingsSectionSubscription => 'Subscription';

  @override
  String get settingsSectionView => 'Browse';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsSectionDebug => 'Debug';

  @override
  String get settingsProfileUnset => 'Not set';

  @override
  String get settingsEditProfileTitle => 'Edit Profile';

  @override
  String get settingsEditProfileName => 'Name';

  @override
  String get settingsEditProfileCity => 'City';

  @override
  String get settingsLanguageZhCn => '简体中文';

  @override
  String get settingsLanguageZhTw => '繁體中文';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageChanged => 'Language updated';

  @override
  String get settingsSoundBlockTitle => 'Block Landing Sound';

  @override
  String get settingsSoundBlockDesc => 'The sound of the wooden blocks landing';

  @override
  String get settingsSoundAmbientTitle => 'Temple Ambience';

  @override
  String get settingsSoundAmbientActive => 'Loops on the result page';

  @override
  String get settingsSoundAmbientLocked => 'Subscribe to unlock';

  @override
  String get settingsSoundHapticTitle => 'Haptic Feedback';

  @override
  String get settingsSoundHapticDesc =>
      'A gentle vibration when the throw completes';

  @override
  String get settingsSoundBadge => 'PRO';

  @override
  String get settingsSubActive => 'Subscribed';

  @override
  String get settingsSubInactive => 'Upgrade for Unlimited';

  @override
  String get settingsSubActiveDesc => 'Thanks for your support!';

  @override
  String get settingsSubInactiveDesc => '\$0.99 / month';

  @override
  String get settingsViewHistory => 'Question History';

  @override
  String get settingsAboutMazu => 'About Mazu';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsTerms => 'Terms of Service';

  @override
  String get settingsAboutApp => 'About this App';

  @override
  String get settingsDebugMockSub => 'Mock Subscription';

  @override
  String get settingsDebugMockSubDesc =>
      'When on, simulates an active subscription (for development). When off, resets the trial start time.';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsDeleteAllData => 'Delete All Data';

  @override
  String get settingsDeleteConfirmTitle => 'Delete All Data?';

  @override
  String get settingsDeleteConfirmBody =>
      'This action cannot be undone. Your name, city, throw history, and settings will be permanently erased. The app will return to its initial state.';

  @override
  String get settingsDeleteDone => 'Data deleted';

  @override
  String get commonDelete => 'Delete';

  @override
  String get settingsUpgradeTitle => 'Upgrade to Pro';

  @override
  String get settingsUpgradeFeatures =>
      '· Unlimited daily throws\n· Full 60-sign library\n· Temple ambience';

  @override
  String get settingsUpgradeNote =>
      'Note: Subscription goes live in V1 (after iOS App Store release).';

  @override
  String get historyTitle => 'Question History';

  @override
  String get historyEmpty => 'No questions yet';

  @override
  String historyLoadError(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get historyResultSaint => 'Saint Cup';

  @override
  String get historyResultLaugh => 'Laughing Cup';

  @override
  String get historyResultYin => 'Yin Cup';

  @override
  String get historyNoSign => 'No sign drawn';

  @override
  String historyAsk(String question) {
    return 'Q: $question';
  }

  @override
  String historySignTitle(String level, String id, String title) {
    return '$level · #$id 「$title」';
  }

  @override
  String get signsTitle => 'Sign Library';

  @override
  String signsLoadError(String error) {
    return 'Failed to load: $error';
  }

  @override
  String signsDetailTitle(String id) {
    return 'Sign #$id';
  }

  @override
  String get signsDetailInterpretation => 'Interpretation';

  @override
  String get signsDetailAllusion => 'Origin';

  @override
  String get signsDetailModern => 'Modern Reading';

  @override
  String get throwHint => 'Throw · Throw';

  @override
  String saintTemplate1(String name, String signTitle) {
    return 'Mazu has heard your prayer, $name. This is the sign of 「$signTitle」.';
  }

  @override
  String saintTemplate2(String name) {
    return 'The path is illuminated, $name. The sign is true.';
  }

  @override
  String saintTemplate3(String name, String signTitle) {
    return 'Mazu blesses your question, $name. The sign 「$signTitle」 — heed Heaven\'s timing.';
  }

  @override
  String saintTemplate4(String name) {
    return 'The sail is set, $name. Fair winds ahead. Ponder the sign carefully.';
  }

  @override
  String saintTemplate5(String name, String signTitle) {
    return 'Mazu, the mother, grants your wish. The sign 「$signTitle」 — go forth in peace.';
  }

  @override
  String saintTemplate6(String name) {
    return 'The Saint Cup is cast, $name. The way is clear — move forward with intent.';
  }

  @override
  String saintTemplate7(String name, String signTitle) {
    return 'Sails are raised, $name. The sign 「$signTitle」 — act when the time is right.';
  }

  @override
  String saintTemplate8(String name) {
    return 'Mazu smiles and nods. The sign is true. A steady heart wins all.';
  }

  @override
  String laughTemplate1(String name) {
    return 'A sincere heart, $name. Mazu has not yet granted. Pause, reflect, then ask again.';
  }

  @override
  String laughTemplate2(String name) {
    return 'Mazu smiles but says nothing, $name. Your question is unclear. Reflect and ask again.';
  }

  @override
  String laughTemplate3(String name) {
    return 'Mazu smiles, $name. The question may be too hasty or too broad. Slow down and ask again.';
  }

  @override
  String laughTemplate4(String name) {
    return 'The incense is not yet ready, $name. Take three quiet breaths and return.';
  }

  @override
  String laughTemplate5(String name) {
    return 'Asking Mazu is like sharpening a blade — too quickly dulls it. Mazu smiles at your haste. Slow down.';
  }

  @override
  String laughTemplate6(String name) {
    return 'Mazu shakes her head and smiles, $name. The time is not yet right. Return another day.';
  }

  @override
  String laughTemplate7(String name) {
    return 'Mazu smiles without answering, $name. There is a reason. Reflect inward — the answer may already be within you.';
  }

  @override
  String laughTemplate8(String name) {
    return 'The Laughing Cup is a \"not yet,\" $name. An unsettled heart cannot receive an answer.';
  }

  @override
  String yinTemplate1(String name) {
    return 'Mazu signals this path is not right, $name. Proceed slowly, if at all.';
  }

  @override
  String yinTemplate2(String name) {
    return 'This goes against the timing, $name. Mazu says: step back — the sea is wide.';
  }

  @override
  String yinTemplate3(String name) {
    return 'Haste brings no gain, $name. Mazu says: slow down, await the turning of fortune.';
  }

  @override
  String yinTemplate4(String name) {
    return 'Mazu clearly says this is wrong, $name. To force it brings regret.';
  }

  @override
  String yinTemplate5(String name) {
    return 'Mazu does not grant, $name. There is a deeper reason. Do not work against Heaven — defend, do not attack.';
  }

  @override
  String yinTemplate6(String name) {
    return 'Out of compassion, Mazu gives the Yin Cup, $name. It is for your good. Sheath the blade; plan, then act.';
  }

  @override
  String yinTemplate7(String name) {
    return 'Mazu shakes her head in warning, $name. The road ahead is closed. Wait patiently for Heaven\'s time.';
  }

  @override
  String yinTemplate8(String name) {
    return 'The Yin Cup warns of difficulty, not doom, $name. Mazu points you: turn the corner — the road lies ahead.';
  }

  @override
  String get resultSaint => 'Saint Cup';

  @override
  String get resultLaugh => 'Laughing Cup';

  @override
  String get resultYin => 'Yin Cup';

  @override
  String get resultShareBtn => 'Share';

  @override
  String get resultRetrySaint => 'Ask Again';

  @override
  String get resultRetryLaugh => 'Reframe Your Question';

  @override
  String get resultRetryYin => 'Try Another Day';

  @override
  String get shareTitle => 'Share Mazu\'s Reading';

  @override
  String get shareWechat => 'WeChat';

  @override
  String get shareMoments => 'Moments';

  @override
  String get shareCopy => 'Copy';

  @override
  String get shareSave => 'Save';

  @override
  String get shareCopied => 'Text copied to clipboard';

  @override
  String get shareSavedToAlbum => 'Saved to \"AskMazu\" album';

  @override
  String get shareImageGenFail => 'Failed to generate image. Please try again.';

  @override
  String shareOpFail(String error) {
    return 'Operation failed: $error';
  }

  @override
  String get shareAlbumPermFail =>
      'Photo permission required. Please enable in Settings.';

  @override
  String get shareSubject => 'Mazu\'s Reading';

  @override
  String get shareSignPrefix => '🙏 Mazu\'s Reading · ';

  @override
  String get shareFooter => '— from 「Ask Mazu 問媽祖」';

  @override
  String get shareMomentsHint =>
      '(Please choose \"Moments\" in the share sheet)';

  @override
  String get aboutMazuTitle => 'About Mazu';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get tosTitle => 'Terms of Service';

  @override
  String get aboutAppVersion => 'Version';

  @override
  String get aboutAppBuildTime => 'Build';

  @override
  String get aboutAppPlatform => 'Platform';

  @override
  String get aboutAppFooter => 'Made with ❤️ and 🙏';

  @override
  String get aboutCopy => 'Copy';

  @override
  String get aboutCopied => 'Copied to clipboard';
}
