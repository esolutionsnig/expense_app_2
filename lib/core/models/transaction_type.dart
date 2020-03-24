class TransactionType {
  int id;
  String name;

  // Constructor
  TransactionType(int id, String name) {
    this.id = id;
    this.name = name;
  }

  TransactionType.fromJson(Map json)
      : id = json['id'],
        name = json['name'];

  Map toJson() {
    return {'id': id, 'name': name};
  }

}
