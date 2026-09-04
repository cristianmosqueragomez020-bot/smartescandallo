# Project TODO

- [ ] Localizar el repositorio o archivo fuente de SmartEscandallo y revisar `docs/ESTADO-DEL-PROYECTO.md`.
- [ ] Inventariar los paquetes existentes, sus pruebas y sus dependencias para planificar una migración verificable.
- [ ] Definir y documentar la arquitectura de producción, incluidos los límites operativos de procesamiento documental y mensajería.
- [ ] Validar los contratos actuales de Google Document AI y Twilio WhatsApp antes de integrarlos.
- [ ] Diseñar el modelo de organizaciones, restaurantes, miembros y permisos con aislamiento obligatorio de datos por organización.
- [ ] Crear y aplicar el esquema persistente para ingredientes, proveedores, albaranes, líneas de albarán, historial de precios, recetas, costes, recomendaciones, alertas, decisiones y umbrales.
- [ ] Migrar y cubrir con pruebas la lógica existente de costes, cambios de precio, priorización, recomendaciones, aprendizaje, texto de alerta y enrutamiento de WhatsApp.
- [ ] Incorporar trazabilidad para que aplicar o rechazar una recomendación actualice su alerta vinculada y preserve el motivo de la decisión.
- [ ] Implementar carga de albaranes, almacenamiento seguro y procesamiento documental con control de confianza y revisión manual de líneas inciertas.
- [ ] Implementar endpoints protegidos para los flujos de WhatsApp entrante y saliente, con validación de solicitudes y trazabilidad de conversaciones.
- [ ] Construir el panel de restaurante con visibilidad de costes, márgenes, cambios detectados, alertas, recomendaciones e historial de albaranes.
- [ ] Construir la pantalla de configuración de umbrales editable y limitada a la organización activa.
- [ ] Completar las pantallas restantes y estados de carga, vacío, error y permisos.
- [ ] Crear pruebas unitarias, de integración y de navegador para el flujo piloto de albarán a decisión y para el flujo de WhatsApp.
- [ ] Redactar configuración de entorno, guía de despliegue, operación, datos piloto y activación de Google Document AI y Twilio.
- [ ] Verificar visualmente la aplicación web en escritorio y móvil, ejecutar pruebas y comprobación de tipos.
- [ ] Guardar un punto de control de la aplicación terminada y dejarla preparada para publicación.
