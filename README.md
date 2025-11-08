# 🏫 Moodle Aules GVA — Versió Dockeritzada

Versió **preconfigurada de Moodle 4.5 estable** basada en el tema institucional **Moove GVA**, amb base de dades MariaDB i phpMyAdmin per a gestió senzilla.  
Ideal per a pràctiques del màster o entorns de demostració d’Aules GVA.

---

## 🚀 Instal·lació automàtica

### 1️⃣ Clona el repositori
```bash
git clone https://github.com/juatafe/moodle-gva-base.git
cd moodle-gva-base
```

### 2️⃣ Llença el Moodle amb l’script
```bash
bash iniciar_moodle.sh
```

🧩 Si existeix un fitxer `moodle_base.sql`, s’importarà automàticament com a base de dades inicial.  
Si no, es crearà una instal·lació neta i buida.

---

## 🌐 Accés als serveis

| Servei        | URL                          | Descripció                      |
|----------------|-------------------------------|---------------------------------|
| **Moodle**     | [http://localhost:8080](http://localhost:8080) | Plataforma Moodle 4.5 amb tema Moove |
| **phpMyAdmin** | [http://localhost:8081](http://localhost:8081) | Gestió de la base de dades MariaDB |

---

## 👤 Credencials per defecte

| Tipus | Usuari | Contrasenya |
|-------|---------|-------------|
| Base de dades | `moodleuser` | `moodlepass` |
| Administrador Moodle | `admin` | `Master-Pr8f!` |

---

## ⚙️ Variables d’entorn (.env)

Pots personalitzar ports i credencials editant el fitxer `.env`:

```env
MOODLE_PORT=8080
MOODLE_DB_HOST=db
MOODLE_DB_NAME=moodle
MOODLE_DB_USER=moodleuser
MOODLE_DB_PASSWORD=moodlepass
```

---

## 🧹 Comandes útils

```bash
# Aturar els contenidors
docker compose down

# Eliminar dades i imatges per començar de zero
docker compose down -v --rmi all

# Tornar a construir completament
bash iniciar_moodle.sh
```

---

## 🧱 Estructura del projecte

```
moodle-gva-base/
├── Dockerfile              → imatge base (PHP 8.3 + Apache + Moodle)
├── docker-compose.yml      → serveis: db, moodle i cron
├── iniciar_moodle.sh       → script d’arrencada automàtic
├── php.ini                 → configuració PHP optimitzada
├── config.php              → configuració Moodle preinstal·lada
├── moodle_base.sql         → base de dades inicial (opcional)
└── .env                    → variables d’entorn
```

---

## 💡 Notes

- La instal·lació és **autònoma i persistirà dades** dins de les carpetes `moodledata` i `db_data`.  
- Si vols modificar el tema o afegir extensions, pots entrar al contenidor:
  ```bash
  docker exec -it moodle-web bash
  ```
- El cron de Moodle ja està actiu automàticament (cada 60 segons).

---

✳️ Projecte creat per **Juan Bautista Talens Felis**  
🎓 Professor de Sistemes i Aplicacions Informàtiques — *IES Jaume II el Just (Tavernes de la Valldigna)*
