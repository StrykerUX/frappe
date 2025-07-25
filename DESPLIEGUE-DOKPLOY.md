# 🚀 Guía de Despliegue: Frappe CRM en Dokploy

Esta guía te llevará paso a paso para desplegar **Frappe CRM** en tu VPS usando **Dokploy**, sin necesidad de conocimientos técnicos avanzados.

## 📋 Requisitos Previos

### ✅ Lo que necesitas tener:
- ✔️ Un VPS con **Dokploy ya instalado**
- ✔️ Un **dominio** apuntando a tu VPS (ejemplo: `mi-crm.midominio.com`)
- ✔️ Acceso a **GitHub** (donde subirás el código)

### 💻 Recursos mínimos del VPS:
- **RAM**: Mínimo 2GB (recomendado 4GB)
- **CPU**: 2 cores
- **Disco**: Mínimo 20GB libres
- **OS**: Ubuntu 20.04+ o Debian 11+

---

## 🔧 Paso 1: Preparar el Repositorio en GitHub

### 1.1 Crear tu repositorio
1. Ve a [GitHub.com](https://github.com) e inicia sesión
2. Haz clic en **"New repository"** (botón verde)
3. Nombra tu repositorio: `frappe-crm-production`
4. Marca como **"Private"** (recomendado)
5. Haz clic en **"Create repository"**

### 1.2 Subir el código
1. En tu computadora, abre una terminal
2. Ve a la carpeta del proyecto:
   ```bash
   cd frappe/
   ```
3. Configura el repositorio remoto:
   ```bash
   git remote add origin https://github.com/TU-USUARIO/frappe-crm-production.git
   ```
4. Sube el código:
   ```bash
   git push -u origin production
   ```

---

## ⚙️ Paso 2: Configurar Variables de Entorno

### 2.1 Configurar tu dominio y credenciales
1. Copia el archivo de ejemplo:
   ```bash
   cp .env.example .env
   ```

2. Edita el archivo `.env` con tus datos:
   ```bash
   # Reemplaza con tu dominio real
   SITE_NAME=mi-crm.midominio.com
   
   # Puertos (generalmente no cambiar)
   APP_PORT=8000
   SOCKET_PORT=9000
   
   # ⚠️ IMPORTANTE: Cambiar estas contraseñas por unas seguras
   MYSQL_ROOT_PASSWORD=mi_password_super_seguro_123
   MYSQL_PASSWORD=mi_password_frappe_seguro_456
   ADMIN_PASSWORD=mi_password_admin_seguro_789
   ```

### 2.2 Notas importantes sobre contraseñas:
- ❌ **NO uses** contraseñas simples como "123456" o "password"
- ✅ **USA** contraseñas fuertes con letras, números y símbolos
- ✅ **GUARDA** estas contraseñas en un lugar seguro
- ✅ **La contraseña ADMIN_PASSWORD** es la que usarás para entrar al CRM

### 2.3 Subir cambios a GitHub:
```bash
git add .env
git commit -m "feat: configuración de producción personalizada"
git push origin production
```

---

## 🐳 Paso 3: Desplegar en Dokploy

### 3.1 Acceder a Dokploy
1. Abre tu navegador y ve a: `http://tu-vps-ip:3000`
2. Inicia sesión con tus credenciales de Dokploy

### 3.2 Crear nueva aplicación
1. Haz clic en **"Create Application"**
2. Selecciona **"Docker Compose"**
3. Configura los siguientes datos:

   **Información básica:**
   - **Name**: `frappe-crm`
   - **Repository URL**: `https://github.com/TU-USUARIO/frappe-crm-production.git`
   - **Branch**: `production`

   **Configuración Docker:**
   - **Docker Compose File**: `docker-compose.production.yml`
   - **Environment File**: `.env`

### 3.3 Configurar dominio
1. En la sección **"Domains"**, haz clic en **"Add Domain"**
2. Ingresa tu dominio: `mi-crm.midominio.com`
3. **Puerto**: `8000`
4. Guarda la configuración

### 3.4 Variables de entorno adicionales
En la sección **"Environment Variables"**, agrega:

| Variable | Valor |
|----------|-------|
| `SITE_NAME` | `mi-crm.midominio.com` |
| `MYSQL_ROOT_PASSWORD` | `tu_password_seguro_123` |
| `MYSQL_PASSWORD` | `tu_password_frappe_456` |
| `ADMIN_PASSWORD` | `tu_password_admin_789` |
| `APP_PORT` | `8000` |
| `SOCKET_PORT` | `9000` |

---

## 🚀 Paso 4: Desplegar la Aplicación

### 4.1 Iniciar el despliegue
1. Haz clic en **"Deploy"**
2. Dokploy comenzará a:
   - 📥 Descargar el código desde GitHub
   - 🔨 Construir las imágenes Docker
   - 🗄️ Configurar la base de datos
   - 🚀 Iniciar los servicios

### 4.2 Monitorear el progreso
- El despliegue puede tomar **5-10 minutos**
- Puedes ver los logs en tiempo real en la sección **"Logs"**
- Busca mensajes como:
  ```
  ✅ Base de datos lista
  ✅ Redis listo
  🎉 ¡Frappe CRM iniciado exitosamente!
  ```

### 4.3 Verificar estado
- En el dashboard de Dokploy, verifica que todos los servicios estén **"Running"** (verde)
- Los servicios deben ser:
  - `frappe-crm-app`
  - `frappe-crm-db`
  - `frappe-crm-redis`

---

## 🌐 Paso 5: Acceder a tu CRM

### 5.1 Primera conexión
1. Abre tu navegador
2. Ve a: `https://mi-crm.midominio.com/crm`
3. **Usuario**: `Administrator`
4. **Contraseña**: La que configuraste en `ADMIN_PASSWORD`

### 5.2 ¿Qué hacer si no funciona?
Si no puedes acceder, verifica:

1. **Dominio configurado correctamente:**
   - ✅ El dominio apunta a la IP de tu VPS
   - ✅ Esperaste la propagación DNS (puede tomar hasta 24h)

2. **Servicios funcionando:**
   - En Dokploy, revisa que todos los contenedores estén "Running"
   - Revisa los logs por errores

3. **Firewall del VPS:**
   - Asegúrate que el puerto 8000 esté abierto
   - Dokploy generalmente maneja esto automáticamente

---

## 🔧 Paso 6: Configuración Inicial del CRM

### 6.1 Primeros pasos después de acceder:
1. **Cambiar contraseña del administrador:**
   - Ve a Settings → User → Administrator
   - Cambia la contraseña por una personal

2. **Configurar tu empresa:**
   - Ve a Setup → Company
   - Configura nombre, logo, dirección

3. **Crear usuarios adicionales:**
   - Ve a Settings → Users
   - Invita a tu equipo

### 6.2 Configuraciones recomendadas:
- **Email**: Configura SMTP para envío de emails
- **Backup**: Configura respaldos automáticos
- **SSL**: Habilita certificado SSL en Dokploy

---

## 📚 Solución de Problemas Comunes

### ❌ Error: "Site not found"
**Solución:**
1. Ve a los logs en Dokploy
2. Busca errores en la creación del sitio
3. Reinicia la aplicación

### ❌ Error: "Database connection failed"
**Solución:**
1. Verifica las contraseñas en las variables de entorno
2. Asegúrate que el servicio MariaDB esté corriendo
3. Revisa los logs de la base de datos

### ❌ Error: "Port already in use"
**Solución:**
1. Cambia el puerto en las variables de entorno
2. Actualiza la configuración del dominio en Dokploy

### ❌ La página se ve "rota" (sin estilos)
**Solución:**
1. Espera 2-3 minutos más (los assets se están construyendo)
2. Refresca la página con Ctrl+F5
3. Revisa los logs por errores en el build

---

## 🔄 Actualizaciones y Mantenimiento

### Actualizar el CRM:
1. En tu repositorio de GitHub, haz pull del código original:
   ```bash
   git pull upstream develop
   git push origin production
   ```
2. En Dokploy, haz clic en **"Redeploy"**

### Respaldos:
- Dokploy hace respaldos automáticos de los volúmenes
- Para respaldos manuales: Settings → Backup en Dokploy

### Monitoreo:
- Revisa los logs regularmente en Dokploy
- Configura alertas de disco y memoria

---

## 📞 Soporte

### Si necesitas ayuda:
1. **Logs**: Siempre revisa los logs primero en Dokploy
2. **Documentación oficial**: [docs.frappe.io/crm](https://docs.frappe.io/crm)
3. **Comunidad**: [discuss.frappe.io](https://discuss.frappe.io)

### Información técnica:
- **Versión**: Frappe CRM v2.x
- **Base de datos**: MariaDB 10.8
- **Cache**: Redis 7
- **Framework**: Python/JavaScript

---

## ✅ Checklist Final

Después del despliegue, verifica:

- [ ] ✅ Todos los servicios están corriendo en Dokploy
- [ ] ✅ Puedes acceder a `https://tu-dominio.com/crm`
- [ ] ✅ Puedes iniciar sesión con Administrator
- [ ] ✅ La interfaz se ve correctamente (con estilos)
- [ ] ✅ Puedes crear un Lead de prueba
- [ ] ✅ Las variables de entorno están configuradas
- [ ] ✅ Tienes respaldos configurados

---

## 🎉 ¡Felicidades!

Has desplegado exitosamente **Frappe CRM** en producción. Ahora puedes:

- 👥 Gestionar tus leads y clientes
- 💼 Seguir oportunidades de venta
- 📊 Analizar métricas de ventas
- 📧 Enviar emails desde el CRM
- 📞 Gestionar llamadas (con integración Twilio)

**¡Comienza a vender más efectivamente con tu nuevo CRM!** 🚀