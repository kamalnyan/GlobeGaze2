enum Type { text, image }

class Message {
  String fromId;
  String msg;
  String read;
  String sent;
  String toId;
  Type type; // Changed from late String to Type enum

  Message({
    required this.fromId,
    required this.msg,
    required this.read,
    required this.sent,
    required this.toId,
    required this.type,
  });

  // Factory constructor to create a Message instance from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      fromId: json['fromId'].toString(),
      msg: json['msg'].toString(),
      read: json['read'].toString(),
      sent: json['sent'].toString(),
      toId: json['toId'].toString(),
      // Check the value of 'type' in the JSON and map it to the appropriate enum value
      type: json['type'] == 'image' ? Type.image : Type.text,
    );
  }

  // Method to convert a Message instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'fromId': fromId,
      'msg': msg,
      'read': read,
      'sent': sent,
      'toId': toId,
      'type': type == Type.image ? 'image' : 'text',
    };
  }
}
