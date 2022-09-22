import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
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
      accounts: [PRIVATE_KEY]
    },
    mumbai: {
      url: "https://matic-mumbai.chainstacklabs.com",
      chainId: 80001,
      accounts: [PRIVATE_KEY]
    }
  }
};

export default config;
