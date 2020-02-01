<template>
  <v-container>
    <v-card outlined>
      <v-card-title class="headline mb-1">My Account</v-card-title>
      <v-divider></v-divider>
      <v-row no-gutters>
        <v-col>
          <v-list-item two-line><v-list-item-content>
            <v-list-item-title>{{account[0].name}}</v-list-item-title><v-list-item-subtitle>{{account[0].value}}</v-list-item-subtitle>
          </v-list-item-content></v-list-item>
        </v-col>
        <v-col>
          <v-list-item two-line><v-list-item-content>
            <v-list-item-title>{{account[1].name}}</v-list-item-title><v-list-item-subtitle>{{account[1].value}} ETH</v-list-item-subtitle>
          </v-list-item-content></v-list-item>
        </v-col>
        <v-col>
          <v-list-item two-line><v-list-item-content>
            <v-list-item-title>{{account[2].name}}</v-list-item-title><v-list-item-subtitle>{{account[2].value}}</v-list-item-subtitle>
          </v-list-item-content></v-list-item>
        </v-col>
      </v-row>

      <v-row no-gutters>
        <v-col>
          <v-list-item two-line><v-list-item-content>
            <v-list-item-title>{{account[3].name}}</v-list-item-title><v-list-item-subtitle>{{account[3].value/1e18}} ETH</v-list-item-subtitle>
          </v-list-item-content></v-list-item>
        </v-col>
        <v-col v-if="account[4].value != null">
          <v-list-item two-line><v-list-item-content>
            <v-list-item-title>{{account[4].name}}</v-list-item-title><v-list-item-subtitle>{{Math.max(account[4].value, 0)}}</v-list-item-subtitle>
          </v-list-item-content></v-list-item>
        </v-col>
        <v-col v-if="account[4].value != null">
          <v-list-item two-line><v-list-item-content>
            <v-list-item-title>{{account[5].name}}</v-list-item-title><v-list-item-subtitle>{{account[4].value >= 0 ? account[5].value : 'Ready'}}</v-list-item-subtitle>
          </v-list-item-content></v-list-item>
        </v-col>
      </v-row>
    </v-card>

    <v-snackbar v-model="breedAlert" color="error" :timeout="5000">
      You have to match a male and a female !
      <v-btn text @click="breedAlert = false">Close</v-btn>
    </v-snackbar>

    <div class="text-center">
      <v-card class="ma-2 text-left d-inline-block" width="290" outlined align="center" v-if="account[4].value != null && account[4].value <= 0">
        <v-list-item two-line>
          <v-list-item-content>
            <v-list-item-title class="headline mb-1">Egg</v-list-item-title>              
            <div class="body-2">
              <v-chip x-small color="blue white--text" label>READY</v-chip>  
              <p>Congrats your egg is now ready to hatch ! Which pokemon will come out of it ?</p>
            </div>
          </v-list-item-content>    
          <v-list-item-avatar tile size="90" color="white"><v-img :src="require('@/assets/egg.png')"></v-img></v-list-item-avatar>
        </v-list-item>
        <v-card-actions>
          <v-btn text v-on:click="hatch">Hatch</v-btn>                          
        </v-card-actions>
      </v-card>

      <v-card class="ma-2 text-left d-inline-block" width="290" outlined align="center" v-if="account[6].value > 0">
        <v-list-item two-line>
          <v-list-item-content>
            <v-list-item-title class="headline mb-1">Pokeball</v-list-item-title>              
            <div class="body-2">
              <v-chip x-small color="blue white--text" label>READY</v-chip>  
              <p>Why don't you open this pokeball to get your favorite starter ? ({{account[6].value}} left)</p>
            </div>
          </v-list-item-content>    
          <v-list-item-avatar tile size="90" color="white"><v-img :src="require('@/assets/pokeball.png')"></v-img></v-list-item-avatar>
        </v-list-item>
        <v-card-actions>
          <v-btn text v-on:click="pokeballDialog = true">Open</v-btn>                          
        </v-card-actions>
      </v-card>

      <v-card class="ma-2 text-left d-inline-block" width="290" outlined align="center" v-if="account[3].value != 0">
        <v-list-item two-line>
          <v-list-item-content>
            <v-list-item-title class="headline mb-1">Money !!!</v-list-item-title>              
            <div class="body-2">
              <v-chip x-small color="blue white--text" label>READY</v-chip>  
              <p>Wahou you had a lot of success in the market ! You can redeem your ethereum now</p>
            </div>
          </v-list-item-content>    
          <v-list-item-avatar tile size="90" color="white"><v-img :src="require('@/assets/ethereum.png')"></v-img></v-list-item-avatar>
        </v-list-item>
        <v-card-actions>
          <v-btn text v-on:click="withdraw">Redeem</v-btn>                          
        </v-card-actions>
      </v-card>

      <v-card v-for="token in accountToken" v-bind:key="token.id" v-bind:raised="breeding.tokenA == token || breeding.tokenB == token" class="ma-2 text-left d-inline-block" width="290" outlined>
        <v-list-item two-line>
            <v-list-item-content>
                <v-list-item-title class="headline mb-1">{{token.name}}</v-list-item-title>              
                <div class="body-2">   
                  <v-chip v-if="token.sprite >= 122 || (token.hp*token.atk + 5*token.lvl + parseInt(token.def) > 1000)" x-small color="red white--text" class="mr-2" label><v-icon left small>mdi-fire</v-icon>RARE</v-chip>     
                  <v-chip v-if="token.onBreeding" x-small color="green white--text" label>BREED</v-chip>     
                  <v-chip v-if="token.onMarket" x-small color="purple white--text" label>MARKET</v-chip>
                  <v-chip v-if="!token.onMarket && !token.onBreeding" x-small color="white" outlined></v-chip>
                  <v-row no-gutters><v-col class="ma-1">❤️ {{token.hp}}</v-col><v-col class="ma-1">📈 {{token.lvl}}</v-col></v-row>
                  <v-row no-gutters><v-col class="ma-1">💪 {{token.atk}}</v-col><v-col class="ma-1">🛡️ {{token.def}}</v-col></v-row>
                  <v-row no-gutters><v-col class="ma-1">⌛ {{token.breedingSpeed}}</v-col><v-col class="ma-1">{{token.element != 0 ? (token.element == 1 ? '💦': '🌿') : '🔥'}}</v-col></v-row>
                  <v-row no-gutters><v-col class="ma-1">{{token.gender == 0 ? 'Male ♂️' : 'Female ♀️'}}</v-col></v-row>
                </div>
            </v-list-item-content>
    
            <v-list-item-avatar tile size="90" color="white"><v-img v-bind:src="require('@/assets/sprites/large/'+token.sprite+'.png')"></v-img></v-list-item-avatar>
        </v-list-item>
    
        <v-card-actions>
            <v-btn v-if="!token.onMarket" text v-on:click.stop="sellDialog = true; sellToken = token">Sell</v-btn>
            <v-btn v-if="token.onMarket" text v-on:click="takeBack(token.id)">Take back</v-btn>
            <v-btn :disabled="token.onMarket" text v-on:click="refreshBreeding(token)">Breed</v-btn>
            <v-btn :disabled="token.onMarket" text v-on:click.stop="giveDialog = true; giveToken = token">Give</v-btn>                    
        </v-card-actions>
      </v-card>
    </div>

    <v-dialog v-model="giveDialog" max-width="290">
      <v-card v-if="giveToken != null">
        <v-card-title class="headline">Give {{giveToken.name}} ?</v-card-title>  
        <v-text-field v-model="giveTo" tile outlined label="address" type="text" class="mx-2"></v-text-field>
        <v-card-actions>
          <v-spacer></v-spacer>  
          <v-btn v-on:click="giveDialog = false; give()" outlined color="primary">Confirm</v-btn>
          <v-btn v-on:click="giveDialog = false" outlined color="error">Cancel</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="sellDialog" max-width="290">
      <v-card v-if="sellToken != null">
        <v-card-title class="headline">Sell {{sellToken.name}}?</v-card-title> 
        <v-text-field v-model="sellPrice" tile outlined label="amount (ether)" type="number" class="mx-2"></v-text-field> 
        <v-card-actions>
          <v-spacer></v-spacer>  
          <v-btn outlined color="primary" @click="sellDialog = false; sell()">Sell</v-btn>  
          <v-btn outlined color="error" @click="sellDialog = false">Cancel</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="breedDialog" max-width="400">      
      <v-card v-if="breeding.tokenA != null && breeding.tokenB != null">
        <v-card-title class="title">Breed {{breeding.tokenA.name}} with {{breeding.tokenB.name}} ?</v-card-title> 
        <v-spacer></v-spacer> 
        <v-card-text>
          <v-row no-gutter align="center">
            <v-col class="ma-1"><v-img class="d-inline-block ma-auto" width="100px" v-bind:src="require('@/assets/sprites/medium/'+breeding.tokenA.sprite.padStart(3,'0')+'.png')"></v-img></v-col>
            <v-col class="ma-1" ><p class="text-center headline">+</p></v-col>
            <v-col class="ma-1"><v-img class="d-inline-block ma-auto" width="100px" v-bind:src="require('@/assets/sprites/medium/'+breeding.tokenB.sprite.padStart(3,'0')+'.png')"></v-img></v-col>
          </v-row>
          <p class="text-center body-1 black--text">breeding time = {{parseInt(breeding.tokenA.breedingSpeed) + parseInt(breeding.tokenB.breedingSpeed)}} blocks</p>
        </v-card-text>        
        <v-card-actions>
          <v-spacer></v-spacer> 
          <v-btn outlined color="primary" @click="breedDialog = false; breed()">Breed</v-btn>  
          <v-btn outlined color="error" @click="breedDialog = false">Cancel</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="pokeballDialog" max-width="400">      
      <v-card>
        <v-card-title class="title">Choose your starter</v-card-title> 
        <v-spacer></v-spacer> 
        <v-card-text>
          <v-row no-gutter align="center">
            <v-col class="ma-1"><a v-on:click="openBall(0)"><v-img class="d-inline-block ma-auto" width="80px" v-bind:src="require('@/assets/sprites/medium/001.png')"></v-img></a></v-col>
            <v-col class="ma-1"><a v-on:click="openBall(1)"><v-img class="d-inline-block ma-auto" width="80px" v-bind:src="require('@/assets/sprites/medium/004.png')"></v-img></a></v-col>
            <v-col class="ma-1"><a v-on:click="openBall(2)"><v-img class="d-inline-block ma-auto" width="80px" v-bind:src="require('@/assets/sprites/medium/007.png')"></v-img></a></v-col>
          </v-row>
        </v-card-text>        
        <v-card-actions>
          <v-spacer></v-spacer> 
          <v-btn outlined color="error" @click="pokeballDialog = false">Cancel</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

         

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
    sellDialog: false,
    giveDialog: false,
    breedDialog: false,
    breedAlert: false,
    pokeballDialog: false,

    breeding: {tokenA: null, tokenB: null},

    giveTo: null,
    giveToken: null,

    sellPrice: null,
    sellToken: null,

    starter: null
  }),

  methods: {
    give: function() {
      this.$store.dispatch('give', {to: this.giveTo, id: this.giveToken.id});
    },
    sell: function () {
      this.$store.dispatch('sell',{id: this.sellToken.id, price: this.sellPrice})
    },

    refreshBreeding: function (token) {
      
      if(this.breeding.tokenA != token) {
        if(this.breeding.tokenB != token) {
          if(this.breeding.tokenA == null) {
            this.breeding.tokenA = token
            if(this.breeding.tokenB != null) {
              this.breedDialog = (this.breeding.tokenA.gender != this.breeding.tokenB.gender)
              this.breedAlert = !this.breedDialog
            }
          } else {
            this.breeding.tokenB = token
            this.breedDialog = (this.breeding.tokenA.gender != this.breeding.tokenB.gender)
            this.breedAlert = !this.breedDialog
          }          
        } else {
          this.breeding.tokenB = null
        }
      } else {
        this.breeding.tokenA = null
      }
    },
    withdraw: function() {
      this.$store.dispatch('withdraw')
    },
    takeBack: function(tokenId) {
      this.$store.dispatch('takeBack', tokenId)
    },
    breed: function() {
      if (this.breeding.tokenA != null && this.breeding.tokenB != null) {
        this.$store.dispatch('breed', this.breeding)
      }      
    },
    hatch: function() {
      this.$store.dispatch('hatch')
    },
    openBall: function(starter) {
      this.pokeballDialog = false
      this.$store.dispatch('openBall', starter)
    }
  }
};
</script>
