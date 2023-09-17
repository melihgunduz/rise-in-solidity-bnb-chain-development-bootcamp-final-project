// Sources flattened with hardhat v2.17.3 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}


// File contracts/SmartTransfer.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.18;

// importing reentrancy guard from openzeppelin contracts
contract SmartTransfer is ReentrancyGuard {

    //defining necessary mappings, variables and structs in below
    uint256 private count = 0;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (bytes32 => LockedAmount)) public lockedAmount;
    mapping (address => uint256) private unlockableTokens;
    mapping (address => bytes32[]) public userLockIds;

    // struct for per locked amount
    struct LockedAmount {
        uint256 amount;
        bytes32 lockId;
        uint256 lockTimeForAmount;
        uint256 unlockTimeForAmount;
        uint256 rewardRatio;
    }

    //our events are below that triggers when functions over
    event TokensPurchased (address indexed from, uint256 indexed amount);
    event TokensSold (address indexed from, uint256 indexed amount);
    event TokensTransferred (address indexed from, address indexed to, uint256 indexed amount);
    event TokensLocked (address indexed from, uint256 indexed amount);
    event TokensUnlocked (address indexed from, uint256 indexed amount);
    

    constructor() {
        balances[address(this)] = 1 ether; // giving 1 ether balance to our contract
    }

    // creating medifier for unlock tokens by id
    modifier checkUnlockSuitability (uint256 _amount, bytes32 _id) {
        require(lockedAmount[msg.sender][_id].amount > 0,"You do not have any locked amount by this id."); // check the locked amount is bigger than 0
        require(lockedAmount[msg.sender][_id].amount >= _amount,"You do not have enough locked amount."); // check the locked amount is bigger than requested amount
        require(lockedAmount[msg.sender][_id].unlockTimeForAmount < block.timestamp, "It's not time to unlock tokens yet."); // check the unlock time is smaller than current time
        _;
    }

    // get ether from user and add balance to the user
    function buyToken() public payable nonReentrant {
        require(msg.value >= 0.001 ether, "Enter a valid balance."); // check msg.value is bigger than 1
        uint etherToWei = msg.value; // define uint for convert wei to ether
        balances[msg.sender] += etherToWei; // increase the user balance as amount
        emit TokensPurchased(msg.sender, etherToWei); // emits function
    }

    function calculateRewardRatioPerToken() public{
        bytes32[] memory ids = getUnlockableTokenIds(); // define memory array that holds the unlockable lock ids
        for (uint256 i = 0; i < ids.length; i++) { // loop as array length
            uint256 ratio; // define ratio variable for token reward ratio
            ratio = lockedAmount[msg.sender][ids[i]].unlockTimeForAmount - lockedAmount[msg.sender][ids[i]].lockTimeForAmount;
            // the line above calculating ratio with lock and unlock times
            ratio = (ratio * 500); // changing ratio value
            lockedAmount[msg.sender][ids[i]].rewardRatio = ratio; // applying ratio for locked tokens
        }
    }

    function checkBalanceOfUser(address _user) view public returns(uint256) {
        return balances[_user]; // return the balance of user 
    }

    // generating unique id for mapping locked amounts id
    function generateId() private returns(bytes32) {
        incrementCounter(); // count incremented
        return keccak256(abi.encodePacked(getCount() + block.timestamp)); // id generated and returned
    }

    function getCount() private view returns (uint256) {
        return count; // return the current counter
    }


    // get all locked amount of user
    function getLockedAmount() public view returns(uint256) {
        bytes32[] memory ids = userLockIds[msg.sender]; // define memory array that holds the locked tokens ids
        require(ids.length != 0, "User do not have any locked amount"); // check if user have locked tokens
        uint lockedTotalAmount; // define variable to sum all locked tokens value
        for (uint256 i = 0; i < ids.length; i++) { // loop as array length
            lockedTotalAmount += lockedAmount[msg.sender][ids[i]].amount; // increase total amount if amount is locked
        }
        return lockedTotalAmount; // returns total locked amount
    }

    // calculate the all unlockable amounts locked by user
    function getUnlockableTokens() public view returns(uint256) {
        bytes32[] memory ids = getUnlockableTokenIds(); // define memory array that holds the unlockable lock ids
        uint256 totalAmount; // define uint for total amount
        for (uint256 i = 0; i < ids.length; i++) { // loop as array length
            totalAmount += lockedAmount[msg.sender][ids[i]].amount; // increase total amount if amount is unlockable
        }
        return totalAmount; //return the unlockable amount
    }

    // return the unlockable tokens map ids
    function getUnlockableTokenIds() public view returns(bytes32[] memory) {
        bytes32[] memory ids = userLockIds[msg.sender]; // define memory array that holds the lock ids
        bytes32[] memory unlockableIds = new bytes32[](ids.length); // define memory bytes array with static length
        for (uint256 i = 0; i < ids.length; i++) { // loop as array length
            if (lockedAmount[msg.sender][ids[i]].unlockTimeForAmount < block.timestamp) { // check unlock time for unlock balance
            unlockableIds[i] = ids[i]; // write unlockable id to the byte array
            }
        }
        return unlockableIds; //return the unlockable ids
    }

    function incrementCounter() private {
        count += 1; // increase the counter
    }

        // locking tokens for a period
    function lockTokens(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Requested balance bigger than total balance.");
        balances[msg.sender] -= _amount; // decreasing user balance from balances
        uint256 lockTime = block.timestamp; // get current time as second
        uint256 unlockTime = lockTime + 15 seconds; // set unlock time, added 1 second for development
        bytes32 id = generateId(); // call generateId function and generate id for mapping
        lockedAmount[msg.sender][id] = LockedAmount(_amount,id,lockTime,unlockTime,0); // set locked
        userLockIds[msg.sender].push(id); // push mapping id to the userLockIds list
        emit TokensLocked(msg.sender, _amount); // emit function
    }

    // get tokens from user and pay ether to the user 
    function sellToken(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "User do not have enough balance."); // check balance of the user
        payable(msg.sender).transfer(_amount); // pay ether to the user
        balances[msg.sender] -= _amount; // decrease amount of user as requested amount
        emit TokensSold(msg.sender, _amount); // emit function
    }

    
    function transferToken(address _from, address _to, uint256 _amount) public {
        require(balances[_from] > 0, "You do not have enough balance to transfer."); // check the user balance
        require(balances[_from] >= _amount, "Requested balance bigger than total balance."); // chechk the user balance for requested amount
        balances[_from] -= _amount; // decrease user balance which sends the token
        balances[_to] += _amount; // increase user balance which receives the token
        emit TokensTransferred(_from, _to, _amount); // emits function
    }

    // unlock all unlockable tokens
    function unlockAllAvailableTokens() public {
        bytes32[] memory ids = getUnlockableTokenIds(); // define an bytes array equals to unlockable ids bytes
        uint256 totalAvailableTokens; // define unlockable total amount
        uint256 rewardTokens; // define reward token variable
        calculateRewardRatioPerToken(); // calculating reward before unlock them
        for (uint256 i = 0; i < ids.length; i++) { // loop as array length
            rewardTokens += lockedAmount[msg.sender][ids[i]].amount * lockedAmount[msg.sender][ids[i]].rewardRatio;
            totalAvailableTokens += lockedAmount[msg.sender][ids[i]].amount; // sum of unlockable tokens
            delete lockedAmount[msg.sender][ids[i]]; // delete the map which has zero amount
        }
        delete userLockIds[msg.sender]; // delete the map which has locked ids
        balances[msg.sender] += totalAvailableTokens; // add tokens amount to the user balance
        transferToken(address(this), msg.sender, rewardTokens); // transfer the rewards from contract to user
        emit TokensUnlocked(msg.sender, totalAvailableTokens); // emit function

    }

    // unlock the locked tokens
    function unlockTokensByLockId(uint256 _amount, bytes32 _id) public checkUnlockSuitability(_amount, _id) {
        calculateRewardRatioPerToken(); // calculating reward before unlock them
        uint256 rewardTokens; // define reward token variable
        rewardTokens += lockedAmount[msg.sender][_id].amount * lockedAmount[msg.sender][_id].rewardRatio; 
        transferToken(address(this), msg.sender, rewardTokens); // transfer the rewards from contract to user

        balances[msg.sender] += _amount; // add tokens to the user balances
        if (lockedAmount[msg.sender][_id].amount == _amount) {
            delete lockedAmount[msg.sender][_id]; // if requested amount equals to the user locked amounts then delete mapping
        } else {
            lockedAmount[msg.sender][_id].amount -= _amount; // decrease locked amounts as requested amount
        }
        emit TokensUnlocked(msg.sender, _amount); // emit function
    }

    receive() external payable {
        revert(); // reverting transactions that coming outside from functions
    }
}
