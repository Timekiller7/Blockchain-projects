pragma solidity 0.5.1;

contract MyContract3 {
enum State { Waiting, Ready, Active }
State public state;

constructor() public {
state = State.Waiting; }

function activate() public {
state = State.Active; }
function makeReady() public {
state=State.Ready;
}
function makeWaiting() public {
state=State.Waiting;
}

function isActive() public view returns(bool) {
return state == State.Active; }
function isWaiting() public view returns(bool) {
return state == State.Waiting; }
}
