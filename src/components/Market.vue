<template>
  <v-container class="text-center">
    <v-card class="ma-2 text-left d-inline-block" width="290" outlined align="center">
      <v-list-item two-line>
        <v-list-item-content>
          <v-list-item-title class="headline mb-1">Pokeball</v-list-item-title>              
          <div class="body-2">
            <v-chip x-small color="blue white--text" label>0.5 ETH only</v-chip>  
            <p>Buy some pokeballs to begin your adventure. Each ball contains one starter. Perfect to start a collection</p>
          </div>
        </v-list-item-content>    
        <v-list-item-avatar tile size="90" color="white"><v-img :src="require('@/assets/pokeball.png')"></v-img></v-list-item-avatar>
      </v-list-item>
      <v-card-actions>
        <v-btn text v-on:click="buyPokeball">Buy</v-btn>                          
      </v-card-actions>
    </v-card>

    <v-card class="ma-2 text-left d-inline-block" width="290" outlined align="center">
      <v-list-item two-line>
        <v-list-item-content>
          <v-list-item-title class="headline mb-1">Starter Pack</v-list-item-title>              
          <div class="body-2">
            <v-chip x-small color="blue white--text" label>1.5 ETH</v-chip>  
            <p>This amazing pack contains 1 pokeball and two Pokemons. We won't tell you what Pokemons are inside...</p>
          </div>
        </v-list-item-content>    
        <v-list-item-avatar tile size="90" color="white"><v-img :src="require('@/assets/bag.png')"></v-img></v-list-item-avatar>
      </v-list-item>
      <v-card-actions>
        <v-btn text v-on:click="buyStarterPack">Buy</v-btn>                          
      </v-card-actions>
    </v-card>


    <v-card v-for="token in market" v-bind:key="token.id" class="ma-2 d-inline-block text-left" width="290" outlined>
      <v-list-item two-line>
        <v-list-item-content>
          <v-list-item-title class="headline mb-1">{{token.name}}</v-list-item-title>
          <v-list-item-subtitle class="subtitle-2">Price: {{token.price/1e18}} ether</v-list-item-subtitle>  
          <div class="body-2">        
            <v-row no-gutters><v-col class="ma-1">❤️ {{token.hp}}</v-col><v-col class="ma-1">📈 {{token.lvl}}</v-col></v-row>
            <v-row no-gutters><v-col class="ma-1">💪 {{token.atk}}</v-col><v-col class="ma-1">🛡️ {{token.def}}</v-col></v-row>
            <v-row no-gutters><v-col class="ma-1">⌛ {{token.breedingSpeed}}</v-col><v-col class="ma-1">{{token.element != 0 ? (token.element == 1 ? '💦': '🌿') : '🔥'}}</v-col></v-row>
            <v-row no-gutters><v-col class="ma-1">{{token.gender == 0 ? 'Male ♂️' : 'Female ♀️'}}</v-col></v-row>
            <v-row no-gutters><v-col class="ma-1"><a target="_blank" :href="'https://ropsten.etherscan.io/address/'+token.owner">owner</a> {{token.isOwner ? '(YOU)' : ''}}</v-col></v-row>
          </div>
        </v-list-item-content>       

        <v-list-item-avatar tile size="90" color="white"><v-img v-bind:src="require('@/assets/sprites/large/'+token.sprite + '.png')"></v-img></v-list-item-avatar>
      </v-list-item>
      <v-card-actions>
        <v-btn color="primary" :disabled="token.isOwner" v-on:click="buy(token.id, token.price)" class="mx-2">Buy</v-btn>
        <v-btn v-on:click.stop="fightMenu(token)" :disabled="token.isOwner" outlined>Fight</v-btn>
        <v-chip v-if="token.sprite >= 122 || (token.hp*token.atk + 5*token.lvl + parseInt(token.def) > 1000)" class="ml-5" color="red" label outlined><v-icon left>mdi-fire</v-icon>RARE</v-chip>     
      </v-card-actions>
    </v-card>

    <v-dialog v-model="fightDialog" scrollable max-width="300px">
      <v-card style="height: 500px;">
        <v-card-title>Select opponent</v-card-title>
        <v-divider></v-divider>
        <v-card-text >
          <v-radio-group v-model="fighterATK" column>
            <v-radio v-for="tok in accountToken" :disabled="tok.onBreeding" :key="'#'+tok.id" :label="tok.name + (tok.onBreeding ? ' 🥚' : (tok.element != 0 ? (tok.element == 1 ? '💦': '🌿') : '🔥'))" :value="tok"></v-radio>                
          </v-radio-group>
        </v-card-text>

        <v-divider></v-divider>

        <div class="body-1 py-2 px-7">
          <v-row no-gutters>
            <v-col align="center" class="ma-1"><v-img width="50px" class="mx-auto" :src="require('@/assets/sprites/small/'+fighterDEF.sprite+'.png')"></v-img></v-col>
            <v-col></v-col>
            <v-col align="center" class="ma-1" ><v-img width="50px" class="mx-auto" :src="require('@/assets/sprites/small/'+fighterATK.sprite+'.png')" v-if="fighterATK != null"></v-img></v-col>
          </v-row>
          <v-row no-gutters >
            <v-col align="center" class="ma-1">{{fighterDEF.hp}}</v-col>
            <v-col align="center">❤️</v-col>
            <v-col align="center" class="ma-1"><span v-if="fighterATK != null">{{fighterATK.hp}}</span></v-col>
          </v-row>
          <v-row no-gutters >
            <v-col align="center" class="ma-1">{{fighterDEF.atk}}</v-col>
            <v-col align="center">💪</v-col>
            <v-col align="center" class="ma-1"><span v-if="fighterATK != null">{{fighterATK.atk}}</span></v-col>
          </v-row>
          <v-row no-gutters >
            <v-col align="center" class="ma-1">{{fighterDEF.def}}</v-col>
            <v-col align="center">🛡️</v-col>
            <v-col align="center" class="ma-1"><span v-if="fighterATK != null">{{fighterATK.hp}}</span></v-col>
          </v-row>
        </div>

        <v-divider></v-divider>
        <v-card-actions>
          <v-btn :disabled="fighterDEF == null || fighterATK == null" color="blue darken-1" text @click="sendFight">Fight</v-btn>
          <v-btn color="blue darken-1" text @click="fightDialog = false">Cancel</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
export default {
  name: 'Market',

  computed: {
    accountToken () {
      return this.$store.state.accountToken
    },
    market () {
      return this.$store.state.market
    }
  },

  data: () => ({
    fightDialog: false,
    fighterDEF: {id:0, hp:null, atk:null, sprite:1},
    fighterATK: null,
  }),

  methods: {
    buy: function(tokenId, price) {
      this.$store.dispatch('buy', {id: tokenId, p: price})
    },
    fightMenu: function (token) {
      this.fightDialog = true
      this.fighterDEF = token
    },
    sendFight: function() {
      this.$store.dispatch('fight', {off: this.fighterATK.id, def: this.fighterDEF.id})
      this.fightDialog = false
    },
    buyPokeball: function() {
      this.$store.dispatch('buyPokeball')
    },
    buyStarterPack: function() {
      this.$store.dispatch('buyStarterPack')
    }
  }
};
</script>
