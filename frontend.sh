#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$( echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
#echo "Please Enter DB password:"
#read -s mysql_root_password

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

dnf install nginx -y &>>LOGFILE
VALIDATE $? "Installing ngix"

systemctl enable nginx &>>LOGFILE
VALIDATE $? "Enabling ngix"

systemctl start nginx &>>LOGFILE
VALIDATE $? "Strating nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing defult contant"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip
VALIDATE $? "extracting frontend" &>>LOGFILE

cp /home/ec2-user/Expenses-Project/expense.conf /etc/nginx/default.d/expense.conf &>>LOGFILE

systemctl restart nginx
VALIDATE $? "Restartign ngix"





