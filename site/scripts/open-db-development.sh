#!/bin/bash
eval $(cat ../.env | sed 's/^/export /')
TMP_SPF="/tmp/$DB_USER.spf"
PARENT_DIR="$(dirname "$(pwd)")"
DEV_HOSTNAME="$(basename "$WP_HOME")"

cat > $TMP_SPF <<EOF
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>ContentFilters</key>
        <dict/>
        <key>auto_connect</key>
        <true/>
        <key>data</key>
        <dict>
            <key>connection</key>
            <dict>
                <key>database</key>
                <string>${DB_NAME}</string>
                <key>user</key>
                <string>${DB_USER}</string>
                <key>password</key>
                <string>${DB_PASSWORD}</string>
                <key>host</key>
                <string>127.0.0.1</string>
                <key>name</key>
                <string>${DEV_HOSTNAME}</string>
                <key>rdbms_type</key>
                <string>mysql</string>
                <key>ssh_host</key>
                <string>${DEV_HOSTNAME}</string>
                <key>ssh_keyLocation</key>
                <string>${PARENT_DIR}/../trellis/.vagrant/machines/default/virtualbox/private_key</string>
                <key>ssh_keyLocationEnabled</key>
                <integer>1</integer>
                <key>ssh_user</key>
                <string>vagrant</string>
                <key>sslCACertFileLocation</key>
                <string></string>
                <key>sslCACertFileLocationEnabled</key>
                <integer>0</integer>
                <key>sslCertificateFileLocation</key>
                <string></string>
                <key>sslCertificateFileLocationEnabled</key>
                <integer>0</integer>
                <key>sslKeyFileLocation</key>
                <string></string>
                <key>sslKeyFileLocationEnabled</key>
                <integer>0</integer>
                <key>type</key>
                <string>SPSSHTunnelConnection</string>
                <key>useSSL</key>
                <integer>0</integer>
            </dict>
        </dict>
        <key>encrypted</key>
        <false/>
        <key>format</key>
        <string>connection</string>
        <key>queryFavorites</key>
        <array/>
        <key>queryHistory</key>
        <array/>
    </dict>
</plist>
EOF

exec open $TMP_SPF
