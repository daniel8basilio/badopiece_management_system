#!/bin/sh

# Databases
APP_DB_NAME=bado
APP_DB_TEST_NAME=bado_test

# Database Configuration
PG_VERSION=9.6
APP_DB_USER=devanya
APP_DB_PASS=devanya
PG_CONF=/etc/postgresql/$PG_VERSION/main/postgresql.conf
PG_HBA=/etc/postgresql/$PG_VERSION/main/pg_hba.conf

set_language() {
    echo "[CofeeBase] Set language to UTF-8 and timezone to pst"
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US=UTF-8
    timedatectl set-timezone Asia/Singapore
}

print_db_details() {
    echo "----------------------------------------------------------"
    echo "Database has been setup:"
    echo "    Database:          $APP_DB_NAME"
    echo "    Test Database:     $APP_DB_TEST_NAME"
    echo "    Username:          $APP_DB_USER"
    echo "    Password:          $APP_DB_PASS"
    echo "----------------------------------------------------------"
}

add_update_repo() {
    echo "[CoffeeBase] Add/Update repo start"
    sudo apt-get update
    # Install software-properties common package to give us add-apt-repository package
    sudo apt-get install -y software-properties-common

    echo "[CoffeeBase] Add nginx repo"
    sudo add-apt-repository ppa:nginx/stable

    echo "[CoffeeBase] Add PostgreSQL repo"
    cp /vagrant/provisioning/database/pgdg.list /etc/apt/sources.list.d/pgdg.list
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

    echo "[CofeeBase] Add Yarn repo"
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key  add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

    echo "[CoffeeBase] Add PHP repo"
    sudo apt-add-repository ppa:ondrej/PHP

    sudo apt-get update
    echo "[CoffeeBase] Add/Update repo done"
}

install_nginx() {
    echo "[CofeeBase] Install NginX"
    sudo apt-get install -y nginx

    # Enable nginx and start
    sudo systemctl enable nginx
    sudo systemctl start nginx
}

install_php() {
    echo "[CofeeBase] Install PHP and extensions"
    sudo apt-get install -y php7.2
    sudo apt-get install -y php7.2-cli php7.2-json php7.2-opcache php7.2-readline php7.2-intl php7.2-xml php7.2-pgsql php7.2-fpm php7.2-zip php7.2-gd php7.2-mbstring php7.2-xdebug php7.2-apcu php7.2-curl
    sudo apt-get install -y make unzip vim

    # FIX: Make sure apache is not installed
    sudo apt-get remove -y apache2

    # Start php7.2-fpm
    sudo service php7.2-fpm start
}

install_postgres() {
    echo "[CofeeBase] Install PostgreSQL"
    sudo apt-get install -y "postgresql-$PG_VERSION" "postgresql-contrib-$PG_VERSION"
}

install_composer() {
    echo "[CofeeBase] Install Composer"
    curl -s https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
}

install_nodejs() {
    echo "[CofeeBase] Install NodeJS 12~"
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs yarn
}

setup_postgres() {
    if [ ! -f /var/log/databasesetup ];
    then
        echo "[CofeeBase] Setup postgres"
        sudo systemctl enable postgresql
        sudo systemctl start postgresql

        sudo -u postgres createuser -DRS "$APP_DB_USER" 
        sudo -u postgres createdb -O "$APP_DB_USER" "$APP_DB_NAME"
        sudo -u postgres createdb -O "$APP_DB_USER" "$APP_DB_TEST_NAME"
        echo "ALTER USER $APP_DB_USER WITH PASWORD '$APP_DB_PASS'" | sudo -u postgres psql "$APP_DB_NAME"

        # Edit postgresql.conf to change listen address to '*'
        sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

        # Update psql access config (allow md5 to local and host)
        sudo cp /vagrant/provisioning/database/pg_hba.conf $PG_HBA

        sudo systemctl restart postgresql
        touch /var/log/databasesetup
    fi
    print_db_details
}

setup_nginx() {
    echo "[CoffeeBase] Setup nginx"
    # Rename default config to prevent localhost address conflict
    sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bk
    sudo rm -rf /etc/nginx/sites-enabled/default
    # Add configuration for bado
    sudo cp /vagrant/provisioning/nginx/develop-bado.com.conf /etc/nginx/sites-available/develop-bado.com.conf
    # Create symbolic link
    sudo ln -s /etc/nginx/sites-available/develop-bado.com.conf /etc/nginx/sites-enabled
    # Reload nginx
    sudo service nginx reload
    sudo service php7.2-fpm restart
}

install_packages() {
    install_nginx
    install_php
    install_postgres
    install_composer
    install_nodejs
}

setup() {
    setup_nginx
    setup_postgres
}

init_app() {
    echo "[CoffeeBase] Initialize Application"
    cd /var/www/bado
    rm -dfr node_modules
    rm -dfr vendor
    composer install
    yarn install
    yarn run build
}


# ----------------------------------------------------------------------- #
if [ ! -f /var/log/appsetup];
    echo "[CoffeeBase] Provisioning already run, nothing to do."
then
    echo "[CoffeeBase] Start Provisioning"
    set_language
    add_update_repo
    install_packages
    setup
    init_app
    echo "[CoffeeBase] End Provisioning"
    touch /var/log/appsetup
fi
# ----------------------------------------------------------------------- #
