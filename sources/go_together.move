// Módulo principal para la app de car pooling
module go_together::app {

    use std::string::String;
    use sui::vec_set::{Self, VecSet};

    // --- Estructuras ---

    // Objeto para identificar a un conductor
    public struct Conductor has key, store {
        id: UID,
        nombre: String,
        coche: String,
        disponible: bool,
        propietario: address, // Dirección del usuario que registró al conductor
    }

    // Registro global de conductores, guardando sus direcciones
    public struct RegistroConductores has key, store {
        id: UID,
        conductores_registrados: VecSet<address>,
        total_conductores: u64,
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

    // Crear el registro global (se llama una vez)
    public fun crear_registro(ctx: &mut TxContext): RegistroConductores {
        let registro = RegistroConductores {
            id: object::new(ctx),
            conductores_registrados: vec_set::empty(),
            total_conductores: 0,
        };
        registro
    }

    // Función pública para validar si un usuario está registrado como conductor
    public fun esta_conductor_registrado(registro: &RegistroConductores, user: address): bool {
        registro.conductores_registrados.contains(&user)
    }

    public fun eliminar_registro(registro: RegistroConductores) {
        let RegistroConductores { id, conductores_registrados: _, total_conductores: _ } = registro;
        id.delete();
    }   

    // Crear un nuevo conductor, disponible para recibir viajes
    #[allow(lint(self_transfer))]
    public fun registrar_conductor(registro: &mut RegistroConductores, nombre: String, coche: String, ctx: &mut TxContext) {
        let propietario = tx_context::sender(ctx);

        // Validar que el conductor no esté ya registrado
        assert!(!registro.conductores_registrados.contains(&propietario), 1);

        let conductor = Conductor {
            id: object::new(ctx),
            nombre,
            coche,
            disponible: true,
            propietario
        };

        // Añadir el propietario al conjunto de conductores registrados
        registro.conductores_registrados.insert(propietario);
        registro.total_conductores = registro.total_conductores + 1;

        // Transferir conductor al propietario
        transfer::transfer(conductor, propietario);
    }

    // Crear un nuevo pasajero
    #[allow(lint(self_transfer))]
    public fun registrar_pasajero(nombre: String, ctx: &mut TxContext) {
        let pasajero = Pasajero {
            id: object::new(ctx),
            nombre,
        };
        transfer::transfer(pasajero, tx_context::sender(ctx));
    }

    // Reservar un viaje: el pasajero elige un conductor disponible
    #[allow(lint(self_transfer))]
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
        let viaje = crear_viaje(conductor, pasajero, origen, destino, ctx);

        transfer::transfer(viaje, tx_context::sender(ctx));
    }

    // Finalizar un viaje, liberando al conductor
    public fun finalizar_viaje(viaje: &mut Viaje, conductor: &mut Conductor) {
        // Marcar viaje como inactivo
        viaje.activo = false;

        // Liberar conductor para nuevos viajes
        conductor.disponible = true;
    }

    // Función para consultar si un conductor está disponible
    public fun esta_disponible(conductor: &Conductor): bool {
        conductor.disponible
    }

    // Función para actualizar la disponibilidad de un conductor
    public fun actualizar_disponibilidad_conductor(conductor: &mut Conductor, disponible: bool) {
        conductor.disponible = disponible;
    }

    // Función para crear un viaje público, devolviendo el objeto para que el caller lo transfiera
    public fun crear_viaje(
        conductor: &mut Conductor,
        pasajero: &Pasajero,
        origen: String,
        destino: String,
        ctx: &mut TxContext
    ): Viaje {
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
        viaje
    }

    // Función para consultar si un viaje está activo
    public fun esta_activo(viaje: &Viaje): bool {
        viaje.activo
    }
}