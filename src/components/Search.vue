<template>
  <v-container>
    <v-simple-table>
      <thead>
        <tr>
          <th width="20px"></th>
          <th class="text-left">Name</th>
          <th class="text-left">HP</th>
          <th class="text-left">ATK</th>
          <th class="text-left">LVL</th>
          <th class="text-left">Actions</th>
          
        </tr>
      </thead>

      <tbody>
        <tr v-for="token in allToken" v-bind:key="token.id">
          <td class="text-right"><v-img class="d-inline-block" v-bind:src="require('@/assets/sprites/medium/'+token.sprite.padStart(3,'0')+'.png')"></v-img></td>
          <td>
            <span class="subtitle-1">{{ token.name+' #'+token.id }} </span>
            <v-chip v-if="token.onMarket" x-small color="purple" outlined>on market</v-chip>
            <v-chip v-if="token.onBreeding" x-small color="green" outlined>breeding</v-chip>
            <p class="caption">owner <a target="_blank" :href="'https://ropsten.etherscan.io/address/'+token.owner">{{token.owner}}</a></p>
          </td>
          <td>{{ token.hp }}</td>
          <td>{{ token.atk }}</td>
          <td>{{ token.lvl }}</td>
          <td><v-btn v-on:click="fightMenu(token)" :disabled="token.isOwner" text>Fight</v-btn> </td>
          
        </tr>
      </tbody>
    </v-simple-table>

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
  name: 'Search',

    computed: {
    allToken () {
      return this.$store.state.allToken
    },
    accountToken () {
      return this.$store.state.accountToken
    }
  },

  data: () => ({
    fightPopUp: false,
    fighter: {id:0, hp:null, atk:null, sprite:1},
    opponent: null
  }),

  methods: {
    fightMenu: function (token) {
      this.fightPopUp = true
      this.fighter = token
    },
    sendFight: function() {
      this.$store.dispatch('fight', {off: this.opponent, def: this.fighter.id})
      this.fightPopUp = false
    }
  }
};
</script>
