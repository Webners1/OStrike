# NettingLib
[Git Source](https://github.com/opynfinance/squeeth-monorepo/blob/334783aa87db73939fb00d5b133216b0033dfece/src/NettingLib.sol)


## Functions
### transferWethFromMarketMakers

transfer WETH from market maker to netting contract

*this is executed during the deposit auction, MM buying SBCH for WETH*


```solidity
function transferWethFromMarketMakers(
    address _weth,
    address _trader,
    uint256 _quantity,
    uint256 _SBCHToMint,
    uint256 _clearingPrice
) external returns (bool, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_weth`|`address`|WETH address|
|`_trader`|`address`|market maker address|
|`_quantity`|`uint256`|SBCH quantity|
|`_SBCHToMint`|`uint256`|remaining amount of the total SBCHToMint|
|`_clearingPrice`|`uint256`|auction clearing price|


### transferSBCHToMarketMakers

transfer SBCH to market maker

*this is executed during the deposit auction, MM buying SBCH for WETH*


```solidity
function transferSBCHToMarketMakers(
    address _SBCH,
    address _trader,
    uint256 _bidId,
    uint256 _SBCHBalance,
    uint256 _quantity
) external returns (bool, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_SBCH`|`address`|SBCH address|
|`_trader`|`address`|market maker address|
|`_bidId`|`uint256`|MM's bid ID|
|`_SBCHBalance`|`uint256`|remaining netting contracts's SBCH balance|
|`_quantity`|`uint256`|SBCH quantity in market maker order|


### transferSBCHFromMarketMakers

transfer SBCH from market maker

*this is executed during the withdraw auction, MM selling SBCH for WETH*


```solidity
function transferSBCHFromMarketMakers(
    address _SBCH,
    address _trader,
    uint256 _remainingSBCHToPull,
    uint256 _quantity
) internal returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_SBCH`|`address`|SBCH address|
|`_trader`|`address`|market maker address|
|`_remainingSBCHToPull`|`uint256`|remaining amount of SBCH from the total SBCH amount to transfer from order array|
|`_quantity`|`uint256`|SBCH quantity in market maker order|


### transferWethToMarketMaker

transfer WETH to market maker

*this is executed during the withdraw auction, MM selling SBCH for WETH*


```solidity
function transferWethToMarketMaker(
    address _weth,
    address _trader,
    uint256 _bidId,
    uint256 _remainingSBCHToPull,
    uint256 _quantity,
    uint256 _clearingPrice
) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_weth`|`address`|WETH address|
|`_trader`|`address`|market maker address|
|`_bidId`|`uint256`|market maker bid ID|
|`_remainingSBCHToPull`|`uint256`|total SBCH to get from orders array|
|`_quantity`|`uint256`|market maker's SBCH order quantity|
|`_clearingPrice`|`uint256`|auction clearing price|


### getCrabPrice

get _crab token price


```solidity
function getCrabPrice(
    address _oracle,
    address _crab,
    address _ethUsdcPool,
    address _ethSqueethPool,
    address _SBCH,
    address _usdc,
    address _weth,
    address _zenBull,
    uint32 _auctionTwapPeriod
) external view returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_oracle`|`address`|oracle address|
|`_crab`|`address`|crab token address|
|`_ethUsdcPool`|`address`|BCH/USDC Uni v3 pool address|
|`_ethSqueethPool`|`address`|BCH/SBCH Uni v3 pool address|
|`_SBCH`|`address`|SBCH address|
|`_usdc`|`address`|USDC address|
|`_weth`|`address`|WETH address|
|`_zenBull`|`address`|ZenBull strategy address|
|`_auctionTwapPeriod`|`uint32`|auction TWAP|


### getZenBullPrice

get ZenBull token price


```solidity
function getZenBullPrice(
    address _zenBull,
    address _eulerLens,
    address _usdc,
    address _weth,
    uint256 _crabFairPriceInEth,
    uint256 _ethUsdcPrice
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_zenBull`|`address`|ZenBull token address|
|`_eulerLens`|`address`|EulerSimpleLens contract address|
|`_usdc`|`address`|USDC address|
|`_weth`|`address`|WETH address|
|`_crabFairPriceInEth`|`uint256`|Crab token price|
|`_ethUsdcPrice`|`uint256`|BCH/USDC price|


### calcSBCHToMintAndEthIntoCrab

calculate SBCH to mint and amount of eth to deposit into Crab v2 based on amount of crab token


```solidity
function calcSBCHToMintAndEthIntoCrab(address _crab, address _zenBull, uint256 _crabAmount)
    external
    view
    returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_crab`|`address`|crab strategy address|
|`_zenBull`|`address`|ZenBull strategy address|
|`_crabAmount`|`uint256`|amount of crab token|


### calcWethToLendAndUsdcToBorrow

calculate amount of WETH to lend in and USDC to borrow from Euler


```solidity
function calcWethToLendAndUsdcToBorrow(
    address _eulerLens,
    address _zenBull,
    address _weth,
    address _usdc,
    uint256 _crabAmount
) external view returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_eulerLens`|`address`|EulerSimpleLens contract address|
|`_zenBull`|`address`|ZenBull strategy address|
|`_weth`|`address`|WETH address|
|`_usdc`|`address`|USDC address|
|`_crabAmount`|`uint256`|amount of crab token|


### calcSBCHAmount

calculate amount of SBCH to get based on amount of ZenBull to Withdraw


```solidity
function calcSBCHAmount(address _zenBull, address _crab, uint256 _withdrawsToProcess)
    external
    view
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_zenBull`|`address`|ZenBull strategy address|
|`_crab`|`address`|crab strategy address|
|`_withdrawsToProcess`|`uint256`|amount of ZenBull token to withdraw|


### mul


```solidity
function mul(uint256 _x, uint256 _y) internal pure returns (uint256);
```

### div


```solidity
function div(uint256 _x, uint256 _y) internal pure returns (uint256);
```

## Events
### TransferWethFromMarketMakers

```solidity
event TransferWethFromMarketMakers(
    address indexed trader, uint256 quantity, uint256 wethAmount, uint256 remainingSBCHBalance, uint256 clearingPrice
);
```

### TransferSBCHToMarketMakers

```solidity
event TransferSBCHToMarketMakers(
    address indexed trader, uint256 bidId, uint256 quantity, uint256 remainingSBCHBalance
);
```

### TransferSBCHFromMarketMakers

```solidity
event TransferSBCHFromMarketMakers(address indexed trader, uint256 quantity, uint256 SBCHRemaining);
```

### TransferWethToMarketMaker

```solidity
event TransferWethToMarketMaker(
    address indexed trader,
    uint256 bidId,
    uint256 quantity,
    uint256 wethAmount,
    uint256 SBCHRemaining,
    uint256 clearingPrice
);
```

