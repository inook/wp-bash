#!/bin/bash

# VARS 
# ———————————————————————

# Admin
email="*****@****.com"
url="http://localhost:8888/"

# Path
pathtoinstall="/Users/**/Desktop/**/**"
foldername="dev-starter"
dbname="wp_starter"

# Wordpress
titre="Starter"
themename="starter"
user="name"
password="*******"

# Misc
sep='————————————————————'


# Export MAMP MySQL executables as functions
# Makes them usable from within shell scripts (unlike an alias)
mysql() {
    /Applications/MAMP/Library/bin/mysql "$@"
}
mysqladmin() {
    /Applications/MAMP/Library/bin/mysqladmin "$@"
}
export -f mysql
export -f mysqladmin


# Stop on error
set -e


echo -e ${sep}
echo -e "WORDPRESS INSTALL"
echo -e ${sep}

cd $pathtoinstall

# check if provided folder name already exists
if [ -d ${foldername} ]; then
  echo -e "Le dossier ${foldername} existe déjà."
  echo -e ${sep}

  # quit script
  exit 1
fi

# Create folder
mkdir $foldername

cd $pathtoinstall/$foldername

# Download WORDPRESS
wp core download --locale=fr_FR --force

# Version
wp core version

# Configuration
wp core config --dbname=${dbname} --dbuser=root --dbpass=root --dbhost=localhost --skip-check

# Create database
wp db create

# Launch install
wp core install --url=$url --title="$titre" --admin_user=$user --admin_email=$email --admin_password=$password

#Plugin install
#wp plugin install wordpress-seo --activate
#wp plugin install simple-page-ordering --activate
#wp plugin install contact-form-7 --activate

# Copy starter Theme
cd ${pathtoinstall}${foldername}/wp-content/themes
git clone git@github.com:inook/wp-starter.git
mv wp-starter $themename

# Activate theme
cd $pathtoinstall/$foldername
wp theme activate $themename

# Misc cleanup
wp post delete 1 --force # Article exemple - no trash. Comment is also deleted
wp post delete 2 --force # page exemple
wp plugin delete hello
wp theme delete twentysixteen
wp theme delete twentyfifteen
wp theme delete twentyfourteen
wp option update blogdescription ''

# Page standard
wp post create --post_type=page --post_title='Accueil' --post_status=publish

# Menu
wp menu create "Menu Principal"
wp menu item add-post menu-principal 3
wp menu location assign menu-principal main-menu

# Permalinks to /%postname%/
wp rewrite structure "/%postname%/" --hard
wp rewrite flush --hard

# Open in browser
open $url
open "${url}wp-admin"

# NPM
cd ${pathtoinstall}${foldername}/wp-content/themes/$themename
npm install
gulp



