#!/system/bin/sh

SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=false
LATESTARTSERVICE=true

ui_print "Installing Aurified-Net (KernelSU/Magisk Compatible)..."

# Ensure service.sh is executable
chmod 755 $MODPATH/service.sh

# Ensure the script has the correct shebang
# (Already set in the file, but good to verify)

ui_print "Installation complete. Reboot required."
