import 'package:flutter/material.dart';

import '../storage/local_app_storage.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController._();

  static final AppLocaleController instance = AppLocaleController._();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
  ];

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  AppLocalizations get l10n => AppLocalizations(_locale);

  Future<void> load() async {
    final savedCode = await LocalAppStorage.instance.getLanguageCode();
    _locale = _normalize(Locale(savedCode));
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final normalized = _normalize(locale);
    if (normalized == _locale) return;
    _locale = normalized;
    await LocalAppStorage.instance.setLanguageCode(normalized.languageCode);
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    await setLocale(Locale(code));
  }

  Locale _normalize(Locale locale) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return const Locale('en');
  }
}

extension AppLocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocaleController.instance.l10n;
}

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const List<Locale> supportedLocales =
      AppLocaleController.supportedLocales;

  String get languageCode {
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported.languageCode;
      }
    }
    return 'en';
  }

  String _t({required String en, required String ar, required String fr}) {
    switch (languageCode) {
      case 'ar':
        return ar;
      case 'fr':
        return fr;
      default:
        return en;
    }
  }

  String languageNameFor(String code) {
    switch (languageCode) {
      case 'ar':
        switch (code) {
          case 'ar':
            return 'العربية';
          case 'fr':
            return 'الفرنسية';
          default:
            return 'الإنجليزية';
        }
      case 'fr':
        switch (code) {
          case 'ar':
            return 'Arabe';
          case 'fr':
            return 'Français';
          default:
            return 'Anglais';
        }
      default:
        switch (code) {
          case 'ar':
            return 'Arabic';
          case 'fr':
            return 'French';
          default:
            return 'English';
        }
    }
  }

  String get appName => 'VacciTrack';
  String get appTagline => _t(
    en: 'HEALTHCARE ASSISTANT',
    ar: 'مساعد الرعاية الصحية',
    fr: 'ASSISTANT DE SANTÉ',
  );
  String get appSlogan => _t(
    en: 'Protect your child, one vaccine at a time',
    ar: 'احمِ طفلك، جرعة بعد جرعة',
    fr: 'Protégez votre enfant, vaccin par vaccin',
  );
  String get appVersionLabel => _t(en: 'Version', ar: 'الإصدار', fr: 'Version');

  String get initializingVault => _t(
    en: 'Initializing secure vault...',
    ar: 'جارٍ تهيئة الخزنة الآمنة...',
    fr: 'Initialisation du coffre sécurisé...',
  );
  String get loadingRecords => _t(
    en: 'Loading health records...',
    ar: 'جارٍ تحميل السجلات الصحية...',
    fr: 'Chargement des dossiers de santé...',
  );
  String get syncingSchedule => _t(
    en: 'Syncing vaccine schedule...',
    ar: 'جارٍ مزامنة جدول اللقاحات...',
    fr: 'Synchronisation du calendrier vaccinal...',
  );
  String get almostReady =>
      _t(en: 'Almost ready...', ar: 'يكاد يكتمل...', fr: 'Presque prêt...');

  String get onboarding1Title => _t(
    en: 'Track every vaccine',
    ar: 'تابع كل لقاح',
    fr: 'Suivez chaque vaccin',
  );
  String get onboarding1Desc => _t(
    en: "Stay on top of your child's immunization schedule with ease and accuracy.",
    ar: 'ابقَ على اطلاع بجدول تطعيم طفلك بسهولة ودقة.',
    fr: "Gardez le calendrier vaccinal de votre enfant sous contrôle facilement et avec précision.",
  );
  String get onboarding2Title => _t(
    en: 'Never miss a dose',
    ar: 'لا تفوّت أي جرعة',
    fr: 'Ne manquez aucune dose',
  );
  String get onboarding2Desc => _t(
    en: 'Get smart reminders before each vaccination appointment.',
    ar: 'احصل على تذكيرات ذكية قبل كل موعد تطعيم.',
    fr: 'Recevez des rappels intelligents avant chaque rendez-vous vaccinal.',
  );
  String get onboarding3Title => _t(
    en: 'Digital health records',
    ar: 'السجلات الصحية الرقمية',
    fr: 'Dossiers de santé numériques',
  );
  String get onboarding3Desc => _t(
    en: 'Store and share official vaccination certificates instantly.',
    ar: 'احفظ وشارك شهادات التطعيم الرسمية فورًا.',
    fr: 'Enregistrez et partagez instantanément les certificats de vaccination officiels.',
  );

  String get skip => _t(en: 'Skip', ar: 'تخطي', fr: 'Passer');
  String get next => _t(en: 'Next', ar: 'التالي', fr: 'Suivant');
  String get getStarted =>
      _t(en: 'Get Started', ar: 'ابدأ الآن', fr: 'Commencer');

  String get welcomeBack =>
      _t(en: 'Welcome back', ar: 'مرحبًا بعودتك', fr: 'Bon retour');
  String get manageYourHealthRecordsSecurely => _t(
    en: 'Manage your health records securely',
    ar: 'أدر سجلاتك الصحية بأمان',
    fr: 'Gérez vos dossiers de santé en toute sécurité',
  );
  String get emailAddress =>
      _t(en: 'Email address', ar: 'البريد الإلكتروني', fr: 'Adresse e-mail');
  String get password =>
      _t(en: 'Password', ar: 'كلمة المرور', fr: 'Mot de passe');
  String get enterYourEmail => _t(
    en: 'Enter your email',
    ar: 'أدخل بريدك الإلكتروني',
    fr: 'Saisissez votre e-mail',
  );
  String get enterYourPassword => _t(
    en: 'Enter your password',
    ar: 'أدخل كلمة المرور',
    fr: 'Saisissez votre mot de passe',
  );
  String get forgotPassword => _t(
    en: 'Forgot password?',
    ar: 'هل نسيت كلمة المرور؟',
    fr: 'Mot de passe oublié ?',
  );
  String get login => _t(en: 'Login', ar: 'تسجيل الدخول', fr: 'Connexion');
  String get cancel => _t(en: 'Cancel', ar: 'إلغاء', fr: 'Annuler');
  String get save => _t(en: 'Save', ar: 'حفظ', fr: 'Enregistrer');
  String get invalidCredentials => _t(
    en: 'Invalid credentials or no local account found. Please sign up first.',
    ar: 'بيانات الدخول غير صحيحة أو لا يوجد حساب محلي. يرجى التسجيل أولًا.',
    fr: 'Identifiants invalides ou aucun compte local trouvé. Veuillez d’abord vous inscrire.',
  );
  String get orContinueWith => _t(
    en: 'Or continue with',
    ar: 'أو تابع باستخدام',
    fr: 'Ou continuez avec',
  );
  String get dontHaveAccount => _t(
    en: "Don't have an account? ",
    ar: 'ليس لديك حساب؟ ',
    fr: "Vous n'avez pas de compte ? ",
  );
  String get signUp => _t(en: 'Sign up', ar: 'إنشاء حساب', fr: "S'inscrire");

  String get createAccount =>
      _t(en: 'Create Account', ar: 'إنشاء حساب', fr: 'Créer un compte');
  String get joinVacciTrack => _t(
    en: 'Join VacciTrack',
    ar: 'انضم إلى VacciTrack',
    fr: 'Rejoignez VacciTrack',
  );
  String get signupSubtitle => _t(
    en: 'Securely track your vaccinations by creating an account.',
    ar: 'تتبع لقاحاتك بأمان من خلال إنشاء حساب.',
    fr: 'Suivez vos vaccinations en toute sécurité en créant un compte.',
  );
  String get fullName =>
      _t(en: 'Full Name', ar: 'الاسم الكامل', fr: 'Nom complet');
  String get enterYourName =>
      _t(en: 'Enter your name', ar: 'أدخل اسمك', fr: 'Saisissez votre nom');
  String get phoneNumber =>
      _t(en: 'Phone Number', ar: 'رقم الهاتف', fr: 'Numéro de téléphone');
  String get enterYourEmailAddress => _t(
    en: 'Enter email',
    ar: 'أدخل البريد الإلكتروني',
    fr: 'Saisissez l’e-mail',
  );
  String get confirmPassword => _t(
    en: 'Confirm Password',
    ar: 'تأكيد كلمة المرور',
    fr: 'Confirmer le mot de passe',
  );
  String get passwordsDoNotMatch => _t(
    en: 'Passwords do not match',
    ar: 'كلمات المرور غير متطابقة',
    fr: 'Les mots de passe ne correspondent pas',
  );
  String get pleaseAgreeToTermsAndConditions => _t(
    en: 'Please agree to Terms & Conditions',
    ar: 'يرجى الموافقة على الشروط والأحكام',
    fr: 'Veuillez accepter les conditions générales',
  );
  String get thisEmailAlreadyExistsPleaseLoginInstead => _t(
    en: 'This email already exists. Please login instead.',
    ar: 'هذا البريد الإلكتروني موجود بالفعل. يرجى تسجيل الدخول بدلًا من ذلك.',
    fr: 'Cet e-mail existe déjà. Veuillez vous connecter à la place.',
  );
  String get weak => _t(en: 'Weak', ar: 'ضعيف', fr: 'Faible');
  String get medium => _t(en: 'Medium', ar: 'متوسط', fr: 'Moyen');
  String get strong => _t(en: 'Strong', ar: 'قوي', fr: 'Fort');
  String get strength => _t(en: 'Strength', ar: 'القوة', fr: 'Niveau');
  String get use8PlusCharactersWithSymbols => _t(
    en: 'Use 8+ characters with symbols.',
    ar: 'استخدم 8 أحرف أو أكثر مع رموز.',
    fr: 'Utilisez 8 caractères ou plus avec des symboles.',
  );
  String get agreeToThe =>
      _t(en: 'I agree to the ', ar: 'أوافق على ', fr: "J'accepte les ");
  String get termsAndConditions => _t(
    en: 'Terms & Conditions',
    ar: 'الشروط والأحكام',
    fr: 'Conditions générales',
  );
  String get andWord => _t(en: ' and ', ar: ' و ', fr: ' et ');
  String get privacyPolicy => _t(
    en: 'Privacy Policy',
    ar: 'سياسة الخصوصية',
    fr: 'Politique de confidentialité',
  );
  String get alreadyHaveAccount => _t(
    en: 'Already have an account? ',
    ar: 'هل لديك حساب بالفعل؟ ',
    fr: 'Vous avez déjà un compte ? ',
  );
  String get logIn => _t(en: 'Log in', ar: 'تسجيل الدخول', fr: 'Connexion');
  String get secureEncryptionActive => _t(
    en: 'Secure 256-bit encryption active',
    ar: 'تفعيل تشفير آمن 256-bit',
    fr: 'Chiffrement sécurisé 256 bits activé',
  );

  String get profileTitle => _t(
    en: 'Profile & Settings',
    ar: 'الملف الشخصي والإعدادات',
    fr: 'Profil et paramètres',
  );
  String get account => _t(en: 'ACCOUNT', ar: 'الحساب', fr: 'COMPTE');
  String get preferences =>
      _t(en: 'PREFERENCES', ar: 'التفضيلات', fr: 'PRÉFÉRENCES');
  String get appInformation => _t(
    en: 'APP INFORMATION',
    ar: 'معلومات التطبيق',
    fr: 'INFORMATIONS SUR L’APPLICATION',
  );
  String get personalInformation => _t(
    en: 'Personal Information',
    ar: 'المعلومات الشخصية',
    fr: 'Informations personnelles',
  );
  String get childrenManagement => _t(
    en: 'Children Management',
    ar: 'إدارة الأطفال',
    fr: 'Gestion des enfants',
  );
  String get childrenManagementSubtitle => _t(
    en: 'Add or edit children profiles',
    ar: 'أضف أو عدّل ملفات الأطفال',
    fr: 'Ajoutez ou modifiez les profils des enfants',
  );
  String get vaccinationCard => _t(
    en: 'Vaccination Card',
    ar: 'بطاقة التطعيم',
    fr: 'Carte de vaccination',
  );
  String get vaccinationCardSubtitle => _t(
    en: 'Open, print or share official card',
    ar: 'افتح البطاقة الرسمية أو اطبعها أو شاركها',
    fr: 'Ouvrir, imprimer ou partager la carte officielle',
  );
  String get notifications =>
      _t(en: 'Notifications', ar: 'الإشعارات', fr: 'Notifications');
  String get enabled => _t(en: 'Enabled', ar: 'مفعّل', fr: 'Activé');
  String get disabled => _t(en: 'Disabled', ar: 'معطّل', fr: 'Désactivé');
  String get testNotification => _t(
    en: 'Test Notification',
    ar: 'اختبار الإشعار',
    fr: 'Notification de test',
  );
  String get testNotificationHint => _t(
    en: 'Pick a date and time to test popup',
    ar: 'اختر تاريخًا ووقتًا لاختبار الإشعار',
    fr: 'Choisissez une date et une heure pour tester la notification',
  );
  String get childGender =>
      _t(en: 'Child gender', ar: 'نوع الطفل', fr: 'Genre de l’enfant');
  String get genderPreferNotToSay => _t(
    en: 'Prefer not to say',
    ar: 'أفضل عدم الإفصاح',
    fr: 'Préfère ne pas dire',
  );
  String get genderBoy => _t(en: 'Boy', ar: 'ولد', fr: 'Garçon');
  String get genderGirl => _t(en: 'Girl', ar: 'بنت', fr: 'Fille');
  String get genderOther => _t(en: 'Other', ar: 'أخرى', fr: 'Autre');
  String get sendTestNow => _t(
    en: 'Send Test Now',
    ar: 'إرسال اختبار الآن',
    fr: 'Envoyer un test maintenant',
  );
  String get editPersonalInformation => _t(
    en: 'Edit Personal Information',
    ar: 'تعديل المعلومات الشخصية',
    fr: 'Modifier les informations personnelles',
  );
  String get language => _t(en: 'Language', ar: 'اللغة', fr: 'Langue');
  String get languageEnglish =>
      _t(en: 'English', ar: 'الإنجليزية', fr: 'Anglais');
  String get languageArabic => _t(en: 'Arabic', ar: 'العربية', fr: 'Arabe');
  String get languageFrench => _t(en: 'French', ar: 'الفرنسية', fr: 'Français');
  String get openNotificationSettings => _t(
    en: 'Open notification settings',
    ar: 'فتح إعدادات الإشعارات',
    fr: 'Ouvrir les paramètres des notifications',
  );
  String get notificationSettings => _t(
    en: 'Notification settings',
    ar: 'إعدادات الإشعارات',
    fr: 'Paramètres des notifications',
  );
  String get exactAlarmSettings => _t(
    en: 'Exact alarm settings',
    ar: 'إعدادات التنبيه الدقيق',
    fr: 'Paramètres des alarmes exactes',
  );
  String get testReminderTitle => _t(
    en: 'VacciTrack Test Reminder',
    ar: 'تذكير اختبار VacciTrack',
    fr: 'Rappel de test VacciTrack',
  );
  String get immediateTestAt =>
      _t(en: 'Immediate test at', ar: 'اختبار فوري في', fr: 'Test immédiat à');
  String get immediateTestSent => _t(
    en: 'Immediate test sent',
    ar: 'تم إرسال الاختبار الفوري',
    fr: 'Test immédiat envoyé',
  );
  String get pendingScheduledNotifications => _t(
    en: 'Pending scheduled notifications',
    ar: 'الإشعارات المجدولة المعلقة',
    fr: 'Notifications programmées en attente',
  );
  String get scheduledTest =>
      _t(en: 'Scheduled test', ar: 'اختبار مجدول', fr: 'Test programmé');
  String get privacyPolicyTitle => _t(
    en: 'Privacy Policy',
    ar: 'سياسة الخصوصية',
    fr: 'Politique de confidentialité',
  );
  String get aboutAppTitle => _t(
    en: 'About VacciTrack',
    ar: 'حول VacciTrack',
    fr: 'À propos de VacciTrack',
  );
  String get aboutBody => _t(
    en: 'VacciTrack helps families track vaccination schedules, reminders, and records locally on the device. It is designed for private, offline-first use.',
    ar: 'يساعد VacciTrack العائلات على متابعة جداول اللقاحات والتذكيرات والسجلات محليًا على الجهاز. تم تصميمه للاستخدام الخاص بدون اتصال أولًا.',
    fr: 'VacciTrack aide les familles à suivre les calendriers vaccinaux, les rappels et les dossiers localement sur l’appareil. L’application est conçue pour une utilisation privée et hors ligne.',
  );
  String get privacyIntro => _t(
    en: 'Your data is stored on this device unless you export or share it. We do not send your family records to a remote server in this build.',
    ar: 'تُخزَّن بياناتك على هذا الجهاز إلا إذا قمت بتصديرها أو مشاركتها. لا نرسل سجلات عائلتك إلى خادم بعيد في هذا الإصدار.',
    fr: 'Vos données sont stockées sur cet appareil, sauf si vous les exportez ou les partagez. Nous n’envoyons pas vos dossiers familiaux vers un serveur distant dans cette version.',
  );
  String get privacyDataTitle =>
      _t(en: 'What we store', ar: 'ما الذي نخزّنه', fr: 'Ce que nous stockons');
  String get privacyDataBody => _t(
    en: 'Children profiles, vaccination history, local reminders, and your selected app language are saved on the phone using shared preferences.',
    ar: 'تُحفظ ملفات الأطفال، وسجل اللقاحات، والتذكيرات المحلية، ولغة التطبيق المختارة على الهاتف باستخدام SharedPreferences.',
    fr: 'Les profils des enfants, l’historique des vaccinations, les rappels locaux et la langue choisie sont enregistrés sur le téléphone via SharedPreferences.',
  );
  String get privacyUseTitle => _t(
    en: 'How we use it',
    ar: 'كيف نستخدمها',
    fr: 'Comment nous les utilisons',
  );
  String get privacyUseBody => _t(
    en: 'The app uses your saved data to build schedules, show reminders, and restore your session after login.',
    ar: 'يستخدم التطبيق بياناتك المحفوظة لإنشاء الجداول وعرض التذكيرات واستعادة جلستك بعد تسجيل الدخول.',
    fr: 'L’application utilise vos données enregistrées pour générer les calendriers, afficher les rappels et restaurer votre session après connexion.',
  );
  String get privacyContactTitle =>
      _t(en: 'Contact', ar: 'التواصل', fr: 'Contact');
  String get privacyContactBody => _t(
    en: 'If you want to change or remove stored data, sign out and clear app storage from Android settings.',
    ar: 'إذا أردت تغيير البيانات المخزنة أو حذفها، سجّل الخروج ثم امسح بيانات التطبيق من إعدادات أندرويد.',
    fr: 'Si vous souhaitez modifier ou supprimer les données stockées, déconnectez-vous puis videz le stockage de l’application depuis les paramètres Android.',
  );
  String get notificationsHelpTitle => _t(
    en: 'Android notification access',
    ar: 'وصول إشعارات أندرويد',
    fr: 'Accès aux notifications Android',
  );
  String get notificationsHelpBody => _t(
    en: 'Use the Android settings shortcuts below if notifications or exact alarms are blocked on your phone.',
    ar: 'استخدم اختصارات إعدادات أندرويد أدناه إذا كانت الإشعارات أو التنبيهات الدقيقة محجوبة على هاتفك.',
    fr: 'Utilisez les raccourcis des paramètres Android ci-dessous si les notifications ou les alarmes exactes sont bloquées sur votre téléphone.',
  );
  String get logout =>
      _t(en: 'Logout', ar: 'تسجيل الخروج', fr: 'Se déconnecter');
  String get confirmLogoutTitle =>
      _t(en: 'Logout', ar: 'تسجيل الخروج', fr: 'Se déconnecter');
  String get confirmLogoutBody => _t(
    en: 'Are you sure you want to logout?',
    ar: 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
    fr: 'Voulez-vous vraiment vous déconnecter ?',
  );
  String get futureDate => _t(
    en: 'Please pick a future date & time.',
    ar: 'يرجى اختيار تاريخ ووقت في المستقبل.',
    fr: 'Veuillez choisir une date et une heure futures.',
  );
  String get profileUpdated => _t(
    en: 'Profile updated',
    ar: 'تم تحديث الملف الشخصي',
    fr: 'Profil mis à jour',
  );
  String get invalidEmailOrPassword => _t(
    en: 'Invalid credentials or no local account found. Please sign up first.',
    ar: 'بيانات اعتماد غير صحيحة أو لا يوجد حساب محلي. يرجى التسجيل أولًا.',
    fr: 'Identifiants invalides ou aucun compte local trouvé. Veuillez d’abord vous inscrire.',
  );
  String get addChildProfileTitle => _t(
    en: 'Add Child Profile',
    ar: 'إضافة ملف طفل',
    fr: "Ajouter un profil d’enfant",
  );
  String get editChildProfileTitle => _t(
    en: 'Edit Child Profile',
    ar: 'تعديل ملف الطفل',
    fr: "Modifier le profil d’enfant",
  );
  String get familyProfiles =>
      _t(en: 'Family Profiles', ar: 'ملفات العائلة', fr: 'Profils familiaux');
  String get addYourChildProfileToGenerateVaccineSchedule => _t(
    en: 'Add your child profile to generate vaccine schedule.',
    ar: 'أضف ملف الطفل لإنشاء جدول اللقاحات.',
    fr: 'Ajoutez le profil de votre enfant pour générer le calendrier vaccinal.',
  );
  String get childFullName => _t(
    en: 'Child Full Name',
    ar: 'الاسم الكامل للطفل',
    fr: "Nom complet de l’enfant",
  );
  String get enterChildName => _t(
    en: 'Please enter child name',
    ar: 'يرجى إدخال اسم الطفل',
    fr: "Veuillez saisir le nom de l’enfant",
  );
  String get dateOfBirth =>
      _t(en: 'Date Of Birth', ar: 'تاريخ الميلاد', fr: 'Date de naissance');
  String get selectDate =>
      _t(en: 'Select date', ar: 'اختر التاريخ', fr: 'Choisir la date');
  String get notesOptional => _t(
    en: 'Notes (optional)',
    ar: 'ملاحظات (اختياري)',
    fr: 'Notes (facultatif)',
  );
  String get saveChildProfile => _t(
    en: 'Save Child Profile',
    ar: 'حفظ ملف الطفل',
    fr: "Enregistrer le profil de l’enfant",
  );
  String get updateChildProfile => _t(
    en: 'Update Child Profile',
    ar: 'تحديث ملف الطفل',
    fr: "Mettre à jour le profil de l’enfant",
  );
  String get pleaseSelectDateOfBirth => _t(
    en: 'Please select date of birth',
    ar: 'يرجى اختيار تاريخ الميلاد',
    fr: 'Veuillez sélectionner la date de naissance',
  );
  String get noChildProfilesYet => _t(
    en: 'No child profiles yet',
    ar: 'لا توجد ملفات أطفال بعد',
    fr: "Aucun profil d'enfant pour l'instant",
  );
  String get tapPlusToCreateFirstFamilyChildProfile => _t(
    en: 'Tap the + button to create the first family child profile.',
    ar: 'اضغط على زر + لإنشاء أول ملف لطفل في العائلة.',
    fr: 'Appuyez sur le bouton + pour créer le premier profil d’enfant de la famille.',
  );
  String get yourChildren =>
      _t(en: 'Your Children', ar: 'أطفالك', fr: 'Vos enfants');
  String get profiles => _t(en: 'Profiles', ar: 'ملفات', fr: 'Profils');
  String get searchChildren => _t(
    en: 'Search children...',
    ar: 'ابحث عن الأطفال...',
    fr: 'Rechercher des enfants...',
  );
  String get upcomingVaccination => _t(
    en: 'Upcoming Vaccination',
    ar: 'اللقاح القادم',
    fr: 'Vaccination à venir',
  );
  String get dueFor =>
      _t(en: 'is due for', ar: 'مستحق لـ', fr: 'doit recevoir');
  String get wouldYouLikeToSetReminder => _t(
    en: 'Would you like to set a reminder?',
    ar: 'هل ترغب في تعيين تذكير؟',
    fr: 'Souhaitez-vous définir un rappel ?',
  );
  String get viewSchedule =>
      _t(en: 'VIEW SCHEDULE →', ar: 'عرض الجدول →', fr: 'VOIR LE CALENDRIER →');
  String get today => _t(en: 'today', ar: 'اليوم', fr: 'aujourd’hui');
  String get tomorrow => _t(en: 'tomorrow', ar: 'غدًا', fr: 'demain');
  String dueInDays(int days) =>
      _t(en: 'in $days days', ar: 'خلال $days أيام', fr: 'dans $days jours');
  String get soon => _t(en: 'soon', ar: 'قريبًا', fr: 'bientôt');
  String get fullyProtected =>
      _t(en: 'Fully Protected', ar: 'محمي بالكامل', fr: 'Entièrement protégé');
  String get progress => _t(en: 'PROGRESS', ar: 'التقدّم', fr: 'PROGRESSION');
  String get vaccines => _t(en: 'VACCINES', ar: 'اللقاحات', fr: 'VACCINS');
  String get editProfile =>
      _t(en: 'Edit profile', ar: 'تعديل الملف', fr: 'Modifier le profil');
  String get deleteProfile =>
      _t(en: 'Delete profile', ar: 'حذف الملف', fr: 'Supprimer le profil');
  String get deleteChildProfileTitle => _t(
    en: 'Delete child profile',
    ar: 'حذف ملف الطفل',
    fr: "Supprimer le profil de l’enfant",
  );
  String deleteChildProfileBody(String childName) => _t(
    en: 'Are you sure you want to delete $childName and all vaccination history?',
    ar: 'هل أنت متأكد أنك تريد حذف $childName وكل سجل التطعيمات؟',
    fr: 'Voulez-vous vraiment supprimer $childName et tout l’historique des vaccinations ?',
  );
  String get delete => _t(en: 'Delete', ar: 'حذف', fr: 'Supprimer');
  String childDeleted(String childName) => _t(
    en: '$childName deleted',
    ar: 'تم حذف $childName',
    fr: '$childName supprimé',
  );
  String get alertsTitle => _t(en: 'Alerts', ar: 'التنبيهات', fr: 'Alertes');
  String get home => _t(en: 'Home', ar: 'الرئيسية', fr: 'Accueil');
  String get schedule => _t(en: 'Schedule', ar: 'الجدول', fr: 'Calendrier');
  String get profile => _t(en: 'Profile', ar: 'الملف', fr: 'Profil');
  String get all => _t(en: 'All', ar: 'الكل', fr: 'Tous');
  String get unread => _t(en: 'Unread', ar: 'غير مقروء', fr: 'Non lus');
  String get history => _t(en: 'History', ar: 'السجل', fr: 'Historique');
  String get noAlertsToShow => _t(
    en: 'No alerts to show',
    ar: 'لا توجد تنبيهات لعرضها',
    fr: 'Aucune alerte à afficher',
  );
  String get guideTitle => _t(
    en: 'Guide & Remarks',
    ar: 'الدليل والملاحظات',
    fr: 'Guide et remarques',
  );
  String get sideEffects =>
      _t(en: 'Side Effects', ar: 'الآثار الجانبية', fr: 'Effets secondaires');
  String get advice => _t(en: 'Advice', ar: 'نصائح', fr: 'Conseils');
  String get warningSigns =>
      _t(en: 'Warning Signs', ar: 'علامات التحذير', fr: 'Signes d’alerte');
  String get guideUnavailable => _t(
    en: 'Guide unavailable right now.',
    ar: 'الدليل غير متاح الآن.',
    fr: 'Le guide est indisponible pour le moment.',
  );
  String get emergencyHelpTitle =>
      _t(en: 'Emergency', ar: 'طوارئ', fr: 'Urgence');
  String get callEmergency => _t(
    en: 'Call Emergency',
    ar: 'الاتصال بالطوارئ',
    fr: 'Appeler les urgences',
  );
  String get emergencyHelpSubtitle => _t(
    en: 'Algeria ambulance line',
    ar: 'خط الإسعاف في الجزائر',
    fr: 'Ligne ambulance en Algérie',
  );
  String get civilProtectionAmbulance =>
      _t(en: 'Ambulance', ar: 'الإسعاف', fr: 'Ambulance');
  String get openEmergencyDialerFailed => _t(
    en: 'Unable to open the emergency dialer.',
    ar: 'تعذّر فتح الاتصال بالطوارئ.',
    fr: 'Impossible d’ouvrir le composeur d’urgence.',
  );
  String get addRemark =>
      _t(en: 'Add Remark', ar: 'إضافة ملاحظة', fr: 'Ajouter une remarque');
  String remarksCount(int count) => _t(
    en: '$count remark${count == 1 ? '' : 's'}',
    ar: '$count ملاحظة${count == 1 ? '' : 'ات'}',
    fr: '$count remarque${count == 1 ? '' : 's'}',
  );
  String get writeYourRemark => _t(
    en: 'Write your remark...',
    ar: 'اكتب ملاحظتك...',
    fr: 'Écrivez votre remarque...',
  );
  String get saveRemark =>
      _t(en: 'Save Remark', ar: 'حفظ الملاحظة', fr: 'Enregistrer la remarque');
  String get vaccinationCalendar => _t(
    en: 'Vaccination Calendar',
    ar: 'جدول اللقاحات',
    fr: 'Calendrier vaccinal',
  );
  String get allVaccines =>
      _t(en: 'All Vaccines', ar: 'كل اللقاحات', fr: 'Tous les vaccins');
  String get mandatory => _t(en: 'Mandatory', ar: 'إلزامي', fr: 'Obligatoire');
  String get optional => _t(en: 'Optional', ar: 'اختياري', fr: 'Facultatif');
  String get travel => _t(en: 'Travel', ar: 'السفر', fr: 'Voyage');
  String get addChildProfile => _t(
    en: 'Add Child Profile',
    ar: 'إضافة ملف طفل',
    fr: "Ajouter un profil d’enfant",
  );
  String get noVaccinationRecordsYet => _t(
    en: 'No vaccination records yet.',
    ar: 'لا توجد سجلات تطعيم بعد.',
    fr: 'Aucun dossier de vaccination pour le moment.',
  );
  String get vaccinationHistoryTitle => _t(
    en: 'Vaccination History',
    ar: 'سجل التطعيم',
    fr: 'Historique de vaccination',
  );
  String get allRecords =>
      _t(en: 'All Records', ar: 'كل السجلات', fr: 'Tous les dossiers');
  String get thisYear =>
      _t(en: 'This Year', ar: 'هذه السنة', fr: 'Cette année');
  String get thisMonth => _t(en: 'This Month', ar: 'هذا الشهر', fr: 'Ce mois');
  String get vaccinationRecords => _t(
    en: 'Vaccination records',
    ar: 'سجلات التطعيم',
    fr: 'Dossiers de vaccination',
  );
  String get noVaccinationHistoryYet => _t(
    en: 'No vaccination history yet.',
    ar: 'لا يوجد سجل تطعيم بعد.',
    fr: 'Aucun historique de vaccination pour le moment.',
  );
  String get usePlusToAddFirstRecord => _t(
    en: 'Use + to add first record.',
    ar: 'استخدم + لإضافة أول سجل.',
    fr: 'Utilisez + pour ajouter le premier dossier.',
  );
  String get vaccinationCardTitle => _t(
    en: 'Vaccination Card',
    ar: 'بطاقة التطعيم',
    fr: 'Carte de vaccination',
  );
  String get printCard =>
      _t(en: 'Print Card', ar: 'طباعة البطاقة', fr: 'Imprimer la carte');
  String get sharePdf =>
      _t(en: 'Share PDF', ar: 'مشاركة PDF', fr: 'Partager le PDF');
  String get saveToWallet => _t(
    en: 'Save to Wallet',
    ar: 'حفظ في المحفظة',
    fr: 'Enregistrer dans le portefeuille',
  );
  String get failedToPrintVaccinationCard => _t(
    en: 'Failed to print vaccination card',
    ar: 'فشل في طباعة بطاقة التطعيم',
    fr: 'Échec de l’impression de la carte de vaccination',
  );
  String get failedToExportVaccinationCard => _t(
    en: 'Failed to export vaccination card',
    ar: 'فشل في تصدير بطاقة التطعيم',
    fr: 'Échec de l’exportation de la carte de vaccination',
  );
  String get unknownChild =>
      _t(en: 'Unknown Child', ar: 'طفل غير معروف', fr: 'Enfant inconnu');
  String get child => _t(en: 'Child', ar: 'الطفل', fr: 'Enfant');
  String get dob => _t(en: 'DOB', ar: 'تاريخ الميلاد', fr: 'DN');
  String get recordId =>
      _t(en: 'Record ID', ar: 'رقم السجل', fr: 'ID du dossier');
  String get vaccine => _t(en: 'Vaccine', ar: 'اللقاح', fr: 'Vaccin');
  String get dose => _t(en: 'Dose', ar: 'الجرعة', fr: 'Dose');
  String get date => _t(en: 'Date', ar: 'التاريخ', fr: 'Date');
  String get clinic => _t(en: 'Clinic', ar: 'العيادة', fr: 'Clinique');
  String get notesShort => _t(en: 'Notes', ar: 'ملاحظات', fr: 'Notes');
  String get noLocalAccountFound => _t(
    en: 'No local account found.',
    ar: 'لا يوجد حساب محلي.',
    fr: 'Aucun compte local trouvé.',
  );
  String get recordVaccinationTitle => _t(
    en: 'Record Vaccination',
    ar: 'تسجيل التطعيم',
    fr: 'Enregistrer la vaccination',
  );
  String get noChildProfileFound => _t(
    en: 'No child profile found',
    ar: 'لم يتم العثور على ملف طفل',
    fr: 'Aucun profil d’enfant trouvé',
  );
  String get selectChild =>
      _t(en: 'Select Child', ar: 'اختر الطفل', fr: 'Sélectionner un enfant');
  String get selectDose =>
      _t(en: 'Select Dose', ar: 'اختر الجرعة', fr: 'Sélectionner une dose');
  String get administrationDate => _t(
    en: 'Administration Date',
    ar: 'تاريخ الإعطاء',
    fr: 'Date d’administration',
  );
  String get clinicNameOptional => _t(
    en: 'Clinic Name (optional)',
    ar: 'اسم العيادة (اختياري)',
    fr: 'Nom de la clinique (facultatif)',
  );
  String get lotNumberOptional => _t(
    en: 'Lot Number (optional)',
    ar: 'رقم الدفعة (اختياري)',
    fr: 'Numéro de lot (facultatif)',
  );
  String get remarks => _t(en: 'Remarks', ar: 'ملاحظات', fr: 'Remarques');
  String get confirmVaccination => _t(
    en: 'Confirm Vaccination',
    ar: 'تأكيد التطعيم',
    fr: 'Confirmer la vaccination',
  );
  String get pleaseSelectAChild => _t(
    en: 'Please select a child',
    ar: 'يرجى اختيار طفل',
    fr: 'Veuillez sélectionner un enfant',
  );
  String get noPendingDoseAvailableToRecord => _t(
    en: 'No pending dose available to record',
    ar: 'لا توجد جرعة معلقة لتسجيلها',
    fr: 'Aucune dose en attente à enregistrer',
  );
  String get vaccinationRecordedSuccessfully => _t(
    en: 'Vaccination recorded successfully',
    ar: 'تم تسجيل التطعيم بنجاح',
    fr: 'Vaccination enregistrée avec succès',
  );
  String get noPendingDose => _t(
    en: 'No pending dose',
    ar: 'لا توجد جرعة معلقة',
    fr: 'Aucune dose en attente',
  );
  String get forgotPasswordTitle => _t(
    en: 'Reset local password',
    ar: 'إعادة تعيين كلمة المرور المحلية',
    fr: 'Réinitialiser le mot de passe local',
  );
  String get forgotPasswordSubtitle => _t(
    en: 'This app stores accounts on the device only. Enter your email and a new password to update the saved login.',
    ar: 'هذا التطبيق يخزن الحسابات على الجهاز فقط. أدخل بريدك الإلكتروني وكلمة مرور جديدة لتحديث تسجيل الدخول المحفوظ.',
    fr: "Cette application stocke les comptes uniquement sur l’appareil. Saisissez votre e-mail et un nouveau mot de passe pour mettre à jour la connexion enregistrée.",
  );
  String get resetPassword => _t(
    en: 'Reset Password',
    ar: 'إعادة تعيين كلمة المرور',
    fr: 'Réinitialiser le mot de passe',
  );
  String get newPassword => _t(
    en: 'New Password',
    ar: 'كلمة المرور الجديدة',
    fr: 'Nouveau mot de passe',
  );
  String get passwordUpdated => _t(
    en: 'Password updated successfully',
    ar: 'تم تحديث كلمة المرور بنجاح',
    fr: 'Mot de passe mis à jour avec succès',
  );
  String get emailNotFound => _t(
    en: 'No saved account matches that email.',
    ar: 'لا يوجد حساب محفوظ يطابق هذا البريد الإلكتروني.',
    fr: "Aucun compte enregistré ne correspond à cet e-mail.",
  );
  String get settingsUnavailable => _t(
    en: 'This shortcut is only available on Android phones.',
    ar: 'هذا الاختصار متاح فقط على هواتف أندرويد.',
    fr: 'Ce raccourci est disponible uniquement sur les téléphones Android.',
  );
  String get openSystemSettingsFailed => _t(
    en: 'Unable to open system settings.',
    ar: 'تعذّر فتح إعدادات النظام.',
    fr: 'Impossible d’ouvrir les paramètres système.',
  );
  String get notificationSettingsSavedHint => _t(
    en: 'Use Android settings if the phone blocks reminders.',
    ar: 'استخدم إعدادات أندرويد إذا كان الهاتف يحظر التذكيرات.',
    fr: 'Utilisez les paramètres Android si le téléphone bloque les rappels.',
  );
  String get childNameExample => _t(
    en: 'Example: Leo Johnson',
    ar: 'مثال: ليو جونسون',
    fr: 'Exemple : Leo Johnson',
  );
  String get childNotesHint => _t(
    en: 'Allergies, previous doses, clinic preferences...',
    ar: 'الحساسية، الجرعات السابقة، تفضيلات العيادة...',
    fr: 'Allergies, doses précédentes, préférences de clinique...',
  );
  String get clinicNameExample => _t(
    en: 'Example: Central Pediatric Clinic',
    ar: 'مثال: عيادة الأطفال المركزية',
    fr: 'Exemple : Clinique pédiatrique centrale',
  );
  String get lotNumberExample => _t(
    en: 'Example: BCG-4281',
    ar: 'مثال: BCG-4281',
    fr: 'Exemple : BCG-4281',
  );
  String get postVaccineNotesHint => _t(
    en: 'Any post-vaccine notes...',
    ar: 'أي ملاحظات بعد التطعيم...',
    fr: 'Toute note après vaccination...',
  );
  String get lotLabel => _t(en: 'Lot', ar: 'الدفعة', fr: 'Lot');
  String get confirm => _t(en: 'Confirm', ar: 'تأكيد', fr: 'Confirmer');
  String get completed => _t(en: 'Completed', ar: 'مكتمل', fr: 'Terminé');
  String get calendar => _t(en: 'Calendar', ar: 'التقويم', fr: 'Calendrier');
  String get recordVaccine =>
      _t(en: 'Record Vaccine', ar: 'تسجيل اللقاح', fr: 'Enregistrer le vaccin');
  String get recentActivity =>
      _t(en: 'Recent Activity', ar: 'النشاط الأخير', fr: 'Activité récente');
  String get viewAll => _t(en: 'View All', ar: 'عرض الكل', fr: 'Tout voir');
  String get noActivityYet => _t(
    en: 'No activity yet. Record a vaccine to see updates here.',
    ar: 'لا يوجد نشاط بعد. سجّل لقاحًا لرؤية التحديثات هنا.',
    fr: "Aucune activité pour le moment. Enregistrez un vaccin pour voir les mises à jour ici.",
  );
  String get hello => _t(en: 'Hello', ar: 'مرحبًا', fr: 'Bonjour');
  String get parent => _t(en: 'Parent', ar: 'الوالد', fr: 'Parent');
  String readyForChildCheckup(String childFirstName) => _t(
    en: "Ready for $childFirstName's checkup?",
    ar: 'هل أنت مستعد لفحص $childFirstName؟',
    fr: 'Prêt pour la visite de $childFirstName ?',
  );
  String get addChild =>
      _t(en: 'Add Child', ar: 'إضافة طفل', fr: 'Ajouter un enfant');
  String get readyForCheckup => _t(
    en: 'Ready for checkup?',
    ar: 'هل أنت مستعد للفحص؟',
    fr: 'Prêt pour la visite ?',
  );
  String get addChildProfileFirstToGenerateTheVaccinationCalendar => _t(
    en: 'Add a child profile first to generate the vaccination calendar.',
    ar: 'أضف ملف طفل أولًا لإنشاء جدول اللقاحات.',
    fr: 'Ajoutez d’abord un profil d’enfant pour générer le calendrier vaccinal.',
  );
  String get nextBadge => _t(en: 'NEXT', ar: 'التالي', fr: 'SUIVANT');
  String get check => _t(en: 'Check', ar: 'تحقق', fr: 'Vérifier');
  String get receivedLabel => _t(en: 'received', ar: 'استلم', fr: 'a reçu');
  String get atLabel => _t(en: 'at', ar: 'في', fr: 'à');
  String get urgentTask =>
      _t(en: 'Urgent Task', ar: 'مهمة عاجلة', fr: 'Tâche urgente');
  String get noUrgentTaskRightNow => _t(
    en: 'No urgent task right now. Vaccines are on track.',
    ar: 'لا توجد مهمة عاجلة الآن. اللقاحات تسير حسب الخطة.',
    fr: 'Aucune tâche urgente pour le moment. Les vaccins sont dans les temps.',
  );
  String get vaccinesAreOnTrack => _t(
    en: 'Vaccines are on track.',
    ar: 'اللقاحات تسير حسب الخطة.',
    fr: 'Les vaccins sont dans les temps.',
  );
  String get late => _t(en: 'LATE', ar: 'متأخر', fr: 'EN RETARD');
  String get inLabel => _t(en: 'IN', ar: 'خلال', fr: 'DANS');
  String get dayLabel => _t(en: 'DAY', ar: 'يوم', fr: 'JOUR');
  String get daysLabel => _t(en: 'DAYS', ar: 'أيام', fr: 'JOURS');
  String get justNow => _t(en: 'JUST NOW', ar: 'الآن', fr: 'À l’instant');
  String monthsAgo(int months) => _t(
    en: '$months MONTH${months > 1 ? 'S' : ''} AGO',
    ar: 'منذ $months شهر${months > 1 ? 'ًا' : ''}',
    fr: 'Il y a $months mois',
  );
  String weeksAgo(int weeks) => _t(
    en: '$weeks WEEK${weeks > 1 ? 'S' : ''} AGO',
    ar: 'منذ $weeks أسبوع${weeks > 1 ? 'ًا' : ''}',
    fr: 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}',
  );
  String daysAgo(int days) => _t(
    en: '$days DAY${days > 1 ? 'S' : ''} AGO',
    ar: 'منذ $days يوم${days > 1 ? 'ًا' : ''}',
    fr: 'Il y a $days jour${days > 1 ? 's' : ''}',
  );
  String hoursAgo(int hours) => _t(
    en: '$hours HOUR${hours > 1 ? 'S' : ''} AGO',
    ar: 'منذ $hours ساعة${hours > 1 ? 'ً' : ''}',
    fr: 'Il y a $hours heure${hours > 1 ? 's' : ''}',
  );
  String get noDosesAvailableForThisFilter => _t(
    en: 'No doses available for this filter.',
    ar: 'لا توجد جرعات متاحة لهذا الفلتر.',
    fr: 'Aucune dose disponible pour ce filtre.',
  );
  String get vaccineReminderTitle =>
      _t(en: 'Vaccine Reminder', ar: 'تذكير باللقاح', fr: 'Rappel de vaccin');
  String get vaccineReminderDueOn =>
      _t(en: 'Due on', ar: 'مستحق في', fr: 'Prévu le');
  String get openVaccinationCalendar => _t(
    en: 'Open vaccination calendar',
    ar: 'افتح جدول اللقاحات',
    fr: 'Ouvrir le calendrier vaccinal',
  );
  String get recordNow =>
      _t(en: 'Record Now', ar: 'سجّل الآن', fr: 'Enregistrer maintenant');
  String get confirmAppointment => _t(
    en: 'Confirm Appointment',
    ar: 'تأكيد الموعد',
    fr: 'Confirmer le rendez-vous',
  );
  String get missedWindow =>
      _t(en: 'MISSED WINDOW', ar: 'نافذة فائتة', fr: 'FENÊTRE MANQUÉE');
  String get doneStatus => _t(en: 'DONE', ar: 'تم', fr: 'TERMINÉ');
  String get overdueStatus => _t(en: 'OVERDUE', ar: 'متأخر', fr: 'EN RETARD');
  String get dueSoonStatus => _t(en: 'DUE SOON', ar: 'قريبًا', fr: 'BIENTÔT');
  String get upcomingStatus => _t(en: 'UPCOMING', ar: 'القادم', fr: 'À VENIR');
  String get dueStatus => _t(en: 'DUE', ar: 'مستحق', fr: 'DÛ');
  String doseOf(int doseNumber, int totalDoses) => _t(
    en: 'Dose $doseNumber of $totalDoses',
    ar: 'الجرعة $doseNumber من $totalDoses',
    fr: 'Dose $doseNumber sur $totalDoses',
  );
  String get officialHealthRecord => _t(
    en: 'Official Health Record',
    ar: 'السجل الصحي الرسمي',
    fr: 'Dossier de santé officiel',
  );
  String get verifiedDigitalCopyOfImmunizationHistory => _t(
    en: 'Verified digital copy of immunization history',
    ar: 'نسخة رقمية موثقة من تاريخ التطعيم',
    fr: 'Copie numérique vérifiée de l’historique de vaccination',
  );
  String get unableToLoadVaccinationCard => _t(
    en: 'Unable to load vaccination card',
    ar: 'تعذّر تحميل بطاقة التطعيم',
    fr: 'Impossible de charger la carte de vaccination',
  );
  String get patientName =>
      _t(en: 'PATIENT NAME', ar: 'اسم المريض', fr: 'NOM DU PATIENT');
  String get vacciTrackVerified => _t(
    en: 'VACCITRACK VERIFIED',
    ar: 'تم التحقق من VacciTrack',
    fr: 'VacciTrack vérifié',
  );
  String get lastUpdatedLabel =>
      _t(en: 'Last Updated', ar: 'آخر تحديث', fr: 'Dernière mise à jour');
  String get vaccineNameHeader =>
      _t(en: 'VACCINE NAME', ar: 'اسم اللقاح', fr: 'NOM DU VACCIN');
  String get dateAdministeredHeader => _t(
    en: 'DATE ADMINISTERED',
    ar: 'تاريخ الإعطاء',
    fr: 'DATE D’ADMINISTRATION',
  );
  String get doseHeader => _t(en: 'DOSE', ar: 'الجرعة', fr: 'DOSE');
  String get providerInformation => _t(
    en: 'PROVIDER INFORMATION',
    ar: 'معلومات المزوّد',
    fr: 'INFORMATIONS DU PRESTATAIRE',
  );
  String get authenticatorSeal => _t(
    en: 'AUTHENTICATOR SEAL',
    ar: 'ختم المصادقة',
    fr: 'SCEAU D’AUTHENTIFICATION',
  );
  String
  get documentGeneratedFromLocalVaccinationRecordsSavedInVacciTrack => _t(
    en: 'This document is generated from local vaccination records saved in VacciTrack.',
    ar: 'تم إنشاء هذا المستند من سجلات التطعيم المحلية المحفوظة في VacciTrack.',
    fr: 'Ce document est généré à partir des dossiers de vaccination locaux enregistrés dans VacciTrack.',
  );
  String get notSpecified =>
      _t(en: 'Not specified', ar: 'غير محدد', fr: 'Non spécifié');
  String get needAnOfficialStamp => _t(
    en: 'Need an official stamp?',
    ar: 'هل تحتاج إلى ختم رسمي؟',
    fr: 'Besoin d’un tampon officiel ?',
  );
  String get acceptedByMostSchoolsAndTravelAuthorities => _t(
    en: 'This digital card is accepted by most schools and travel authorities.',
    ar: 'تُقبل هذه البطاقة الرقمية لدى معظم المدارس وسلطات السفر.',
    fr: 'Cette carte numérique est acceptée par la plupart des écoles et des autorités de voyage.',
  );
  String get pleaseVisitYourClinicAndProvideYourRecordId => _t(
    en: 'If you require a wet-ink signature, please visit your clinic and provide your Record ID:',
    ar: 'إذا كنت بحاجة إلى توقيع بخط اليد، يرجى زيارة العيادة وتقديم رقم السجل:',
    fr: 'Si vous avez besoin d’une signature manuscrite, veuillez vous rendre à votre clinique et fournir votre ID de dossier :',
  );
}
