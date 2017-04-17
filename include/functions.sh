#!/bin/bash
# MAINTAINER https://github.com/cloneMe


function addProxy_pass {
local  result="$1"
result="$result        if (\$remote_user = \"$4\") {\n"
result="$result          proxy_pass http://$2:$3;\n"
result="$result        break;\n        }\n"
echo "$result"
}
function addCouchPotato {
local  result="$1\n"
result="$result couchpotato_$2:\n"
result="$result    image: funtwo/couchpotato:latest-dev\n"
result="$result    container_name: seedboxdocker_couchpotato_$2\n"
result="$result    restart: always\n"
result="$result    networks: \n"
result="$result      - seedbox\n"
result="$result    mem_limit: 300m\n"
result="$result    memswap_limit: 500m\n"
result="$result    volumes:\n"
result="$result        - #seedboxFolder#/config/couchpotato_$2/:/config\n"
result="$result        - #seedboxFolder#/downloads/:/torrents\n"

echo "$result"
}

function delete {
#Delete the lines starting from the pattern '#start_servicename' till #end_servicename
if [ "$2" != "true" ]; then
  local l=$(grep -n "#start_$1" docker-compose.yml | grep -Eo '^[^:]+' )
  if [ "$l" != "" ]; then
   sed -i "$l,/#end_$1/d" docker-compose.yml
  fi

  l=$(grep -n "#start_$1" nginx.conf | grep -Eo '^[^:]+' | head -1)
  while [ "$l" != "" ]; do
    # >&2 echo "q"
    sed -i "$l,/#end_$1/d" nginx.conf
    l=$(grep -n "#start_$1" nginx.conf | grep -Eo '^[^:]+' | head -1)
  done
else
 echo "       - $1\n"
fi
}

function generateHelp {
mkdir -p help
userUp=$(echo "$1" | tr '[:lower:]' '[:upper:]')

echo "
5.1 Sickrage

Open \"Search Settings\" and click on the \"torrent search\" tab. Choose \"rtorrent\" and put following values:

    Search Settings: $httpMode://rtorrent.$server_name/RPC$userUp
    Http auth : basic
    Set userName & password
    Download file location: /downloads/rtorrent/$1/watch

Open the \"Post Processing\" menu, activate it and set following values:
    /downloads/rtorrent/$1/watch
    Processing Method: hard link

When adding a a new serie, set /downloads/rtorrent/$1/serie as the parent folder (step 2).

5.2 Couchpotato

It is not necessary to set username & password. Activate \"rtorrent\" and put following values:

    Host: $httpMode://rtorrent.$server_name
    Rpc Url: /RPC$userUp
    Http auth : basic
    Set userName & password
    Download file location: /downloads/rtorrent/$1/film

Plex
Issue : Plex NEVER asks for authentication. Everybody can access to it :/
nano $seedboxFiles/config/plex/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml
There is \"Disable Remote Security=1\". Changed that 1 to a 0 and restarted my Plex : docker restart seedboxdocker_plex_1
Src : https://forums.plex.tv/discussion/132399/plex-security-issue


To configure ubooquity,
execute:
docker stop stream-comics_ubooquity
docker run --rm -ti -v $seedboxFiles/config/ubooquity:/opt/ubooquity-data:rw -v $seedboxFiles/downloads/LIBRARY:/opt/data -p 2203:2202 cromigon/ubooquity:latest -webadmin
Then open http://$server_name:2203/ubooquity/admin
And the end, execute following command to restart ubooquity:
docker start stream-comics_ubooquity

See https://github.com/cromigon/ubooquity-docker for more information

" > help/$1.txt
}

function generateURL {
mkdir -p help
echo "
Following services are deployed:
" > help/URL.txt
if [ "$portainer" = "true" ]; then
   echo "
portainer
$httpMode://$server_name/portainer
" >> help/URL.txt
fi
if [ "$rtorrent" = "true" ]; then
   echo "
rtorrent
$httpMode://$server_name/rtorrent
" >> help/URL.txt
fi
if [ "$jackett" = "true" ]; then
   echo "
jackett
$httpMode://$server_name/jackett/
" >> help/URL.txt
fi
if [ "$sickrage" = "true" ]; then
   echo "
sickrage
$httpMode://$server_name/sickrage
" >> help/URL.txt
fi
if [ "$couchpotato" = "true" ]; then
   echo "
couchpotato
$httpMode://$server_name/couchpotato
" >> help/URL.txt
fi
if [ "$radarr" = "true" ]; then
   echo "
radarr
$httpMode://$server_name/radarr
" >> help/URL.txt
fi
if [ "$mylar" = "true" ]; then
   echo "
mylar
$httpMode://$server_name/mylar
" >> help/URL.txt
fi

if [ "$headphones" = "true" ]; then
   echo "
headphones
$httpMode://$server_name/headphones
" >> help/URL.txt
fi
if [ "$plex" = "true" ]; then
   echo "
Plex
$httpMode://$server_name/plex
" >> help/URL.txt
fi
if [ "$libresonic" = "true" ]; then
   echo "
libresonic
$httpMode://$server_name/libresonic
Warning: Default user/pass is admin/admin

" >> help/URL.txt
fi
if [ "$ubooquity" = "true" ]; then
   echo "
ubooquity
$httpMode://$server_name/ubooquity
" >> help/URL.txt
fi
if [ "$emby" = "true" ]; then
   echo "
emby
$httpMode://$server_name/emby
" >> help/URL.txt
fi
if [ "$limbomedia" = "true" ]; then
   echo "
limbomedia
$httpMode://$server_name/media
" >> help/URL.txt
fi
if [ "$cloud" = "true" ]; then
   echo "
cloud
$httpMode://$server_name/cloud
" >> help/URL.txt
fi
if [ "$elfinder" = "true" ]; then
   echo "
cloud
$httpMode://$server_name/elfinder
" >> help/URL.txt
fi
if [ "$muximux" = "true" ]; then
   echo "
muximux
$httpMode:/$server_name/muximux
" >> help/URL.txt
fi
if [ "$htpcmanager" = "true" ]; then
   echo "
htpcmanager
$httpMode:/$server_name/htpcmanager
" >> help/URL.txt
fi
if [ "$glances" = "true" ]; then
   echo "
glances
$httpMode://$server_name/glances
" >> help/URL.txt
fi
if [ "$plexpy" = "true" ]; then
   echo "
plexpy
$httpMode://$server_name/plexpy
" >> help/URL.txt
fi
if [ "$syncthing" = "true" ]; then
   echo "
syncthing
$httpMode://$server_name/syncthing
" >> help/URL.txt
fi
if [ "$pureftpd" = "true" ]; then
   echo "
FTP
ftp://$server_name
" >> help/URL.txt
fi
if [ "$explorer" = "true" ]; then
   echo "
explorer
$httpMode://explorer.$server_name
" >> help/URL.txt
fi
if [ "$filemanager" = "true" ]; then
   echo "
File manager
$httpMode://files.$server_name
" >> help/URL.txt
fi
if [ "$butterfly" = "true" ]; then
   echo "
Web console
$httpMode://$server_name/butterfly
" >> help/URL.txt
fi

echo "
Hosting info (does not work with all hosting)
http://$(hostname -f)
" >> help/URL.txt

}


