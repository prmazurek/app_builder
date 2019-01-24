function prepare_variables {
	settings_path="/app/${PROJECT_NAME}/settings.py"
	urls_path="/app/${PROJECT_NAME}/urls.py"
	newline_substitue=$(openssl rand -hex 16)
	sed ':a;N;$!ba;s/\n/'"$newline_substitue"'/g' ${settings_path} > settings.tmp
}

function update_databases {
	databases=$(sed ':a;N;$!ba;s/\n/'"$newline_substitue"'/g' "/app/${PROJECT_NAME}/update_files/databases.py")
	sed -i "s/DATABASES\s=\s{[^{]*{[^}]*}[^}]*}/${databases}/g" settings.tmp
}

function update_installed_apps_drf {
	installed_apps=$(egrep -o "INSTALLED_APPS\s=\s\[[a-zA-Z0-9\s '\.,]+]" settings.tmp | sed "s/\]$/    'rest_framework',$newline_substitue\]/")
	sed -i "s/INSTALLED_APPS\s=\s\[[a-zA-Z0-9\s '\.,]*\]/$installed_apps/" settings.tmp
}

function update_installed_apps_drf_and_cms {
	installed_apps=`egrep -o "INSTALLED_APPS\s=\s\([a-zA-Z0-9\s ,\'\._,]+\)" settings.tmp | sed "s/$newline_substitue)/,$newline_substitue)/" | sed "s/)$/    'rest_framework',$newline_substitue)/"`
	sed -i "s/INSTALLED_APPS\s=\s([a-zA-Z0-9\s \'\._,]*)/$installed_apps/" settings.tmp
}

function switch_settings {
	sed -i 's/'"$newline_substitue"'/\n/g' settings.tmp
	rm ${settings_path}
	mv settings.tmp ${settings_path}
}

function update_django_settings {
	prepare_variables
	update_databases
	switch_settings
}

function update_urls {
	if [ $(egrep -o "path\('admin" ${urls_path}) ]
	then
		sed -i "s/import path/import path, include/g" ${urls_path}
		sed -i "/admin\//a \    path(r'^api-auth/', include('rest_framework.urls'))," ${urls_path}
	else
		sed -i "s/import url/import url, include/g" ${urls_path}
		sed -i "/admin\//a \    url(r'^api-auth/', include('rest_framework.urls'))," ${urls_path}
	fi
}

function update_drf_settings {
	prepare_variables
	update_databases
	update_installed_apps_drf
	switch_settings
	update_urls
}

function update_drf_for_cms_settings {
	prepare_variables
	update_databases
	update_installed_apps_drf_and_cms
	switch_settings
	update_urls
}

$1
