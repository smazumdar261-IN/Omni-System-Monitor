#!/bin/bash
# Universal Cyber-Dashboard Installer for Ubuntu 24.04+

echo "Starting Installation... You may be asked for your password to install Conky."

# 1. Automatic Dependency Check & Installation
# This ensures Conky is installed before anything else runs.
sudo apt update && sudo apt install conky-all zenity -y

# 2. Setup Directories
mkdir -p ~/.config/conky
mkdir -p ~/.config/autostart

# 3. User Color Selection (Defaults to Sayantan's Cyber Green/Cyan)
C_TIME=$(zenity --entry --title="Hacker Dashboard" --text="Color for TIME (Hex):" --entry-text="00d4ff")
C_STATS=$(zenity --entry --title="Hacker Dashboard" --text="Color for STATS/DAY (Hex):" --entry-text="00FF41")
C_TIME=${C_TIME:-00d4ff}; C_STATS=${C_STATS:-00FF41}

# 4. Detect Active Network Hardware
NET_IF=$(ip -o -4 route show to default | awk '{print $5}')

# 5. Create the Dashboard Config
cat << 'INNER_EOF' > ~/.config/conky/secure_auth.conkyrc
conky.config = {
    alignment = 'top_right',
    gap_x = 50, gap_y = 110,
    background = false,
    own_window = true,
    own_window_type = 'desktop',
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_argb_value = 0,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    double_buffer = true,
    update_interval = 1.0,
    default_color = 'REPLACE_STATS',
    font = 'Ubuntu Mono:size=12',
    use_xft = true,
}
conky.text = [[
\${color #00d4ff}\${font Ubuntu Mono:bold:size=12}ID: \${execi 600 whoami | tr '[:lower:]' '[:upper:]'} // AUTHENTICATED\${font}
\${color #00d4ff}\${hr 2}
\${voffset 15}\${alignc}\${font Ubuntu Mono:bold:size=80}\${color #REPLACE_TIME}\${time %H:%M}\${font}
\${voffset 35}\${alignc}\${font Ubuntu Mono:bold:size=38}\${color #REPLACE_STATS}\${time %A}\${font}
\${voffset 10}\${alignc}\${font Ubuntu Mono:size=18}\${color #REPLACE_STATS}\${time %d %B %Y}\${font}

\${voffset 20}\${color #ff3333}\${font Ubuntu Mono:bold:size=14}NODE_STATUS: \${color #ffffff}ENCRYPTED\${font}
\${color #00d4ff}OS_VER: \${alignr}\${color #ffffff}\${execi 6000 lsb_release -ds | sed 's/\"//g'}
\${color #00d4ff}LOCAL_IP: \${alignr}\${color #ffffff}\${addr REPLACE_NET}
\${color #00d4ff}NET_DOWN: \${color #ffffff}\${downspeedf REPLACE_NET}\${alignr}\${color #444444}\${downspeedgraph REPLACE_NET 10,150 REPLACE_STATS 00d4ff}
]]
INNER_EOF

# 6. Finalize values
sed -i "s/REPLACE_NET/$NET_IF/g" ~/.config/conky/secure_auth.conkyrc
sed -i "s/REPLACE_TIME/$C_TIME/g" ~/.config/conky/secure_auth.conkyrc
sed -i "s/REPLACE_STATS/$C_STATS/g" ~/.config/conky/secure_auth.conkyrc

# 7. Create Launch Script & Autostart
cat << 'LAUNCH_EOF' > ~/.config/conky/launch_conky.sh
#!/bin/bash
sleep 20
/usr/bin/conky -c $HOME/.config/conky/secure_auth.conkyrc > /dev/null 2>&1 &
LAUNCH_EOF
chmod +x ~/.config/conky/launch_conky.sh

echo "[Desktop Entry]
Type=Application
Exec=$HOME/.config/conky/launch_conky.sh
Name=Conky Secure Auth" > ~/.config/autostart/conky.desktop

# 8. Start it now with Double-Fork
( ( nohup ~/.config/conky/launch_conky.sh > /dev/null 2>&1 & ) & )

echo "DONE! Conky is installed and configured."
echo "The dashboard will appear on your desktop in 20 seconds."
