<template>
  <v-container>
    <v-card outlined>
      <v-card-title class="headline mb-1">My Account</v-card-title>
      <v-divider></v-divider>
      <v-row no-gutters><v-col v-for="prop in account" v-bind:key="prop.name">
        <v-list-item two-line>
          <v-list-item-content>
              <v-list-item-title>{{prop.name}}</v-list-item-title>
              <v-list-item-subtitle>{{prop.name == 'Pending withdrawal' ? prop.value/1e18+' ether' : prop.value}}</v-list-item-subtitle>
          </v-list-item-content>
        </v-list-item>
      </v-col></v-row>

      <v-card-actions>
      <v-btn v-on:click="withdraw" :disabled="parseInt(account[3].value) == 0" width="200px" color="primary"> withdraw </v-btn>
      <v-btn v-on:click="breed" :disabled="account[4].value != 'Not breeding'" color="primary" width="200px"> breed </v-btn>
      <v-btn v-on:click="hatch" :disabled="account[4].value > 0 || account[4].value == 'Not breeding'" color="primary" width="200px"> hatch </v-btn>
      </v-card-actions>
    </v-card>

    <v-card v-for="token in accountToken" v-bind:key="token.id" v-bind:raised="breeding.tokenIdA == token.id || breeding.tokenIdB == token.id" class="ma-2 d-inline-block" width="290" outlined>
      <v-list-item two-line>
          <v-list-item-content>
              <v-list-item-title class="headline mb-1">{{token.name}}</v-list-item-title>
              
              <v-list-item-subtitle v-if="token.onMarket"><v-chip small color="purple" outlined>ON MARKET</v-chip></v-list-item-subtitle>
              <v-list-item-subtitle v-if="token.onBreeding"><v-chip small color="green" outlined>BREEDING</v-chip></v-list-item-subtitle>
              <v-list-item-subtitle>HP: {{token.hp}}</v-list-item-subtitle>
              <v-list-item-subtitle>ATK: {{token.atk}}</v-list-item-subtitle>
              <v-list-item-subtitle>LVL: {{token.lvl}}</v-list-item-subtitle>
          </v-list-item-content>
  
          <v-list-item-avatar tile size="90" color="white"><v-img v-bind:src="require('@/assets/sprites/large/'+token.sprite+'.png')"></v-img></v-list-item-avatar>
      </v-list-item>
  
      <v-card-actions v-if="selling!=token.id">
          <v-btn v-if="!token.onMarket" text v-on:click="priceBar(token.id)">Sell</v-btn>
          <v-btn v-if="token.onMarket" text v-on:click="takeBack(token.id)">Take back</v-btn>
          <v-btn :disabled="token.onMarket" text v-on:click="refreshBreeding(token.id)">Breed</v-btn>          
      </v-card-actions>
      <v-text-field v-if="selling==token.id" v-model="value" tile outlined label="amount" type="number" class="mx-2"></v-text-field>
      <v-card-actions v-if="selling==token.id">          
          <v-btn v-on:click="sell()" outlined color="primary">Confirm</v-btn>
          <v-btn v-on:click="priceBar(null)" outlined color="error">Cancel</v-btn>
      </v-card-actions>
      
  </v-card>
  </v-container>
</template>

<script>
export default {
  name: 'Account',

  computed: {
    accountToken () {
      return this.$store.state.accountToken
    },
    account () {
      return this.$store.state.account
    }
  },

  data: () => ({
    value: null,
    selling: null,
    breeding: {tokenIdA: null, tokenIdB: null},
    date: new Date()
  }),

  methods: {
    priceBar: function (id) {
      this.selling = id
    },
    sell: function () {
      this.$store.dispatch('sell',{id: this.selling, price: this.value})
    },
    refreshBreeding: function (tokenId) {
      if(this.breeding.tokenIdA != tokenId) {
        if(this.breeding.tokenIdB != tokenId) {
          if(this.breeding.tokenIdA == null) {
            this.breeding.tokenIdA = tokenId
          } else {
            this.breeding.tokenIdB = tokenId
          }          
        } else {
          this.breeding.tokenIdB = null
        }
      } else {
        this.breeding.tokenIdA = null
      }
    },
    withdraw: function() {
      this.$store.dispatch('withdraw')
    },
    takeBack: function(tokenId) {
      this.$store.dispatch('takeBack', tokenId)
    },
    breed: function() {
      if (this.breeding.tokenIdA != null && this.breeding.tokenIdB != null) {
        this.$store.dispatch('breed', this.breeding)
      }      
    },
    hatch: function() {
      this.$store.dispatch('hatch')
    }
  }
};
</script>
