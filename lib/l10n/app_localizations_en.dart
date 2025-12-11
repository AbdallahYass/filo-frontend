// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Filo Menu';

  @override
  String get welcomeMessage => 'Welcome Back!';

  @override
  String get skip => 'Skip';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get checkNetworkMessage => 'Please check your network and try again.';

  @override
  String get processing => 'Processing...';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get logout => 'Logout';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get forgotPasswordInstructions =>
      'Enter your email address to receive a verification code.';

  @override
  String get login => 'LOGIN';

  @override
  String get sendCode => 'SEND CODE';

  @override
  String get codeSentSuccess => 'Code sent! Check your email 📧';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get requiredField => 'Required';

  @override
  String get emailNotVerified => 'Email not verified! New code sent 📧';

  @override
  String get loginFailed => 'Login failed.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get addPhoneNumberTitle => 'Add Your Phone Number 📱';

  @override
  String get addPhoneNumberHint =>
      'Select your country and enter phone number.';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get saveAndContinue => 'SAVE & CONTINUE';

  @override
  String get invalidPhone => 'Invalid Phone';

  @override
  String get checkEmailTitle => 'Check your Email';

  @override
  String get otpInstruction => 'We sent a code to';

  @override
  String get verify => 'VERIFY';

  @override
  String get verificationSuccess =>
      'Account activated successfully! Login now ✅';

  @override
  String get newPasswordTitle => 'New Password';

  @override
  String get enterOtpCode => 'Enter OTP Code';

  @override
  String get tooShort => 'Too short (min 6 chars)';

  @override
  String get invalidCode => 'Invalid Code';

  @override
  String get changePasswordButton => 'CHANGE PASSWORD';

  @override
  String get passwordChangedSuccess => 'Password Changed! Please Login 🚀';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get invalidEmail => 'Invalid Email';

  @override
  String get enterValidPhone => 'Please enter a valid phone number';

  @override
  String welcomeUser(Object name) {
    return 'Welcome $name';
  }

  @override
  String get menu => 'Menu';

  @override
  String get all => 'All';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get myCart => 'My Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get itemRemoved => 'Item removed';

  @override
  String get total => 'Total:';

  @override
  String get checkout => 'Checkout';

  @override
  String get orderPlacedTitle => 'Order Placed! 🎉';

  @override
  String get orderPlacedSuccessMsg =>
      'Your order has been sent to the kitchen.';

  @override
  String get ok => 'OK';

  @override
  String get orderFailed => 'Failed to place order. Check connection.';

  @override
  String get newPhoneNumber => 'New Phone Number';

  @override
  String get profileUpdatedSuccess => 'Profile Updated!';

  @override
  String get descriptionHeader => 'Description:';

  @override
  String get updateOrderButton => 'Update Order';

  @override
  String get addToCartButton => 'Add to Cart';

  @override
  String quantityUpdated(Object quantity) {
    return 'Quantity updated to $quantity';
  }

  @override
  String itemAddedToCart(Object quantity, Object itemTitle) {
    return '$quantity of $itemTitle added to cart';
  }

  @override
  String get home => 'Home';

  @override
  String get getBetterAppExperience => 'Get a better experience with the App!';

  @override
  String get downloadNow => 'Download Now';

  @override
  String get searchHint => 'Search for your favorite dish';

  @override
  String get popularNow => 'Popular Now';

  @override
  String get seeAll => 'See All';

  @override
  String get retry => 'Retry';

  @override
  String get noMenuItems => 'No menu items available';

  @override
  String screenTitlePlaceholder(Object title) {
    return '$title Screen';
  }

  @override
  String get order => 'Order';

  @override
  String get updateYourPassword => 'Update Your Password';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match!';

  @override
  String get generateQrTitle => 'Generate Table QR';

  @override
  String get enterTableNumberHint => 'Enter table number to generate QR';

  @override
  String get enterTableNumberField => 'Enter Table Number (e.g., 5)';

  @override
  String get generateQrButton => 'Generate Web QR';

  @override
  String get qrWebNote =>
      'Note: This QR will open the web version on any phone.';

  @override
  String get scanQrTitle => 'Scan Table QR';

  @override
  String tableSetSuccess(Object tableNumber) {
    return 'Table $tableNumber set successfully! ✅';
  }

  @override
  String get addressesTitle => 'My Addresses';

  @override
  String get noAddressesFound => 'No addresses saved yet.';

  @override
  String get addAddressTitle => 'Add New Address';

  @override
  String get addressDeletedSuccess => 'Address deleted successfully.';

  @override
  String get addressDeleteFailed => 'Failed to delete address.';

  @override
  String get editAddressTitle => 'Edit Address';

  @override
  String get selectLocationRequired => 'Please select a location on the map.';

  @override
  String get selectLocationButton => 'Select Location on Map';

  @override
  String get locationSelected => 'Location Selected';

  @override
  String get locationPickedSuccess => 'Location successfully picked from GPS.';

  @override
  String get locationPermissionError => 'Location permission denied or error.';

  @override
  String get addressTitlePlaceholder => 'Address Title (e.g., Home, Work)';

  @override
  String get addressDetailsPlaceholder => 'Street Name, Building Number';

  @override
  String get addressUpdatedSuccess => 'Address updated successfully!';

  @override
  String get addressAddedSuccess => 'Address added successfully!';

  @override
  String get logoutConfirmationTitle => 'Confirm Logout';

  @override
  String get logoutConfirmationMessage => 'Are you sure you want to log out?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get registrationFailed => 'Registration failed.';

  @override
  String get invalidOtp => 'Invalid activation code.';

  @override
  String get roleNotAllowed => 'Account role not allowed here.';

  @override
  String get serverError => 'Server error occurred.';

  @override
  String get loginRequired => 'Login is required to perform this action.';

  @override
  String get emailNotFound => 'Email not found.';

  @override
  String get userNotFound => 'User not found.';

  @override
  String get invalidOtpOrExpired => 'Invalid or expired OTP.';

  @override
  String get wrongCredentials => 'Wrong credentials.';

  @override
  String get connectionError =>
      'Connection failed. Please check your internet.';

  @override
  String get addressAddFailed =>
      'Failed to add address. Please try again later.';

  @override
  String get addressUpdateFailed =>
      'Failed to update address. Please try again later.';

  @override
  String get error => 'An unexpected error occurred.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmUpdateAddress =>
      'Are you sure you want to update this address?';

  @override
  String get confirmAddAddress => 'Are you sure you want to add this address?';

  @override
  String get confirmDeleteTitle => 'Confirm Deletion';

  @override
  String get deleteButton => 'Delete';

  @override
  String confirmDeleteAddressMessage(Object addressTitle) {
    return 'Are you sure you want to delete the address: $addressTitle?';
  }

  @override
  String get vendorDefaultName => 'Store Name';

  @override
  String get vendorDefaultDescription => 'Specializing in this category';

  @override
  String get storeOpen => 'Open Now';

  @override
  String get storeClosed => 'Closed';

  @override
  String noVendorsFound(Object categoryName) {
    return 'No $categoryName found yet.';
  }

  @override
  String get confirmUpdate => 'Confirm Profile Update';

  @override
  String get confirmUpdateMessage =>
      'Are you sure you want to save these changes?';

  @override
  String get noResultsFound => 'No results found for your search criteria.';

  @override
  String get searchVendorHint => 'Search vendors...';

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortByDefault => 'Default';

  @override
  String get sortByPopular => 'Most Popular';

  @override
  String get sortByRating => 'Best Rated';

  @override
  String get reviews => 'reviews';
}
