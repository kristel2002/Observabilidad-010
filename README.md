# Informe de Laboratorio: Stack de Observabilidad e IaC

**Alumna:** Kristel Catherine Rivera Chamorro  
**Enfoque:** Infraestructura como Código (IaC) y Telemetría Integrada  

---

## Descripción del Trabajo
Despliegue y configuración automatizada de un ecosistema de observabilidad sobre una arquitectura de microservicios (Frontend y Backend) utilizando Docker Compose. El sistema centraliza la telemetría mediante dos señales:
1. **Métricas (Prometheus):** Datos numéricos de rendimiento de hardware capturados vía *node-exporter* y *cAdvisor*.
2. **Logs (Loki):** Registros estructurados en JSON recolectados por **Grafana Alloy** desde los contenedores.

**Grafana** unifica el almacenamiento, genera los páneles visuales e implementa un motor de alertas para cerrar el ciclo de monitorización mediante notificaciones automáticas (*Webhooks*).

---

## 1. Levantar Stack
* **Propósito:** Inicializar, construir y comunicar todos los servicios del proyecto de forma automatizada y agnóstica mediante un comando único. Evita la configuración manual "a ciegas".
* **Componentes:** El binomio **Frontend/Backend** procesa la lógica de negocio; **Prometheus** actúa como almacén temporal de telemetría numérica y **Grafana** opera como la capa centralizada de visualización y orquestación de alertas.

## 2. Generar Tráfico y Logs
* **Propósito:** Simular comportamiento de usuarios en entornos de prueba para inyectar datos reales al stack. Sin tráfico no existen eventos numéricos en Prometheus ni trazas de texto en Loki. Permite validar de forma segura el rendimiento visual de los paneles y la sensibilidad de las alarmas.

## 3. Verificar las Fuentes de Datos (Data Sources)
* **Propósito:** Comprobar la conectividad de red interna entre Grafana y los motores de almacenamiento (Prometheus y Loki). Valida que la estrategia de aprovisionamiento como código (*provisioning*) funcionó correctamente en el arranque sin intervención manual.

## 4. Construir el Dashboard
* **Propósito:** Centralizar datos abstractos en gráficos interactivos en tiempo real para correlacionar eventos.
  * **4.1 CPU del Contenedor:** Mide el consumo de cómputo aislado del proceso del backend. Diagnostica bucles lógicos o sobrecargas específicas del servicio.
  * **4.2 CPU del Host:** Mide el estrés global del servidor virtualizado. Identifica cuellos de botella del sistema operativo o procesos externos al stack.
  * **4.3 Logs de Aplicación:** Muestra errores lógicos y trazas (JSON) de la app en Loki para descubrir el *porqué* de una falla (Causa Raíz).
  * **4.4 Logs de Infraestructura:** Registros internos del motor de contenedores y del stack de monitoreo. Sirve para vigilar la salud de las herramientas de supervisión.

## 5. Configurar la Alarma
* **Propósito:** Automatizar la monitorización definiendo umbrales lógicos (ej: CPU Backend > 50%). Utiliza intervalos de evaluación y periodos de gracia (*Pending*) para evitar la saturación por falsos positivos.

## 6. Probar la Alarma
* **Propósito:** Forzar picos de carga controlados para verificar la transición de estados de la regla (`Normal` -> `Pending` -> `Firing`). Garantiza la resiliencia técnica de la alerta antes del paso a producción.

## 7. Cerrar el Ciclo (Alarma ➔ Log)
* **Propósito:** Automatizar el flujo de retroalimentación. La anomalía numérica en Prometheus activa el motor de Grafana, el cual dispara un *Webhook* al endpoint del backend (`/alerts`). El backend procesa el evento, genera un log crudo que es capturado por Alloy, almacenado en Loki y devuelto al Dashboard, garantizando trazabilidad absoluta ante incidentes.

---

##  Cuestionario de Evaluación

### 1. ¿Por qué necesitamos Loki además de Prometheus si ya tenemos `/metrics`?
Porque manejan señales distintas. Prometheus recopila **métricas** numéricas ideales para saber *cuándo* falla el sistema. Loki almacena **logs** (texto/JSON) indispensables para diagnosticar *por qué* falló el código (causa raíz).

### 2. ¿Qué ventaja aporta que las fuentes de datos de Grafana estén aprovisionadas como código?
Garantiza repetibilidad, portabilidad y consistencia absoluta. El entorno de monitoreo se despliega idéntico en Local o Producción, elimina el error humano del clic manual y permite mantener el control de versiones mediante Git.

### 3. El panel "CPU contenedor" y "CPU host" muestran valores distintos. ¿Por qué? ¿Cuál usarías para alertar sobre una app concreta?
Difieren porque el Host mide el consumo general del servidor (S.O. y contenedores vecinos), mientras que el Contenedor mide únicamente el proceso aislado de la app. Para alertar sobre un servicio específico se debe usar el **CPU del contenedor**.

### 4. ¿Qué diferencia hay entre el *evaluation interval* y el *pending period* de una alarma?
El **Evaluation Interval** es la frecuencia fija con la que Grafana ejecuta la consulta de análisis (cada `10s`). El **Pending Period** es el tiempo de tolerancia continuo que la métrica debe violar el umbral (ej: `1m`) antes de enviar la notificación crítica, mitigando picos de estrés transitorios.

---

## Servicios utilizados

| Servicio | URL |
| :--- | :--- |
| **Frontend** | `http://localhost:8080` |
| **Backend (API)** | `http://localhost:3001` |
| **Grafana** | `http://localhost:3000` |
| **Prometheus** | `http://localhost:9090` |
| **Loki** | `http://localhost:3100` |
| **Alloy (UI)** | `http://localhost:12345` |
| **node-exporter** | `http://localhost:9100/metrics` |


##  Comandos de Verificación
```bash
# Construir e inicializar el stack de infraestructura en segundo plano
docker compose up -d --build

# Verificar el estado operativo de los contenedores desplegados
docker compose ps

