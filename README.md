# SQLCHESS documentation
### Developed by kindii00

## 1. Introduction
This project implements chess in PL/pgSQL and PL/SQL.

## 2. Installation
### PostgreSQL
1. Install contents from file postgresql/create.sql
2. Install contents from file postgresql/populate.sql 

If you use console, you can do it by using command

`psql -U username -d databaseName -a -f postgresql/create.sql -f postgresql/populate.sql`

### Oracle
1. Install contents from file oracle/create.sql
2. Install contents from file oracle/populate.sql

## 3. How to play?
### Starting a game
1. Insert yourself as player in table PLAYERS, eg. `INSERT INTO PLAYERS (name) VALUES ('myName');`
2. Create or join a lobby:
   a) Create a lobby `CALL create_lobby(myID);` where `myID` is id of you in table PLAYERS
   b) Or join an existing lobby `CALL join_lobby(gameID, myID);` where `gameID` is id of a game in table GAMES and `myID` is id of you in table PLAYERS
3. If using Oracle database, call start_game `CALL start_game(gameID);` where `gameID` is id of game in table GAMES

### During game
1. If you want to move a piece - `CALL move(myID, gameID, start, end);` where
   a) `myID` is id of you in table PLAYERS,
   b) `gameID` is id of a game in table GAMES,
   c) `start` is a starting position, eg. 'A2',
   d) `end` is a final position, eg. 'A4'
2. If you want to see a board - `CALL print_board(gameID);` where `gameID` is id of game in table GAMES
