import Vue from 'vue'
import Vuex from 'vuex'
import crtInterface from '@/assets/contract.json'
import Web3 from 'web3'

Vue.use(Vuex)

const names = ["Bulbasaur","Ivysaur","Venusaur","Charmander","Charmeleon","Charizard","Squirtle","Wartortle","Blastoise","Caterpie","Metapod","Butterfree","Weedle","Kakuna","Beedrill","Pidgey","Pidgeotto","Pidgeot","Rattata","Raticate","Spearow","Fearow","Ekans","Arbok","Pikachu","Raichu","Sandshrew","Sandslash","Nidoran♀","Nidorina","Nidoqueen","Nidoran♂","Nidorino","Nidoking","Clefairy","Clefable","Vulpix","Ninetales","Jigglypuff","Wigglytuff","Zubat","Golbat","Oddish","Gloom","Vileplume","Paras","Parasect","Venonat","Venomoth","Diglett","Dugtrio","Meowth","Persian","Psyduck","Golduck","Mankey","Primeape","Growlithe","Arcanine","Poliwag","Poliwhirl","Poliwrath","Abra","Kadabra","Alakazam","Machop","Machoke","Machamp","Bellsprout","Weepinbell","Victreebel","Tentacool","Tentacruel","Geodude","Graveler","Golem","Ponyta","Rapidash","Slowpoke","Slowbro","Magnemite","Magneton","Farfetch'd","Doduo","Dodrio","Seel","Dewgong","Grimer","Muk","Shellder","Cloyster","Gastly","Haunter","Gengar","Onix","Drowzee","Hypno","Krabby","Kingler","Voltorb","Electrode","Exeggcute","Exeggutor","Cubone","Marowak","Hitmonlee","Hitmonchan","Lickitung","Koffing","Weezing","Rhyhorn","Rhydon","Chansey","Tangela","Kangaskhan","Horsea","Seadra","Goldeen","Seaking","Staryu","Starmie","Mr. Mime","Scyther","Jynx","Electabuzz","Magmar","Pinsir","Tauros","Magikarp","Gyarados","Lapras","Ditto","Eevee","Vaporeon","Jolteon","Flareon","Porygon","Omanyte","Omastar","Kabuto","Kabutops","Aerodactyl","Snorlax","Articuno","Zapdos","Moltres","Dratini","Dragonair","Dragonite","Mewtwo","Mew"];
const CONTRACT_ADDRESS = '0x39dd6caa6213195833EeeBc6925B8A8C378E3Ba4'


var store = new Vuex.Store({
  state: {
    market: [],
    accountToken: [],
    allToken: [],
    account: [
      {name: "Address", value: "xxxxx"},
      {name: "Balance", value: "xxxx ether"},
      {name: "Tokens owned", value: "xx"},
      {name: "Pending withdrawal", value: "xxxxx wei"},
      {name: "Remaing breeding block", value: "Not breeding"},
      {name: "Remaing breeding time", value: "Not breeding"}
    ],
    web3: null,
    crt: null
  },

  mutations: {
    emptyMarket(state) {
      state.market = []
    },
    addTokenToMarket(state, payload) {
      state.market.push(payload)
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
    },
    addTokenToAccount(state, payload) {
      state.accountToken.push(payload)
    },
    addAllToken(state, payload) {
      state.allToken.push(payload)
    }
  },

  actions: {
    async updateMarket({commit, state}) { 
      commit('emptyMarket')
      const supply = await state.crt.methods.getMarketSupply().call()
      for (var i = 0; i < supply; i++) {
        const object = await state.crt.methods.getMarketTokenByIndex(i).call()
        const price = object[0]
        const tokenId = object[1]        
        let attributes = await state.crt.methods.getTokenAttribute(tokenId).call()
        let addressOwner = await state.crt.methods.ownerOf(tokenId).call()
        commit('addTokenToMarket', {
          sprite: attributes[2],
          hp: attributes[0], 
          atk: attributes[1], 
          lvl: attributes[3], 
          price: price, 
          name: names[attributes[2]-1], 
          id: tokenId,
          isOwner: addressOwner.toUpperCase() == state.account[0].value.toUpperCase()
        })        
      }
    },
    async updateAccountToken({commit, state}) { 
      const supply = await state.crt.methods.balanceOf(state.account[0].value).call()
      for (var i = 0; i < supply; i++) {
        const tokenId = await state.crt.methods.getOwnedTokenbyIndex(i).call()        
        let attributes = await state.crt.methods.getTokenAttribute(tokenId).call()
        let onMarket = await state.crt.methods.isOnSale(tokenId).call()
        let onBreeding = await state.crt.methods.tokenIsOnBreeding(tokenId).call()
        commit('addTokenToAccount', {
          sprite: attributes[2], 
          hp: attributes[0], 
          atk: attributes[1], 
          lvl: attributes[3], 
          name: names[attributes[2]-1], 
          id: tokenId,
          onMarket: onMarket,
          onBreeding: onBreeding
        })        
      }
    },
    async updateAllToken({commit, state}) { 
      const supply = await state.crt.methods.getTotalSupply().call()
      for (var i = 0; i < supply; i++) {      
        let attributes = await state.crt.methods.getTokenAttribute(i).call()
        let owner = await state.crt.methods.ownerOf(i).call()
        let onMarket = await state.crt.methods.isOnSale(i).call()
        let onBreeding = await state.crt.methods.tokenIsOnBreeding(i).call()
        let addressOwner = await state.crt.methods.ownerOf(i).call()
        commit('addAllToken', {
          sprite: attributes[2], 
          hp: attributes[0], 
          atk: attributes[1], 
          lvl: attributes[3], 
          name: names[attributes[2]-1], 
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
      const pendingWithdrawal = await state.crt.methods.getPendingWithdrawal().call({from: state.account[0].value})
      const isBreeding = await state.crt.methods.playerIsBreeding(state.account[0].value).call()
      var breedingTime = 'Not breeding'
      var breedingBlock = 'Not breeding'
      if (isBreeding) {
        breedingBlock = await state.crt.methods.getBlockRemaining().call({from: state.account[0].value})
        breedingTime = 'approx ' + breedingBlock * 15 + ' sec'
      }
       
      const payload = {balance: balance, tokenNum: tokenNum, pendingWithdrawal: pendingWithdrawal, breedingBlock: breedingBlock, breedingTime: breedingTime}
      commit('getAccountStat', payload)
    },
    async buy({state}, payload) {
      state.crt.methods.buy(payload.id).send({from: state.account[0].value, value: payload.p})
    },
    async fight({state}, payload) {
      state.crt.methods.fight(payload.off, payload.def).send({from: state.account[0].value})
    },
    withdraw({state}) {
      state.crt.methods.withdraw().send({from: state.account[0].value})
    },
    takeBack({state}, payload) {
      state.crt.methods.takeOffMarket(payload).send({from: state.account[0].value})
    },
    sell({state}, payload) {
      state.crt.methods.putOnSale(payload.id, state.web3.utils.toHex(parseInt(payload.price*1e18))).send({from: state.account[0].value})
    },
    breed({state}, payload) {
      state.crt.methods.breed(payload.tokenIdA, payload.tokenIdB).send({from: state.account[0].value})
    },
    hatch({state}) {
      state.crt.methods.hatch().send({from: state.account[0].value})
    }
  },

  modules: {
  }
})

store.dispatch('initWeb3').then(() => {
  store.dispatch('updateMarket')
  store.dispatch('updateAccountToken')
  store.dispatch('updateAccountStat')
  store.dispatch('updateAllToken')
})

export default store