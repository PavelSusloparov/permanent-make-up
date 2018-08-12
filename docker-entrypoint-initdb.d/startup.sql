DROP USER IF EXISTS 'permanent_make_up_rwx';
CREATE USER 'permanent_make_up_rwx'@'%';

CREATE DATABASE IF NOT EXISTS main;
GRANT SELECT, INSERT, DELETE, UPDATE ON main.* TO 'permanent_make_up_rwx'@'%' IDENTIFIED BY 'ekl84';
GRANT ALL ON main.* TO 'permanent_make_up_rwx'@'%' IDENTIFIED BY 'ekl84';

CREATE TABLE main.guestbook_message (
  id BIGINT NOT NULL AUTO_INCREMENT,
  name CHAR(128) NOT NULL,
  message CHAR(255),
  image_uri CHAR(255),
  PRIMARY KEY (id)
);
