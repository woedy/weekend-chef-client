class CartItemDetailsModel {
  String? message;
  Data? data;

  CartItemDetailsModel({this.message, this.data});

  CartItemDetailsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? dish;
  int? quantity;
  String? specialNotes;
  List<Customizations>? customizations;
  int? totalPrice;

  Data(
      {this.id,
      this.dish,
      this.quantity,
      this.specialNotes,
      this.customizations,
      this.totalPrice});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dish = json['dish'];
    quantity = json['quantity'];
    specialNotes = json['special_notes'];
    if (json['customizations'] != null) {
      customizations = <Customizations>[];
      json['customizations'].forEach((v) {
        customizations!.add(new Customizations.fromJson(v));
      });
    }
    totalPrice = json['total_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['dish'] = this.dish;
    data['quantity'] = this.quantity;
    data['special_notes'] = this.specialNotes;
    if (this.customizations != null) {
      data['customizations'] =
          this.customizations!.map((v) => v.toJson()).toList();
    }
    data['total_price'] = this.totalPrice;
    return data;
  }
}

class Customizations {
  String? customizationOption;
  int? quantity;

  Customizations({this.customizationOption, this.quantity});

  Customizations.fromJson(Map<String, dynamic> json) {
    customizationOption = json['customization_option'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customization_option'] = this.customizationOption;
    data['quantity'] = this.quantity;
    return data;
  }
}
