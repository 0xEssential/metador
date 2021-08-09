import * as fs from 'fs';
import * as path from 'path';
import 'dotenv/config';

import {NFTStorage, File} from 'nft.storage';

async function main() {
  const storage = new NFTStorage({token: process.env.NFT_STORAGE_KEY});

  const directory = [];

  for (const id of Array.from(Array(5).keys())) {
    const fileData = fs.readFileSync(
      path.join(__dirname, `../assets/${id}.png`)
    );
    const imageFile = new File([fileData], `${id}.png`, {
      type: 'image/png',
    });
    const image = await storage.storeBlob(imageFile);

    const metadata = {
      name: id.toString(),
      description: 'Token description',
      image: `ipfs://${image}`,
    };

    directory.push(new File([JSON.stringify(metadata, null, 2)], `${id}`));
  }

  const pinnedDir = await storage.storeDirectory(directory);

  return fs.writeFileSync(
    path.join(__dirname, `../assets/ipfs.txt`),
    pinnedDir
  );
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
