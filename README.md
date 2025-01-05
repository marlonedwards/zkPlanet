# zkPlanet
A resource management and civilization game using zero knowledge proofs.

## Overview
Players start off with a plot of land on an uninhabited planet in space. Each plot has a unique set of resources that the player can use to grow their population and expand across the universe. Players will be able to trade with others for the resources they need most to advance.

### Technical Implementation
This game relies on Aleo's zero knowledge proof technology to verify that players are using legitimate resources as they play- these proofs are especially important for the trading system. The contracts are written in Leo.

The game is currently being developed for the command line with future plans for a dedicated frontend with React.

## To-Do List
- [x] Create main planet structs
- [ ] Create structs for buildings responsible for resource collection
- [ ] Create framework for spending resources
- [ ] Separate game loop from communicaton and trade logic
- [ ] Implement trading between two players with in-game currency
