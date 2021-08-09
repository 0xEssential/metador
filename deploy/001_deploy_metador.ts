import * as fs from 'fs';
import * as path from 'path';
import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {chainlinkEnv} from '../utils/network';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts, getChainId} = hre;
  const {deploy} = deployments;
  const networkName = await getChainId().then(
    (id) =>
      ({
        1: 'mainnet',
        4: 'rinkeby',
      }[id])
  );

  if (!networkName) return;

  const {deployer} = await getNamedAccounts();
  const {vrfCoordinator, linkToken, keyhash} = chainlinkEnv(networkName);

  const ipfsHash = fs
    .readFileSync(path.join(__dirname, '../assets/ipfs.txt'))
    .toString();

  await deploy('METADOR', {
    from: deployer,
    args: [vrfCoordinator, linkToken, keyhash, 'Metador', 'MDOR', ipfsHash],
    log: true,
  });
};
export default func;
func.tags = ['NFTStateTransfer'];
