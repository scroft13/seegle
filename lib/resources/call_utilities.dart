import 'package:get/get.dart';
import 'package:seegle/models/call.dart';
import 'package:seegle/models/call_user.dart';
import 'package:seegle/resources/call_methods.dart';
import 'package:seegle/screens/call%20screens/call_screen.dart';
// import 'package:seegle/video_test.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({required CallUser from, required CallUser to, context}) async {
    Call call = Call(
      callerId: from.id,
      callerName: from.username,
      receiverName: to.username,
      receiverId: to.id,
      channelId: from.username,
    );
    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialed = true;

    if (callMade) {
      Get.to(() => {}
          // () => JoinChannelVideo(
          //     channelId: call.callerId.toString(),
          //     call: call,
          //     needsSquawkLink: false,
          //     answeringReturnedCall: false,
          //     isHero: true,
          //     isSquawker: false,
          //     ),
          );
    }
  }

  static groupDial(
      {required CallUser from,
      required String topic,
      required String dbCategory,
      required String subcategory,
      required String label,
      context}) async {
    Call call = Call(
        callerId: from.id,
        callerName: from.username,
        channelId: topic,
        label: label);
    bool callMade = await callMethods.makeGroupCall(
        call: call,
        dbCategory: dbCategory,
        subcategory: subcategory,
        topic: topic,
        label: label);

    call.hasDialed = true;

    if (callMade) {
      Get.to(() => {}
          //  JoinChannelVideo(
          //     channelId: call.callerId.toString(),
          //     call: call,
          //     dbCategory: dbCategory,
          //     subcategory: subcategory,
          //     label: label,
          //     needsSquawkLink: true,
          //     answeringReturnedCall: false,
          //     isHero: false,
          //     isSquawker: true,
          //     ),
          );
    }
  }
}
