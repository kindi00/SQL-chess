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
    -- turn False means it is first player's turn,
    -- turn True means it is second player's turn,
    -- status 0 means not started
    -- status 1 means running
    -- status NULL means finished
    bid      SMALLINT PRIMARY KEY REFERENCES BOARDS(id),
    fplayer  SMALLINT REFERENCES PLAYERS(id),
    splayer  SMALLINT REFERENCES PLAYERS(id),
    turn     BOOLEAN,
    status   BOOLEAN
);

CREATE OR REPLACE FUNCTION convert_alpha_to_int(v VARCHAR(1)) RETURNS SMALLINT AS $$
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
        EXECUTE FORMAT('LISTEN lobby_%s_p1', board);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE join_lobby(game_id integer, my_id integer) AS $$
DECLARE
    player  GAMES.splayer%TYPE;
    my_name    PLAYERS.name%TYPE;
BEGIN
    SELECT splayer FROM GAMES WHERE bid = game_id INTO player;
    SELECT name FROM PLAYERS WHERE id = my_id INTO my_name;
    IF player IS NULL THEN
        UPDATE GAMES SET splayer = my_id WHERE bid = game_id;
        EXECUTE FORMAT('LISTEN lobby_%s_p2', game_id);
        EXECUTE FORMAT('NOTIFY lobby_%s_p1, ''[Lobby %1$s] Player %s has joined the lobby.''', game_id, my_name);
        CALL start_game(game_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE start_game(game_id integer) AS $$
    DECLARE
        first_player    GAMES.turn%TYPE;
    BEGIN
        SELECT FLOOR(RANDOM() * 2)::int::boolean INTO first_player;  
        UPDATE GAMES SET status = TRUE, turn = first_player WHERE bid = game_id;
        EXECUTE FORMAT('NOTIFY lobby_%s_p%s, ''[Lobby %1$s] It''''s your turn!''', game_id, first_player::int+1);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION convert_position_to_ints(pos varchar(2)) RETURNS
    TABLE (col SMALLINT,
           r SMALLINT) AS $$
    DECLARE
        arr VARCHAR(1) ARRAY[2];
    BEGIN
        SELECT * FROM regexp_split_to_array(pos, '\s*') INTO arr;
        RETURN QUERY SELECT convert_alpha_to_int(arr[1]) AS col, arr[2]::SMALLINT AS r; 
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE move(my_id integer, board_id integer, _start varchar(2), _end varchar(2)) AS $$
    << outerblock >>
    DECLARE
        start_pos   RECORD;
        end_pos     RECORD;
        game        GAMES%ROWTYPE;
    BEGIN
        SELECT * FROM GAMES WHERE bid = board_id INTO game;
        IF game.fplayer != my_id AND (game.splayer != my_id OR game.splayer IS NULL) THEN
            RAISE NOTICE '[Lobby %] Move aborted: you are not a player in this lobby.', board_id;
            EXIT outerblock;
        ELSIF NOT game.status THEN
            RAISE NOTICE '[Lobby %] Move aborted: game has not started yet.', board_id;
            EXIT outerblock;
        ELSIF NOT game.turn AND game.fplayer != my_id THEN
            RAISE NOTICE '[Lobby %] Move aborted: it''s not your turn.', board_id;
            EXIT outerblock;
        ELSIF game.turn AND game.splayer != my_id THEN
            RAISE NOTICE '[Lobby %] Move aborted: it''s not your turn.', board_id;
            EXIT outerblock;
        END IF;
        -- TODO
        -- make sure that it is valid turn order
        -- make sure that a move is valid
        -- notify about changes after move

        -- crete array valid moves [pos]
        -- foreach
        -- if symm: for i in range 1 + 3*is_sym
        -- couter := 1
        -- while not blocked by other piece: insert pos+vector into arr
        -- if not rep break
        -- rotate by 90deg (++ -> -+ -> -- -> +-) (01 -> -10 -> 0-1 -> 10) (11 -> -11 -> -1-1 -> 1-1)
        SELECT * FROM convert_position_to_ints(_start) INTO start_pos;
        SELECT * FROM convert_position_to_ints(_end) INTO end_pos;
        EXECUTE FORMAT('UPDATE pieces SET col = %s, row = %s-1 WHERE bid = %s AND col = %s AND row = %s-1',
                        end_pos.col, end_pos.r, board_id, start_pos.col, start_pos.r);
        UPDATE GAMES SET turn = NOT turn WHERE bid = board_id;
    END;
$$ LANGUAGE plpgsql;

(01 -> -10 -> 0-1 -> 10)
(11 -> -11 -> -1-1 -> 1-1)
1. row <-> col, col * -1
2. row <-> col, col * -1
3. row <-> col, col * -1

CREATE OR REPLACE FUNCTION notify_turn() RETURNS TRIGGER AS $$
BEGIN
    EXECUTE FORMAT('NOTIFY lobby_%s_p%s, ''[Lobby %1$s] It''''s your turn!''', NEW.bid, NEW.turn::int+1);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER turn_change AFTER UPDATE ON GAMES
    FOR EACH ROW
    WHEN (OLD.turn != NEW.turn)
    EXECUTE FUNCTION notify_turn();


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
