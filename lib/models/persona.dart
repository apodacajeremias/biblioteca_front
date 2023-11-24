class Persona {
    final String id;
    final DateTime fechaCreacion;
    final String documentoIdentidad;
    final bool activo;
    final String nombre;

    Persona({
        required this.id,
        required this.fechaCreacion,
        required this.documentoIdentidad,
        required this.activo,
        required this.nombre,
    });

    factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        id: json["id"],
        fechaCreacion: DateTime.parse(json["fechaCreacion"]),
        documentoIdentidad: json["documentoIdentidad"],
        activo: json["activo"],
        nombre: json["nombre"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "fechaCreacion": fechaCreacion.toIso8601String(),
        "documentoIdentidad": documentoIdentidad,
        "activo": activo,
        "nombre": nombre,
    };
}
