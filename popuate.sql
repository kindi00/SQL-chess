INSERT INTO PIECETYPES (name, white_visual_representation, bloack_visual_representation)
    VALUES ('pawn', '♙', '♟'), ('rook', '♖', '♜'), ('queen', '♕', '♛'), ('king', '♔', '♚'), ('knight', '♘', '♞'), ('bishop', '♗', '♝');

INSERT INTO MOVES (col, row, repeatable, sym) 
    VALUES  (0, 1, FALSE, FALSE),
            (0, 1, FALSE, TRUE),
            (1, 1, FALSE, TRUE),
            (0, 1, TRUE, TRUE), 
            (1, 1, TRUE, TRUE),
            (1, 2, FALSE, TRUE),
            (2, 1, FALSE, TRUE);

INSERT INTO AVAILABLEMOVES (ptid, mid)
    VALUES (1, 1),
           (2, 4),
           (3, 4),
           (3, 5),
           (4, 2),
           (4, 3),
           (5, 7),
           (5, 8),
           (6, 3);

INSERT INTO PLAYERS (name) VALUES ('Zosia');
INSERT INTO PLAYERS (name) VALUES ('Dominik');
