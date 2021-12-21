class User_{
  String id;
  String name;
  String apepat;
  String apemat;
  String tipdoc;
  String numdoc;
  String email;
  double total_amount;
  String telefono;
  String fecha_nac;
  bool notificar;
  /*
  String bd;
  String gender;
  String bio;
  String phone;
  String n_account;*/
  String get Id {
    return id;
  }
  String get Name {
    return name;
  }
  String get Apepat{
    return apepat;
  }
  String get Apemat{
    return apemat;
  }
  String get Tipdoc{
    return tipdoc;
  }
  String get Numdoc{
    return numdoc;
  }
  String get Email {
    return email;
  }
  double get Total_amount {
    return total_amount;
  }
  String get Telefono{
    return telefono;
  }

  String get Fecha_nac {
    return fecha_nac;
  }


  /*
  String get Bio {
    return bio;
  }
  String get Gender {
    return gender;
  }
  String get BD {
    return bd;
  }
  String get Phone {
    return phone;
  }
  String get N_account {
    return n_account;
  }*/
  User_(this.id,this.name,this.apepat, this.apemat, this.tipdoc, this.numdoc, this.email, this.total_amount,  this.fecha_nac, this.telefono, this.notificar);
}