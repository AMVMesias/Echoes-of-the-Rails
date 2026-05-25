# UNIVERSIDAD DE LAS FUERZAS ARMADAS – ESPE
**Departamento de Ciencias de la Computación | Innovación para la Excelencia**

---

**Asignatura:** Desarrollo de Videojuegos | Unidad 2
**Docente:** Ing. Paul Pinto

---

# INFORME DE DISEÑO
## Diseño de un Entorno Virtual

---

> **Videojuego:** Echoes of the Rails
> *"¡Llega a tiempo o quédate solo en la niebla!!"*

| Campo | Detalle |
|---|---|
| **Grupo** | Grupo #1 |
| **Integrantes** | Jordan Guaman, Anthony Morales, Mesias Mariscal, Denise Rea |
| **Empresa / Estudio** | CF Games |
| **Docente** | Ing. Paul Pinto |
| **Fecha de entrega** | Mayo 2026 |
| **Motor de juego** | Godot 4.6 + OpenXR (VR) |

*Versión 1.00 – Tuesday, May 05, 2026*

---

## Tabla de Contenidos

1. [Coherencia del Entorno con el Videojuego](#1-coherencia-del-entorno-con-el-videojuego)
2. [Diseño Visual y Ambientación del Escenario](#2-diseño-visual-y-ambientación-del-escenario)
3. [Elementos y Objetos del Entorno](#3-elementos-y-objetos-del-entorno)
4. [Funcionalidad e Interacción del Entorno](#4-funcionalidad-e-interacción-del-entorno)
5. [Presentación y Justificación Grupal](#5-presentación-y-justificación-grupal)

---

## 1. Coherencia del Entorno con el Videojuego

El entorno de *Echoes of the Rails* está diseñado con coherencia total respecto a cada pilar del videojuego: su objetivo medible, la historia que narra, el género que habita y las mecánicas que lo definen. Cada decisión espacial refuerza la experiencia de **estrés tranquilo** que el juego persigue.

### 1.1 Coherencia con el Objetivo del Juego

> **Objetivo principal:** el jugador debe completar al menos 5 rutas consecutivas sin que el carbón llegue a cero y llegar a un mínimo del 60% de las estaciones activas.

El escenario responde directamente al objetivo porque:

- El sistema de vías **Path3D infinito** genera un entorno continuo sin interrupciones, alineado con la necesidad de completar múltiples rutas consecutivas.
- Las estaciones están distribuidas a lo largo de la ruta con **temporizadores individuales** visibles, haciendo que la meta del 60% sea alcanzable pero desafiante.
- La **niebla volumétrica** que limita la visibilidad a 50 metros funciona como consecuencia dramática del fallo: cuando el tiempo se acaba, la niebla cubre el andén y los pasajeros desaparecen.
- El **medidor de carbón** en el tablero diegético es el recordatorio constante del recurso limitado que define la regla de las 5 rutas.

### 1.2 Coherencia con la Historia

La narrativa sitúa al jugador como el último maquinista de una línea ferroviaria olvidada en una zona montañosa sin acceso por carretera. El entorno materializa este relato de tres maneras clave:

- El diseño visual **retro de baja poligonización** y texturas pixeladas evoca una era pasada, reforzando la sensación de que esta ruta existe desde hace décadas y está en decadencia.
- La ausencia de HUD y la **interfaz completamente diegética** ubican al jugador dentro de la cabina, sin romper la ilusión de ser un maquinista real y solitario.
- Las **siluetas oscuras de los pasajeros** en los andenes, que esperan en silencio y se retiran sin protestar, construyen la atmósfera de melancolía y soledad que la historia requiere.
- Los **fragmentos narrativos** —diarios de pasajeros desbloqueables al llegar a tiempo— son la única recompensa no mecánica del juego, coherentes con una historia que trata sobre el peso emocional del tiempo.

### 1.3 Coherencia con el Género y las Mecánicas

| Campo | Detalle |
|---|---|
| **Género** | Simulación ferroviaria VR / Gestión de recursos / Horror sutil |
| **Plataforma objetivo** | Quest / PCVR – Godot 4.6 con OpenXR |
| **Mecánica central** | Equilibrio entre velocidad y consumo de carbón bajo presión temporal |
| **Estilo visual** | Retro Realism (estética PSX / quinta generación de consolas) |

El género de simulación de gestión exige que el entorno sea lo suficientemente complejo para generar decisiones con consecuencias reales, pero suficientemente legible para no frustrar al jugador. El diseño de *El Paso de la Bruma* cumple ambas condiciones: la niebla limita la información disponible, las pendientes y curvas afectan el consumo de carbón, y las estaciones crean nodos de tensión y resolución que estructuran el ritmo del juego.

---

## 2. Diseño Visual y Ambientación del Escenario

El entorno de *El Paso de la Bruma* propone una identidad visual única construida sobre la estética **Retro Realism**: la técnica y fidelidad de Godot 4.6 al servicio de una apariencia deliberadamente retro que evoca las consolas de quinta generación (PSX). Esta paradoja visual es la que da personalidad al juego y lo diferencia de otros simuladores ferroviarios.

### 2.1 Paleta de Color e Iluminación

| Elemento | Color | Hex |
|---|---|---|
| Cielo nocturno | ██ Azul oscuro | `#1A1A2E` |
| Neblina de ruta | ██ Gris niebla | `#C8C8D0` |
| Madera y vías | ██ Marrón cálido | `#8B7355` |
| Vegetación | ██ Verde oscuro | `#2D5A27` |
| Alertas (zona roja) | ██ Rojo crítico | `#CC2200` |
| Iluminación andén | ██ Amarillo tenue | `#FFDD00` |

La iluminación del entorno es **tenue y global**, sin fuentes de luz directas que compitan con la atmósfera. El único contrapunto luminoso son las luces amarillas de los andenes y las agujas del tablero con sus zonas rojas de alerta. Esta economía de luz mantiene la atención del jugador en los elementos funcionales sin saturar visualmente el espacio VR.

### 2.2 Composición y Uso del Espacio

La composición visual del escenario sigue una estructura en profundidad de **tres capas**:

- **Primer plano:** la cabina de la locomotora, completamente modelada, con tablero diegético, palancas y medidores que ocupan el campo visual central del jugador en VR.
- **Plano medio:** las vías, el suelo rocoso y la vegetación de pinos que bordea el camino, visible hasta los 50 metros que permite la niebla.
- **Fondo:** las formaciones montañosas silueteadas contra el cielo nublado perpetuo, pintadas con polígonos grandes para crear profundidad sin coste de renderizado.

### 2.3 Estilo Visual Retro Realism

> **Apuesta estética central:** texturas pixeladas de baja resolución y modelos low-poly que evocan la era de las consolas de los años noventa, renderizados con Godot 4.6 para garantizar rendimiento estable en VR mediante Foveated Rendering.

- Los modelos utilizan un **conteo de polígonos reducido intencionalmente**, creando ángulos y planos visibles que dan carácter retro.
- Las texturas aplican **dithering** y resolución baja (64×64 a 128×128 px) para simular la limitación técnica de las consolas de los 90.
- La **niebla volumétrica nativa** de Godot 4.6 no solo aporta atmósfera; también permite oclusión agresiva al no renderizar elementos más allá de 50 metros.
- El **Foveated Rendering** concentra la resolución en el centro del campo visual del usuario VR, manteniendo la estética pixelada sin sacrificar la legibilidad del tablero.

### 2.4 Vista General del Escenario

```
MAPA ESQUEMÁTICO – "El Paso de la Bruma"

  [Montañas fondo] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  ███ Estación A          ███ Estación B          ███ Estación C
  [Inicio]  ←——————————— [Intermedia] ————————————→ [Final/Niebla]
  
  ══════════════════════════ VÍAS PATH3D ══════════════════════════
       🚂 Locomotora
       ↑ Cabina VR (zona de juego principal)
  
  [Pinos] [Rocas] ~~~niebla~~~ [Pinos] [Rocas] ~~~niebla densa~~~
  
  ← visibilidad máxima: 50 m →    ← más allá: invisible →
```

*Figura 1. Representación esquemática del escenario El Paso de la Bruma.*

---

## 3. Elementos y Objetos del Entorno

El entorno de *Echoes of the Rails* se sostiene sobre tres categorías de objetos bien diferenciadas: los **principales** que estructuran la jugabilidad, los **decorativos** que construyen la atmósfera, y los **interactivos** que canalizan las decisiones del jugador.

### 3.1 Objetos Principales

| Objeto | Función en el Entorno |
|---|---|
| **Locomotora de vapor** | Vehículo y espacio del jugador. Contiene todos los controles interactivos. |
| **Vías ferroviarias (Path3D)** | Definen la ruta continua y generan el movimiento del tren sobre el escenario. |
| **Andenes / Estaciones** | Nodos de tensión. Contienen temporizadores, pasajeros NPC y fragmentos narrativos. |
| **Tablero de cabina** | Interfaz diegética. Muestra presión, carbón, velocidad y reloj del tren. |
| **Caldera de carbón** | Recurso limitado crítico. Su agotamiento determina el fin de la partida. |

### 3.2 Objetos Decorativos

| Objeto | Función en el Entorno |
|---|---|
| **Bosque de pinos (low-poly)** | Enmarca visualmente la ruta. Refuerza la atmósfera de aislamiento montañoso. |
| **Formaciones rocosas** | Delimitan los bordes del camino. Añaden profundidad y peligro visual. |
| **Niebla volumétrica** | Limita visibilidad a 50 m. Crea tensión atmosférica y optimiza el renderizado. |
| **Cielo nublado perpetuo** | Iluminación difusa y tenue. Refuerza la melancolía de la experiencia. |
| **Fragmentos narrativos (diarios)** | Recompensa inmersiva desbloqueada al llegar a tiempo a las estaciones. |

### 3.3 Objetos Interactivos

| Objeto | Función en el Entorno |
|---|---|
| **Regulador de vapor (palanca)** | Controla la velocidad y el consumo proporcional de carbón. |
| **Freno neumático** | Permite detención precisa en andenes y reducción de velocidad en curvas. |
| **Panel de suministros** | Permite comprar carbón con los puntos obtenidos por pasajeros. |
| **Temporizador de estación** | Cuenta regresiva por andén. Integrado visualmente en el tablero diegético. |
| **Silbato de vapor** | Feedback sonoro sin efecto mecánico. Expresa humanidad en la cabina solitaria. |

### 3.4 Pasajeros NPC como Elementos del Entorno

Los pasajeros son elementos híbridos entre decorativo e interactivo. Representados como **siluetas oscuras sin rostro ni voz**, existen en tres estados:

- **Estado Esperar:** el NPC permanece de pie en el andén mientras el temporizador está activo.
- **Estado Abordar:** se activa cuando el tren llega a tiempo y frena correctamente. El jugador obtiene puntos y desbloquea el fragmento narrativo.
- **Estado Retirarse:** cuando el temporizador llega a cero. El NPC desaparece en la niebla sin protesta. El silencio resultante es la penalización más efectiva del juego.

---

## 4. Funcionalidad e Interacción del Entorno

El entorno no es un telón de fondo: es un **sistema activo que genera decisiones con consecuencias**. Cada zona, ruta y elemento interactivo contribuye directamente a la jugabilidad de *Echoes of the Rails*.

### 4.1 Rutas y Zonas de Exploración

| Zona | Descripción | Impacto en Jugabilidad |
|---|---|---|
| **Cabina VR** | Zona de juego principal. Room-scale limitado. Contiene tablero, palancas y controles. | 100% de las decisiones del jugador ocurren aquí. Núcleo interactivo del juego. |
| **Tramo recto** | Segmentos de vía sin curvas donde el consumo de carbón es predecible y constante. | Permite acelerar con seguridad y planificar el consumo hacia la próxima estación. |
| **Curvas cerradas** | Secciones con ángulo pronunciado. Velocidad excesiva provoca descarrilamiento. | Obliga a reducir velocidad y aplicar el freno neumático con precisión. |
| **Pendientes** | Tramos ascendentes y descendentes. El consumo de carbón varía según la inclinación. | Subir cuesta más carbón; bajar permite ahorrar. Gestión estratégica de recursos. |
| **Andenes / Estaciones** | Zonas de parada con temporizador activo, pasajeros NPC y recompensas narrativas. | Punto de resolución de tensión. Llegar a tiempo premia; tarde penaliza. |
| **Zona de niebla densa** | Área más allá de los 50 m de visibilidad. El andén desaparece si el tiempo expira. | Penalización visual y dramática sin pantallas de error artificiales. |

### 4.2 Obstáculos del Entorno

El entorno incorpora tres tipos de obstáculos que mantienen la tensión durante toda la partida:

- **Obstáculo de recurso – El carbón:** el combustible se consume de forma dinámica y proporcional a la velocidad. El jugador debe encontrar constantemente el equilibrio entre velocidad y economía.
- **Obstáculo temporal – El reloj:** el temporizador de cada estación es el principal antagonista. No hay enemigos visibles; la amenaza es el tiempo que avanza sin piedad.
- **Obstáculo físico – Curvas y pendientes:** la geometría de la ruta impone límites de velocidad implícitos. Ignorarlos provoca el descarrilamiento del tren.

### 4.3 Puntos de Interés e Interacciones Clave

| Interacción | Descripción |
|---|---|
| **Regulador de vapor** | El jugador apunta el láser VR y empuja la palanca para acelerar el tren. |
| **Freno neumático** | Reduce velocidad para detención exacta en el andén sin sobrepasar. |
| **Panel de suministros** | Invierte puntos en carbón para continuar la ruta. Decisión estratégica. |
| **Silbato de vapor** | Sin efecto mecánico; crea presencia humana en la cabina solitaria. |
| **Andén con pasajero** | Punto de interés narrativo. Llegar a tiempo desbloquea el diario. |
| **Zona roja en medidor** | Único indicador de peligro en la interfaz diegética. Señal de alerta crítica. |

### 4.4 Loop Principal de Jugabilidad

```
1. Revisar instrumentos de cabina
        ↓
2. Acelerar con el regulador de vapor
        ↓
3. Administrar carbón, presión y velocidad
        ↓
4. Frenar con precisión antes de curvas o estaciones
        ↓
5. Llegar a tiempo → recoger pasajeros
        ↓
6. Obtener puntos y fragmentos narrativos
        ↓
7. Comprar carbón o conservar puntos
        ↓
8. Avanzar al siguiente tramo  ──────────────────────┐
        ↑                                             │
        └─────────────────────────────────────────────┘
```

> **Condición de fallo:** Carbón = 0 → Game Over | Temporizador = 0 → Pasajeros se retiran, historia perdida.

---

## 5. Presentación y Justificación Grupal

### 5.1 Decisiones de Diseño Justificadas

#### Decisión 1 – Niebla volumétrica como límite de visibilidad (50 m)

**Justificación:** Limitar la visibilidad cumple tres funciones simultáneas. Primero, crea aislamiento y urgencia narrativa coherente con la historia del maquinista solitario. Segundo, oculta los andenes con pasajeros perdidos sin transiciones artificiales. Tercero, permite optimización agresiva del renderizado al no procesar objetos más allá del límite, garantizando framerate estable en hardware VR de gama media.

#### Decisión 2 – Interfaz completamente diegética (sin HUD)

**Justificación:** En realidad virtual, los elementos superpuestos en pantalla rompen la inmersión porque el ojo no puede enfocarlos naturalmente. Al integrar toda la información en el tablero físico de la cabina, el jugador permanece dentro del mundo sin fricciones cognitivas. Esta decisión también refuerza la narrativa: el maquinista solo tiene las herramientas que tendría un maquinista real.

#### Decisión 3 – Estética Retro Realism (PSX / low-poly)

**Justificación:** La elección de modelos low-poly con texturas pixeladas no es una limitación técnica sino una decisión artística deliberada. La nostalgia visual activa una respuesta emocional que complementa la melancolía de la historia. Técnicamente, el bajo conteo de polígonos reduce la carga de renderizado y permite incorporar la niebla volumétrica sin comprometer el rendimiento en VR, donde mantener 72 FPS estables es crítico para evitar el motion sickness.

#### Decisión 4 – Pasajeros como siluetas anónimas

**Justificación:** Representar a los pasajeros como siluetas sin rostro amplifica el impacto emocional de su partida. Un personaje con rostro genera empatía diferenciada; una silueta genera empatía universal porque el jugador proyecta en ella lo que quiere. El silencio de los pasajeros que se retiran es más perturbador que cualquier animación de protesta: la ausencia es la verdadera penalización.

#### Decisión 5 – Sistema de carbón dinámico (no tasa fija)

**Justificación:** El consumo proporcional a la velocidad convierte cada ajuste del regulador en una microgestión con consecuencias encadenadas. Un sistema de tasa fija generaría un juego predecible. El sistema dinámico introduce incertidumbre calculada: el jugador sabe que ir más rápido gasta más carbón, pero no sabe exactamente cuánto le queda para la siguiente estación, manteniendo la tensión activa en todo momento.

### 5.2 Utilidad del Entorno dentro del Juego

El entorno de *El Paso de la Bruma* no es un decorado: es el **sistema central que genera la experiencia de juego**. Sin él, las mecánicas no tienen contexto ni tensión:

- La línea ferroviaria infinita **justifica** la necesidad de combustible.
- La niebla **justifica** el temporizador.
- Las montañas **justifican** las curvas y pendientes.
- Los andenes **justifican** la gestión de velocidad.

> **El entorno es el juego.** *El Paso de la Bruma* no podría transportarse a otro escenario sin perder su identidad. La elección del entorno montañoso, la ruta ferroviaria olvidada y la niebla constante son inseparables de la experiencia que *Echoes of the Rails* busca crear.

### 5.3 Distribución de Trabajo del Grupo #1

| Integrante | Responsabilidad Principal | Aporte al Entorno Virtual |
|---|---|---|
| **Jordan Guaman** | Diseño de mecánicas y sistema de carbón | Diseño de rutas y zonas de exploración. Lógica del loop de jugabilidad. |
| **Anthony Morales** | Desarrollo técnico – Godot 4.6 / VR | Implementación de Path3D, niebla volumétrica y sistema de renderizado. |
| **Mesias Mariscal** | Diseño visual y ambientación | Definición de paleta de color, estética Retro Realism y composición del escenario. |
| **Denise Rea** | Narrativa y diseño de personajes | Diseño de andenes, pasajeros NPC, diarios narrativos y justificación del entorno. |

---

## Conclusión

El entorno virtual de *Echoes of the Rails* demuestra que un escenario de videojuego bien diseñado no es un contenedor de mecánicas sino un **sistema narrativo activo**. *El Paso de la Bruma* integra coherentemente la historia, el objetivo medible, el género de simulación y las mecánicas de gestión de recursos en un espacio visual unificado por la estética Retro Realism y la niebla volumétrica.

Cada decisión de diseño —desde la interfaz diegética hasta el consumo dinámico de carbón, desde las siluetas anónimas de los pasajeros hasta la ausencia de puntuaciones visibles— está al servicio de una experiencia de **estrés tranquilo**: desafiante, inmersiva y emocionalmente resonante.

El entorno diseñado cumple con los cinco criterios de evaluación propuestos: es coherente con el videojuego, tiene una ambientación visual definida, clasifica claramente sus objetos, define rutas e interacciones funcionales, y puede ser justificado colectivamente por cada decisión que lo compone.

---

*Grupo #1 – CF Games | Echoes of the Rails | Universidad de las Fuerzas Armadas ESPE | Mayo 2026*
