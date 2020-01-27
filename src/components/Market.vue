<template>
  <v-container>
    <v-card v-for="token in market" v-bind:key="token.id" class="ma-2 d-inline-block" width="290" outlined>
      <v-list-item two-line>
        <v-list-item-content>
          <v-list-item-title class="headline mb-1">{{token.name}}</v-list-item-title>
          <v-list-item-subtitle class="subtitle-2">Price: {{token.price/1e18}} ether</v-list-item-subtitle>
          <v-list-item-subtitle>HP: {{token.hp}}</v-list-item-subtitle>
          <v-list-item-subtitle>ATK: {{token.atk}}</v-list-item-subtitle>
          <v-list-item-subtitle>LVL: {{token.lvl}}</v-list-item-subtitle>
        </v-list-item-content>
        <p class="font-weight-bold" v-if="token.isOwner">You are the owner of this token</p>

        <v-list-item-avatar tile size="90" color="white"><v-img v-bind:src="require('@/assets/sprites/large/'+token.sprite + '.png')"></v-img></v-list-item-avatar>
      </v-list-item>
      <v-card-actions>
        <v-btn color="primary" :disabled="token.isOwner" v-on:click="buy(token.id, token.price)" class="mx-2">Buy</v-btn>
        <v-btn v-on:click="fightMenu(token)" :disabled="token.isOwner" text>Fight</v-btn>       
      </v-card-actions>
    </v-card>
    <v-dialog v-model="fightPopUp" scrollable max-width="300px">
      <v-card>
        <v-card-title>Select opponent</v-card-title>
        <v-divider></v-divider>
        <v-card-text style="height: 400px;">
          <v-radio-group v-model="opponent" column>
            <v-radio v-for="tok in accountToken" :key="tok.name+tok.id" :label="tok.name+' (Power = '+tok.atk*tok.hp+')'" :value="tok.id"></v-radio>                
          </v-radio-group>
          <p class="text-center font-italic">Ennemi has a power of {{fighter.hp * (parseInt(fighter.atk) + 5)}}</p>
          <v-img width="50px" class="mx-auto" :src="require('@/assets/sprites/small/'+fighter.sprite+'.png')"></v-img>
        </v-card-text>
        <v-divider></v-divider>
        <v-card-actions>
          <v-btn :disabled="opponent == null || fighter == null" color="blue darken-1" text @click="sendFight">Fight</v-btn>
          <v-btn color="blue darken-1" text @click="fightPopUp = false">Cancel</v-btn>
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
    fightPopUp: false,
    fighter: {id:0, hp:null, atk:null, sprite:1},
    opponent: null
  }),

  methods: {
    buy: function(tokenId, price) {
      this.$store.dispatch('buy', {id: tokenId, p: price})
    },
    fightMenu: function (token) {
      this.fightPopUp = true
      this.fighter = token
    },
    sendFight: function() {
      console.log({off: this.opponent, def: this.fighter.id})
      this.$store.dispatch('fight', {off: this.opponent, def: this.fighter.id})
      this.fightPopUp = false
    }
  }
};
</script>
