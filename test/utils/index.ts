import {Contract} from 'ethers';
import {ethers, getUnnamedAccounts} from 'hardhat';

export async function setupUsers<T extends {[contractName: string]: Contract}>(
  addresses: string[],
  contracts: T
): Promise<({address: string} & T)[]> {
  const users: ({address: string} & T)[] = [];
  for (const address of addresses) {
    users.push(await setupUser(address, contracts));
  }
  return users;
}

export async function setupUser<T extends {[contractName: string]: Contract}>(
  address: string,
  contracts: T
): Promise<{address: string} & T> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const user: any = {address};
  for (const key of Object.keys(contracts)) {
    user[key] = contracts[key].connect(await ethers.getSigner(address));
  }
  return user as {address: string} & T;
}

export async function deployContracts() {
  const [deployer] = await ethers.getSigners();

  const MockLink = await ethers.getContractFactory('MockLink');
  const VRFCoordinatorMock = await ethers.getContractFactory(
    'VRFCoordinatorMock'
  );
  const link = await MockLink.deploy();
  const vrfCoordinatorMock = await VRFCoordinatorMock.deploy(link.address);
  const keyhash =
    '0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4';

  const MetadorContract = await ethers.getContractFactory('Metador');

  const Metador = await MetadorContract.deploy(
    vrfCoordinatorMock.address,
    link.address,
    keyhash,
    'Metador',
    'MDOR',
    'randomHash'
  );

  await link.transfer(Metador.address, '100000000000000000000');

  const contracts = {
    VRF: vrfCoordinatorMock,
    Metador,
  };

  return contracts;
}
