import 'package:flutter/material.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: const Center(
        child: Text(
            " Effective Date: April 13, 2025 /n Seegle LLC (“Seegle”, “we”, “our”, or “us”) is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our services. By accessing or using Seegle, you agree to the terms of this Privacy Policy. If you do not agree, please do not use the service. ⸻ 1. Information We Collect a. Personal Information We may collect personal data you voluntarily provide, such as: •	Your name •	Email address •	Username or profile information •	Contact information b. Usage Data Automatically collected data includes: •	IP address•	Browser type •	Device information •	Pages visited •	Time and date of visits c. Third-Party Sign-Ins If you sign in using services like Google, Apple, or Facebook, we may receive basic profile information from them. ⸻ 2. How We Use Your Information We use your information to:•	Operate and maintain Seegle •	Personalize your experience •	Communicate with you (e.g., notifications or updates) •	Improve our service •	Prevent fraud and ensure security ⸻ 3. Sharing Your Information We do not sell your data. We may share information with: •	Service providers working on our behalf •	Legal authorities when required by law •	Other users (only the data you intentionally share) ⸻ 4. Cookies & Analytics We use cookies to remember your preferences and improve your experience. We may use Google Analytics or similar tools to understand how users interact with Seegle. You can disable cookies in your browser if you prefer. ⸻ 5. Data Security We use reasonable security measures to protect your data. However, no system is 100% secure. ⸻ 6. Children’s Privacy Seegle is not intended for users under 13. We do not knowingly collect personal data from children. If we become aware of such data, we will delete it. ⸻ 7. Your Rights Depending on your location, you may have rights to access, correct, or delete your personal data. Contact us to exercise your rights. 8. Changes to This Policy We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated effective date. 9. Contact Us If you have questions about this Privacy Policy, contact us at: 📧 privacy@seegle.app📬 Seegle LLC, 2364 Bristol RD, Bristol, VT 05443"),
      ),
    );
  }
}
