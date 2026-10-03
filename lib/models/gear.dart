class Gear {
  Gear({required this.name, required this.type});

  String name;
  String type; // sama seperti Activity.type: Lari / Sepeda / Jalan Kaki

  Map<String, dynamic> toJson() => {'name': name, 'type': type};

  factory Gear.fromJson(Map<String, dynamic> json) => Gear(
    name: json['name'] as String,
    type: json['type'] as String,
  );
}
