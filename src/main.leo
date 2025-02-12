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
    }

    // Trade record for resource exchange
    record Trade {
        owner: address,
        sender: address,
        receiver: address,
        // Resources requested by sender
        requested_iron: u32,
        requested_gold: u32,
        requested_water: u32,
        // Resources offered by sender
        offered_iron: u32,
        offered_gold: u32,
        offered_water: u32,
        is_completed: bool,
    }


    mapping generated_plots: u8 => Plot;

    function get_resource_value(source: u128, position: u8) -> u32 {
        // Use u32 for shift amount since u128 isn't supported for shifts
        let shift_amount: u32 = (position as u32) * 4u32;
        // Shift right by position * 4 bits, then mask with 0xF (15)
        let shifted: u128 = source >> shift_amount;
        let masked: u128 = shifted & 15u128;
        // Convert to u32 and add base value
        return (masked as u32) + 50u32;
    }

    // Modified new transition
    transition new() -> (Board, PlayerState) {
        // Create one large random seed, can be replaced with hashed wallet address/nonce
        let seed: u128 = WALLET_ADDRESS;

        // Create board using segments of the seed
        let board: Board = Board {
            r1: Row { 
                c1: Plot {
                    iron: get_resource_value(seed, 0u8),
                    gold: get_resource_value(seed, 1u8),
                    water: get_resource_value(seed, 2u8),
                    population: 0u32,
                    has_extractor: false,
                    has_habitat: false
                },
                c2: Plot {
                    iron: get_resource_value(seed, 3u8),
                    gold: get_resource_value(seed, 4u8),
                    water: get_resource_value(seed, 5u8),
                    population: 0u32,
                    has_extractor: false,
                    has_habitat: false
                },
                c3: Plot {
                    iron: get_resource_value(seed, 6u8),
                    gold: get_resource_value(seed, 7u8),
                    water: get_resource_value(seed, 8u8),
                    population: 0u32,
                    has_extractor: false,
                    has_habitat: false
                }
            },
            r2: Row { 
                c1: Plot {
                    iron: get_resource_value(seed, 9u8),
                    gold: get_resource_value(seed, 10u8),
                    water: get_resource_value(seed, 11u8),
                    population: 0u32,
                    has_extractor: false,
                    has_habitat: false
                },
                c2: Plot {
                    iron: get_resource_value(seed, 12u8),
                    gold: get_resource_value(seed, 13u8),
                    water: get_resource_value(seed, 14u8),
                    population: 0u32,
                    has_extractor: false,
                    has_habitat: false
                },
                c3: Plot {
                    iron: get_resource_value(seed, 15u8),
                    gold: get_resource_value(seed, 16u8),
                    water: get_resource_value(seed, 17u8),
                    population: 0u32,
                    has_extractor: false,
                    has_habitat: false
                }
            },
            r3: Row { 
                c1: Plot {
                    iron: get_resource_value(seed, 18u8),
                    gold: get_resource_value(seed, 19u8),
                    water: get_resource_value(seed, 20u8),
                    population: 0u32,
                    has_extractor: false,
                    has_habitat: false
                },
                c2: Plot {
                    iron: get_resource_value(seed, 21u8),
                    gold: get_resource_value(seed, 22u8),
                    water: get_resource_value(seed, 23u8),
                    population: 0u32,
                    has_extractor: false,
                    has_habitat: false
                },
                c3: Plot {
                    iron: get_resource_value(seed, 24u8),
                    gold: get_resource_value(seed, 25u8),
                    water: get_resource_value(seed, 26u8),
                    population: 0u32,
                    has_extractor: false,
                    has_habitat: false
                }
            }
        };

        // Initialize player state
        let player: PlayerState = PlayerState {
            owner: self.caller,
            iron_total: 0u32,
            gold_total: 50u32,
            water_total: 0u32,
            population_total: 0u32,
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
        // Resources being requested
        requested_iron: u32,
        requested_gold: u32,
        requested_water: u32,
        // Resources being offered
        offered_iron: u32,
        offered_gold: u32,
        offered_water: u32,
        player: PlayerState
    ) -> Trade {
        // Verify sender has enough resources to offer
        assert(player.iron_total >= offered_iron);
        assert(player.gold_total >= offered_gold);
        assert(player.water_total >= offered_water);

        // Create trade proposal
        return Trade {
            owner: receiver,
            sender: self.caller,
            receiver: receiver,
            requested_iron: requested_iron,
            requested_gold: requested_gold,
            requested_water: requested_water,
            offered_iron: offered_iron,
            offered_gold: offered_gold,
            offered_water: offered_water,
            is_completed: false,
        };
    }

    // Modified accept_trade transition
    transition accept_trade(
        trade: Trade,
        sender_state: PlayerState,
        receiver_state: PlayerState
    ) -> (PlayerState, PlayerState) {
        // Verify trade hasn't been completed
        assert(!trade.is_completed);
        
        // Verify receiver is the one accepting
        assert(trade.owner == self.caller);
        
        // Verify receiver has enough resources to fulfill trade
        assert(receiver_state.iron_total >= trade.requested_iron);
        assert(receiver_state.gold_total >= trade.requested_gold);
        assert(receiver_state.water_total >= trade.requested_water);

        // Update sender's state
        let updated_sender: PlayerState = PlayerState {
            owner: sender_state.owner,
            iron_total: sender_state.iron_total - trade.offered_iron + trade.requested_iron,
            gold_total: sender_state.gold_total - trade.offered_gold + trade.requested_gold,
            water_total: sender_state.water_total - trade.offered_water + trade.requested_water,
            population_total: sender_state.population_total,
        };

        // Update receiver's state
        let updated_receiver: PlayerState = PlayerState {
            owner: receiver_state.owner,
            iron_total: receiver_state.iron_total + trade.offered_iron - trade.requested_iron,
            gold_total: receiver_state.gold_total + trade.offered_gold - trade.requested_gold,
            water_total: receiver_state.water_total + trade.offered_water - trade.requested_water,
            population_total: receiver_state.population_total,
        };

        return (updated_sender, updated_receiver);
    }
}
