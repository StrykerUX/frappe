#!/bin/bash
set -e

# Script de inicialización para producción - Frappe CRM
echo "🚀 Iniciando Frappe CRM en modo producción..."

# Configurar variables
SITE_NAME=${SITE_NAME:-"frappe-crm.localhost"}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-"admin"}
DB_HOST=${DB_HOST:-"mariadb"}
REDIS_HOST=${REDIS_HOST:-"redis"}

# Esperar a que los servicios estén listos
echo "⏳ Esperando a que la base de datos esté lista..."
while ! mysqladmin ping -h"$DB_HOST" --silent; do
    sleep 1
done
echo "✅ Base de datos lista"

echo "⏳ Esperando a que Redis esté listo..."
while ! redis-cli -h "$REDIS_HOST" ping; do
    sleep 1
done
echo "✅ Redis listo"

# Inicializar bench si no existe
if [ ! -d "sites" ]; then
    echo "🔧 Inicializando nuevo bench..."
    bench init --skip-redis-config-generation --skip-assets frappe-bench
    cd frappe-bench
else
    echo "📁 Usando bench existente..."
    cd frappe-bench
fi

# Configurar base de datos y Redis en common_site_config.json
echo "🔧 Configurando conexiones de base de datos y Redis..."
cat > sites/common_site_config.json <<EOF
{
    "db_host": "$DB_HOST",
    "db_port": 3306,
    "redis_cache": "redis://$REDIS_HOST:6379",
    "redis_queue": "redis://$REDIS_HOST:6379",
    "redis_socketio": "redis://$REDIS_HOST:6379",
    "auto_update": false,
    "serve_default_site": true,
    "frappe_user": "frappe",
    "restart_supervisor_on_update": false,
    "restart_systemd_on_update": false,
    "shallow_clone": true,
    "background_workers": 1,
    "file_watcher_port": 6787,
    "socketio_port": 9000
}
EOF

# Instalar aplicación CRM si no existe el sitio
if [ ! -d "sites/$SITE_NAME" ]; then
    echo "🏗️  Creando nuevo sitio: $SITE_NAME"
    
    # Obtener la aplicación CRM
    if [ ! -d "apps/crm" ]; then
        echo "📦 Obteniendo aplicación CRM..."
        bench get-app crm --branch main
    fi
    
    # Crear el sitio e instalar CRM
    echo "🔨 Creando sitio e instalando CRM..."
    bench new-site "$SITE_NAME" \
        --admin-password "$ADMIN_PASSWORD" \
        --db-host "$DB_HOST" \
        --install-app crm \
        --force
    
    echo "✅ Sitio creado exitosamente"
else
    echo "📍 Sitio existente encontrado: $SITE_NAME"
    
    # Actualizar si es necesario
    echo "🔄 Actualizando sitio..."
    bench --site "$SITE_NAME" migrate
fi

# Configurar el sitio por defecto
echo "$SITE_NAME" > sites/currentsite.txt

# Construir assets para producción
echo "🎨 Construyendo assets para producción..."
bench --site "$SITE_NAME" build --production

# Configurar permisos
echo "🔐 Configurando permisos..."
chown -R frappe:frappe /home/frappe/frappe-bench

echo "🎉 ¡Frappe CRM iniciado exitosamente!"
echo "🌐 Accede a tu CRM en: http://$SITE_NAME:8000/crm"
echo "👤 Usuario: Administrator"
echo "🔑 Contraseña: $ADMIN_PASSWORD"

# Iniciar servidor
echo "🚀 Iniciando servidor Frappe..."
exec bench start