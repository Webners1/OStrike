import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

import { getPoolAddress } from '../test/setup'
import { getUniswapDeployments, getUSDC, getWETH, createArgumentFile } from '../tasks/utils'

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, ethers, network, deployments } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  
  
  const feeTier = 10000

  // Load contracts
  const oracle = await ethers.getContractAt("Oracle", "0xDc371dF9029603165f9C6F5267CC4B4e9AD7DE38");
  const shortSqueeth = await ethers.getContractAt("ShortPowerPerp", "0x518a8f5ac599C96bB0c4aa17aCaa7654F04Ff56C");
  const wsqueeth = await ethers.getContractAt("WPowerPerp", "0xB58c687d4645FfC502036c13253373AA1548Fb00");
  const weth9 = await getWETH(ethers, deployer, network.name)
  const usdc = await getUSDC(ethers, deployer, network.name)
  const { uniswapFactory, positionManager } = await getUniswapDeployments(ethers, deployer, network.name)
  const ethUSDCPool = await getPoolAddress(weth9, usdc, uniswapFactory)
  const squeethEthPool = await getPoolAddress(weth9, wsqueeth, uniswapFactory)

  if (network.name === 'goerli' || network.name === 'mainnet') return

  // deploy abdk library
  const abdk = await deploy("ABDKMath64x64", { from: deployer, log: true })

  const tickMathExternal = await deploy("TickMathExternal", { from: deployer, log: true })

  const sqrtPriceMathPartial = await deploy("SqrtPriceMathPartial", { from: deployer, log: true })
console.log("deployed",ethUSDCPool)
  // deploy controller
  const controllerArgs = [oracle.address, shortSqueeth.address, wsqueeth.address, weth9.address, usdc.address, "0x158FFB03DD88A083C211817b19f98636765276F6", "0x8a9FB9c7Ec2095A541188943E71D5D13f6d474FA", positionManager.address, feeTier]
  const Controller = await deploy("Controller", { from: deployer, log: true, libraries: { ABDKMath64x64: abdk.address, SqrtPriceMathPartial: sqrtPriceMathPartial.address, TickMathExternal: tickMathExternal.address }, args: controllerArgs });
  createArgumentFile('Controller', network.name, controllerArgs)
  const controller = await ethers.getContractAt("Controller", Controller.address);

  try {
    const tx = await wsqueeth.init(controller.address, { from: deployer });
    await ethers.provider.waitForTransaction(tx.hash, 1)
    console.log(`Squeeth init done 🍋`);
  } catch (error) {
    console.log(`Squeeth already init or wrong deployer address.`)
  }

  try {
   
    const tx = await shortSqueeth.init(controller.address, { from: deployer });
    await ethers.provider.waitForTransaction(tx.hash, 1)
    console.log(`ShortPowerPerp init done 🥭`);
  } catch (error) {
    console.log(`ShortPowerPerp already init or wrong deployer address.`)
  }

  const alsig = "0x0144571202B48d8B3EEE3A95E4140B7144F8b72F"

  if (network.name === "mainnet") {
    try {
      //@ts-ignore
      const tx = await controller.transferOwnership(alsig, { from: deployer });
      await ethers.provider.waitForTransaction(tx.hash, 1)
      console.log(`Ownership transferred! 🥭`);
    } catch (error) {
      console.log(`Ownership transfer failed`)
    }
  }

}

export default func;