
-- MySQL 2 PostgreSQL dump

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;

-- Table: Books
DROP TABLE IF EXISTS "books" CASCADE;
CREATE TABLE "books" (
  "id" integer NOT NULL,
  "title" character varying(60) NOT NULL,
  "isbn" character varying(30) NOT NULL,
  "price" real NOT NULL,
  "author" character varying(100) NOT NULL,
  "pubblisher" character varying(100) NOT NULL,
  "subjects_id" int NOT NULL
)
WITHOUT OIDS;

-- Table: Classes
DROP TABLE IF EXISTS "classes" CASCADE;
CREATE TABLE "classes" (
  "id" integer NOT NULL,
  "section" character varying(1) NOT NULL,
  "year" smallint NOT NULL
)
WITHOUT OIDS;

-- Table: Classes_Books
DROP TABLE IF EXISTS "classes_books" CASCADE;
CREATE TABLE "classes_books" (
  "Classes_id" integer NOT NULL,
  "Books_id" integer NOT NULL
)
WITHOUT OIDS;

DROP SEQUENCE IF EXISTS Conditions_id_seq CASCADE;
CREATE SEQUENCE Conditions_id_seq INCREMENT BY 1
                                  NO MAXVALUE NO MINVALUE CACHE 1;
SELECT pg_catalog.setval('Conditions_id_seq', 5, true);

-- Table: Conditions
DROP TABLE IF EXISTS "conditions" CASCADE;
CREATE TABLE "conditions" (
  "id" integer DEFAULT nextval('Conditions_id_seq'::regclass) NOT NULL,
  "name" character varying(15) NOT NULL
)
WITHOUT OIDS;

DROP SEQUENCE IF EXISTS Negotiations_id_seq CASCADE;
CREATE SEQUENCE Negotiations_id_seq INCREMENT BY 1
                                  NO MAXVALUE NO MINVALUE CACHE 1;
SELECT pg_catalog.setval('Negotiations_id_seq', 1, true);

-- Table: Negotiations
DROP TABLE IF EXISTS "negotiations" CASCADE;
CREATE TABLE "negotiations" (
  "Require_id" integer NOT NULL,
  "Sell_id" integer NOT NULL,
  "id" integer DEFAULT nextval('Negotiations_id_seq'::regclass) NOT NULL
)
WITHOUT OIDS;

-- Table: Require
DROP TABLE IF EXISTS "require" CASCADE;
CREATE TABLE "require" (
  "id" integer NOT NULL,
  "creation_date" timestamp without time zone NOT NULL,
  "Statuses_id" integer NOT NULL,
  "Users_id" integer NOT NULL,
  "Books_id" integer NOT NULL
)
WITHOUT OIDS;

-- Table: Sell
DROP TABLE IF EXISTS "sell" CASCADE;
CREATE TABLE "sell" (
  "id" integer NOT NULL,
  "creation_date" timestamp without time zone NOT NULL,
  "price" integer NOT NULL,
  "old_edition" boolean DEFAULT false NOT NULL,
  "Users_id" integer NOT NULL,
  "Statuses_id" integer NOT NULL,
  "Books_id" integer NOT NULL,
  "Conditions_id" integer NOT NULL
)
WITHOUT OIDS;

-- Table: Statuses
DROP TABLE IF EXISTS "statuses" CASCADE;
CREATE TABLE "statuses" (
  "id" integer NOT NULL,
  "name" character varying(15) NOT NULL
)
WITHOUT OIDS;

DROP SEQUENCE IF EXISTS Users_id_seq CASCADE;
CREATE SEQUENCE Users_id_seq INCREMENT BY 1
                                  NO MAXVALUE NO MINVALUE CACHE 1;
SELECT pg_catalog.setval('Users_id_seq', 1, true);

-- Table: Users
DROP TABLE IF EXISTS "users" CASCADE;
CREATE TABLE "users" (
  "id" integer DEFAULT nextval('Users_id_seq'::regclass) NOT NULL,
  "username" character varying(45) NOT NULL,
  "password" character varying(45),
  "email" character varying(100) NOT NULL
)
WITHOUT OIDS;

DROP SEQUENCE IF EXISTS Subjects_id_seq CASCADE;
CREATE SEQUENCE Subjects_id_seq INCREMENT BY 1 
                                    NO MAXVALUE NO MINVALUE CACHE 1;
SELECT pg_catalog.setval('Subjects_id_seq', 1, true);

-- Table: subjects
DROP TABLE IF EXISTS "subjects" CASCADE;
CREATE TABLE "subjects" (
  "id" integer DEFAULT nextval('Subjects_id_seq'::regclass) NOT NULL,
  "name" character varying(50) NOT NULL
)
WITHOUT OIDS;

--
-- Data for Name: Books; Type: TABLE DATA;
--

COPY "books" ("id", "title", "isbn", "price", "author", "pubblisher") FROM stdin;
\.


--
-- Data for Name: Classes; Type: TABLE DATA;
--

COPY "classes" ("id", "section", "year") FROM stdin;
\.


--
-- Data for Name: Classes_Books; Type: TABLE DATA;
--

COPY "classes_books" ("Classes_id", "Books_id") FROM stdin;
\.


--
-- Data for Name: Conditions; Type: TABLE DATA;
--

COPY "conditions" ("id", "name") FROM stdin;
1	Rovinato
2	Discrete
3	Buone
4	Eccellenti
\.


--
-- Data for Name: Negotiations; Type: TABLE DATA;
--

COPY "negotiations" ("Require_id", "Sell_id", "id") FROM stdin;
\.


--
-- Data for Name: Require; Type: TABLE DATA;
--

COPY "require" ("id", "creation_date", "Statuses_id", "Users_id", "Books_id") FROM stdin;
\.


--
-- Data for Name: Sell; Type: TABLE DATA;
--

COPY "sell" ("id", "creation_date", "price", "old_edition", "Users_id", "Statuses_id", "Books_id", "Conditions_id") FROM stdin;
\.


--
-- Data for Name: Statuses; Type: TABLE DATA;
--

COPY "statuses" ("id", "name") FROM stdin;
\.


--
-- Data for Name: Users; Type: TABLE DATA;
--

COPY "users" ("id", "username", "password", "email") FROM stdin;
\.

ALTER TABLE "subjects" ADD CONSTRAINT "Subjects_id_pkey" PRIMARY KEY(id);
ALTER TABLE "books" ADD CONSTRAINT "Books_id_pkey" PRIMARY KEY(id);ALTER TABLE "classes" ADD CONSTRAINT "Classes_id_pkey" PRIMARY KEY(id);ALTER TABLE "classes_books" ADD CONSTRAINT "Classes_Books_Classes_id_Books_id_pkey" PRIMARY KEY(Classes_id, Books_id);
DROP INDEX IF EXISTS "Classes_Books_Books_id" CASCADE;
CREATE INDEX "Classes_Books_Books_id" ON "classes_books" ("Books_id");
DROP INDEX IF EXISTS "Classes_Books_Classes_id" CASCADE;
CREATE INDEX "Classes_Books_Classes_id" ON "classes_books" ("Classes_id");ALTER TABLE "conditions" ADD CONSTRAINT "Conditions_id_pkey" PRIMARY KEY(id);ALTER TABLE "negotiations" ADD CONSTRAINT "Negotiations_id_Require_id_Sell_id_pkey" PRIMARY KEY(id, Require_id, Sell_id);
DROP INDEX IF EXISTS "Negotiations_Sell_id" CASCADE;
CREATE INDEX "Negotiations_Sell_id" ON "negotiations" ("Sell_id");
DROP INDEX IF EXISTS "Negotiations_Require_id" CASCADE;
CREATE INDEX "Negotiations_Require_id" ON "negotiations" ("Require_id");ALTER TABLE "require" ADD CONSTRAINT "Require_id_pkey" PRIMARY KEY(id);
DROP INDEX IF EXISTS "Require_Users_id" CASCADE;
CREATE INDEX "Require_Users_id" ON "require" ("Users_id");
DROP INDEX IF EXISTS "Require_Books_id" CASCADE;
CREATE INDEX "Require_Books_id" ON "require" ("Books_id");ALTER TABLE "sell" ADD CONSTRAINT "Sell_id_pkey" PRIMARY KEY(id);
DROP INDEX IF EXISTS "Sell_Users_id" CASCADE;
CREATE INDEX "Sell_Users_id" ON "sell" ("Users_id");
DROP INDEX IF EXISTS "Sell_Statuses_id" CASCADE;
CREATE INDEX "Sell_Statuses_id" ON "sell" ("Statuses_id");
DROP INDEX IF EXISTS "Sell_Books_id" CASCADE;
CREATE INDEX "Sell_Books_id" ON "sell" ("Books_id");
DROP INDEX IF EXISTS "Sell_Conditions_id" CASCADE;
CREATE INDEX "Sell_Conditions_id" ON "sell" ("Conditions_id");ALTER TABLE "statuses" ADD CONSTRAINT "Statuses_id_pkey" PRIMARY KEY(id);
DROP INDEX IF EXISTS "Statuses_name" CASCADE;
CREATE UNIQUE INDEX "Statuses_name" ON "statuses" ("name");ALTER TABLE "users" ADD CONSTRAINT "Users_id_pkey" PRIMARY KEY(id);
DROP INDEX IF EXISTS "Users_username" CASCADE;
CREATE UNIQUE INDEX "Users_username" ON "users" ("username");

-- Foreign keys
ALTER TABLE "books" ADD FOREIGN KEY ("subjects_id")
            REFERENCES "subjects"(id);
ALTER TABLE "classes_books" ADD FOREIGN KEY ("Books_id")
            REFERENCES "books"(id);
ALTER TABLE "classes_books" ADD FOREIGN KEY ("Classes_id")
            REFERENCES "classes"(id);ALTER TABLE "negotiations" ADD FOREIGN KEY ("Require_id")
            REFERENCES "require"(id);
ALTER TABLE "negotiations" ADD FOREIGN KEY ("Sell_id")
            REFERENCES "sell"(id);ALTER TABLE "require" ADD FOREIGN KEY ("Books_id")
            REFERENCES "books"(id);
ALTER TABLE "require" ADD FOREIGN KEY ("Users_id")
            REFERENCES "users"(id);ALTER TABLE "sell" ADD FOREIGN KEY ("Books_id")
            REFERENCES "books"(id);
ALTER TABLE "sell" ADD FOREIGN KEY ("Conditions_id")
            REFERENCES "conditions"(id);
ALTER TABLE "sell" ADD FOREIGN KEY ("Statuses_id")
            REFERENCES "statuses"(id);
ALTER TABLE "sell" ADD FOREIGN KEY ("Users_id")
            REFERENCES "users"(id);
