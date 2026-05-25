# Documento de Diseño: Echoes of the Rails

> *"¡Llega a tiempo o quédate solo en la niebla!!"*

**Escrito por Grupo #1**  
**Integrantes:** Jordan Guaman · Anthony Morales · Mesias Mariscal · Denise Rea  
**Versión:** 1.00 — Tuesday, May 05, 2026  
**Estudio:** CF GAMES  

*This work is licensed under a Creative Commons Attribution 2.5 License.*

---

## Tabla de Contenidos

1. [Objetivo del Videojuego](#objetivo-del-videojuego)
2. [Diseño de la Historia](#diseño-de-la-historia)
3. [Información General del Juego](#información-general-del-juego)
   - [Filosofía del Juego](#filosofía-del-juego)
   - [Preguntas Comunes](#preguntas-comunes)
4. [Conjunto de Características](#conjunto-de-características)
5. [¿Cómo se Juega?](#cómo-se-juega)
6. [Personajes del Juego](#personajes-del-juego)
7. [Interfaz de Usuario](#interfaz-de-usuario)
8. [Armas o Herramientas](#armas-o-herramientas)
9. [Partituras Musicales y Efectos de Sonido](#partituras-musicales-y-efectos-de-sonido)
10. [Diseño del Motor Lógico](#diseño-del-motor-lógico)

---

## Objetivo del Videojuego

**Echoes of the Rails** es una experiencia de simulación ferroviaria en realidad virtual (VR) cuyo objetivo central es transportar pasajeros entre estaciones de montaña sin quedarse sin carbón, manteniendo la locomotora operativa durante la mayor cantidad de rutas posible.

### Objetivo Principal (medible)

- El jugador debe completar al menos **5 rutas consecutivas** sin que el medidor de carbón llegue a cero.
- En cada ruta, el jugador debe llegar a tiempo a un mínimo del **60% de las estaciones activas** para recibir suficientes puntos de recarga.
- El jugador gana acceso a los **fragmentos narrativos** (diarios de pasajeros) solo si llega antes de que el temporizador de cada andén expire.
- Al finalizar cada partida, el sistema registra: número de rutas completadas, pasajeros transportados y diarios desbloqueados.

### Objetivo de Experiencia

Que el jugador sienta la tensión emocional del tiempo, la soledad del maquinista y el valor de cada decisión al manejar el acelerador y el carbón. El juego busca una experiencia inmersiva de **"estrés tranquilo"**: desafiante pero nunca frustrante.

### Coherencia con el Diseño

Este objetivo guía todas las mecánicas: el sistema de carbón como recurso limitado, los temporizadores de estación, el puntero láser para interacción mínima, y el diseño sonoro que indica urgencia. Cada elemento del juego existe para servir a este objetivo.

---

## Diseño de la Historia

El juego sitúa al jugador como el **último maquinista** de una locomotora de vapor en una ruta montañosa olvidada. Esta línea ferroviaria, que alguna vez unió aldeas prósperas entre picos y valles, hoy es apenas un trazo oxidado en el mapa que nadie más recorre. No hay carreteras que lleguen hasta aquí. No hay reemplazos. Solo la vieja locomotora, y el maquinista que la conduce, mantienen vivo el hilo que conecta a estas comunidades con el resto del mundo.

> *Pero este no es un juego sobre conducir trenes. Es un juego sobre el peso de llegar a tiempo.*

El objetivo no es solo conducir, sino recolectar **fragmentos de la historia de los pasajeros** que esperan en los andenes. En cada parada hay alguien de pie en la niebla: una madre que busca a su hijo en la aldea del norte, un anciano que quizás haga este viaje por última vez, un joven que carga algo que no puede esperar. Nadie exige nada. Solo esperan, con la mirada puesta en las vías.

Si el jugador es eficiente y llega a tiempo, los pasajeros confían sus historias: dejan sobre el asiento una nota escrita a mano, una página de su diario, un instante de su vida. Esos fragmentos son la verdadera recompensa del viaje, no los puntos ni las rutas completadas.

Si el jugador llega tarde, el andén desaparece en la niebla. Los pasajeros no protestan ni reclaman; simplemente se van, como si nunca hubieran estado. Y en la cabina, el silencio se vuelve más pesado. No hay mensaje de error, no hay penalización visible: solo la ausencia, y la certeza de que algo quedó sin resolverse.

Es una carrera contra el tiempo y el desabastecimiento de carbón en un entorno de **realismo retro**, donde la niebla cubre el camino y el mundo parece terminar justo más allá de las vías.

---

## Información General del Juego

### Filosofía del Juego

**Punto #1** — Este juego busca la inmersión absoluta mediante el uso de **Godot 4.6** y su sistema de OpenXR. Fundamentalmente, estamos logrando una experiencia de gestión de recursos de "estrés tranquilo", donde el diseño sonoro orgánico es el motor de la narrativa.

**Punto #2** — El juego se ejecuta en hardware compatible con VR (Quest/PCVR). Creemos que la tendencia actual valora experiencias atmosféricas cortas pero mecánicamente pulidas, optimizando el rendimiento mediante niebla volumétrica.

### Preguntas Comunes

**¿De qué se trata el juego?**  
Es una experiencia de simulación y supervivencia técnica en realidad virtual donde el jugador asume el rol de un maquinista en una ruta ferroviaria de alta montaña. La mecánica central combina la conducción de precisión con la gestión estratégica de recursos: el jugador debe equilibrar la potencia de la caldera para mantener la velocidad, mientras monitorea el consumo de carbón.

**¿Por qué crear este juego?**  
Este proyecto nace de la necesidad de crear una experiencia de VR inmersiva que elimine la barrera de entrada de los controles complejos. Al centrar la interacción en un tablero de mandos fijo, se reduce la fatiga del usuario y se elimina el mareo por movimiento (*motion sickness*), permitiendo que el foco principal sea la atmósfera y la toma de decisiones bajo presión.

**¿En qué lugar ocurre el juego?**  
La acción se desarrolla en **"El Paso de la Bruma"**, un entorno de montaña infinito generado sobre un sistema de vías (Path3D). El paisaje está compuesto por bosques de pinos de baja poligonización y formaciones rocosas cortantes, todo bajo un cielo perpetuamente nublado. Se utiliza un sistema de niebla volumétrica densa nativa de Godot 4.6 para limitar la visibilidad a 50 metros.

**¿Cuántos personajes controla el juego? ¿Qué controlo?**  
El jugador controla a un único personaje: el maquinista, quien permanece en una posición fija dentro de la cabina de la locomotora (room-scale limitada). El control se ejerce sobre los mandos físicos de la máquina mediante un puntero láser:

- **Regulador de Vapor:** Controla la aceleración y el consumo de combustible.
- **Freno Neumático:** Gestiona la desaceleración para evitar pasarse de la estación o descarrilar en curvas.
- **Panel de Suministros:** Un sistema de botones para comprar sacos de carbón utilizando los puntos obtenidos por los pasajeros transportados.

**¿Cuál es el principal enfoque?**  
El enfoque principal es la **toma de decisiones bajo presión**: el jugador debe equilibrar constantemente la velocidad con el consumo de carbón, sabiendo que ir rápido agota el combustible y llegar tarde hace desaparecer a los pasajeros en la niebla.

**¿Qué le hace diferente de otros juegos?**  
Su principal diferenciador es la fusión de la estética **Retro Realism** (estilo visual de la quinta generación de consolas/PSX) con la fidelidad técnica de Godot 4.6. La integración de audio posicional diseñado en Reaper y una mecánica de interacción simplificada por láser lo convierten en un simulador táctil único en su clase dentro del ámbito académico.

---

## Conjunto de Características

### Características Generales

- **Simulación Ferroviaria:** El tren se desplaza de manera suave y continua sobre un sistema de vías generado mediante Path3D, adaptándose a las curvas y pendientes de la ruta montañosa. Acelerar demasiado en una curva tiene consecuencias, y frenar a destiempo puede significar pasarse de la estación.

- **Estética Retro:** El mundo visual está construido con texturas pixeladas de baja resolución y modelos low-poly que evocan la era de las consolas de los años noventa. Esta elección refuerza la sensación de nostalgia y melancolía que define la experiencia.

- **Sistema de Carbón:** El combustible no se consume a una tasa fija; su gasto es dinámico y responde directamente a la posición del acelerador. A mayor velocidad, mayor consumo. El jugador debe encontrar un equilibrio constante entre llegar a tiempo y no quedarse varado.

- **VR Optimizado:** El juego utiliza el *Foveated Rendering* nativo de Godot 4.6, concentrando la resolución donde el ojo humano realmente mira, manteniendo un rendimiento estable dentro del visor sin sacrificar la atmósfera visual.

### Características Multiplayer

**Single Player** — Experiencia exclusivamente individual. La decisión es intencional: el juego trata sobre la soledad del maquinista, y esa soledad no funciona si hay otra persona en la cabina.

---

## ¿Cómo se Juega?

El jugador inicia dentro de la cabina de la locomotora. Primero revisa los instrumentos principales: el reloj de llegada, el nivel de carbón y el medidor de presión. Luego, con el puntero láser, acciona el regulador de vapor para que el tren avance por la vía.

Desde ese momento debe vigilar constantemente el reloj y el medidor de carbón. Si llega a tiempo y frena correctamente en la estación, los pasajeros suben automáticamente, otorgan puntos y pueden desbloquear fragmentos narrativos. Si llega tarde, la niebla ya habrá cubierto el andén y la historia de ese pasajero se perderá para siempre.

### Loop Principal

1. Revisar instrumentos de cabina.
2. Acelerar con el regulador de vapor.
3. Administrar carbón, presión y velocidad.
4. Frenar con precisión antes de curvas o estaciones.
5. Llegar a tiempo para recoger pasajeros.
6. Obtener puntos y fragmentos narrativos.
7. Comprar carbón o conservar puntos.
8. Avanzar al siguiente tramo.

---

## Personajes del Juego

### Visión General

El protagonista es invisible, representado únicamente por su interacción con la máquina. No tiene rostro ni voz: su identidad se construye a través de las decisiones que toma en la cabina. Los pasajeros son sombras que habitan las estaciones, siluetas oscuras que esperan de pie en la niebla sin pronunciar una sola palabra.

### Crear un Personaje

No hay personalización. El jugador no elige apariencia, nombre ni habilidades. La identidad del maquinista emerge de cómo conduce, no de cómo se ve.

### "Enemigos y Monstruos"

- **IA de Pasajeros:** Los NPCs evalúan el tiempo de llegada del tren y existen en tres estados: *Esperar* (mientras el temporizador corre), *Abordar* (si el tren llega a tiempo), y *Retirarse* (cuando el temporizador llega a cero). No atacan: simplemente se marchan, y esa retirada silenciosa es suficiente para generar presión.

- **El Tiempo:** El reloj es el verdadero enemigo del juego. No hay monstruos ni antagonistas visibles; la amenaza es invisible y constante. Cuando el temporizador de una estación llega a cero, la niebla consume la estación y todo lo que ese pasajero cargaba desaparece con él.

---

## Interfaz de Usuario

### Visión General

La interfaz es completamente **diegética**: está integrada en el mundo 3D de la cabina del tren. No existe ningún HUD superpuesto en pantalla, ningún menú flotante ni indicador artificial. Toda la información vive dentro del mundo del juego, sobre el tablero físico de la locomotora.

### Detalle #1 — Medidor de Presión y Carbón

El tablero de la cabina cuenta con agujas físicas que indican en tiempo real el estado de la locomotora. Una aguja marca la presión de vapor y otra indica el nivel de carbón restante. Cuando el carbón se acerca al límite crítico, la aguja entra en una zona marcada en rojo: la única advertencia visual que el juego ofrece.

### Detalle #2 — Puntero Láser VR

El jugador interactúa con todos los elementos de la cabina mediante el puntero láser de su controlador VR. Al apuntar hacia un botón o palanca del tablero, el elemento se ilumina suavemente indicando que puede ser accionado. Este sistema elimina la necesidad de movimientos amplios, reduce la fatiga en VR y mantiene al jugador siempre anclado visualmente dentro de la cabina.

---

## Armas o Herramientas

### Visión General

La locomotora es la única herramienta del jugador. No hay inventario, no hay objetos que recoger ni equipamiento que gestionar.

### Detalle #1 — Palanca de Aceleración

Controla la variable de velocidad del tren. Al empujarla hacia adelante, el motor responde aumentando la potencia y el consumo de carbón de manera proporcional. Encontrar la posición correcta de la palanca —ni demasiado lenta para llegar a tiempo ni demasiado rápida para no agotar el combustible— es la **decisión técnica central del juego**.

### Detalle #2 — Silbato de Vapor

No tiene función práctica sobre las mecánicas del juego. El jugador puede accionarlo en cualquier momento con el puntero láser, produciendo un sonido característico que se propaga por la niebla. Es un elemento estético y de feedback sonoro: un pequeño gesto humano dentro de una cabina solitaria, y la única forma en que el maquinista puede hacerse notar en el silencio de la ruta.

---

## Partituras Musicales y Efectos de Sonido

### Visión General

El diseño sonoro es **minimalista, mecánico y diegético**. No hay música compuesta ni banda sonora orquestal: el audio del juego nace de la propia locomotora y del entorno que la rodea. El sonido funciona como información, atmósfera y narrativa al mismo tiempo.

### Información acerca del Audio

Todos los archivos de audio son `.wav` de alta calidad, procesados y mezclados en **Reaper**.

- **Track 1 — "Chugging Rhythm"** *(Loop dinámico)*: Representa el ritmo mecánico del motor. Cambia de pitch y tempo en tiempo real según la velocidad del tren.
- **Track 2 — "Wind & Fog"** *(Ambiente de fondo)*: El viento entre las montañas, el crujido de las vías y la presencia silenciosa de la niebla.

### Sonido 3D

Se utiliza la API de `AudioStreamPlayer3D` de Godot 4.6 para posicionar el audio en el espacio tridimensional de la cabina. El sonido del motor proviene de la parte frontal, el viento de los laterales y la campana de cada estación desde el exterior. En un entorno donde la niebla elimina la visibilidad, el **audio posicional** se convierte en la principal herramienta de orientación del jugador.

### Diseño del Sonido

El enfoque está en sonidos metálicos y de vapor grabados orgánicamente: herramientas reales, superficies metálicas, agua hirviente. Nada es sintético. Esta decisión refuerza la sensación de Retro Realism y hace que la locomotora se sienta como una máquina viva.

---

## Diseño del Motor Lógico

| Responsabilidad | Descripción | Ejemplo Práctico |
|---|---|---|
| **Reglas del juego** | El jugador debe manejar una locomotora de vapor, cuidar el carbón y llegar a las estaciones antes de que los pasajeros se vayan. | Completar 5 rutas seguidas sin que el carbón llegue a cero. |
| **Control del jugador** | El jugador controla los mandos de la cabina usando realidad virtual. No camina por el mapa, sino que maneja el tren desde su puesto. | Apuntar con el láser VR al regulador de vapor para acelerar o al freno neumático para detenerse. |
| **Comportamiento de NPCs** | Los pasajeros esperan en las estaciones durante un tiempo limitado. Si el tren llega a tiempo, suben; si llega tarde, se van. | Un pasajero espera en el andén, pero si el temporizador llega a cero, desaparece en la niebla. |
| **Estados del juego** | El juego cambia según lo que esté pasando: el tren viajando, llegando a una estación, recogiendo pasajeros o quedándose sin carbón. | Si el tren llega a una estación, el juego pasa al momento de recoger pasajeros. |
| **Eventos y triggers** | Algunas acciones se activan cuando el jugador cumple una condición dentro del juego. | Al detener el tren correctamente en el andén, se activa la subida de pasajeros. |
| **Sistema de puntuación** | El juego cuenta los puntos, las rutas completadas, los pasajeros transportados y los diarios desbloqueados. | Al recoger pasajeros, el jugador gana puntos que luego puede usar para comprar carbón. |
| **Actualización de frame** | El juego revisa constantemente lo que está ocurriendo mientras el tren avanza. | Mientras el tren se mueve, baja el carbón, cambia la velocidad y se actualizan las agujas del tablero. |
| **Validación de lógica** | El juego comprueba que las acciones tengan sentido antes de permitirlas. | No dejar subir pasajeros si el tren llegó tarde o si no se detuvo bien en la estación. |
| **Coordinación con otros sistemas** | El motor conecta el movimiento del tren con el sonido, la interfaz, los pasajeros y la experiencia VR. | Cuando el tren acelera, el sonido del motor cambia y el medidor de velocidad también se actualiza. |

---

*CF GAMES © 2026 — Evaluación Parcial 1*