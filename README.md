# Gestión del Estudio (Gomez | Di Vanni | Serdoch)

Presupuestos automáticos y seguimiento de escrituras. Sitio estático (`index.html`) con datos en Supabase.

## Archivos
- `index.html`: la aplicación.
- `supabase-config.js`: URL y clave pública de tu proyecto de Supabase (se completa en el paso 5).
- `setup.sql`: crea las tablas, las reglas de seguridad y la lista de cuentas autorizadas.

## 0. Respaldá lo que ya cargaste
En la versión anterior, en el mismo navegador y computadora: Tarifas > **Exportar copia**.
Abrí el `.json` con el Bloc de notas y verificá que estén tus clientes y presupuestos.

## 1. Proyecto en Supabase
supabase.com > New project. Nombre `estudio-gds`, región South America (São Paulo), guardá la contraseña de la base.
Si te dice que alcanzaste el límite de proyectos gratuitos, pausá o borrá uno que no uses. No uses el proyecto de otra empresa.

## 2. Base de datos
SQL Editor > New query. Pegá `setup.sql`, **cambiá los correos del final** por los de quienes van a usar la app y tocá Run.
Tiene que decir "Success". Se puede volver a ejecutar sin problema.

## 3. Cerrar el registro público
Authentication > Sign In / Providers (o Providers) > Email: dejá Email activado y **desactivá "Allow new users to sign up"**.

## 4. Crear los usuarios
Authentication > Users > Add user > Create new user. Correo, contraseña y tildá **Auto Confirm User**. Uno por persona.
El correo tiene que ser el mismo que pusiste en `setup.sql`. Cada persona puede cambiar su contraseña en Tarifas > Mi cuenta.

## 5. Claves
Project Settings > API (o API Keys): copiá **Project URL** y la clave **anon** (o "publishable"). Pegalas en `supabase-config.js`.
Nunca uses la clave `service_role` ni la `secret`.

## 6. GitHub Pages
Repositorio nuevo `estudio-gds` (público), subí `index.html`, `supabase-config.js`, `setup.sql` y `README.md`.
Settings > Pages > Deploy from a branch > `main` / root > Save. Queda en `https://TU-USUARIO.github.io/estudio-gds/`.

## 7. Primer ingreso e importación
Entrá con correo y contraseña. Tarifas > **Importar copia** y elegí el `.json` del paso 0. Importá una sola vez.

## Seguridad
- La clave `anon` es pública por diseño. Lo que protege los datos son las políticas RLS de `setup.sql` y el registro cerrado.
- Con el repositorio público se ve el código y el logo, no los datos.
- Los cambios se guardan por presupuesto: si dos personas editan el mismo presupuesto a la vez, gana el último en guardar.
- Si se corta internet, la app avisa "Sin guardar" y reintenta con el próximo cambio. No cierres la pestaña en ese estado.
