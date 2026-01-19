# Proyecto Star ⭐

Aplicación móvil familiar de gestión de tareas y mesada (allowance management system).

## Descripción

Proyecto Star es una aplicación móvil diseñada para ayudar a las familias a gestionar las tareas del hogar y la mesada de sus miembros. La aplicación incluye dos perfiles principales:

### Perfil Administrador
El administrador tiene las siguientes funcionalidades:
- ✅ Crear grupos familiares
- ✅ Crear checklists diarios de tareas del hogar
- ✅ Asignar recompensas de 1 a 5 estrellas por tarea
- ✅ Gestionar grupos y miembros
- ✅ Revisar tareas completadas semanalmente
- ✅ Ajustar estrellas de las tareas
- ✅ Aprobar o rechazar solicitudes de pago
- ✅ Procesar pagos mensuales

### Perfil Usuario
Los usuarios tienen las siguientes funcionalidades:
- ✅ Unirse a grupos familiares
- ✅ Ver tareas disponibles en su grupo
- ✅ Marcar tareas como completadas (máximo 48 horas)
- ✅ Visualizar estrellas acumuladas
- ✅ Solicitar pagos totales o parciales
- ✅ Ver historial de pagos

## Características Principales

### Sistema de Estrellas
- Las tareas tienen recompensas de 1 a 5 estrellas
- Los usuarios acumulan estrellas al completar tareas
- Las estrellas pueden canjearse por pagos

### Límite de Tiempo
- Todas las tareas tienen un plazo máximo de 48 horas
- Las tareas no completadas a tiempo se marcan como expiradas
- Indicadores visuales de urgencia (verde, naranja, rojo)

### Gestión de Pagos
- Los usuarios pueden solicitar pagos totales o parciales
- Los administradores revisan y aprueban/rechazan pagos
- Historial completo de transacciones
- Estados: Pendiente, Aprobado, Rechazado, Pagado

## Tecnología

Esta aplicación está desarrollada con:
- **Flutter**: Framework de desarrollo móvil multiplataforma
- **Provider**: Gestión de estado
- **Material Design 3**: Diseño moderno y atractivo

## Instalación

### Requisitos Previos
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (para desarrollo móvil)

### Pasos de Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/WaltherMoraRivera/Proyecto_Star.git
cd Proyecto_Star
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Ejecutar la aplicación:
```bash
flutter run
```

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
│   ├── user.dart            # Modelo de usuario
│   ├── group.dart           # Modelo de grupo
│   ├── task.dart            # Modelo de tarea
│   └── payment.dart         # Modelo de pago
├── providers/               # Gestión de estado
│   ├── auth_provider.dart   # Autenticación
│   ├── group_provider.dart  # Gestión de grupos
│   ├── task_provider.dart   # Gestión de tareas
│   └── payment_provider.dart # Gestión de pagos
├── screens/                 # Pantallas de la aplicación
│   ├── login_screen.dart
│   ├── admin_home_screen.dart
│   ├── admin_groups_screen.dart
│   ├── admin_tasks_screen.dart
│   ├── admin_payments_screen.dart
│   ├── user_home_screen.dart
│   ├── user_groups_screen.dart
│   ├── user_tasks_screen.dart
│   └── user_stars_screen.dart
└── widgets/                 # Widgets reutilizables
```

## Uso

### Inicio de Sesión
1. Abrir la aplicación
2. Ingresar nombre y email
3. Seleccionar tipo de perfil (Administrador o Usuario)
4. Presionar "Ingresar"

### Para Administradores

#### Crear un Grupo
1. Ir a la pestaña "Grupos"
2. Presionar el botón "Nuevo Grupo"
3. Ingresar el nombre del grupo
4. Presionar "Crear"

#### Crear una Tarea
1. Ir a la pestaña "Tareas"
2. Seleccionar un grupo
3. Presionar el botón "Nueva Tarea"
4. Completar los campos:
   - Título de la tarea
   - Descripción
   - Recompensa en estrellas (1-5)
5. Presionar "Crear"

#### Gestionar Pagos
1. Ir a la pestaña "Pagos"
2. Revisar las solicitudes pendientes
3. Aprobar o rechazar según corresponda
4. Marcar como pagado cuando se complete el pago

### Para Usuarios

#### Completar Tareas
1. Ir a la pestaña "Tareas"
2. Ver tareas disponibles en la pestaña "Disponibles"
3. Seleccionar una tarea
4. Presionar "Marcar como Completada"
5. Confirmar la acción

#### Solicitar Pago
1. Ir a la pestaña "Estrellas"
2. Presionar "Solicitar Pago"
3. Seleccionar:
   - Grupo
   - Tipo de pago (Total o Parcial)
   - Cantidad de estrellas (si es parcial)
   - Monto esperado
4. Presionar "Solicitar"

## Contribuir

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT.

## Contacto

Walther Mora Rivera - [GitHub](https://github.com/WaltherMoraRivera)

---

Hecho con ❤️ para familias

