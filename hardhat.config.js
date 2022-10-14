require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");

const { ALCHEMY_API_KEY, PRIVATE_KEY, ETHERSCAN_KEY } = require('./credentials');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  allowUnlimitedContractSize: true,
  networks: {
    arbitrum: {
      url: `https://arb-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: [ETHERSCAN_KEY]
  }
};
