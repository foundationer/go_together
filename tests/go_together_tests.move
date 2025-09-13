
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

    scenario.next_tx(user);
    {
        app::registrar_conductor(string::utf8(b"Juan"), string::utf8(b"Toyota"), scenario.ctx());
    };

    scenario.end();
}

// Test para registrar pasajero
#[test]
fun test_registrar_pasajero() {
    let user = @0xAD;

    let mut scenario = test_scenario::begin(user);

    scenario.next_tx(user);
    {
        app::registrar_pasajero(string::utf8(b"Ana"), scenario.ctx());
    };

    scenario.end();
}

