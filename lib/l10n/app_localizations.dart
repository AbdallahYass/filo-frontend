import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Filo Menu'**
  String get appName;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeMessage;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// No description provided for @checkNetworkMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your network and try again.'**
  String get checkNetworkMessage;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @forgotPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a verification code.'**
  String get forgotPasswordInstructions;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'SEND CODE'**
  String get sendCode;

  /// No description provided for @codeSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code sent! Check your email 📧'**
  String get codeSentSuccess;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified! New code sent 📧'**
  String get emailNotVerified;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed.'**
  String get loginFailed;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @addPhoneNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Phone Number 📱'**
  String get addPhoneNumberTitle;

  /// No description provided for @addPhoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Select your country and enter phone number.'**
  String get addPhoneNumberHint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'SAVE & CONTINUE'**
  String get saveAndContinue;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid Phone'**
  String get invalidPhone;

  /// No description provided for @checkEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your Email'**
  String get checkEmailTitle;

  /// No description provided for @otpInstruction.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to'**
  String get otpInstruction;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get verify;

  /// No description provided for @verificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account activated successfully! Login now ✅'**
  String get verificationSuccess;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordTitle;

  /// No description provided for @enterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get enterOtpCode;

  /// No description provided for @tooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short (min 6 chars)'**
  String get tooShort;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid Code'**
  String get invalidCode;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'CHANGE PASSWORD'**
  String get changePasswordButton;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password Changed! Please Login 🚀'**
  String get passwordChangedSuccess;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid Email'**
  String get invalidEmail;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get enterValidPhone;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}'**
  String welcomeUser(Object name);

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @itemRemoved.
  ///
  /// In en, this message translates to:
  /// **'Item removed'**
  String get itemRemoved;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @orderPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Placed! 🎉'**
  String get orderPlacedTitle;

  /// No description provided for @orderPlacedSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Your order has been sent to the kitchen.'**
  String get orderPlacedSuccessMsg;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @orderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to place order. Check connection.'**
  String get orderFailed;

  /// No description provided for @newPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'New Phone Number'**
  String get newPhoneNumber;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated!'**
  String get profileUpdatedSuccess;

  /// No description provided for @descriptionHeader.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get descriptionHeader;

  /// No description provided for @updateOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Update Order'**
  String get updateOrderButton;

  /// No description provided for @addToCartButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCartButton;

  /// No description provided for @quantityUpdated.
  ///
  /// In en, this message translates to:
  /// **'Quantity updated to {quantity}'**
  String quantityUpdated(Object quantity);

  /// No description provided for @itemAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'{quantity} of {itemTitle} added to cart'**
  String itemAddedToCart(Object quantity, Object itemTitle);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @getBetterAppExperience.
  ///
  /// In en, this message translates to:
  /// **'Get a better experience with the App!'**
  String get getBetterAppExperience;

  /// No description provided for @downloadNow.
  ///
  /// In en, this message translates to:
  /// **'Download Now'**
  String get downloadNow;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for your favorite dish'**
  String get searchHint;

  /// No description provided for @popularNow.
  ///
  /// In en, this message translates to:
  /// **'Popular Now'**
  String get popularNow;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Server connection error.'**
  String get connectionError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noMenuItems.
  ///
  /// In en, this message translates to:
  /// **'No menu items available'**
  String get noMenuItems;

  /// No description provided for @screenTitlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'{title} Screen'**
  String screenTitlePlaceholder(Object title);

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @updateYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Update Your Password'**
  String get updateYourPassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match!'**
  String get passwordsDoNotMatch;

  /// No description provided for @generateQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate Table QR'**
  String get generateQrTitle;

  /// No description provided for @enterTableNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter table number to generate QR'**
  String get enterTableNumberHint;

  /// No description provided for @enterTableNumberField.
  ///
  /// In en, this message translates to:
  /// **'Enter Table Number (e.g., 5)'**
  String get enterTableNumberField;

  /// No description provided for @generateQrButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Web QR'**
  String get generateQrButton;

  /// No description provided for @qrWebNote.
  ///
  /// In en, this message translates to:
  /// **'Note: This QR will open the web version on any phone.'**
  String get qrWebNote;

  /// No description provided for @scanQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Table QR'**
  String get scanQrTitle;

  /// No description provided for @tableSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Table {tableNumber} set successfully! ✅'**
  String tableSetSuccess(Object tableNumber);

  /// No description provided for @addressesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get addressesTitle;

  /// No description provided for @noAddressesFound.
  ///
  /// In en, this message translates to:
  /// **'No addresses saved yet.'**
  String get noAddressesFound;

  /// No description provided for @addAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addAddressTitle;

  /// No description provided for @addressDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address deleted successfully.'**
  String get addressDeletedSuccess;

  /// No description provided for @addressDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete address.'**
  String get addressDeleteFailed;

  /// No description provided for @editAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddressTitle;

  /// No description provided for @selectLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a location on the map.'**
  String get selectLocationRequired;

  /// No description provided for @selectLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Select Location on Map'**
  String get selectLocationButton;

  /// No description provided for @locationSelected.
  ///
  /// In en, this message translates to:
  /// **'Location Selected'**
  String get locationSelected;

  /// No description provided for @locationPickedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location successfully picked from GPS.'**
  String get locationPickedSuccess;

  /// No description provided for @locationPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied or error.'**
  String get locationPermissionError;

  /// No description provided for @addressTitlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Address Title (e.g., Home, Work)'**
  String get addressTitlePlaceholder;

  /// No description provided for @addressDetailsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Street Name, Building Number'**
  String get addressDetailsPlaceholder;

  /// No description provided for @addressUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address updated successfully!'**
  String get addressUpdatedSuccess;

  /// No description provided for @addressAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address added successfully!'**
  String get addressAddedSuccess;

  /// No description provided for @logoutConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get logoutConfirmationTitle;

  /// No description provided for @logoutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmationMessage;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed.'**
  String get registrationFailed;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid activation code.'**
  String get invalidOtp;

  /// No description provided for @roleNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Account role not allowed here.'**
  String get roleNotAllowed;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred.'**
  String get serverError;

  /// No description provided for @addressAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add address.'**
  String get addressAddFailed;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login is required to perform this action.'**
  String get loginRequired;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found.'**
  String get emailNotFound;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get userNotFound;

  /// No description provided for @invalidOtpOrExpired.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired OTP.'**
  String get invalidOtpOrExpired;

  /// No description provided for @wrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong credentials.'**
  String get wrongCredentials;

  /// No description provided for @addressUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Address update failed.'**
  String get addressUpdateFailed;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
