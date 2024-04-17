class OnBoarding {
  final String title;
  final String image;
  final String subtitle;
  OnBoarding({
    required this.title,
    required this.image,
    required this.subtitle
  });
}

List<OnBoarding> onboardingContents = [
  OnBoarding(
    title: 'Welcome to Seegle',
    subtitle: 'Get video help from experts around the world, or answer calls and become an expert yourself!',
    image: 'assets/icon/seegle_logo_with_words.png',
  ),
  OnBoarding(
    title: 'This is the Home page.',
    subtitle: 'This is where you go to get answers to your questions. Click on a category, select the difficulty level of the question you\'re asking, and try to get connected with a random expert around the world!',
    image: 'assets/images/IMG_1787.PNG',
  ),
  OnBoarding(
    title: 'This is the Squawks page',
    subtitle: 'From here you can return your fellow Seeglers\' questions. See a question you can answer? Give the user a call back!',
    image: 'assets/images/IMG_1789.PNG',
  ),
  OnBoarding(
    title: 'This is your Profile page',
    image: 'assets/images/IMG_1788 2.PNG',
    subtitle: 'This is where you can set your preferences, including what categories YOU want to answer calls in. This is what makes the whole operation possible! Without the help of Seeglers\' like yourself, no calls can get answered.'
  ),
];