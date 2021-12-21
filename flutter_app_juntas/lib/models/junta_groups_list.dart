class JuntaGroupsList{
  String id;
  String id_creator;
  String name_junta;
  String create_date;
  String get Id {
    return id;
  }
  String get Id_creator{
    return id_creator;
  }
  String get Create_date{
    return create_date;
  }
  String get Name_junta {
    return name_junta;
  }

  JuntaGroupsList(this.id,this.name_junta, this.id_creator, this.create_date);


}

class Notificacion{
  String id;
  String id_creator;
  String name_junta;
  String create_date;
  String idNotif;
  String get Id {
    return id;
  }
  String get Id_creator{
    return id_creator;
  }
  String get Create_date{
    return create_date;
  }
  String get Name_junta {
    return name_junta;
  }

  String get Id_notif {
    return idNotif;
  }

  Notificacion(this.id,this.name_junta, this.id_creator, this.create_date, this.idNotif);

  
}