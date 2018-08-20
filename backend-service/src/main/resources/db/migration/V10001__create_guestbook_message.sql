CREATE TABLE main.guestbook_message (
  id BIGINT NOT NULL AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  message VARCHAR(255),
  image_uri VARCHAR(255),
  PRIMARY KEY (id)
);