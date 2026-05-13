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
    Locale('fr')
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Denzel\'s Cakes'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

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

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @chooseCategoryForCake.
  ///
  /// In en, this message translates to:
  /// **'Choose a category for this cake'**
  String get chooseCategoryForCake;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrders;

  /// No description provided for @completedOrders.
  ///
  /// In en, this message translates to:
  /// **'Completed Orders'**
  String get completedOrders;

  /// No description provided for @cancelledOrders.
  ///
  /// In en, this message translates to:
  /// **'Cancelled Orders'**
  String get cancelledOrders;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orderNumber;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @appRestartRequired.
  ///
  /// In en, this message translates to:
  /// **'App restart required for changes to take effect'**
  String get appRestartRequired;

  /// No description provided for @loadingCakes.
  ///
  /// In en, this message translates to:
  /// **'Loading cakes...'**
  String get loadingCakes;

  /// No description provided for @signingYouIn.
  ///
  /// In en, this message translates to:
  /// **'Signing you in...'**
  String get signingYouIn;

  /// No description provided for @creatingYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating your account...'**
  String get creatingYourAccount;

  /// No description provided for @placingYourOrder.
  ///
  /// In en, this message translates to:
  /// **'Placing your order...'**
  String get placingYourOrder;

  /// No description provided for @loadingOrders.
  ///
  /// In en, this message translates to:
  /// **'Loading orders...'**
  String get loadingOrders;

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get loadingProfile;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @loadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Loading categories...'**
  String get loadingCategories;

  /// No description provided for @loadingFavorites.
  ///
  /// In en, this message translates to:
  /// **'Loading favorites...'**
  String get loadingFavorites;

  /// No description provided for @loadingReviews.
  ///
  /// In en, this message translates to:
  /// **'Loading reviews...'**
  String get loadingReviews;

  /// No description provided for @sendingYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Sending your message...'**
  String get sendingYourMessage;

  /// No description provided for @loadingCakeDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading cake details...'**
  String get loadingCakeDetails;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get addPaymentMethod;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

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

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @noItemsInCart.
  ///
  /// In en, this message translates to:
  /// **'No items in cart'**
  String get noItemsInCart;

  /// No description provided for @emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCart;

  /// No description provided for @addItemsToCart.
  ///
  /// In en, this message translates to:
  /// **'Add items to your cart to get started'**
  String get addItemsToCart;

  /// No description provided for @welcomeBackTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back to'**
  String get welcomeBackTo;

  /// No description provided for @denzelsCakeShop.
  ///
  /// In en, this message translates to:
  /// **'Denzel\'s Cake Shop'**
  String get denzelsCakeShop;

  /// No description provided for @signInToOrder.
  ///
  /// In en, this message translates to:
  /// **'Sign in to order your favorite cakes and explore our delicious collection'**
  String get signInToOrder;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone'**
  String get emailOrPhone;

  /// No description provided for @enterEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter email or phone number'**
  String get enterEmailOrPhone;

  /// No description provided for @pleaseEnterEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or phone number'**
  String get pleaseEnterEmailOrPhone;

  /// No description provided for @pleaseEnterValidEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email or phone number'**
  String get pleaseEnterValidEmailOrPhone;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @createYourAccountToOrder.
  ///
  /// In en, this message translates to:
  /// **'Create your account to order delicious cakes and explore our collection'**
  String get createYourAccountToOrder;

  /// No description provided for @joinDenzelsCakes.
  ///
  /// In en, this message translates to:
  /// **'Join Denzel\'s Cakes'**
  String get joinDenzelsCakes;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccessful;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterYourPhoneNumber;

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumber;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @popularCakes.
  ///
  /// In en, this message translates to:
  /// **'Popular Cakes'**
  String get popularCakes;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get newArrivals;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @removeFromCart.
  ///
  /// In en, this message translates to:
  /// **'Remove from Cart'**
  String get removeFromCart;

  /// No description provided for @updateCart.
  ///
  /// In en, this message translates to:
  /// **'Update Cart'**
  String get updateCart;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @shoppingCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get shoppingCart;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @selectDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Date'**
  String get selectDeliveryDate;

  /// No description provided for @selectDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Select delivery time'**
  String get selectDeliveryTime;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructions;

  /// No description provided for @referenceImages.
  ///
  /// In en, this message translates to:
  /// **'Reference Images'**
  String get referenceImages;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @clearColor.
  ///
  /// In en, this message translates to:
  /// **'Clear Color'**
  String get clearColor;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @reviewOrder.
  ///
  /// In en, this message translates to:
  /// **'Review Order'**
  String get reviewOrder;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processingPayment;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSuccessful;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @viewOrder.
  ///
  /// In en, this message translates to:
  /// **'View Order'**
  String get viewOrder;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get startShopping;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @manageAddresses.
  ///
  /// In en, this message translates to:
  /// **'Manage Addresses'**
  String get manageAddresses;

  /// No description provided for @managePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Manage Payment Methods'**
  String get managePaymentMethods;

  /// No description provided for @orderNotifications.
  ///
  /// In en, this message translates to:
  /// **'Order Notifications'**
  String get orderNotifications;

  /// No description provided for @marketingEmails.
  ///
  /// In en, this message translates to:
  /// **'Marketing Emails'**
  String get marketingEmails;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @welcomeToDenzels.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Denzel\'s! 🎂'**
  String get welcomeToDenzels;

  /// No description provided for @deliciousCakesAwait.
  ///
  /// In en, this message translates to:
  /// **'Delicious cakes await!'**
  String get deliciousCakesAwait;

  /// No description provided for @searchForCakes.
  ///
  /// In en, this message translates to:
  /// **'Search for delicious cakes...'**
  String get searchForCakes;

  /// No description provided for @featuredCakes.
  ///
  /// In en, this message translates to:
  /// **'Featured Cakes'**
  String get featuredCakes;

  /// Category-specific cake title
  ///
  /// In en, this message translates to:
  /// **'{category} Cakes'**
  String cakesCategory(String category);

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @failedToLoadCakes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cakes'**
  String get failedToLoadCakes;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// Message when cake is removed from favorites
  ///
  /// In en, this message translates to:
  /// **'{cakeName} removed from favorites'**
  String removedFromFavorites(String cakeName);

  /// No description provided for @failedToUpdateFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorites'**
  String get failedToUpdateFavorites;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @loadingCart.
  ///
  /// In en, this message translates to:
  /// **'Loading cart...'**
  String get loadingCart;

  /// No description provided for @cartUpdated.
  ///
  /// In en, this message translates to:
  /// **'Cart updated'**
  String get cartUpdated;

  /// No description provided for @failedToUpdateCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to update cart'**
  String get failedToUpdateCart;

  /// No description provided for @itemRemovedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get itemRemovedFromCart;

  /// No description provided for @failedToRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove item'**
  String get failedToRemoveItem;

  /// No description provided for @cartCleared.
  ///
  /// In en, this message translates to:
  /// **'Cart cleared'**
  String get cartCleared;

  /// No description provided for @failedToClearCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cart'**
  String get failedToClearCart;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @clearCartConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items from your cart?'**
  String get clearCartConfirmation;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @browseCakesAndAdd.
  ///
  /// In en, this message translates to:
  /// **'Browse our delicious cakes and add them to your cart'**
  String get browseCakesAndAdd;

  /// Subtotal with item count
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String subtotalItems(num count);

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax (10%)'**
  String get tax;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @flavor.
  ///
  /// In en, this message translates to:
  /// **'Flavor'**
  String get flavor;

  /// No description provided for @checkoutWithTotal.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutWithTotal;

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedToLoadData;

  /// No description provided for @addressAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Address added successfully!'**
  String get addressAddedSuccessfully;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @selectDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Address'**
  String get selectDeliveryAddress;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @addNewPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add New Payment Method'**
  String get addNewPaymentMethod;

  /// No description provided for @specialInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructionsLabel;

  /// No description provided for @specialInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Leave at front door, Ring doorbell twice...'**
  String get specialInstructionsHint;

  /// No description provided for @targetGender.
  ///
  /// In en, this message translates to:
  /// **'Target Gender'**
  String get targetGender;

  /// No description provided for @selectTargetGender.
  ///
  /// In en, this message translates to:
  /// **'Select target gender for this order'**
  String get selectTargetGender;

  /// No description provided for @ageGroupAndGender.
  ///
  /// In en, this message translates to:
  /// **'Age Group & Gender'**
  String get ageGroupAndGender;

  /// No description provided for @ageGroupAndGenderOptional.
  ///
  /// In en, this message translates to:
  /// **'Age Group & Gender (Optional)'**
  String get ageGroupAndGenderOptional;

  /// No description provided for @specifyAgeGroupAndGender.
  ///
  /// In en, this message translates to:
  /// **'Specify the target age group and gender for this order'**
  String get specifyAgeGroupAndGender;

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'Age Group'**
  String get ageGroup;

  /// No description provided for @selectAgeGroup.
  ///
  /// In en, this message translates to:
  /// **'Select age group'**
  String get selectAgeGroup;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @adults.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get adults;

  /// No description provided for @kids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kids;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @boy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get boy;

  /// No description provided for @girl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get girl;

  /// No description provided for @cakeCustomizations.
  ///
  /// In en, this message translates to:
  /// **'Cake Customizations'**
  String get cakeCustomizations;

  /// No description provided for @addCustomizationsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., \"Happy Birthday John\", pink roses, gold lettering...'**
  String get addCustomizationsHint;

  /// No description provided for @chooseCakeColor.
  ///
  /// In en, this message translates to:
  /// **'Choose Cake Color'**
  String get chooseCakeColor;

  /// No description provided for @hue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get hue;

  /// No description provided for @saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturation;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @addReferenceImages.
  ///
  /// In en, this message translates to:
  /// **'Add Reference Images'**
  String get addReferenceImages;

  /// No description provided for @errorPickingImages.
  ///
  /// In en, this message translates to:
  /// **'Error picking images'**
  String get errorPickingImages;

  /// No description provided for @failedToPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to place order'**
  String get failedToPlaceOrder;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get orderPlacedSuccessfully;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// No description provided for @enterStreetName.
  ///
  /// In en, this message translates to:
  /// **'Enter street name and number'**
  String get enterStreetName;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @enterCityName.
  ///
  /// In en, this message translates to:
  /// **'Enter city name'**
  String get enterCityName;

  /// No description provided for @stateRegion.
  ///
  /// In en, this message translates to:
  /// **'State/Region'**
  String get stateRegion;

  /// No description provided for @enterStateOrRegion.
  ///
  /// In en, this message translates to:
  /// **'Enter state or region'**
  String get enterStateOrRegion;

  /// No description provided for @pleaseEnterStreetAndCity.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least street and city'**
  String get pleaseEnterStreetAndCity;

  /// No description provided for @locationAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Location added successfully!'**
  String get locationAddedSuccessfully;

  /// No description provided for @failedToLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders'**
  String get failedToLoadOrders;

  /// Cancel order confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel order #{orderNumber}?\n\nThis action cannot be undone.'**
  String cancelOrderConfirmation(String orderNumber);

  /// No description provided for @keepOrder.
  ///
  /// In en, this message translates to:
  /// **'Keep Order'**
  String get keepOrder;

  /// Order cancelled success message
  ///
  /// In en, this message translates to:
  /// **'Order #{orderNumber} has been cancelled'**
  String orderHasBeenCancelled(String orderNumber);

  /// No description provided for @failedToCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel order'**
  String get failedToCancelOrder;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Handcrafted with Love, Delivered Fresh'**
  String get splashTagline;

  /// No description provided for @preparingCakeExperience.
  ///
  /// In en, this message translates to:
  /// **'Preparing your cake experience...'**
  String get preparingCakeExperience;

  /// No description provided for @aboutDenzelsCakes.
  ///
  /// In en, this message translates to:
  /// **'About DenzelsCakes'**
  String get aboutDenzelsCakes;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Delicious cakes delivered fresh to your doorstep in Cameroon'**
  String get aboutTagline;

  /// No description provided for @ourStory.
  ///
  /// In en, this message translates to:
  /// **'Our Story'**
  String get ourStory;

  /// No description provided for @ourStoryText.
  ///
  /// In en, this message translates to:
  /// **'Founded in 2020, Denzel\'s Cakes began as a passion project to bring the finest, freshest cakes to the people of Cameroon. Our journey started in a small kitchen in Douala with a simple mission: to create memorable moments through exceptional cakes.\n\nToday, we\'re proud to serve customers across Cameroon with our handcrafted cakes, made with love and the finest local ingredients. Every cake tells a story, and we\'re honored to be part of your special moments.'**
  String get ourStoryText;

  /// No description provided for @whatWeOffer.
  ///
  /// In en, this message translates to:
  /// **'What We Offer'**
  String get whatWeOffer;

  /// No description provided for @freshCakesDaily.
  ///
  /// In en, this message translates to:
  /// **'Fresh Cakes Daily'**
  String get freshCakesDaily;

  /// No description provided for @freshCakesDailyDesc.
  ///
  /// In en, this message translates to:
  /// **'Baked fresh every day with premium ingredients'**
  String get freshCakesDailyDesc;

  /// No description provided for @fastDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fast Delivery'**
  String get fastDelivery;

  /// No description provided for @fastDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Same-day delivery across Yaoundé and surrounding areas'**
  String get fastDeliveryDesc;

  /// No description provided for @customDesigns.
  ///
  /// In en, this message translates to:
  /// **'Custom Designs'**
  String get customDesigns;

  /// No description provided for @customDesignsDesc.
  ///
  /// In en, this message translates to:
  /// **'Personalized cakes for your special occasions'**
  String get customDesignsDesc;

  /// No description provided for @easyPayment.
  ///
  /// In en, this message translates to:
  /// **'Easy Payment'**
  String get easyPayment;

  /// No description provided for @easyPaymentDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay with cards or mobile money (MTN, Orange)'**
  String get easyPaymentDesc;

  /// No description provided for @support247.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get support247;

  /// No description provided for @support247Desc.
  ///
  /// In en, this message translates to:
  /// **'Customer support whenever you need us'**
  String get support247Desc;

  /// No description provided for @ourTeam.
  ///
  /// In en, this message translates to:
  /// **'Our Team'**
  String get ourTeam;

  /// No description provided for @headBakerFounder.
  ///
  /// In en, this message translates to:
  /// **'Head Baker & Founder'**
  String get headBakerFounder;

  /// No description provided for @pastryChef.
  ///
  /// In en, this message translates to:
  /// **'Pastry Chef'**
  String get pastryChef;

  /// No description provided for @customerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Customer Success'**
  String get customerSuccess;

  /// No description provided for @yearsBakingExperience.
  ///
  /// In en, this message translates to:
  /// **'15+ years of baking experience'**
  String get yearsBakingExperience;

  /// No description provided for @specialistCustomCakes.
  ///
  /// In en, this message translates to:
  /// **'Specialist in custom cake designs'**
  String get specialistCustomCakes;

  /// No description provided for @ensuringCustomerHappy.
  ///
  /// In en, this message translates to:
  /// **'Ensuring every customer is happy'**
  String get ensuringCustomerHappy;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationAddress.
  ///
  /// In en, this message translates to:
  /// **'Makepe, Douala\nCameroon\nOpposite Tradex Rhone Poulenc'**
  String get locationAddress;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @legalCredits.
  ///
  /// In en, this message translates to:
  /// **'Legal & Credits'**
  String get legalCredits;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2020 DenzelsCakes Cameroon\nAll rights reserved'**
  String get copyright;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyText.
  ///
  /// In en, this message translates to:
  /// **'At DenzelsCakes, we respect your privacy and are committed to protecting your personal information.\n\nInformation We Collect:\n• Contact information (name, email, phone)\n• Delivery addresses\n• Order history and preferences\n• Payment information (securely processed)\n\nHow We Use Your Information:\n• Process and fulfill your orders\n• Communicate about your orders\n• Improve our services\n• Send promotional offers (with consent)\n\nWe never sell your personal information to third parties.'**
  String get privacyPolicyText;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @termsOfServiceText.
  ///
  /// In en, this message translates to:
  /// **'Welcome to DenzelsCakes! By using our service, you agree to these terms.\n\nOrders:\n• All orders are subject to availability\n• Custom cakes require 24-48 hours notice\n• Prices are in FCFA and include applicable taxes\n\nDelivery:\n• Delivery times are estimates\n• Delivery fees apply based on location\n• We are not responsible for delays due to weather or traffic\n\nCancellations:\n• Orders can be cancelled within 2 hours of placement\n• Custom orders may have different cancellation policies\n\nQuality Guarantee:\n• We guarantee the freshness and quality of our cakes\n• Contact us within 24 hours for any quality issues'**
  String get termsOfServiceText;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @failedToLoadFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to load favorites'**
  String get failedToLoadFavorites;

  /// No description provided for @unknownErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownErrorOccurred;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @startAddingCakesToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Start adding cakes to your favorites\nto see them here'**
  String get startAddingCakesToFavorites;

  /// No description provided for @browseCakes.
  ///
  /// In en, this message translates to:
  /// **'Browse Cakes'**
  String get browseCakes;

  /// No description provided for @unableToViewCakeDetails.
  ///
  /// In en, this message translates to:
  /// **'Unable to view cake details'**
  String get unableToViewCakeDetails;

  /// No description provided for @unknownCake.
  ///
  /// In en, this message translates to:
  /// **'Unknown Cake'**
  String get unknownCake;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @ago.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get ago;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @clearAllFavorites.
  ///
  /// In en, this message translates to:
  /// **'Clear All Favorites'**
  String get clearAllFavorites;

  /// No description provided for @clearAllFavoritesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all cakes from your favorites?'**
  String get clearAllFavoritesConfirmation;

  /// No description provided for @allFavoritesCleared.
  ///
  /// In en, this message translates to:
  /// **'All favorites cleared'**
  String get allFavoritesCleared;

  /// No description provided for @failedToClearFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear favorites'**
  String get failedToClearFavorites;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @failedToUndoRemoval.
  ///
  /// In en, this message translates to:
  /// **'Failed to undo removal'**
  String get failedToUndoRemoval;

  /// No description provided for @failedToRemoveFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove from favorites'**
  String get failedToRemoveFromFavorites;

  /// Message when cake is added to cart
  ///
  /// In en, this message translates to:
  /// **'{cakeName} added to cart!'**
  String addedToCart(String cakeName);

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @recently.
  ///
  /// In en, this message translates to:
  /// **'recently'**
  String get recently;

  /// No description provided for @invalidFavoriteItem.
  ///
  /// In en, this message translates to:
  /// **'Invalid favorite item'**
  String get invalidFavoriteItem;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @getInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get in Touch'**
  String get getInTouch;

  /// No description provided for @sendUsAMessage.
  ///
  /// In en, this message translates to:
  /// **'Send us a Message'**
  String get sendUsAMessage;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @pleaseEnterASubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get pleaseEnterASubject;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @pleaseEnterYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your message'**
  String get pleaseEnterYourMessage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @messageSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully! We\'ll get back to you soon.'**
  String get messageSentSuccessfully;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get failedToSendMessage;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @ourLocation.
  ///
  /// In en, this message translates to:
  /// **'Our Location'**
  String get ourLocation;

  /// No description provided for @businessHours.
  ///
  /// In en, this message translates to:
  /// **'Business Hours'**
  String get businessHours;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @receiveNotificationsOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications on your device'**
  String get receiveNotificationsOnDevice;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order Updates'**
  String get orderUpdates;

  /// No description provided for @orderUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Order confirmations, preparation, and delivery updates'**
  String get orderUpdatesDesc;

  /// No description provided for @promotionsOffers.
  ///
  /// In en, this message translates to:
  /// **'Promotions & Offers'**
  String get promotionsOffers;

  /// No description provided for @promotionsOffersDesc.
  ///
  /// In en, this message translates to:
  /// **'Special deals and new product announcements'**
  String get promotionsOffersDesc;

  /// No description provided for @securityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Security Alerts'**
  String get securityAlerts;

  /// No description provided for @securityAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Important security notifications and account activity'**
  String get securityAlertsDesc;

  /// No description provided for @resetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// No description provided for @resetToDefaultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaultsTitle;

  /// No description provided for @resetToDefaultsMessage.
  ///
  /// In en, this message translates to:
  /// **'This will reset all notification settings to their default values. Are you sure?'**
  String get resetToDefaultsMessage;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @notificationSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Notification settings saved!'**
  String get notificationSettingsSaved;

  /// No description provided for @settingsResetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetToDefaults;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @updateAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updateAccountPassword;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get activeSessions;

  /// No description provided for @manageDevicesLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Manage devices logged into your account'**
  String get manageDevicesLoggedIn;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChangedSuccessfully;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This Device'**
  String get thisDevice;

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get activeNow;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @webBrowser.
  ///
  /// In en, this message translates to:
  /// **'Web Browser'**
  String get webBrowser;

  /// Days ago text
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(num days);

  /// No description provided for @accountActions.
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActions;

  /// No description provided for @deactivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Account'**
  String get deactivateAccount;

  /// No description provided for @deactivateAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account will be temporarily disabled. You can reactivate it anytime by logging in.'**
  String get deactivateAccountMessage;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @accountDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Account deactivated'**
  String get accountDeactivated;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted.'**
  String get deleteAccountMessage;

  /// No description provided for @accountDeletionRequiresVerification.
  ///
  /// In en, this message translates to:
  /// **'Account deletion requires email verification'**
  String get accountDeletionRequiresVerification;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get myReviews;

  /// My reviews tab with count
  ///
  /// In en, this message translates to:
  /// **'My Reviews ({count})'**
  String myReviewsCount(num count);

  /// Pending reviews tab with count
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String pendingCount(num count);

  /// No description provided for @failedToLoadReviews.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reviews'**
  String get failedToLoadReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @reviewsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your reviews will appear here after you rate your orders'**
  String get reviewsWillAppearHere;

  /// No description provided for @noPendingReviews.
  ///
  /// In en, this message translates to:
  /// **'No pending reviews'**
  String get noPendingReviews;

  /// No description provided for @ordersWaitingForReview.
  ///
  /// In en, this message translates to:
  /// **'Orders waiting for your review will appear here'**
  String get ordersWaitingForReview;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get writeReview;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit Review'**
  String get editReview;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @reviewSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully!'**
  String get reviewSubmittedSuccessfully;

  /// No description provided for @failedToSubmitReview.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review'**
  String get failedToSubmitReview;

  /// No description provided for @editReviewFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Edit review feature coming soon!'**
  String get editReviewFeatureComingSoon;

  /// No description provided for @chooseCakeToReview.
  ///
  /// In en, this message translates to:
  /// **'Choose a cake to review'**
  String get chooseCakeToReview;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @searchForHelp.
  ///
  /// In en, this message translates to:
  /// **'Search for help...'**
  String get searchForHelp;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @whatsappOrCall.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp or Call'**
  String get whatsappOrCall;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @trySearchingWithDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get trySearchingWithDifferentKeywords;

  /// No description provided for @chooseHowToContact.
  ///
  /// In en, this message translates to:
  /// **'Choose how you\'d like to contact our support team:'**
  String get chooseHowToContact;

  /// No description provided for @trainingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Training Schedule'**
  String get trainingSchedule;

  /// No description provided for @masterArtOfCakeDecoration.
  ///
  /// In en, this message translates to:
  /// **'Master the art of cake decoration'**
  String get masterArtOfCakeDecoration;

  /// No description provided for @cakeDecorationMastery.
  ///
  /// In en, this message translates to:
  /// **'Cake Decoration Mastery'**
  String get cakeDecorationMastery;

  /// No description provided for @topicsCovered.
  ///
  /// In en, this message translates to:
  /// **'Topics Covered'**
  String get topicsCovered;

  /// No description provided for @viewProgress.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgress;

  /// No description provided for @currentlyRunning.
  ///
  /// In en, this message translates to:
  /// **'Currently Running'**
  String get currentlyRunning;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @guestEmail.
  ///
  /// In en, this message translates to:
  /// **'guest@example.com'**
  String get guestEmail;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @updateYourPersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get updateYourPersonalInformation;

  /// No description provided for @manageDeliveryAddresses.
  ///
  /// In en, this message translates to:
  /// **'Manage delivery addresses'**
  String get manageDeliveryAddresses;

  /// No description provided for @manageCardsAndPaymentOptions.
  ///
  /// In en, this message translates to:
  /// **'Manage cards and payment options'**
  String get manageCardsAndPaymentOptions;

  /// No description provided for @ordersPreferences.
  ///
  /// In en, this message translates to:
  /// **'Orders & Preferences'**
  String get ordersPreferences;

  /// No description provided for @viewYourPastOrders.
  ///
  /// In en, this message translates to:
  /// **'View your past orders'**
  String get viewYourPastOrders;

  /// No description provided for @yourFavoriteCakes.
  ///
  /// In en, this message translates to:
  /// **'Your favorite cakes'**
  String get yourFavoriteCakes;

  /// No description provided for @yourReviewsAndRatings.
  ///
  /// In en, this message translates to:
  /// **'Your reviews and ratings'**
  String get yourReviewsAndRatings;

  /// No description provided for @supportSettings.
  ///
  /// In en, this message translates to:
  /// **'Support & Settings'**
  String get supportSettings;

  /// No description provided for @getHelpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get getHelpAndSupport;

  /// No description provided for @getInTouchWithUs.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with us'**
  String get getInTouchWithUs;

  /// No description provided for @manageNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Manage notification settings'**
  String get manageNotificationSettings;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// No description provided for @legalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Legal & Privacy'**
  String get legalPrivacy;

  /// No description provided for @privacySettingsAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings and security'**
  String get privacySettingsAndSecurity;

  /// No description provided for @appVersionAndInformation.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get appVersionAndInformation;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @categoryBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get categoryBirthday;

  /// No description provided for @categoryWedding.
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get categoryWedding;

  /// No description provided for @categoryAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get categoryAnniversary;

  /// No description provided for @categoryBabyShower.
  ///
  /// In en, this message translates to:
  /// **'Baby Shower'**
  String get categoryBabyShower;

  /// No description provided for @categoryFaithCelebrations.
  ///
  /// In en, this message translates to:
  /// **'Faith Celebrations'**
  String get categoryFaithCelebrations;

  /// No description provided for @categoryEngagement.
  ///
  /// In en, this message translates to:
  /// **'Engagement'**
  String get categoryEngagement;

  /// No description provided for @categoryBridalShower.
  ///
  /// In en, this message translates to:
  /// **'Bridal Shower'**
  String get categoryBridalShower;

  /// No description provided for @categoryGenderReveal.
  ///
  /// In en, this message translates to:
  /// **'Gender Reveal'**
  String get categoryGenderReveal;

  /// No description provided for @categoryBaptism.
  ///
  /// In en, this message translates to:
  /// **'Baptism'**
  String get categoryBaptism;

  /// No description provided for @categoryChildDedication.
  ///
  /// In en, this message translates to:
  /// **'Child Dedication'**
  String get categoryChildDedication;

  /// No description provided for @categoryFirstCommunion.
  ///
  /// In en, this message translates to:
  /// **'First Communion'**
  String get categoryFirstCommunion;

  /// No description provided for @categoryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get categoryConfirmation;

  /// No description provided for @categoryBarMitzvah.
  ///
  /// In en, this message translates to:
  /// **'Bar Mitzvah'**
  String get categoryBarMitzvah;

  /// No description provided for @categoryBatMitzvah.
  ///
  /// In en, this message translates to:
  /// **'Bat Mitzvah'**
  String get categoryBatMitzvah;

  /// No description provided for @categoryReligiousCelebration.
  ///
  /// In en, this message translates to:
  /// **'Religious Celebration'**
  String get categoryReligiousCelebration;

  /// No description provided for @categoryChristmas.
  ///
  /// In en, this message translates to:
  /// **'Christmas'**
  String get categoryChristmas;

  /// No description provided for @categoryEaster.
  ///
  /// In en, this message translates to:
  /// **'Easter'**
  String get categoryEaster;

  /// No description provided for @categoryNewYear.
  ///
  /// In en, this message translates to:
  /// **'New Year'**
  String get categoryNewYear;

  /// No description provided for @categoryThanksgiving.
  ///
  /// In en, this message translates to:
  /// **'Thanksgiving'**
  String get categoryThanksgiving;

  /// No description provided for @categoryHalloween.
  ///
  /// In en, this message translates to:
  /// **'Halloween'**
  String get categoryHalloween;

  /// No description provided for @categoryValentinesDay.
  ///
  /// In en, this message translates to:
  /// **'Valentine\'s Day'**
  String get categoryValentinesDay;

  /// No description provided for @categoryMothersDay.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Day'**
  String get categoryMothersDay;

  /// No description provided for @categoryFathersDay.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Day'**
  String get categoryFathersDay;

  /// No description provided for @categoryIndependenceDay.
  ///
  /// In en, this message translates to:
  /// **'Independence Day'**
  String get categoryIndependenceDay;

  /// No description provided for @categoryStPatricksDay.
  ///
  /// In en, this message translates to:
  /// **'St. Patrick\'s Day'**
  String get categoryStPatricksDay;

  /// No description provided for @categoryGraduation.
  ///
  /// In en, this message translates to:
  /// **'Graduation'**
  String get categoryGraduation;

  /// No description provided for @categoryRetirement.
  ///
  /// In en, this message translates to:
  /// **'Retirement'**
  String get categoryRetirement;

  /// No description provided for @categoryPromotion.
  ///
  /// In en, this message translates to:
  /// **'Promotion'**
  String get categoryPromotion;

  /// No description provided for @categoryCongratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get categoryCongratulations;

  /// No description provided for @categoryAchievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get categoryAchievement;

  /// No description provided for @categoryCorporateEvent.
  ///
  /// In en, this message translates to:
  /// **'Corporate Event'**
  String get categoryCorporateEvent;

  /// No description provided for @categoryOfficeParty.
  ///
  /// In en, this message translates to:
  /// **'Office Party'**
  String get categoryOfficeParty;

  /// No description provided for @categoryHousewarming.
  ///
  /// In en, this message translates to:
  /// **'Housewarming'**
  String get categoryHousewarming;

  /// No description provided for @categoryWelcomeParty.
  ///
  /// In en, this message translates to:
  /// **'Welcome Party'**
  String get categoryWelcomeParty;

  /// No description provided for @categoryFarewellParty.
  ///
  /// In en, this message translates to:
  /// **'Farewell Party'**
  String get categoryFarewellParty;

  /// No description provided for @categorySympathy.
  ///
  /// In en, this message translates to:
  /// **'Sympathy'**
  String get categorySympathy;

  /// No description provided for @categoryMemorial.
  ///
  /// In en, this message translates to:
  /// **'Memorial'**
  String get categoryMemorial;

  /// No description provided for @categoryCustomDesign.
  ///
  /// In en, this message translates to:
  /// **'Custom Design'**
  String get categoryCustomDesign;

  /// No description provided for @categoryGeneralCelebration.
  ///
  /// In en, this message translates to:
  /// **'General Celebration'**
  String get categoryGeneralCelebration;

  /// No description provided for @customOrder.
  ///
  /// In en, this message translates to:
  /// **'Custom Order'**
  String get customOrder;

  /// No description provided for @placeCustomOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Custom Order'**
  String get placeCustomOrder;

  /// No description provided for @orderCustomCake.
  ///
  /// In en, this message translates to:
  /// **'Order Custom Cake'**
  String get orderCustomCake;

  /// No description provided for @cakeType.
  ///
  /// In en, this message translates to:
  /// **'Cake Type'**
  String get cakeType;

  /// No description provided for @selectCakeType.
  ///
  /// In en, this message translates to:
  /// **'Select cake type'**
  String get selectCakeType;

  /// No description provided for @cakeSize.
  ///
  /// In en, this message translates to:
  /// **'Cake Size'**
  String get cakeSize;

  /// No description provided for @selectCakeSize.
  ///
  /// In en, this message translates to:
  /// **'Select cake size'**
  String get selectCakeSize;

  /// No description provided for @cakeFlavor.
  ///
  /// In en, this message translates to:
  /// **'Flavor'**
  String get cakeFlavor;

  /// No description provided for @selectFlavor.
  ///
  /// In en, this message translates to:
  /// **'Select flavor'**
  String get selectFlavor;

  /// No description provided for @eventDate.
  ///
  /// In en, this message translates to:
  /// **'Event Date'**
  String get eventDate;

  /// No description provided for @selectEventDate.
  ///
  /// In en, this message translates to:
  /// **'Select event date'**
  String get selectEventDate;

  /// No description provided for @cakeDescription.
  ///
  /// In en, this message translates to:
  /// **'Cake Description'**
  String get cakeDescription;

  /// No description provided for @describeYourCake.
  ///
  /// In en, this message translates to:
  /// **'Describe your cake design, colors, decorations, or any special requirements...'**
  String get describeYourCake;

  /// No description provided for @enterDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter delivery address'**
  String get enterDeliveryAddress;

  /// No description provided for @deliveryType.
  ///
  /// In en, this message translates to:
  /// **'Delivery Type'**
  String get deliveryType;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @preferredDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred Delivery Time'**
  String get preferredDeliveryTime;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning (8 AM - 12 PM)'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon (12 PM - 5 PM)'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening (5 PM - 8 PM)'**
  String get evening;

  /// No description provided for @estimatedBudget.
  ///
  /// In en, this message translates to:
  /// **'Estimated Budget (FCFA)'**
  String get estimatedBudget;

  /// No description provided for @enterBudget.
  ///
  /// In en, this message translates to:
  /// **'Enter estimated budget'**
  String get enterBudget;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @anyOtherInformation.
  ///
  /// In en, this message translates to:
  /// **'Any other information we should know...'**
  String get anyOtherInformation;

  /// No description provided for @smallCake.
  ///
  /// In en, this message translates to:
  /// **'Small (1-5 people)'**
  String get smallCake;

  /// No description provided for @mediumCake.
  ///
  /// In en, this message translates to:
  /// **'Medium (6-15 people)'**
  String get mediumCake;

  /// No description provided for @largeCake.
  ///
  /// In en, this message translates to:
  /// **'Large (16-30 people)'**
  String get largeCake;

  /// No description provided for @extraLargeCake.
  ///
  /// In en, this message translates to:
  /// **'Extra Large (30+ people)'**
  String get extraLargeCake;

  /// No description provided for @customOrderSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Custom order submitted successfully!'**
  String get customOrderSubmitted;

  /// No description provided for @weWillContactYou.
  ///
  /// In en, this message translates to:
  /// **'We will contact you within 2-4 hours to confirm your order details and provide a final quote.'**
  String get weWillContactYou;

  /// No description provided for @accountCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'A new account has been created for you. You can use \"Forgot Password\" to set your password.'**
  String get accountCreatedMessage;

  /// No description provided for @orderLinkedToAccount.
  ///
  /// In en, this message translates to:
  /// **'Your order has been linked to your existing account.'**
  String get orderLinkedToAccount;

  /// No description provided for @cakeDetails.
  ///
  /// In en, this message translates to:
  /// **'Cake Details'**
  String get cakeDetails;

  /// No description provided for @deliveryInformation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Information'**
  String get deliveryInformation;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @submitOrder.
  ///
  /// In en, this message translates to:
  /// **'Submit Order'**
  String get submitOrder;
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
      'that was used.');
}
