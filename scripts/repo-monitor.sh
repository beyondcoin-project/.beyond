#!/bin/bash -e
## Copyright 2020, The Beyondcoin Developers

if [ "$EUID" -ne 0 ]
     then echo "This script must be run as root."
     exit
fi

## Downloads directory.
BEYOND_TMP=/root
## Archive directory.
BEYOND_ARCHIVE=/root
## BIND9 configuration directory.
BEYOND_BIND_CONF=/etc/bind

echo ""
echo ""
echo "     ██████╗ ███████╗██╗   ██╗ ██████╗ ███╗   ██╗██████╗   "
echo "     ██╔══██╗██╔════╝╚██╗ ██╔╝██╔═══██╗████╗  ██║██╔══██╗  "
echo "     ██████╔╝█████╗   ╚████╔╝ ██║   ██║██╔██╗ ██║██║  ██║  "
echo "     ██╔══██╗██╔══╝    ╚██╔╝  ██║   ██║██║╚██╗██║██║  ██║  "
echo " ██╗ ██████╔╝███████╗   ██║   ╚██████╔╝██║ ╚████║██████╔╝  "
echo " ╚═╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚═════╝   "
echo ""
echo "[**] Checking git repo and updating BIND9..."
echo "[**] Last checked on $(date)."
echo ""

## Avoid unnecessarily restarting BIND
if [ ! -d "$BEYOND_TMP/.beyond" ] ; then

     git clone https://github.com/beyondcoin-project/.beyond $BEYOND_TMP/.beyond

else

     git -C $BEYOND_TMP/.beyond fetch

     BEYONDDB_LOCAL=$(git -C $BEYOND_TMP/.beyond rev-parse @)
     BEYONDDB_ORIGIN=$(git -C $BEYOND_TMP/.beyond rev-parse origin/master)

     if [[ $BEYONDDB_LOCAL == "$BEYONDDB_ORIGIN" ]]; then

          echo "[**] No updates, exiting."
          exit

     fi

     git -C $BEYOND_TMP/.beyond reset --hard origin/master

fi

echo ""
## Optionally copy the existing configs to the $BEYOND_ARCHIVE/archived directory.
## You will be responsible for backup rotation.
#echo "[**] Moving old config to $BEYOND_ARCHIVE/archived/"
#mkdir -p $BEYOND_ARCHIVE/archived
#gzip -c $BEYOND_BIND_CONF/named.conf > "$BEYOND_ARCHIVE/archived/named-config.$(date +%F-%H-%M).backup.gz"
#gzip -c $BEYOND_BIND_CONF/named.conf.opennic > "$BEYOND_ARCHIVE/archived/named.conf.opennic.$(date +%F-%H-%M).backup.gz"
#gzip -c $BEYOND_BIND_CONF/beyond.zone > "$BEYOND_ARCHIVE/archived/domain-config.$(date +%F-%H-%M).backup.gz"
#gzip -c $BEYOND_BIND_CONF/bot.beyond.zone > "$BEYOND_ARCHIVE/archived/bot.beyond.zone.$(date +%F-%H-%M).backup.gz"
#gzip -c $BEYOND_BIND_CONF/dev.beyond.zone > "$BEYOND_ARCHIVE/archived/dev.beyond.zone.$(date +%F-%H-%M).backup.gz"
#gzip -c $BEYOND_BIND_CONF/fork.beyond.zone > "$BEYOND_ARCHIVE/archived/fork.beyond.zone.$(date +%F-%H-%M).backup.gz"
#gzip -c $BEYOND_BIND_CONF/pool.beyond.zone > "$BEYOND_ARCHIVE/archived/pool.beyond.zone.$(date +%F-%H-%M).backup.gz"
#gzip -c $BEYOND_BIND_CONF/user.beyond.zone > "$BEYOND_ARCHIVE/archived/user.beyond.zone.$(date +%F-%H-%M).backup.gz"
##gzip -c $BEYOND_BIND_CONF/app.beyond.zone > "$BEYOND_ARCHIVE/archived/app.beyond.zone.$(date +%F-%H-%M).backup.gz"
##gzip -c $BEYOND_BIND_CONF/test.beyond.zone > "$BEYOND_ARCHIVE/archived/test.beyond.zone.$(date +%F-%H-%M).backup.gz"
##gzip -c $BEYOND_BIND_CONF/www.beyond.zone > "$BEYOND_ARCHIVE/archived/www.beyond.zone.$(date +%F-%H-%M).backup.gz"
echo "[**] Moving domain-config to beyond.zone..."
cp -f $BEYOND_TMP/.beyond/config/domain-config $BEYOND_BIND_CONF/beyond.zone
echo "[**] Moving .beyond subzones..."
cp -f $BEYOND_TMP/.beyond/config/bot.beyond.zone $BEYOND_BIND_CONF/bot.beyond.zone
cp -f $BEYOND_TMP/.beyond/config/dev.beyond.zone $BEYOND_BIND_CONF/dev.beyond.zone
cp -f $BEYOND_TMP/.beyond/config/fork.beyond.zone $BEYOND_BIND_CONF/fork.beyond.zone
cp -f $BEYOND_TMP/.beyond/config/pool.beyond.zone $BEYOND_BIND_CONF/pool.beyond.zone
cp -f $BEYOND_TMP/.beyond/config/user.beyond.zone $BEYOND_BIND_CONF/user.beyond.zone
cp -f $BEYOND_TMP/.beyond/config/node.beyond.zone $BEYOND_BIND_CONF/node.beyond.zone
#cp -f $BEYOND_TMP/.beyond/config/app.beyond.zone $BEYOND_BIND_CONF/app.beyond.zone
#cp -f $BEYOND_TMP/.beyond/config/test.beyond.zone $BEYOND_BIND_CONF/test.beyond.zone
#cp -f $BEYOND_TMP/.beyond/config/www.beyond.zone $BEYOND_BIND_CONF/www.beyond.zone
echo "[**] Moving named-config to named.conf..."
cp -f $BEYOND_TMP/.beyond/config/named-config $BEYOND_BIND_CONF/named.conf
echo "[**] Copying opennic conf..."
cp -f $BEYOND_TMP/.beyond/config/named.conf.opennic $BEYOND_BIND_CONF/named.conf.opennic
echo ""
echo "[**] Restarting BIND9 service..."
/etc/init.d/bind9 reload
sleep 5
echo ""
/etc/init.d/bind9 status
sleep 5
echo ""
echo "[**] Testing DNS..."
echo ""
ping -c 2 google.beyond
#ping -c 2 bynd.beyond
echo "[**] Update completed successfully."
sleep 5
