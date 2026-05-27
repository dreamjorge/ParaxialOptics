# Borrador de LinkedIn: ParaxialOptics v1.0.0

Estoy preparando el primer release público de `ParaxialOptics`, una librería MATLAB/GNU Octave para propagación paraxial, modos Gaussianos, Hermite-Gaussianos, Laguerre-Gaussianos, haces tipo Hankel y análisis de frente de onda.

Más que anunciar otro repositorio, quiero compartir una idea con la comunidad de óptica: necesitamos recuperar el pragmatismo de codificar en ciencia.

Durante años muchos scripts científicos crecieron como cuadernos personales: funcionan en la computadora del autor, reproducen una figura, resuelven una tesis, pero son difíciles de instalar, probar o extender. La IA no corrige eso por sí sola. Lo que sí puede hacer, si se usa con criterio, es acelerar tareas de ingeniería que muchas veces posponemos: separar APIs, escribir tests, documentar decisiones, limpiar rutas legacy y preparar paquetes que otra persona pueda ejecutar.

En este release estoy dejando `+paraxial/` como namespace canónico, `BeamFactory.create()` como entrada práctica y una suite portable para Octave/MATLAB. El código histórico no se borra por moda: se preserva cuando sostiene reproducibilidad. La limpieza se aplica donde aporta claridad sin romper ciencia.

Ese es el nuevo pragmatismo que me interesa promover: no programar para impresionar, sino para que el conocimiento óptico sea verificable, instalable y compartible.

Si trabajas en óptica, fotónica o simulación científica y tienes scripts que merecen convertirse en herramientas reutilizables, me encantaría conversar.

#Optics #Photonics #MATLAB #Octave #ScientificComputing #OpenScience #ComputationalOptics

## Optional English summary

I am preparing the first public release of `ParaxialOptics`, a MATLAB/GNU Octave library for paraxial beam propagation and wavefront analysis. The goal is not only to share code, but to promote a pragmatic way of writing scientific software: tested APIs, reproducible examples, clear compatibility boundaries, and packages that other researchers can actually run.
