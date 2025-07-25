#!/bin/bash
set -e

echo "🚀 Iniciando Frappe CRM todo-en-uno..."

# Variables de entorno con valores por defecto
SITE_NAME=${SITE_NAME:-"frappe-crm.localhost"}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-"admin"}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-"frappe123"}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-"frappe456"}

echo "📊 Configuración:"
echo "  - Sitio: $SITE_NAME"
echo "  - Usuario admin: Administrator"

# Iniciar MariaDB
echo "🗄️  Iniciando MariaDB..."
service mariadb start

# Esperar a que MariaDB esté listo
echo "⏳ Esperando a que MariaDB esté listo..."
while ! mysqladmin ping --silent; do
    sleep 1
done
echo "✅ MariaDB listo"

# Configurar usuarios de base de datos si no existen
echo "🔧 Configurando base de datos..."
mysql -u root -e "CREATE USER IF NOT EXISTS 'frappe'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" 2>/dev/null || true
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'frappe'@'localhost';" 2>/dev/null || true
mysql -u root -e "FLUSH PRIVILEGES;" 2>/dev/null || true

# Iniciar Redis
echo "📊 Iniciando Redis..."
redis-server --daemonize yes

# Esperar a que Redis esté listo
echo "⏳ Esperando a que Redis esté listo..."
while ! redis-cli ping > /dev/null 2>&1; do
    sleep 1
done
echo "✅ Redis listo"

# Cambiar al directorio correcto
cd /home/frappe/frappe-bench

# Configurar permisos
chown -R frappe:frappe /home/frappe/frappe-bench

# Cambiar a usuario frappe para operaciones de bench
su - frappe -c "
cd /home/frappe/frappe-bench

# Obtener aplicación CRM si no existe
if [ ! -d \"apps/crm\" ]; then
    echo \"📦 Obteniendo aplicación CRM...\"
    bench get-app crm --branch main
fi

# Verificar si el sitio ya existe
if [ -d \"sites/$SITE_NAME\" ]; then
    echo \"🗑️  Eliminando sitio existente con credenciales antiguas...\"
    bench drop-site \"$SITE_NAME\" --db-root-password \"$MYSQL_ROOT_PASSWORD\" --force || true
    rm -rf \"sites/$SITE_NAME\" || true
fi

echo \"🏗️  Creando sitio: $SITE_NAME\"
    
# Crear sitio
echo \"🔨 Creando sitio e instalando CRM...\"
bench new-site \"$SITE_NAME\" \
    --admin-password \"$ADMIN_PASSWORD\" \
    --db-host localhost \
    --db-root-password \"$MYSQL_ROOT_PASSWORD\" \
    --install-app crm \
    --force

echo \"✅ Sitio creado exitosamente\"

# Configurar sitio por defecto
echo \"$SITE_NAME\" > sites/currentsite.txt

# Construir assets
echo \"🎨 Construyendo assets...\"
bench --site \"$SITE_NAME\" build --production || bench --site \"$SITE_NAME\" build

echo \"🎉 ¡Frappe CRM configurado exitosamente!\"
echo \"🌐 Sitio disponible en: http://localhost:8000/crm\"
echo \"👤 Usuario: Administrator\"
echo \"🔑 Contraseña: $ADMIN_PASSWORD\"
"

# Iniciar Frappe
echo "🚀 Iniciando servidor Frappe..."
cd /home/frappe/frappe-bench
su - frappe -c "cd /home/frappe/frappe-bench && bench start --bind 0.0.0.0 --port 8000"