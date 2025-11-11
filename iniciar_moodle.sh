#!/bin/bash
# ============================================================
# Script: iniciar_moodle.sh
# Descripció: Llança Moodle GVA amb Docker i importa la BD
# ============================================================

set -e
echo "🚀 Iniciant Moodle Aules GVA (versió dockeritzada)..."
echo ""

# 🧹 Eliminar contenidors antics
docker rm -f moodle-db moodle-web moodle-cron >/dev/null 2>&1 || true
docker network rm moodle-gva-base_default >/dev/null 2>&1 || true

# 🔧 Reconstruir imatges
docker compose build --no-cache

# ▶️ Llançar serveis
docker compose up -d

# ⏳ Esperar que la base de dades estiga llesta
echo "⌛ Esperant que la base de dades estiga disponible..."
sleep 15

# 📥 Importar base de dades automàticament si existeix
if [ -f "moodle_base.sql" ]; then
  echo "💾 Important la base de dades inicial (moodle_base.sql)..."
  docker cp moodle_base.sql moodle-db:/tmp/
  docker exec -i moodle-db bash -c "mysql -u ${MOODLE_DB_USER:-moodleuser} -p${MOODLE_DB_PASSWORD:-moodlepass} ${MOODLE_DB_NAME:-moodle} < /tmp/moodle_base.sql" \
    && echo "✅ Importació completada correctament."
else
  echo "⚠️ No s’ha trobat moodle_base.sql — es crearà una base de dades buida."
fi

# 🌐 Instal·lar idioma català si no existeix
echo "🌐 Comprovant i instal·lant idioma català..."
docker exec -i moodle-web bash -lc "
if [ ! -d /var/www/html/lang/ca ]; then
  echo '🗣️ Descarregant paquet d idioma ca...'
  mkdir -p /var/www/html/lang/ca
  cd /var/www/html/lang
  wget -q https://download.moodle.org/langpack/4.5/ca.zip -O ca.zip
  unzip -o ca.zip -d /var/www/html/lang/ >/dev/null
  rm -f ca.zip
  echo '✅ Idioma ca descarregat i instal·lat.'
else
  echo '✅ L idioma ca ja està present.'
fi
"

# 🔧 Fixar idioma per defecte i netejar memòria cau
docker exec -i moodle-web bash -lc "php /var/www/html/admin/cli/cfg.php --name=lang --set=ca"
docker exec -i moodle-web bash -lc "php /var/www/html/admin/cli/purge_caches.php || true"




# 🧩 Activar resultats, competències i compleció si encara no ho estan
echo "🧩 Activant resultats, competències i compleció..."
docker exec -it moodle-web bash -c "php /var/www/html/admin/cli/cfg.php --name=enableoutcomes --set=1"
docker exec -it moodle-web bash -c "php /var/www/html/admin/cli/cfg.php --name=enablecompletion --set=1"
docker exec -it moodle-web bash -c "php /var/www/html/admin/cli/cfg.php --name=competencyframeworks --set=1"

# 🔁 Reiniciar Moodle perquè veja els canvis
docker restart moodle-web >/dev/null 2>&1

echo ""
echo "✅ Moodle GVA disponible a: http://localhost:${MOODLE_PORT:-8080}"
echo "👤 Usuari: admin"
echo "🔑 Contrasenya: Master-Pr8f!"

