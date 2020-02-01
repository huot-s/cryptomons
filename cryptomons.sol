pragma solidity ^0.5.0;


contract CryptoMons {

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

    address[] private _tokenOwner;
    mapping (uint256 => uint256) private _ownedTokensIndex;
    mapping (address => uint256[]) private _ownedTokens;
    mapping (address => uint256) private _ownedTokensCount;

    mapping (address => uint256) private _pokeballSupply;

    mapping (uint256 => Pokemon) private _tokenStats;
    
    mapping (uint256 => bool) private _tokenOnMarket;
    mapping (uint256 => uint256) private _marketTokensIndex;
    uint256[] private _marketPrices;
    uint256[] private _marketTokens;

    mapping (address => uint256) private _pendingWithdrawals;

    address private _admin;
    uint256 private _totalSupply = 0;
    uint256 private _marketSupply = 0;

    mapping (address => bool) private _ownerIsBreeding;
    mapping (uint256 => bool) private _tokenIsBreeding;
    mapping (address => Breeding) private _breedParam;


    constructor () public {
        _admin = msg.sender;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "zero address");
        return _ownedTokensCount[owner];
    }
    function ownerOf(uint256 tokenId) public view returns (address) {
        require(tokenId < _totalSupply, "token does not exists");
        address owner = _tokenOwner[tokenId];
        return owner;
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function marketSupply() public view returns (uint256) {
        return _marketSupply;
    }
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns(uint256) {
        require(balanceOf(owner) > index, "invalid index");
        return _ownedTokens[owner][index];
    }
    function tokenOfMarketByIndex(uint256 index) public view returns(uint256) {
        require(index < _marketSupply, "invalid index");
        return _marketTokens[index];
    }
    function priceOfMarketByIndex(uint256 index) public view returns(uint256) {
        require(index < _marketSupply, "invalid index");
        return _marketPrices[index];
    }
    function isOnMarket(uint256 tokenId) public view returns(bool) {
        return _tokenOnMarket[tokenId];
    }
    function tokenIsBreeding(uint256 tokenId) public view returns(bool){
        return _tokenIsBreeding[tokenId];
    }
    function ownerIsBreeding(address owner) public view returns(bool){
        return _ownerIsBreeding[owner];
    }
    function pendingWithdrawals(address owner) public view returns(uint256) {
        return _pendingWithdrawals[owner];
    }
    function tokenStats(uint256 tokenId) public view returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256,Type) {
        Pokemon memory token = _tokenStats[tokenId];
        return (token.pokedexIndex, token.hp, token.atk, token.def, token.lvl, token.breedingBlock, token.gender, token.elementType);
    }
    function blocksRemaining() public view returns (int256) {
        require(ownerIsBreeding(msg.sender), "you must be breeding");
        return int(_breedParam[msg.sender].hatchBlock) - int(block.number);
    }
    function pokeballSupply(address owner) public view returns(uint256) {
        return _pokeballSupply[owner];
    }

    function mint(address to, uint256 pokedexIndex, uint256 hp, uint256 atk, uint256 def, uint256 gender, Type elementType) public {
        require(msg.sender == _admin, "you must be admin to mint");
        uint256 tokenId = _totalSupply;
        _mint(to);
        _tokenStats[tokenId] = Pokemon(pokedexIndex, hp, atk, def, 0, 20, gender, elementType);
        _addTokenToOwnerEnumeration(to, tokenId);
    }
    function putOnMarket(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "you must be the owner of the token");
        require(price > 0, "must be positive price");
        require(!isOnMarket(tokenId), "this token is already on the market");
        require(!tokenIsBreeding(tokenId), "can't sell a token that is breeding");

        _addTokenToMarketEnumeration(tokenId, price);
        _tokenOnMarket[tokenId] = true;
        _marketSupply++;
    }
    function takeOffMarket(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "you must be the owner of the token");
        require(isOnMarket(tokenId), "this token is not on the market");
        _removeTokenFromMarketEnumeration(tokenId);
        _marketSupply--;
        _tokenOnMarket[tokenId] = false;
    }
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
    function give(address to, uint256 tokenId) public {
        require (msg.sender == ownerOf(tokenId), "you must be the owner of the token");
        require(!isOnMarket(tokenId), "you can't give a token that is on market");
        require(!tokenIsBreeding(tokenId), "you can't give a token that is breeding");
        _transferFrom(msg.sender, to, tokenId);
    }
    function withdraw() public {
        uint256 amount = _pendingWithdrawals[msg.sender];
        _pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
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
    function buyPokeball() external payable {
        require(msg.value == 0.5 ether, "a pokeball costs 0.5 ether");
        _pokeballSupply[msg.sender]++;
        _pendingWithdrawals[_admin] += 0.5 ether;
    }
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
