DROP USER IF EXISTS 'permanent_make_up_rwx';
CREATE USER 'permanent_make_up_rwx'@'%';

CREATE DATABASE IF NOT EXISTS main;
GRANT SELECT, INSERT, DELETE, UPDATE ON main.* TO 'permanent_make_up_rwx'@'%' IDENTIFIED BY 'ekl84';
GRANT ALL ON main.* TO 'permanent_make_up_rwx'@'%' IDENTIFIED BY 'ekl84';
