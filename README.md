# Pie Slicer | Eth Istanbul 2023

## Links:
 * [Pitch Deck](https://drive.google.com/file/d/1YdFab9mxvfu6uwtDeOnS6Zuk_OoeaI2d/view?usp=drive_link)
 * [Live Demo](https://pieslicer.xyz)
 * [Frontend Repo](https://github.com/PieSlicer/frontend)
 * [Submission Link](https://ethglobal.com/showcase/pieslicer-cb3xx)

A profit-sharing network, automated and founded on a square root function, facilitating a fair distribution of profits among its members

# Problem
We gotta fund them public goods! 
Getting funds for a non-commercial project is difficult. 

# Solution
Transform art into a dynamic loop of creation and distribution. NFT purchases fund artists, community treasuries, and future projects, creating a continuous cycle of value. With decentralized governance and strategic investment, it's not just an NFT marketplace; it's a thriving ecosystem where every participant plays a role in shaping the artistic landscape. 

# Features
* This marketplace is designed to easily join our network by buying NFTs even without a wallet (social login).
* The treasury and reward distributions are updated in real-time on the treasury page and each holder can follow their own share of the pie.

# Upcoming features
* We want to make the markeplace even more accessible by allowing users to top up their wallet with a credit card using Safe OnRamp kit
* We will add a personal dashboard for the users to follow their NFTs and their treasury shares
* We will add a DAO voting page to allow the community to vote on the new projects to fund and apply for funding

# Tech Stack
1. Solidity Smart Contracts deployed on Gnosis Chain
2. PowerPool for automation of the distribution of the treasury
3. Multibass for Admin, Deployments and Event Querying
4. It uses Tailwind CSS for global styling and levrage @ensdomains/thorin UI components.
5. For wallet connection, we use Web3Auth, and wagmi and alchemy-sdk to interact with the blockchain.
6. We use ENS name when available to display the user's address and our own smart contracts.
7. We use Nouns API to retrieve amazing profile pictures for our users.
8. The project is deployed on Vercel and is designed to interact with Gnosis blockchain (currently on Sepolia testnet).

# Tech Architecture

## Deployments


| Name        | Address |
| ----------- | ----------- |
| PieSlicer   | [0xa5E29c97974Ec63a95c961f4fF4801082BFf45aA](https://sepolia.etherscan.io/address/0xa5E29c97974Ec63a95c961f4fF4801082BFf45aA)        |
| Uly PSNFT   | [0x5E46758F854cA69Ce59f5D18c0E6BcEd805fc201](https://sepolia.etherscan.io/address/0x5E46758F854cA69Ce59f5D18c0E6BcEd805fc201)        |
| Treasury    | [0x8F12a1B697762E41aE6271669354cF133F6F9911](https://sepolia.etherscan.io/address/0x8F12a1B697762E41aE6271669354cF133F6F9911)        |

* [Multibaas deployment](https://jsr5t5k46baslix37sz3bzot5a.multibaas.com)
* [Powerpool Job](https://app.powerpool.finance/#/sepolia/explorer/jobs/0xbdE2Aed54521000DC033B67FB522034e0F93A7e5/0x47912e70d78f15201580d525418d2c53ce7c5df709020441714c0e1b2db27598/)
* [Live Demo](https://pieslicer.xyz)

## Smart contracts

The Pie Slicer ecosystem is comprised of two main smart contracts: `PieSlicer` and `SqrTreasury`. These contracts work in tandem to facilitate the creation, distribution, and management of NFTs within a decentralized network.



### Purpose:
The `PieSlicer` contract acts as the central hub for the Pie Slicer ecosystem, overseeing the deployment of NFTs and managing the overall network dynamics.
### Key Functions:
1. **Deploy PSNFTs:** The admin deploys new PSNFT contracts through `deployPSNFT`, triggering the creation of unique NFTs that contribute to the network. This is going to be governed by the Pie Slicer DAO instead of admin. All NFT holders will vote on which projects to be funded and join the network. 
2. **Track Holders and Balances:** The contract keeps a record of NFT holders and their respective balances, ensuring transparent and efficient tracking of network participation.
3. **Manage Total Tokens and all PSNFT contracts in the network:** The contract manages the total number of tokens in the network, adjusting the count with each new NFT deployment to maintain accurate statistics.
### Relationship with PSNFT Contracts:
- The `PieSlicer` contract deploys new PSNFT contracts, creating a symbiotic relationship between the central hub and individual NFT contracts.
- PSNFT contracts interact with `PieSlicer` to update holder balances, enabling seamless communication and coordination within the network.

## SqrTreasury Contract
### Purpose:
The `SqrTreasury` contract specializes in the fair distribution of funds to NFT holders using a square root algorithm. It ensures an equitable reward system that discourages concentration of wealth among a few holders.

### Key Functions:
1. **Square Root Distribution:** Utilizing the square root algorithm, the contract calculates shares for each NFT holder based on their holdings, promoting a balanced and inclusive distribution.
2. **Scheduled Distributions:** The contract schedules periodic distributions, promoting predictability and allowing holders to anticipate reward cycles.
3. **Transparent Reward Retrieval:** Holders can retrieve their rewards through the `getRewardPerHolder` function, fostering transparency and encouraging active participation.
### Relationship with PieSlicer Contract:
- The `SqrTreasury` contract is deployed by `PieSlicer` to handle fund distribution, demonstrating a modular design that separates concerns and promotes maintainability.
- `SqrTreasury` relies on the `PieSlicer` contract to access holder information and perform calculations for accurate fund distribution.

## Communication Flow
1. **PSNFT Deployment:**
   - The `PieSlicer` admin deploys a new PSNFT contract, updating the list of NFT contracts.
   - PSNFT contracts interact with `PieSlicer` to adjust holder balances upon transfers.
2. **SqrTreasury Fund Distribution:**
   - The `SqrTreasury` contract is scheduled for periodic distribution by `PieSlicer`.
   - `SqrTreasury` uses data from `PieSlicer` to calculate square root shares for each holder.
   - Funds are distributed to holders based on their calculated shares.
   - The distribution is automated using PowerPool for decentralized task execution. This way we there will be no operations for the PieSlicer team as well as ensuring true decentralization and clarity for all the participatns. 

## Design Thinking
- **Modularity:** The design separates concerns between contracts, allowing for independent upgrades and maintenance.
- **Fair Distribution:** The square root algorithm in `SqrTreasury` ensures a fair and decentralized reward system, discouraging concentration of rewards among a few holders.
- **Transparent Tracking:** `PieSlicer` provides transparent tracking of NFT holders and balances, fostering a sense of community and participation.


In summary, the Pie Slicer ecosystem leverages a thoughtful design that promotes decentralization, transparency, and fairness, fostering a sustainable and engaging NFT network.

