# Contexto de la Conversación - Kardex App (service_manager_front)

Este archivo registra el contexto de las interacciones y el estado del desarrollo de la aplicación `service_manager_front`.

## Estado del Proyecto

- **Módulos Existentes**:
  - `servin` (Vista, Cubits, Diálogos e Integración listos)
  - `user` (Modelos, Data Source, Repository, Cubits, Vista y Diálogos completamente implementados)
  - `auth` (Data Source, Repository y Cubit con soporte exclusivo para login de usuario e integración listos)
  - `login` (Vista premium de Login terminada e integrada como pantalla de inicio en `main.dart`)

## Sesión: 6 de Junio de 2026

### Tareas
1. **Revisión del módulo `user`**: Evaluación del estado de Cubits, Repository, Data Source y Modelos. Todo alineado a `AGENTS.md`.
2. **Implementación de la Vista y Diálogos de `user`**: Creación de la UI y los flujos de creación, edición y visualización detallada del usuario, siguiendo el patrón de `servin`.
3. **Implementación del Módulo `auth`**:
   - Creación de `AuthsDataSource` y `AuthsRepository` consumiendo el endpoint `POST /auths/login`.
   - Limpieza del scaffolding genérico de Auth (eliminación de `read_auths_cubit.dart` y `read_auths_state.dart`).
   - Implementación de `AuthCubit` y `AuthState` enfocados únicamente en el flujo de inicio de sesión de usuarios.
   - Reutilización de la dependencia del modelo `UserInDb` existente en `users.dart` dentro del repositorio de Auth.
4. **Implementación de la Vista de `login`**:
   - Generación del scaffolding de vista de login usando `onion dart-view login`.
   - Creación de una UI premium con gradientes, tarjeta de login, campos de entrada estilizados, toggle de visibilidad de contraseña e indicador de progreso asíncrono.
   - Modificación de `main.dart` para establecer `LoginsScreen` como pantalla inicial de la aplicación.

### Detalles de la Implementación
1.  **Modelos (`lib/src/domain/models/users.dart`)**:
    - Sigue el patrón definido en `AGENTS.md`. Posee `BaseUser`, `CreateUser`, `UpdateUser` y `UserInDb`.
    - Implementa correctamente la serialización `fromJson` y `toJson`.
2.  **DataSource (`lib/src/data/users_data_source.dart` y `auths_data_source.dart`)**:
    - `UsersDataSource`: Singleton, usa endpoint `/users`.
    - `AuthsDataSource`: Singleton, usa endpoint `/auths/login`.
3.  **Repository (`lib/src/domain/repository/users_repository.dart` y `auths_repository.dart`)**:
    - `UsersRepository`: Aplica `ReactiveRepository<UserInDb>`. Notifica mutaciones.
    - `AuthsRepository`: Consume `AuthsDataSource`, importa `UserInDb` para deserializar la respuesta del login y retorna una estructura ligera `LoginResult` (con `user`, `accessToken`, `refreshToken`).
4.  **Cubits (`lib/src/modules/user/cubit/` y `lib/src/cubits/auth_cubit/`)**:
    - `ReadUserCubit` y `WriteUserCubit`: Manejan lectura reactiva y mutaciones.
    - `AuthCubit`: Expone `login(username, password)` y despacha los estados `AuthInitial`, `AuthLoading`, `AuthSuccess` y `AuthError`.
5.  **Registro de Componentes**:
    - Registrados en los barrels `data.dart` y `repository.dart`.
    - Registrados en `lib/provider_container.dart`.
6.  **Vistas y Diálogos**:
    - **`users_view.dart`**: Implementa la lista de usuarios.
    - **`dialogs/user_editor_dialog.dart`**: Edición y creación de usuario.
    - **`dialogs/user_viewer_dialog.dart`**: Visor de detalles del usuario y eliminación interactiva reactiva.
    - **`logins_view.dart`**: Vista premium de inicio de sesión con soporte de carga e integración a `AuthCubit`. Navega a `ServinScreen` en login exitoso.
