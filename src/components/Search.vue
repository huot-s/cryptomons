<template>
  <v-container>
    <v-simple-table>
      <thead>
        <tr>
          <th width="20px"></th>
          <th class="text-left">Name</th>
          <th class="text-center">Type</th>
          <th class="text-center">HP</th>
          <th class="text-center">ATK</th>
          <th class="text-center">DEF</th>
          <th class="text-center">LVL</th>
          <th class="text-center">Gender</th>
          <th class="text-left">Actions</th>
          
        </tr>
      </thead>

      <tbody>
        <tr v-for="token in allToken" v-bind:key="token.id">
          <td class="text-right"><v-img class="d-inline-block" v-bind:src="require('@/assets/sprites/medium/'+token.sprite.padStart(3,'0')+'.png')"></v-img></td>
          <td>
            <span class="subtitle-1">{{ token.name }} - #{{ token.id }} </span>
            <v-chip v-if="token.onMarket" x-small color="purple" class="ml-3" outlined label>on market</v-chip>
            <v-chip v-if="token.onBreeding" x-small color="green" class="ml-3" outlined label>breeding</v-chip>
            <v-chip v-if="token.sprite >= 122 || (token.hp*token.atk + 5*token.lvl + parseInt(token.def) > 1000)" label class="ml-3" color="red" x-small outlined>rare</v-chip>
            <p class="caption">owner <a target="_blank" :href="'https://ropsten.etherscan.io/address/'+token.owner">{{token.owner}}</a></p>
          </td>
          <td class="text-center">{{token.element != 0 ? (token.element == 1 ? '💦': '🌿') : '🔥'}}</td>
          <td class="text-center">{{ token.hp }}</td>
          <td class="text-center">{{ token.atk }}</td>
          <td class="text-center">{{ token.def }}</td>
          <td class="text-center">{{ token.lvl }}</td>
          <td class="text-center">{{token.gender == 0 ? 'Male ♂️' : 'Female ♀️'}}</td>
          <td>
            <v-btn v-on:click.stop="fightMenu(token)" :disabled="token.isOwner" outlined >Fight</v-btn>
          </td>
          
        </tr>
      </tbody>
    </v-simple-table>

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
    fightDialog: false,
    fighterDEF: {id:0, hp:null, atk:null, sprite:1},
    fighterATK: null,
  }),

  methods: {
    fightMenu: function (token) {
      this.fightDialog = true
      this.fighterDEF = token
    },
    sendFight: function() {
      this.$store.dispatch('fight', {off: this.fighterATK.id, def: this.fighterDEF.id})
      this.fightDialog = false
    },
  }
};
</script>
