# zkPlanet
A resource management and civilization game using zero knowledge proofs.

## Overview
Players start off with a plot of land on an uninhabited planet in space. Each plot has a unique set of resources that the player can use to grow their population and expand across the universe. Players can trade with others for the resources they need most to advance.

### Technical Implementation
This game relies on Aleo's zero knowledge proof technology to verify that players are using legitimate resources as they play- these proofs are especially important for the trading system. The contracts are written in Leo.

The game has both a command line interface and a web application built with React and TypeScript. 
The `zkplanetv0.aleo` program is deployed on the Aleo testnet at: `aleo1qad5h5s6pdsw3vrmdhevkn5az03rv36gdeawvelqm0nhtk3tkqgstt2aru`

## Web Application
The zkPlanet web application is built using:
- React 18 with TypeScript
- Provable SDK for Aleo blockchain interactions
- Tailwind

The application interfaces with the `zkplanetv0.aleo` program on the Aleo testnet, allowing players to:
1. Claim their unique planet
2. Gather resources using resource extractors
3. Build habitats
5. Trade resources with other players

### Web  Architecture
- **Components/**: Reusable UI components
  - `GameBoard.tsx`: Displays the 3x3 grid representing the planet
  - `PlotView.tsx`: Individual plot display with resources and buildings
  - `ResourcePanel.tsx`: Shows player's current resources
  - `TradeInterface.tsx`: UI for creating and accepting trades
  
- **Hooks/**: Custom React hooks
  - `useAleoWASM.ts`: Hook for initializing and interacting with Aleo WASM
  - `usePlayerState.ts`: Manages the player's game state
  - `useZkPlanetContract.ts`: Interface for the zkPlanet smart contract
  
- **Workers/**: Web workers for compute-intensive operations
  - `AleoWorker.ts`: Handles Aleo program execution in a separate thread
  - `worker.js`: Worker implmentation

### Connecting to Aleo Testnet
The web application connects to the Aleo testnet using the Provable SDK, which provides a seamless interface for executing zero-knowledge proofs and interacting with Leo programs on the blockchain. Players can connect their Aleo wallets or create new accounts directly from the application.

## Smart Contract Implementation
The zkPlanet game is implemented as a Leo program (`zkplanetv0.aleo`), which includes:
1. Data structures for the game state:
   - `Plot`: Contains resource quantities and building status
   - `Board`: Represents the 3x3 grid of plots
   - `PlayerState`: Tracks player resources and data
2. Core game functions:
   - `new()`: Initializes a new game board with random resources
   - `place_extractor()`: Places resource extractors on plots
   - `place_habitat()`: Builds habitats to increase population
   - `propose_trade()`: Creates a trade offer with another player
   - `accept_trade()`: Accepts and executes a pending trade

The game uses Aleo's privacy features to keep player resources and trades confidential while still allowing verifiable gameplay.
## To-Do List
- [x] Create main planet structs
- [x] Create structs for buildings responsible for resource collection
- [x] Create framework for spending resources
- [x] Separate game loop from communication and trade logic
- [x] Implement trading between two players with in-game currency
- [x] Deploy initial version to Aleo testnet as `zkplanetv0.aleo`
- [x] Create React web application interface
- [ ] Implement more advanced buildings and upgrades
- [ ] Add multiplayer chat and social features
- [ ] Create a global leaderboard system
- [ ] Optimize for performance with larger planet sizes

## Development Setup
### Prerequisites
- Node.js v16+
- Aleo SDK
- Leo

### Installation
1. Clone the repository:
```git clone https://github.com/yourusername/zkplanet.git`
cd zkplanet```
2. Install dependencies:
```npm install```
3. Create a `.env` file with your Aleo credentials:
```
PRIVATE_KEY=your_aleo_private_key
NETWORK=testnet
ENDPOINT=https://api.explorer.provable.com/v1
```
4. Start the development server:
```npm run dev```

Enjoy!
