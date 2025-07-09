CREATE TABLE PIECETYPES (
    -- representation of piece types;
    -- eg: queen, pawn, ...
    id      SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name    VARCHAR(20) UNIQUE NOT NULL,
    white_visual_representation     VARCHAR(1) UNIQUE NOT NULL,
    bloack_visual_representation    VARCHAR(1) UNIQUE NOT NULL
);

CREATE TABLE BOARDS (
    -- a board on which a game takes place
    id      SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tmp     VARCHAR(20)
);

CREATE TABLE PIECES (
    -- affiliation FALSE means white or first player
    -- affiliation TRUE means black or second player
    id      SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tid     SMALLINT REFERENCES PIECETYPES(id),
    bid     SMALLINT REFERENCES BOARDS(id),
    col     SMALLINT NOT NULL,
    row     SMALLINT NOT NULL,
    affiliation BOOLEAN NOT NULL
);

CREATE TABLE MOVES (
    -- moves available for piece types
    -- repeatable means that a piece can move indefinetly in specified direction
    -- sym means symmetric - a move can be made by changing direction 4 times by 90 deg
    id      SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    col     SMALLINT NOT NULL,
    row     SMALLINT NOT NULL,
    repeatable  BOOLEAN NOT NULL,
    sym         BOOLEAN NOT NULL
);

CREATE TABLE AVAILABLEMOVES (
    -- moves available for a piece type
    ptid    SMALLINT REFERENCES PIECETYPES(id),
    mid     SMALLINT REFERENCES MOVES(id),
    PRIMARY KEY (ptid, mid)
);

CREATE TABLE PLAYERS (
    id      SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name    VARCHAR(50)
);

CREATE TABLE GAMES (
    -- turn 0/False means it is first player's turn,
    -- turn 1/True means it is second player's turn,
    -- status 0 means not started
    -- status 1 means running
    -- status NULL means finished
    bid      SMALLINT PRIMARY KEY REFERENCES BOARDS(id),
    fplayer  SMALLINT REFERENCES PLAYERS(id),
    splayer  SMALLINT REFERENCES PLAYERS(id),
    turn     BOOLEAN,
    status   BOOLEAN
);

CREATE OR REPLACE PROCEDURE create_lobby(my_id integer) AS $$
    DECLARE
        board BOARDS.id%TYPE;
        piece_id    PIECES.tid%TYPE;
    BEGIN
        INSERT INTO BOARDS (tmp) VALUES ('foo') RETURNING id INTO board;
        INSERT INTO GAMES (bid, fplayer, splayer, turn, status)
            VALUES (board, my_id, NULL, FALSE, FALSE);

            SELECT id FROM PIECETYPES WHERE name = 'rook' INTO piece_id;
            INSERT INTO PIECES (tid, bid, col, row, affiliation) VALUES 
                (piece_id, board, 0, 0, FALSE), (piece_id, board, 7, 0, FALSE), 
                (piece_id, board, 0, 7, TRUE), (piece_id, board, 7, 7, TRUE);
            
            SELECT id FROM PIECETYPES WHERE name = 'knight' INTO piece_id;
            INSERT INTO PIECES (tid, bid, col, row, affiliation) VALUES 
                (piece_id, board, 1, 0, FALSE), (piece_id, board, 6, 0, FALSE), 
                (piece_id, board, 1, 7, TRUE), (piece_id, board, 6, 7, TRUE);

            SELECT id FROM PIECETYPES WHERE name = 'bishop' INTO piece_id;
            INSERT INTO PIECES (tid, bid, col, row, affiliation) VALUES 
                (piece_id, board, 2, 0, FALSE), (piece_id, board, 5, 0, FALSE), 
                (piece_id, board, 2, 7, TRUE), (piece_id, board, 5, 7, TRUE);

            SELECT id FROM PIECETYPES WHERE name = 'queen' INTO piece_id;
            INSERT INTO PIECES (tid, bid, col, row, affiliation) VALUES 
                (piece_id, board, 3, 0, FALSE), (piece_id, board, 3, 7, TRUE);

            SELECT id FROM PIECETYPES WHERE name = 'king' INTO piece_id;
            INSERT INTO PIECES (tid, bid, col, row, affiliation) VALUES 
                (piece_id, board, 4, 0, FALSE), (piece_id, board, 4, 7, TRUE);

            SELECT id FROM PIECETYPES WHERE name = 'pawn' INTO piece_id;
            INSERT INTO PIECES (tid, bid, col, row, affiliation) VALUES 
                (piece_id, board, 0, 1, FALSE), (piece_id, board, 1, 1, FALSE),
                (piece_id, board, 2, 1, FALSE), (piece_id, board, 3, 1, FALSE),
                (piece_id, board, 4, 1, FALSE), (piece_id, board, 5, 1, FALSE),
                (piece_id, board, 6, 1, FALSE), (piece_id, board, 7, 1, FALSE),
                (piece_id, board, 0, 6, TRUE), (piece_id, board, 1, 6, TRUE),
                (piece_id, board, 2, 6, TRUE), (piece_id, board, 3, 6, TRUE),
                (piece_id, board, 4, 6, TRUE), (piece_id, board, 5, 6, TRUE),
                (piece_id, board, 6, 6, TRUE), (piece_id, board, 7, 6, TRUE);
        
        EXECUTE 'LISTEN lobby_' || board::varchar(10);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION start_game(game_id integer) RETURNS VARCHAR AS $$
        BEGIN
            RETURN 0;
        END;
$$ LANGUAGE plpgsql;

-- SELECT FLOOR(RANDOM() * 2) AS order <- losuj pierwszeństwo

CREATE OR REPLACE FUNCTION move(col int, row int) RETURNS integer AS $$
    BEGIN
        RETURN 0;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION convert_int_to_alpha(i INTEGER) RETURNS varchar(1) AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION print_board(board_id integer) RETURNS 
    TABLE (id  SMALLINT,
            a   VARCHAR(1),
            b   VARCHAR(1),
            c   VARCHAR(1),
            d   VARCHAR(1),
            e   VARCHAR(1),
            f   VARCHAR(1),
            g   VARCHAR(1),
            h   VARCHAR(1)) AS $$
    DECLARE
        piece   PIECES%ROWTYPE;
        col     VARCHAR(1);
        symbol  VARCHAR(1);
    BEGIN
        CREATE TEMPORARY TABLE pboard (
            id  SMALLINT PRIMARY KEY,
            a   VARCHAR(1),
            b   VARCHAR(1),
            c   VARCHAR(1),
            d   VARCHAR(1),
            e   VARCHAR(1),
            f   VARCHAR(1),
            g   VARCHAR(1),
            h   VARCHAR(1)
        );
        INSERT into pboard VALUES 
            (8, '□', '■', '□', '■', '□', '■', '□', '■'),
            (7, '■', '□', '■', '□', '■', '□', '■', '□'),
            (6, '□', '■', '□', '■', '□', '■', '□', '■'),
            (5, '■', '□', '■', '□', '■', '□', '■', '□'),
            (4, '□', '■', '□', '■', '□', '■', '□', '■'),
            (3, '■', '□', '■', '□', '■', '□', '■', '□'),
            (2, '□', '■', '□', '■', '□', '■', '□', '■'),
            (1, '■', '□', '■', '□', '■', '□', '■', '□');
        FOR piece IN
            SELECT *
                FROM PIECES
                WHERE bid = board_id
        LOOP
            IF piece.affiliation THEN
                SELECT bloack_visual_representation FROM PIECETYPES pt WHERE pt.id = piece.tid INTO symbol;
            ELSE
                SELECT white_visual_representation FROM PIECETYPES pt WHERE pt.id = piece.tid INTO symbol;
            END IF;
            SELECT * FROM convert_int_to_alpha(piece.col) INTO col;
            EXECUTE FORMAT('UPDATE pboard SET %s = ''%s'' WHERE id = 1+%s', col, symbol, piece.row);
        END LOOP;
        RETURN QUERY
            SELECT * FROM pboard ORDER BY id DESC;
        DROP TABLE pboard;
    END;
$$ LANGUAGE plpgsql;
