# Control de acceso vehicular inteligente

Aplicación móvil desarrollada como proyecto de tesis para gestionar el ingreso de visitantes en urbanizaciones privadas mediante **QR, OCR, reconocimiento facial y lectura de placas**.

El objetivo del prototipo es reducir la intervención manual en garitas de seguridad y construir un flujo de validación más ágil, trazable y consistente.

## 🎯 Funcionalidades principales

- Escaneo y validación de códigos QR para ingresos previamente autorizados.
- Ingreso sin QR mediante captura y lectura OCR de cédula.
- Validación facial del visitante.
- Registro de destino, manzana, villa y motivo de visita.
- Flujo de autorización mediante llamada automática.
- Captura y reconocimiento de placa vehicular.
- Flujos diferenciados para ingreso vehicular y peatonal.
- Manejo de estados de éxito, rechazo y validación en curso.

## 📱 Stack mobile

- Flutter / Dart
- Provider
- Mobile Scanner
- Camera
- Google ML Kit Face Detection
- Google ML Kit Text Recognition
- Flutter Secure Storage
- HTTP
- Media Kit
- Flutter SVG

## 🧠 Capacidades técnicas

| Área | Implementación |
| --- | --- |
| QR | Escaneo de códigos para validación de visitantes |
| OCR | Lectura de documento de identidad y placa |
| Biometría visual | Detección y validación facial |
| Video | Integración con fuentes de cámara |
| Seguridad local | Almacenamiento seguro |
| Estado | Provider |
| Integración | Consumo de servicios HTTP |

## 🔄 Flujo de ingreso

### Ingreso con QR

1. Escaneo del código QR.
2. Validación del código.
3. Confirmación o rechazo del ingreso.

### Ingreso sin QR

1. Captura del documento de identidad.
2. Lectura OCR.
3. Validación facial.
4. Selección de destino.
5. Registro del motivo de visita.
6. Solicitud de autorización.
7. Captura de la placa.
8. Resultado final del proceso.

## 🏗️ Enfoque de arquitectura

El proyecto separa la navegación, los flujos funcionales, la captura de información y la integración con servicios para mantener cada responsabilidad aislada y facilitar el mantenimiento.

Entre las pantallas y flujos principales se encuentran:

- Splash e inicio.
- Layout principal.
- Flujo de ingreso por QR.
- Flujo de ingreso sin QR.
- Captura de documento.
- Validación facial.
- Registro de destino y motivo.
- Lectura de placa.
- Estados de confirmación y rechazo.

## ⚙️ Requisitos

- Flutter compatible con Dart 3.10.3.
- Android Studio o VS Code.
- Dispositivo o emulador con soporte de cámara.
- Archivo de variables de entorno configurado.

## ▶️ Ejecución

~~~bash
flutter pub get
flutter run
~~~

El proyecto utiliza un archivo .env, por lo que debe configurarse antes de ejecutar la aplicación.

## 🧪 Tecnologías de visión utilizadas

El prototipo utiliza procesamiento visual en distintas etapas del flujo:

- **Mobile Scanner** para códigos QR.
- **ML Kit Text Recognition** para OCR.
- **ML Kit Face Detection** para detección facial.
- **Camera** para captura desde dispositivo.
- **Media Kit** para reproducción e integración de video.

## 📌 Contexto del proyecto

Este repositorio corresponde al componente móvil del proyecto de tesis orientado al control de acceso vehicular de visitantes. La solución completa contempla además servicios backend, persistencia y componentes de infraestructura para soportar las validaciones del flujo.

---

<div align="center">

### Seguridad, automatización y experiencia móvil aplicadas a un problema real

**Flutter · OCR · Reconocimiento facial · QR · Integración de servicios**

</div>
