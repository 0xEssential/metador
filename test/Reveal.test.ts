import chai, {expect} from './chai-setup';
import {ethers, deployments, getUnnamedAccounts} from 'hardhat';
import {deployContracts, setupUser, setupUsers} from './utils';
import {Contract} from 'ethers';

describe('Drop Registration', function () {
  const setup = deployments.createFixture(async () => {
    const contracts = await deployContracts();
    const [_owner] = await ethers.getSigners();

    const users = await setupUsers(await getUnnamedAccounts(), contracts);

    const owner = await setupUser(_owner.address, contracts);

    return {
      ...contracts,
      users,
      owner: {...owner, ..._owner},
    };
  });

  interface ContractUser {
    address: string;
    VRF: Contract;
    Metador: Contract;
  }

  let fixtures: any;

  describe('Metadata', function () {
    beforeEach(async () => {
      fixtures = await setup();

      const account = fixtures.users[0];

      const mint = await account.Metador.publicMint({
        value: ethers.utils.parseUnits('0.02', 'ether'),
      });

      await mint.wait();
    });

    it('Returns the placeholder before reveal', async () => {
      const {Metador} = fixtures;

      const uri = await Metador.tokenURI(0);
      expect(uri).to.eq('ipfs://randomHash/placeholder');
    });

    it('Returns the URI for index offset post-reveal', async () => {
      const {
        Metador,
        users: [account],
        owner,
      } = fixtures;

      const result = await account.Metador.revealMetadata();

      const tx = await result.wait();
      const requestId = tx.events[3].data;

      const offset = Math.floor(Math.random() * 10_000);

      const randomnessTx = await owner.VRF.callBackWithRandomness(
        requestId,
        offset,
        Metador.address
      );

      await randomnessTx.wait();

      const uri = await Metador.tokenURI(0);

      expect(uri).to.eq(`ipfs://randomHash/${offset}`);
    });

    it('Returns the URI for index offset 1 when random offset is 0', async () => {
      const {
        Metador,
        users: [account],
        owner,
      } = fixtures;

      const result = await account.Metador.revealMetadata();

      const tx = await result.wait();
      const requestId = tx.events[3].data;

      const offset = 0;

      const randomnessTx = await owner.VRF.callBackWithRandomness(
        requestId,
        offset,
        Metador.address
      );

      await randomnessTx.wait();

      const uri = await Metador.tokenURI(0);

      expect(uri).to.eq(`ipfs://randomHash/1`);
    });

    it('Returns a wraparound URI when tokenId + offset > MAX_TOKENS', async () => {
      const {
        Metador,
        users: [account],
        owner,
      } = fixtures;

      for (const _id of Array.from(Array(5).keys())) {
        const mint = await account.Metador.publicMint({
          value: ethers.utils.parseUnits('0.02', 'ether'),
        });

        await mint.wait();
      }

      const result = await account.Metador.revealMetadata();

      const tx = await result.wait();
      const requestId = tx.events[3].data;

      const offset = 9999;

      const randomnessTx = await owner.VRF.callBackWithRandomness(
        requestId,
        offset,
        Metador.address
      );

      await randomnessTx.wait();

      const uri = await Metador.tokenURI(5);
      expect(uri).to.eq(`ipfs://randomHash/4`);
    });
  });
});
