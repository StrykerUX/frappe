# 🐳 Deploy Frappe CRM con Dokploy Compose Service

## 📋 Requisitos previos

### ✅ Lo que necesitas:
- **VPS** con Dokploy instalado
- **Dominio** configurado (ej: `crm.miempresa.com`)
- **Repositorio GitHub** con el código
- **Acceso admin** a Dokploy

### 💻 Recursos mínimos:
- **RAM**: 4GB mínimo (recomendado 8GB)
- **CPU**: 2 cores mínimo
- **Disco**: 20GB libres mínimo
- **Sistema**: Ubuntu 20.04+ o Debian 11+

---

## 🔧 Paso 1: Configurar DNS

1. **Ve a tu proveedor de dominio** (Cloudflare, Namecheap, etc.)
2. **Crea un registro A**:
   ```
   Tipo: A
   Nombre: crm (o @)
   Valor: IP_DE_TU_VPS
   TTL: 300 (5 minutos)
   ```
3. **Espera** 5-10 minutos para propagación

---

## 🐳 Paso 2: Crear servicio Compose en Dokploy

### 2.1 Acceder a Dokploy
1. Ve a: `http://TU_VPS_IP:3000`
2. Inicia sesión con tus credenciales

### 2.2 Crear nuevo proyecto (opcional)
1. Click en **"Create Project"**
2. Nombre: `frappe-crm-project`
3. Descripción: `Sistema CRM empresarial`

### 2.3 Crear servicio Compose
1. En tu proyecto, click **"Create Service"**
2. Selecciona **"Compose"** (NO Application)
3. **Service Name**: `frappe-crm-compose`
4. **Description**: `Frappe CRM con MariaDB y Redis`

---

## ⚙️ Paso 3: Configurar repositorio

### 3.1 Configuración básica
- **Source Type**: `GitHub`
- **Repository**: `https://github.com/TU-USUARIO/frappe.git`
- **Branch**: `production`
- **Compose File Path**: `docker-compose.dokploy.yml`

### 3.2 Build Configuration
- **Build Context**: `.`
- **Dockerfile**: `Dockerfile`
- **Auto Deploy**: ✅ (Activado)

---

## 🌍 Paso 4: Configurar variables de entorno

Ve a la pestaña **"Environment"** y agrega estas variables:

### Variables principales:
```bash
SITE_NAME=crm.miempresa.com
ADMIN_PASSWORD=MiPasswordSuperSeguro123!
MYSQL_ROOT_PASSWORD=RootPasswordMuySeguro456!
MYSQL_PASSWORD=FrappePasswordSeguro789!
```

### Variables adicionales (opcionales):
```bash
FRAPPE_ENV=production
DEVELOPER_MODE=0
```

### ⚠️ Notas importantes:
- **Cambia** `crm.miempresa.com` por tu dominio real
- **Usa contraseñas fuertes** diferentes entre sí
- **Guarda** las contraseñas en lugar seguro
- **NO uses** espacios en las contraseñas

---

## 🔗 Paso 5: Configurar dominio en Dokploy

### 5.1 Configurar dominio principal
1. Ve a la pestaña **"Domains"**
2. Click **"Add Domain"**
3. **Domain**: `crm.miempresa.com`
4. **Path**: `/` (raíz)
5. **Port**: `8000`
6. **HTTPS**: ✅ (Let's Encrypt automático)

### 5.2 Verificar configuración Traefik
- Dokploy configura Traefik automáticamente
- Los labels en el docker-compose son detectados automáticamente
- SSL se genera automáticamente con Let's Encrypt

---

## 🚀 Paso 6: Deploy inicial

### 6.1 Iniciar deployment
1. Ve a la pestaña **"Deployments"**
2. Click **"Deploy"**
3. **Monitorea los logs** en tiempo real

### 6.2 Proceso de deploy (toma 10-15 minutos):
```bash
🔄 Cloning repository...
🔨 Building Dockerfile...
🏗️  Creating services...
🗄️  Starting MariaDB...
📊 Starting Redis...
🚀 Starting Frappe application...
✅ All services running
```

### 6.3 Verificar estado de servicios
En la pestaña **"Services"**, todos deben mostrar:
- 🟢 **frappe-crm-db**: Running
- 🟢 **frappe-crm-redis**: Running  
- 🟢 **frappe-crm-app**: Running

---

## 🌐 Paso 7: Acceder al CRM

### 7.1 Primera conexión
1. Espera **5-10 minutos** después del deploy completo
2. Ve a: `https://crm.miempresa.com/crm`
3. **Usuario**: `Administrator`
4. **Contraseña**: La que configuraste en `ADMIN_PASSWORD`

### 7.2 Si no puedes acceder:
1. **Verifica logs** en Dokploy → Services → frappe-crm-app → Logs
2. **Comprueba DNS**: `nslookup crm.miempresa.com`
3. **Espera más tiempo**: La inicialización puede tomar hasta 15 minutos

---

## 🔧 Paso 8: Configuración inicial del CRM

### 8.1 Configuración básica:
1. **Cambiar contraseña admin**:
   - User → Administrator → Change Password

2. **Configurar empresa**:
   - Setup → Company Information
   - Agregar logo, dirección, etc.

3. **Crear usuarios**:
   - Settings → Users → Add User
   - Asignar roles apropiados

### 8.2 Configuraciones recomendadas:
- **Email Settings**: Configurar SMTP para envío de emails
- **System Settings**: Ajustar zona horaria y idioma
- **Backup Settings**: Configurar respaldos automáticos

---

## 📊 Monitoreo y mantenimiento

### 9.1 Monitorear estado:
- **Dokploy Dashboard**: Ver estado de servicios
- **Logs**: Revisar logs regularmente para errores
- **Recursos**: Monitorear CPU, RAM y disco

### 9.2 Actualizaciones:
1. **Git push** nuevos cambios al repositorio
2. **Auto-deploy** se ejecuta automáticamente
3. **Monitorear** el proceso en Dokploy

### 9.3 Respaldos:
- **Volúmenes**: Dokploy respalda volúmenes automáticamente
- **Base de datos**: Configurar respaldos automáticos de MySQL
- **Archivos**: Los uploads se guardan en volúmenes persistentes

---

## 🔍 Troubleshooting

### ❌ Error: "Site not found"
**Solución:**
1. Verificar que `SITE_NAME` coincide con tu dominio
2. Revisar logs del contenedor frappe-crm-app
3. Esperar más tiempo (proceso de creación de sitio)

### ❌ Error: "Database connection failed"
**Solución:**
1. Verificar contraseñas en variables de entorno
2. Asegurar que MariaDB está corriendo (healthcheck verde)
3. Revisar logs de mariadb

### ❌ Error: "502 Bad Gateway"
**Solución:**
1. Verificar que la aplicación está corriendo en puerto 8000
2. Revisar healthcheck del contenedor
3. Reiniciar el servicio

### ❌ Dominio no accesible
**Solución:**
1. Verificar configuración DNS (registro A)
2. Esperar propagación DNS (hasta 24h)
3. Verificar que Traefik está funcionando

### ❌ SSL certificate error
**Solución:**
1. Verificar que el dominio resuelve correctamente
2. Esperar a que Let's Encrypt genere el certificado
3. Reiniciar Traefik si es necesario

---

## 📚 Comandos útiles

### Acceder al contenedor:
```bash
docker exec -it frappe-crm-app bash
```

### Ver logs en tiempo real:
```bash
docker logs -f frappe-crm-app
```

### Verificar estado de servicios:
```bash
docker ps
```

### Backup manual de base de datos:
```bash
docker exec frappe-crm-db mysqldump -u root -p frappe_crm > backup.sql
```

---

## ✅ Checklist final

Después del deploy exitoso, verifica:

- [ ] ✅ Todos los servicios están **Running** en Dokploy
- [ ] ✅ Puedes acceder a `https://tu-dominio.com/crm`
- [ ] ✅ SSL certificate está **válido** (candado verde)
- [ ] ✅ Puedes hacer **login** con Administrator
- [ ] ✅ La interfaz se ve **correctamente** (sin errores 404)
- [ ] ✅ Puedes crear un **Lead de prueba**
- [ ] ✅ **Variables de entorno** están configuradas
- [ ] ✅ **Backup automático** está habilitado
- [ ] ✅ **Monitoring** está funcionando

---

## 🎉 ¡Listo para usar!

Tu **Frappe CRM** está desplegado y listo para usar. Características disponibles:

- 👥 **Gestión de Leads y Deals**
- 📞 **Registro de llamadas**
- 📧 **Integración de email**
- 📊 **Dashboard y reportes**
- 👨‍💼 **Gestión de contactos y organizaciones**
- 📋 **Gestión de tareas**
- 🔄 **Workflow personalizable**

**¡Comienza a gestionar tus ventas de manera profesional!** 🚀