
#~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
# Editez ces paramètres
#~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
SERVEURFTP=""                                               # Serveur ftp
FTPUSER=""                                                  # Votre nom POUR LE ftp
FTPMDP=""                                                   # Mot de passe FTP
MYSQLUSER=""                                                # Utilisateur Mysql
MYSQLMDP=""                                                 # Mot de passe MySQL
MYSQLHOST="localhost"                                                # Hôte MySQL (localhost dans la majorité des ca$
EMAIL=""                                                    # Pour envoi mail si backup echoue ou OK
MAILSIOK="O"                                                # Mettre "O" si on veut un mail aussi si backup ok
TEMPDIR="/tmp/"                                       # repertoire temporaire ou $
SAVEDIR1="/var/www/*"                                       # Backup SANS slash a la fin des fichiers web ()
EXCLUDEFILE="exclude.txt"                  # Ce fichier doit contenir les repétoires a exclure $
OLD_BACKUP="3"                                             # Par défaut je mets "30", donc je garderai les 30 derniè$
SUIVILOG="/tmp/suiviscrip.log" # Notre fichier log


