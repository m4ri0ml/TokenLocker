// SPDX-License-Identifier: Do-Whatever-You-Want-With-This-License
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*

 /$$$$$$$$        /$$                           /$$                           /$$                          
|__  $$__/       | $$                          | $$                          | $$                          
   | $$  /$$$$$$ | $$   /$$  /$$$$$$  /$$$$$$$ | $$        /$$$$$$   /$$$$$$$| $$   /$$  /$$$$$$   /$$$$$$ 
   | $$ /$$__  $$| $$  /$$/ /$$__  $$| $$__  $$| $$       /$$__  $$ /$$_____/| $$  /$$/ /$$__  $$ /$$__  $$
   | $$| $$  \ $$| $$$$$$/ | $$$$$$$$| $$  \ $$| $$      | $$  \ $$| $$      | $$$$$$/ | $$$$$$$$| $$  \__/
   | $$| $$  | $$| $$_  $$ | $$_____/| $$  | $$| $$      | $$  | $$| $$      | $$_  $$ | $$_____/| $$      
   | $$|  $$$$$$/| $$ \  $$|  $$$$$$$| $$  | $$| $$$$$$$$|  $$$$$$/|  $$$$$$$| $$ \  $$|  $$$$$$$| $$      
   |__/ \______/ |__/  \__/ \_______/|__/  |__/|________/ \______/  \_______/|__/  \__/ \_______/|__/      
                                            By: 0xM4R10.eth
            Messy, unoptimized code from a solidity apprentice, dont use this in production
                            or lock a significant amount of funds. (please)    
                    Also, owner can rug all funds in contract (see rugWithdraw())                                
**/

contract TokenLocker is Ownable {
    using SafeERC20 for IERC20;
    
    bool isPaused = false;

    mapping (address => uint256) public lockedEthBalance;
    mapping (address => uint256) public ethUnlockTime;

    mapping (address => uint256) public lockedERC20Balance;
    mapping (address => address) public lockedERC20;
    mapping (address => uint256) public erc20UnlockTime;

    event Withdrawal(uint amount, uint when);
    event Locking(uint amount, uint unlockTime);

    function lockETH(uint256 time) public payable {
        require(isPaused == false, "Contract is currently paused");
        require(block.timestamp < time, "Unlock time should be in the future");
        require(time >= ethUnlockTime[msg.sender], 
            "Unlock time for new locking should be equal or greater to current one");

        ethUnlockTime[msg.sender] = time;
        lockedEthBalance[msg.sender] += msg.value;

        emit Locking(msg.value, time);
    }

    /* @notice Withdraws all ETH from contract to function caller. **/

    function withdrawETH() public {
        require(block.timestamp >= ethUnlockTime[msg.sender], "You can't withdraw yet");

        payable(msg.sender).transfer(lockedEthBalance[msg.sender]);

        lockedEthBalance[msg.sender] = 0;
        ethUnlockTime[msg.sender] = 0;

        emit Withdrawal(lockedEthBalance[msg.sender], block.timestamp);
    }

    function lockERC20(IERC20 token, uint256 amount, uint256 time) public {
        require(isPaused == false, "Contract is currently paused");
        require(lockedERC20[msg.sender] == address(0), "A ERC20 token is already locked");
        require(block.timestamp < time, "Unlock time should be in the future");

        lockedERC20Balance[msg.sender] = amount;
        erc20UnlockTime[msg.sender] = time;
        lockedERC20[msg.sender] = address(token);

        token.safeTransferFrom(msg.sender, address(this), amount);

        emit Locking(amount, time);
    }

    /* @notice Withdraws all ERC20 tokens from contract to function caller. **/

    function withdrawERC20() public {
        require(block.timestamp >= erc20UnlockTime[msg.sender], "You can't withdraw yet");

        IERC20 token = IERC20(lockedERC20[msg.sender]);
        token.transfer(msg.sender, lockedERC20Balance[msg.sender]);

        erc20UnlockTime[msg.sender] = 0;
        lockedERC20[msg.sender] = address(0);

        emit Withdrawal(lockedERC20Balance[msg.sender], block.timestamp);
    }   
    
    /*
    @notice Transfers all ETH and selected ERC20 from contract to owner.
    @param token - Token address of the ERC20 you want to withdraw from contract.
    @param amount - Amount of tokens you want to withdraw from selected ERC20.
    **/

    function rugWithdraw(IERC20 token, uint256 amount) public onlyOwner {
        if (address(this).balance != 0) {
            payable(msg.sender).transfer(address(this).balance);
        }

        token.transfer(msg.sender, amount);
    }

    function pauseContract(bool paused) public onlyOwner {
        isPaused = paused;
    }
}
