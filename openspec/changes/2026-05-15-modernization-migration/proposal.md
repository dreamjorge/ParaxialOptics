# Migration to Canonical Architecture

## Context and Motivation

La arquitectura moderna centraliza todo el desarrollo en `+paraxial/`, usando `BeamFactory` como contrato API y relegando `src/` a transición/compatibilidad. La documentación, ejemplos y tests actuales están alineados en esta estrategia (ver README.md, ROADMAP.md, ARCHITECTURE.md y AGENTS.md). Los cambios en arquitectura, limpieza de legacy y migración destructiva solo se permiten bajo SDD, con etapas y comunicación explícita.

## Problemas actuales

- Persisten adaptadores/legacy en `src/`, runners alternativos, ejemplos legacy e historical Addons.
- Aún existen riesgos de fuga de contextos legacy o de compatibility break si no se sigue el gating (migrar sin test o sin CI).
- Se necesita completar la migración a `+paraxial/`, asegurar runners/ejemplos/docs modernos, y ejecutar la etapa staged de limpieza del legacy deprecado, siguiendo las políticas y estrategias vigentes.

## Objetivos de la migración

- Que el usuario, el codebase y las automatizaciones CI sólo usen la superficie moderna.
- Que la remoción de legacy/compatibilidad se haga solo después de superar los gates técnicos, de usuarios y de comunicación descritos.
