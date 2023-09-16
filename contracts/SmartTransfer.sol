//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract SmartTransfer {

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

    event TokensPurchased (address indexed from, uint256 indexed amount);
    event TokensSold (address indexed from, uint256 indexed amount);
    event TokensTransferred (address indexed from, address indexed to, uint256 indexed amount);
    event TokensLocked (address indexed from, uint256 indexed amount);
    event TokensUnlocked (address indexed from, uint256 indexed amount);
    
    error GetLockedAmountRevertError(string);

    modifier checkUnlockSuitability (uint256 _amount, bytes32 _id) {
        require(lockedAmount[msg.sender][_id].amount > 0,"You do not have any locked amount by this id."); // check the locked amount is bigger than 0
        require(lockedAmount[msg.sender][_id].amount >= _amount,"You do not have enough locked amount."); // check the locked amount is bigger than requested amount
        require(lockedAmount[msg.sender][_id].unlockTimeForAmount < block.timestamp, "It's not time to unlock tokens yet."); // check the unlock time is smaller than current time
        _;
    }

    // get ether from user and add balance to the user
    function buyToken() public payable {
        require(msg.value >= 0.001 ether, "Enter a valid balance."); // check msg.value is bigger than 1
        uint etherToWei = msg.value; // define uint for convert wei to ether
        balances[msg.sender] += etherToWei; // increase the user balance as amount
        emit TokensPurchased(msg.sender, etherToWei); // emits function
    }

    function calculateReward() public {
        bytes32[] memory ids = getUnlockableTokenIds(); // define memory array that holds the unlockable lock ids
        for (uint256 i = 0; i < ids.length; i++) { // loop as array length
            uint256 ratio;
            ratio = lockedAmount[msg.sender][ids[i]].unlockTimeForAmount - lockedAmount[msg.sender][ids[i]].lockTimeForAmount;
            ratio = (ratio * 5) / 1 gwei;
            lockedAmount[msg.sender][ids[i]].rewardRatio = ratio;
        }
    }
    // reward calculation completed will be tested and connect to unlock functions

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

    function getLockedAmount() public view returns(uint256) {
        bytes32[] memory ids = userLockIds[msg.sender];
        require(ids.length != 0, "User do not have any locked amount");
        uint lockedTotalAmount;
        for (uint256 i = 0; i < ids.length; i++) { // loop as array length
            lockedTotalAmount += lockedAmount[msg.sender][ids[i]].amount; // increase total amount if amount is locked
        }
        return lockedTotalAmount;
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
        uint256 unlockTime = lockTime; //+ 0 seconds; // set unlock time, added 1 second for development
        bytes32 id = generateId(); // call generateId function and generate id for mapping
        lockedAmount[msg.sender][id].amount = _amount; // set amount of the will be locked tokens
        lockedAmount[msg.sender][id].lockId = id; // set id of the will be locked tokens
        lockedAmount[msg.sender][id].lockTimeForAmount = lockTime; // set lock time of the will be locked tokens
        lockedAmount[msg.sender][id].unlockTimeForAmount = unlockTime; // set unlock time of the will be locked tokens
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
        for (uint256 i = 0; i < ids.length; i++) { // loop as array length
            totalAvailableTokens += lockedAmount[msg.sender][ids[i]].amount; // sum of unlockable tokens
            delete lockedAmount[msg.sender][ids[i]]; // delete the map which has zero amount
        }
        delete userLockIds[msg.sender]; // delete the map which has locked ids
        balances[msg.sender] += totalAvailableTokens; // add tokens amount to the user balance
    }

    // unlock the locked tokens
    function unlockTokensByLockId(uint256 _amount, bytes32 _id) public checkUnlockSuitability(_amount, _id) {
        balances[msg.sender] += _amount; // add tokens to the user balances
        if (lockedAmount[msg.sender][_id].amount == _amount) {
            delete lockedAmount[msg.sender][_id]; // if requested amount equals to the user locked amounts then delete mapping
        } else {
            lockedAmount[msg.sender][_id].amount -= _amount; // decrease locked amounts as requested amount
        }
        emit TokensUnlocked(msg.sender, _amount); // emit function
    }

    //unlock remaining time funct

    receive() external payable {
        revert();
    }
}