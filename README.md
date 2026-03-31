<a id="readme-top"></a>

# Klinico 🏥 - App de Gestión Clínica Hospitalaria

Klinico es una plataforma integral para la gestión de pacientes, admisiones y episodios clínicos, diseñada bajo estándares de alta disponibilidad y robustez técnica. Este proyecto se centra en la digitalización del flujo de trabajo médico, desde el ingreso del paciente hasta su alta, así como en la automatización de KPIs de interés para jefes de servicio.

## Estructura del proyecto

```text
lib/
├── core/                # Configuración global, constantes, temas, interceptores API
├── data/                # Capa de datos (Acceso a Red / Almacenamiento Local)
│   ├── models/          # Clases de datos (User, Patient, Admission...)
│   ├── services/        # Clases que hacen las llamadas HTTP (Dio o Http)
│   └── repositories/    # Lógica para decidir si los datos vienen de Red o Local
├── ui/                  # Capa de Interfaz de Usuario
│   ├── views/           # Tus Widgets de pantalla (Login, MedicoHome, etc.)
│   ├── viewmodels/      # La lógica de cada pantalla (State Management)
│   └── widgets/         # Componentes reutilizables (Botones, Inputs propios)
└── main.dart            # Punto de entrada de la aplicación
```

## Arquitectura MVVM

```mermaid
flowchart TB
 subgraph View["Capa de Vista (UI)"]
        UI["<b>UI Components</b><br>LoginScreen, MedicoScreen"]
  end
 subgraph VM["Capa ViewModel (Estado)"]
        AuthVM["<b>AuthViewModel</b><br>Gestiona login/sesión"]
        DataVM["<b>OtrosViewModel</b><br>Gestiona datos clínicos"]
  end
 subgraph Logic["Capa de Servicios (Lógica)"]
        Srv["<b>Services</b><br>ScaleService, AuthService"]
  end
 subgraph Repo["Capa Repositorio (Abstracción)"]
        AuthRepo["<b>AuthRepository</b><br>Login / Logout"]
        ClinicalRepo["<b>OtrosRepositories</b><br>CRUD Ingresos, Episodios | KPIs"]
  end
 subgraph Infra["Capa de Infraestructura (Data)"]
        API["<b>API Client (Dio)</b><br>+ JWT Interceptor"]
        Storage["<b>Secure Storage</b><br>Persistencia del JWT"]
  end
    UI --> AuthVM & DataVM
    AuthVM --> Srv
    DataVM --> Srv
    Srv --> AuthRepo & ClinicalRepo
    AuthRepo --> API
    ClinicalRepo --> API
    AuthRepo -. "1. Guarda Token" .-> Storage
    API <-. "2. Inyecta Token en cada Header /
Redirige al Login si error 401" .-> Storage

    style View fill:#e1f5fe,stroke:#01579b
    style VM fill:#f5f5f5,stroke:#616161
    style Repo fill:#fff3e0,stroke:#e65100
    style Infra fill:#e8f5e9,stroke:#2e7d32
    style Logic fill:#E1BEE7

```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

