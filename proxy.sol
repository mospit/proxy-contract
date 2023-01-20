//SPDX-License-Identifier: MIT
/*
  This is an example of a proxy contract that can deploy any contract
*/
pragma solidity ^0.8.0;

contract TestContract1 {
    address public owner = msg.sender;

    function setOwner(address _newOwner) public {
        require(msg.sender == owner, "not owner");

        owner = _newOwner;
    }

}
contract TestContract2 {
    address public owner = msg.sender;
    uint public value = msg.value;
    uint public x;
    uint public y;

    constructor(uint _x, uint _y) {
        x = _x;
        y = _y;
    }
}

contract proxy {
    event Deploy(address);

    fallback() external payable {}
    function deploy(bytes memory _code) external payable returns (address addr) {
        assembly {
            // create(v, p, n)
            // v is the amount of ETH to send to contract
            // p pointer in memory to start of code
            // n is the size of code
            addr :=  create(callvalue(), add(_code, 0x20), mload(_code))
        }
        require(addr != address(0), "deploy failed");
        emit Deploy(addr);
    }

    function exucute(address _target, bytes memory _data) external payable {
        (bool success, ) = _target.call{value: msg.value}(_data);
        require(success, "failed");
    }
}

contract Helper {
    function getByecode1() external pure returns (bytes memory) {
        bytes memory bytecode = type(TestContract1).creationCode;
        return bytecode;
    }

    function getByecode2( uint _x, uint _y) external pure returns (bytes memory) {
        bytes memory bytecode = type(TestContract2).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_x, _y));
    }

    function getCallData(address _owner) external pure returns (bytes memory) {
        return abi.encodeWithSignature("setOwner(address)", _owner);
    }
}
