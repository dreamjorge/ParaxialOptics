# Diseño: limpieza de release y comunicación científica

Fecha: 2026-05-26

## Objetivo

Preparar el primer release público de `Simulation_Scripts` con una superficie limpia para usuarios de óptica, MATLAB y GNU Octave, sin perder la trazabilidad técnica ni la compatibilidad histórica que todavía sostiene parte del proyecto.

El trabajo separa tres intereses que no deben mezclarse: higiene del repositorio público, empaquetado limpio del release y comunicación para la comunidad científica. La IA se trata como una herramienta de ingeniería asistida, no como parte del producto final ni como sustituto del criterio físico, numérico o experimental.

## Alcance de limpieza pública

El repositorio contiene archivos útiles para sesiones de agentes y planificación, pero no todos pertenecen a la superficie pública de un paquete científico. La limpieza debe revisar y reclasificar artefactos como `.atl/skill-registry.md`, `plan.md`, `AGENTS.md` y `openspec/`.

La intención no es borrar memoria de ingeniería sin control. Los archivos de proceso pueden moverse a documentación interna, archivarse fuera del paquete o mantenerse en el repo si aportan transparencia. Lo que sí debe evitarse es que rutas locales, instrucciones de agentes o planes obsoletos aparezcan como parte natural del producto para usuarios finales.

## Alcance del release limpio

El paquete de release debe incluir solo los componentes necesarios para instalar, usar, probar y entender la librería. La superficie esperada es `+paraxial/`, `ParaxialBeams/`, `tests/`, ejemplos canónicos, documentación pública, metadata de paquete y scripts de instalación.

El flujo de release actual crea el toolbox MATLAB desde la raíz del proyecto. Ese comportamiento puede arrastrar `openspec/`, `.atl/`, planes históricos y otros artefactos internos. La implementación debe ajustar el empaquetado o introducir una etapa de staging para que los artefactos publicados representen la API canónica y no el historial operativo completo.

## Compatibilidad y legacy

No se eliminarán agresivamente `src/`, `legacy/compat/`, `examples/legacy/` ni `ParaxialBeams/Addons/` en este pase. La documentación existente indica que esas rutas todavía sostienen compatibilidad, reproducibilidad de investigación o scripts históricos.

La limpieza debe distinguir entre residuo operativo y compatibilidad científica. Un archivo generado por agente o un plan de sesión puede salir del release sin afectar resultados. Un helper usado por un script de tesis o una ruta `src/` con adaptadores deprecados requiere gates, tests y comunicación antes de removerse.

## Comunicación pública

El release debe ir acompañado por una nota breve y un borrador de LinkedIn. El mensaje para la comunidad de óptica debe enfatizar pragmatismo científico: APIs legibles, pruebas portables, reproducibilidad, documentación y una transición gradual desde scripts de investigación hacia librerías mantenibles.

La narrativa propuesta es que la IA puede ayudar a limpiar, auditar y documentar código científico, pero el valor sigue estando en el modelo físico, la validación numérica y la capacidad de compartir herramientas que otros investigadores puedan ejecutar.

## Resultado esperado

Al finalizar, el repositorio público tendrá menos ruido de herramientas de agente en su superficie visible, el release evitará empaquetar metadata interna y la documentación presentará `+paraxial/` como contrato canónico. La compatibilidad legacy quedará preservada salvo artefactos inequívocamente removibles bajo verificación.

La comunicación externa deberá invitar a la comunidad de óptica a adoptar un pragmatismo de codificación: construir software científico pequeño, verificable, instalable y útil para otros laboratorios.
