# Arquitectura del Sistema - Proyecto Star

## Visión General

Proyecto Star utiliza una arquitectura limpia basada en Flutter con el patrón Provider para la gestión del estado.

## Estructura de Capas

```
┌─────────────────────────────────────────────┐
│          Presentation Layer (UI)            │
│  ┌─────────────────────────────────────┐   │
│  │         Screens/Widgets             │   │
│  │  - LoginScreen                      │   │
│  │  - AdminHomeScreen                  │   │
│  │  - UserHomeScreen                   │   │
│  │  - AdminTasksScreen                 │   │
│  │  - UserTasksScreen                  │   │
│  │  - etc.                             │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
                    │
                    │ Provider.of / Consumer
                    ▼
┌─────────────────────────────────────────────┐
│         Business Logic Layer                │
│  ┌─────────────────────────────────────┐   │
│  │          Providers                  │   │
│  │  - AuthProvider                     │   │
│  │  - TaskProvider                     │   │
│  │  - GroupProvider                    │   │
│  │  - PaymentProvider                  │   │
│  │                                     │   │
│  │  (ChangeNotifier implementaciones)  │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
                    │
                    │ Models
                    ▼
┌─────────────────────────────────────────────┐
│            Data Layer                       │
│  ┌─────────────────────────────────────┐   │
│  │           Models                    │   │
│  │  - User                             │   │
│  │  - Task                             │   │
│  │  - Group                            │   │
│  │  - Payment                          │   │
│  │                                     │   │
│  │  (Inmutables con copyWith, JSON)   │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Componentes Principales

### 1. Presentation Layer (Capa de Presentación)

**Responsabilidad**: Mostrar la interfaz de usuario y capturar interacciones.

**Componentes**:
- `main.dart`: Punto de entrada, configura MultiProvider
- `screens/`: Pantallas completas de la aplicación
- `widgets/`: Componentes reutilizables (futuro)

**Características**:
- Uso de StatelessWidget cuando es posible
- StatefulWidget para estados locales (formularios, animaciones)
- Consumer/Provider.of para acceder al estado global

### 2. Business Logic Layer (Capa de Lógica de Negocio)

**Responsabilidad**: Gestionar el estado de la aplicación y la lógica de negocio.

**Providers**:

#### AuthProvider
```dart
Funciones:
- login(User user)
- logout()
- updateUser(User user)
- addStars(int stars)
- deductStars(int stars)

Estado:
- User? currentUser
- bool isAuthenticated
- bool isAdministrator
```

#### TaskProvider
```dart
Funciones:
- addTask(Task task)
- updateTask(Task task)
- completeTask(String taskId, String userId)
- adjustStars(String taskId, int newStarReward)
- checkExpiredTasks()
- deleteTask(String taskId)

Estado:
- List<Task> tasks
```

#### GroupProvider
```dart
Funciones:
- addGroup(Group group)
- updateGroup(Group group)
- addMemberToGroup(String groupId, String userId)
- removeMemberFromGroup(String groupId, String userId)
- deleteGroup(String groupId)

Estado:
- List<Group> groups
```

#### PaymentProvider
```dart
Funciones:
- addPayment(Payment payment)
- updatePayment(Payment payment)
- approvePayment(String paymentId, String adminId)
- rejectPayment(String paymentId, String adminId, String notes)
- markAsPaid(String paymentId)
- deletePayment(String paymentId)

Estado:
- List<Payment> payments
```

**Patrón**: ChangeNotifier
- Extienden ChangeNotifier
- Llaman a notifyListeners() después de cambios de estado
- Los widgets se suscriben automáticamente

### 3. Data Layer (Capa de Datos)

**Responsabilidad**: Definir estructuras de datos y serialización.

**Models**:

#### User
```dart
Propiedades:
- String id
- String name
- String email
- UserRole role (administrator/user)
- String? groupId
- int accumulatedStars

Métodos:
- copyWith()
- toJson()
- fromJson()
```

#### Group
```dart
Propiedades:
- String id
- String name
- String administratorId
- List<String> memberIds
- DateTime createdAt

Métodos:
- copyWith()
- toJson()
- fromJson()
```

#### Task
```dart
Propiedades:
- String id
- String title
- String description
- int starReward (1-5)
- String groupId
- DateTime createdAt
- DateTime deadline (48h)
- String? assignedUserId
- TaskStatus status
- DateTime? completedAt

Métodos:
- isExpired()
- copyWith()
- toJson()
- fromJson()
```

#### Payment
```dart
Propiedades:
- String id
- String userId
- String groupId
- int starsRequested
- double amount
- PaymentType type (total/partial)
- PaymentStatus status
- DateTime requestedAt
- DateTime? processedAt
- String? processedBy
- String? notes

Métodos:
- copyWith()
- toJson()
- fromJson()
```

## Flujo de Datos

### Lectura (Read Flow)
```
Screen/Widget
    │
    │ Consumer/Provider.of
    ▼
Provider (Estado)
    │
    │ Retorna datos
    ▼
Screen renderiza UI
```

### Escritura (Write Flow)
```
User Action (ej: botón presionado)
    │
    ▼
Screen llama método del Provider
    │
    ▼
Provider actualiza estado interno
    │
    ▼
Provider.notifyListeners()
    │
    ▼
Todos los Consumer se reconstruyen
    │
    ▼
UI se actualiza automáticamente
```

## Gestión de Estado

### Provider Pattern

**Ventajas**:
- Simple y fácil de entender
- Integrado con Flutter
- Buen rendimiento
- Testeable

**Implementación**:
```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => TaskProvider()),
    ChangeNotifierProvider(create: (_) => GroupProvider()),
    ChangeNotifierProvider(create: (_) => PaymentProvider()),
  ],
  child: MaterialApp(...)
)
```

**Consumo**:
```dart
// Opción 1: Consumer
Consumer<TaskProvider>(
  builder: (context, tasks, child) {
    return ListView(...)
  }
)

// Opción 2: Provider.of (con listen)
final tasks = Provider.of<TaskProvider>(context);

// Opción 3: context.watch (equivalente a Provider.of)
final tasks = context.watch<TaskProvider>();

// Opción 4: context.read (sin reconstruir)
context.read<TaskProvider>().addTask(task);
```

## Navegación

### Estructura de Navegación

```
LoginScreen
    │
    ├─ isAdministrator? ─┬─ AdminHomeScreen
    │                    │   ├─ Dashboard (Tab 0)
    │                    │   ├─ AdminGroupsScreen (Tab 1)
    │                    │   ├─ AdminTasksScreen (Tab 2)
    │                    │   └─ AdminPaymentsScreen (Tab 3)
    │                    │
    └─ isUser? ──────────┴─ UserHomeScreen
                            ├─ Dashboard (Tab 0)
                            ├─ UserGroupsScreen (Tab 1)
                            ├─ UserTasksScreen (Tab 2)
                            └─ UserStarsScreen (Tab 3)
```

**Tipo**: NavigationBar con tabs
**Estado**: Local (selectedIndex en StatefulWidget)

## Ciclo de Vida de los Datos

### Tareas (Tasks)

```
Creación (Admin)
    │
    ▼
Pendiente (48h deadline)
    │
    ├─ Usuario completa ──→ Completada
    │
    └─ Expira (48h) ──────→ Expirada
```

### Pagos (Payments)

```
Solicitud (User)
    │
    ▼
Pendiente
    │
    ├─ Admin aprueba ──→ Aprobado ──→ Pagado
    │
    └─ Admin rechaza ──→ Rechazado
```

### Estrellas (Stars)

```
Usuario completa tarea
    │
    ▼
accumulatedStars += task.starReward
    │
    ▼
Usuario puede solicitar pago
    │
    ▼
(Las estrellas no se decrementan,
 son moneda virtual hasta pago real)
```

## Patrones de Diseño Utilizados

### 1. Provider Pattern
- **Uso**: Gestión de estado global
- **Implementación**: ChangeNotifier + Provider

### 2. Repository Pattern (Implícito)
- **Uso**: Providers actúan como repositorios
- **Futuro**: Separar en capa de repositorio para persistencia

### 3. Factory Pattern
- **Uso**: `fromJson()` en modelos
- **Propósito**: Crear instancias desde JSON

### 4. Builder Pattern (implícito)
- **Uso**: `copyWith()` en modelos
- **Propósito**: Crear copias modificadas inmutables

### 5. Observer Pattern
- **Uso**: ChangeNotifier/Listeners
- **Propósito**: Notificar cambios de estado

## Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5        # State management
  intl: ^0.18.1          # Date formatting
  uuid: ^4.1.0           # ID generation
  cupertino_icons: ^1.0.2 # iOS-style icons
  shared_preferences: ^2.2.2 # Local storage (futuro)
```

## Consideraciones de Escalabilidad

### Actual (Prototype)
- Estado en memoria (se pierde al cerrar app)
- Sin persistencia
- Un solo usuario activo a la vez

### Futuro (Production)
- Agregar capa de persistencia:
  - Local: SQLite/Hive
  - Cloud: Firebase/Supabase
- Implementar Repository Pattern
- Agregar sincronización
- Multi-usuario con autenticación real
- Cache strategy

## Testing Strategy

### Unit Tests
- Modelos (toJson/fromJson)
- Providers (lógica de negocio)
- Utilities

### Widget Tests
- Screens individuales
- Componentes reutilizables
- Interacciones

### Integration Tests
- Flujos completos E2E
- Navegación
- Estado compartido

## Seguridad

### Actual
- Separación visual por roles
- Sin autenticación real
- Estado local no encriptado

### Recomendaciones Futuras
- Implementar Firebase Auth
- Tokens JWT
- Encriptación de datos sensibles
- Validación en backend
- Rate limiting

## Performance

### Optimizaciones Implementadas
- Consumer específicos (no rebuild innecesario)
- context.read() para acciones sin rebuild
- ListView.builder para listas largas
- Const constructors donde posible

### Métricas Objetivo
- Tiempo de carga: < 1s
- Scroll: 60fps
- Respuesta de acciones: < 100ms

## Conclusión

La arquitectura de Proyecto Star está diseñada para ser:
- **Simple**: Fácil de entender y mantener
- **Escalable**: Puede crecer con nuevas funcionalidades
- **Testeable**: Separación clara de responsabilidades
- **Mantenible**: Código organizado y documentado

La estructura actual es ideal para un prototipo/MVP, con un camino claro para evolucionar a una aplicación de producción completa.
