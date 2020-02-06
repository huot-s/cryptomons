import Vue from 'vue'
import Vuex from 'vuex'
import crtInterface from '@/assets/contract.json'
import Web3 from 'web3'

Vue.use(Vuex)

const names = ["Bulbasaur","Ivysaur","Venusaur","Charmander","Charmeleon","Charizard","Squirtle","Wartortle","Blastoise","Caterpie","Metapod","Butterfree","Weedle","Kakuna","Beedrill","Pidgey","Pidgeotto","Pidgeot","Rattata","Raticate","Spearow","Fearow","Ekans","Arbok","Pikachu","Raichu","Sandshrew","Sandslash","Nidoran♀","Nidorina","Nidoqueen","Nidoran♂","Nidorino","Nidoking","Clefairy","Clefable","Vulpix","Ninetales","Jigglypuff","Wigglytuff","Zubat","Golbat","Oddish","Gloom","Vileplume","Paras","Parasect","Venonat","Venomoth","Diglett","Dugtrio","Meowth","Persian","Psyduck","Golduck","Mankey","Primeape","Growlithe","Arcanine","Poliwag","Poliwhirl","Poliwrath","Abra","Kadabra","Alakazam","Machop","Machoke","Machamp","Bellsprout","Weepinbell","Victreebel","Tentacool","Tentacruel","Geodude","Graveler","Golem","Ponyta","Rapidash","Slowpoke","Slowbro","Magnemite","Magneton","Farfetch'd","Doduo","Dodrio","Seel","Dewgong","Grimer","Muk","Shellder","Cloyster","Gastly","Haunter","Gengar","Onix","Drowzee","Hypno","Krabby","Kingler","Voltorb","Electrode","Exeggcute","Exeggutor","Cubone","Marowak","Hitmonlee","Hitmonchan","Lickitung","Koffing","Weezing","Rhyhorn","Rhydon","Chansey","Tangela","Kangaskhan","Horsea","Seadra","Goldeen","Seaking","Staryu","Starmie","Mr. Mime","Scyther","Jynx","Electabuzz","Magmar","Pinsir","Tauros","Magikarp","Gyarados","Lapras","Ditto","Eevee","Vaporeon","Jolteon","Flareon","Porygon","Omanyte","Omastar","Kabuto","Kabutops","Aerodactyl","Snorlax","Articuno","Zapdos","Moltres","Dratini","Dragonair","Dragonite","Mewtwo","Mew"];
const CONTRACT_ADDRESS = '0x1f95d3C245cF46c96637Bb016c4E0c1645485bf8'


// CREATION OF THE STORE (GLOBAL STATE FOR ALL THE COMPONENTS)
var store = new Vuex.Store({

  // global state containg all the tokens and their attributes, the web3 contract object, the player stats, etc
  state: {
    market: [],
    accountToken: [],
    allToken: [],
    receipt : false,
    hatchDialog: false,
    fightDialog: false,
    tx: {"transactionHash": "0"},
    account: [
      {name: "Address", value: null},
      {name: "Balance", value: null},
      {name: "Tokens owned", value: null},
      {name: "Pending withdrawal", value: null},
      {name: "Remaing breeding block", value: null},
      {name: "Remaing breeding time", value: null},
      {name: "Pokeball Supply", value: null}
    ],
    web3: null,
    crt: null
  },

  // functions that are called by actions of the store and modify the state
  mutations: {
    newFight(state) {
      state.fightDialog = true
    },
    newHatch(state) {
      state.hatchDialog = true
    },
    newReceipt(state, payload) {
      state.tx = payload
      state.receipt = true
    },
    addTokenToMarket(state, payload) {
      state.market.push(payload)
    },
    addTokenToAccount(state, payload) {
      state.accountToken.push(payload)
    },
    addAllToken(state, payload) {
      state.allToken.push(payload)
    },
    cleanMarket(state) {
      state.market = []
    },
    cleanAccountToken(state) {
      state.accountToken = []
    },
    cleanAllToken(state) {
      state.allToken = []
    },
    initWeb3(state, payload) {
      state.web3 = new Web3(window.ethereum)
      state.crt = new state.web3.eth.Contract(crtInterface, CONTRACT_ADDRESS, {from: payload})
      state.account[0].value = payload
    },
    getAccountStat(state, payload) {
      state.account[1].value = state.web3.utils.fromWei(payload.balance)
      state.account[2].value = payload.tokenNum
      state.account[3].value = payload.pendingWithdrawal
      state.account[4].value = payload.breedingBlock
      state.account[5].value = payload.breedingTime
      state.account[6].value = payload.pokeballSupply
    }
  },

  // functions that are called by our components and interact with the contract
  actions: {
    async updateMarket({commit, state}) { 
      commit('cleanMarket')
      const supply = await state.crt.methods.marketSupply().call()
      for (var i = 0; i < supply; i++) {
        const tokenId = await state.crt.methods.tokenOfMarketByIndex(i).call()
        const price = await state.crt.methods.priceOfMarketByIndex(i).call()     
        let attributes = await state.crt.methods.tokenStats(tokenId).call()
        let addressOwner = await state.crt.methods.ownerOf(tokenId).call()
        commit('addTokenToMarket', {
          sprite: attributes[0],
          hp: attributes[1], 
          atk: attributes[2],
          def: attributes[3], 
          lvl: attributes[4],
          breedingSpeed: attributes[5],
          gender: attributes[6],
          element: attributes[7], 
          price: price, 
          name: names[attributes[0]-1], 
          id: tokenId,
          isOwner: addressOwner.toUpperCase() == state.account[0].value.toUpperCase(),
          owner: addressOwner
        })        
      }
    },
    async updateAccountToken({commit, state}) { 
      commit('cleanAccountToken')
      const supply = await state.crt.methods.balanceOf(state.account[0].value).call()
      for (var i = 0; i < supply; i++) {
        const tokenId = await state.crt.methods.tokenOfOwnerByIndex(state.account[0].value, i).call()        
        let attributes = await state.crt.methods.tokenStats(tokenId).call()
        let onMarket = await state.crt.methods.isOnMarket(tokenId).call()
        let onBreeding = await state.crt.methods.tokenIsBreeding(tokenId).call()
        commit('addTokenToAccount', {
          sprite: attributes[0], 
          hp: attributes[1], 
          atk: attributes[2], 
          def: attributes[3],
          lvl: attributes[4], 
          name: names[attributes[0]-1], 
          breedingSpeed: attributes[5],
          gender: attributes[6],
          element: attributes[7],
          id: tokenId,
          onMarket: onMarket,
          onBreeding: onBreeding
        })        
      }
    },
    async updateAllToken({commit, state}) { 
      commit('cleanAllToken')
      const supply = await state.crt.methods.totalSupply().call()
      for (var i = 0; i < supply; i++) {      
        let attributes = await state.crt.methods.tokenStats(i).call()
        let owner = await state.crt.methods.ownerOf(i).call()
        let onMarket = await state.crt.methods.isOnMarket(i).call()
        let onBreeding = await state.crt.methods.tokenIsBreeding(i).call()
        let addressOwner = await state.crt.methods.ownerOf(i).call()
        commit('addAllToken', {
          sprite: attributes[0], 
          hp: attributes[1], 
          atk: attributes[2],
          def: attributes[3], 
          lvl: attributes[4],
          breedingSpeed: attributes[5],
          gender: attributes[6],
          element: attributes[7],  
          name: names[attributes[0]-1], 
          id: i,
          owner: owner,
          onMarket: onMarket,
          onBreeding: onBreeding,
          isOwner: addressOwner.toUpperCase() == state.account[0].value.toUpperCase()
        })        
      }
    },
    async initWeb3({commit}){
      const ac = await window.ethereum.enable()
      commit('initWeb3', ac[0])
    },
    async updateAccountStat({commit, state}) {
      const balance = await state.web3.eth.getBalance(state.account[0].value)
      const tokenNum = await state.crt.methods.balanceOf(state.account[0].value).call()
      const pendingWithdrawal = await state.crt.methods.pendingWithdrawals(state.account[0].value).call({from: state.account[0].value})
      const isBreeding = await state.crt.methods.ownerIsBreeding(state.account[0].value).call()
      var breedingTime = null
      var breedingBlock = null
      if (isBreeding) {
        breedingBlock = await state.crt.methods.blocksRemaining().call({from: state.account[0].value})
        breedingTime = 'approx ' + breedingBlock * 15 + ' sec'
      }
      const pokeballSupply = await state.crt.methods.pokeballSupply(state.account[0].value).call()       
      const payload = {balance: balance, tokenNum: tokenNum, pendingWithdrawal: pendingWithdrawal, breedingBlock: breedingBlock, breedingTime: breedingTime, pokeballSupply: pokeballSupply}
      commit('getAccountStat', payload)
    },
    async buy({state, commit, dispatch}, payload) {
      state.crt.methods.buy(payload.id).send({from: state.account[0].value, value: payload.p}).on('receipt', function(receipt) {
        commit('newReceipt', receipt)
        dispatch('updateMarket')
      })
    },
    async fight({state, commit, dispatch}, payload) {
      state.crt.methods.fight(payload.off, payload.def).send({from: state.account[0].value}).on('receipt', function() {
        commit('newFight')
        dispatch('updateAccountToken')
      })
    },
    withdraw({state, commit, dispatch}) {
      state.crt.methods.withdraw().send({from: state.account[0].value}).on('receipt', function(receipt) {
        commit('newReceipt', receipt)
        dispatch('updateAccountStat')
      })
    },
    takeBack({state, commit, dispatch}, payload) {
      state.crt.methods.takeOffMarket(payload).send({from: state.account[0].value}).on('receipt', function(receipt) {
        commit('newReceipt', receipt)
        dispatch('updateAccountToken')
        dispatch('updateMarket')
      })
    },
    sell({state, commit, dispatch}, payload) {
      state.crt.methods.putOnMarket(payload.id, state.web3.utils.toHex(parseInt(payload.price*1e18))).send({from: state.account[0].value}).on('receipt', function(receipt) {
        commit('newReceipt', receipt)
        dispatch('updateAccountStat')
        dispatch('updateAccountToken')
        dispatch('updateMarket')
      })
    },
    breed({state, commit, dispatch}, payload) {
      state.crt.methods.breed(payload.tokenA.id, payload.tokenB.id).send({from: state.account[0].value}).on('receipt', function(receipt) {
        commit('newReceipt', receipt)
        dispatch('updateAccountStat')
        dispatch('updateAccountToken')
      })
    },
    hatch({state, commit, dispatch}) {
      state.crt.methods.hatch().send({from: state.account[0].value}).on('receipt', function() {
        commit('newHatch')
        dispatch('updateAccountStat')
        dispatch('updateAccountToken')
      })
    },
    give({state, commit, dispatch}, payload) {
      state.crt.methods.give(payload.to, payload.id).send({from: state.account[0].value}).on('receipt', function(receipt) {
        commit('newReceipt', receipt)
        dispatch('updateAccountStat')
        dispatch('updateAccountToken')
      })
    },
    openBall({state, commit, dispatch}, payload) {
      state.crt.methods.usePokeball(payload).send({from: state.account[0].value}).on('receipt', function(receipt) {
        commit('newReceipt', receipt)
        dispatch('updateAccountStat')
        dispatch('updateAccountToken')
      })
    },
    buyPokeball({state, commit, dispatch}) {
      state.crt.methods.buyPokeball().send({from: state.account[0].value, value: 0.5*1e18}).on('receipt', function(receipt) {
        commit('newReceipt', receipt)
        dispatch('updateAccountStat')
      })
    },
    buyStarterPack({state, commit, dispatch}) {
      state.crt.methods.buyStarterPack().send({from: state.account[0].value, value: 1.5*1e18}).on('receipt', function(receipt) {
        commit('newReceipt', receipt)
        dispatch('updateAccountStat')
      })
    }
  },

  modules: {
  }
})


// INITIALIZE THE STORE CONTENT
store.dispatch('initWeb3').then(() => {
  store.dispatch('updateMarket') // load marker
  store.dispatch('updateAccountToken') // load account tokens
  store.dispatch('updateAccountStat') // load account stats
  store.dispatch('updateAllToken') // load the list of all tokens for the 'search' page
})

export default store