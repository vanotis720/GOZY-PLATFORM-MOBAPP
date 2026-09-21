enum SplashScreen {
  guestHome,
  resetPassword,
  stepFinal,
  userRoleChanger,
  login,
  signup,
  viewMessage,
  editProfile,
  homeItemDetail,
  getStarted
}

abstract class SplashNavigator {
  void navigateScreen(SplashScreen screen, Map<String, dynamic> param) {}

}