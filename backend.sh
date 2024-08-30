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
validate $? "move to directory /app" &>>$logfile
rm -rf /app/*
validate $? "remove previous backend code" &>>$logfile
unzip /tmp/backend.zip
validate $? "unzip backend code" &>>$logfile
cd /app
validate $? "move to directory /app" &>>$logfile
npm install
validate $? "install npm dependencies" &>>$logfile
cp /home/ec2-user/expense-shell/backend.service  /etc/systemd/system/backend.service
validate $? "Copy backend service from local to server" &>>$logfile
systemctl daemon-reload
validate $? "To reload backend service" &>>$logfile
systemctl enable backend
validate $? "Enable backend service" &>>$logfile
systemctl start backend
validate $? "Start backend service" &>>$logfile
dnf install mysql -y
validate $? "Install mysql" &>>$logfile
mysql -h 172.31.86.123 -uroot -pExpenseApp@1 < /app/schema/backend.sql
validate $? "load schema to mysql" &>>$logfile
systemctl restart backend
validate $? "restart backend service" &>>$logfile


