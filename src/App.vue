<template>
  <v-app>
    <v-card height="100%">
      <v-card-title class="headline justify-center"> CryptoMons </v-card-title>
      <p class="text-center">
        <v-img class="d-inline-block mx-5" width="50px" :src="require('@/assets/jigglypuff.png')"></v-img>
        <v-img class="d-inline-block mx-5" width="50px" :src="require('@/assets/pokemon.png')"></v-img>
        <v-img class="d-inline-block mx-5" width="50px" :src="require('@/assets/pikachu.png')"></v-img>
      </p>
      
      <v-tabs fixed-tabs v-model="tab">
          <v-tab key="tab1"> Market </v-tab>
          <v-tab key="tab2"> My Account </v-tab>
          <v-tab key="tab3"> Search </v-tab>
      </v-tabs>
  
      <v-tabs-items v-model="tab">
          <v-tab-item key="tab1">
              <Market></Market>
          </v-tab-item>

          <v-tab-item key="tab2">
              <Account></Account>
          </v-tab-item>

          <v-tab-item key="tab3">
              <Search></Search>
          </v-tab-item>
      </v-tabs-items>
    
    </v-card>

    <v-snackbar v-model="receipt" color="success" :timeout="0">
      <span>Transaction confirmed, see details  <a target="_blank" class="white--text" :href="'https://ropsten.etherscan.io/tx/'+tx['transactionHash']"> HERE </a></span>
      <v-btn text @click="receipt = false">Close</v-btn>
    </v-snackbar>

    <v-dialog v-model="hatchDialog" max-width="300px">
      <v-card >
        <v-card-title>Your egg hatched !</v-card-title>
        <v-divider></v-divider>
        <v-card-text >
          <v-img class="mx-auto my-5" width="100" :src="require('@/assets/egg_open.png')"></v-img>
          <p>Go to your account and discover your new Cryptomon !!!</p>
        </v-card-text>
        <v-divider></v-divider>
        <v-card-actions>
          <v-btn text @click="hatchDialog = false">Understood</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="fightDialog" max-width="300px">
      <v-card >
        <v-card-title>The fight is finished</v-card-title>
        <v-divider></v-divider>
        <v-card-text >
          <v-img class="mx-auto my-5" width="75" :src="require('@/assets/war.png')"></v-img>
          <p>Go to your account and see if your pokemon improved</p>
        </v-card-text>
        <v-divider></v-divider>
        <v-card-actions>
          <v-btn text @click="fightDialog = false">Understood</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-footer>
      <v-col class="text-center overline" cols="12">
        {{ new Date().getFullYear() }} — <strong>Sébastien Huot</strong> — This website requires Metamask on Ropsten network
      </v-col>
    </v-footer>

  </v-app>
</template>

<script>
import Market from './components/Market';
import Account from './components/Account';
import Search from './components/Search';

export default {
  name: 'App',

  components: {
    Market,
    Account,
    Search
  },

  computed: {
    receipt: {
      get: function() {
        return this.$store.state.receipt
      },
      set: function(newValue) {
        this.$store.state.receipt = newValue
      }
    },    
    tx: function() {
      return this.$store.state.tx
    },
    hatchDialog: {
      get: function() {
        return this.$store.state.hatchDialog
      },
      set: function(newValue) {
        this.$store.state.hatchDialog = newValue
      }
    },
    fightDialog: {
      get: function() {
        return this.$store.state.fightDialog
      },
      set: function(newValue) {
        this.$store.state.fightDialog = newValue
      }
    },
  },

  data: () => ({
    tab: null,
  }),
};
</script>
