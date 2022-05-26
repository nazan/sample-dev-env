CREATE DATABASE test;
GRANT ALL PRIVILEGES ON test.* TO 'root'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON test.* TO 'root'@'localhost' IDENTIFIED BY 'password';