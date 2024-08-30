userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
DATE=$(date +"%Y-%m-%d %H:%M:%S")
logfolder=/var/log/shell-script
script_name=$0
logfile=$logfolder/$script_name-$DATE.log
mkdir -p $logfolder
if [ $userid -ne 0 ]
then
  echo "execute script in root privileges"
  exit 1
fi
validate()
{
if [ $1 -ne 0 ]
then
  echo "$2 failed"
else
  echo "$2 success"
  fi
}

dnf install nginx -y &>>$logfile
validate $? "Install nginx" &>>$logfile
systemctl enable nginx
validate $? "Enable nginx" &>>$logfile
systemctl start nginx
validate $? "Start nginx" &>>$logfile
rm -rf /usr/share/nginx/html/*
validate $? "remove default nginx content" &>>$logfile
curl -o /tmp/frontend.zip https://expense-artifacts.s3.amazonaws.com/expense-frontend-v2.zip
validate $? "download frontend code" &>>$logfile
cd /usr/share/nginx/html
validate $? "move to this directory" &>>$logfile
unzip /tmp/frontend.zip
validate $? "unarchive frontend code" &>>$logfile
cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
validate $? "copy expense conf from server" &>>$logfile
systemctl restart nginx
validate $? "restart nginx server" &>>$logfile