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
  echo -e "$2 $G success $N" &>>$logfile
fi
}
dnf module disable nodejs -y &>>$logfile
validate $? "nodejs module disabled"|tee -a $logfile
dnf module enable nodejs:20 -y &>>$logfile
validate $? "nodejs module enabled" &>>$logfile
dnf install nodejs -y &>>$logfile
validate $? "install nodejs" &>>$logfile
