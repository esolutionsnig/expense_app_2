class Beneficiary {
  int id;
  String surname;
  String firstname;

  // Constructor
  Beneficiary(int id, String surname, String firstname) {
    this.id = id;
    this.surname = surname;
    this.firstname = firstname;
  }

  Beneficiary.fromJson(Map json)
      : id = json['id'],
        surname = json['surname'],
        firstname = json['firstname'];

  Map toJson() {
    return {'id': id, 'surname': surname, 'firstname': firstname};
  }
}
