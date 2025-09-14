
#[test_only]
module go_together::go_together_tests;

use go_together::app;
use sui::test_scenario;
use std::string;

// Test para registrar un conductor
#[test]
fun test_registrar_conductor() {
    // Llamamos a la función pública para registrar conductor
    // No podemos validar el objeto directamente, pero si no hay error es exitoso.
    let user = @0xAD;

    let mut scenario = test_scenario::begin(user);
    let mut registro = app::crear_registro(scenario.ctx());

    scenario.next_tx(user);
    {
        let conductor = app::crear_conductor(string::utf8(b"Juan"), string::utf8(b"Toyota"), scenario.ctx());
        app::registrar_conductor(&mut registro, conductor);
        let esta = go_together::app::esta_conductor_registrado(&registro, user);
        assert!(esta, 100);
        app::eliminar_registro(registro);
    };

    scenario.end();
}

// Test para registrar pasajero
#[test]
fun test_registrar_pasajero() {
    let user = @0xAD;

    let mut scenario = test_scenario::begin(user);
    let mut registro = app::crear_registro_pasajeros(scenario.ctx());

    scenario.next_tx(user);
    {
        app::registrar_pasajero(&mut registro, string::utf8(b"Ana"), scenario.ctx());
        let esta = go_together::app::esta_pasajero_registrado(&registro, user);
        assert!(esta, 100);
    };

    app::eliminar_registro_pasajeros(registro);
    scenario.end();
}

#[test]
fun test_reservar_viaje() {
    let conductor_addr = @0xAD;
    let pasajero_addr = @0xAE;

    let mut scenario = test_scenario::begin(conductor_addr);
    let mut registro_conductores = app::crear_registro(scenario.ctx());
    let mut registro_pasajeros = app::crear_registro_pasajeros(scenario.ctx());

    // Registrar conductor
    let conductor = app::crear_conductor(string::utf8(b"Juan"), string::utf8(b"Toyota"), scenario.ctx());
    app::registrar_conductor(&mut registro_conductores, conductor);

    scenario.next_tx(pasajero_addr);
    {
        // Registrar pasajero
        app::registrar_pasajero(&mut registro_pasajeros, string::utf8(b"Ana"), scenario.ctx());
        
        // Verificar que el pasajero se registró correctamente
        let esta_pasajero = app::esta_pasajero_registrado(&registro_pasajeros, pasajero_addr);
        assert!(esta_pasajero, 100);
    };

    // Cambiar al conductor para crear el viaje
    scenario.next_tx(conductor_addr);
    {
        // Obtener el conductor del escenario
        let mut conductor_obj = scenario.take_from_sender<app::Conductor>();
        
        // Obtener el pasajero del escenario
        scenario.next_tx(pasajero_addr);
        let pasajero_obj = scenario.take_from_sender<app::Pasajero>();
        
        // Cambiar de vuelta al conductor para crear el viaje
        scenario.next_tx(conductor_addr);
        
        // Crear un viaje vacío
        let mut viaje = app::crear_viaje_vacio(
            string::utf8(b"Madrid"),
            string::utf8(b"Barcelona"),
            scenario.ctx()
        );
        
        // Usar la función reservar_viaje para reservar el viaje
        app::reservar_viaje(
            &mut viaje,
            &mut conductor_obj,
            &pasajero_obj
        );
        
        // Verificar que el conductor no está disponible después de reservar el viaje
        let conductor_disponible = app::esta_disponible(&conductor_obj);
        assert!(!conductor_disponible, 101);
        
        // Verificar que el viaje está activo
        let viaje_activo = app::esta_activo(&viaje);
        assert!(viaje_activo, 102);
        
        // Finalizar el viaje
        app::finalizar_viaje(&mut viaje, &mut conductor_obj);
        
        // Verificar que el conductor vuelve a estar disponible después de finalizar el viaje
        let conductor_disponible_despues = app::esta_disponible(&conductor_obj);
        assert!(conductor_disponible_despues, 103);
        
        // Verificar que el viaje ya no está activo después de finalizarlo
        let viaje_activo_despues = app::esta_activo(&viaje);
        assert!(!viaje_activo_despues, 104);
        
        // Transferir objetos de vuelta usando transfer::public_transfer
        transfer::public_transfer(conductor_obj, conductor_addr);
        transfer::public_transfer(viaje, conductor_addr);
        transfer::public_transfer(pasajero_obj, pasajero_addr);
    };

    app::eliminar_registro_pasajeros(registro_pasajeros);
    app::eliminar_registro(registro_conductores);
    scenario.end();
}