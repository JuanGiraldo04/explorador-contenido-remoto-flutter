# Explorador de Contenido Remoto

App Flutter que consume la [Rick and Morty API](https://rickandmortyapi.com) para explorar personajes, episodios y locaciones de la serie.

---
# Demo

https://www.loom.com/share/b79aa334c0fe43c9a78d0f2028fba348

## Por qué Rick and Morty API

Se eligió esta API por tres razones concretas:

1. **Sin autenticación** — no requiere API key, lo que permite enfocarse en el aprendizaje sin fricción de configuración.
2. **Paginación real** — todos los endpoints devuelven paginación con `info.pages`, lo que permite practicar scroll infinito con datos reales.
3. **Modelo de datos rico** — los personajes tienen status, género, origen y locación, lo que permite practicar serialización con enums y objetos anidados.

---

## Endpoints usados

| Feature | Método | Endpoint | Descripción |
|---|---|---|---|
| Personajes | GET | `/character?page=&name=&status=` | Listado paginado con filtros |
| Episodios | GET | `/episode?page=&name=` | Listado paginado con búsqueda |
| Locaciones | GET | `/location?page=&name=` | Listado paginado con búsqueda |

Base URL: `https://rickandmortyapi.com/api`

---

## Estructura del proyecto

```
lib/
├── core/
│   ├── api/
│   │   └── api_endpoints.dart        # Constantes de endpoints
│   ├── errors/
│   │   ├── failure.dart              # Sealed class de errores de dominio
│   │   └── api_result.dart           # ApiResult<T> + executeApiCall
│   ├── providers/
│   │   └── dio_provider.dart         # Instancia global de Dio
│   └── widgets/
│       └── error_view.dart           # Widget reutilizable de error + retry
│
└── features/
    ├── character/
    │   ├── data/
    │   │   ├── datasources/remote/
    │   │   │   └── character_remote_datasource.dart
    │   │   ├── models/
    │   │   │   ├── character_model.dart
    │   │   │   └── character_page_model.dart
    │   │   └── repositories/
    │   │       └── character_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── character.dart         # Entidad + enums CharacterStatus/Gender
    │   │   │   ├── character_filter.dart
    │   │   │   └── character_page.dart
    │   │   ├── repositories/
    │   │   │   └── character_repository.dart   # Interfaz abstracta
    │   │   └── usecases/
    │   │       └── get_characters.dart
    │   └── presentation/
    │       ├── providers/
    │       │   ├── character_providers.dart
    │       │   └── character_list_notifier.dart
    │       ├── screens/
    │       │   ├── character_list_screen.dart
    │       │   └── character_detail_screen.dart
    │       └── widgets/
    │           └── character_card.dart
    │
    ├── episode/              # Misma estructura que character
    └── location/             # Misma estructura que character
```

---

## Arquitectura

Se implementó **Clean Architecture simplificada** con tres capas por feature:

**`data`** — todo lo que toca la red. El datasource llama a Dio y retorna modelos. El repositorio convierte los modelos a entidades del dominio llamando `.toEntity()`.

**`domain`** — el núcleo de la app. Contiene entidades Dart puras sin dependencias externas, la interfaz del repositorio y los casos de uso.

**`presentation`** — Riverpod + UI. Los providers construyen el grafo de dependencias, los notifiers manejan el estado, las pantallas consumen los notifiers.

El flujo de datos es siempre unidireccional:

```
UI → Provider → UseCase → Repository (interface)
                               ↓
                     RepositoryImpl → DataSource → Dio → API
```

---

## Manejo de estado

Se usa **Riverpod 3** sin generación de código. Cada feature tiene un `AsyncNotifier` que maneja cuatro estados:

| Estado | Cuándo ocurre |
|---|---|
| `AsyncLoading` | Primera carga o nueva búsqueda |
| `AsyncData` | Datos cargados correctamente |
| `AsyncError` | Fallo de red, 404, 500, etc. |
| `isLoadingMore` | Paginación mientras ya hay datos visibles |

---

## Manejo de errores

Todos los errores HTTP pasan por `executeApiCall`, que convierte excepciones de Dio en tipos de `Failure`:

| HTTP | Failure | Mensaje al usuario |
|---|---|---|
| 401 | `UnauthorizedFailure` | Sesión expirada |
| 404 | `NotFoundFailure` | Recurso no encontrado |
| 5xx | `ServerErrorFailure` | Error del servidor |
| Red / timeout | `NetworkFailure` | Sin conexión a internet |
| Otro | `UnknownFailure` | Error inesperado |

En búsquedas sin resultados la API retorna 404, lo que permite mostrar un estado vacío diferenciado del error genérico.

---

## Stack

| Herramienta | Versión | Uso |
|---|---|---|
| Flutter | stable | Framework |
| Dart | stable | Lenguaje |
| flutter_riverpod | ^3.3.1 | Gestión de estado |
| dio | ^5.9.2 | Cliente HTTP |

Sin generación de código. Sin freezed. Sin dartz.

---

## Cómo correr el proyecto

```bash
flutter pub get
flutter run
```

No se requiere configuración adicional. La API es pública y no necesita API key.