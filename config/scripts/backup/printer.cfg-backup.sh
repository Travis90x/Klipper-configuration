if find ~/printer_data/config -maxdepth 1 -type f -name "printer-*.cfg" | grep -q .; then
    mv -v ~/printer_data/config/printer-*.cfg ~/printer_data/config/config/backup/
    echo "printer.cfg backups moved."
elif [ -f ~/printer_data/config/moonraker.conf.backup ]; then
    mv -v ~/printer_data/config/moonraker.conf.backup ~/printer_data/config/config/backup/
    echo "moonraker backup moved."
else
    echo "no backups to move."
fi
