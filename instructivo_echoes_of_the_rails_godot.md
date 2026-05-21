# Instructivo Técnico Completo para IA  
# Desarrollo del videojuego en Godot: **Echoes of the Rails**

## 1. Contexto del proyecto

**Echoes of the Rails** es una experiencia de simulación ferroviaria en realidad virtual donde el jugador asume el rol del último maquinista de una locomotora de vapor en una ruta montañosa cubierta por niebla.

El juego no se centra únicamente en conducir un tren, sino en la presión emocional de llegar a tiempo, administrar recursos limitados y mantener viva la conexión entre estaciones aisladas.

El jugador permanece dentro de la cabina de la locomotora y utiliza controles VR mediante puntero láser para manejar el regulador de vapor, el freno, el panel de suministros y el silbato.

---

## 2. Objetivo general del juego

Crear un videojuego en **Godot 4.x con soporte VR/OpenXR**, llamado **Echoes of the Rails**, donde el jugador debe:

- Conducir una locomotora de vapor sobre vías de montaña.
- Administrar el carbón como recurso limitado.
- Llegar a estaciones antes de que expire el temporizador.
- Recoger pasajeros si llega y se detiene correctamente.
- Desbloquear fragmentos narrativos o diarios de pasajeros.
- Comprar carbón con puntos obtenidos.
- Completar rutas consecutivas sin quedarse sin combustible.
- Evitar descarrilamientos por exceso de velocidad en curvas.

El juego debe transmitir una experiencia de **estrés tranquilo**, con tensión constante, pero sin volverse frustrante.

---

## 3. Objetivo medible del gameplay

El sistema debe permitir medir estos resultados:

```text
- Rutas completadas.
- Pasajeros transportados.
- Diarios desbloqueados.
- Estaciones visitadas.
- Estaciones completadas a tiempo.
- Porcentaje de puntualidad.
- Motivo de finalización de la partida.
```

Reglas principales:

```text
1. El jugador debe completar al menos 5 rutas consecutivas.
2. El carbón no debe llegar a cero.
3. En cada ruta debe llegar a tiempo al menos al 60% de estaciones activas.
4. Los diarios narrativos solo se desbloquean si llega antes de que expire el temporizador.
5. Al terminar la partida, se registran rutas, pasajeros y diarios desbloqueados.
```

---

## 4. Loop principal del juego

```text
1. El jugador inicia dentro de la cabina.
2. Revisa los instrumentos:
   - Carbón.
   - Presión.
   - Velocidad.
   - Tiempo restante para la próxima estación.
3. Usa el regulador de vapor para acelerar.
4. El tren avanza sobre un sistema de vías Path3D.
5. El carbón disminuye según velocidad y aceleración.
6. El jugador debe frenar antes de curvas peligrosas o estaciones.
7. Si llega a tiempo y se detiene correctamente:
   - Los pasajeros suben.
   - El jugador gana puntos.
   - Se puede desbloquear un diario narrativo.
8. Si llega tarde:
   - Los pasajeros se retiran.
   - La estación desaparece en la niebla.
   - Se pierde el diario narrativo.
9. El jugador puede usar puntos para comprar carbón.
10. Avanza al siguiente tramo.
11. Si el carbón llega a cero, termina la partida.
```

---

## 5. Filosofía de diseño

El juego debe tener una identidad clara:

```text
- Simulación ferroviaria en VR.
- Gestión de recursos.
- Tensión por el tiempo.
- Soledad del maquinista.
- Estética retro tipo PSX / Retro Realism.
- Audio diegético como guía narrativa.
- Interfaz integrada dentro de la cabina.
- Sin HUD flotante tradicional.
```

El jugador no debe sentir que controla un personaje tradicional. Debe sentir que **es el maquinista**, atrapado en la cabina, tomando decisiones importantes con cada movimiento del regulador y del freno.

---

## 6. Arquitectura general del proyecto

Usar una arquitectura modular basada en sistemas separados.

```text
EchoesOfTheRails/
│
├── scenes/
│   ├── main/
│   │   └── MainGame.tscn
│   ├── train/
│   │   ├── Train.tscn
│   │   ├── Cabin.tscn
│   │   ├── SteamRegulator.tscn
│   │   ├── BrakeLever.tscn
│   │   ├── CoalGauge.tscn
│   │   ├── PressureGauge.tscn
│   │   └── Whistle.tscn
│   ├── track/
│   │   ├── TrackPath.tscn
│   │   └── TrackSegment.tscn
│   ├── station/
│   │   ├── Station.tscn
│   │   ├── Platform.tscn
│   │   └── Passenger.tscn
│   ├── ui_diegetic/
│   │   ├── Dashboard.tscn
│   │   ├── AnalogNeedle.tscn
│   │   └── SupplyPanel.tscn
│   ├── vr/
│   │   ├── XROrigin.tscn
│   │   ├── VRController.tscn
│   │   └── LaserPointer.tscn
│   ├── audio/
│   │   ├── TrainAudioController.tscn
│   │   └── StationBell.tscn
│   └── environment/
│       ├── FogWorld.tscn
│       ├── MountainEnvironment.tscn
│       └── LowPolyForest.tscn
│
├── scripts/
│   ├── core/
│   │   ├── GameManager.gd
│   │   ├── GameStateMachine.gd
│   │   ├── SaveManager.gd
│   │   └── EventBus.gd
│   ├── train/
│   │   ├── TrainController.gd
│   │   ├── FuelSystem.gd
│   │   ├── BrakeSystem.gd
│   │   ├── PressureSystem.gd
│   │   └── DerailmentSystem.gd
│   ├── station/
│   │   ├── StationManager.gd
│   │   ├── Station.gd
│   │   ├── Passenger.gd
│   │   └── PassengerStateMachine.gd
│   ├── interaction/
│   │   ├── Interactable.gd
│   │   ├── LaserPointer.gd
│   │   ├── ButtonInteractable.gd
│   │   └── LeverInteractable.gd
│   ├── scoring/
│   │   ├── ScoreManager.gd
│   │   └── DiaryManager.gd
│   ├── ui/
│   │   ├── GaugeController.gd
│   │   ├── DashboardController.gd
│   │   └── SupplyPanel.gd
│   └── audio/
│       ├── AudioManager.gd
│       └── TrainAudioController.gd
│
├── resources/
│   ├── configs/
│   │   ├── TrainConfig.tres
│   │   ├── StationConfig.tres
│   │   └── GameBalanceConfig.tres
│   ├── diaries/
│   │   ├── diary_001.tres
│   │   ├── diary_002.tres
│   │   └── diary_003.tres
│   └── passengers/
│       └── PassengerData.tres
│
├── assets/
│   ├── models/
│   ├── textures/
│   ├── materials/
│   ├── shaders/
│   │   ├── psx_retro_shader.gdshader
│   │   ├── fog_dissolve_shader.gdshader
│   │   ├── steam_shader.gdshader
│   │   ├── coal_warning_emission_shader.gdshader
│   │   ├── dirty_glass_shader.gdshader
│   │   └── passenger_fade_shader.gdshader
│   └── audio/
│       ├── chugging_rhythm.wav
│       ├── wind_fog.wav
│       ├── whistle.wav
│       └── station_bell.wav
│
└── project.godot
```

---

# 7. Escenas principales

## 7.1 MainGame.tscn

```text
MainGame
├── GameManager
├── Environment
├── TrackPath
├── Train
├── StationManager
├── XROrigin
├── AudioManager
└── DirectionalLight
```

Responsabilidad:

```text
- Contener el mundo principal.
- Instanciar el tren.
- Instanciar las estaciones.
- Controlar el entorno.
- Conectar los sistemas principales.
```

---

## 7.2 Train.tscn

```text
Train
├── PathFollow3D
├── LocomotiveModel
├── Cabin
├── TrainController
├── FuelSystem
├── BrakeSystem
├── PressureSystem
├── DerailmentSystem
└── TrainAudioController
```

Responsabilidad:

```text
- Movimiento del tren.
- Consumo de carbón.
- Presión de vapor.
- Frenado.
- Audio del motor.
- Riesgo de descarrilamiento.
```

---

## 7.3 Cabin.tscn

```text
Cabin
├── Dashboard
├── SteamRegulator
├── BrakeLever
├── CoalGauge
├── PressureGauge
├── SpeedGauge
├── StationClock
├── SupplyPanel
└── Whistle
```

Responsabilidad:

```text
- Representar la interfaz diegética.
- Contener controles físicos.
- Mostrar información sin HUD.
- Permitir interacción VR mediante puntero láser.
```

---

## 7.4 Station.tscn

```text
Station
├── Platform
├── StopArea
├── Passengers
├── StationBell
├── FogEffect
└── StationScript
```

Responsabilidad:

```text
- Representar una parada.
- Controlar temporizador.
- Validar llegada del tren.
- Activar subida o retirada de pasajeros.
- Desbloquear diarios.
```

---

# 8. Patrones de diseño obligatorios

## 8.1 Singleton / Autoload

Usar Singletons para sistemas globales:

```text
GameManager
EventBus
AudioManager
SaveManager
ScoreManager
DiaryManager
```

Uso:

```text
GameManager:
Controla el estado general del juego.

EventBus:
Comunica sistemas mediante señales globales.

AudioManager:
Controla sonidos globales y ambiente.

ScoreManager:
Registra puntos, rutas, pasajeros y diarios.

SaveManager:
Guarda resultados de partida.

DiaryManager:
Controla diarios narrativos desbloqueados.
```

---

## 8.2 State Machine

Usar máquina de estados para el juego y para los pasajeros.

### Estados del juego

```text
GAME_START
TRAVELING
APPROACHING_STATION
STOPPED_AT_STATION
BOARDING_PASSENGERS
ROUTE_COMPLETED
OUT_OF_COAL
DERAILED
GAME_OVER
```

### Estados del pasajero

```text
WAITING
BOARDING
LEFT_IN_FOG
```

---

## 8.3 Observer mediante señales

Usar señales para evitar dependencias directas entre sistemas.

```gdscript
signal coal_changed(value)
signal pressure_changed(value)
signal train_speed_changed(speed)
signal station_timer_changed(station_id, remaining_time)
signal station_timer_expired(station_id)
signal train_arrived_at_station(station_id)
signal passengers_boarded(amount)
signal route_completed(route_number)
signal diary_unlocked(diary_id)
signal buy_coal_requested()
signal whistle_requested()
signal game_over(reason)
```

Ejemplo de comunicación:

```text
FuelSystem emite coal_changed.
GaugeController escucha coal_changed.
AudioManager escucha train_speed_changed.
StationManager escucha train_arrived_at_station.
ScoreManager escucha passengers_boarded.
DiaryManager escucha diary_unlocked.
```

---

## 8.4 Factory Pattern

Usar Factory para crear estaciones y pasajeros.

```text
StationFactory:
Crea estaciones procedimentales.

PassengerFactory:
Crea pasajeros con datos narrativos.

DiaryFactory:
Asigna diarios desbloqueables por estación.
```

---

## 8.5 Strategy Pattern

Usar Strategy para consumo de carbón y dificultad.

```text
FuelConsumptionStrategy:
- NormalConsumption
- HighSpeedConsumption
- EmergencyConsumption

DifficultyStrategy:
- Easy
- Normal
- Hard
```

Ejemplo:

```text
En dificultad normal:
consumo = acelerador * velocidad * factor_ruta

En dificultad alta:
consumo = acelerador * velocidad * pendiente * penalización_curva
```

---

## 8.6 Command Pattern para interacción VR

Cada botón o palanca debe ejecutar una acción independiente.

```text
SteamRegulatorCommand
BrakeCommand
BuyCoalCommand
WhistleCommand
```

Este patrón permite que el puntero láser detecte objetos interactuables sin conocer toda la lógica interna del sistema.

---

# 9. Sistemas principales

## 9.1 Sistema de tren

Archivo sugerido:

```text
scripts/train/TrainController.gd
```

Responsabilidad:

```text
- Mover el tren sobre Path3D.
- Controlar velocidad.
- Recibir aceleración desde el regulador.
- Recibir frenado desde el freno.
- Detectar curvas peligrosas.
- Enviar señales de velocidad.
- Detenerse en estaciones.
```

Variables mínimas:

```gdscript
var current_speed: float
var max_speed: float
var acceleration_input: float
var brake_input: float
var distance_along_path: float
var is_stopped: bool
```

Lógica base:

```gdscript
func _physics_process(delta):
    update_speed(delta)
    move_along_track(delta)
    check_derailment_risk()
    EventBus.train_speed_changed.emit(current_speed)
```

Regla:

```text
Si la velocidad en curva supera el límite permitido,
activar riesgo de descarrilamiento.
```

---

## 9.2 Sistema de carbón

Archivo sugerido:

```text
scripts/train/FuelSystem.gd
```

Responsabilidad:

```text
- Controlar carbón actual.
- Reducir carbón según aceleración y velocidad.
- Permitir comprar carbón.
- Activar Game Over si llega a cero.
```

Variables:

```gdscript
var current_coal: float = 100.0
var max_coal: float = 100.0
var critical_coal_level: float = 15.0
```

Regla de consumo:

```text
consumo = consumo_base + acelerador * velocidad * factor_consumo
```

Pseudocódigo:

```gdscript
func consume_fuel(delta, throttle, speed):
    var consumption = base_consumption + throttle * speed * consumption_factor
    current_coal -= consumption * delta
    current_coal = clamp(current_coal, 0, max_coal)

    EventBus.coal_changed.emit(current_coal)

    if current_coal <= 0:
        EventBus.game_over.emit("OUT_OF_COAL")
```

---

## 9.3 Sistema de presión

Archivo sugerido:

```text
scripts/train/PressureSystem.gd
```

Responsabilidad:

```text
- Simular presión de vapor.
- Subir presión cuando se usa acelerador.
- Bajar presión cuando se frena o se reduce potencia.
- Alimentar la aguja física del tablero.
```

Variables:

```gdscript
var current_pressure: float
var max_pressure: float
```

Regla:

```text
Más aceleración = más presión.
Presión demasiado alta = advertencia visual o sonora.
```

---

## 9.4 Sistema de freno

Archivo sugerido:

```text
scripts/train/BrakeSystem.gd
```

Responsabilidad:

```text
- Aplicar desaceleración.
- Permitir detenerse correctamente en estaciones.
- Evitar pasarse del andén.
- Reducir riesgo en curvas.
```

Pseudocódigo:

```gdscript
func apply_brake(delta, brake_input):
    current_speed -= brake_force * brake_input * delta
```

---

## 9.5 Sistema de descarrilamiento

Archivo sugerido:

```text
scripts/train/DerailmentSystem.gd
```

Responsabilidad:

```text
- Evaluar velocidad en curvas.
- Detectar zonas peligrosas.
- Activar Game Over si el tren descarrila.
```

Reglas:

```text
1. Cada curva puede tener un límite de velocidad.
2. Si el tren supera el límite durante cierto tiempo, aumenta el riesgo.
3. Si el riesgo llega al máximo, se activa descarrilamiento.
```

---

## 9.6 Sistema de estaciones

Archivo sugerido:

```text
scripts/station/StationManager.gd
```

Responsabilidad:

```text
- Generar estaciones.
- Controlar estación activa.
- Manejar temporizador.
- Validar si el tren llegó a tiempo.
- Activar pasajeros.
- Cubrir estación con niebla si se pierde.
```

Cada estación debe tener:

```gdscript
var station_id: int
var time_limit: float
var remaining_time: float
var passengers_count: int
var has_diary_fragment: bool
var is_active: bool
var was_completed: bool
```

Lógica:

```gdscript
func update_station_timer(delta):
    if is_active:
        remaining_time -= delta

        if remaining_time <= 0:
            passengers_leave()
            EventBus.station_timer_expired.emit(station_id)
```

Validación de llegada:

```text
El tren solo recoge pasajeros si:

1. Llegó antes de que el temporizador llegue a cero.
2. Está dentro del área del andén.
3. La velocidad es menor o igual a la velocidad permitida.
4. El tren está prácticamente detenido.
```

---

## 9.7 Sistema de pasajeros

Archivo sugerido:

```text
scripts/station/Passenger.gd
```

Estados:

```text
WAITING
BOARDING
LEFT_IN_FOG
```

Comportamiento:

```text
WAITING:
El pasajero permanece en el andén.

BOARDING:
Si el tren llegó a tiempo y se detuvo correctamente, sube al tren.

LEFT_IN_FOG:
Si el temporizador llega a cero, desaparece en la niebla.
```

---

## 9.8 Sistema de puntuación

Archivo sugerido:

```text
scripts/scoring/ScoreManager.gd
```

Debe registrar:

```text
- Puntos actuales.
- Rutas completadas.
- Pasajeros transportados.
- Diarios desbloqueados.
- Estaciones visitadas.
- Estaciones exitosas.
- Porcentaje de puntualidad.
```

Reglas:

```text
Si pasajeros abordan:
+ puntos por pasajero.

Si llega a tiempo:
+ bonus de puntualidad.

Si desbloquea diario:
+ registrar diario.

Si completa 5 rutas:
+ marcar objetivo principal cumplido.
```

Pseudocódigo:

```gdscript
func add_passengers(amount):
    passengers_transported += amount
    points += amount * points_per_passenger
    EventBus.score_changed.emit(points)

func complete_route():
    routes_completed += 1
    EventBus.route_completed.emit(routes_completed)
```

---

## 9.9 Sistema de diarios narrativos

Archivo sugerido:

```text
scripts/scoring/DiaryManager.gd
```

Responsabilidad:

```text
- Desbloquear diarios si el jugador llega a tiempo.
- Guardar qué diarios fueron obtenidos.
- Mostrar fragmentos dentro de la cabina o al finalizar la ruta.
```

Estructura de recurso:

```gdscript
class_name DiaryEntry
extends Resource

@export var diary_id: String
@export var title: String
@export_multiline var content: String
@export var station_id: int
```

Regla:

```text
El diario solo se desbloquea si el jugador llega antes de que expire el temporizador de estación.
```

---

# 10. Interfaz diegética

El juego no debe usar HUD flotante tradicional.

Toda la información debe vivir dentro de la cabina, como si fuera parte real de la locomotora.

Elementos obligatorios:

```text
1. Aguja de carbón.
2. Aguja de presión.
3. Medidor de velocidad.
4. Reloj / temporizador de estación.
5. Botón comprar carbón.
6. Palanca regulador de vapor.
7. Palanca de freno.
8. Silbato.
```

Archivo sugerido:

```text
scripts/ui/GaugeController.gd
```

Pseudocódigo:

```gdscript
func update_needle(value, min_value, max_value):
    var normalized = inverse_lerp(min_value, max_value, value)
    rotation_degrees.z = lerp(min_angle, max_angle, normalized)
```

Reglas de interfaz:

```text
- No usar barras flotantes.
- No usar minimapa.
- No usar textos grandes sobre pantalla.
- Las advertencias deben ser físicas:
  - Aguja en zona roja.
  - Luz tenue.
  - Sonido de presión.
  - Vibración sutil del mando.
```

---

# 11. Sistema de interacción VR

## Objetivo

El jugador debe interactuar con la cabina usando un **puntero láser VR**.

No debe tener que caminar por la cabina ni hacer movimientos incómodos.

Herramientas recomendadas de Godot:

```text
- OpenXR.
- XROrigin3D.
- XRController3D.
- RayCast3D.
- Area3D.
- CollisionShape3D.
```

---

## 11.1 Interactable base

Archivo:

```text
scripts/interaction/Interactable.gd
```

```gdscript
class_name Interactable
extends Node3D

func on_hover_enter():
    pass

func on_hover_exit():
    pass

func interact():
    pass
```

---

## 11.2 Botón interactuable

```gdscript
class_name ButtonInteractable
extends Interactable

@export var command_name: String

func interact():
    match command_name:
        "BUY_COAL":
            EventBus.buy_coal_requested.emit()
        "WHISTLE":
            EventBus.whistle_requested.emit()
```

---

## 11.3 Palanca interactuable

```gdscript
class_name LeverInteractable
extends Interactable

@export var min_value: float = 0.0
@export var max_value: float = 1.0
var current_value: float = 0.0

func set_value(value):
    current_value = clamp(value, min_value, max_value)
    EventBus.lever_value_changed.emit(name, current_value)
```

---

# 12. Sistema de audio

El audio debe ser diegético, ambiental y funcional.

No se recomienda música constante. El sonido debe venir de:

```text
- La locomotora.
- El viento.
- La niebla.
- Las vías.
- La campana de estación.
- El silbato.
- El freno.
```

Archivos mínimos:

```text
chugging_rhythm.wav
wind_fog.wav
whistle.wav
station_bell.wav
brake_screech.wav
coal_warning.wav
passenger_board.wav
station_lost.wav
```

## TrainAudioController

Debe hacer:

```text
- Cambiar pitch del motor según velocidad.
- Subir volumen del viento en zonas abiertas.
- Activar campana al acercarse a estación.
- Activar alerta suave si carbón está crítico.
```

Pseudocódigo:

```gdscript
func update_engine_audio(speed):
    var pitch = lerp(0.8, 1.6, speed / max_speed)
    engine_audio.pitch_scale = pitch
```

Herramientas Godot:

```text
- AudioStreamPlayer3D.
- Audio buses.
- Reverb moderado.
- Sonidos .wav.
```

---

# 13. Sistema de entorno

## Escenario principal

Nombre del entorno:

```text
El Paso de la Bruma
```

Características:

```text
- Montañas.
- Bosques low-poly.
- Vías curvas.
- Niebla densa.
- Visibilidad limitada.
- Estética retro PSX / low-poly.
- Texturas pixeladas.
- Cielo nublado.
- Sensación de aislamiento.
```

## Optimización

Implementar:

```text
- Niebla para limitar visión.
- Modelos low-poly.
- Texturas de baja resolución.
- Ocultar objetos lejanos.
- Foveated Rendering si está disponible en VR.
- Evitar físicas complejas innecesarias.
- Usar colisiones simples.
- Evitar exceso de luces dinámicas.
```

---

# 14. Sistema de shaders y efectos visuales en Godot

El juego debe usar shaders y herramientas visuales nativas de Godot para reforzar:

```text
- Estética Retro Realism / PSX.
- Niebla densa.
- Soledad del entorno.
- Sensación de locomotora antigua.
- Optimización VR.
```

El modelo de IA puede crear shaders propios en Godot Shader Language o usar shaders descargables como referencia, siempre que sean compatibles con Godot 4.x y tengan licencia abierta.

---

## 14.1 Shader de niebla / bruma

Objetivo:

```text
Crear una sensación de aislamiento, limitar la visibilidad y ocultar objetos lejanos para mejorar rendimiento.
```

Implementación recomendada:

```text
- Usar WorldEnvironment.
- Activar Volumetric Fog.
- Usar FogVolume para niebla localizada.
- Usar niebla densa en tonos grises o azulados.
- Combinar con shader de disolución en estaciones.
```

Uso en gameplay:

```text
Cuando el jugador llega tarde a una estación:
- Activar animación de niebla.
- Ocultar pasajeros.
- Reducir visibilidad del andén.
- Cambiar sonido ambiente.
```

---

## 14.2 Shader PSX / Retro

Objetivo:

```text
Dar apariencia de consola antigua, con baja precisión visual, texturas pixeladas y sensación nostálgica.
```

Características:

```text
- Texturas de baja resolución.
- Vertex snapping sutil.
- Dithering suave.
- Reducción de precisión visual.
- Iluminación simple.
```

Aplicar en:

```text
- Montañas.
- Rocas.
- Árboles.
- Estaciones.
- Cabina.
- Locomotora.
```

Importante:

```text
No exagerar el efecto en VR porque puede generar incomodidad visual.
Debe ser sutil.
```

---

## 14.3 Shader de vapor

Objetivo:

```text
Simular vapor de la locomotora y ambiente húmedo de montaña.
```

Implementación:

```text
- GPUParticles3D para vapor.
- Material transparente con ShaderMaterial.
- Movimiento usando ruido procedural.
- Desvanecimiento gradual.
- NoiseTexture2D o FastNoiseLite.
```

Uso:

```text
- Chimenea de la locomotora.
- Válvulas de presión.
- Freno de vapor.
- Ambiente cerca de estaciones.
```

---

## 14.4 Shader de carbón crítico

Objetivo:

```text
Cuando el carbón esté bajo, reforzar visualmente la tensión sin usar HUD flotante.
```

Implementación:

```text
- Zona roja del medidor de carbón con brillo tenue.
- Material emisivo leve.
- Parpadeo suave cuando el carbón esté por debajo del 15%.
```

Regla:

```text
No usar alertas invasivas.
La advertencia debe ser diegética dentro del tablero.
```

---

## 14.5 Shader de estación perdida en la niebla

Objetivo:

```text
Cuando el jugador llega tarde, la estación y los pasajeros deben desaparecer visualmente dentro de la bruma.
```

Implementación:

```text
- Material con transparencia gradual.
- Shader de disolución usando noise texture.
- Fade out de pasajeros.
- Aumento local de niebla.
```

Pseudocódigo:

```gdscript
func station_lost_effect():
    fog_density += 0.2
    passengers.fade_to_fog()
    station_material.set_shader_parameter("dissolve_amount", 1.0)
```

---

## 14.6 Shader de vidrio sucio de cabina

Objetivo:

```text
Dar sensación de estar dentro de una locomotora antigua.
```

Implementación:

```text
- Material transparente.
- Suciedad leve.
- Reflejo muy sutil.
- Distorsión mínima.
```

Importante:

```text
En VR no usar reflejos pesados ni distorsiones fuertes.
```

---

# 15. Herramientas nativas de Godot que deben usarse

El modelo IA debe usar preferentemente herramientas internas de Godot antes de depender de plugins externos.

```text
WorldEnvironment:
- Niebla.
- Color ambiental.
- Ajuste de exposición.
- Tonemapping.

FogVolume:
- Niebla localizada en estaciones.
- Zonas de desaparición.
- Ambiente de montaña.

GPUParticles3D:
- Vapor.
- Humo.
- Polvo.
- Niebla cercana.

ShaderMaterial:
- Materiales personalizados.
- Efecto PSX.
- Disolución de pasajeros.
- Brillo de medidores.

NoiseTexture2D / FastNoiseLite:
- Disolución.
- Vapor.
- Movimiento irregular de niebla.

Path3D / PathFollow3D:
- Movimiento del tren sobre vías.

AudioStreamPlayer3D:
- Audio posicional.

OpenXR:
- Soporte VR.

XRController3D:
- Controladores VR.

RayCast3D:
- Puntero láser de interacción.
```

---

# 16. Shaders que la IA puede crear

La IA debe crear estos archivos:

```text
assets/shaders/
├── psx_retro_shader.gdshader
├── fog_dissolve_shader.gdshader
├── steam_shader.gdshader
├── coal_warning_emission_shader.gdshader
├── dirty_glass_shader.gdshader
└── passenger_fade_shader.gdshader
```

---

## 16.1 Reglas para descargar shaders

Si el modelo IA propone descargar shaders, debe cumplir:

```text
1. Deben ser compatibles con Godot 4.x.
2. Deben permitir uso libre o licencia abierta.
3. No deben depender de plugins pesados.
4. Deben poder modificarse.
5. Deben estar optimizados para VR.
6. No deben usar efectos muy agresivos de pantalla completa.
7. Deben respetar la estética retro del juego.
```

Preferencia:

```text
Primero crear shaders simples propios.
Luego, si hace falta, usar shaders descargados solo como referencia.
```

No conviene depender demasiado de shaders externos porque pueden venir mal optimizados o incompatibles con VR.

---

# 17. Resources de configuración

No quemar valores directamente en scripts. Usar Resources `.tres`.

---

## 17.1 TrainConfig.gd

```gdscript
class_name TrainConfig
extends Resource

@export var max_speed: float = 35.0
@export var acceleration_force: float = 8.0
@export var brake_force: float = 15.0
@export var derailment_curve_speed: float = 25.0
```

---

## 17.2 GameBalanceConfig.gd

```gdscript
class_name GameBalanceConfig
extends Resource

@export var starting_coal: float = 100.0
@export var max_coal: float = 100.0
@export var coal_warning_level: float = 15.0
@export var points_per_passenger: int = 10
@export var coal_purchase_cost: int = 30
@export var coal_purchase_amount: float = 25.0
@export var required_routes_to_win: int = 5
@export var required_station_success_rate: float = 0.6
```

---

## 17.3 StationConfig.gd

```gdscript
class_name StationConfig
extends Resource

@export var min_wait_time: float = 60.0
@export var max_wait_time: float = 120.0
@export var stop_speed_threshold: float = 1.0
@export var stop_distance_threshold: float = 5.0
```

---

# 18. Reglas de validación del gameplay

El modelo IA debe implementar estas reglas obligatorias:

```text
1. No permitir recoger pasajeros si el tren llegó tarde.
2. No permitir recoger pasajeros si el tren no está detenido.
3. No permitir recoger pasajeros si el tren se pasó del área del andén.
4. No permitir comprar carbón si no hay puntos suficientes.
5. No permitir carbón mayor al máximo.
6. Terminar partida si carbón llega a cero.
7. Activar riesgo de descarrilamiento si velocidad en curva es excesiva.
8. Actualizar agujas cada frame.
9. El audio del motor debe cambiar según la velocidad.
10. El diario solo se desbloquea si se llega a tiempo.
11. No usar HUD flotante tradicional.
12. Las advertencias deben ser diegéticas.
13. No usar efectos visuales pesados en VR.
14. No exagerar el efecto PSX.
15. Mantener al jugador fijo dentro de la cabina.
```

---

# 19. Secuencia de implementación paso a paso

## Fase 1: Base del proyecto

```text
1. Crear proyecto en Godot 4.x.
2. Activar OpenXR.
3. Crear MainGame.tscn.
4. Crear estructura de carpetas.
5. Crear Autoloads:
   - GameManager.
   - EventBus.
   - AudioManager.
   - ScoreManager.
   - SaveManager.
   - DiaryManager.
6. Crear escena XROrigin con cámara VR y controladores.
```

---

## Fase 2: Locomotora y movimiento

```text
1. Crear TrackPath usando Path3D.
2. Crear Train.tscn con PathFollow3D.
3. Implementar TrainController.
4. Hacer que el tren avance por la vía.
5. Agregar aceleración y frenado.
6. Agregar límite de velocidad.
7. Emitir señal train_speed_changed.
```

---

## Fase 3: Carbón, presión y freno

```text
1. Crear FuelSystem.
2. Consumir carbón según velocidad y acelerador.
3. Crear PressureSystem.
4. Crear BrakeSystem.
5. Conectar presión y carbón con agujas físicas.
6. Si carbón llega a cero, activar Game Over.
```

---

## Fase 4: Cabina interactiva

```text
1. Crear Cabin.tscn.
2. Crear tablero físico.
3. Crear palanca de aceleración.
4. Crear freno.
5. Crear botón comprar carbón.
6. Crear silbato.
7. Implementar Interactable.gd.
8. Implementar LaserPointer.gd.
9. Conectar interacciones con sistemas.
```

---

## Fase 5: Estaciones y pasajeros

```text
1. Crear Station.tscn.
2. Crear StopArea.
3. Crear Passenger.tscn.
4. Implementar StationManager.
5. Crear temporizador por estación.
6. Si el tren llega a tiempo y se detiene, pasajeros abordan.
7. Si el tiempo llega a cero, pasajeros se retiran.
8. Activar niebla sobre estación perdida.
```

---

## Fase 6: Puntuación y diarios

```text
1. Implementar ScoreManager.
2. Sumar puntos por pasajero.
3. Registrar rutas completadas.
4. Registrar pasajeros transportados.
5. Crear DiaryManager.
6. Crear recursos DiaryEntry.
7. Desbloquear diarios solo al llegar a tiempo.
```

---

## Fase 7: Audio

```text
1. Agregar AudioStreamPlayer3D al tren.
2. Reproducir loop del motor.
3. Cambiar pitch según velocidad.
4. Agregar ambiente Wind & Fog.
5. Agregar campana de estación.
6. Agregar silbato.
7. Agregar alerta de carbón bajo.
```

---

## Fase 8: Shaders y efectos visuales

```text
1. Crear carpeta assets/shaders/.
2. Crear shader retro PSX.
3. Crear shader de disolución por niebla.
4. Crear shader de vapor.
5. Crear shader de carbón crítico.
6. Crear shader de vidrio sucio.
7. Crear shader de fade para pasajeros.
8. Aplicar materiales ShaderMaterial a objetos correspondientes.
9. Probar rendimiento en VR.
```

---

## Fase 9: Optimización VR

```text
1. Usar modelos low-poly.
2. Usar texturas pixeladas.
3. Mantener niebla densa.
4. Reducir objetos lejanos.
5. Evitar luces dinámicas excesivas.
6. Usar colisiones simples.
7. Mantener interacción fija en cabina.
8. Evitar movimiento libre del jugador para reducir mareo.
```

---

## Fase 10: Pantalla final / resultados

Al terminar la partida mostrar dentro de la cabina o en una escena final:

```text
- Rutas completadas.
- Pasajeros transportados.
- Diarios desbloqueados.
- Estaciones exitosas.
- Porcentaje de puntualidad.
- Motivo de fin de partida:
  - Sin carbón.
  - Descarrilamiento.
  - Partida completada.
```

---

# 20. Criterios de aceptación

El juego se considera correctamente implementado si cumple:

```text
1. El tren se mueve sobre vías usando Path3D.
2. El jugador controla acelerador, freno, compra de carbón y silbato con puntero láser VR.
3. El carbón baja de forma dinámica según velocidad y aceleración.
4. El jugador puede quedarse sin carbón.
5. Las estaciones tienen temporizador.
6. Los pasajeros abordan solo si el tren llega a tiempo y se detiene.
7. Los pasajeros se retiran si el jugador llega tarde.
8. Los puntos sirven para comprar carbón.
9. Los diarios se desbloquean solo por puntualidad.
10. La interfaz está integrada físicamente en la cabina.
11. El audio del tren cambia según velocidad.
12. El ambiente tiene niebla, estética retro y sensación de soledad.
13. Se registran rutas, pasajeros y diarios al final.
14. El código está modularizado.
15. Los shaders están separados en assets/shaders/.
16. Los efectos visuales están optimizados para VR.
17. No existe HUD flotante artificial.
18. La experiencia se mantiene diegética.
```

---

# 21. Prompt maestro para pegar en una IA

```text
Actúa como desarrollador senior experto en Godot 4.x, VR/OpenXR, arquitectura de videojuegos, GDScript, shaders y optimización para realidad virtual.

Necesito que desarrolles la base completa de un videojuego llamado “Echoes of the Rails”.

El juego es una experiencia VR de simulación ferroviaria en primera persona. El jugador está fijo dentro de la cabina de una locomotora de vapor y controla los mandos mediante un puntero láser VR. No debe existir movimiento libre por el mapa.

El objetivo es conducir una locomotora por una ruta montañosa con niebla, administrar carbón, llegar a estaciones antes de que expire el temporizador, recoger pasajeros, ganar puntos, desbloquear diarios narrativos y comprar carbón para continuar. Si el carbón llega a cero, termina la partida. Si el jugador llega tarde a una estación, los pasajeros se retiran y se pierde el fragmento narrativo.

Quiero que el proyecto esté bien implementado con arquitectura modular, patrones de diseño y buenas prácticas.

Implementa los siguientes sistemas:

1. GameManager con máquina de estados:
   - GAME_START
   - TRAVELING
   - APPROACHING_STATION
   - STOPPED_AT_STATION
   - BOARDING_PASSENGERS
   - ROUTE_COMPLETED
   - OUT_OF_COAL
   - DERAILED
   - GAME_OVER

2. EventBus como Autoload con señales globales:
   - coal_changed
   - pressure_changed
   - train_speed_changed
   - station_timer_changed
   - station_timer_expired
   - passengers_boarded
   - route_completed
   - diary_unlocked
   - game_over

3. TrainController:
   - Movimiento sobre Path3D / PathFollow3D.
   - Velocidad, aceleración y frenado.
   - Control por regulador de vapor.
   - Riesgo de descarrilamiento por exceso de velocidad en curvas.

4. FuelSystem:
   - Carbón actual y máximo.
   - Consumo dinámico según acelerador y velocidad.
   - Alerta por carbón bajo.
   - Game Over si el carbón llega a cero.
   - Compra de carbón con puntos.

5. BrakeSystem:
   - Desaceleración progresiva.
   - Validación de parada correcta en estación.

6. PressureSystem:
   - Presión de vapor ligada al uso del acelerador.
   - Actualización de aguja física en el tablero.

7. StationManager:
   - Estaciones activas.
   - Temporizador por estación.
   - Validación de llegada a tiempo.
   - Validación de tren detenido en zona correcta.
   - Activar pasajeros o retirarlos en la niebla.

8. Passenger con máquina de estados:
   - WAITING
   - BOARDING
   - LEFT_IN_FOG

9. ScoreManager:
   - Puntos.
   - Rutas completadas.
   - Pasajeros transportados.
   - Estaciones exitosas.
   - Porcentaje de puntualidad.

10. DiaryManager:
   - Desbloqueo de diarios narrativos solo si se llega a tiempo.
   - Uso de Resources para DiaryEntry.

11. Interacción VR:
   - Interactable base.
   - LaserPointer.
   - ButtonInteractable.
   - LeverInteractable.
   - Comandos para acelerar, frenar, comprar carbón y usar silbato.

12. Interfaz diegética:
   - Sin HUD flotante.
   - Medidor físico de carbón.
   - Medidor físico de presión.
   - Medidor físico de velocidad.
   - Reloj físico de temporizador.
   - Panel físico de suministros.

13. Audio:
   - AudioStreamPlayer3D.
   - Motor con pitch dinámico según velocidad.
   - Ambiente Wind & Fog.
   - Silbato.
   - Campana de estación.
   - Alerta de carbón bajo.

14. Entorno:
   - Montañas.
   - Bosque low-poly.
   - Vías curvas.
   - Niebla densa.
   - Estética retro PSX.
   - Optimización para VR.

15. Shaders y efectos visuales:
   - Crear carpeta assets/shaders/.
   - Crear psx_retro_shader.gdshader.
   - Crear fog_dissolve_shader.gdshader.
   - Crear steam_shader.gdshader.
   - Crear coal_warning_emission_shader.gdshader.
   - Crear dirty_glass_shader.gdshader.
   - Crear passenger_fade_shader.gdshader.

Usa herramientas nativas de Godot:
- WorldEnvironment.
- Volumetric Fog.
- FogVolume.
- GPUParticles3D.
- ShaderMaterial.
- NoiseTexture2D.
- FastNoiseLite.
- Path3D.
- PathFollow3D.
- AudioStreamPlayer3D.
- OpenXR.
- XRController3D.
- RayCast3D.

Usa estos patrones de diseño:
- Singleton/Autoload para managers globales.
- State Machine para juego y pasajeros.
- Observer mediante señales.
- Factory para estaciones y pasajeros.
- Strategy para consumo de carbón y dificultad.
- Command para acciones de interacción VR.

Crea la estructura de carpetas recomendada:
scenes, scripts, resources, assets, audio, shaders y configs.

No mezcles toda la lógica en un solo script. Cada sistema debe tener responsabilidad única.

Reglas importantes:
- No usar efectos pesados de pantalla completa que afecten el rendimiento VR.
- No exagerar el efecto PSX porque puede incomodar en realidad virtual.
- La niebla debe servir tanto para atmósfera como para optimización.
- Los efectos visuales deben ser diegéticos, integrados al mundo del juego.
- La advertencia de carbón bajo debe verse en el tablero, no como HUD flotante.
- Los shaders deben ser simples, editables y compatibles con Godot 4.x.

Entrega:
1. Estructura de carpetas.
2. Escenas principales.
3. Scripts GDScript principales.
4. Señales.
5. Resources de configuración.
6. Shaders base.
7. Pseudocódigo o código base funcional.
8. Explicación de cómo se conectan los sistemas.
9. Reglas de validación del gameplay.
10. Checklist final de implementación.
```

---

# 22. Recomendación final de trabajo

Para evitar que la IA genere un proyecto desordenado, pedirle que trabaje por fases:

```text
1. Arquitectura del proyecto.
2. GameManager + EventBus.
3. Movimiento del tren.
4. Carbón + presión + freno.
5. Cabina interactiva.
6. Estaciones + pasajeros.
7. Puntuación + diarios.
8. Audio.
9. Shaders y efectos visuales.
10. VR/OpenXR.
11. Optimización y pruebas.
```

La IA no debe intentar crear todo el juego en una sola respuesta si eso provoca código incompleto o mal estructurado.

---

# 23. Checklist final para revisar el proyecto

```text
[ ] Proyecto creado en Godot 4.x.
[ ] OpenXR activado.
[ ] Estructura de carpetas organizada.
[ ] GameManager configurado como Autoload.
[ ] EventBus configurado como Autoload.
[ ] TrainController funcional.
[ ] Movimiento sobre Path3D.
[ ] Acelerador funcional.
[ ] Freno funcional.
[ ] Sistema de carbón funcional.
[ ] Sistema de presión funcional.
[ ] Medidores físicos actualizados.
[ ] Estaciones con temporizador.
[ ] Pasajeros con estados.
[ ] Sistema de puntos.
[ ] Compra de carbón.
[ ] Diarios desbloqueables.
[ ] Audio 3D implementado.
[ ] Motor cambia pitch según velocidad.
[ ] Niebla volumétrica configurada.
[ ] Shaders creados.
[ ] Shader PSX aplicado con moderación.
[ ] Shader de disolución en pasajeros/estaciones.
[ ] Shader de vapor aplicado a partículas.
[ ] Interacción VR mediante puntero láser.
[ ] Sin HUD flotante.
[ ] Optimización VR aplicada.
[ ] Pantalla final de resultados.
[ ] Código separado por responsabilidades.
```
