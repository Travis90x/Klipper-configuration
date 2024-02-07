cd ~/printer_data/config/config/backup/
file_count=$(find . -maxdepth 1 -type f -name "printer-*.cfg" | wc -l)
if [ "$file_count" -gt 10 ]; then
    find . -maxdepth 1 -type f -name "printer-*.cfg" -printf '%T@ %p\n' | sort -nr | tail -n +11 | cut -d ' ' -f 2- | xargs rm
    echo "Backups cleaned."
else
    echo "No backups to clean."
fi
