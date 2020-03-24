class Department {
  int id;
  String name;
  int hod;

  // Constructor
  Department(int id, String name, int hod) {
    this.id = id;
    this.name = name;
    this.hod = hod;
  }

  Department.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        hod = json['hod'];

  Map toJson() {
    return {'id': id, 'name': name, 'hod': hod};
  }
}
