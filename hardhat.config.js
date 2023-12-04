require("@nomicfoundation/hardhat-toolbox");


require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-ethers");

const _BNB_SCAN = "TEP7NRSEFIXD5BS3YWZGCQNTFDXXYUKTBF";
const PRIVATE_KEY =
  "";

module.exports = {
  solidity: {
	version : "0.5.0",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
},
networks: {
  bnb: {
    url: `https://thrumming-sparkling-flower.bsc-testnet.discover.quiknode.pro/fead7afad205a9aa914c6dc8d0d8b2823040e60e/`,
    accounts: [`0x${PRIVATE_KEY}`]
  },
},
etherscan: {
  apiKey: _BNB_SCAN,
}
};

