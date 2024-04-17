class Call {
  String? callerId;
  String? callerName;
  String? receiverId;
  String? receiverName;
  String? channelId;
  String? label;
  bool? hasDialed;
  Call(
      {this.callerId,
      this.callerName,
      this.receiverId,
      this.receiverName,
      this.label,
      this.channelId,
      this.hasDialed});
  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = {};
    callMap["caller_id"] = call.callerId;
    callMap["caller_name"] = call.callerName;
    callMap["receiver_name"] = call.receiverName;
    callMap["receiver_id"] = call.receiverId;
    callMap["channel_id"] = call.channelId;
    callMap["has_dialed"] = call.hasDialed;
    callMap["label"] = call.label;
    return callMap;
  }

  Call.fromMap(Map callMap) {
    callerId = callMap['caller_id'];
    callerName = callMap['caller_name'];
    receiverName = callMap['receiver_name'];
    receiverId = callMap['receiver_id'];
    channelId = callMap['channel_id'];
    hasDialed = callMap['has_dialed'];
    label = callMap['label'];
  }
}
