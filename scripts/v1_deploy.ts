//@ts-ignore
import { ethers } from "hardhat";
import {
  NFTBase,
  NFT,
  RMRKEquipRenderUtils,
} from "../typechain-types";
import { ContractTransaction } from "ethers";

const kanariaFallbackURI= "https://ipfs.io/ipfs/QmbBTpn7nZeAm4gZfK6DK5JGxZe9yBjqfGHvMYAFt9AXqa/1";
const gemFallbackURI= "https://ipfs.io/ipfs/QmbBTpn7nZeAm4gZfK6DK5JGxZe9yBjqfGHvMYAFt9AXqa/2";

const pricePerMint = ethers.utils.parseEther("0.000001");
const totalBirds = 1;
const deployedKanariaAddress = "";
const deployedGemAddress = "";
const deployedBaseAddress = "";
const deployedViewsAddress = "";

async function main() {
  const [kanaria, gem, base] = await deployContracts();
  // const [kanaria, gem, base, views] = await retrieveContracts();

  // Notice that most of these steps will happen at different points in time
  // Here we do all in one go to demonstrate how to use it.
  await setupBase(base, gem.address);
  await mintTokens(kanaria);
  await addKanariaResources(kanaria, base.address);
  // await addGemResources(gem, kanaria.address, base.address);
  // await equipGems(kanaria);
  // await composeEquippables(views, kanaria.address);
}

async function retrieveContracts(): Promise<
  [NFT, NFT, NFTBase, RMRKEquipRenderUtils]
> {
  const contractFactory = await ethers.getContractFactory("NFT");
  const baseFactory = await ethers.getContractFactory("NFTBase");
  const viewsFactory = await ethers.getContractFactory("RMRKEquipRenderUtils");

  const kanaria: NFT = contractFactory.attach(
    deployedKanariaAddress
  );
  const gem: NFT = contractFactory.attach(deployedGemAddress);
  const base: NFTBase = baseFactory.attach(deployedBaseAddress);
  const views: RMRKEquipRenderUtils = await viewsFactory.attach(
    deployedViewsAddress
  );

  return [kanaria, gem, base, views];
}


async function deployContracts(): Promise<
  [NFT, NFT, NFTBase]
> {
  const contractFactory = await ethers.getContractFactory("NFT");
  const baseFactory = await ethers.getContractFactory("NFTBase");
  const viewsFactory = await ethers.getContractFactory("RMRKEquipRenderUtils");
  const whitelistUtilsFactory = await ethers.getContractFactory("WhitelistUtils");

  const kanariaWhitelistUtils = await whitelistUtilsFactory.deploy(ethers.constants.AddressZero);
  const gemWhitelistUtils = await whitelistUtilsFactory.deploy(ethers.constants.AddressZero);

  await kanariaWhitelistUtils.deployed();
  console.log(`Deployed NFT Whitelist Utils to ${kanariaWhitelistUtils.address}`);

  await gemWhitelistUtils.deployed();
  console.log(`Deployed Gems Whitelist Utils to ${gemWhitelistUtils.address}`);
  
  const kanaria: NFT = await contractFactory.deploy(
    "EQ TEST",
    "EQ",
    1000,
    pricePerMint,
    kanariaFallbackURI
  );
  const gem: NFT = await contractFactory.deploy(
    "Gem",
    "GM",
    3000,
    pricePerMint,
    gemFallbackURI
  );
  const base: NFTBase = await baseFactory.deploy("KB", "svg");
  const views: RMRKEquipRenderUtils = await viewsFactory.deploy();

  await kanaria.deployed();
  await gem.deployed();
  await base.deployed();

  console.log(
    `Sample contracts deployed to ${kanaria.address}, ${gem.address} and ${base.address}`
    // `Sample contracts deployed to ${kanaria.address} |  ${base.address}`
  );

  await kanaria.setWhitelistUtils(kanariaWhitelistUtils.address);
  await gem.setWhitelistUtils(gemWhitelistUtils.address);
  console.log(`(NFT Contract) Whilist Utils address set.`);

  await kanariaWhitelistUtils.setNFTContract(kanaria.address);
  await gemWhitelistUtils.setNFTContract(gem.address);
  console.log(`(Whilist Utils) NFT Contract address set.`);
  
  return [kanaria, gem, base];
}

async function setupBase(base: NFTBase, gemAddress: string): Promise<void> {
  // Setup base with 2 fixed part options for background, head, body and wings.
  // Also 3 slot options for gems
  const tx = await base.addPartList([
    {
      // Background option 1
      partId: 1,
      part: {
        itemType: 2, // Fixed
        z: 0,
        equippable: [],
        metadataURI: "ipfs://bafybeibmo577eq6h4y5vsqpadzha7c7zyd2kko3bfqziq4nmsljdiu5buy/background.JPEG",
      },
    },
    {
      // Background option 2
      partId: 2,
      part: {
        itemType: 2, // Fixed
        z: 0,
        equippable: [],
        metadataURI: "ipfs://backgrounds/2.svg",
      },
    },
    {
      // Head option 1
      partId: 3,
      part: {
        itemType: 2, // Fixed
        z: 3,
        equippable: [],
        metadataURI: "ipfs://bafybeibmo577eq6h4y5vsqpadzha7c7zyd2kko3bfqziq4nmsljdiu5buy/Head.JPEG",
      },
    },
    {
      // Head option 2
      partId: 4,
      part: {
        itemType: 2, // Fixed
        z: 3,
        equippable: [],
        metadataURI: "ipfs://heads/2.svg",
      },
    },
    {
      // Body option 1
      partId: 5,
      part: {
        itemType: 2, // Fixed
        z: 2,
        equippable: [],
        metadataURI: "ipfs://bafybeibmo577eq6h4y5vsqpadzha7c7zyd2kko3bfqziq4nmsljdiu5buy/Eyes.JPEG",
      },
    },
    {
      // Body option 2
      partId: 6,
      part: {
        itemType: 2, // Fixed
        z: 2,
        equippable: [],
        metadataURI: "ipfs://body/2.svg",
      },
    },
    {
      // Wings option 1
      partId: 7,
      part: {
        itemType: 2, // Fixed
        z: 1,
        equippable: [],
        metadataURI: "ipfs://bafybeibmo577eq6h4y5vsqpadzha7c7zyd2kko3bfqziq4nmsljdiu5buy/Face.JPEG",
      },
    },
    {
      // Wings option 2
      partId: 8,
      part: {
        itemType: 2, // Fixed
        z: 1,
        equippable: [],
        metadataURI: "ipfs://wings/2.svg",
      },
    },
    {
      // Gems slot 1
      partId: 9,
      part: {
        itemType: 1, // Slot
        z: 4,
        equippable: [gemAddress], // Only gems tokens can be equipped here
        metadataURI: "",
      },
    },
    {
      // Gems slot 2
      partId: 10,
      part: {
        itemType: 1, // Slot
        z: 4,
        equippable: [gemAddress], // Only gems tokens can be equipped here
        metadataURI: "",
      },
    },
    {
      // Gems slot 3
      partId: 11,
      part: {
        itemType: 1, // Slot
        z: 4,
        equippable: [gemAddress], // Only gems tokens can be equipped here
        metadataURI: "",
      },
    },
  ]);
  await tx.wait();
  console.log("Base is set");
}

async function mintTokens(
  kanaria: NFT
): Promise<void> {
  const [owner] = await ethers.getSigners();

  // Mint some kanarias
  let tx = await kanaria.mint(totalBirds, {
    value: pricePerMint.mul(totalBirds),
  });
  await tx.wait();
  console.log(`Minted ${totalBirds} kanarias`);

  let _tx = await kanaria.tokenURI(1);
  console.log(_tx);

  // Mint 3 gems into each kanaria
  // let allTx: ContractTransaction[] = [];
  // for (let i = 1; i <= totalBirds; i++) {
  //   let tx = await gem.mintNesting(kanaria.address, 3, i, {
  //     value: pricePerMint.mul(3),
  //   });
  //   allTx.push(tx);
  // }
  // await Promise.all(allTx.map((tx) => tx.wait()));
  // console.log(`Minted 3 gems into each kanaria`);

  // // Accept 3 gems for each kanaria
  // for (let i = 0; i < 3; i++) {
  //   allTx = [];
  //   for (let tokenId = 1; tokenId <= totalBirds; tokenId++) {
  //     let tx = await kanaria.acceptChild(tokenId, 0);
  //     allTx.push(tx);
  //   }
  //   await Promise.all(allTx.map((tx) => tx.wait()));
  //   console.log(`Accepted 1 gem for each kanaria`);
  // }
}

async function addKanariaResources(
  kanaria: NFT,
  baseAddress: string
): Promise<void> {
  const resourceComposedId = 1;
  let allTx: ContractTransaction[] = [];

  let tx = await kanaria.addResourceEntry(
    {
      id: resourceComposedId,
      equippableRefId: 0, // Only used for resources meant to equip into others
      baseAddress: baseAddress, // Since we're using parts, we must define the base
    //   metadataURI: "ipfs://bafkreigg5xbvr4hrpldkki6w62f2ssme5thly3yvyp7ie3uxkrpihz2wsm",
      metadataURI: "meta1.json", //metadata of the image of fixed parts
    },
    [1, 3, 5, 7], // We're using first background, head, body and wings
    [9, 10, 11] // We state that this can receive the 3 slot parts for gems
  );
  allTx.push(tx);
  // Wait for both resources to be added
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log("Added 1 resource entries");

  // Add resources to token
  const tokenId = 1;
  allTx = [
    await kanaria.addResourceToToken(tokenId, resourceComposedId, 0),
  ];
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log("Added resources to token 1");

  // Accept both resources:
  tx = await kanaria.acceptResource(tokenId, 0);
  await tx.wait();
  console.log("Resources accepted");
}

async function addGemResources(
  gem: NFT,
  kanariaAddress: string,
  baseAddress: string
): Promise<void> {
  // We'll add 4 resources for each gem, a full version and 3 versions matching each slot.
  // We will have only 2 types of gems -> 4x2: 8 resources.
  // This is not composed by others, so fixed and slot parts are never used.
  const gemVersions = 4;

  // These refIds are used from the child's perspective, to group resources that can be equipped into a parent
  // With it, we avoid the need to do set it resource by resource
  const equippableRefIdLeftGem = 1;
  const equippableRefIdMidGem = 2;
  const equippableRefIdRightGem = 3;

  // We can do a for loop, but this makes it clearer.
  let allTx = [
    await gem.addResourceEntry(
      // Full version for first type of gem, no need of refId or base
      {
        id: 1,
        equippableRefId: 0,
        baseAddress: ethers.constants.AddressZero,
        metadataURI: `ipfs://gems/typeA/full.svg`,
      },
      [],
      []
    ),
    await gem.addResourceEntry(
      // Equipped into left slot for first type of gem
      {
        id: 2,
        equippableRefId: equippableRefIdLeftGem,
        baseAddress: baseAddress,
        metadataURI: `ipfs://gems/typeA/left.svg`,
      },
      [],
      []
    ),
    await gem.addResourceEntry(
      // Equipped into mid slot for first type of gem
      {
        id: 3,
        equippableRefId: equippableRefIdMidGem,
        baseAddress: baseAddress,
        metadataURI: `ipfs://gems/typeA/mid.svg`,
      },
      [],
      []
    ),
    await gem.addResourceEntry(
      // Equipped into left slot for first type of gem
      {
        id: 4,
        equippableRefId: equippableRefIdRightGem,
        baseAddress: baseAddress,
        metadataURI: `ipfs://gems/typeA/right.svg`,
      },
      [],
      []
    ),
    await gem.addResourceEntry(
      // Full version for second type of gem, no need of refId or base
      {
        id: 5,
        equippableRefId: 0,
        baseAddress: ethers.constants.AddressZero,
        metadataURI: `ipfs://gems/typeB/full.svg`,
      },
      [],
      []
    ),
    await gem.addResourceEntry(
      // Equipped into left slot for second type of gem
      {
        id: 6,
        equippableRefId: equippableRefIdLeftGem,
        baseAddress: baseAddress,
        metadataURI: `ipfs://gems/typeB/left.svg`,
      },
      [],
      []
    ),
    await gem.addResourceEntry(
      // Equipped into mid slot for second type of gem
      {
        id: 7,
        equippableRefId: equippableRefIdMidGem,
        baseAddress: baseAddress,
        metadataURI: `ipfs://gems/typeB/mid.svg`,
      },
      [],
      []
    ),
    await gem.addResourceEntry(
      // Equipped into right slot for second type of gem
      {
        id: 8,
        equippableRefId: equippableRefIdRightGem,
        baseAddress: baseAddress,
        metadataURI: `ipfs://gems/typeB/right.svg`,
      },
      [],
      []
    ),
  ];

  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log(
    "Added 8 gem resources. 2 Types of gems with full, left, mid and right versions."
  );

  // 9, 10 and 11 are the slot part ids for the gems, defined on the base.
  // e.g. Any resource on gem, which sets its equippableRefId to equippableRefIdLeftGem
  //      will be considered a valid equip into any kanaria on slot 9 (left gem).
  allTx = [
    await gem.setValidParentRefId(equippableRefIdLeftGem, kanariaAddress, 9),
    await gem.setValidParentRefId(equippableRefIdMidGem, kanariaAddress, 10),
    await gem.setValidParentRefId(equippableRefIdRightGem, kanariaAddress, 11),
  ];
  await Promise.all(allTx.map((tx) => tx.wait()));

  // We add resources of type A to gem 1 and 2, and type B to gem 3. Both are nested into the first kanaria
  // This means gems 1 and 2 will have the same resource, which is totally valid.
  allTx = [
    await gem.addResourceToToken(1, 1, 0),
    await gem.addResourceToToken(1, 2, 0),
    await gem.addResourceToToken(1, 3, 0),
    await gem.addResourceToToken(1, 4, 0),
    await gem.addResourceToToken(2, 1, 0),
    await gem.addResourceToToken(2, 2, 0),
    await gem.addResourceToToken(2, 3, 0),
    await gem.addResourceToToken(2, 4, 0),
    await gem.addResourceToToken(3, 5, 0),
    await gem.addResourceToToken(3, 6, 0),
    await gem.addResourceToToken(3, 7, 0),
    await gem.addResourceToToken(3, 8, 0),
  ];
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log("Added 4 resources to each of 3 gems.");

  // We accept each resource for both gems
  for (let i = 0; i < gemVersions; i++) {
    allTx = [
      await gem.acceptResource(1, 0),
      await gem.acceptResource(2, 0),
      await gem.acceptResource(3, 0),
    ];
    await Promise.all(allTx.map((tx) => tx.wait()));
  }
  console.log("Accepted 4 resources to each of 3 gems.");
}

async function equipGems(kanaria: NFT): Promise<void> {
  const allTx = [
    await kanaria.equip({
      tokenId: 1, // Kanaria 1
      childIndex: 0, // Gem 1 is on position 0
      resourceId: 1, // Resource for the kanaria which is composable
      slotPartId: 9, // left gem slot
      childResourceId: 2, // Resource id for child meant for the left gem
    }),
    await kanaria.equip({
      tokenId: 1, // Kanaria 1
      childIndex: 2, // Gem 2 is on position 2 (positions are shifted when accepting children)
      resourceId: 1, // Resource for the kanaria which is composable
      slotPartId: 10, // mid gem slot
      childResourceId: 3, // Resource id for child meant for the mid gem
    }),
    await kanaria.equip({
      tokenId: 1, // Kanaria 1
      childIndex: 1, // Gem 3 is on position 1
      resourceId: 1, // Resource for the kanaria which is composable
      slotPartId: 11, // right gem slot
      childResourceId: 8, // Resource id for child meant for the right gem
    }),
  ];
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log("Equipped 3 gems into first kanaria");
}

async function composeEquippables(
  views: RMRKEquipRenderUtils,
  kanariaAddress: string
): Promise<void> {
  const tokenId = 1;
  const resourceId = 1;
  console.log(
    "Composed: ",
    await views.composeEquippables(kanariaAddress, tokenId, resourceId)
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
