# Dockerfile todo-en-uno para producción - Frappe CRM
FROM ubuntu:22.04

# Variables de entorno
ENV DEBIAN_FRONTEND=noninteractive
ENV FRAPPE_ENV=production
ENV DEVELOPER_MODE=0
# Nota: Las contraseñas se configurarán via variables de entorno en runtime
ENV SITE_NAME=frappe-crm.localhost

# Instalar dependencias del sistema (sin Node.js)
RUN apt-get update && apt-get install -y \
    # Sistema base
    curl wget git build-essential \
    # Python y pip
    python3 python3-pip python3-venv python3-dev \
    # MariaDB
    mariadb-server mariadb-client \
    # Redis
    redis-server \
    # Nginx y supervisor
    nginx supervisor \
    # Herramientas adicionales
    fontconfig wkhtmltopdf \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js 18 (requerido por Frappe) - limpiar conflictos primero
RUN apt-get purge -y nodejs npm libnode-dev || true && \
    apt-get autoremove -y && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Instalar yarn
RUN npm install -g yarn

# Crear usuario frappe
RUN useradd -m -s /bin/bash frappe && \
    usermod -aG sudo frappe

# Configurar MariaDB - solo preparar directorios y permisos
RUN mkdir -p /var/run/mysqld && \
    chown mysql:mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql

# Configurar Redis
RUN echo "bind 127.0.0.1" >> /etc/redis/redis.conf

# Instalar bench (Frappe CLI)
RUN pip3 install frappe-bench

# Cambiar a usuario frappe
USER frappe
WORKDIR /home/frappe

# Crear directorio bench
RUN bench init --skip-redis-config-generation frappe-bench --python python3

# Cambiar al directorio bench
WORKDIR /home/frappe/frappe-bench

# Copiar código del CRM
COPY --chown=frappe:frappe . apps/crm/

# Configurar common_site_config.json para localhost
RUN echo '{\
    "db_host": "localhost",\
    "db_port": 3306,\
    "redis_cache": "redis://localhost:6379",\
    "redis_queue": "redis://localhost:6379",\
    "redis_socketio": "redis://localhost:6379",\
    "auto_update": false,\
    "serve_default_site": true,\
    "frappe_user": "frappe",\
    "restart_supervisor_on_update": false,\
    "restart_systemd_on_update": false,\
    "shallow_clone": true,\
    "background_workers": 1,\
    "file_watcher_port": 6787,\
    "socketio_port": 9000\
}' > sites/common_site_config.json

# Volver a root para configurar servicios
USER root

# Configurar supervisor
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Script de inicio
COPY docker/start-all.sh /start-all.sh
RUN chmod +x /start-all.sh

# Exponer puertos
EXPOSE 8000 9000

# Comando de inicio
CMD ["/start-all.sh"]