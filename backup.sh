#! /bin/bash

#*******************************************************************************************#
#         Sauvegarde des données sur le FTP d'OVH  par Zenzla - zenzla.com                 #
#             ------------------------------------------------------------                  #
# Ce script permet de sauvegarder vos bases de données MySQL ainsi que les fichiers webs de    #
# vos sites.                                                                                #
# Vous pouvez l'utiliser comme tel (en changeant bien sur les paramètres).                 #
# N'hésitez pas à me contacter via mon blog zenzla.com pour toutes éclaicissements           #
#*******************************************************************************************#

#*******************************************************************************************#
#                           /!\ ATTENTION SVP  /!\                                          #
#                        *---------------------------*                                      #
#   Ce script est est libre de droit, vous pouvez le modifier, le copier, l’améliorer,       #  
#   pensez quand même à mettre la source c’est a dire l’URL du site svp. ainsi que            #
#   partager l'article sur vos réseaux sociaux. MERCI                                      #
#                                                                                           #
#*******************************************************************************************#

#
#  Nom de la fonction: parametrage
#  Fonction : Renseignement des paramètres du serveur FTP et de MySQL
#  

parametrage(){
   
#~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
# Importation du fichier de configuration
#~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
. config.conf


# Autre Paramètres (A éditer uniquement si utilisateur avancé )

FILENAME=`date +%Y-%m-%d`_backupsite.tar                    # Nom du fichier "[ANNEE-MOIS-JOUR]_backupsite.tar.gz"
DATE_FORMAT=`date +%F`                                      # Format de la date en aaaa-mm-dd
DATE_ULTERIEUR=`date -d "$OLD_BACKUP days ago" +%F`         # La date qui nous servira à supprimer les anciennes sauvegarde.

# Ne plus rien toucher plus bas, sauf si vous conaissez~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~

GZIP="$(which gzip)"
MYSQLDUMP="$(which mysqldump)"
TAR="$(which tar)"
DEBUT=`date +%s`
NCFTP="$(which ncftp)"

#~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

creation_log                                                # Appel de la fonction creation_log
}

##
#  Nom de la fonction: creation_log
#  Fonction : crée un fichier de suivi étape par étape de la sauvegarde, chaque étape sera inscrite sur ce
#  fichier, cela nous permettra d'identifier en cas de disfonctionnement, la fonction qui cause problème,
#  il est possible de recevoir le récapitulatif par mail
##
creation_log () {
   

if [ ! -f $SUIVILOG ]; then  # Si il existe pas, il faut le créer avec la fonction touch

  touch $SUIVILOG                                  

 
    if [ ! $? -eq  0 ]; then

        echo "Impossible de créer $SUIVILOG"

    else        
        echo "**************************sauvegarde $(date)***********************" > $SUIVILOG  # Mise en page du fichier Log avec la date
        echo "1- Création de fichier $SUIVILOG  Ok $(pwd)" >> $SUIVILOG
       
        verif_ncftp                                 # Appel de la fonction verif_ncftp
    fi
else                                                 # Si il existe, nous écrasons le contenu précédent (Je me pose la question sur la pertinence de garder ou non les anciens fichiers log ?)
   
  echo "**************************sauvegarde $(date)***********************" > $SUIVILOG
  echo "1- Fichier $SUIVILOG  Ok dans $(pwd)" >> $SUIVILOG
 
  verif_ncftp # Appel de la fonction verif_ncftp
fi
}

##
#  Nom de la fonction: verif_ncftp
#  Fonction : Vérifie si ncftp est installé, sinon l'instal
##
 
verif_ncftp(){
if [ -z $NCFTP ]; then

       apt-get install ncftp && echo "2- instalation ncftp Ok de ncftp" >> $SUIVILOG ||  echo "2- impossible d'installer ncftp" >> $SUIVILOG
       
       creation_backup
else
       creation_backup
fi
}



##
#  Nom de la fonction: creation_backup
#  Fonction : crée le répertoire /tmp/backup, qui regroupera tous les fichiers
#  sauvegardés
##
creation_backup(){
   
if [ ! -d $TEMPDIR ]; then                  # si /tmp/backup n'existe pas, alors il le créé
    mkdir -p $TEMPDIR
    if [ ! $? -eq  0 ]; then        
       echo "3- Impossible de créer la repertoire /tmp/backup." >> $SUIVILOG
    else
        echo "3- Création du repertoire /tmp/backup. Ok" >> $SUIVILOG
        cd $TEMPDIR && sauvegarde_bdd
    fi
else                                        # sinon /tmp/backup existe, alors il le vide
    echo "3- Repertoire /tmp/backup. Ok" >> $SUIVILOG
    rm -rf $TEMPDIR/* && cd $TEMPDIR && sauvegarde_bdd
fi
}

##
#  Nom de la fonction: sauvegarde_bdd
#  Fonction : sauvegarde de toutes les bases MySQL
#  ATTENTION : le nom des bases de ne doivent pas contenir d'espace (Je vous rassure, en générale dans MySQL il y en a pas)
##
sauvegarde_bdd (){

echo "4- Debut de la boucle sauvegarde base de données" >> $SUIVILOG
DBS="$(mysql -u $MYSQLUSER -h $MYSQLHOST -p$MYSQLMDP -Bse 'SHOW DATABASES')"  #  Liste les noms des base de données présentes
for db in $DBS                                                          # Boucle, pour chaque base de données dans DBS
do
    echo "Database : $db"
        FILE=$TEMPDIR/mysql-$db-$DATE_FORMAT.gz   # FILE est le nom que portera le fichier de sauvagarde de cette base
        touch $FILE
        `$MYSQLDUMP -l -u $MYSQLUSER -h $MYSQLHOST -p$MYSQLMDP $db | $GZIP > $FILE`   # Dump de la base, puis compression dans FILE
        echo "*****tour de $db dans $FILE***" >> $SUIVILOG # A chaque passage de la boucle, il est noté la base sur laquelle nous sommes
done
echo "4- Fin de la boucle" >> $SUIVILOG

sauvegarde_rep

}

##
#  Nom de la fonction: sauvegarde_rep
#  Fonction : Compression d'un ou plusieurs repertoires choisi en parametre $SAVEDIR1
##
sauvegarde_rep (){
   
echo "5- Commence la sauvegarde des fichiers web">> $SUIVILOG
$TAR -cvzf $FILENAME.gz $SAVEDIR1 -X $EXCLUDEFILE   # Compression du repertoires $SAVEDIR1 en excluant les fichier présent dans $EXCLUDEFILE

if [ ! $? -eq  0 ]; then
    echo "6- Erreur TAR $SAVEDIR1" >> $SUIVILOG
    exit $?
else
    echo "6 - Tar $SAVEDIR1 Ok " >> $SUIVILOG
   
    sauvegarde_letout
fi

}
##
#  Nom de la fonction: sauvegarde_letout
#  Fonction : Compression de tous les fichiers précédents dans un seul fichier $DATE_FORMAT-sauvegarde.gz
##
sauvegarde_letout (){
echo "7- Commence la sauvegarde de tout les fichier">> $SUIVILOG

cd /tmp  # accès /tmp, là ou se trouve le répertoir backup qui contient tous nos fichiers

    echo "INFO : je suis dans $(pwd)" >> $SUIVILOG
   
    $TAR -cvzf $DATE_FORMAT-sauvegarde.gz $TEMPDIR # Compression du fichier Backup
   
    if [ ! $? -eq  0 ]; then
   
        echo "8 -Erreur TAR de la totalité  $TEMPDIR" >> $SUIVILOG
        exit $?
    else
        echo "8 -Tar $TEMPDIR Oki" >> $SUIVILOG
       
        envoi_ftp
       
    fi
}

##
#  Nom de la fonction: envoi_ftp
#  Fonction : Envoi le fichier $DATE_FORMAT-sauvegarde.gz sur le serveur FTP d'OVH
##
envoi_ftp() {
DATE=`date +%H:%M:%S`
echo "9 - Envoi FTP en cours" >> $SUIVILOG
ncftpput -m -u $FTPUSER -p $FTPMDP $SERVEURFTP "/" $DATE_FORMAT-sauvegarde.gz   # Envoi du fichier $DATE_FORMAT-sauvegarde.gz sur le serveur FTP
RESULT=$?
FILESIZE=`ls -l $DATE_FORMAT-sauvegarde.gz | awk '{print $5}'`   # Récupération de la taille du backup
FILESIZE=$(($FILESIZE/1000000))  # Mis een forme de la taille en Mega Octet

if [ "$RESULT" != "0" ]; then # Si Erreur lors de transfert FTP


    echo " 10 - [$0] -->ERREUR: ${CDERR[$RESULT]} à $DATE Backup NON effectué." >> $SUIVILOG # Type de l'erreur dans le fichier de suivi
    echo "[$0] -->ERREUR: ${CDERR[$RESULT]} à $DATE Backup NON effectué." | mail -s 'ERREUR BACKUP FTP OVH' $EMAIL < $SUIVILOG  # Envoi du fichier
    exit $RESULT
else
    TOTALTIME=$(((`date +%s`-$DEBUT)/60)) # Si Ok lors de l'envoi FTP
    echo "10 - [$0] -->Fin de backup normal de $SAVEDIR a $DATE.  Durée: $TOTALTIME mn. Taille: $FILESIZE Mb" >> $SUIVILOG
   
    sup_ftp
fi 
   
    }
   
##
#  Nom de la fonction: sup_ftp
#  Fonction : supprime le fichier $DATE_ULTERIEUR-sauvegarde.gz de votre serveur FTP
##
sup_ftp() {
echo "11 - Suppression du fichier $DATE_ULTERIEUR-sauvegarde.gz du FTP " >> $SUIVILOG
ftp -n << EOF
open $SERVEURFTP
user $FTPUSER $FTPMDP
delete $DATE_ULTERIEUR-sauvegarde.gz
quit
EOF

  envoi_mail
    }
   
##
#  Nom de la fonction: envoi_mail
#  Fonction : Envoi du rapport final
##  
envoi_mail (){

    rm -rf /tmp/$DATE_FORMAT-sauvegarde.gz  #  Supression de la sauvegarde local
   
        echo "12 - Suppression du fichier $DATE_FORMAT-sauvegarde.gz du de /tmp " >> $SUIVILOG
   
    if [ "$MAILSIOK" = "O" ]; then
    echo "mail envoyer" >> $SUIVILOG
    mail -s 'BACKUP FTP OVH OK' $EMAIL < $SUIVILOG      
    fi
}
# lancement de backup
if [ ! `id -u` = 0 ]; then  #Nous vérifions que l'utilisateur est root            
    echo "Vous devez être ROOT pour exécuter ce Sript"
else
    parametrage
fi
