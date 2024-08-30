userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
DATE=$(date +"%Y-%m-%d %H:%M:%S")
script_name=$0
logfolder=/var/log/shell-script
logfile=/var/log/shell-script/$script_name-$DATE.log
mkdir -p $logfolder
if [ $userid -ne 0 ]; then
  echo -e "$Y script executes in root privileges $userid $N" &>>$logfile
  exit 1
fi
validate()
{
if [ $1 -ne 0 ]
then
    echo -e "$2 $R failed $N" &>>$logfile
else
  echo -e "$2 $G success $N"|tee -a $logfile
fi
}
dnf module disable nodejs -y &>>$logfile
validate $? "nodejs module disabled" &>>$logfile
dnf module enable nodejs:20 -y &>>$logfile
validate $? "nodejs module enabled" &>>$logfile
dnf install nodejs -y &>>$logfile
validate $? "install nodejs"|tee -a $logfile
id expense
if [ $? -ne 0 ]
then
  echo -e "$R useradd: user not created...please add $N" &>>$logfile
  useradd expense
  validate $? "add user as expense" &>>$logfile
else
  echo -e "$G useradd: user 'expense' already exists $N" &>>$logfile
fi
mkdir -p  /app
validate $? "$G make a directory /app $N" &>>$logfile
curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/expense-backend-v2.zip
validate $? "Download backend code"
cd /app
validate $? "move to directory /app"
rm -rf /app/*
validate $? "remove previous backend code"
unzip /tmp/backend.zip
validate $? "unzip backend code"
cd /app
validate $? "move to directory /app"
npm install
validate $? "install npm dependencies"
cp /home/ec2-user/expense-shell/backend.service  /etc/systemd/system/backend.service
validate $? "Copy backend service from local to server"
systemctl daemon-reload
validate $? "To reload backend service"


