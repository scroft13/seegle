import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seegle/models/call.dart';

class CallMethods{
  final CollectionReference callCollection = 
    FirebaseFirestore.instance.collection("call");
  final CollectionReference groupNotification = 
    FirebaseFirestore.instance.collection("groupNotification");

  Future<bool> makeCall({required Call call}) async {
    try {
      call.hasDialed = true;
    Map<String, dynamic> hasDialedMap = call.toMap(call);
    call.hasDialed = false;
    Map<String, dynamic> hasNotDialedMap = call.toMap(call);
    await callCollection.doc(call.callerId).set(hasDialedMap);
    await callCollection.doc(call.receiverId).set(hasNotDialedMap);
    return true;
    } catch (e) {
      return false;
    }
    
  }
  Future<bool> makeGroupCall({required Call call, required String dbCategory, required String subcategory, required String topic, required String label}) async {
    try {
    await groupNotification.doc(call.callerId).set({
      "caller_id": call.callerId,
      "caller_name": call.callerName,
      "category": dbCategory,
      "subcategory": subcategory,
      "topic": topic,
      "label": label,
    });
    return true;
    } catch (e) {
      return false;
    }
    
  }

  Future<bool> endCall({required Call call}) async {
      try {
        await callCollection.doc(call.callerId).delete();
        await callCollection.doc(call.receiverId).delete();
        await groupNotification.doc(call.callerId).delete();
        return true;
      }
      catch (e){
        return false;
      }
  }
}