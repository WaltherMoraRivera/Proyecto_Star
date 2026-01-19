# Características Detalladas - Proyecto Star

## Resumen Ejecutivo

Proyecto Star es una aplicación móvil de gestión familiar que permite a los administradores crear tareas del hogar con recompensas en forma de estrellas, y a los usuarios completar estas tareas para acumular estrellas que pueden canjear por pagos.

## Arquitectura de la Aplicación

### Patrones de Diseño
- **State Management**: Provider pattern para gestión reactiva del estado
- **MVC**: Separación clara entre Models, Views (Screens) y Controllers (Providers)
- **Composition**: Widgets reutilizables y componibles

### Flujo de Datos
```
User Action → Screen → Provider → Model → State Update → UI Refresh
```

## Características por Perfil

### 1. Perfil Administrador

#### 1.1 Dashboard Principal
**Descripción**: Panel de control con vista general del sistema.

**Componentes**:
- Tarjeta de perfil con nombre y rol
- Estadísticas en tiempo real:
  - Número total de grupos
  - Número total de tareas
  - Tareas completadas
  - Pagos pendientes
- Acciones rápidas para navegación

**Funcionalidades**:
- Visualización de métricas clave
- Navegación rápida a secciones importantes
- Indicadores de estado (badges) en navegación

#### 1.2 Gestión de Grupos
**Descripción**: Sistema para crear y administrar grupos familiares.

**Características**:
- Crear nuevos grupos con nombre personalizado
- Ver lista de todos los grupos administrados
- Contador de miembros por grupo
- Eliminar grupos (con confirmación)
- Fecha de creación del grupo

**Validaciones**:
- Nombre de grupo obligatorio
- Confirmación antes de eliminar
- Prevención de duplicados (opcional)

#### 1.3 Gestión de Tareas
**Descripción**: Sistema completo para crear y administrar tareas del hogar.

**Características**:
- Crear tareas con:
  - Título descriptivo
  - Descripción detallada
  - Recompensa de 1-5 estrellas
  - Deadline automático de 48 horas
- Selección de grupo para asignar tarea
- Visualización por grupo
- Ajuste de estrellas de tareas existentes
- Eliminación de tareas
- Indicadores de estado:
  - Pendiente (naranja)
  - Completada (verde)
  - Expirada (rojo)

**Reglas de Negocio**:
- Deadline fijo de 48 horas desde creación
- Las tareas expiradas no pueden completarse
- Solo se pueden crear tareas si existe al menos un grupo
- Las estrellas solo pueden ajustarse entre 1 y 5

#### 1.4 Gestión de Pagos
**Descripción**: Sistema de aprobación de solicitudes de pago.

**Características**:
- Vista de pagos pendientes y historial
- Información detallada de cada solicitud:
  - Usuario solicitante
  - Cantidad de estrellas
  - Monto solicitado
  - Tipo (Total/Parcial)
  - Fecha de solicitud
- Acciones disponibles:
  - Aprobar pago
  - Rechazar pago (con motivo)
  - Marcar como pagado
- Estados de pago:
  - Pendiente (naranja)
  - Aprobado (azul)
  - Rechazado (rojo)
  - Pagado (verde)

**Workflow**:
1. Usuario solicita pago → Pendiente
2. Admin aprueba → Aprobado
3. Admin realiza pago físico → Pagado

O bien:
1. Usuario solicita pago → Pendiente
2. Admin rechaza (con motivo) → Rechazado

### 2. Perfil Usuario

#### 2.1 Dashboard Principal
**Descripción**: Panel principal del usuario con resumen de actividad.

**Componentes**:
- Tarjeta de perfil con estrellas acumuladas
- Estadísticas personales:
  - Número de grupos
  - Tareas pendientes
  - Tareas completadas
  - Total de estrellas
- Recordatorios de tareas pendientes
- Accesos rápidos a funcionalidades

**Características Especiales**:
- Badge de estrellas prominente
- Alertas visuales para tareas urgentes
- Indicador de tareas por expirar

#### 2.2 Vista de Grupos
**Descripción**: Visualización de grupos a los que pertenece el usuario.

**Características**:
- Lista de grupos con información:
  - Nombre del grupo
  - Número de miembros
  - Fecha de creación
- Detalles del grupo en modal
- Estados de membresía

**Limitaciones**:
- Los usuarios no pueden crear grupos
- Los usuarios no pueden agregar/eliminar miembros
- Solo visualización de información del grupo

#### 2.3 Gestión de Tareas
**Descripción**: Sistema para visualizar y completar tareas.

**Características**:
- Dos vistas principales:
  - **Disponibles**: Tareas del grupo sin asignar
  - **Mis Tareas**: Tareas completadas por el usuario
- Información de cada tarea:
  - Título y descripción
  - Recompensa en estrellas (visual)
  - Deadline con countdown
  - Indicador de urgencia (color)
- Función de completar tarea:
  - Confirmación con vista previa de recompensa
  - Actualización inmediata de estrellas
  - Feedback visual de éxito

**Sistema de Urgencia**:
- Verde: Más de 24 horas restantes
- Naranja: Entre 12-24 horas restantes
- Rojo: Menos de 12 horas restantes

**Reglas de Negocio**:
- Solo se pueden completar tareas dentro del plazo
- Al completar, se asigna al usuario automáticamente
- Las estrellas se acreditan inmediatamente
- No se puede "des-completar" una tarea

#### 2.4 Sistema de Estrellas y Pagos
**Descripción**: Gestión de estrellas acumuladas y solicitudes de pago.

**Características**:
- Display prominente de estrellas acumuladas
- Historial completo de pagos:
  - Fecha de solicitud
  - Estado actual
  - Cantidad de estrellas
  - Monto solicitado
  - Notas del administrador (si hay rechazo)
- Solicitud de pago con opciones:
  - **Pago Total**: Todas las estrellas
  - **Pago Parcial**: Cantidad específica
- Selección de grupo para el pago
- Especificación de monto esperado

**Validaciones**:
- Solo se puede solicitar si hay estrellas > 0
- En pago parcial, cantidad ≤ estrellas acumuladas
- Monto debe ser un número válido
- Debe existir al menos un grupo

**Estados Visuales**:
- Pendiente: Ícono de reloj, color naranja
- Aprobado: Ícono de check, color azul
- Rechazado: Ícono de X, color rojo con motivo
- Pagado: Ícono de check completo, color verde

## Características Técnicas

### Sistema de Estrellas
- Contador global por usuario
- Incremento automático al completar tareas
- No se decrementan al solicitar pago (son virtuales hasta aprobación)
- Persistencia en memoria durante la sesión

### Sistema de Deadline (48 horas)
- Cálculo automático desde fecha de creación
- Verificación periódica de expiración
- Actualización automática de estado a "Expirada"
- Prevención de completar tareas expiradas

### Notificaciones y Feedback
- SnackBars para acciones exitosas
- Diálogos de confirmación para acciones críticas
- Badges en navegación para elementos pendientes
- Indicadores visuales de urgencia

### Responsive Design
- Adaptación a diferentes tamaños de pantalla
- ScrollView para contenido largo
- Cards para agrupación lógica de información
- Iconografía consistente

## Flujos de Usuario Principales

### Flujo 1: Crear y Completar Tarea
```
1. Admin crea grupo
2. Admin crea tarea (48h deadline)
3. Usuario ve tarea en "Disponibles"
4. Usuario completa tarea
5. Usuario recibe estrellas
6. Tarea aparece en "Mis Tareas" como completada
```

### Flujo 2: Solicitud y Aprobación de Pago
```
1. Usuario acumula estrellas
2. Usuario solicita pago
3. Admin ve solicitud en "Pendientes"
4. Admin aprueba o rechaza
5. Si aprueba: Admin marca como pagado
6. Usuario ve estado actualizado en historial
```

### Flujo 3: Expiración de Tarea
```
1. Admin crea tarea
2. Pasan 48 horas
3. Sistema marca tarea como expirada
4. Tarea ya no disponible para completar
5. Aparece con estado "Expirada" en lista admin
```

## Seguridad y Validaciones

### Validaciones de Formulario
- Campos obligatorios marcados claramente
- Validación en tiempo real
- Mensajes de error descriptivos
- Prevención de envío con datos inválidos

### Separación de Roles
- Los usuarios no ven funciones de administrador
- Los administradores tienen vista completa
- Navegación diferenciada por rol
- Permisos implícitos por tipo de usuario

## Mejoras Futuras Sugeridas

1. **Persistencia de Datos**
   - Integrar base de datos (SQLite/Firebase)
   - Sincronización en la nube
   - Backup automático

2. **Notificaciones Push**
   - Recordatorios de tareas por expirar
   - Notificaciones de aprobación de pago
   - Alertas de nuevas tareas

3. **Gamificación Avanzada**
   - Niveles de usuario
   - Logros y badges
   - Tabla de clasificación familiar
   - Racha de tareas completadas

4. **Estadísticas Detalladas**
   - Gráficos de rendimiento
   - Tendencias semanales/mensuales
   - Comparativas entre miembros
   - Exportación de reportes

5. **Funcionalidades Adicionales**
   - Tareas recurrentes
   - Tareas con subtareas
   - Comentarios en tareas
   - Adjuntar fotos de tarea completada
   - Chat familiar
   - Calendario de tareas

6. **Administración de Usuarios**
   - Invitaciones por email
   - Códigos de grupo
   - Perfiles editables
   - Avatares personalizados

7. **Sistema de Moneda**
   - Configurar valor monetario por estrella
   - Diferentes tipos de recompensas
   - Sistema de ahorro
   - Metas de ahorro

## Conclusión

Proyecto Star ofrece una solución completa para la gestión familiar de tareas y mesadas, con interfaces intuitivas para administradores y usuarios, un sistema robusto de recompensas, y flujos de trabajo bien definidos que facilitan la organización familiar y enseñan responsabilidad a los miembros más jóvenes.
