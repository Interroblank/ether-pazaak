pragma solidity >=0.4.22 <0.7.0;

// EtherPazaak
// Interroblank, 2020

// Based on the minigame 'Pazaak' from the classic CRPG: 'Star Wars: Knights of the Old Republic'.

contract EtherPazaak {
    
    // Initializing fields.
    int8[9] public board1;
    int8[9] public board2;
    int8[4] public hand1;
    int8[4] public hand2;
    address payable public player1;
    address payable public player2;
    // Players' decks.
    uint8 public player1d = 1; // 'side1p1' by default.
    uint8 public player2d = 4; // 'side1p2' by default.
    // Players' points.
    uint8 public player1p = 0;
    uint8 public player2p = 0;
    // If the players have bought in.
    bool public player1b = false;
    bool public player2b = false;
    // If either player is standing.
    bool public player1s = false;
    bool public player2s = false;
    // If the first player is up next.
    bool public player1t;
    
    // Initializing the decks.
    uint8[40] public main = [1, 1, 1, 1,
                            2, 2, 2, 2,
                            3, 3, 3, 3,
                            4, 4, 4, 4,
                            5, 5, 5, 5,
                            6, 6, 6, 6,
                            7, 7, 7, 7,
                            8, 8, 8, 8,
                            9, 9, 9, 9,
                            10, 10, 10, 10];
    int8[10] public side1p1 = [-2, -2, -1, -1, 1, 1, 2, 2, 3, 3];       // 1.
    int8[10] public side2p1 = [-6, -6, -4, -4, 2, 2, 4, 4, 6, 6];       // 2.
    int8[10] public side3p1 = [-5, -5, -4, -4, -3, -3, -2, -2, -1, -1]; // 3.
    int8[10] public side1p2 = [-2, -2, -1, -1, 1, 1, 2, 2, 3, 3];       // 4.
    int8[10] public side2p2 = [-6, -6, -4, -4, 2, 2, 4, 4, 6, 6];       // 5.
    int8[10] public side3p2 = [-5, -5, -4, -4, -3, -3, -2, -2, -1, -1]; // 6.
    
    event update();
    
    // Constructor method.
    constructor() public {
        // player1 = msg.sender;
        // 'Emptying' the hands and boards (preparing them for play).
        fold();
        empty();
    }
    
    // Will allow a second player to join the game.
    function join() public {
        if (player1 == address(0)) {
            player1 = msg.sender;
        }
        else if (player2 == address(0)) {
            player2 = msg.sender;
        }
    }
    
    // Will allow players to pick a side deck.
    // TODO - Do not allow both players to pick the same instance of the same side deck.
    function deck(uint8 s) public {
        if (msg.sender == player1)
            { player1d = s; }
        if (msg.sender == player2)
            { player2d = s; }
    }
    
    // Will allow players to buy in.
    function buy() public payable {
        require (msg.value >= 0.0005 ether);
        if (msg.sender == player1) {
            player1b = true;
        }
        if (msg.sender == player2) {
            player2b = true;
        }
    }
    
    // Will transfer the ether in the pot to the winner.
    function pot(uint8 p) public {
        if (p == 1)
            { player1.transfer(address(this).balance); }
        if (p == 2)
            { player2.transfer(address(this).balance); }
    }
    
    // Will prepare the game for both players.
    function start() public {
        // Only the first player may begin the game.
        require (msg.sender == player1);
        // Both players must have bought in.
        // require ((player1b == true) || (player2b == true));
        // Dealing the players' hands and beginning the game.
        deal();
        player1t = true;
        draw(1);
        emit update();
    }
    
    // Will cycle the turn.
    function turn() public {
        // If it is currently the first player's turn.
        if (player1t == true) {
            require (msg.sender == player1);
            // Evaluating the game boards.
            bool val = eval();
            // If play can continue.
            if (val == false) {
                player1t = false;
                // Drawing a card for player two.
                if (player2s == false) {
                    draw(2);
                }
            }
            // If points have been awarded.
            else {
                // If a player has won the game.
                if ((player1p >= 3) || player2p >= 3) {
                    end();
                }
                // Default back to player one for the next round.
                else {
                    empty();
                    reset();
                    player1t = true;
                    draw(1);
                }
            }
        }
        // Else it must be the second player's turn.
        else {
            require (msg.sender == player2);
            // Evaluating the game boards.
            bool val = eval();
            // If play can continue.
            if (val == false) {
                player1t = true;
                // Drawing a card for player two.
                if (player1s == false) {
                    draw(1);
                }
            }
            // If points have been awarded.
            else {
                // If a player has won the game.
                if ((player1p >= 3) || player2p >= 3) {
                    end();
                }
                // Default back to player one for the next round.
                else {
                    empty();
                    reset();
                    player1t = true;
                    draw(1);
                }
            }
        }
        emit update();
    }
    
    // Will initialize the hands.
    function deal() public {
        // TODO - Add support for other side decks.
        // TODO - Address the issue of card duplication.
        if (player1d == 1) {
            // Fetching four random cards from the first player's side deck and dealing them to the player's hand.
            (int8 temp1, int8 temp2, int8 temp3, int8 temp4) = qand(10);
            if (side1p1[uint(temp1)] != 0) {
                hand1[0] = int8(side1p1[uint(temp1)]);
            }
            if (side1p1[uint(temp2)] != 0) {
                hand1[1] = int8(side1p1[uint(temp2)]);
            }
            if (side1p1[uint(temp3)] != 0) {
                hand1[2] = int8(side1p1[uint(temp3)]);
            }
            if (side1p1[uint(temp4)] != 0) {
                hand1[3] = int8(side1p1[uint(temp4)]);
            }
        }
        if (player2d == 4) {
            // Fetching four random cards from the second player's side deck and dealing them to the player's hand.
            (int8 temp1, int8 temp2, int8 temp3, int8 temp4) = qand(9);
            if (side1p2[uint(temp1)] != 0) { // TODO - 'qand(9)' is not a tenable solution.
                hand2[0] = int8(side1p1[uint(temp1)]);
            }
            if (side1p2[uint(temp2)] != 0) {
                hand2[1] = int8(side1p1[uint(temp2)]);
            }
            if (side1p2[uint(temp3)] != 0) {
                hand2[2] = int8(side1p1[uint(temp3)]);
            }
            if (side1p2[uint(temp4)] != 0) {
                hand2[3] = int8(side1p1[uint(temp4)]);
            }
        }
        emit update();
    }
    
    // Will randomly select a card from the main deck and place it on the board.
    function draw(uint8 p) public {
        // For the first player.
        if (p == 1) {
            while(true) {
                uint temp1 = uint(rand(40));
                // If the card selected has not been previously selected.
                if (main[temp1] != 0) {
                    // Place it on the board.
                    board1[find(1)] = int8(main[temp1]);
                    main[temp1] = 0;
                    break;
                }
            }
        }
        // For the second player.
        if (p == 2) {
            while(true) {
                uint temp2 = uint(rand(40));
                // If the card selected has not been previously selected.
                if (main[temp2] != 0) {
                    // Place it on the board.
                    board2[find(2)] = int8(main[temp2]);
                    main[temp2] = 0;
                    break;
                }
            }
        }
        emit update();
    }
    
    // Will allow a player to place a card from their hand onto their board.
    function play(uint8 c) public {
        if (msg.sender == player1) {
            if ((player1t == true) && (player1s == false)) {
                board1[find(1)] = hand1[c];
                hand1[c] = 0;
            }
        }
        if (msg.sender == player2) {
            if ((player1t == false) && (player2s == false)) {
                board2[find(2)] = hand2[c];
                hand2[c] = 0;
            }
        }
        emit update();
    }
    
    // Will stand a player.
    function stand() public {
        if (msg.sender == player1) {
            player1s = true;
        }
        if (msg.sender == player2) {
            player2s = true;
        }
    }
    
    // Will return a pseudorandom integer up to the input integer.
    function rand(int8 r) view public returns (int8) {
        bytes32 hash = sha256(abi.encode(block.timestamp));
        uint8 temp = (uint8(hash[0])) % uint8(r);
        return int8(temp);
    }
    
    // Will return four pseudorandom integers up to the input integer.
    function qand(int8 r) view public returns (int8, int8, int8, int8) {
        bytes32 hash = sha256(abi.encode(block.timestamp));
        uint8 temp1 = (uint8(hash[0])) % uint8(r);
        uint8 temp2 = (uint8(hash[1])) % uint8(r);
        uint8 temp3 = (uint8(hash[2])) % uint8(r);
        uint8 temp4 = (uint8(hash[3])) % uint8(r);
        return (int8(temp1), int8(temp2), int8(temp3), int8(temp4));
    }
    
    // Will find the next free space on the board.
    function find(uint8 p) public view returns (uint8) {
        int8 temp;
        // For the first player.
        if (p == 1) {
            for (uint i = 0; i < 9; i++) {
                if (board1[i] == 0) {
                    temp = int8(i);
                    break;
                }
            }
        }
        // For the second player.
        if (p == 2) {
            for (uint j = 0; j < 9; j++) {
                if (board2[j] == 0) {
                    temp = int8(j);
                    break;
                }
            }
        }
        return uint8(temp);
    }
    
    // Will calculate the sum of all cards on the board.
    function sum(uint8 p) public view returns (uint8) {
        int8 temp = 0;
        // For the first player.
        if (p == 1) {
            for (uint i = 0; i < 9; i++) {
                temp = temp + board1[i];
            }
        }
        // For the second player.
        if (p == 2) {
            for (uint j = 0; j < 9; j++) {
                temp = temp + board2[j];
            }
        }
        return uint8(temp);
    }
    
    // Will reset the decks and other booleans.
    function reset() public {
        main = [1, 1, 1, 1,
                2, 2, 2, 2,
                3, 3, 3, 3,
                4, 4, 4, 4,
                5, 5, 5, 5,
                6, 6, 6, 6,
                7, 7, 7, 7,
                8, 8, 8, 8,
                9, 9, 9, 9,
                10, 10, 10, 10];
        side1p1 = [-2, -2, -1, -1, 1, 1, 2, 2, 3, 3];
        side2p1 = [-6, -6, -4, -4, 2, 2, 4, 4, 6, 6];
        side3p1 = [-5, -5, -4, -4, -3, -3, -2, -2, -1, -1];
        side1p2 = [-2, -2, -1, -1, 1, 1, 2, 2, 3, 3];
        side2p2 = [-6, -6, -4, -4, 2, 2, 4, 4, 6, 6];
        side3p2 = [-5, -5, -4, -4, -3, -3, -2, -2, -1, -1];
        player1s = false;
        player2s = false;
        emit update();
    }
    
    // Will empty both hands.
    function fold() public {
        for (uint i = 0; i < 4; i++) {
            hand1[i] = 0;
            hand2[i] = 0;
        }
        emit update();
    }
    
    // Will empty both boards.
    function empty() public {
        for (uint i = 0; i < 9; i++) {
            board1[i] = 0;
            board2[i] = 0;
        }
        emit update();
    }
    
    // Will determine if a win condition has been met and allocate points.
    function eval() public returns (bool) {
        // If the first player has gone bust.
        if (sum(1) > 20) {
            player2p = player2p + 1;
            return true;
        }
        // If the second player has gone bust.
        if (sum(2) > 20) {
            player1p = player1p + 1;
            return true;
        }
        // If both players are standing.
        if ((player1s == true) && (player2s == true)) {
            // If player one has a higher sum than player two.
            if (sum(1) > sum(2)) {
                player1p = player1p + 1;
                return true;
            }
            // If player two has a higher sum than player one.
            else if (sum(1) < sum(2)) {
                player2p = player2p + 2;
                return true;
            }
            // If both players have the same amount.
            else {
                return true;
            }
        }
        emit update();
    }
    
    // Will return the total point count of the given player.
    function count(uint8 p) public view returns (uint8) {
        if (p == 1) {
            return player1p;
        }
        if (p == 2) {
            return player2p;
        }
    }
    
    // Will end the game and disperse winnings.
    function end() public {
        // TODO - Devise a better way of 'locking down' the game after play has ended.
        player1s = true;
        player2s = true;
        if (player1p >= 3) {
            pot(1);
        }
        if (player2p >= 3) {
            pot(2);
        }
    }
    
} 
