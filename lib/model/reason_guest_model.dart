class ReasonGuestsModel {
  final int id;
  final String itemValue;
  final String itemName;
  final String label;

  ReasonGuestsModel({
    required this.id,
    required this.itemValue,
    required this.itemName,
    required this.label,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "itemValue": itemValue,
      "itemName": itemName,
      "label": label,
    };
  }
}