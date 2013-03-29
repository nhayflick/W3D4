CREATE TABLE users (
  user_id INTEGER PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  is_instructor INTEGER NOT NULL,
  CHECK(is_instructor BETWEEN 0 AND 1)
);

CREATE TABLE questions (
  question_id INTEGER PRIMARY KEY,
  body VARCHAR(255) NOT NULL,
  title VARCHAR(30) NOT NULL,
  author INTEGER NOT NULL,
  FOREIGN KEY(author) REFERENCES users(user_id)
);

CREATE TABLE question_followers (
  follower INTEGER NOT NULL,
  question INTEGER NOT NULL,
  FOREIGN KEY(follower) REFERENCES users(user_id),
  FOREIGN KEY(question) REFERENCES questions(question_id)
);

CREATE TABLE question_replies (
  reply_id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  reply_author INTEGER NOT NULL,
  body VARCHAR(255) NOT NULL,
  FOREIGN KEY(question_id) REFERENCES questions(question_id),
  FOREIGN KEY(reply_author) REFERENCES users(user_id)
);

CREATE TABLE question_actions (
  type VARCHAR(7) NOT NULL,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY(user_id) REFERENCES users(user_id),
  FOREIGN KEY(question_id) REFERENCES questions(question_id),
  CHECK(type IN ('redact', 'close', 'reopen'))
);

CREATE TABLE question_likes (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY(question_id) REFERENCES questions(question_id),
  FOREIGN KEY(user_id) REFERENCES users(user_id)
);

INSERT INTO users ('first_name', 'last_name', 'is_instructor')
  VALUES ('Nederick', 'R', 1), ('Ryan', 'Seepppaassiii', 1) , ('Mill', 'Man', 0);

INSERT INTO questions('body', 'title', 'author')
  VALUES ('Why is the sky blue?', 'Sky', 1), ('How do you know someone is vegan?', 'Sky', 2), ('How do I defeat Ro Man?', 'Conquest', 3);

INSERT INTO question_replies('body', 'question_id', 'reply_author')
  VALUES ('You cannot defeat him!', 3, 1), ('Because science', 1, 2),
          ('He will tell you.', 2, 3), ('Yeah he will def tell you', 2, 1);

INSERT INTO question_likes ('question_id', 'user_id')
VALUES (3, 1), (3, 2), (3, 3 );


