import 'package:flutter/material.dart';
import 'package:seegle/widgets/squawk_listener.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    // var username = userProvider.user?.username ?? "No username available";

    return Scaffold(
      body: Center(
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Container(
                      color: Color(0xffffffff),
                      child: SquawkListWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
