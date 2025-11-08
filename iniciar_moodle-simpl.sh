#!/bin/bash
set -e
echo "🚀 Construint i llançant Moodle GVA amb Docker..."

# Eliminar contenidors antics
docker rm -f moodle-web moodle-db >/dev/null 2>&1 || true

# Construir la imatge local de Moodle
docker compose build

# Iniciar els serveis
docker compose up -d

echo ""
echo "✅ Moodle GVA disponible a: http://localhost:8080"
echo "👤 Usuari: admin"
echo "🔑 Contrasenya: Admin1234!"
