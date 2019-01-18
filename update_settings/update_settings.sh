settings_path=$(find / -name "settings.py")
newline_substitue=$(openssl rand -hex 16)
sed ':a;N;$!ba;s/\n/'"$newline_substitue"'/g' ${settings_path} | sed 's/DATABASES\s=\s{[^{]*{[^}]*}[^}]*}//g' | sed 's/'"$newline_substitue"'/\n/g' > updated_settings.py
cat /app/${PROJECT_NAME}/update_settings/databases.py >> updated_settings.py
rm ${settings_path}
mv updated_settings.py ${settings_path}
