# PROA

Prevención y reeducación en obesidad y alimentación. App Flutter para Android (8.0 o superior).

## Correr

```bash
flutter run                          # con Firebase, necesita android/app/google-services.json
flutter run --dart-define=DEMO=true  # sin Firebase, datos en memoria, para revisar pantallas
```

APK para instalar: `flutter build apk --release`

## Firebase

Proyecto `proa-acb63` en la cuenta de Diego (organización estudiantesunibague.edu.co), plan gratuito Spark, Firestore en nam5. Ya configurado; estos son los pasos por si hay que rehacerlo


1. Proyecto en console.firebase.google.com con app Android `co.edu.unibague.proa`
2. Huellas SHA-1 de la app:
   - release `D3:67:B3:20:70:29:4E:C0:62:DE:68:7A:09:E5:14:14:97:3E:3B:92`
   - debug de este PC `94:17:C4:99:75:FB:61:D1:3F:E1:CD:54:A6:89:BF:B0:B5:DC:03:53`
3. Authentication: activar Google
4. Firestore: crear base y pegar `firestore.rules`
5. Descargar `google-services.json` a `android/app/`

Si se publica en Play Store, agregar también la SHA-1 de la firma de Google Play.

## Firma

`android/proa-release.jks` y `android/key.properties` firman el APK. Guárdalos en un lugar seguro, sin ellos no se puede actualizar la app instalada. No van al repositorio.

## Datos

Un documento por persona en `users/{uid}` con perfil, respuestas del test, plan, registros diarios, antojos, guías guardadas y recordatorios.
