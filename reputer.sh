#!/bin/bash
welcome_screen() {


echo "░▒▓█▓▒░▒▓███████▓▒░       ░▒▓███████▓▒░░▒▓████████▓▒░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓████████▓▒░▒▓███████▓▒░  "
echo "░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ "
echo "░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ "
echo "░▒▓█▓▒░▒▓███████▓▒░       ░▒▓███████▓▒░░▒▓██████▓▒░ ░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓██████▓▒░ ░▒▓███████▓▒░  "
echo "░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ "
echo "░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ "
echo "░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓█▓▒░       ░▒▓██████▓▒░   ░▒▓█▓▒░   ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░ "
                                                                                                                       

    echo "Reputer by Viernez13"
}

CSV_FILE="ip_report.csv"
echo "IP,Abuse Score,Confiabilidad,País,ISP" > $CSV_FILE
check_ip_reputation() {
    IP=$1
    API_KEY="Acá tu Api"
    RESPONSE=$(curl -sG https://api.abuseipdb.com/api/v2/check \
        --data-urlencode "ipAddress=$IP" \
        -d maxAgeInDays=90 \
        -H "Key: $API_KEY" \
        -H "Accept: application/json")

    # Parsear la respuesta JSON
    ABUSE_SCORE=$(echo "$RESPONSE" | jq '.data.abuseConfidenceScore')
    COUNTRY=$(echo "$RESPONSE" | jq -r '.data.countryCode')
    ISP=$(echo "$RESPONSE" | jq -r '.data.isp')

    # Evaluar si es confiable o no
    if [ "$ABUSE_SCORE" -gt 50 ]; then
        CONFIABILIDAD="No confiable"
    else
        CONFIABILIDAD="Confiable"
    fi

    # Mostrar en la terminal
    echo "La IP $IP tiene un score de abuso de $ABUSE_SCORE% ($CONFIABILIDAD)"
    echo "País: $COUNTRY | ISP: $ISP"

    # Guardar en el archivo CSV
    echo "$IP,$ABUSE_SCORE,$CONFIABILIDAD,$COUNTRY,$ISP" >> $CSV_FILE
}

# Función principal para procesar la lista de IPs
process_ip_list() {
    IP_LIST=$1

    while IFS= read -r IP; do
        echo "Procesando IP: $IP"
        check_ip_reputation "$IP"
        echo "--------------------------------------------"
    done < "$IP_LIST"
}

# Mostrar la pantalla de bienvenida
welcome_screen

# Verificar si se pasa un archivo de IPs
if [ -z "$1" ]; then
    echo "Por favor, proporciona un archivo con una lista de IPs."
    exit 1
fi

# Procesar el archivo de IPs
process_ip_list "$1"

# Confirmación de que el CSV fue creado
echo "Los resultados han sido guardados en $CSV_FILE."
