userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
date=$(date +"%Y-%m-%d %H:%M:%S")
script_name=$0
logfolder=/var/log/shell-script
logfile=$logfolder/$script_name-$date.log
mkdir -p $logfolder
validate()
{
  if [ $1 -ne 0 ]; then
    echo -e "$R $2 installation failed.please check $N"&>>$logfile
  else
    echo -e "$G $2 installation success $N"&>>$logfile
  fi
}
usage()
{
  if [ $1 -eq 0 ]; then
    echo "Please pass params like package1,package2...."
    exit 1
  fi
}
if [ $userid -ne 0 ]; then
    echo -e "$Y script packages executes with root privileges $N $userid"
    exit 1
fi

dnf list installed mysql-server
if [ $? -ne 0 ]; then
  echo -e "$Y mysql-server not installed.please installed it..$N"&>>$logfile
  dnf install mysql-server -y &>>$logfile
  validate $? "mysql-server"
else
  echo -e "$G mysql-server installed already.nothing to do!..$N" | tee -a $logfile
fi

systemctl enable mysqld
validate $? "Enable mysqld" &>>$logfile
systemctl start mysqld
validate $? "Start mysqld" &>>$logfile
mysql -h 172.31.86.123 -u root -pExpenseApp@1 -e 'show databases' &>>$logfile
if [ $? -ne 0 ]; then
  echo -e "$R mysql password not set,please set mysql root password $N"&>>$logfile
  mysql_secure_installation --set-root-pass ExpenseApp@1
  validate $? "mysql-server set password"
else
  echo -e "$G Password already set, You cannot reset the password with mysql_secure_installation...$N" | tee -a $logfile
fi

#usage $#
#for package in $@
#do
#dnf list installed $package
#if [ $? -ne 0 ]; then
#  echo -e "$Y $package not installed.please installed it..$N"&>>$logfile
#  dnf install $package -y &>>$logfile
#  validate $? $package
#else
#  echo -e "$G $package installed already.nothing to do!..$N" | tee -a $logfile
#fi
#
#done



