pragma solidity ^0.6.0;

import "./ERC721.sol";

// SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: bsc-library/contracts/SafeBEP20.sol

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File openzeppelin-solidity/contracts/security/ReentrancyGuard.sol@v4.4.1

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract GuitarNftFarm is Ownable, ReentrancyGuard, IERC721Receiver {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    IBEP20 public stakingToken;
    ERC721Enumerable public nftToken;

    uint256 public startAt; // NFT Farming Start Date
    uint256 public endAt; // NFT Farming End Date

    uint256 public totalNftsToSell; // Total NFTs to sell
    uint256 public nftPrice; // NFT price in staking token
    uint256 public maxPerUser; // Max NFTs an user can get
    uint256 public totalNftsSold = 0; // Nfts sold to users including locked
    uint256 public totalNftsLocked = 0; // Nfts locked now
    uint256 public totalTokensLocked = 0; // Sum of tokens locked
    uint16 public depositFeeBP; // Deposit fee
    address public feeAddress; // Fee address
    uint256 public lockPeriod; // Lock period for getting NFTs

    uint16 public constant MAX_DEPOSIT_FEE = 2000; // Max deposit fee 20%
    uint256 public constant MAX_LOCK_PERIOD = 90 days; // Max lock period 3 months

    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 nftsLocked; // NFTs locked now
        uint256 tokensLocked; // Tokens locked now
        uint256 nftsPurchased; // NFTs purchased so far including locked
        uint256 lastStakedAt; // Last staked time
    }

    event Staked(
        address indexed user,
        uint256 tokenAmount,
        uint256 nftToBuyAmount
    );
    event Claimed(
        address indexed user,
        uint256 claimedTokenAmount,
        uint256 claimedNftAmount
    );
    event StartDateUpdated(uint256 oldDate, uint256 newDate);
    event EndDateUpdated(uint256 oldDate, uint256 newDate);
    event TotalNftsToSellUpdated(uint256 oldAmount, uint256 newAmount);
    event MaxPerUserUpdated(uint256 oldLimit, uint256 newLimit);
    event NftPriceUpdated(uint256 oldPrice, uint256 newPrice);
    event FarmingEnded();
    event DepositFeeUpdated(uint16 oldFee, uint16 newFee);
    event FeeAddressUpdated(address oldAddress, address newAddress);
    event LockPeriodUpdated(uint256 oldPeriod, uint256 newPeriod);
    event EmergencyWithdrawn(address indexed user, uint256 amount);
    event AdminNftWithdrawn(uint256 amount);
    event AdminTokenRecovery(address tokenRecovered, uint256 amount);

    constructor(
        IBEP20 _stakingToken,
        ERC721Enumerable _nftToken,
        uint256 _startAt,
        uint256 _endAt,
        uint256 _totalNftsToSell,
        uint256 _nftPrice,
        uint256 _maxPerUser,
        uint16 _depositFeeBP,
        address _feeAddress,
        uint256 _lockPeriod
    ) public {
        stakingToken = _stakingToken;
        nftToken = _nftToken;

        require(_startAt <= _endAt, "Start time should be before end time");
        require(
            _startAt >= block.timestamp,
            "Start time should be after current time"
        );
        startAt = _startAt;
        endAt = _endAt;

        totalNftsToSell = _totalNftsToSell;
        require(_nftPrice > 0, "Invalid nft price");
        nftPrice = _nftPrice;
        maxPerUser = _maxPerUser;

        require(_depositFeeBP <= MAX_DEPOSIT_FEE, "Deposit fee exceeds limit");
        depositFeeBP = _depositFeeBP;
        require(_feeAddress != address(0), "Invalid fee address");
        feeAddress = _feeAddress;

        require(_lockPeriod <= MAX_LOCK_PERIOD, "Lock period exceeds limit");
        lockPeriod = _lockPeriod;
    }

    // Stake tokens to get NFTs
    function stake(uint256 tokenAmountToStake, uint256 nftAmountToBuy)
        external
        nonReentrant
    {
        require(block.timestamp >= startAt, "Farm not started yet");
        require(block.timestamp < endAt, "Farm ended already");
        require(nftAmountToBuy > 0, "Invalid nft amount to buy");
        require(
            tokenAmountToStake >= nftAmountToBuy.mul(nftPrice),
            "Insufficient token amount"
        );

        UserInfo storage user = userInfo[msg.sender];
        user.nftsPurchased = user.nftsPurchased.add(nftAmountToBuy);
        user.nftsLocked = user.nftsLocked.add(nftAmountToBuy);
        require(
            user.nftsPurchased <= maxPerUser,
            "Exceeds user purchasable limit"
        );
        user.lastStakedAt = block.timestamp;

        totalNftsLocked = totalNftsLocked.add(nftAmountToBuy);
        totalNftsSold = totalNftsSold.add(nftAmountToBuy);
        require(
            nftToken.balanceOf(address(this)) >= totalNftsLocked,
            "Insufficient NFTs to be farmed"
        );

        uint256 balanceBefore = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(
            msg.sender,
            address(this),
            tokenAmountToStake
        );
        tokenAmountToStake = stakingToken.balanceOf(address(this)).sub(
            balanceBefore
        );
        if (depositFeeBP > 0) {
            uint256 depositFee = tokenAmountToStake.mul(depositFeeBP).div(
                10000
            );
            if (depositFee > 0) {
                tokenAmountToStake = tokenAmountToStake.sub(depositFee);
                stakingToken.safeTransfer(feeAddress, depositFee);
            }
        }
        user.tokensLocked = user.tokensLocked.add(tokenAmountToStake);
        totalTokensLocked = totalTokensLocked.add(tokenAmountToStake);
        emit Staked(msg.sender, tokenAmountToStake, nftAmountToBuy);
    }

    // Claim tokens and NFTs locked
    function claim() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(
            user.tokensLocked > 0 || user.nftsLocked > 0,
            "Nothing to claim"
        );
        require(
            stakingToken.balanceOf(address(this)) >= user.tokensLocked,
            "Less amount of staking token in the farm"
        );
        require(
            nftToken.balanceOf(address(this)) >= user.nftsLocked,
            "Less amount of nfts in the farm"
        );
        require(
            user.lastStakedAt.add(lockPeriod) <= block.timestamp,
            "Still in lock status"
        );

        // Token claim
        stakingToken.safeTransfer(msg.sender, user.tokensLocked);

        // Nft claim
        for (uint256 i = 0; i < user.nftsLocked; i++) {
            uint256 tokenId = nftToken.tokenOfOwnerByIndex(address(this), 0);
            nftToken.safeTransferFrom(address(this), msg.sender, tokenId);
        }

        emit Claimed(msg.sender, user.tokensLocked, user.nftsLocked);

        totalNftsLocked = totalNftsLocked.sub(user.nftsLocked);
        totalTokensLocked = totalTokensLocked.sub(user.tokensLocked);
        user.tokensLocked = 0;
        user.nftsLocked = 0;
    }

    // function to set the presale start date
    // only owner can call this function
    function setStartDate(uint256 _startAt) external onlyOwner {
        require(startAt > block.timestamp, "Farm already started");
        require(
            _startAt >= block.timestamp,
            "Start date should be after current time"
        );
        require(_startAt <= endAt, "Start date should be before end date");
        emit StartDateUpdated(startAt, _startAt);
        startAt = _startAt;
    }

    // Function to set the presale end date
    // only owner can call this function
    function setEndDate(uint256 _endAt) external onlyOwner {
        require(
            _endAt >= block.timestamp,
            "End date should be after current time"
        );
        require(_endAt >= startAt, "End date should be after start date");
        emit EndDateUpdated(endAt, _endAt);
        endAt = _endAt;
    }

    // function to set the total tokens to sell
    // only owner can call this function
    function setTotalNftsToSell(uint256 _totalNftsToSell) external onlyOwner {
        require(
            _totalNftsToSell >= totalNftsSold,
            "Alreday sold more than this amount"
        );
        emit TotalNftsToSellUpdated(totalNftsToSell, _totalNftsToSell);
        totalNftsToSell = _totalNftsToSell;
    }

    // function to set the maximum amount which a user can buy
    // only owner can call this function
    function setMaxPerUser(uint256 _maxPerUser) external onlyOwner {
        emit MaxPerUserUpdated(maxPerUser, _maxPerUser);
        maxPerUser = _maxPerUser;
    }

    // function to set the Nft price
    // only owner can call this function
    function setNftPrice(uint256 _nftPrice) external onlyOwner {
        require(_nftPrice > 0, "Invalid Nft price");
        emit NftPriceUpdated(nftPrice, _nftPrice);
        nftPrice = _nftPrice;
    }

    //function to end the sale
    //only owner can call this function
    function endFarming() external onlyOwner {
        require(endAt <= block.timestamp, "Farming already finished");
        endAt = block.timestamp;
        if (startAt > block.timestamp) {
            startAt = block.timestamp;
        }
        emit FarmingEnded();
    }

    function updateDepositFee(uint16 _depositFeeBP) external onlyOwner {
        require(_depositFeeBP <= MAX_DEPOSIT_FEE, "Deposit fee exceeds limit");
        emit DepositFeeUpdated(depositFeeBP, _depositFeeBP);
        depositFeeBP = _depositFeeBP;
    }

    function updateFeeAddresss(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0), "Invalid fee address");
        emit FeeAddressUpdated(feeAddress, _feeAddress);
        feeAddress = _feeAddress;
    }

    function updateLockPeriod(uint256 _lockPeriod) external onlyOwner {
        require(_lockPeriod <= MAX_LOCK_PERIOD, "Lock period exceeds limit");
        emit LockPeriodUpdated(lockPeriod, _lockPeriod);
        lockPeriod = _lockPeriod;
    }

    //function to withdraw unsold tokens
    //only owner can call this function
    function withdrawRemainedNfts(uint256 nftAmount)
        external
        onlyOwner
        nonReentrant
    {
        uint256 nftsInFarm = nftToken.balanceOf(address(this));
        require(
            nftsInFarm >= nftAmount.add(totalNftsLocked),
            "Insufficient NFT amount"
        );

        for (uint256 i = 0; i < nftsInFarm; i++) {
            uint256 tokenId = nftToken.tokenOfOwnerByIndex(address(this), 0);
            nftToken.safeTransferFrom(address(this), msg.sender, tokenId);
        }

        emit AdminNftWithdrawn(nftAmount);
    }

    // Emergency withdraw tokens from the farm
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.tokensLocked > 0, "Nothing to withdraw");
        require(
            stakingToken.balanceOf(address(this)) >= user.tokensLocked,
            "Less amount of staking token in the farm"
        );

        // Token claim
        stakingToken.safeTransfer(msg.sender, user.tokensLocked);

        emit EmergencyWithdrawn(msg.sender, user.tokensLocked);

        totalNftsLocked = totalNftsLocked.sub(user.nftsLocked);
        totalNftsSold = totalNftsSold.sub(user.nftsLocked);
        totalTokensLocked = totalTokensLocked.sub(user.tokensLocked);
        user.nftsPurchased = user.nftsPurchased.sub(user.nftsLocked);
        user.tokensLocked = 0;
        user.nftsLocked = 0;
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        require(
            _tokenAddress != address(stakingToken),
            "Cannot be staked token"
        );

        IBEP20(_tokenAddress).safeTransfer(msg.sender, _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
