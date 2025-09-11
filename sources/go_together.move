// Módulo principal para la app de car pooling
module go_together::app {

    use std::string::String;

    // --- Estructuras ---

    // Objeto para identificar a un conductor
    public struct Conductor has key, store {
        id: UID,
        nombre: String,
        coche: String,
        disponible: bool,
    }

    // Objeto para identificar a un pasajero
    public struct Pasajero has key, store {
        id: UID,
        nombre: String,
    }

    // Estructura para un viaje reservado
    public struct Viaje has key, store {
        id: UID,
        conductor_nombre: String,
        pasajero_nombre: String,
        origen: String,
        destino: String,
        activo: bool,
    }

    // --- Funciones ---

    // Crear un nuevo conductor, disponible para recibir viajes
    public fun registrar_conductor(nombre: String, coche: String, ctx: &mut TxContext) {
        let conductor = Conductor {
            id: object::new(ctx),
            nombre,
            coche,
            disponible: true,
        };
        transfer::transfer(conductor, tx_context::sender(ctx));
    }

    // Crear un nuevo pasajero
    public fun registrar_pasajero(nombre: String, ctx: &mut TxContext) {
        let pasajero = Pasajero {
            id: object::new(ctx),
            nombre,
        };
        transfer::transfer(pasajero, tx_context::sender(ctx));
    }

    // Reservar un viaje: el pasajero elige un conductor disponible
    public fun reservar_viaje(
        conductor: &mut Conductor,
        pasajero: &Pasajero,
        origen: String,
        destino: String,
        ctx: &mut TxContext
    ) {
        // Verificar que el conductor esté disponible
        assert!(conductor.disponible, 1);

        // Marcar conductor como no disponible
        conductor.disponible = false;

        // Crear el viaje
        let viaje = Viaje {
            id: object::new(ctx),
            conductor_nombre: conductor.nombre,
            pasajero_nombre: pasajero.nombre,
            origen,
            destino,
            activo: true,
        };

        transfer::transfer(viaje, tx_context::sender(ctx));
    }

    // Finalizar un viaje, liberando al conductor
    public fun finalizar_viaje(viaje: &mut Viaje, conductor: &mut Conductor) {
        // Marcar viaje como inactivo
        viaje.activo = false;

        // Liberar conductor para nuevos viajes
        conductor.disponible = true;
    }
}