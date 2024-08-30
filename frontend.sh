userid=$(id -u)
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

dnf install nginx -y
validate $? "Install nginx"
systemctl enable nginx
validate $? "Enable nginx"
systemctl start nginx
validate $? "Start nginx"
rm -rf /usr/share/nginx/html/*
validate $? "remove default nginx content"
curl -o /tmp/frontend.zip https://expense-artifacts.s3.amazonaws.com/expense-frontend-v2.zip
validate $? "download frontend code"
