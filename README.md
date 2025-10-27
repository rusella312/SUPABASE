# Aplicación de Gestión de Usuarios con Flutter y Supabase

Esta es una aplicación completa de gestión de usuarios construida con Flutter y Supabase que incluye:

- 🔐 Autenticación con Magic Links
- 👤 Gestión de perfiles de usuario
- 📷 Subida de fotos de perfil
- 💾 Almacenamiento en base de datos PostgreSQL
- ☁️ Almacenamiento de archivos en la nube

## 🚀 Configuración del Proyecto

### 1. Configurar Supabase

1. **Crear un proyecto en Supabase:**
   - Ve a [https://supabase.com/dashboard](https://supabase.com/dashboard)
   - Haz clic en "New project"
   - Completa los detalles del proyecto
   - Espera a que la base de datos se lance

2. **Configurar el esquema de la base de datos:**
   - Ve a la página del Editor SQL en el Dashboard
   - Haz clic en "User Management Starter" bajo la pestaña Community > Quickstarts
   - Haz clic en "Run"

3. **Obtener las credenciales de la API:**
   - Ve a Settings > API en tu proyecto de Supabase
   - Copia la "Project URL"
   - Copia la "anon/public key"

### 2. Configurar la Aplicación Flutter

1. **Actualizar las credenciales:**
   - Abre el archivo `lib/main.dart`
   - Reemplaza `'YOUR_SUPABASE_URL'` con tu URL del proyecto
   - Reemplaza `'YOUR_SUPABASE_PUBLISHABLE_KEY'` con tu clave anon/public

2. **Configurar la URL de redirección:**
   - Ve a Authentication > URL Configuration en tu proyecto de Supabase
   - Agrega `io.supabase.buildausermanagement://login-callback/` como URL de redirección

### 3. Ejecutar la Aplicación

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en Android/iOS
flutter run

# Ejecutar en web
flutter run -d web-server --web-hostname localhost --web-port 3000
```

## 📱 Funcionalidades

### Autenticación
- Inicio de sesión sin contraseña usando Magic Links
- Los usuarios reciben un enlace por email para autenticarse
- Sesiones persistentes

### Gestión de Perfil
- Actualizar nombre de usuario y sitio web
- Subir y actualizar foto de perfil
- Cerrar sesión

### Seguridad
- Row Level Security (RLS) habilitado
- Los usuarios solo pueden ver y editar sus propios datos
- Almacenamiento seguro de archivos

## 🏗️ Estructura del Proyecto

```
lib/
├── components/
│   └── avatar.dart          # Widget para subir fotos
├── pages/
│   ├── login_page.dart      # Página de inicio de sesión
│   └── account_page.dart    # Página de perfil
├── main.dart                # Punto de entrada de la app
└── .env                     # Variables de entorno (ejemplo)
```

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo móvil
- **Supabase**: Backend-as-a-Service
  - PostgreSQL Database
  - Authentication
  - Storage
  - Row Level Security
- **Dart**: Lenguaje de programación

## 📝 Notas Importantes

1. **Deep Links**: Configurados para `io.supabase.buildausermanagement://login-callback/`
2. **Permisos de Storage**: El bucket 'avatars' debe estar configurado como público
3. **RLS**: Asegúrate de que las políticas de Row Level Security estén habilitadas
4. **Email**: Configura un proveedor de email en Supabase para Magic Links

## 🔧 Solución de Problemas

### La autenticación no funciona
- Verifica que la URL de redirección esté configurada correctamente
- Asegúrate de que las credenciales de Supabase sean correctas

### Error al subir imágenes
- Verifica que el bucket 'avatars' existe y es público
- Revisa las políticas de storage en Supabase

### Problemas de navegación
- Verifica que los deep links estén configurados en Android/iOS
- Asegúrate de que no hay conflictos de importación

## 📚 Recursos Adicionales

- [Documentación de Flutter](https://docs.flutter.dev/)
- [Documentación de Supabase](https://supabase.com/docs)
- [Tutorial original](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
