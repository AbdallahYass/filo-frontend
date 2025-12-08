// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'قائمة فيلو';

  @override
  String get welcomeMessage => 'أهلاً بك مجدداً!';

  @override
  String get skip => 'تخطي';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get checkNetworkMessage => 'يرجى التحقق من الشبكة والمحاولة مرة أخرى.';

  @override
  String get error => 'خطأ';

  @override
  String get processing => 'جاري المعالجة...';

  @override
  String get settings => 'الإعدادات';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get signInToContinue => 'سجل دخولك للمتابعة';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordInstructions =>
      'أدخل بريدك الإلكتروني لاستلام رمز التحقق.';

  @override
  String get login => 'دخول';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get codeSentSuccess => 'تم إرسال الرمز! تحقق من بريدك 📧';

  @override
  String get or => 'أو';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام جوجل';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'تسجيل حساب';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get emailNotVerified => 'الإيميل غير مفعل! تم إرسال رمز جديد 📧';

  @override
  String get loginFailed => 'فشل تسجيل الدخول.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get completeProfile => 'إكمال الملف الشخصي';

  @override
  String get addPhoneNumberTitle => 'أضف رقم هاتفك 📱';

  @override
  String get addPhoneNumberHint => 'اختر دولتك وأدخل رقم الهاتف.';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get saveAndContinue => 'حفظ ومتابعة';

  @override
  String get invalidPhone => 'رقم هاتف غير صحيح';

  @override
  String get checkEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get otpInstruction => 'أرسلنا رمزاً إلى';

  @override
  String get verify => 'تأكيد';

  @override
  String get verificationSuccess =>
      'تم تفعيل الحساب بنجاح! قم بتسجيل الدخول الآن ✅';

  @override
  String get newPasswordTitle => 'كلمة المرور الجديدة';

  @override
  String get enterOtpCode => 'أدخل رمز التحقق';

  @override
  String get tooShort => 'قصير جداً (6 خانات على الأقل)';

  @override
  String get invalidCode => 'رمز غير صحيح';

  @override
  String get changePasswordButton => 'تغيير كلمة المرور';

  @override
  String get passwordChangedSuccess =>
      'تم تغيير كلمة المرور! يرجى تسجيل الدخول 🚀';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get enterValidPhone => 'يرجى إدخال رقم هاتف صالح';

  @override
  String welcomeUser(Object name) {
    return 'أهلاً بك $name';
  }

  @override
  String get menu => 'القائمة';

  @override
  String get all => 'الكل';

  @override
  String get noItemsFound => 'لم يتم العثور على عناصر';

  @override
  String get myCart => 'سلة مشترياتي';

  @override
  String get cartEmpty => 'سلتك فارغة';

  @override
  String get itemRemoved => 'تم حذف العنصر';

  @override
  String get total => 'الإجمالي:';

  @override
  String get checkout => 'إتمام الطلب';

  @override
  String get orderPlacedTitle => 'تم تأكيد الطلب! 🎉';

  @override
  String get orderPlacedSuccessMsg => 'تم إرسال طلبك إلى المطبخ.';

  @override
  String get ok => 'حسناً';

  @override
  String get orderFailed => 'فشل إرسال الطلب. تحقق من الاتصال.';

  @override
  String get newPhoneNumber => 'رقم هاتف جديد';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get profileUpdatedSuccess => 'تم تحديث الملف الشخصي!';

  @override
  String get descriptionHeader => 'الوصف:';

  @override
  String get updateOrderButton => 'تحديث الطلب';

  @override
  String get addToCartButton => 'أضف للسلة';

  @override
  String quantityUpdated(Object quantity) {
    return 'تم تحديث الكمية إلى $quantity';
  }

  @override
  String itemAddedToCart(Object quantity, Object itemTitle) {
    return 'تم إضافة $quantity من $itemTitle للسلة';
  }

  @override
  String get home => 'الرئيسية';

  @override
  String get getBetterAppExperience => 'احصل على تجربة أفضل مع التطبيق!';

  @override
  String get downloadNow => 'حمل الآن';

  @override
  String get searchHint => 'ابحث عن طبقك المفضل';

  @override
  String get popularNow => 'الأكثر شعبية الآن';

  @override
  String get seeAll => 'مشاهدة الكل';

  @override
  String get connectionError => 'خطأ في الاتصال بالسيرفر.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noMenuItems => 'لا توجد عناصر في القائمة';

  @override
  String screenTitlePlaceholder(Object title) {
    return 'شاشة $title';
  }

  @override
  String get order => 'اطلب';

  @override
  String get updateYourPassword => 'تحديث كلمة المرور الخاصة بك';

  @override
  String get oldPassword => 'كلمة المرور القديمة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين!';

  @override
  String get generateQrTitle => 'توليد رمز QR للطاولة';

  @override
  String get enterTableNumberHint => 'أدخل رقم الطاولة لتوليد رمز QR';

  @override
  String get enterTableNumberField => 'أدخل رقم الطاولة (مثال: 5)';

  @override
  String get generateQrButton => 'توليد رمز QR للويب';

  @override
  String get qrWebNote => 'ملاحظة: هذا الرمز سيفتح نسخة الويب على أي هاتف.';

  @override
  String get scanQrTitle => 'مسح رمز QR للطاولة';

  @override
  String tableSetSuccess(Object tableNumber) {
    return 'تم تعيين الطاولة رقم $tableNumber بنجاح! ✅';
  }

  @override
  String get addressesTitle => 'عناويني';

  @override
  String get noAddressesFound => 'لم يتم حفظ أي عناوين بعد.';

  @override
  String get addAddressTitle => 'إضافة عنوان جديد';

  @override
  String get addressDeletedSuccess => 'تم حذف العنوان بنجاح.';

  @override
  String get addressDeleteFailed => 'فشل حذف العنوان.';

  @override
  String get editAddressTitle => 'تعديل العنوان';

  @override
  String get selectLocationRequired => 'يرجى تحديد الموقع على الخريطة.';

  @override
  String get selectLocationButton => 'حدد الموقع على الخريطة';

  @override
  String get locationSelected => 'تم تحديد الموقع';

  @override
  String get locationPickedSuccess => 'تم التقاط الموقع بنجاح من GPS.';

  @override
  String get locationPermissionError => 'فشل الحصول على الموقع أو رفض الإذن.';

  @override
  String get addressTitlePlaceholder => 'عنوان الموقع (مثل: المنزل، العمل)';

  @override
  String get addressDetailsPlaceholder => 'اسم الشارع، رقم المبنى';

  @override
  String get addressUpdatedSuccess => 'تم تحديث العنوان بنجاح!';

  @override
  String get addressAddedSuccess => 'تم إضافة العنوان بنجاح!';

  @override
  String get logoutConfirmationTitle => 'تأكيد تسجيل الخروج';

  @override
  String get logoutConfirmationMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get registrationFailed => 'فشل عملية التسجيل.';

  @override
  String get invalidOtp => 'رمز التفعيل غير صحيح.';

  @override
  String get roleNotAllowed => 'هذا الحساب غير مخصص لتطبيق الزبائن.';

  @override
  String get serverError => 'حدث خطأ في الخادم.';

  @override
  String get addressAddFailed => 'فشل إضافة العنوان.';

  @override
  String get loginRequired => 'يجب تسجيل الدخول لإجراء هذه العملية.';

  @override
  String get emailNotFound => 'البريد الإلكتروني غير موجود.';

  @override
  String get userNotFound => 'المستخدم غير موجود.';

  @override
  String get invalidOtpOrExpired => 'رمز التفعيل غير صحيح أو منتهي الصلاحية.';

  @override
  String get wrongCredentials => 'بيانات الاعتماد غير صحيحة.';

  @override
  String get addressUpdateFailed => 'فشل تحديث العنوان.';
}
