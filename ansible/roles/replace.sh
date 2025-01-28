find . -name '*.yml' -exec sed -i -e 's/admin_username/login_username/g' {} \;
