pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/security/Pausable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-solidity/contracts/utils/structs/EnumerableSet.sol";
import "openzeppelin-solidity/contracts/token/ERC20/utils/SafeERC20.sol";


contract BACStaking is ReentrancyGuard, Pausable, Ownable,  IERC721Receiver {
    
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;


    /* Reward Token */
    address public rewardTokenAddress;

    /* Staking Reward ratio ( every day ) */
    uint256 public rewardPerDay =  10 * 10 ** 18;
    
    address public stakeNft;

    struct UserInfo {
        uint256 balance;
        uint256 rewards;
        uint256 lastUpdated;
    }


    mapping(address => EnumerableSet.UintSet) private userBlanaces;

    // Info of each user that stakes LP tokens.
    mapping(address => UserInfo) private userInfo;

    event RewardAddressUpdated( address token);
    event RewardPerDayUpdated( uint256 reward);

    event Staked( address indexed account, uint256 tokenId);
    event Withdrawn( address indexed account, uint256 tokenId);
    event Harvest(address indexed user, uint256 amount);

    constructor(address _rewardTokenAddress,address _stakeNft, uint256 _rewardPerDay) {
        stakeNft = _stakeNft;
        rewardTokenAddress = _rewardTokenAddress;
        rewardPerDay = _rewardPerDay;
    }

    function userStakeInfo(address _owner) external view returns(UserInfo memory){
         return userInfo[_owner];
    } 

    function userStakedNFT(address _owner) public view returns(uint256[] memory){
        //  return userBlanaces[_owner].values();
        uint256 tokenCount = userBlanaces[_owner].length();
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }

    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        return userBlanaces[owner].at(index);
    } 

    function userStakedNFTCount(address _owner) public view returns(uint256){
         return userBlanaces[_owner].length();
    }


    function setRewardTokenAddress( address _address) external onlyOwner {
        require(_address != address(0x0), "invalid address");
        rewardTokenAddress = _address;

        emit RewardAddressUpdated(_address);
    }

    function setRewardPerDay( uint256 _reward) external onlyOwner {
        rewardPerDay = _reward;
        emit RewardPerDayUpdated(_reward);
    }

   
    function isStaked( address account ,uint256 tokenId) public view returns (bool) {
        return userBlanaces[account].contains(tokenId);
    }

    function earned(address account) public view returns (uint256) {
        uint256 blockTime = block.timestamp;

        UserInfo memory user = userInfo[account];

        uint256 amount = blockTime.sub(user.lastUpdated).mul(userStakedNFTCount(account)).mul(rewardPerDay).div(1 days);

        return user.rewards.add(amount);
    }


    function stake( uint256[] memory  tokenIdList) public nonReentrant whenNotPaused {

        require(IERC721(stakeNft).isApprovedForAll(_msgSender(),address(this)),"Not approve nft to staker address");

        UserInfo storage user = userInfo[_msgSender()];
        user.rewards = earned(_msgSender());
        user.lastUpdated = block.timestamp;

        for (uint256 i = 0; i < tokenIdList.length; i++) {
            IERC721(stakeNft).safeTransferFrom(_msgSender(), address(this), tokenIdList[i]);

            userBlanaces[_msgSender()].add(tokenIdList[i]);

            emit Staked( _msgSender(), tokenIdList[i]);
        }
    }


    function withdraw( uint256[] memory  tokenIdList) public nonReentrant {
        UserInfo storage user = userInfo[_msgSender()];
        user.rewards = earned(_msgSender());
        user.lastUpdated = block.timestamp;

        for (uint256 i = 0; i < tokenIdList.length; i++) {
            require(tokenIdList[i] > 0, "Invaild token id");

            require(isStaked(_msgSender(), tokenIdList[i]), "Not staked this nft");        

            IERC721(stakeNft).safeTransferFrom(address(this) , _msgSender(), tokenIdList[i]);

            userBlanaces[_msgSender()].remove(tokenIdList[i]);

            emit Withdrawn(_msgSender(), tokenIdList[i]);    
        }
    }


    function harvest() public  nonReentrant {

        UserInfo storage user = userInfo[_msgSender()];

        user.rewards = earned(_msgSender());
        user.lastUpdated = block.timestamp;

        require(IERC20(rewardTokenAddress).balanceOf(address(this)) >= user.rewards,"Reward token amount is small");

        if (user.rewards > 0) {
            IERC20(rewardTokenAddress).safeTransfer(_msgSender(), user.rewards);
        }

        user.rewards = 0;

        emit Harvest(_msgSender(),  user.rewards);
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
