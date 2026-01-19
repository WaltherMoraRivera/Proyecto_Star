# Testing Guide for Proyecto Star

## Overview
This document describes how to test the Proyecto Star application manually and through automated tests.

## Prerequisites
- Flutter SDK installed (>=3.0.0)
- Android Studio or Xcode for mobile emulators
- A physical device (optional)

## Running the Application

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the Application
```bash
flutter run
```

### 3. Build for Production
```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## Manual Testing Scenarios

### Administrator Flow

#### TC-01: Login as Administrator
**Steps:**
1. Open the application
2. Enter name: "Admin Test"
3. Enter email: "admin@test.com"
4. Select role: "Administrador"
5. Click "Ingresar"

**Expected Result:**
- User is logged in as Administrator
- Admin dashboard is displayed
- Navigation bar shows: Inicio, Grupos, Tareas, Pagos

#### TC-02: Create a Group
**Steps:**
1. Login as Administrator
2. Navigate to "Grupos" tab
3. Click "Nuevo Grupo" button
4. Enter group name: "Familia Test"
5. Click "Crear"

**Expected Result:**
- Group is created successfully
- Success message is displayed
- Group appears in the list

#### TC-03: Create a Task
**Steps:**
1. Login as Administrator with at least one group created
2. Navigate to "Tareas" tab
3. Select a group from dropdown
4. Click "Nueva Tarea" button
5. Enter title: "Lavar los platos"
6. Enter description: "Lavar todos los platos después de la cena"
7. Select 3 stars as reward
8. Click "Crear"

**Expected Result:**
- Task is created successfully
- Task appears in the list with 3 stars
- Deadline is set to 48 hours from creation

#### TC-04: Adjust Task Stars
**Steps:**
1. Navigate to "Tareas" tab
2. Find a task in the list
3. Click the menu button (three dots)
4. Select "Ajustar Estrellas"
5. Select a different number of stars (e.g., 5)
6. Click "Guardar"

**Expected Result:**
- Stars are adjusted successfully
- Task now shows the new star count

#### TC-05: Approve Payment Request
**Steps:**
1. Navigate to "Pagos" tab
2. View "Pendientes" tab
3. Find a pending payment request
4. Click "Aprobar" button

**Expected Result:**
- Payment status changes to "Aprobado"
- Success message is displayed
- Payment moves to "Historial" tab

#### TC-06: Reject Payment Request
**Steps:**
1. Navigate to "Pagos" tab
2. View "Pendientes" tab
3. Find a pending payment request
4. Click "Rechazar" button
5. Enter rejection reason
6. Confirm rejection

**Expected Result:**
- Payment status changes to "Rechazado"
- Rejection reason is saved
- Payment moves to "Historial" tab

### User Flow

#### TC-07: Login as User
**Steps:**
1. Open the application
2. Enter name: "User Test"
3. Enter email: "user@test.com"
4. Select role: "Usuario"
5. Click "Ingresar"

**Expected Result:**
- User is logged in as regular User
- User dashboard is displayed
- Navigation bar shows: Inicio, Grupos, Tareas, Estrellas
- Initial accumulated stars: 0

#### TC-08: Complete a Task
**Steps:**
1. Login as User
2. Ensure you are in a group with available tasks
3. Navigate to "Tareas" tab
4. View "Disponibles" tab
5. Find a task
6. Click "Marcar como Completada"
7. Confirm the action

**Expected Result:**
- Task is marked as completed
- Stars are added to user's accumulated stars
- Success message shows star reward
- Task moves to "Mis Tareas" tab with "Completada" status

#### TC-09: Request Full Payment
**Steps:**
1. Login as User with accumulated stars > 0
2. Navigate to "Estrellas" tab
3. Click "Solicitar Pago" button
4. Select a group
5. Select "Pago Total"
6. Enter expected amount (e.g., "10.00")
7. Click "Solicitar"

**Expected Result:**
- Payment request is created
- Request appears in payment history
- Status is "Pendiente"

#### TC-10: Request Partial Payment
**Steps:**
1. Login as User with accumulated stars > 10
2. Navigate to "Estrellas" tab
3. Click "Solicitar Pago" button
4. Select a group
5. Select "Pago Parcial"
6. Enter stars to request (e.g., "5")
7. Enter expected amount (e.g., "5.00")
8. Click "Solicitar"

**Expected Result:**
- Payment request is created for partial amount
- Request appears in payment history
- Status is "Pendiente"

#### TC-11: View Task Urgency
**Steps:**
1. Login as User
2. Navigate to "Tareas" tab
3. View a task that has less than 12 hours remaining

**Expected Result:**
- Task shows red urgency indicator
- Time remaining is displayed in red
- Shows "Tiempo restante: Xh"

### Cross-functional Tests

#### TC-12: Task Expiration (48-hour deadline)
**Steps:**
1. Create a task as Administrator
2. Wait 48 hours (or manually adjust system time)
3. Check task status

**Expected Result:**
- Task status changes to "Expirada"
- Task cannot be completed by users
- Task shows expired status

#### TC-13: Star Accumulation
**Steps:**
1. Login as User with 0 stars
2. Complete a task worth 3 stars
3. Complete a task worth 5 stars
4. Check accumulated stars

**Expected Result:**
- Accumulated stars = 8
- Star count is displayed correctly in dashboard
- Star count is displayed correctly in "Estrellas" tab

#### TC-14: Payment Workflow
**Steps:**
1. User requests payment for 10 stars
2. Administrator approves payment
3. Administrator marks payment as paid

**Expected Result:**
- Payment status progresses: Pendiente → Aprobado → Pagado
- User can see status updates in payment history
- User's accumulated stars remain unchanged (stars are virtual currency)

## Edge Cases

### EC-01: Completing Task After Deadline
**Steps:**
1. Try to complete a task that has expired

**Expected Result:**
- Task cannot be completed
- Button is not available or disabled

### EC-02: Requesting Payment with 0 Stars
**Steps:**
1. Login as User with 0 stars
2. Try to request payment

**Expected Result:**
- "Solicitar Pago" button should be disabled or not visible
- If attempted, error message is displayed

### EC-03: Creating Task Without Group
**Steps:**
1. Login as Administrator with 0 groups
2. Navigate to "Tareas" tab

**Expected Result:**
- Message displayed: "Crea un grupo primero para gestionar tareas"
- Cannot create tasks

### EC-04: User Without Group
**Steps:**
1. Login as User not in any group
2. Navigate to "Tareas" tab

**Expected Result:**
- Message displayed: "Únete a un grupo para ver tareas"
- No tasks are visible

## Performance Tests

### PT-01: Load Many Tasks
**Scenario:** Create 100+ tasks and verify UI performance

**Expected Result:**
- List scrolls smoothly
- No lag or stuttering
- Tasks load within acceptable time

### PT-02: Multiple Users
**Scenario:** Simulate 10+ users completing tasks simultaneously

**Expected Result:**
- Star accumulation is accurate
- No data loss or corruption
- State updates correctly

## Automation Tests (Future Work)

The following test files should be created for automated testing:

```
test/
├── models/
│   ├── user_test.dart
│   ├── group_test.dart
│   ├── task_test.dart
│   └── payment_test.dart
├── providers/
│   ├── auth_provider_test.dart
│   ├── group_provider_test.dart
│   ├── task_provider_test.dart
│   └── payment_provider_test.dart
└── widgets/
    └── (widget tests for custom widgets)
```

### Running Automated Tests
```bash
flutter test
```

## Bug Reporting

When reporting bugs, include:
1. Test case number (e.g., TC-03)
2. Steps to reproduce
3. Expected result
4. Actual result
5. Screenshots or video
6. Device/Platform information
7. Flutter version

## Test Coverage Goals

- Unit tests: 80%+ coverage
- Widget tests: Key user flows covered
- Integration tests: End-to-end scenarios
- Manual testing: All test cases passed

## Notes

- This is a prototype application with in-memory storage
- Data is not persisted between app restarts
- For production, implement persistent storage (SQLite, Firebase, etc.)
- Add proper authentication and authorization
- Implement proper error handling and validation
