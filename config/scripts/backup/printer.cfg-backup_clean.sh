cd ~/printer_data/config/config/backup/
# ls -lt printer-*.cfg | tail -n +11 | xargs rm
if [[ $(find . -maxdepth 1 -type f -name "printer-*.cfg") ]]; then
     find . -maxdepth 1 -type f -name "printer-*.cfg" -printf '%T@ %p\n' | sort -nr | tail -n +11 | cut -d ' ' -f 2- | xargs -- rm
     echo "Backups cleaned."
else
     echo "No file to clean."
fi
