"# backend_flutter" 

```
lib/
├── core/                        # Utilidades y configuraciones transversales
│   ├── network/                 # Configuración de Dio (base para Retrofit)
│   ├── database/                # Configuración de SQLite (Tablas, Migraciones)
│   ├── routing/                 # Configuración de rutas (ej. GoRouter)
│   ├── theme/                   # Colores, tipografías, estilos globales
│   └── errors/                  # Manejo de excepciones personalizadas
│
├── features/                    # Módulos de la aplicación
│   └── expenses/                # Ejemplo del módulo principal: Gastos
│       │
│       ├── data/                # [MODELO] Orígenes de datos y serialización
│       │   ├── models/          # DTOs (clases autogeneradas por json_serializable)
│       │   ├── local/           # DAOs y queries locales (SQLite)
│       │   ├── remote/          # Interfaces de Retrofit (API endpoints)
│       │   └── repositories/    # Implementación de la lógica de datos
│       │
│       ├── domain/              # [MODELO] Lógica de negocio abstracta
│       │   ├── entities/        # Objetos Dart puros (sin dependencias de frameworks)
│       │   └── repositories/    # Interfaces de los repositorios
│       │
│       └── presentation/        # [VISTA y VIEWMODEL]
│           ├── viewmodels/      # Providers de Riverpod (Notifiers / AsyncNotifiers)
│           ├── views/           # Pantallas completas (Scaffolds)
│           └── widgets/         # Componentes visuales específicos de este módulo
│
└── main.dart                    # Entry point y ProviderScope de Riverpod
│_ app.dart
```