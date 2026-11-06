# Botmate: guiado visual de un UR3 con ArUco y MATLAB

Contribución académica al proyecto Botmate, orientado a la asistencia de personas con discapacidad mediante robótica colaborativa. Una cámara conectada a una Raspberry Pi detecta un marcador ArUco; MATLAB estima su pose y calcula una posición objetivo para que un robot UR3 acerque la pinza a la pieza.

## Qué hace el proyecto

El sistema combina tres fuentes de información: la imagen de la cámara, la calibración de esa cámara y la pose actual de la herramienta del robot. Con ellas construye transformaciones homogéneas para expresar la posición del marcador en el sistema de coordenadas del robot. Después convierte el resultado al formato de pose de Universal Robots y envía un movimiento `movep` por TCP.

```text
Cámara Raspberry Pi → detección ArUco → pose del marcador
                                      + calibración cámara/pinza
                                      + pose actual del robot
                                      ↓
                         transformación a la base del robot
                                      ↓
                         pose objetivo → movep → programa de pinza
```

## Mi trabajo

- Integración de captura de imágenes desde Raspberry Pi con detección y estimación de pose ArUco en MATLAB.
- Cálculo y composición de transformaciones entre marcador, cámara, pinza y base del robot.
- Comunicación TCP con el controlador UR para recibir la pose actual y enviar una pose objetivo.
- Organización del flujo en funciones de detección, cálculo y movimiento.

## Tecnologías

MATLAB, Computer Vision Toolbox, Raspberry Pi Camera Board, marcadores ArUco, transformaciones homogéneas y comunicación TCP con Universal Robots. El código fue desarrollado alrededor de un **UR3**; los valores de calibración y los movimientos corresponden a ese montaje concreto.

## Estructura

| Elemento | Propósito |
| --- | --- |
| `ejecutarGuiadoAruco.m` | Orquesta el flujo completo. |
| `detectarAruco.m` | Busca un marcador en la imagen. |
| `estimarPoseAruco.m` | Estima su pose y aplica la relación cámara-pinza. |
| `recibirPoseUR3.m` | Recibe la pose del robot. |
| `iniciarProgramaUR3.m`, `moverUR3YEjecutarPrograma.m`, `esperarDeteccionAruco.m` | Comunicación y órdenes al robot. |
| `intrinsecosCamaraRaspberry.mat` | Calibración cargada por el detector. |
| [Guía técnica](docs/GUIA_TECNICA.md) | Requisitos, secuencia detallada y recalibración. |

## Alcance y reproducción

Este repositorio documenta el código MATLAB y los intrínsecos de cámara usados por el prototipo. Para repetirlo hacen falta una Raspberry Pi con cámara, un robot UR configurado y los programas PolyScope `test_calib_cam.urp` y `cogerpieza.urp` almacenados en su controlador. Esos programas no estaban en los archivos locales del proyecto y no están incluidos aquí. La guía técnica explica las conexiones y los valores que deben recalibrarse antes de usar otro montaje.

La calibración de la cámara, la posición de la cámara respecto a la pinza y el tamaño real del marcador afectan directamente a la pose calculada. Las coordenadas y direcciones IP del código son las del entorno original; no deben asumirse válidas en otra instalación.

> Proyecto académico presentado para mostrar el diseño e integración del sistema. El código no incluye una demostración ejecutable sin el hardware y los programas del controlador.
