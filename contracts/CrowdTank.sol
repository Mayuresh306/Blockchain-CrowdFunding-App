// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CrowdTank is ReentrancyGuard {

    uint TotalRaisedFunding;
    uint public TotalProjects;
    address public admin;
    uint public systemCommission;
    uint Successful_Funded_Projects;
    uint Failed_Funded_Projects;

   event addedCreator(address indexed creator);
   event removedCreator(address indexed creator);

   constructor() {        
        admin = msg.sender;
   }

   modifier OnlyAdmin() {
    require(admin == msg.sender , "Only Admin can access");_;
   }

   mapping (address => bool) public AuthorizedCreators;

    function Add_Creators( address _creator ) external OnlyAdmin {
        AuthorizedCreators[_creator] = true;

        emit addedCreator(_creator);
    }
    
    function Remove_Creators( address _creator ) external OnlyAdmin {
        AuthorizedCreators[_creator] = false;

        emit removedCreator(_creator);
    }
    
    //data type for project details.
    struct project {
        address creator;
        string name;
        string description;
        uint fundingGoal;
        uint deadline;
        uint amountRaised;
        bool funded;
        address highest_Funder;      
        uint highest_contribution;
        bool failed_projects;
        bool status_processed;
    }
    
    mapping (uint => bool) project_results;

    // projctID => project details
    mapping (uint => project) public Projects;

    // projectID => userAddress => contributions
    mapping (uint => mapping (address => uint)) public Contributions;

    // projectID => whether the id is used or not
    mapping (uint => bool) isIdUsed;

    uint[] projectIDs;

    // events 
    event ProjectCreated(uint indexed projectID , address indexed creator , string name , string description , uint fundingGoal , uint deadline);
    event funded(uint indexed projectID , address contributor , uint amount , uint refund);
    event userWithdrawn(uint indexed projectID , address withdrawer , uint amount);
    event creatorWithdrawn(uint indexed projectID , address withdrawer , uint amount );
    event UserEarlyWithdraw( address indexed user , uint indexed _projectID , uint amount );

    // creating the 'project create' function
    function createProject(string memory _name , string memory _description , uint _fundingGoal , uint _durationSeconds , uint _id) external {
        require(!isIdUsed[_id], "Project ID is already in use!" );
        require(AuthorizedCreators[msg.sender] , "Only Authorized creators can access!!");
        isIdUsed[_id] = true;
        Projects[_id] = project({
            creator : msg.sender,
            name: _name,
            description: _description,
            fundingGoal: _fundingGoal,
            deadline: block.timestamp + _durationSeconds,
            amountRaised: 0,
            funded: false,
            highest_Funder: address(0),
            highest_contribution:0,
            failed_projects: false,
            status_processed: false
        });
        TotalProjects++;    
        projectIDs.push(_id);
        emit ProjectCreated(_id , msg.sender , _name , _description , _fundingGoal , block.timestamp+_durationSeconds);
    }

    // creating the 'fund the project' function
        function fundProject(uint _projectID) external payable nonReentrant {
            project storage Project = Projects[_projectID];
            require(block.timestamp<=Project.deadline , "Project deadline is over!");
            require(!Project.funded , "Project Reached its Funding requirement");
            require(msg.value>0 , "send some ether to contribute in the project");
            require(msg.value <= Project.fundingGoal, "Amount Contributed is more than Goal");
            uint remaining = Project.fundingGoal - Project.amountRaised;     
            uint amountToAccept;
            uint refund;
            if(msg.value > remaining) {
                amountToAccept = remaining;
                refund = msg.value - remaining;
            } else {
                amountToAccept = msg.value;
                refund = 0;
            }
            uint commission = (amountToAccept * 5) / 100;   
            uint netAmount = amountToAccept - commission;
            systemCommission += commission;
            Project.amountRaised += netAmount;
            Contributions[_projectID][msg.sender] = netAmount;
            // task 2 (line 150)
            TotalRaisedFunding+=netAmount;
            if (refund > 0) {                        
                (bool sent, ) = payable(msg.sender).call{value: refund}("");
                require(sent , "Refund Failed");
            }
            uint userTotal = Contributions[_projectID][msg.sender];
            if (userTotal > Project.highest_contribution) {
                Project.highest_contribution = userTotal;
                Project.highest_Funder = msg.sender;
            }

            emit funded(_projectID, msg.sender, amountToAccept , refund);

            if (Project.amountRaised>=Project.fundingGoal && !Project.status_processed) {
                Project.funded = true;
                Project.status_processed = true;
                Successful_Funded_Projects++;
            }
        }

        function UpdateProjectStatus() public {
            for (uint i = 0; i < projectIDs.length; i++) {
                uint projectID = projectIDs[i];
                project storage Project = Projects[projectID];
                if (!Project.status_processed && block.timestamp >= Project.deadline) {
                    Project.status_processed = true;
                    if (Project.amountRaised >= Project.fundingGoal && block.timestamp >= Project.deadline) {
                        if (!Project.funded) {
                            Project.funded = true;
                            Successful_Funded_Projects++;
                        }
                    } else {
                        Project.failed_projects = true;
                        Failed_Funded_Projects++;
                    }
                }
            }
        }

        function GetProjectStatus() view public returns(uint Successfully_Funded_Projects , uint Failed_To_Fund_Projects) {
            return (Successful_Funded_Projects, Failed_Funded_Projects);
        }
            
        function Get_Total_Raised_Funding() view public returns(uint) {
            return TotalRaisedFunding;
        }

        // function to get overall projects statistics
        function ProjectStatistics() public view returns(
        uint totalProjects,
        uint successfulProjects,
        uint failedProjects,
        uint activeProjects,
        uint totalFundsRaised
    ) {
        return (
            TotalProjects,
            Successful_Funded_Projects,
            Failed_Funded_Projects,
            TotalProjects - Successful_Funded_Projects - Failed_Funded_Projects,
            TotalRaisedFunding
        );
    }

    // withdrawing fund = user
    function userWithdraw(uint _projectID) external payable {
        project storage Project = Projects[_projectID];
        require(Project.amountRaised<Project.fundingGoal , "Funding goal has reached , user can't withdraw");
        uint fundsContributed = Contributions[_projectID][msg.sender];
        require(fundsContributed > 0, "No funds to withdraw");

        bool wasPreviouslyFunded = Project.funded;

        Project.amountRaised -= fundsContributed;
        Contributions[_projectID][msg.sender] -= fundsContributed;
        TotalRaisedFunding -= fundsContributed;

        if (wasPreviouslyFunded && Project.amountRaised < Project.fundingGoal) {
            Project.funded = false;
            Project.status_processed = false; // Allow re-evaluation at deadline
            if (Successful_Funded_Projects > 0) {
                Successful_Funded_Projects--;
            }
        }

        (bool sent, ) = payable(msg.sender).call{value: fundsContributed}("");
        require(sent , "Withdrawal Failed");


        emit userWithdrawn(_projectID, msg.sender, fundsContributed);
        
    }

    // withdrawing funds = project creator
    function creatorWithdraw(uint _projectID) external payable {
        project storage Project = Projects[_projectID];
        uint totalfunding = Project.amountRaised;
        require(Project.funded , "funding goal has not reached , admin can't withdraw");
        require(Project.creator == msg.sender , "only admin can withdraw");
        require(Project.deadline<=block.timestamp , "deadline has not reached , admin can't withdraw");
        payable(msg.sender).transfer(totalfunding);

        emit creatorWithdrawn(_projectID, msg.sender, msg.value);
    }

      function Time_Left(uint projectID) view public returns(uint) {
        project storage Project = Projects[projectID];
        if (block.timestamp >= Project.deadline) {
            return 0;
        } else {
            return(Project.deadline - block.timestamp);
        }
      }


    function Remaining_Fund(uint projectID) public view returns(uint fundingGoal , uint remainingFund) {
         project storage Project = Projects[projectID];
        fundingGoal = Project.fundingGoal;
        require(Project.creator != address(0), "project has not been created yet!");
        if (Project.amountRaised >= Project.fundingGoal) {
             remainingFund = 0;
        } else {
            remainingFund = Project.fundingGoal - Project.amountRaised;
        }
    }

    function Extend_Deadline(uint _projectID , uint _deadline) external {
        project storage Project = Projects[_projectID];
        require(Project.creator == msg.sender , "Only Project creator can extend the deadline!!");
        Project.deadline += _deadline;
    }

    function Change_FundingGoal( uint _projectID , uint Change_Goal) external {
         project storage Project = Projects[_projectID];
        require(Project.deadline > 0 , "Deadline is over , you Can't change the funding goal !!");
        require(Project.creator == msg.sender , "You are not the project creator , Only Porject creator can Change !!");

        Project.fundingGoal = Change_Goal;
    }

    function Funding_Raised_Percentage( uint _projectID ) public view  returns(uint) {
        project storage Project = Projects[_projectID];
        uint Raised_Percentage = ( Project.amountRaised*100 ) / Project.fundingGoal;
        return Raised_Percentage;
    }

    function userEarlyWithdraw( uint _projectID , uint withdrawn_amount) external payable {
        project storage Project = Projects[_projectID];
        require(block.timestamp < Project.deadline, "Cannot withdraw after deadline");
        uint contributed_amount = Contributions[_projectID][msg.sender];
        require(contributed_amount > 0 , "No Funds to withdraw!!");
        require(withdrawn_amount <= contributed_amount , "Withdraw amount exceeds your contribution");

        bool wasPreviouslyFunded = Project.funded;

        // updating the state var before sending funds
        Project.amountRaised -= withdrawn_amount;
        Contributions[_projectID][msg.sender] -= withdrawn_amount;
        TotalRaisedFunding -= withdrawn_amount;

        if (wasPreviouslyFunded && Project.amountRaised < Project.fundingGoal) {
            Project.funded = false;
            Project.status_processed = false; // Allow re-evaluation at deadline
            if (Successful_Funded_Projects > 0) {
                Successful_Funded_Projects--;
            }
        }

        // sending funds to user
        (bool sent, ) = payable(msg.sender).call{value : withdrawn_amount}("");
        require(sent , "withdraw failed!!!!");

        emit UserEarlyWithdraw(msg.sender, _projectID, withdrawn_amount);
    }

    function AdminWithdrawCommission() external OnlyAdmin {
        require(systemCommission > 0 , "No commission to withdraw");
        uint amount = systemCommission;
        systemCommission = 0;

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent , "Withdrawal Failed!");
    }
}