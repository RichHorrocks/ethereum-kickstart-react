const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

// Get the path to the build folder, then remove it.
const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

// Read the contracts in and compile them.
const campaignPath = path.resolve(__dirname, 'contracts', 'Campaign.sol');
const source = fs.readFileSync(campaignPath, 'utf8');
const output = solc.compile(source, 1).contracts;

// Create the build folder.
fs.ensureDirSync(buildPath);

for (let contract in output) {
  fs.outputJsonSync(
    path.resolve(buildPath, contract.replace(':', '') + '.json'),
    output[contract]
  );
}
