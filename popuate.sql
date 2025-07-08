INSERT INTO PIECETYPES (name)
    VALUES ('pawn'), ('tower'), ('queen'), ('king'), ('knight'), ('bishop');

INSERT INTO MOVES 
    VALUES (0, 1, FALSE, FALSE),
    VALUES(0, 1, FALSE, TRUE),
    VALUES(1, 1, FALSE, TRUE);
