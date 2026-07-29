pragma solidity >=0.0;
contract C {
	function f() public view returns (uint) {
		return block.slotnum;
	}
}
