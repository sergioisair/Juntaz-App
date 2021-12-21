class JuntaInfo{
  String id;
  String name_junta;
  String code;
  double aporte;
  String aporte_day;
  String pago_day;
  double total_amount;
  String creator_email;
  String creator_phone;
  String creator_name;
  String id_creator;
  String create_date;
  String coin_type;
  int pendientes;
  String tipoJunta;
  var turno;
  String get Id {
    return id;
  }
  String get Name_junta {
    return name_junta;
  }
  String get Code{
    return code;
  }
  double get Aporte{
    return aporte;
  }
  String get Aporte_day{
    return aporte_day;
  }
  String get Pago_day{
    return pago_day;
  }
  double get Total_amount{
    return total_amount;
  }
  String get Creator_email {
    return creator_email;
  }
  String get Creator_phone {
    return creator_phone;
  }
  String get Creator_name{
    return creator_name;
  }
  String get Id_creator{
    return id_creator;
  }
  String get Create_date {
    return create_date;
  }
  String get Coin_type{
    return coin_type;
  }
  int get Turno{
    return turno;
  }
  JuntaInfo(this.id,this.name_junta,this.code, this.aporte, this.aporte_day, this.pago_day, this.total_amount, this.creator_email, this.creator_phone, this.create_date, this.creator_name, this.id_creator,this.coin_type,this.turno, this.pendientes, this.tipoJunta);
}