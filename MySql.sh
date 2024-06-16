#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$( echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2....$R FAILURE $N"
        EXIT 1
    else
       echo -e "$2....$G SUCCESS $N" 
    fi   
} 

if [ $USERID -ne 0 ]
then
   echo "Please run the script with root access"
   exit 1 #Manully exit if error comes
else
   echo "You are super user"
fi

dnf install mysql-server -y &>>LOGFILE
VALIDATE $? "Installing Mysql Server"

systemctl enable mysqld &>>LOGFILE
VALIDATE $? "Enabling Mysql Server"

systemctl start mysqld &>>LOGFILE
VALIDATE $? "Starting Mysql Server"

#mysql_secure_installation --set-root-pass ExpenseApp@1
#VALIDATE $? "Setting up root password"

#Below code will be useful for idempotent nature
mysql -h db.daws78s.online -uroot -pExpenseApp@1 -e 'show databases:' &>>LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOGFILE
    VALIDATE $? "MYSql Root Password setting up"
else
    echo -e "MySql root password is already setup...$Y SKIPPING $N"
fi




