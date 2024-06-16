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

mkdir -p /app
VALIDATE $? "Creating App directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
unzip /tmp/backend.zip
VALIDATE $? "Extrated backend code"

cd /app #downloading dependencies
npm install
VALIDATE $? "Dependencies downloading"

cp /home/ec2-user/Expenses-Project/backend.service /etc/systemd/system/backend.service
VALIDATE $? "Copied backedend service"

systemctl daemon-reload &>>LOGFILE
systemctl start backend &>>LOGFILE
systemctl enable backend &>>LOGFILE
VALIDATE $? "Starting and Enabling backend"

dnf install mysql -y &>>LOGFILE
VALIDATE $? "Installing MYSQL Client"

mysql -h db.daws78s.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>LOGFILE
VALIDATE $? "Shema Loading"

systemctl restart backend &>>LOGFILE
VALIDATE $? "Restarting Backend"








