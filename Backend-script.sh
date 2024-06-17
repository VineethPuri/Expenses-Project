#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$( echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please Enter DB password:"
read -s mysql_root_password

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

dnf module disable nodejs -y &>>LOGFILE
VALIDATE $? "Disabling defult nodejs"

dnf module enable nodejs:20 -y &>>LOGFILE
VALIDATE $? "Enabling nodejs 20 version"

dnf install nodejs -y &>>LOGFILE
VALIDATE $? "Installing Nodejs"

id expense &>>LOGFILE
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "Adding user"
else
    echo -e "Expense user already created...$Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "Creating App directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip
VALIDATE $? "Extrated backend code"

cd /app #downloading dependencies
npm install
VALIDATE $? "Dependencies downloading"

chmod 777 /home/ec2-user/Expenses-Project/backend.service   

cp /home/ec2-user/Expenses-Project/backend.service /etc/systemd/system/backend.service &>>LOGFILE
VALIDATE $? "Copied backedend service"

cd /etc/systemd/system
chmod 777 backend.service

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "Reloading daemon"

systemctl start backend &>>LOGFILE
VALIDATE $? "Starting backend"
systemctl enable backend &>>LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>LOGFILE
VALIDATE $? "Installing MYSQL Client"

mysql -h 172.31.17.247 -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>LOGFILE
VALIDATE $? "Shema Loading"

systemctl restart backend &>>LOGFILE
VALIDATE $? "Restarting Backend"








