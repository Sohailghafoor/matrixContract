// SPDX-License-Identifier: MIT
pragma solidity >=0.4.23 <0.8.0;
// Successfully verified contract TolMatrixX4 on Etherscan.
// https://testnet.bscscan.com/address/0x5232B9c20746BB3ffD048b0c8fa646feC2B90Ff8#code
//            0
//           000
//           000
//          00000
//          00000
//         0000000
//         0000000
//        000000000
//        000000000
//       00000000000
//       00000000000
//      0000000000000
//      0000000000000
//     000000000000000
//     000000000000000
//    00000000000000000
//           ██
//           ██
//           ██
//           ██

///     Tree Of Life
//       (TolCoin)
// https://www.tolcoin.co/


contract XGOLD {
    function deposit(address sender, address referrer) public payable;
}

contract TolMatrixX4 {
    
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        mapping(uint8 => bool) activeX4Levels;
        mapping(uint8 => X4) x4Matrix;
    }
    
    struct X4 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint reinvestCount;
        address closedPart;
    }

    uint8 public currentStartingLevel = 1;
    uint8 public constant LAST_LEVEL = 15;
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;

    uint public lastUserId = 1;
    address public owner;
    
    mapping(uint8 => uint) public levelPrice;

    XGOLD public xGOLD;
    
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);
    
    
    constructor(address ownerAddress) public {
        levelPrice[1] = 0.0001 ether;
        levelPrice[2] = 0.002 ether;
        levelPrice[3] = 0.04 ether;
        levelPrice[4] = 0.8 ether;
        levelPrice[5] = 16 ether;
        levelPrice[6] = 32 ether;
        levelPrice[7] = 64 ether;
        levelPrice[8] = 128 ether;
        levelPrice[9] = 256 ether;
        levelPrice[10] = 512 ether;
        levelPrice[11] = 1024 ether;
        levelPrice[12] = 2048 ether;
        levelPrice[13] = 3584 ether;
        levelPrice[14] = 6272 ether;
        levelPrice[15] = 10976 ether;

         
        owner = ownerAddress;
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0)
        });
        
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeX4Levels[i] = true;
        }   
        userIds[1] = ownerAddress;

    }
    //done 
    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }
    //done
    function setXGold(address xGoldAddress) public {
        require(msg.sender == 0xc25cA3567626a6845103D2CBb5cdcF268Fa4D96A, "onlyOwner");
        require(address(xGOLD) == address(0));
        xGOLD = XGOLD(xGoldAddress);
    }
    //done
    function withdrawLostTRXFromBalance() public {
        require(msg.sender == 0xc25cA3567626a6845103D2CBb5cdcF268Fa4D96A, "onlyOwner");
        0xc25cA3567626a6845103D2CBb5cdcF268Fa4D96A.transfer(address(this).balance);
    }

    //done 
    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }
    //done 
    function buyNewLevel(uint8 matrix, uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(matrix == 1 , "invalid matrix");
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

        if (matrix == 1)  {
            require(users[msg.sender].activeX4Levels[level-1], "buy previous level first");
            require(!users[msg.sender].activeX4Levels[level], "level already activated"); 

            if (users[msg.sender].x4Matrix[level-1].blocked) {
                users[msg.sender].x4Matrix[level-1].blocked = false;
            }

            address freeX4Referrer = findfreeX4Referrer(msg.sender, level);
            users[msg.sender].x4Matrix[level].currentReferrer = freeX4Referrer;
            users[msg.sender].activeX4Levels[level] = true;
            updateX4Referrer(msg.sender, freeX4Referrer, level);
            
            emit Upgrade(msg.sender, freeX4Referrer, 1, level);
        }
    }
    //done 
    function registration(address userAddress, address referrerAddress) private {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        if (address(xGOLD) != address(0)) {
            xGOLD.deposit(userAddress, referrerAddress);
            require(msg.value == levelPrice[currentStartingLevel] * 3, "invalid registration cost");
        } else {
            require(msg.value == levelPrice[currentStartingLevel] * 2, "invalid registration cost");
        }
        lastUserId++;
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0
        });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        users[userAddress].activeX4Levels[1] = true;
        userIds[lastUserId] = userAddress;
        users[referrerAddress].partnersCount++;

        address freeX4Referrer = findfreeX4Referrer(userAddress, 1);
     //need to check
        users[userAddress].x4Matrix[1].currentReferrer = freeX4Referrer;
        updateX4Referrer(userAddress, freeX4Referrer, 1);
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    //done
    function updateX4Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeX4Levels[level], "500. Referrer level is inactive");
        
        if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length < 2) {
            users[referrerAddress].x4Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].x4Matrix[level].firstLevelReferrals.length));
            
            //set current level
            users[userAddress].x4Matrix[level].currentReferrer = referrerAddress;

            if (referrerAddress == owner) {
                return sendETHDividends(referrerAddress, userAddress, 1, level);
            }
            
            address ref = users[referrerAddress].x4Matrix[level].currentReferrer;            
            users[ref].x4Matrix[level].secondLevelReferrals.push(userAddress); 
            
            uint len = users[ref].x4Matrix[level].firstLevelReferrals.length;
            
            if ((len == 2) && 
                (users[ref].x4Matrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].x4Matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 1, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 1, level, 6);
                }
            }  else if ((len == 1 || len == 2) &&
                    users[ref].x4Matrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 1, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, 1, level, 4);
                }
            } else if (len == 2 && users[ref].x4Matrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 1, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 1, level, 6);
                }
            }

            return updateX4ReferrerSecondLevel(userAddress, ref, level);
        }
        
        users[referrerAddress].x4Matrix[level].secondLevelReferrals.push(userAddress);

        if (users[referrerAddress].x4Matrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x4Matrix[level].closedPart)) {

                updateX4(userAddress, referrerAddress, level, true);
                return updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].x4Matrix[level].closedPart) {
                updateX4(userAddress, referrerAddress, level, true);
                return updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                updateX4(userAddress, referrerAddress, level, false);
                return updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (users[referrerAddress].x4Matrix[level].firstLevelReferrals[1] == userAddress) {
            updateX4(userAddress, referrerAddress, level, false);
            return updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] == userAddress) {
            updateX4(userAddress, referrerAddress, level, true);
            return updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
        }
        
        if (users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.length) {
            updateX4(userAddress, referrerAddress, level, false);
        } else {
            updateX4(userAddress, referrerAddress, level, true);
        }
        
        updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
    }
    //done
    function updateX4(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x4Matrix[level].firstLevelReferrals[0], 1, level, uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 1, level, 2 + uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].x4Matrix[level].currentReferrer = users[referrerAddress].x4Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x4Matrix[level].firstLevelReferrals[1], 1, level, uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 1, level, 4 + uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].x4Matrix[level].currentReferrer = users[referrerAddress].x4Matrix[level].firstLevelReferrals[1];
        }
    }
    //done
    function updateX4ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].x4Matrix[level].secondLevelReferrals.length < 4) {
            return sendETHDividends(referrerAddress, userAddress, 1, level);
        }
        
        address[] memory x4 = users[users[referrerAddress].x4Matrix[level].currentReferrer].x4Matrix[level].firstLevelReferrals;
        
        if (x4.length == 2) {
            if (x4[0] == referrerAddress ||
                x4[1] == referrerAddress) {
                users[users[referrerAddress].x4Matrix[level].currentReferrer].x4Matrix[level].closedPart = referrerAddress;
            } else if (x4.length == 1) {
                if (x4[0] == referrerAddress) {
                    users[users[referrerAddress].x4Matrix[level].currentReferrer].x4Matrix[level].closedPart = referrerAddress;
                }
            }
        }
        
        users[referrerAddress].x4Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].x4Matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].x4Matrix[level].closedPart = address(0);

        if (!users[referrerAddress].activeX4Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].x4Matrix[level].blocked = true;
        }

        users[referrerAddress].x4Matrix[level].reinvestCount++;
        
        if (referrerAddress != owner) {
            address freeReferrerAddress = findfreeX4Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            updateX4Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner, address(0), userAddress, 1, level);
            sendETHDividends(owner, userAddress, 1, level);
        }
    }
    //done
    function findfreeX4Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX4Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
    //done
    function usersactiveX4Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeX4Levels[level];
    }
    //done
    function usersx4Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, bool, address) {
        return (users[userAddress].x4Matrix[level].currentReferrer,
                users[userAddress].x4Matrix[level].firstLevelReferrals,
                users[userAddress].x4Matrix[level].secondLevelReferrals,
                users[userAddress].x4Matrix[level].blocked,
                users[userAddress].x4Matrix[level].closedPart);
    }
    //done
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    //done
    function findEthReceiver(address userAddress, address _from, uint8 matrix, uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].x4Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x4Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
    }
    //done
    function sendETHDividends(address userAddress, address _from, uint8 matrix, uint8 level) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, matrix, level);

        // if (!address(uint160(receiver)).send(levelPrice[level])) {
        //     address(uint160(owner)).send(address(this).balance);
        //     return;
        // }
       require(address(uint160(receiver)).send(address(this).balance), "Failed to send Ether");

        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }
    //done
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}