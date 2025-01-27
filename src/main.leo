// The 'zkplanet' program.
program zkplanet.aleo {
    // Resource quantities per plot in 3x3 grid
    struct Plot {
        iron: u32,
        gold: u32,
        water: u32,
        population: u32,
        has_extractor: bool,
        has_habitat: bool
    }

    // Row in 3x3 grid containing plots
    struct Row {
        c1: Plot,
        c2: Plot,
        c3: Plot
    }

    // Game board representing 3x3 grid
    struct Board {
        r1: Row,
        r2: Row,
        r3: Row
    }

    // Player's resource totals and state
    record PlayerState {
        owner: address,
        iron_total: u32,
        gold_total: u32,
        water_total: u32,
        population_total: u32,
        opponent: address,
    }

    // Trade record for resource exchange
    record Trade {
        owner: address,
        sender: address,
        receiver: address,
        iron_amount: u32,
        gold_amount: u32,
        water_amount: u32,
        is_completed: bool,
    }

    // Creates a new game board with random resources per plot
    transition new() -> (Board, PlayerState) {
        // Initialize empty plot with random resources
        let empty_plot: Plot = Plot {
            iron: 100u32,
            gold: 100u32,
            water: 100u32,
            population: 0u32,
            has_extractor: false,
            has_habitat: false
        };

        // Create board with empty plots
        let board: Board = Board {
            r1: Row { c1: empty_plot, c2: empty_plot, c3: empty_plot },
            r2: Row { c1: empty_plot, c2: empty_plot, c3: empty_plot },
            r3: Row { c1: empty_plot, c2: empty_plot, c3: empty_plot }
        };

        // Initialize player state with starting resources
        let player: PlayerState = PlayerState {
            owner: self.caller,
            iron_total: 0u32,
            gold_total: 50u32, // Starting gold
            water_total: 0u32,
            population_total: 0u32,
            opponent: OPPONENT_ADDRESS,
        };

        return (board, player);
    }

    // Place extractor on a plot to mine resources
    transition place_extractor(
        row: u8, 
        col: u8, 
        resource_type: u8, // 1=iron, 2=gold, 3=water
        board: Board, 
        player: PlayerState
    ) -> (Board, PlayerState) {
        // Verify player has enough gold
        assert(player.gold_total >= 10u32);
        
        // Verify valid position
        assert(1u8 <= row && row <= 3u8);
        assert(1u8 <= col && col <= 3u8);

        // Get current plot state and verify no extractor exists
        let plot: Plot = get_plot(board, row, col);
        assert(!plot.has_extractor);

        // Calculate new resource totals
        let new_iron_total: u32 = resource_type == 1u8 ? player.iron_total + plot.iron : player.iron_total;
        let new_gold_total: u32 = resource_type == 2u8 ? player.gold_total + plot.gold - 10u32 : player.gold_total - 10u32;
        let new_water_total: u32 = resource_type == 3u8 ? player.water_total + plot.water : player.water_total;

        // Create updated player state
        let updated_player: PlayerState = PlayerState {
            owner: player.owner,
            iron_total: new_iron_total,
            gold_total: new_gold_total,
            water_total: new_water_total,
            population_total: player.population_total,
            opponent: player.opponent,
        };

        // Create updated plot with extractor
        let updated_plot: Plot = Plot {
            iron: plot.iron,
            gold: plot.gold,
            water: plot.water,
            population: plot.population,
            has_extractor: true,
            has_habitat: plot.has_habitat
        };

        // Update board with new plot
        let updated_board: Board = update_plot(board, row, col, updated_plot);

        return (updated_board, updated_player);
    }

    // Place habitat to increase population
    transition place_habitat(
        row: u8,
        col: u8,
        board: Board,
        player: PlayerState
    ) -> (Board, PlayerState) {
        // Verify resources
        assert(player.water_total >= 10u32);
        assert(player.gold_total >= 10u32);
        assert(player.iron_total >= 10u32);

        // Verify valid position
        assert(1u8 <= row && row <= 3u8);
        assert(1u8 <= col && col <= 3u8);

        // Get plot and verify no habitat exists
        let plot: Plot = get_plot(board, row, col);
        assert(!plot.has_habitat);

        // Create updated player state
        let updated_player: PlayerState = PlayerState {
            owner: player.owner,
            iron_total: player.iron_total - 10u32,
            gold_total: player.gold_total - 10u32,
            water_total: player.water_total - 10u32,
            population_total: player.population_total + 25u32,
            opponent: player.opponent,
        };

        // Create updated plot with habitat
        let updated_plot: Plot = Plot {
            iron: plot.iron,
            gold: plot.gold,
            water: plot.water,
            population: plot.population,
            has_extractor: plot.has_extractor,
            has_habitat: true
        };

        // Update board with new plot
        let updated_board: Board = update_plot(board, row, col, updated_plot);

        return (updated_board, updated_player);
    }

    // Helper to get plot at position
    function get_plot(board: Board, row: u8, col: u8) -> Plot {
        if row == 1u8 {
            if col == 1u8 { return board.r1.c1; }
            if col == 2u8 { return board.r1.c2; }
            return board.r1.c3;
        } else if row == 2u8 {
            if col == 1u8 { return board.r2.c1; }
            if col == 2u8 { return board.r2.c2; }
            return board.r2.c3;
        } else {
            if col == 1u8 { return board.r3.c1; }
            if col == 2u8 { return board.r3.c2; }
            return board.r3.c3;
        }
    }

    // Helper to update plot at position by creating new board
    function update_plot(board: Board, row: u8, col: u8, new_plot: Plot) -> Board {
        if row == 1u8 {
            if col == 1u8 {
                return Board {
                    r1: Row { c1: new_plot, c2: board.r1.c2, c3: board.r1.c3 },
                    r2: board.r2,
                    r3: board.r3
                };
            } else if col == 2u8 {
                return Board {
                    r1: Row { c1: board.r1.c1, c2: new_plot, c3: board.r1.c3 },
                    r2: board.r2,
                    r3: board.r3
                };
            } else {
                return Board {
                    r1: Row { c1: board.r1.c1, c2: board.r1.c2, c3: new_plot },
                    r2: board.r2,
                    r3: board.r3
                };
            }
        } else if row == 2u8 {
            if col == 1u8 {
                return Board {
                    r1: board.r1,
                    r2: Row { c1: new_plot, c2: board.r2.c2, c3: board.r2.c3 },
                    r3: board.r3
                };
            } else if col == 2u8 {
                return Board {
                    r1: board.r1,
                    r2: Row { c1: board.r2.c1, c2: new_plot, c3: board.r2.c3 },
                    r3: board.r3
                };
            } else {
                return Board {
                    r1: board.r1,
                    r2: Row { c1: board.r2.c1, c2: board.r2.c2, c3: new_plot },
                    r3: board.r3
                };
            }
        } else {
            if col == 1u8 {
                return Board {
                    r1: board.r1,
                    r2: board.r2,
                    r3: Row { c1: new_plot, c2: board.r3.c2, c3: board.r3.c3 }
                };
            } else if col == 2u8 {
                return Board {
                    r1: board.r1,
                    r2: board.r2,
                    r3: Row { c1: board.r3.c1, c2: new_plot, c3: board.r3.c3 }
                };
            } else {
                return Board {
                    r1: board.r1,
                    r2: board.r2,
                    r3: Row { c1: board.r3.c1, c2: board.r3.c2, c3: new_plot }
                };
            }
        }
    }

    // Trade functions remain the same as they don't modify struct fields directly
    transition propose_trade(
        receiver: address,
        iron_amount: u32,
        gold_amount: u32,
        water_amount: u32,
        player: PlayerState
    ) -> Trade {
        assert(player.iron_total >= iron_amount);
        assert(player.gold_total >= gold_amount);
        assert(player.water_total >= water_amount);

        return Trade {
            owner: receiver,
            sender: self.caller,
            receiver: receiver,
            iron_amount: iron_amount,
            gold_amount: gold_amount,
            water_amount: water_amount,
            is_completed: false,
        };
    }

    transition accept_trade(
        trade: Trade,
        sender_state: PlayerState,
        receiver_state: PlayerState
    ) -> (PlayerState, PlayerState) {
        assert(!trade.is_completed);
        assert(trade.owner == self.caller);

        let updated_sender: PlayerState = PlayerState {
            owner: sender_state.owner,
            iron_total: sender_state.iron_total - trade.iron_amount,
            gold_total: sender_state.gold_total - trade.gold_amount,
            water_total: sender_state.water_total - trade.water_amount,
            population_total: sender_state.population_total,
            opponent: sender_state.opponent,
        };

        let updated_receiver: PlayerState = PlayerState {
            owner: receiver_state.owner,
            iron_total: receiver_state.iron_total + trade.iron_amount,
            gold_total: receiver_state.gold_total + trade.gold_amount,
            water_total: receiver_state.water_total + trade.water_amount,
            population_total: receiver_state.population_total,
            opponent: receiver_state.opponent,
        };

        return (updated_sender, updated_receiver);
    }
}

