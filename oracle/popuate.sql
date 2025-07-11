INSERT ALL
    INTO PIECETYPES (name, white_visual_representation, bloack_visual_representation) VALUES ('pawn', '♙', '♟')
    INTO PIECETYPES (name, white_visual_representation, bloack_visual_representation) VALUES ('rook', '♖', '♜')
    INTO PIECETYPES (name, white_visual_representation, bloack_visual_representation) VALUES ('queen', '♕', '♛')
    INTO PIECETYPES (name, white_visual_representation, bloack_visual_representation) VALUES ('king', '♔', '♚')
    INTO PIECETYPES (name, white_visual_representation, bloack_visual_representation) VALUES ('knight', '♘', '♞')
    INTO PIECETYPES (name, white_visual_representation, bloack_visual_representation) VALUES ('bishop', '♗', '♝')
SELECT * FROM DUAL;

INSERT ALL
    INTO MOVES (col, r, repeatable, sym) VALUES (0, 1, 0, 0)
    INTO MOVES (col, r, repeatable, sym) VALUES (0, 1, 0, 1)
    INTO MOVES (col, r, repeatable, sym) VALUES (1, 1, 0, 1)
    INTO MOVES (col, r, repeatable, sym) VALUES (0, 1, 1, 1) 
    INTO MOVES (col, r, repeatable, sym) VALUES (1, 1, 1, 1)
    INTO MOVES (col, r, repeatable, sym) VALUES (1, 2, 0, 1)
    INTO MOVES (col, r, repeatable, sym) VALUES (2, 1, 0, 1)
SELECT * FROM DUAL;

INSERT ALL
    INTO AVAILABLEMOVES (ptid, mid) VALUES (1, 1)
    INTO AVAILABLEMOVES (ptid, mid) VALUES (2, 4)
    INTO AVAILABLEMOVES (ptid, mid) VALUES (3, 4)
    INTO AVAILABLEMOVES (ptid, mid) VALUES (3, 5)
    INTO AVAILABLEMOVES (ptid, mid) VALUES (4, 2)
    INTO AVAILABLEMOVES (ptid, mid) VALUES (4, 3)
    INTO AVAILABLEMOVES (ptid, mid) VALUES (5, 7)
    INTO AVAILABLEMOVES (ptid, mid) VALUES (5, 6)
    INTO AVAILABLEMOVES (ptid, mid) VALUES (6, 3)
SELECT * FROM DUAL;

INSERT INTO PLAYERS (name) VALUES ('Zosia');
INSERT INTO PLAYERS (name) VALUES ('Dominik');
