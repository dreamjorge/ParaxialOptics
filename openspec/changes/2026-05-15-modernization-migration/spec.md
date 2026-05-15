# Especificación Técnica — Migración y Modernización SDD

## Criterios de Éxito

- Solo los paths/api documentados en `README.md` y `docs/ARCHITECTURE.md` permanecen como onboarding/superficie canónica.
- Los ejemplos canónicos y los tests portables no dependen más de `src/` ni de constructores legacy.
- Todo usuario puede migrar siguiendo el README y las notas de migración.
- Runners de test y CI sólo usan la estructura moderna.
- No se elimina ningún helper ni legacy/adapter crítico sin haber pasado los gates de uso/test/ci/com.
- Todo cambio mayor deja evidencia en CHANGELOG.md y con artefactos OpenSpec actualizados.

## Restricciones y Non-Goals

- No se reescribe física/substrato numérico.
- No se elimina por completo legacy/compat hasta superar todas las gates (testing, señales de uso, comunicación, versionado).
- No se tocan addons “vendored-third-party” sin verificación de origen/licencia.
- No eliminar ejemplos/legacy usados por investigación sin consulta equivalente.

## Seguridad y Mitigación de Riesgos

- La migración se realiza por fases, siguiendo los planes de deprecación/remoção staged (warnings, errors, remove, doc, tests).
- Se auditan los tests canonicos y legacy en cada fase.
- Todo retiro real de código legacy queda reportado en artifacts y notas de version.
