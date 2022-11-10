import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("hardhat-gas-reporter");
require ("dotenv").config();
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    }
  },
  networks: {
    hardhat: {},
    godwoken_testnet: {
      url: "https://godwoken-testnet-v1.ckbapp.dev",
      chainId: 71401,
      accounts: [PRIVATE_KEY],
      gas: 10000000
    },
    mumbai: {
      url: "https://matic-mumbai.chainstacklabs.com",
      chainId: 80001,
      accounts: [PRIVATE_KEY],
      gas: 10000000
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/53000910bf484824842024352cee1eac",
      chainId: 4,
      accounts: [PRIVATE_KEY],
      gas: 10000000
    }
  },
  // gasReporter: {
  //   outputFile: "gas-report.txt",
  //   enabled: process.env.REPORT_GAS !== undefined,
  //   currency: "USD",
  //   noColors: true,
  //   coinmarketcap: process.env.COIN_MARKETCAP_API_KEY || "",
  //   token: "ETH"
  // }
};

export default config;
