class NotificationBody {
  String? title;
  String? body;
  int? orderId;
  String? type;
  String? image;
  String? userName;

  NotificationBody(
      {this.title, this.body, this.orderId, this.type, this.image, this.userName});

  NotificationBody.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
    type = json['type'];
    image = json['user_image'];
    userName = json['user_name'];
    orderId = int.tryParse(json['order_id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    data['type'] = type;
    data['user_image'] = image;
    data['user_name'] = userName;
    data['order_id'] = type;
    return data;
  }
}
