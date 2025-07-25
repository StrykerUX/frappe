# Dockerfile para producción - Frappe CRM
FROM frappe/bench:latest

# Variables de entorno para producción
ENV FRAPPE_ENV=production
ENV DEVELOPER_MODE=0
ENV ADMIN_PASSWORD=admin
ENV INSTALL_APPS=crm

# Configurar directorio de trabajo
WORKDIR /home/frappe/frappe-bench

# Instalar dependencias del sistema necesarias para producción
USER root
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Volver al usuario frappe
USER frappe

# Copiar archivos de configuración
COPY --chown=frappe:frappe . /home/frappe/frappe-bench/apps/crm

# Exponer puertos
EXPOSE 8000 9000

# Script de inicio para producción
COPY docker/production-init.sh /home/frappe/production-init.sh
RUN chmod +x /home/frappe/production-init.sh

# Comando por defecto
CMD ["/home/frappe/production-init.sh"]