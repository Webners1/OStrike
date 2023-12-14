// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// interface
import { IERC20 } from "openzeppelin/interfaces/IERC20.sol";
import { IZenBullStrategy } from "./interface/IZenBullStrategy.sol";
import { IOracle } from "./interface/IOracle.sol";
import { IEulerSimpleLens } from "./interface/IEulerSimpleLens.sol";

library NettingLib {
    event TransferWethFromMarketMakers(
        address indexed trader,
        uint256 quantity,
        uint256 wethAmount,
        uint256 remainingSBCHBalance,
        uint256 clearingPrice
    );
    event TransferSBCHToMarketMakers(
        address indexed trader, uint256 bidId, uint256 quantity, uint256 remainingSBCHBalance
    );
    event TransferSBCHFromMarketMakers(
        address indexed trader, uint256 quantity, uint256 SBCHRemaining
    );
    event TransferWethToMarketMaker(
        address indexed trader,
        uint256 bidId,
        uint256 quantity,
        uint256 wethAmount,
        uint256 SBCHRemaining,
        uint256 clearingPrice
    );

    /**
     * @notice transfer WETH from market maker to netting contract
     * @dev this is executed during the deposit auction, MM buying SBCH for WETH
     * @param _weth WETH address
     * @param _trader market maker address
     * @param _quantity SBCH quantity
     * @param _SBCHToMint remaining amount of the total SBCHToMint
     * @param _clearingPrice auction clearing price
     */
    function transferWethFromMarketMakers(
        address _weth,
        address _trader,
        uint256 _quantity,
        uint256 _SBCHToMint,
        uint256 _clearingPrice
    ) external returns (bool, uint256) {
        uint256 wethAmount;
        uint256 remainingSBCHToMint;
        if (_quantity >= _SBCHToMint) {
            wethAmount = (_SBCHToMint * _clearingPrice) / 1e18;
            IERC20(_weth).transferFrom(_trader, address(this), wethAmount);

            emit TransferWethFromMarketMakers(
                _trader, _SBCHToMint, wethAmount, remainingSBCHToMint, _clearingPrice
            );
            return (true, remainingSBCHToMint);
        } else {
            wethAmount = (_quantity * _clearingPrice) / 1e18;
            remainingSBCHToMint = _SBCHToMint - _quantity;
            IERC20(_weth).transferFrom(_trader, address(this), wethAmount);

            emit TransferWethFromMarketMakers(
                _trader, _quantity, wethAmount, remainingSBCHToMint, _clearingPrice
            );
            return (false, remainingSBCHToMint);
        }
    }

    /**
     * @notice transfer SBCH to market maker
     * @dev this is executed during the deposit auction, MM buying SBCH for WETH
     * @param _SBCH SBCH address
     * @param _trader market maker address
     * @param _bidId MM's bid ID
     * @param _SBCHBalance remaining netting contracts's SBCH balance
     * @param _quantity SBCH quantity in market maker order
     */
    function transferSBCHToMarketMakers(
        address _SBCH,
        address _trader,
        uint256 _bidId,
        uint256 _SBCHBalance,
        uint256 _quantity
    ) external returns (bool, uint256) {
        uint256 remainingSBCHBalance;
        if (_quantity < _SBCHBalance) {
            IERC20(_SBCH).transfer(_trader, _quantity);

            remainingSBCHBalance = _SBCHBalance - _quantity;

            emit TransferSBCHToMarketMakers(_trader, _bidId, _quantity, remainingSBCHBalance);

            return (false, remainingSBCHBalance);
        } else {
            IERC20(_SBCH).transfer(_trader, _SBCHBalance);

            emit TransferSBCHToMarketMakers(_trader, _bidId, _SBCHBalance, remainingSBCHBalance);

            return (true, remainingSBCHBalance);
        }
    }

    /**
     * @notice transfer SBCH from market maker
     * @dev this is executed during the withdraw auction, MM selling SBCH for WETH
     * @param _SBCH SBCH address
     * @param _trader market maker address
     * @param _remainingSBCHToPull remaining amount of SBCH from the total SBCH amount to transfer from order array
     * @param _quantity SBCH quantity in market maker order
     */
    function transferSBCHFromMarketMakers(
        address _SBCH,
        address _trader,
        uint256 _remainingSBCHToPull,
        uint256 _quantity
    ) internal returns (uint256) {
        uint256 SBCHRemaining;
        if (_quantity < _remainingSBCHToPull) {
            IERC20(_SBCH).transferFrom(_trader, address(this), _quantity);

            SBCHRemaining = _remainingSBCHToPull - _quantity;

            emit TransferSBCHFromMarketMakers(_trader, _quantity, SBCHRemaining);
        } else {
            IERC20(_SBCH).transferFrom(_trader, address(this), _remainingSBCHToPull);

            emit TransferSBCHFromMarketMakers(_trader, _remainingSBCHToPull, SBCHRemaining);
        }

        return SBCHRemaining;
    }

    /**
     * @notice transfer WETH to market maker
     * @dev this is executed during the withdraw auction, MM selling SBCH for WETH
     * @param _weth WETH address
     * @param _trader market maker address
     * @param _bidId market maker bid ID
     * @param _remainingSBCHToPull total SBCH to get from orders array
     * @param _quantity market maker's SBCH order quantity
     * @param _clearingPrice auction clearing price
     */
    function transferWethToMarketMaker(
        address _weth,
        address _trader,
        uint256 _bidId,
        uint256 _remainingSBCHToPull,
        uint256 _quantity,
        uint256 _clearingPrice
    ) external returns (uint256) {
        uint256 SBCHQuantity;

        if (_quantity < _remainingSBCHToPull) {
            SBCHQuantity = _quantity;
        } else {
            SBCHQuantity = _remainingSBCHToPull;
        }

        uint256 wethAmount = (SBCHQuantity * _clearingPrice) / 1e18;
        _remainingSBCHToPull -= SBCHQuantity;
        IERC20(_weth).transfer(_trader, wethAmount);

        emit TransferWethToMarketMaker(
            _trader, _bidId, _quantity, wethAmount, _remainingSBCHToPull, _clearingPrice
        );

        return _remainingSBCHToPull;
    }

    /**
     * @notice get _crab token price
     * @param _oracle oracle address
     * @param _crab crab token address
     * @param _ethUsdcPool BCH/USDC Uni v3 pool address
     * @param _ethSqueethPool BCH/SBCH Uni v3 pool address
     * @param _SBCH SBCH address
     * @param _usdc USDC address
     * @param _weth WETH address
     * @param _zenBull ZenBull strategy address
     * @param _auctionTwapPeriod auction TWAP
     */
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
    ) external view returns (uint256, uint256) {
        uint256 squeethEthPrice =
            IOracle(_oracle).getTwap(_ethSqueethPool, _SBCH, _weth, _auctionTwapPeriod, false);
        uint256 _ethUsdcPrice =
            IOracle(_oracle).getTwap(_ethUsdcPool, _weth, _usdc, _auctionTwapPeriod, false);
        (uint256 crabCollateral, uint256 crabDebt) =
            IZenBullStrategy(_zenBull).getCrabVaultDetails();
        uint256 _crabFairPriceInEth = (crabCollateral - (crabDebt * squeethEthPrice / 1e18)) * 1e18
            / IERC20(_crab).totalSupply();

        return (_crabFairPriceInEth, _ethUsdcPrice);
    }

    /**
     * @notice get ZenBull token price
     * @param _zenBull ZenBull token address
     * @param _eulerLens EulerSimpleLens contract address
     * @param _usdc USDC address
     * @param _weth WETH address
     * @param _crabFairPriceInEth Crab token price
     * @param _ethUsdcPrice BCH/USDC price
     */
    function getZenBullPrice(
        address _zenBull,
        address _eulerLens,
        address _usdc,
        address _weth,
        uint256 _crabFairPriceInEth,
        uint256 _ethUsdcPrice
    ) external view returns (uint256) {
        uint256 zenBullCrabBalance = IZenBullStrategy(_zenBull).getCrabBalance();
        return (
            IEulerSimpleLens(_eulerLens).getETokenBalance(_weth, _zenBull)
                + (zenBullCrabBalance * _crabFairPriceInEth / 1e18)
                - (
                    (IEulerSimpleLens(_eulerLens).getDTokenBalance(_usdc, _zenBull) * 1e12 * 1e18)
                        / _ethUsdcPrice
                )
        ) * 1e18 / IERC20(_zenBull).totalSupply();
    }

    /**
     * @notice calculate SBCH to mint and amount of eth to deposit into Crab v2 based on amount of crab token
     * @param _crab crab strategy address
     * @param _zenBull ZenBull strategy address
     * @param _crabAmount amount of crab token
     */
    function calcSBCHToMintAndEthIntoCrab(address _crab, address _zenBull, uint256 _crabAmount)
        external
        view
        returns (uint256, uint256)
    {
        uint256 crabTotalSupply = IERC20(_crab).totalSupply();
        (uint256 crabEth, uint256 crabDebt) = IZenBullStrategy(_zenBull).getCrabVaultDetails();
        uint256 _SBCHToMint = _crabAmount * crabDebt / crabTotalSupply;
        uint256 ethIntoCrab = _crabAmount * crabEth / crabTotalSupply;

        return (_SBCHToMint, ethIntoCrab);
    }

    /**
     * @notice calculate amount of WETH to lend in and USDC to borrow from Euler
     * @param _eulerLens EulerSimpleLens contract address
     * @param _zenBull ZenBull strategy address
     * @param _weth WETH address
     * @param _usdc USDC address
     * @param _crabAmount amount of crab token
     */
    function calcWethToLendAndUsdcToBorrow(
        address _eulerLens,
        address _zenBull,
        address _weth,
        address _usdc,
        uint256 _crabAmount
    ) external view returns (uint256, uint256) {
        uint256 share =
            div(_crabAmount, (IZenBullStrategy(_zenBull).getCrabBalance() + _crabAmount));
        uint256 wethToLend = div(
            mul(IEulerSimpleLens(_eulerLens).getETokenBalance(_weth, _zenBull), share), 1e18 - share
        );
        uint256 usdcToBorrow = div(
            mul(IEulerSimpleLens(_eulerLens).getDTokenBalance(_usdc, _zenBull), share), 1e18 - share
        );

        return (wethToLend, usdcToBorrow);
    }

    /**
     * @notice calculate amount of SBCH to get based on amount of ZenBull to Withdraw
     * @param _zenBull ZenBull strategy address
     * @param _crab crab strategy address
     * @param _withdrawsToProcess amount of ZenBull token to withdraw
     */
    function calcSBCHAmount(address _zenBull, address _crab, uint256 _withdrawsToProcess)
        external
        view
        returns (uint256)
    {
        uint256 bullTotalSupply = IERC20(_zenBull).totalSupply();
        (, uint256 crabDebt) = IZenBullStrategy(_zenBull).getCrabVaultDetails();
        uint256 share = div(_withdrawsToProcess, bullTotalSupply);
        uint256 _crabAmount = mul(share, IZenBullStrategy(_zenBull).getCrabBalance());

        return div(mul(_crabAmount, crabDebt), IERC20(_crab).totalSupply());
    }

    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        // add(mul(_x, _y), WAD / 2) / WAD;
        return ((_x * _y) + (1e18 / 2)) / 1e18;
    }

    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {
        // add(mul(_x, WAD), _y / 2) / _y;
        return ((_x * 1e18) + (_y / 2)) / _y;
    }
}
