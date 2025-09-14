# Script de Ejemplo - Go Together 🚗

Este directorio contiene un script bash de ejemplo que demuestra cómo usar el CLI de Sui para interactuar con el módulo Go Together.

## 📋 Prerrequisitos

Antes de ejecutar el script, asegúrate de tener:

1. **Sui CLI instalado**: Descárgalo desde [https://docs.sui.io/build/install](https://docs.sui.io/build/install)
2. **Conexión a la red**: El script funciona con testnet o devnet de Sui
3. **Fondos suficientes**: Necesitas SUI tokens para pagar las transacciones
4. **jq instalado**: Para procesar JSON (instalar con `sudo apt install jq` en Ubuntu/Debian)

## 🚀 Uso del Script

### Ejecución Básica

```bash
./ejemplo_uso.sh
```

### ¿Qué hace el script?

El script ejecuta una demostración completa del flujo de carpooling:

1. **Compilación**: Compila el proyecto Move
2. **Publicación**: Publica el módulo en la red de Sui
3. **Creación de Registros**: Crea los registros globales de conductores y pasajeros
4. **Registro de Conductor**: Crea y registra un conductor llamado "Juan Pérez" con un "Toyota Corolla 2020"
5. **Registro de Pasajero**: Crea y registra un pasajero llamado "María García"
6. **Creación de Viaje**: Crea un viaje del "Centro de la ciudad" al "Aeropuerto"
7. **Verificación de Estados**: Muestra el estado de conductor y viaje
8. **Finalización**: Finaliza el viaje y libera al conductor

## 📁 Archivos Generados

El script genera varios archivos temporales:

- `package_id.txt`: ID del paquete publicado
- `conductor_registry_id.txt`: ID del registro de conductores
- `passenger_registry_id.txt`: ID del registro de pasajeros
- `driver_id.txt`: ID del conductor creado
- `passenger_id.txt`: ID del pasajero creado
- `trip_id.txt`: ID del viaje creado
- `*.json`: Archivos JSON con detalles de las transacciones

## 🔧 Personalización

Puedes modificar el script para:

### Cambiar nombres y datos
```bash
# En la función main(), modifica estas líneas:
create_driver "Tu Nombre" "Tu Coche"
create_passenger "Nombre Pasajero"
create_trip "Origen" "Destino"
```

### Usar diferentes redes
```bash
# Antes de ejecutar, cambia la red:
sui client switch --env testnet
# o
sui client switch --env devnet
```

### Ajustar presupuesto de gas
```bash
# Modifica los valores --gas-budget en las llamadas sui client call
```

## 🐛 Solución de Problemas

### Error: "Sui CLI no está instalado"
```bash
# Instala Sui CLI
curl -fLJO https://github.com/MystenLabs/sui/releases/download/testnet-v1.18.0/sui-testnet-v1.18.0-ubuntu-x86_64.tgz
tar -xzf sui-testnet-v1.18.0-ubuntu-x86_64.tgz
sudo mv sui /usr/local/bin/
```

### Error: "jq no está instalado"
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# CentOS/RHEL
sudo yum install jq
```

### Error: "No se encontró Move.toml"
```bash
# Asegúrate de estar en el directorio correcto
cd /ruta/a/go_together
```

### Error de gas insuficiente
```bash
# Aumenta el presupuesto de gas en el script
# Busca --gas-budget y aumenta los valores
```

## 📊 Salida del Script

El script muestra información detallada con códigos de color:

- 🔵 **Azul**: Información general
- 🟢 **Verde**: Operaciones exitosas
- 🟡 **Amarillo**: Advertencias
- 🔴 **Rojo**: Errores

## 🔍 Verificación Manual

Después de ejecutar el script, puedes verificar los objetos creados:

```bash
# Ver conductor
sui client object <DRIVER_ID>

# Ver pasajero
sui client object <PASSENGER_ID>

# Ver viaje
sui client object <TRIP_ID>

# Ver registros
sui client object <REGISTRY_ID>
```

## 🧪 Casos de Uso Adicionales

### Crear múltiples conductores
```bash
# Modifica el script para crear varios conductores
create_driver "Conductor 1" "Coche 1"
create_driver "Conductor 2" "Coche 2"
```

### Crear múltiples viajes
```bash
# Crea varios viajes con diferentes rutas
create_trip "Punto A" "Punto B"
create_trip "Punto C" "Punto D"
```

### Simular viajes concurrentes
```bash
# Crea varios pasajeros y asigna viajes
create_passenger "Pasajero 1"
create_passenger "Pasajero 2"
```

## 📝 Notas Importantes

1. **Costo**: Cada transacción consume gas, asegúrate de tener fondos suficientes
2. **Red**: El script usa la red activa configurada en tu cliente Sui
3. **Objetos**: Los objetos creados son tuyos y puedes transferirlos o eliminarlos
4. **Limpieza**: El script ofrece limpiar archivos temporales al final

## 🤝 Contribuir

Si encuentras problemas o quieres mejorar el script:

1. Abre un issue en el repositorio
2. Envía un pull request con tus mejoras
3. Documenta cualquier cambio en este README

---

**¡Disfruta explorando el mundo del carpooling descentralizado! 🚗💨**
