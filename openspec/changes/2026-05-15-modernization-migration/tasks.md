# Tareas para la Migración a la Arquitectura Moderna

## 1. Mapeo y validación
- [x] Enumerar artefactos aún atados a legacy/src (clases, tests, ejemplos, helpers, paths).
    - `ParaxialBeams/BeamFactory.m` mantiene fallback a `src/beams`.
    - `setpaths.m` agrega paths legacy para compatibilidad.
    - Runners/tests (ej: `portable_runner.m`, `test_Wavefront.m`, `edge_cases/run_all_edge_tests.m`) aún usan `addpath` a `src/`.
    - `tests/legacy_compat/` verifica y prueba ausencia/control de aliases removidos.
    - Ejemplos y scripts en `examples/legacy/` dependen de Addons y plotting helpers legacy.
- [x] Detectar ejemplos y tests que aún requieren adaptadores o runners alternativos.
    - Testeo explícito de runners/paths duales en tests legacy, edge, performance.
    - Addons y helpers legacy sólo activos en scripts legacy/compatibilidad.

## 2. Refactorización y migración
- [ ] Migrar ejemplos y tests a la API moderna (`BeamFactory`, +paraxial/) asegurando equivalencia funcional.
- [ ] Actualizar runners y docs para reflejar solo paths modernos, salvo casos de compatibilidad documentada.

## 3. Gating para remoción legacy
- [ ] Implementar emisiones de warnings->errors en rutas/adaptadores en desuso siguiendo la política staged.
- [ ] Correr tests canonicos y legacy tras cada fase de limpieza.
- [ ] Asegurar comunicación en CHANGELOG y README antes de borrar helpers/adapters.

## 4. Confirmación de gates
- [ ] Validar que no quedan dependencias de usuarios/CI/tests sobre legacy.
- [ ] Documentar evidencia en artifacts OpenSpec y logs CI.
- [ ] Solo tras validar todo lo anterior, ejecutar remoción/destrucción física de rutas legacy.
