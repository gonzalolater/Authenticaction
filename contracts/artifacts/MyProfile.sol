
contract Identity {

    struct BasicInfo {
        string name;
        string email;
    }
    struct PersonalInfo {
        uint256 salary;
        string _address;
    }
    enum UserType {
        Basic,
        Personal
    }

    error UserUnauthorized(address user, UserType userType);

    // Variables para guardar información de la cuenta
    BasicInfo private basicInfo;
    PersonalInfo private personalInfo;
    address private owner;

    // Mapping para otorgar permisos de lectura a otras cuentas
    mapping(address => bool) private basicUsers;
    mapping(address => bool) private personalUsers;

    constructor(string memory name, string memory email, uint256 salary, string memory _address) {
        basicInfo = BasicInfo(name, email);
        personalInfo = PersonalInfo(salary, _address);
        owner = msg.sender;
    }

    // Verificador de Autorización del usuario
    modifier authorizeUser(UserType userType) {
        if (msg.sender == owner || personalUsers[msg.sender]) {
            _;
        } else if (userType == UserType.Basic && basicUsers[msg.sender]) {
            _;
        } else {
            revert UserUnauthorized(msg.sender, userType);
        }
    }

    // Solo el owner puede otorgar permisos a otras cuentas
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can authorize users");
        _;
    }
    
    // Otorgamos permisos de lectura a otra cuenta
    function registerUser(UserType userType, address user) public onlyOwner {
        if (userType == UserType.Basic) {
            basicUsers[user] = true;
        } else if (userType == UserType.Personal) {
            personalUsers[user] = true;
        }
    }
    
    function getBasicInfo() public view authorizeUser(UserType.Basic) returns (BasicInfo memory) {
        return basicInfo;
    }

    function getPersonalInfo() public view authorizeUser(UserType.Personal) returns (PersonalInfo memory) {
        return personalInfo;
    }
}