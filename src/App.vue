<template>
  <v-app>
    <v-card height="100%">
      <v-card-title class="justify-center"> CryptoMons </v-card-title>
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

    <v-footer>
      <v-col class="text-center" cols="12">
        {{ new Date().getFullYear() }} — <strong>Sébastien Huot</strong> This website requires Metamask on Ropsten network
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

  data: () => ({
    tab: null
  }),
};
</script>
