pragma solidity ^0.5.0;


contract CryptoMons {

    // Helper structures for pokemon attributes and breeding
    enum Type {fire, water, grass}

    struct Pokemon {
        uint256 pokedexIndex;
        uint256 hp;
        uint256 atk;
        uint256 def;
        uint256 lvl;
        uint256 breedingBlock;
        uint256 gender;
        Type elementType;
    }

    struct Breeding {
        uint256 tokenIdA;
        uint256 tokenIdB;
        uint256 hatchBlock;
    }

    // Tracks the ownership of the tokens
    address[] private _tokenOwner;
    mapping (uint256 => uint256) private _ownedTokensIndex;
    mapping (address => uint256[]) private _ownedTokens;
    mapping (address => uint256) private _ownedTokensCount;

    // Tracks how many Pokeball a player has
    mapping (address => uint256) private _pokeballSupply;

    // Mapping storing Pokemon attributes
    mapping (uint256 => Pokemon) private _tokenStats;

    // Models the Marketplace
    mapping (uint256 => bool) private _tokenOnMarket;
    mapping (uint256 => uint256) private _marketTokensIndex;
    uint256[] private _marketPrices;
    uint256[] private _marketTokens;

    // Uselfull to setup a withdrawal pattern for security
    mapping (address => uint256) private _pendingWithdrawals;

    // Some variables to know the admin of the contract and the supplies
    address private _admin;
    uint256 private _totalSupply = 0;
    uint256 private _marketSupply = 0;

    // Helps to manage breeding
    mapping (address => bool) private _ownerIsBreeding;
    mapping (uint256 => bool) private _tokenIsBreeding;
    mapping (address => Breeding) private _breedParam;

    // the address instanciating the contract is the admin
    constructor () public {
        _admin = msg.sender;
    }

    // given an address, returns the number of tokens owned
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "zero address");
        return _ownedTokensCount[owner];
    }

    // given an tokenId, returns the address of the account owning it
    function ownerOf(uint256 tokenId) public view returns (address) {
        require(tokenId < _totalSupply, "token does not exists");
        address owner = _tokenOwner[tokenId];
        return owner;
    }

    // simply returns the total supply of token
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // simply returns the number of token that are on the market
    function marketSupply() public view returns (uint256) {
        return _marketSupply;
    }

    // given an address and an index, returns the the tokenId of the address at position index
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns(uint256) {
        require(balanceOf(owner) > index, "invalid index");
        return _ownedTokens[owner][index];
    }

    // given an index, returns the tokenId at position index in the market
    function tokenOfMarketByIndex(uint256 index) public view returns(uint256) {
        require(index < _marketSupply, "invalid index");
        return _marketTokens[index];
    }

    // given an index, returns the price at position index in the market
    function priceOfMarketByIndex(uint256 index) public view returns(uint256) {
        require(index < _marketSupply, "invalid index");
        return _marketPrices[index];
    }

    // given a tokenId, returns if the token is on the market
    function isOnMarket(uint256 tokenId) public view returns(bool) {
        return _tokenOnMarket[tokenId];
    }

    // given a tokenId, returns if the token is breeding
    function tokenIsBreeding(uint256 tokenId) public view returns(bool){
        return _tokenIsBreeding[tokenId];
    }

    // given an address, returns whether the player is currently breeding or not
    function ownerIsBreeding(address owner) public view returns(bool){
        return _ownerIsBreeding[owner];
    }

    // given an address, returns how much this person can withdraw to his account
    function pendingWithdrawals(address owner) public view returns(uint256) {
        return _pendingWithdrawals[owner];
    }

    // given a tokenId, returns the attributes of the token
    function tokenStats(uint256 tokenId) public view returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256,Type) {
        Pokemon memory token = _tokenStats[tokenId];
        return (token.pokedexIndex, token.hp, token.atk, token.def, token.lvl, token.breedingBlock, token.gender, token.elementType);
    }

    // returns how many blocks the player has to wait before hatching
    function blocksRemaining() public view returns (int256) {
        require(ownerIsBreeding(msg.sender), "you must be breeding");
        return int(_breedParam[msg.sender].hatchBlock) - int(block.number);
    }

    // given an address returns how many pokeball the player has
    function pokeballSupply(address owner) public view returns(uint256) {
        return _pokeballSupply[owner];
    }

    // only callable by the address _admin
    // creates a new token from scratch
    function mint(address to, uint256 pokedexIndex, uint256 hp, uint256 atk, uint256 def, uint256 gender, Type elementType) public {
        require(msg.sender == _admin, "you must be admin to mint");
        uint256 tokenId = _totalSupply;
        _mint(to);
        _tokenStats[tokenId] = Pokemon(pokedexIndex, hp, atk, def, 0, 20, gender, elementType);
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    // puts a token on the market for a certain price
    // only the owner of the token can perform this action
    // a token already on market or already breeding can't be put on market
    function putOnMarket(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "you must be the owner of the token");
        require(price > 0, "must be positive price");
        require(!isOnMarket(tokenId), "this token is already on the market");
        require(!tokenIsBreeding(tokenId), "can't sell a token that is breeding");

        _addTokenToMarketEnumeration(tokenId, price);
        _tokenOnMarket[tokenId] = true;
        _marketSupply++;
    }

    // function to take back a token (remove from the market)
    // only callable by the owner of the token
    // the token must be on market to have an effect
    function takeOffMarket(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "you must be the owner of the token");
        require(isOnMarket(tokenId), "this token is not on the market");
        _removeTokenFromMarketEnumeration(tokenId);
        _marketSupply--;
        _tokenOnMarket[tokenId] = false;
    }

    // buy a token
    // the token must be on sale
    // the value sent must match the price in the market
    function buy(uint256 tokenId) external payable {
        require(isOnMarket(tokenId), "this token can't be bought");
        uint256 price = _marketPrices[_marketTokensIndex[tokenId]];
        require(price <= msg.value, "not enough money received");
        address previousOwner = ownerOf(tokenId);
        _transferFrom(previousOwner, msg.sender, tokenId);
        _removeTokenFromMarketEnumeration(tokenId);
        _marketSupply--;
        _tokenOnMarket[tokenId] = false;
        _pendingWithdrawals[previousOwner] += price;
    }

    // transfer the ownership of a token to someone else
    // only callable by the owner of the token
    function give(address to, uint256 tokenId) public {
        require (msg.sender == ownerOf(tokenId), "you must be the owner of the token");
        require(!isOnMarket(tokenId), "you can't give a token that is on market");
        require(!tokenIsBreeding(tokenId), "you can't give a token that is breeding");
        _transferFrom(msg.sender, to, tokenId);
    }

    // function to transfer the ETH accumulated by a player on pendingWithdrawal
    // msg.sender.transfer() is called after setting the balance to 0
    function withdraw() public {
        uint256 amount = _pendingWithdrawals[msg.sender];
        _pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    // function to breed two tokens
    // both tokens must be owned by the caller
    // the player must have no breeding running
    // the tokens can't be on market or already breeding
    function breed(uint256 tokenIdA, uint256 tokenIdB) public {
        require(ownerOf(tokenIdA) == msg.sender, "this is not your token");
        require(ownerOf(tokenIdB) == msg.sender, "this is not your token");
        require(!ownerIsBreeding(msg.sender), "you are already breeding");
        require(!isOnMarket(tokenIdA), "token on market");
        require(!isOnMarket(tokenIdB), "token on market");
        require(_tokenStats[tokenIdA].gender != _tokenStats[tokenIdB].gender, "must be different genders");

        _ownerIsBreeding[msg.sender] = true;
        _tokenIsBreeding[tokenIdA] = true;
        _tokenIsBreeding[tokenIdB] = true;

        uint256 blocks = _tokenStats[tokenIdA].breedingBlock + _tokenStats[tokenIdB].breedingBlock;
        _breedParam[msg.sender] = Breeding(tokenIdA, tokenIdB, block.number + blocks);
    }

    // hatch a egg have the breeding time is ellapsed
    // we just check that the player is breeding and that the egg is ready
    function hatch() public {
        require(ownerIsBreeding(msg.sender), "not breeding");
        require(_breedParam[msg.sender].hatchBlock <= block.number, "breeding not finished");
        
        uint256 tokenIdA = _breedParam[msg.sender].tokenIdA;
        uint256 tokenIdB = _breedParam[msg.sender].tokenIdB;
        Pokemon memory parentA = _tokenStats[tokenIdA];
        Pokemon memory parentB = _tokenStats[tokenIdB];

        _ownerIsBreeding[msg.sender] = false;
        _tokenIsBreeding[tokenIdA] = false;
        _tokenIsBreeding[tokenIdB] = false;

        uint256 tokenId = _totalSupply;
        _mint(msg.sender);
        _addTokenToOwnerEnumeration(msg.sender, tokenId);

        uint gender = uint(block.number + block.difficulty)%2;

        uint256 pokedexIndex = parentB.pokedexIndex;
        uint256 hp = parentB.hp;
        uint256 atk = parentA.atk;
        uint256 def = parentB.def;
        Type elementType = parentB.elementType;
        
        if(gender == 1){
            pokedexIndex = parentA.pokedexIndex;
            hp = parentB.hp;
            atk = parentB.atk;
            def = parentA.def;
            elementType = parentA.elementType;
        }

        if (uint(block.number + block.difficulty)%5 == 0) {
            pokedexIndex = (pokedexIndex + block.number)%122 + 1;
        }

        _tokenStats[tokenId] = Pokemon(pokedexIndex, hp, atk, def, 0, 20, gender, elementType);
        _tokenStats[tokenIdA].breedingBlock += 20;
        _tokenStats[tokenIdB].breedingBlock += 20;
    }

    // performs a fight between two tokens using the fight formula
    function fight(uint256 tokenIdATK, uint256 tokenIdDEF) public {
        require(ownerOf(tokenIdATK) == msg.sender, "not your token");
        require(!tokenIsBreeding(tokenIdATK), "can't attack with a breeding token");
        require(ownerOf(tokenIdDEF) != msg.sender, "can't attack your own token");

        Pokemon memory ATK = _tokenStats[tokenIdATK];
        Pokemon memory DEF = _tokenStats[tokenIdDEF];

        uint256 bonusATK = 1;
        uint256 bonusDEF = 1;
         
        if((uint(ATK.elementType)+1)%3 == uint(DEF.elementType)) {
            bonusDEF = 2;
        } else if((uint(DEF.elementType)+1)%3 == uint(ATK.elementType)) {
            bonusATK = 2;
        }

        if((ATK.atk*bonusATK - DEF.def)*ATK.hp + 5*ATK.lvl - (DEF.atk*bonusDEF - ATK.def + 5)*DEF.hp - 5*DEF.lvl > 0) {
            _tokenStats[tokenIdATK].lvl++;
            if(tokenIsBreeding(tokenIdDEF) && _breedParam[ownerOf(tokenIdDEF)].hatchBlock > block.number) {
                _tokenIsBreeding[_breedParam[ownerOf(tokenIdDEF)].tokenIdA] = false;
                _tokenIsBreeding[_breedParam[ownerOf(tokenIdDEF)].tokenIdB] = false;
                _ownerIsBreeding[ownerOf(tokenIdDEF)] = false;
            }
        }
    }

    // buy a pokeball to the contract
    function buyPokeball() external payable {
        require(msg.value == 0.5 ether, "a pokeball costs 0.5 ether");
        _pokeballSupply[msg.sender]++;
        _pendingWithdrawals[_admin] += 0.5 ether;
    }

    // opens a ball and mint a pokemon according to starter given in input
    function usePokeball(uint8 starter) public {
        require(_pokeballSupply[msg.sender] > 0, "you need to own pokeball");
        _pokeballSupply[msg.sender]--;
        uint256 tokenId = _totalSupply;
        Type element;
        if (starter%3 == 0) {
            element = Type.grass;
        } else if (starter%3 == 1) {
            element = Type.fire;
        } else {
            element = Type.water;
        }
        _mint(msg.sender);
        _tokenStats[tokenId] = Pokemon((starter%3)*3+1, 25, 5, 15, 0, 10, 0, element);
        _addTokenToOwnerEnumeration(msg.sender, tokenId);
 
    }

    // buy a starter pck to the contract
    function buyStarterPack() external payable {
        require(msg.value == 1.5 ether, "a pack costs 1.5 ether");
        _pokeballSupply[msg.sender]++;
        uint256 tokenId = _totalSupply;
        _mint(msg.sender);
        _mint(msg.sender);
        _tokenStats[tokenId] = Pokemon(25, 25, 5, 15, 0, 10, 0, Type.fire);
        _tokenStats[tokenId + 1] = Pokemon(15, 30, 8, 9, 0, 15, 1, Type.water);
        _addTokenToOwnerEnumeration(msg.sender, tokenId);
        _addTokenToOwnerEnumeration(msg.sender, tokenId + 1);
        _pendingWithdrawals[_admin] += 1.5 ether;
    }

    // Internal and private functions

    // transfers the ownership of a token
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(tokenId < _totalSupply, "nonexistent token");
        address owner = ownerOf(tokenId);
        require(owner == from, "transfer of token that is not own");
        require(to != address(0), "transfer to the zero address");

        _ownedTokensCount[from]--;
        _ownedTokensCount[to]++;

        _tokenOwner[tokenId] = to;

        _removeTokenFromOwnerEnumeration(from, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);

        //emit Transfer(from, to, tokenId);
    }

    function _mint(address to) internal {
        require(to != address(0), "mint to the zero address");
        _tokenOwner.push(to);
        _ownedTokensCount[to]++;
        _totalSupply++;

        //emit Transfer(address(0), to, tokenId);
    }
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }
    function _addTokenToMarketEnumeration(uint256 tokenId, uint256 price) private {
        _marketTokensIndex[tokenId] = _marketPrices.length;
        _marketPrices.push(price);
        _marketTokens.push(tokenId);
    }
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }
        _ownedTokens[from].pop();
    }
    function _removeTokenFromMarketEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _marketTokens.length - 1;
        uint256 tokenIndex = _marketTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _marketTokens[lastTokenIndex];
            uint256 lastPrice = _marketPrices[lastTokenIndex];
            _marketTokens[tokenIndex] = lastTokenId;
            _marketPrices[tokenIndex] = lastPrice;
            _marketTokensIndex[lastTokenId] = tokenIndex;
        }
        _marketTokens.pop();
        _marketPrices.pop();
    }
}
