CREATE TABLE PIECETYPES (
    -- representation of piece types;
    -- eg: queen, pawn, ...
    id      SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name    VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE BOARDS (
    -- a board on which a game takes place
    id      SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY
);

CREATE TABLE PIECES (
    tid     SMALLINT REFERENCES PIECETYPES(id),
    bid     SMALLINT REFERENCES BOARDS(id),
    col     VARCHAR(1) NOT NULL,
    row     SMALLINT NOT NULL
);

CREATE TABLE MOVES (
    -- moves available for piece types
    -- repeatable means that a piece can move indefinetly in specified direction
    -- symmetric means that a move can be made by changing direction 4 times by 90 deg
    id      SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    column  SMALLINT NOT NULL,
    row     SMALLINT NOT NULL,
    repeatable  BOOLEAN NOT NULL,
    symmetric   BOOLEAN NOT NULL
);

CREATE TABLE AVAILABLEMOVES (
    -- moves available for a piece type
);

CREATE TABLE PLAYERS (

);

CREATE TABLE GAMES (

);

CREATE PROCEDURE STARTLOBBY (

);

CREATE PROCEDURE MOVE (

);

CREATE PROCEDURE PRINTBOARD (

);

