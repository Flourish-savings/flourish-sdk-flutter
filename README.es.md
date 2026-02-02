[<img width="400" src="https://github.com/Flourish-savings/flourish_sdk_flutter/blob/main/images/logo_flourish.png?raw=true"/>](https://flourishfi.com)
<br>
<br>
# Flourish SDK Flutter

🇺🇸 [English version](README.md)

Este plugin de Flutter permite la comunicación entre la implementación visual de la funcionalidad de Flourish.
<br>
<br>

Tabla de contenidos
=================

<!--ts-->
   * [Primeros Pasos](#primeros-pasos)
     * [Acerca del SDK](#acerca-del-sdk)
     * [Usando el SDK](#usando-el-sdk)
   * [Manejo de Errores](#manejo-de-errores)
   * [Eventos](#eventos)
   * [Ejemplos](#ejemplos)
<!--te-->
<br>

## Primeros Pasos
___

### Agregar Flourish a tu proyecto

En el archivo `pubspec.yaml` de tu proyecto, agrega la última versión del Flourish Flutter SDK a tus dependencias.
```yaml
# pubspec.yaml

dependencies:
  flourish_flutter_sdk: ^<última versión>
```

### Requisitos internos del SDK

Para usar este SDK, necesitarás los siguientes elementos:

- partnerId: un identificador único que será proporcionado por Flourish
- secret: una cadena que representa una clave, también proporcionada por Flourish
- customer_code: una cadena que representa un identificador tuyo

Este plugin puede ejecutarse en dos entornos diferentes:

- staging: En este entorno, puedes probar la funcionalidad sin afectar datos reales
- production: este entorno es para ejecutar la aplicación con datos reales
<br>
<br>

### Acerca del SDK

La integración con nosotros funciona de la siguiente manera: el cliente se autentica en nuestro backend
y devolvemos un token de acceso que le permite cargar nuestro webview. El SDK sirve para
encapsular y ayudar en la carga de este webview.

### Usando el SDK
___

### 1 - Inicialización

##<span style="color:red;">IMPORTANTE❗</span>


<div style="border: 1px solid grey; padding: 10px;">

**Para que el flujo funcione correctamente y para que tengamos las métricas correctas para demostrar nuestro valor, es extremadamente importante inicializar nuestro SDK al abrir tu App, por ejemplo al inicio o en la pantalla principal. Lo más importante es que no se inicialice al mismo tiempo que se abre nuestro módulo.**

</div>

___

En primer lugar, es necesario inicializar el SDK proporcionando las variables: `partnerId`, `secret`, `env`, `language` y `customerCode`.

```dart
    Flourish flourish = Flourish(
      partnerId: 'AQUÍ_USARÁS_TU_PARTNER_ID',
      secret: 'AQUÍ_USARÁS_TU_SECRET',
      env: Environment.staging,
      language: Language.spanish,
      customerCode: 'AQUÍ_USARÁS_TU_CUSTOMER_CODE',
      trackingId: 'AQUÍ_USARÁS_TU_CLAVE_DE_GOOGLE_ANALYTICS_ESTO_NO_ES_OBLIGATORIO',
      onError: (context, error) {
        developer.log('Error: ${error.code} - ${error.message}', name: 'MiApp');
        // Navegar a tu propia pantalla de error o mostrar un diálogo
      },
      onAuthError: (context) {
        developer.log('Error de autenticación - redirigiendo al login', name: 'MiApp');
        // Navegar a tu pantalla de login
      },
      onWebViewLoadError: (context, error) {
        developer.log('Error al cargar WebView: ${error.description}', name: 'MiApp');
        // Mostrar una pantalla de reintento o mensaje sin conexión
      },
    );
```

La variable `trackingId` se usa si deseas pasar tu clave de Google Analytics para poder monitorear el uso de nuestra plataforma por parte de tus usuarios.

### 2 - Abrir módulo Flourish

Finalmente debemos llamar al método `home()`.
```dart
  flourish.home();
```

## Manejo de Errores
___

El SDK proporciona tres callbacks opcionales de error que puedes pasar en el constructor:

| Callback | Cuándo se dispara | Comportamiento por defecto |
|---|---|---|
| `onError` | Errores de la web app (red, lógica de negocio, onboarding, mantenimiento) | Muestra una página de error con refresh de token |
| `onAuthError` | Token de autenticación inválido/expirado | Muestra una página de error con refresh de token |
| `onWebViewLoadError` | El WebView nativo no puede cargar (sin internet, DNS, timeout) | Muestra una página de error de conexión |

Todos los callbacks reciben un `BuildContext` para que puedas navegar a tus propias pantallas. Si no proporcionas un callback, el SDK usa sus páginas de error por defecto.

### Escenarios de error

Hay dos capas de errores:

1. **Errores nativos del WebView** — El dispositivo no puede alcanzar el servidor (sin internet, fallo de DNS, timeout, CloudFront 403). Manejado por `onWebViewLoadError`.
2. **Errores de la web app** — La web app cargó pero encontró un error (fallos de API, modo mantenimiento, errores de onboarding). Enviado vía JavaScript `postMessage` y manejado por `onError`.

### Escuchar eventos de error

También puedes escuchar eventos de error vía streams para fines de logging:

```dart
flourish.onErrorEvent((ErrorEvent event) {
  developer.log(
    'Error: ${event.code} - ${event.message}',
    name: 'MiApp',
    level: 1000,
  );
});
```

## EVENTOS
___

También puedes registrarte para algunos eventos para saber cuándo algo sucede dentro de nuestra plataforma.

Puedes escuchar un evento específico ya mapeado, un evento no mapeado, o todos los eventos si lo prefieres.

### Escuchar nuestros eventos mapeados

Tenemos algunos eventos ya mapeados que puedes escuchar por separado.

Por ejemplo, si necesitas saber cuándo finaliza nuestra función de Trivia, puedes escuchar el "TriviaGameFinishedEvent"

```dart
flourish.onTriviaGameFinishedEvent((TriviaGameFinishedEvent response) {
  developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'MiApp');
});
```
puedes encontrar todos nuestros eventos mapeados aquí:
https://github.com/Flourish-savings/flourish_sdk_flutter/tree/main/lib/events/types/v2

### Escuchar nuestros eventos no mapeados
Incluso si nuestra plataforma comienza a enviar nuevos eventos no mapeados, no será necesario actualizar la versión del SDK para consumirlos.

Solo comienza a escuchar los eventos genéricos

```dart
flourish.onGenericEvent((GenericEvent response) {
  developer.log('${response.name} - data: ${jsonEncode(response.data.toJson())}', name: 'MiApp');
});
```

### Escuchar todos los eventos
Pero si quieres escuchar todos los eventos, también tenemos eso para ti.

```dart
flourish.onAllEvent((Event response) {
  developer.log('Event: ${response.name}', name: 'MiApp');
});
```

### Eventos disponibles
aquí tienes todos los eventos que retornaremos

| Nombre del evento | Descripción                                                                              |
|---|------------------------------------------------------------------------------------------|
| BACK_BUTTON_PRESSED | Cuando necesitas saber cuándo el usuario hace clic en el botón de retroceso del menú.    |
| TRIVIA_GAME_FINISHED | Cuando necesitas saber cuándo el usuario termina un juego de Trivia.                     |
| TRIVIA_CLOSED | Cuando necesitas saber cuándo el usuario cerró el juego de Trivia.                       |
| REFERRAL_COPY | Cuando necesitas saber cuándo el usuario copia el código de referido al portapapeles.    |
| GIFT_CARD_COPY | Cuando necesitas saber cuándo el usuario copia el código de Gift Card al portapapeles.   |
| HOME_BANNER_ACTION | Cuando necesitas saber cuándo el usuario hace clic en el banner del inicio.              |
| MISSION_ACTION | Cuando necesitas saber cuándo el usuario hace clic en una tarjeta de misión.             |
| ERROR | Cuando necesitas saber cuándo ocurrió un error.                                          |


## Ejemplos
Dentro de este repositorio, tienes una aplicación de ejemplo para mostrar cómo integrarse con nosotros:

https://github.com/Flourish-savings/flourish_sdk_flutter/tree/main/example
<br>
