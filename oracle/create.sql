CREATE TABLE PIECETYPES (
    id      NUMBER(9) GENERATED ALWAYS AS IDENTITY,
    name    VARCHAR(20) UNIQUE NOT NULL,
    white_visual_representation     VARCHAR(1) UNIQUE NOT NULL,
    bloack_visual_representation    VARCHAR(1) UNIQUE NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE BOARDS (
    id      NUMBER(9) GENERATED ALWAYS AS IDENTITY,
    tmp     VARCHAR(20),
    PRIMARY KEY (id)
);

CREATE TABLE PIECES (
    id      NUMBER(9) GENERATED ALWAYS AS IDENTITY,
    tid     NUMBER(9),
    bid     NUMBER(9),
    col     NUMBER(9) NOT NULL,
    r       NUMBER(9) NOT NULL,
    affiliation NUMBER(1) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (tid) REFERENCES PIECETYPES(id),
    FOREIGN KEY (bid) REFERENCES BOARDS(id)
);
    
CREATE TABLE MOVES (
    id      NUMBER(9) GENERATED ALWAYS AS IDENTITY,
    col     NUMBER(9) NOT NULL,
    r       NUMBER(9) NOT NULL,
    repeatable  NUMBER(1) NOT NULL,
    sym         NUMBER(1) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE AVAILABLEMOVES (
    ptid    NUMBER(9),
    mid     NUMBER(9),
    PRIMARY KEY (ptid, mid),
    FOREIGN KEY (ptid) REFERENCES PIECETYPES(id),
    FOREIGN KEY (mid) REFERENCES MOVES(id)
);

CREATE TABLE PLAYERS (
    id      NUMBER(9) GENERATED ALWAYS AS IDENTITY,
    name    VARCHAR(50),
    PRIMARY KEY (id)
);

CREATE TABLE GAMES (
    bid      NUMBER(9),
    fplayer  NUMBER(9),
    splayer  NUMBER(9),
    turn     NUMBER(1),
    status   NUMBER(1),
    PRIMARY KEY (bid),
    FOREIGN KEY (bid) REFERENCES BOARDS(id),
    FOREIGN KEY (fplayer) REFERENCES PLAYERS(id),
    FOREIGN KEY (splayer) REFERENCES PLAYERS(id)
);

CREATE OR REPLACE FUNCTION convert_alpha_to_int(v VARCHAR) RETURN NUMBER AS
    BEGIN
        CASE
            WHEN v = 'a' THEN RETURN 0;
            WHEN v = 'b' THEN RETURN 1;
            WHEN v = 'c' THEN RETURN 2;
            WHEN v = 'd' THEN RETURN 3;
            WHEN v = 'e' THEN RETURN 4;
            WHEN v = 'f' THEN RETURN 5;
            WHEN v = 'g' THEN RETURN 6;
            WHEN v = 'h' THEN RETURN 7;
        END CASE;
    END;
/
CREATE OR REPLACE FUNCTION convert_int_to_alpha(i NUMBER) RETURN varchar AS
    BEGIN
        CASE
            WHEN i = 0 THEN RETURN 'a';
            WHEN i = 1 THEN RETURN 'b';
            WHEN i = 2 THEN RETURN 'c';
            WHEN i = 3 THEN RETURN 'd';
            WHEN i = 4 THEN RETURN 'e';
            WHEN i = 5 THEN RETURN 'f';
            WHEN i = 6 THEN RETURN 'g';
            WHEN i = 7 THEN RETURN 'h';
        END CASE;
    END;
/
CREATE OR REPLACE PROCEDURE create_lobby(my_id integer) AS
        board       BOARDS.id%TYPE;
        piece_id    PIECES.tid%TYPE;
    BEGIN
        INSERT INTO BOARDS (tmp) VALUES ('foo') RETURNING id INTO board;
        INSERT INTO GAMES (bid, fplayer, splayer, turn, status)
            VALUES (board, my_id, NULL, 0, 0);

            SELECT id INTO piece_id FROM PIECETYPES WHERE name = 'rook';
            INSERT ALL
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 0, 0, 0)
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 7, 0, 0) 
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 0, 7, 1)
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 7, 7, 1)
            SELECT * FROM DUAL;
            
            SELECT id INTO piece_id FROM PIECETYPES WHERE name = 'knight';
            INSERT ALL 
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 1, 0, 0)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 6, 0, 0)
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 1, 7, 1)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 6, 7, 1)
            SELECT * FROM DUAL;

            SELECT id INTO piece_id FROM PIECETYPES WHERE name = 'bishop';
            INSERT ALL 
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 2, 0, 0)
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 5, 0, 0) 
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 2, 7, 1)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 5, 7, 1)
            SELECT * FROM DUAL;

            SELECT id INTO piece_id FROM PIECETYPES WHERE name = 'queen';
            INSERT ALL 
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 3, 0, 0)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 3, 7, 1)
            SELECT * FROM DUAL;

            SELECT id INTO piece_id FROM PIECETYPES WHERE name = 'king';
            INSERT ALL 
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 4, 0, 0)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 4, 7, 1)
            SELECT * FROM DUAL;

            SELECT id INTO piece_id FROM PIECETYPES WHERE name = 'pawn';
            INSERT ALL 
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 0, 1, 0)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 1, 1, 0)
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 2, 1, 0)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 3, 1, 0)
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 4, 1, 0)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 5, 1, 0)
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 6, 1, 0)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 7, 1, 0)
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 0, 6, 1)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 1, 6, 1)
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 2, 6, 1)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 3, 6, 1)
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 4, 6, 1)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 5, 6, 1)
                INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 6, 6, 1)
				INTO PIECES (tid, bid, col, r, affiliation) VALUES (piece_id, board, 7, 6, 1)
            SELECT * FROM DUAL;
    END;
/
CREATE OR REPLACE PROCEDURE start_game(game_id integer) AS
        first_player    GAMES.turn%TYPE;
    BEGIN
        first_player := FLOOR(dbms_random.value() * 2);  
        UPDATE GAMES SET status = 1, turn = first_player WHERE bid = game_id;
    END;
/
CREATE OR REPLACE PROCEDURE join_lobby(game_id integer, my_id integer) AS
    player  GAMES.splayer%TYPE;
    my_name    PLAYERS.name%TYPE;
BEGIN
    SELECT splayer INTO player FROM GAMES WHERE bid = game_id;
    SELECT name INTO my_name FROM PLAYERS WHERE id = my_id;
    IF player IS NULL THEN
        UPDATE GAMES SET splayer = my_id WHERE bid = game_id;
    END IF;
END;
/
CREATE OR REPLACE FUNCTION convert_position_to_ints(pos varchar) RETURN sys.odcinumberlist AS
    out sys.odcinumberlist;
    colchar CHAR(1) := substr(pos, 1, 1);
    rchar CHAR(1) := substr(pos, 2, 1);
    BEGIN
    select * bulk collect into out from (
        select convert_alpha_to_int(colchar) as col from dual union all
        select to_number(rchar)-1 as r from dual);
    return out;
    END;
/
