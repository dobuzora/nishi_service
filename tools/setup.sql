INSERT INTO hang_url (user_id, url, do_notify, created_at, updated_at) VALUES (1, 'http://code-hex.tumblr.com/', 1, '2016-10-09 23:49:27.866277', '2016-10-09 23:49:27.866277');
INSERT INTO hang_url (user_id, url, do_notify, created_at, updated_at) VALUES (2, 'http://www.yahoo.co.jp/', 1, '2016-10-09 23:49:37.619018', '2016-10-09 23:49:37.619018');
INSERT INTO hang_url (user_id, url, do_notify, created_at, updated_at) VALUES (2, 'http://code-hex.tumblr.com/', 1, '2016-10-09 23:50:08.891442', '2016-10-09 23:50:08.891442');

INSERT INTO users (username, password, token, created_at, updated_at) VALUES ('Mc_Donald', '12345678', 'abcdefghijklmn', now(), now());
INSERT INTO users (username, password, token, created_at, updated_at) VALUES ('CodeHex', 'Alpaca2016', 'opqrstuvwxyz!?', now(), now());

INSERT INTO website (url, html_hash, created_at, updated_at) VALUES ('http://code-hex.tumblr.com/', '87783d6a3b34dc771d28f5b07c8be8e4', now(), now());
INSERT INTO website (url, created_at, updated_at) VALUES ('http://www.yahoo.co.jp/', now(), now());