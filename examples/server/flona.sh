#!/bin/sh

# Add the JDBC drivers to this directory
export LOADER_PATH=drivers
export FLONA_FILE_DB_CFG_PATH=db.properties
MAIN_CLASS=com.amiyul.flona.db.remote.server.ServerBootstrap
SPRING_LAUNCHER=org.springframework.boot.loader.PropertiesLauncher
# You might have to change the server jar name below to match that of the downloaded file
java -cp flona-server-1.2.0.jar -Dloader.main=$MAIN_CLASS $SPRING_LAUNCHER
