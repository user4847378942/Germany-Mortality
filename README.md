brew install docker

docker run --name deutschland-db -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d -p 3306:3306 mariadb:latest --secure-file-priv=""

./import_csv.sh data/Tote.csv deutschland
./import_csv.sh data/Einwohner.csv deutschland

mysql -h 127.0.0.1 -u root deutschland <query.sql
mysql -h 127.0.0.1 -u root deutschland <jahr.sql >./out/jahr.csv
mysql -h 127.0.0.1 -u root deutschland <quartal.sql >./out/quartal.csv
mysql -h 127.0.0.1 -u root deutschland <woche_36_40.sql >./out/woche_36_40.csv
