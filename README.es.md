[<img width="400" src="https://github.com/Flourish-savings/flourish-sdk-flutter/blob/main/images/logo_flourish.png?raw=true"/>](https://flourishfi.com)
<br>
<br>
# Flourish SDK Flutter

Este plugin de Flutter permite la comunicaci&oacute;n entre la implementaci&oacute;n visual de las funcionalidades de Flourish.
<br>
<br>

Tabla de contenidos
=================

<!--ts-->
   * [Primeros Pasos](#primeros-pasos)
     * [Sobre el SDK](#sobre-el-sdk)
     * [Uso del SDK](#uso-del-sdk)
   * [Eventos](#eventos)
   * [Manejo de Errores](#manejo-de-errores)
   * [Ejemplos](#ejemplos)
<!--te-->
<br>

## Primeros Pasos
___

### Agregar Flourish a tu proyecto

En el archivo `pubspec.yaml` de tu proyecto, agrega la &uacute;ltima versi&oacute;n del SDK de Flourish Flutter a tus dependencias.
```yaml
# pubspec.yaml

dependencies:
  flourish_flutter_sdk: ^<latest version>
```

### Requisitos internos del SDK

Para utilizar este SDK, necesitar&aacute;s los siguientes elementos:

- uuid: un identificador &uacute;nico que ser&aacute; proporcionado por Flourish
- secret: una cadena que representa una clave, tambi&eacute;n proporcionada por Flourish
- customer_code: una cadena que representa un identificador de ti mismo

Este plugin puede ejecutarse en dos entornos diferentes:

- staging: En este entorno, puedes probar las funcionalidades sin impactar datos reales
- production: este entorno es para ejecutar la aplicaci&oacute;n con datos reales
<br>
<br>

### Sobre el SDK

La integraci&oacute;n con nosotros funciona de la siguiente manera: el cliente se autentica en nuestro backend
y le devolvemos un token de acceso que le permite cargar nuestra webview. Dado esto,
el SDK sirve para encapsular y ayudar en la carga de esta webview.

### Uso del SDK
___

### 1 - Inicializaci&oacute;n

##<span style="color:red;">IMPORTANTE&#10071;</span>


<div style="border: 1px solid grey; padding: 10px;">

**Para que el flujo funcione correctamente y para que tengamos las m&eacute;tricas correctas para demostrar nuestro valor, es extremadamente importante inicializar nuestro SDK al abrir tu App, por ejemplo al inicio o en la pantalla principal. Lo m&aacute;s importante es que no se inicialice al mismo tiempo que se abre nuestro m&oacute;dulo.**

</div>

___

En primer lugar, es necesario inicializar el SDK proporcionando las variables: `uuid`, `secret`, `env`, `language` y `customerCode`.

```dart
    Flourish flourish = await Flourish.create(
      uuid: 'AQUI_USARAS_TU_PARTNER_ID',
      secret: 'AQUI_USARAS_TU_SECRET',
      env: Environment.staging,
      language: Language.spanish,
      customerCode: 'AQUI_USARAS_TU_CUSTOMER_CODE',
      trackingId: 'AQUI_USARAS_TU_CLAVE_DE_GOOGLE_ANALYTICS_ESTO_NO_ES_OBLIGATORIO',
      onError: (context, errorEvent) {
        // Se ejecuta cuando la web app env&iacute;a un evento ERROR (errores de red, l&oacute;gica de negocio, mantenimiento)
        developer.log('Error: ${errorEvent.code} - ${errorEvent.message}', name: 'MyApp', level: 1000);
      },
      onAuthError: (context) {
        // Se ejecuta cuando la web app env&iacute;a un evento INVALID_TOKEN (fallo de autenticaci&oacute;n 401)
        // Usa esto para refrescar el token o redirigir al login
      },
      onWebViewLoadError: (context, error) {
        // Se ejecuta cuando el WebView no puede cargar (sin internet, fallo DNS, timeout)
        // Usa esto para mostrar una pantalla de error nativa personalizada
      },
    );
```

La variable `trackingId` se usa si deseas pasar tu clave de Google Analytics para poder monitorear el uso de nuestra plataforma por parte de tus usuarios.

Los callbacks de error (`onError`, `onAuthError`, `onWebViewLoadError`) son todos opcionales. Si no se proporcionan, el SDK muestra p&aacute;ginas de error predeterminadas. Consulta [Manejo de Errores](#manejo-de-errores) para m&aacute;s detalles.

### 2 - Abrir el m&oacute;dulo Flourish

Finalmente debemos llamar al m&eacute;todo `home()`.
```dart
  flourish.home();
```

#### Deep-link a una p&aacute;gina espec&iacute;fica (opcional)

`home()` acepta dos par&aacute;metros opcionales que permiten abrir el m&oacute;dulo
directamente en una p&aacute;gina espec&iacute;fica en lugar del punto de entrada por
defecto. Un caso de uso com&uacute;n es una **notificaci&oacute;n push** que lleva al
usuario directamente a una tienda asociada espec&iacute;fica:

```dart
  flourish.home(
    redirectTo: 'PARTNER_STORE_DETAIL', // la clave de la p&aacute;gina destino
    resourceId: '123',                  // el id del recurso (ej. el id de la tienda)
  );
```

- `redirectTo` — la clave de la p&aacute;gina a abrir. Om&iacute;telo (o pasa `null`)
  para el comportamiento por defecto.
- `resourceId` — el id para p&aacute;ginas que apuntan a un recurso espec&iacute;fico
  (como una tienda). Solo es necesario para p&aacute;ginas que lo requieren.

Estos valores se reenv&iacute;an a la web app, que los valida y vuelve de forma
segura a su p&aacute;gina por defecto si son desconocidos o inv&aacute;lidos.

## EVENTOS
___

Tambi&eacute;n puedes registrarte para recibir algunos eventos y saber cu&aacute;ndo algo ocurre dentro de nuestra plataforma.

Puedes escuchar un evento espec&iacute;fico ya mapeado, un evento no mapeado, o todos los eventos si lo prefieres.

### Escuchar nuestros eventos mapeados

Tenemos algunos eventos ya mapeados que puedes escuchar por separado.

Por ejemplo, si necesitas saber cu&aacute;ndo nuestra funcionalidad de Trivia termin&oacute;, puedes escuchar el "TriviaGameFinishedEvent"

```dart
flourish.onTriviaGameFinishedEvent((TriviaGameFinishedEvent response) {
  developer.log("${response.name} - data: ${jsonEncode(response.data.toJson())}", name: 'MyApp');
});
```
puedes encontrar todos nuestros eventos mapeados aqu&iacute;:
https://github.com/Flourish-savings/flourish-sdk-flutter/tree/main/lib/events/types/v2

### Escuchar nuestros eventos no mapeados
Incluso si nuestra plataforma comienza a enviar nuevos eventos no mapeados, no ser&aacute; necesario actualizar la versi&oacute;n del SDK para consumirlos.

Simplemente comienza a escuchar los eventos gen&eacute;ricos

```dart
flourish.onGenericEvent((GenericEvent response) {
  developer.log("${response.name} - data: ${jsonEncode(response.data?.toJson())}", name: 'MyApp');
});
```

### Escuchar todos los eventos
Pero si quieres escuchar todos los eventos, tambi&eacute;n tenemos eso para ti.

```dart
flourish.onAllEvent((Event response) {
  developer.log("Event: ${response.name}", name: 'MyApp');
});
```

### Eventos disponibles
aqu&iacute; tienes todos los eventos que retornaremos

| Nombre del evento              | Descripci&oacute;n                                                                                                                   |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------|
| BACK_BUTTON_PRESSED            | Cuando necesitas saber cu&aacute;ndo el usuario hace clic en el bot&oacute;n de retroceso del men&uacute; en nuestra plataforma.                       |
| ERROR_BACK_BUTTON_PRESSED      | Cuando necesitas saber cu&aacute;ndo el usuario hace clic en el bot&oacute;n de retroceso del men&uacute; en nuestra p&aacute;gina de error.                   |
| HOME_BACK_BUTTON_PRESSED       | Cuando necesitas saber cu&aacute;ndo el usuario hace clic en el bot&oacute;n de retroceso estando en la pantalla principal de nuestra plataforma. |
| ONBOARDING_BACK_BUTTON_PRESSED | Cuando necesitas saber cu&aacute;ndo el usuario hace clic en el bot&oacute;n de retroceso estando en la pantalla de onboarding.               |
| TERMS_ACCEPTED                 | Cuando necesitas saber cu&aacute;ndo el usuario acepta los t&eacute;rminos.                                                                  |
| TRIVIA_GAME_FINISHED           | Cuando necesitas saber cu&aacute;ndo el usuario termina un juego de Trivia en nuestra plataforma.                                    |
| TRIVIA_CLOSED                  | Cuando necesitas saber cu&aacute;ndo el usuario cerr&oacute; el juego de Trivia en nuestra plataforma.                                        |
| REFERRAL_COPY                  | Cuando necesitas saber cu&aacute;ndo el usuario copia el c&oacute;digo de referido al portapapeles.                                           |
| REFERRAL_FINISHED              | Cuando necesitas saber cu&aacute;ndo el referido finaliz&oacute;.                                                                            |
| REFERRAL_REWARD_REDEEMED       | Cuando necesitas saber cu&aacute;ndo el usuario canjea las recompensas de referido.                                                  |
| REFERRAL_REWARD_SKIPPED        | Cuando necesitas saber cu&aacute;ndo el usuario omiti&oacute; las recompensas de referido.                                                    |
| GIFT_CARD_COPY                 | Cuando necesitas saber cu&aacute;ndo el usuario copia el c&oacute;digo de Gift Card al portapapeles.                                          |
| HOME_BANNER_ACTION             | Cuando necesitas saber cu&aacute;ndo el usuario hace clic en el banner principal.                                                    |
| MISSION_ACTION                 | Cuando necesitas saber cu&aacute;ndo el usuario hace clic en una tarjeta de misi&oacute;n.                                                    |
| AUTHENTICATION_FAILURE         | Cuando necesitas saber cu&aacute;ndo la autenticaci&oacute;n fall&oacute;.                                                                            |
| ERROR                          | Cuando ocurre un error en la aplicaci&oacute;n web (red, l&oacute;gica de negocio, onboarding, mantenimiento).                               |
| INVALID_TOKEN                  | Cuando el token de sesi&oacute;n es inv&aacute;lido o expir&oacute; (401). Se despacha antes de ERROR.                                                |

## Manejo de Errores
___

El SDK maneja errores en dos niveles: **errores nativos del WebView** (antes de que la web app cargue) y **errores de la web app** (enviados v&iacute;a JavaScript postMessage despu&eacute;s de que la p&aacute;gina carga).

### Errores Nativos del WebView

Estos ocurren cuando el WebView no puede cargar la p&aacute;gina (ej: sin internet, fallo DNS, timeout). El SDK los detecta v&iacute;a `onWebResourceError` y muestra una p&aacute;gina predeterminada de "Sin conexi&oacute;n a internet".

| Error | Causa | P&aacute;gina Predeterminada |
|-------|-------|----------------------|
| `WebResourceErrorType.connect` | Fallo de conexi&oacute;n TCP (servidor inalcanzable, puerto bloqueado) | `WebViewLoadErrorPage` |
| `WebResourceErrorType.timeout` | Tiempo de espera agotado (com&uacute;n en regiones de alta latencia) | `WebViewLoadErrorPage` |
| `WebResourceErrorType.hostLookup` | Fallo en resoluci&oacute;n DNS | `WebViewLoadErrorPage` |
| C&oacute;digo de error `-1009` | iOS: dispositivo sin conexi&oacute;n a internet | `WebViewLoadErrorPage` |
| C&oacute;digo de error `403` | Acceso denegado de CloudFront / URL firmada expirada | `FlourishTokenErrorPage` |

Para proporcionar una UI personalizada para estos errores:

```dart
Flourish flourish = await Flourish.create(
  // ...
  onWebViewLoadError: (context, error) {
    // error.errorCode, error.errorType, error.description est&aacute;n disponibles
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MiPaginaDeErrorPersonalizada()),
    );
  },
);
```

### Errores de la Web App

Estos ocurren despu&eacute;s de que el WebView carga la p&aacute;gina. La web app comunica errores al SDK v&iacute;a `postMessage` a trav&eacute;s del canal JavaScript.

| Evento | Causa | Comportamiento Predeterminado |
|--------|-------|------------------------------|
| `INVALID_TOKEN` | Token expirado o inv&aacute;lido (HTTP 401) | Muestra `AuthErrorPage` (refresca el token autom&aacute;ticamente) |
| `ERROR` | Error de red, error de l&oacute;gica de negocio (422), fallo de onboarding, fallo de datos de mantenimiento | Muestra `FlourishTokenErrorPage` |
| `ERROR_BACK_BUTTON_PRESSED` | Usuario presion&oacute; retroceso en la p&aacute;gina de error | Despacha `GenericEvent` |

**Importante:** `INVALID_TOKEN` se despacha **antes** de `ERROR` por la web app. Si manejas `INVALID_TOKEN` (ej: refrescando el token), el evento `ERROR` subsiguiente puede ignorarse de forma segura.

Para manejar errores de la web app:

```dart
Flourish flourish = await Flourish.create(
  // ...
  onAuthError: (context) {
    // Manejar INVALID_TOKEN: refrescar token y recargar, o redirigir al login
  },
  onError: (context, errorEvent) {
    // Manejar ERROR: errorEvent.code y errorEvent.message contienen detalles
    developer.log('Error: ${errorEvent.code} - ${errorEvent.message}', name: 'MyApp', level: 1000);
  },
);
```

Tambi&eacute;n puedes escuchar eventos de error v&iacute;a el stream:

```dart
flourish.onErrorEvent((ErrorEvent event) {
  developer.log('Error: ${event.code} - ${event.message}', name: 'MyApp', level: 1000);
});
```

### Logging de Depuraci&oacute;n

El SDK usa `dart:developer` `log()` para logging estructurado y seguro para producci&oacute;n. Todos los logs del SDK usan el nombre `FlourishSDK`, lo que permite filtrar en Flutter DevTools.

Para ver los logs del SDK en DevTools, filtra por `FlourishSDK` en la pesta&ntilde;a de Logging.

Ejemplo de salida para un error de carga del WebView:
```
[FlourishSDK] WebView Load Error - code: -1009, type: WebResourceErrorType.hostLookup, description: net::ERR_NAME_NOT_RESOLVED, isForMainFrame: true
```

Niveles de log utilizados:
- **Default** (info): Carga de URL, mensajes JS, inicio de sesi&oacute;n exitoso
- **900** (warning): C&oacute;digo de referido faltante, errores de conectividad de red
- **1000** (error): Errores de carga del WebView, fallos al refrescar token

En tu propia app, usa `dart:developer` `log()` en lugar de `print()`:
```dart
import 'dart:developer' as developer;

flourish.onErrorEvent((ErrorEvent event) {
  developer.log(
    'Error: ${event.code} - ${event.message}',
    name: 'MyApp',
    level: 1000,
  );
});
```

## Ejemplos
Dentro de este repositorio, tienes una app de ejemplo para mostrar c&oacute;mo integrarte con nosotros:

https://github.com/Flourish-savings/flourish-sdk-flutter/tree/main/example
<br>
