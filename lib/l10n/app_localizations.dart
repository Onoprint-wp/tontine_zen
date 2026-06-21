import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tontine Zen'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Tontine Zen'**
  String get welcome;

  /// No description provided for @phoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get phoneLabel;

  /// No description provided for @sendOtp.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le code OTP'**
  String get sendOtp;

  /// No description provided for @enterOtp.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le code de confirmation'**
  String get enterOtp;

  /// No description provided for @verify.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le code'**
  String get verify;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @myTontines.
  ///
  /// In fr, this message translates to:
  /// **'Mes Tontines'**
  String get myTontines;

  /// No description provided for @createTontine.
  ///
  /// In fr, this message translates to:
  /// **'Créer une Tontine'**
  String get createTontine;

  /// No description provided for @reputationScore.
  ///
  /// In fr, this message translates to:
  /// **'Score de Réputation'**
  String get reputationScore;

  /// No description provided for @trustScoreDescription.
  ///
  /// In fr, this message translates to:
  /// **'Base de confiance'**
  String get trustScoreDescription;

  /// No description provided for @amountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant de la cotisation'**
  String get amountLabel;

  /// No description provided for @frequencyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fréquence'**
  String get frequencyLabel;

  /// No description provided for @daily.
  ///
  /// In fr, this message translates to:
  /// **'Quotidien'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In fr, this message translates to:
  /// **'Hebdomadaire'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In fr, this message translates to:
  /// **'Mensuel'**
  String get monthly;

  /// No description provided for @membersCount.
  ///
  /// In fr, this message translates to:
  /// **'Membres'**
  String get membersCount;

  /// No description provided for @disputes.
  ///
  /// In fr, this message translates to:
  /// **'Litiges'**
  String get disputes;

  /// No description provided for @contract.
  ///
  /// In fr, this message translates to:
  /// **'Contrat OHADA'**
  String get contract;

  /// No description provided for @signContract.
  ///
  /// In fr, this message translates to:
  /// **'Signer le contrat'**
  String get signContract;

  /// No description provided for @submitDispute.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un litige'**
  String get submitDispute;

  /// No description provided for @treasurer.
  ///
  /// In fr, this message translates to:
  /// **'Trésorier'**
  String get treasurer;

  /// No description provided for @member.
  ///
  /// In fr, this message translates to:
  /// **'Membre'**
  String get member;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
