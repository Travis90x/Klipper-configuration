if find ~/printer_data/config -maxdepth 1 -type f -name "printer-*.cfg" | grep -q .; then
    mv -v ~/printer_data/config/printer-*.cfg ~/printer_data/config/config/backup/
    echo "Backups moved."
else
    echo "No backups to move."
fi
