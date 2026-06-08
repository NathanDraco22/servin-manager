# Workflow: Crear un nuevo módulo CRUD

## 1. Generar scaffolding (automático)

```bash
onion dart <entidad>          --output-dir .\lib\src
onion dart-cubit <entidad>    --output-dir .\lib\src\modules\<entidad>\cubit
onion dart-view <entidad>     --output-dir .\lib\src\modules\<entidad>\view
```

Esto genera un esqueleto **parcialmente funcional** que requiere personalización manual.

---

## 2. Lo que el esqueleto NO hace (debes personalizar)

### 2a. Modelos (`lib/src/domain/models/<entidads>.py`)
El comando `onion dart` crea modelos vacíos. Debes rellenar los campos reales de la entidad.

Buscar en el backend (`service-manager-server/app/repos/v1/<entidad>/models/`) para conocer los campos.

**Patrón a seguir** (`lib/src/domain/models/servins.dart` o `users.dart`):
- `Base<Entidad>` con todos los campos + `fromJson()` / `toJson()`
- `Create<Entidad>` extiende `Base<Entidad>`
- `Update<Entidad>` con todos los campos nullable + `toJson()` que remueve nulos
- `<Entidad>InDb` extiende `Base<Entidad>` con `id`, `createdAt`, `updatedAt` + `fromJson()`

Eliminar la carpeta `user_model/` generada y crear el archivo manualmente.

### 2b. DataSource (`lib/src/data/<entidad>s_data_source.dart`)
El CLI genera `generateAuthHeaders()` que **no se usa** en este proyecto. Eliminarlo.

**Patrón** (`lib/src/data/servins_data_source.dart` o `users_data_source.dart`):
- Singleton con `_()` / `factory`
- Sin `headers` en las llamadas HTTP
- Endpoint en `_endpoint`
- Solo pasar `uri` y `body` a los métodos del mixin `HttpService`

### 2c. Repository (`lib/src/domain/repository/<entidad>s_repository.dart`)
El CLI genera con caché interno (`_items`, sort, search local). **Eliminar eso**.

**Patrón** (`lib/src/domain/repository/servins_repository.dart` o `users_repository.dart`):
- Sin caché, sin getter `items`, sin `searchLocal`
- Métodos planos: llamar al DataSource, convertir con `fromJson()`, retornar
- Usar `ListResponse<T>.fromJson()` en `getAll`

### 2d. Cubits (`lib/src/modules/<entidad>/cubit/`)

#### Read Cubit
El CLI genera tipos genéricos (`User` en vez de `UserInDb`). **Corregir**:
- Import real a `package:service_manager_front/src/domain/models/<entidad>s.dart`
- Import a `package:service_manager_front/src/domain/repository/repository.dart`
- Cambiar tipo `User` → `UserInDb` (o el tipo concreto `<Entidad>InDb`)
- **Inyectar repositorio** en el constructor: `{required this.<entidad>Repository}`
- **Implementar `getAll()`** con try/catch + `isClosed` checks
- **Implementar `getById()`** con try/catch + null check

**Si existe `ReactiveRepository`** en el proyecto (`lib/src/tools/reactive_repo/reactive_repository.dart`):
- Aplicar el mixin `ReactiveRepository<T>` al Repository
- Llamar `notifyItemCreated/Updated/Deleted` después de cada mutación
- En el ReadCubit, suscribirse al `eventStream` en el constructor:

```dart
ReadXxxCubit({required this.xxxRepository}) : super(ReadXxxInitial()) {
  xxxRepository.eventStream.listen((event) {
    if (event is RepoItemCreated<XxxInDb>) markXxxCreated(event.item);
    if (event is RepoItemUpdated<XxxInDb>) markXxxUpdated(event.item);
    if (event is RepoItemDeleted<XxxInDb>) markXxxDeleted(event.item);
  });
}
```

#### Write Cubit
- **Inyectar repositorio**: `{required this.<entidad>Repository}`
- **Implementar `create/update/delete`** con try/catch
- Ya no necesita llamar al ReadCubit (el ReactiveRepository se encarga)

### 2e. Estados
El CLI genera con tipos genéricos (`User`). Corregir a `<Entidad>InDb`:
- `ReadXxxSuccess.items` → `List<XxxInDb>`
- `WriteXxxSuccess.item` → `XxxInDb`
- Mantener `ReadXxxRefreshing`, `newItems`/`updatedItems`/`deletedItems`

### 2f. View
El CLI genera un placeholder. Dejarlo tal cual hasta que se requiera la UI concreta.

---

## 3. Archivos barrel y providers

- `lib/src/data/data.dart` → añadir `export '<entidad>s_data_source.dart';`
- `lib/src/domain/repository/repository.dart` → añadir `export '<entidad>s_repository.dart';`
- `lib/provider_container.dart` → añadir `RepositoryProvider` para el nuevo repositorio

---

## 4. Resumen: automático vs manual

| Paso | Automático (CLI) | Manual (agente) |
|------|------------------|-----------------|
| Models | Esqueleto vacío | **Rellenar campos** con `toJson()`/`fromJson()` |
| DataSource | Con `generateAuthHeaders()` | **Quitar headers**, dejar estilo proyecto |
| Repository | Con caché, sort, searchLocal | **Simplificar** sin caché |
| Read Cubit | Sin repo, tipos genéricos, TODOs | **Inyectar repo**, corregir tipos, implementar métodos, añadir reactive listener |
| Write Cubit | Sin repo, tipos genéricos, TODOs | **Inyectar repo**, corregir tipos, implementar métodos |
| Read State | Tipo genérico (`User`) | **Cambiar** a `<Entidad>InDb` |
| Write State | Tipo genérico (`User`) | **Cambiar** a `<Entidad>InDb` |
| View | Placeholder | Dejar igual (futuro) |
| Barrel files | Creados en `repositories/` (plural) | **Mover** a `repository/` (singular) siguiendo el proyecto y añadir exports |
