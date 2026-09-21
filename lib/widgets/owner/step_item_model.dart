class StepItemModel {
  String? image;
  num? id;
  String? itemValue;
  String? itemName;
  dynamic dynamicItemName;
  String? itemReference;

  StepItemModel({this.image, this.id, this.itemName,this.dynamicItemName,this.itemValue,this.itemReference,});

  StepItemModel.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    id = json['id'];
    itemName = json['itemName'];
    dynamicItemName = json['dynamicItemName'];
    itemValue = json['itemValue'];
    itemReference = json['itemReference'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['id'] = this.id;
    data['itemName'] = this.itemName;
    data['dynamicItemName'] = this.dynamicItemName;
    data['itemValue'] = this.itemValue;
    data['itemReference'] = this.itemReference;
    return data;
  }

}


class DynamicLanguageItemModel {
  num? id;
  String? itemValue;
  String? itemName;
  String? itemReference;
  String? itemTitle;
  String? itemDesc;

  DynamicLanguageItemModel({ this.id, this.itemName,this.itemValue,this.itemReference,this.itemTitle,this.itemDesc});

  DynamicLanguageItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemName = json['itemName'];
    itemValue = json['itemValue'];
    itemReference = json['itemReference'];
    itemTitle = json['itemTitle'];
    itemDesc = json['itemDesc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['itemName'] = this.itemName;
    data['itemValue'] = this.itemValue;
    data['itemReference'] = this.itemReference;
    data['itemTitle'] = this.itemTitle;
    data['itemDesc'] = this.itemDesc;
    return data;
  }

}