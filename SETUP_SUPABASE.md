# INSTRUCCIONES PASO A PASO - CONFIGURACIÓN DE SUPABASE

## ✅ PASO 1: Crear Proyecto en Supabase

1. Ve a https://supabase.com/dashboard
2. Haz clic en "New project"
3. Selecciona tu organización
4. Nombre del proyecto: `buildausermanagement` (o el que prefieras)
5. Database Password: Anota esta contraseña en un lugar seguro
6. Region: Selecciona la más cercana a tu ubicación
7. Haz clic en "Create new project"
8. ⏳ Espera 2-3 minutos mientras se crea la base de datos

## ✅ PASO 2: Configurar Base de Datos

1. En el dashboard de tu proyecto, ve a "SQL Editor" (ícono de base de datos)
2. Haz clic en la pestaña "Quickstarts"
3. Busca "User Management Starter" 
4. Haz clic en "User Management Starter"
5. Haz clic en el botón "Run" (botón verde)
6. Verifica que aparezca el mensaje de éxito ✅

## ✅ PASO 3: Configurar Storage

1. Ve a "Storage" en el menú lateral
2. Haz clic en "Create a new bucket"
3. Nombre: `avatars`
4. ✅ Marca "Public bucket"
5. Haz clic en "Save"

## ✅ PASO 5: Configurar Storage para Avatares (Políticas)

En el panel de Supabase que tienes abierto:

1. **Crear el bucket:**
   - En la barra lateral izquierda, busca y haz clic en "Storage" (ícono de archivos)
   - Haz clic en "Create a new bucket"
   - Nombre del bucket: `avatars`
   - Haz clic en "Create bucket"

2. **Configurar las políticas del bucket:**
   - Una vez que hayas creado el bucket, haz clic en el bucket "avatars" que acabas de crear
   - Ve a la pestaña "Policies"
   - Haz clic en "New Policy"
   - Selecciona "For full customization"
   - Pega este código SQL:

```sql
-- Allow users to upload their own avatar
CREATE POLICY "Users can upload their own avatar" ON storage.objects
FOR INSERT WITH CHECK (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to update their own avatar
CREATE POLICY "Users can update their own avatar" ON storage.objects
FOR UPDATE USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to view their own avatar
CREATE POLICY "Users can view their own avatar" ON storage.objects
FOR SELECT USING (auth.uid()::text = (storage.foldername(name))[1]);
```

   - Haz clic en "Review" y luego "Save policy"

**Nota:** También puedes copiar el contenido del archivo `storage_policies.sql` incluido en este proyecto.

## ✅ PASO 4: Obtener Credenciales

1. Ve a "Settings" > "API" (ícono de engranaje)
2. 📋 Copia estos valores:

### Project URL:
```
https://[tu-proyecto-id].supabase.co
```

### API Key (anon/public):
```
eyJ0... (una clave muy larga)
```

## ✅ PASO 6: Configurar Authentication

1. Ve a "Authentication" > "URL Configuration"
2. En "Redirect URLs", agrega:
```
io.supabase.buildausermanagement://login-callback/
```
3. Haz clic en "Save"

## ✅ PASO 7: Configurar la App Flutter

1. Abre el archivo `lib/main.dart`
2. Reemplaza estas líneas:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',           // ← Pega tu Project URL aquí
  anonKey: 'YOUR_SUPABASE_PUBLISHABLE_KEY',  // ← Pega tu API Key aquí
);
```

**EJEMPLO:**
```dart
await Supabase.initialize(
  url: 'https://abcdefgh.supabase.co',
  anonKey: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...',
);
```

## ✅ PASO 8: Probar la Aplicación

1. Abre terminal en la carpeta del proyecto
2. Ejecuta:
```bash
flutter pub get
flutter run
```

## 🔧 Si hay problemas...

### Problema: "Failed to load"
- ✅ Verifica que las URLs y keys están correctas
- ✅ Verifica que no hay espacios extra al copiar/pegar

### Problema: "Magic link no funciona"
- ✅ Verifica que la redirect URL está configurada
- ✅ Revisa tu carpeta de spam en el email

### Problema: "No se pueden subir imágenes"
- ✅ Verifica que el bucket 'avatars' está marcado como público
- ✅ Ve a Storage > avatars > Settings > Make public

## 📧 Configurar Email (Opcional)

Por defecto Supabase usa un servicio de email básico. Para producción:

1. Ve a "Authentication" > "Settings"
2. Configura tu proveedor de email (SendGrid, etc.)
3. Personaliza las plantillas de email

## ✅ ¡LISTO!

Tu aplicación debe estar funcionando ahora. Puedes:
- 📧 Iniciar sesión con email (magic link)
- 👤 Actualizar tu perfil
- 📷 Subir una foto de perfil
- 🚪 Cerrar sesión

**¿Necesitas ayuda?** Revisa la consola de desarrollador en tu navegador o los logs de Flutter para más detalles sobre errores.