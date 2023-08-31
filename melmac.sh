#!/bin/bash

echo "
             .,::.                                                              
    ..'.   .'',ldl .''                                                          
    .;,...''...;lc..;o.                                                         
     ..'..;',,.::';',                                                           
      .,, '.;:.''.;.                                                            
      .,;'..,;;'.,:.                                                            
      .,,,,,;:;:::,.                                                            
      .,.,:':l:cc:;.                                                            
    ..;,.'',,;;;,,:cl.                                                          
  ..,:l'...'',,,,,:cooc.                                                        
 .';;.'.......',,;;',:c;'                                                       
 .,:,........'''''...':c'                                                       
 .,;'...',;:::::cc'..'::.  .............                                        
 .,'....;:::::::co:..'::. .;;;;;;'...,;;.      .;;;;;;,. .,;;'                  
  .'....,;;;;;;;;;'...'.  '::::::.   '::..    ..::::::.                         
      ............'.      '::::::.   '::..;;;;'.::::::.        .';;;.  ...';;;;.
      ..,;,......',.      '::::::.   '::..;:::'.::::::'        .::::.     '::::.
      ..,oc'...'',,.      '::::::,''';::..;:::'.::::::,'...    .::::...',.'::::.
     .'.,::'..,,'','.     ':::::::,,,:::..;:::'.:::::::;;,.    .::::...',.'::::.
     .;.:;,...';,':,.     ......      .,..,,,,..,,,,,,.         ......... .,,,,.

 " 
echo "Iniciando la limpieza y mantenimiento de Melmac..."

# Actualizar la lista de paquetes disponibles
echo "Actualizando lista de paquetes..."
sudo apt update

# Actualizar los paquetes instalados
echo "Actualizando paquetes..."
sudo apt upgrade -y

# Eliminar paquetes innecesarios
echo "Eliminando paquetes innecesarios..."
sudo apt autoremove -y

# Limpiar la caché de paquetes
echo "Limpiando la caché de paquetes..."
sudo apt clean

# Limpiar la caché de thumbnails (miniaturas)
echo "Limpiando caché de thumbnails..."
rm -rf ~/.cache/thumbnails/*

# Limpiar la papelera de reciclaje
echo "Vaciando la papelera de reciclaje..."
if ! rm -rf ~/.local/share/Trash/*; then
    echo "Problemas al vaciar la papelera. Usando sudo para forzar el borrado."
    sudo rm -rf ~/.local/share/Trash/*
fi

# Limpiar la caché DNS
echo "Limpiando la caché DNS..."
sudo systemd-resolve --flush-caches

# Opción para full-upgrade
read -p "¿Quieres realizar una actualización completa del sistema? (puede tener cambios significativos) [s/N] " respuesta
if [[ $respuesta == "s" || $respuesta == "S" ]]; then
    sudo apt full-upgrade -y
fi

# Identificar y desinstalar aplicaciones no deseadas
echo "Buscando aplicaciones instaladas..."
paquetes=$(dpkg --get-selections | grep -v deinstall | awk '{print $1}')

seleccion=$(whiptail --title "Aplicaciones instaladas" --checklist \
"Selecciona las aplicaciones que deseas desinstalar" 25 80 16 \
$(for paquete in $paquetes; do echo "$paquete OFF"; done) 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ]; then
    for paquete in $seleccion; do
        sudo apt purge "$paquete" -y
    done
fi

echo "¡Mantenimiento y limpieza completados!"
