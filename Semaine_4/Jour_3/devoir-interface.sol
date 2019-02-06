pragma solidity ^0.5.3;


import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";


contract Credibilite {
   using SafeMath for uint256;

   mapping (address => uint256) public cred;

   bytes32[] private devoirs;

   function produireHash(string memory url) public pure returns(bytes32);
   function transfer(address destinataire, uint256 valeur) public;
   function remettre(bytes32 dev) public returns(uint256);
}
