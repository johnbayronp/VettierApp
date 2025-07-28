# Firebase Security Rules para MirallApp

## Reglas de Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Reglas para la colección users
    match /users/{userId} {
      // Permitir lectura y escritura si el usuario está autenticado y es el propietario
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Permitir escritura durante el registro (cuando el documento se crea)
      allow create: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reglas para la colección pets
    match /pets/{petId} {
      allow read, write: if request.auth != null;
    }
    
    // Reglas para la colección clinics
    match /clinics/{clinicId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.role == 'admin';
    }
    
    // Reglas para la colección appointments
    match /appointments/{appointmentId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Cómo aplicar las reglas:

1. **Ve a Firebase Console**
2. **Firestore Database**
3. **Reglas**
4. **Reemplaza las reglas existentes** con las de arriba
5. **Publica**

## Reglas temporales para desarrollo (menos seguras):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // ⚠️ SOLO PARA DESARROLLO
    }
  }
}
```

## Verificar configuración:

1. **Firebase Console** → **Authentication** → **Sign-in method**
2. **Habilitar** "Email/Password"
3. **Firestore Database** → **Reglas** → **Aplicar reglas correctas**
4. **Proyecto** → **Configuración** → **General** → **Verificar google-services.json**

## Debugging:

Si los usuarios no se guardan, verifica:

1. **Consola de Flutter** para logs de error
2. **Firebase Console** → **Authentication** → **Users** (debería aparecer)
3. **Firestore Database** → **users** collection (debería aparecer)
4. **Reglas de Firestore** (deberían permitir escritura)

## Logs esperados:

```
🔐 Iniciando registro de usuario: usuario@email.com
✅ Usuario creado en Firebase Auth con UID: abc123...
✅ DisplayName actualizado: Nombre Usuario
📝 Guardando datos en Firestore: {uid: abc123..., name: Nombre Usuario, ...}
✅ Usuario guardado exitosamente en Firestore
``` 