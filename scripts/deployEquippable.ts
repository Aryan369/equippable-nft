import { ethers } from "hardhat";
import {
    NFTBase,
    NFT,
    RMRKEquipRenderUtils,
} from "../typechain-types";
import { ContractTransaction } from "ethers";

const pricePerMint = ethers.utils.parseEther("0.0001");
const maxSupply = 3301;

async function main() {
    const [kanaria, gem, base, views] = await deployContracts();
}

async function deployContracts(): Promise<
    [NFT, NFT, NFTBase, RMRKEquipRenderUtils]
> {
    console.log("Deploying smart contracts");

    const [beneficiary] = await ethers.getSigners();
    const contractFactory = await ethers.getContractFactory("NFT");
    const baseFactory = await ethers.getContractFactory("NFTBase");
    const viewsFactory = await ethers.getContractFactory("RMRKEquipRenderUtils");

    const kanaria: NFT = await contractFactory.deploy(
    "Kanaria",
    "KAN",
    "ipfs://tokenMeta",
    {
        erc20TokenAddress: ethers.constants.AddressZero,
        tokenUriIsEnumerable: true,
        royaltyRecipient: await beneficiary.getAddress(),
        royaltyPercentageBps: 10,
        maxSupply: maxSupply,
        pricePerMint: pricePerMint
    }
    );
    const gem: NFT = await contractFactory.deploy(
    "Gem",
    "GM",
    "ipfs://collectionMeta",
    "ipfs://tokenMeta",
    {
        erc20TokenAddress: ethers.constants.AddressZero,
        tokenUriIsEnumerable: true,
        royaltyRecipient: await beneficiary.getAddress(),
        royaltyPercentageBps: 10,
        maxSupply: 3000,
        pricePerMint: pricePerMint
    }
    );
    const base: NFTBase = await baseFactory.deploy("KB", "svg");
    const views: RMRKEquipRenderUtils = await viewsFactory.deploy();

    await kanaria.deployed();
    await gem.deployed();
    await base.deployed();
    console.log(
    `Sample contracts deployed to ${kanaria.address} (Kanaria), ${gem.address} (Gem) and ${base.address} (Base)`
    );

    return [kanaria, gem, base, views];
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});