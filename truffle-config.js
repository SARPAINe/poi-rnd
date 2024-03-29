const HDWalletProvider = require("@truffle/hdwallet-provider");
const fs = require("fs");
const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
    networks: {
        ganache: {
            provider: () =>
                new HDWalletProvider({
                    mnemonic: mnemonic,
                    providerOrUrl: `HTTP://127.0.0.1:7545`,
                    numberOfAddresses: 10,
                    addressIndex: 0,
                }),
            network_id: "7589",
            gas: 0xfffffffffff, //gas limit
            gasPrice: 1,
            timeoutBlocks: 200,
        },

        free: {
            provider: () =>
                new HDWalletProvider({
                    mnemonic: mnemonic,
                    providerOrUrl: `HTTP://127.0.0.1:8545`,
                    numberOfAddresses: 10,
                    addressIndex: 0,
                }),
            network_id: "123",
            gas: 0x1ffffffffffffe, //gas limit
            gasPrice: 0,
            timeoutBlocks: 200,
        },

        goerli: {
            provider: () =>
                new HDWalletProvider({
                    mnemonic: mnemonic,
                    providerOrUrl: `https://goerli.infura.io/v3/0916d37d35c648168bae4f724c2f9d13`,
                    addressIndex: 4,
                }),
            network_id: 5, // Ropsten's id
            // confirmations: 0, // # of confirmations to wait between deployments. (default: 0)
            timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
            // gas: 3000000,
            // gasPrice: 2000000000,
            skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
        },
    },

    // Set default mocha options here, use special reporters, etc.
    mocha: {
        // timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: "0.8.17", // Fetch exact version from solc-bin (default: truffle's version)
            // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
            // settings: {          // See the solidity docs for advice about optimization and evmVersion
            optimizer: {
                enabled: true,
                runs: 1,
            },
            //  evmVersion: "byzantium"
            // }
        },
    },

    // Truffle DB is currently disabled by default; to enable it, change enabled:
    // false to enabled: true. The default storage location can also be
    // overridden by specifying the adapter settings, as shown in the commented code below.
    //
    // NOTE: It is not possible to migrate your contracts to truffle DB and you should
    // make a backup of your artifacts to a safe location before enabling this feature.
    //
    // After you backed up your artifacts you can utilize db by running migrate as follows:
    // $ truffle migrate --reset --compile-all
    //
    // db: {
    //   enabled: false,
    //   host: "127.0.0.1",
    //   adapter: {
    //     name: "sqlite",
    //     settings: {
    //       directory: ".db"
    //     }
    //   }
    // }
};
