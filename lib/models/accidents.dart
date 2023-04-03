class Accidents {
  final id;
  final nbr_totale_accidents;
  final nbr_jours_sans_accident;
    final message;

  final name;
  final createdAt;
  final updatedAt;

  Accidents({
    required this.id,
    required this.nbr_jours_sans_accident,
    required this.nbr_totale_accidents,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.message
  });

  factory Accidents.fromJson(Map<String, dynamic> data) {
    return Accidents(
        id: data["_id"],
        nbr_totale_accidents: data["nbr_totale_accidents"],
        nbr_jours_sans_accident: data["nbr_jours_sans_accident"],
        name: data["name"],
        message: data["message"],
        createdAt: data["createdAt"],
        updatedAt: data["updatedAt"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = id;
    data['message'] = message;
    data['nbr_totale_accidents'] = nbr_totale_accidents;
    data['nbr_jours_sans_accident'] = nbr_jours_sans_accident;
    data["name"] = name;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;

    return data;
  }
}
