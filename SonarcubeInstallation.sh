#!/bin/bash

#########################
#NAME: V.THIPPAREDDY
#SCRIPT: Installation of sonar cube
#########################

Unzip_Installation() {
    if [ "$(grep -Ei 'debian|ubuntu|mint' /etc/*-release)" ];
    then
        echo "checking if unzip is available or not"
        unzip
        if [ $? -eq 0 ];
        then
            echo "Unzip is already available"
            echo "As Unzip packages are already unavailable installing java"
            Java_Installation
        else
            echo "Installing Unzip packages"
            sudo apt install unzip
            unzip
                if [ $? -eq 0 ];
                then
                    echo "Unzip package is successfully installed" 
                    echo "As Unzip packages are already unavailable installing java on ubuntu"
                    Java_Installation
                else
                    echo "Unable to install unzip packages"
                    exit 1
                fi
        fi
    elif [ "$(grep -Ei 'centos|redhat' /etc/*release)" ];
    then
        echo "checking if unzip is available or not"
        yum list installed unzip
           if [ $? -eq 0 ];
           then
            echo "Unzip packages are already available"
            echo "As Unzip packages are already unavailable installing java"
            Java_Installation
           else
            echo "Installing unzip packages"
            sudo yum install unzip -y
            yum list installed unzip
                if [ $? -eq 0 ];
                then
                    echo "Unzip packages are successfully installed"
                    echo "As Unzip packages are already unavailable installing java"
                    Java_Installation
                else
                    echo "Unable to install Unzip packages"
                    exit 1
                fi
            fi   
    fi
}

Java_Installation() {
    java --version
    if [ $? -eq 0 ];
    then
       echo "Java is already available"
       echo "As Java packages are already unavailable installing Postgres SQL"
       PostgreSQL_Repository
    elif [ "$(grep -Ei 'debian|ubuntu|mint' /etc/*-release)" ];   
    then
        echo "Updating exsisting packages"
        sudo apt update
        echo "Installing Java 11 on Ubuntu OS"
        sudo apt install openjdk-11-jdk -y
        java --version
            if [ $? -eq 0 ];
            then
                echo "Java successfully installed on Ubuntu OS"
                echo "As Java packages are already unavailable installing Postgres SQL on Ubuntu"
                PostgreSQL_Repository
            else
                echo "Unable to install Java on Ubuntu OS"
                exit 1
            fi
    elif [ "$(grep -Ei 'centos|redhat' /etc/*release)" ];
    then
        echo "Updating exsisting packages"
        sudo yum update
        echo "Installing Java packages on Redhat OS"
        sudo yum install java-11-openjdk
        java --version
            if [ $? -eq 0 ];
            then
                echo "Java successfully installed on Redhat OS"
                echo "As Java packages are already unavailable installing Postgres SQL on Redhat"
                PostgreSQL_Repository
            else
                echo "Unable to install Java on Redhat OS"
                exit 1
            fi
    fi
}

PostgreSQL_Repository() {
    if [ "$(grep -Ei 'debian|ubuntu|mint' /etc/*-release)" ];
    then
       echo "Checking if PostgreSQL is available or not"
       apt list --installed | grep postgresql
       if [ $? -eq 0 ];
       then
        echo "PostgreSQL IS already available"
       else
        echo "Installing PostgreSQL"
        sudo apt install -y postgresql postgresql-contrib
        apt list --installed | grep postgresql
            if [ $? -eq 0 ];
            then
                echo "postgresql is successfully installed"
            else
                echo "Unable to install postgresql"
                exit 1
            fi
        echo "Starting and enabling postgresql on Ubuntu"
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
        echo "Checking if postgresql is up and running or not"
        sudo systemctl start postgresql > Status.txt
            if [ "$(grep -Ei 'Active: active (exited)' Status.txt)" ];
            then
                echo "postgresql is up and active"
            elif [ "$(grep -Ei 'Active: inactive (dead)' Status.txt)" ];
            then
                echo "postgresql is inactive"
                exit 1
            fi
        ##Need to create postgres_conf.txt and pg_hba_conf.txt files in temp location as we have to edit the config files which we cant  do while executing shell script
        #echo "Allowing all remote connections"
        #sudo cat /tmp/postgres_conf.txt > /etc/postgresql/13/main/postgresql.conf # Getting permission deined
        #echo "setting up access permissions"
        #sudo cat pg_hba_conf.txt > /var/lib/pgsql/13/data/pg_hba.conf
        #echo "Restarting postgres sql"
        #sudo systemctl restart postgresql
        echo "Creating user"
        sudo -i -u postgres # have to change passowrd if required
        psql # After switching to user not able to perform next steps
        echo "Creating new Database"
        CREATE DATABASE Sonarcube;
        echo "Creating user for the database"
        CREATE USER Sonarcube WITH ENCRYPTED PASSWORD 'Sonarcube';
        echo "Granting the required previlages"
        GRANT ALL PRIVILEGES ON DATABASE Sonarcube TO Sonarcube;
        echo "Exiting from the SQL prompt"
        \q
        exit
        fi
    elif [ "$(grep -Ei 'centos|redhat' /etc/*release)" ];
    then
    echo "Checking if PostgreSQL is available or not"
    dnf list installed | grep postgresql
       if [ $? -eq 0 ];
       then
        echo "PostgreSQL IS already available"
       else
        echo "Installing PostgreSQL"
        sudo dnf install https://download.postgresql.org/pub/repos/yum/reporpms/el8/x86_64/pgdg-redhat-repo-latest.noarch.rpm
        sudo dnf -qy module disable postgresql
        sudo dnf install postgresql13-server postgresql13
        dnf list installed | grep postgresql
            if [ $? -eq 0 ];
            then
                echo "postgresql is successfully installed"
            else
                echo "Unable to install postgresql"
                exit 1
            fi        
        echo "Initializing DB setup"
        sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
        echo "Starting and enabling postgresql on Redhat"
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
        echo "Checking if postgresql is up and running or not"
        sudo systemctl start postgresql > Status.txt
            if [ "$(grep -Ei 'Active: active (exited)' Status.txt)" ];
            then
                echo "postgresql is up and active"
            elif [ "$(grep -Ei 'Active: inactive (dead)' Status.txt)" ];
            then
                echo "postgresql is inactive"
                exit 1
            fi
        ##Need to create postgres_conf.txt and pg_hba_conf.txt files in temp location as we have to edit the config files which we cant  do while executing shell script
        echo "Allowing all remote connections"
        sudo cat /tmp/postgres_conf.txt > /etc/postgresql/13/main/postgresql.conf
        echo "setting up access permissions"
        sudo cat pg_hba_conf.txt > /var/lib/pgsql/13/data/pg_hba.conf
        echo "Restarting postgres sql"
        sudo systemctl restart postgresql    
        echo "Switching to the user"
        sudo -i -u postgres
        psql
        echo "Creating Database"
        CREATE DATABASE Sonarcube;  
        CREATE USER Sonarcube WITH ENCRYPTED PASSWORD 'Sonarcube'; 
        GRANT ALL PRIVILEGES ON DATABASE Sonarcube TO Sonarcube;  
        \q
        exit
        fi
    fi  
}

echo "Intsalling postgres"
Unzip_Installation

