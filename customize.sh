#!/system/bin/sh

# SPPH Ultra Net - Clean Fork
# No system replacements needed for this version (uses runtime props)
REPLACE_EXAMPLE=""
REPLACE=""

# Set permissions for vendor directories if they exist
set_permissions() {
  set_perm_recursive $MODPATH/system/vendor/etc/permissions 0 0 0755 0644
  set_perm_recursive $MODPATH/system/vendor/lib 0 0 0755 0644
  set_perm_recursive $MODPATH/system/vendor/lib64 0 0 0755 0644
}

# Run permissions
set_permissions

ui_print "Aurified-Net Installed."
ui_print "Networking Optimized."
