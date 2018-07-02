pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    // Create a type definition of our struct.
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint yesCount;
        mapping (address => bool) approvals;
    }

    // Variables that are held in storage. Available between function calls.
    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping (address => bool) public approvers;
    uint public approversCount;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    // Remember: function arguments are memory variables. We have to set them
    // to storage variables.
    constructor(uint minimum, address creator) public {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);

        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string description, uint value, address recipient)
        public
        restricted
    {
        // This is a memory value which we'll add to our storage array.
        // Remember: When you initialise a struct, only initialise the value
        // types, not the reference types.
        Request memory newRequest = Request({
           description: description,
           value: value,
           recipient: recipient,
           complete: false,
           yesCount: 0
        });

        requests.push(newRequest);
    }

    function approveRequest(uint requestId) public {
        Request storage request = requests[requestId];

        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.yesCount++;
    }

    function finalizeRequest(uint requestId) public restricted {
        Request storage request = requests[requestId];

        require(request.yesCount > (approversCount / 2));
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;

    }

    function getSummary() public view returns (
        uint, uint, uint, uint, address
        ) {
        return (
            minimumContribution,
            this.balance,
            requests.length,
            approversCount,
            manager
        );
    }

    function getRequestsCount() public view returns (uint) {
        return requests.length;
    }
}
