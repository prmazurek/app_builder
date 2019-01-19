settings_path="/app/${PROJECT_NAME}/settings.py"
newline_substitue=$(openssl rand -hex 16)
databases=$(sed ':a;N;$!ba;s/\n/'"$newline_substitue"'/g' "/app/${PROJECT_NAME}/update_settings/databases.py")
sed ':a;N;$!ba;s/\n/'"$newline_substitue"'/g' ${settings_path} | sed "s/DATABASES\s=\s{[^{]*{[^}]*}[^}]*}/${databases}/g" | sed 's/'"$newline_substitue"'/\n/g' > updated_settings.py
rm ${settings_path}
mv updated_settings.py ${settings_path}
