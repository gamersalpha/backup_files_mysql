# backup_files_mysql

Script de backup donnée , Base de donnée MYSQL

Install 

mkdir /home/[user]/mes_scripts/
git clone 
chmod u+x /home/[user]/mes_scripts/backup.sh

Editer votre crontab
 crontab -e

Puis ajouter la ligne ci-dessous, puis sauvegarder.
33 03 * * * /home/[user]/mes_scripts/backup.sh > /dev/null


Source : https://www.zenzla.com/linux/574-script-shell-sauvegarde-base-donnees-mysql-web.html
