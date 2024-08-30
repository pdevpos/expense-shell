userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
if [ $userid -ne 0 ]; then
  echo -e "$Y script executes in root privileges $userid $N"
  exit 1
fi
validate()
{
if [ $1 -ne 0 ]
then
    echo -e "$2 $R failed $N"
else
  echo -e "$2 $R success $N"
fi
}
dnf module disable nodejs -y
validate $? "nodejs module disabled"
dnf module enable nodejs:20 -y
validate $? "nodejs module enabled"
dnf install nodejs -y
validate $? "install nodejs"
