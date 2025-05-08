
module staking::staking{
  use sui::transfer;
  use sui::object::{Self,ID, UID};
  use sui::tx_context::{Self, TxContext};
  //use std::string;
  //use std::vector;
  //use sui::url::{Self, Url};
  use sui::dynamic_object_field as ofield;
  use sui::address;
  use sui::balance::{Self, Balance};
  use sui::coin::{Self, Coin};
  use sui::clock::{Self, Clock};
  use sui::package;
  use sui::display;
  use std::string::{utf8, String};
  use sui::table::{Self,Table};
  use std::vector;

  struct HominidsVault<phantom T,phantom N: key + store> has key{
    id : UID,
    owner: address,
    staked_hominids: u64,
    common_dpr: u64,
    rare_dpr: u64,
    epic_dpr: u64,
    legendary_dpr: u64,
    rewards: Balance<T>,
    rarities: Table<ID,u8>,
    withdrawn_rewards: u64
  }

  struct StakeReceipt has key{
    id : UID,
    nft_id : address,
    rarity: String,
    stakedAt: u64,
    withdrawn_amount: u64
  }

  struct AdminCap has key, store {
        id: UID,
        owner: address
  }

  struct STAKING has drop {}

 
  /// Attempted to perform an admin-only operation without valid permissions
  /// Try using the correct `AdminCap`
  const EAdminOnly: u64 = 0;

  // === Admin-only functionality ===
  fun init(otw: STAKING, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),
            utf8(b"description"),
        ];

        let values = vector[
            utf8(b"Staked hominid receipt"),
            utf8(b"https://era-homi.xyz/nft/{nft_id}"),
            utf8(b"https://hominids.io/hominids_ipfs/staking/{rarity}.png"),
            utf8(b"A receipt NFT which prove that you are staking a Hominid NFT."),
        ];
        let publisher = package::claim(otw, ctx);
        let display = display::new_with_fields<StakeReceipt>(
            &publisher, keys, values, ctx
        );
        display::update_version(&mut display);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));

        transfer::transfer(AdminCap { id: object::new(ctx), owner: tx_context::sender(ctx) }, tx_context::sender(ctx));
  }

  // On module init, create a Vault
  public entry fun create_vault<T,N: key + store>(cap: &AdminCap,ctx: &mut TxContext) {
        assert!(cap.owner == tx_context::sender(ctx), EAdminOnly);
        let id = object::new(ctx);
        transfer::share_object(HominidsVault<T,N> {
            id: id,
            owner: tx_context::sender(ctx),
            staked_hominids: 0,
            common_dpr: 10,
            rare_dpr: 20,
            epic_dpr: 50,
            legendary_dpr: 100,
            rewards: balance::zero<T>(),
            rarities: table::new<ID,u8>(ctx),
            withdrawn_rewards: 0
        });
  }

  public entry fun deposit_rewards<T,N: key + store>(
        self: &mut HominidsVault<T,N>, coin: Coin<T>, ctx: &mut TxContext
    ) {
        assert!(self.owner == tx_context::sender(ctx), EAdminOnly);
        coin::put(&mut self.rewards, coin);
  }

  public entry fun withdraw_rewards<T,N: key + store>(
        self: &mut HominidsVault<T,N>, amount: u64, ctx: &mut TxContext
  ) {
        assert!(self.owner == tx_context::sender(ctx), EAdminOnly);
        let withdraw_coins = coin::take(&mut self.rewards, amount, ctx);
        transfer::public_transfer(withdraw_coins, tx_context::sender(ctx));
  }

  public entry fun add_rarity<T,N: key + store>(
        self: &mut HominidsVault<T,N>,nft_id: ID,rarity: u8, ctx: &mut TxContext
    ) {
        assert!(self.owner == tx_context::sender(ctx), EAdminOnly);
        assert!(rarity == 0 || rarity == 1 || rarity == 2 || rarity == 3, EAdminOnly);

        if(table::contains<ID,u8>(&self.rarities,nft_id)){
             let rarity_number = table::borrow_mut<ID,u8>(&mut self.rarities,nft_id);
             *rarity_number = rarity;
        }else{
          table::add<ID,u8>(&mut self.rarities,nft_id,rarity);
        };
  }
  
  // === Staking functionality ===

  public entry fun stake<T,N: key + store>(vault: &mut HominidsVault<T,N>,nft: N,clock: &Clock,ctx: &mut TxContext){
    let rarity_number = table::borrow<ID,u8>(&mut vault.rarities,object::id(&nft));
    let rarities_text = vector[utf8(b"Common"),utf8(b"Rare"),utf8(b"Epic"),utf8(b"Legendary")];
    let rarity = *vector::borrow(&rarities_text,(*rarity_number as u64));
    let staker_address = tx_context::sender(ctx);
    let nft_address = object::id_address(&mut nft);
    let nft_address_name = address::to_bytes(nft_address);
    ofield::add(&mut vault.id, nft_address_name, nft);
    let stakedAt : u64 = clock::timestamp_ms(clock);
    let receipt = StakeReceipt { id: object::new(ctx), nft_id: nft_address, rarity: rarity, stakedAt: stakedAt,withdrawn_amount:0};
    transfer::transfer(receipt,staker_address);
    vault.staked_hominids = vault.staked_hominids + 1;
  }

  public entry fun claim_rewards<T,N: key + store>(vault: &mut HominidsVault<T,N>,receipt: &mut StakeReceipt,clock: &Clock,ctx: &mut TxContext){
    let rewards = &mut vault.rewards;
    //let withdrawn_amount = &mut receipt.withdrawn_amount;
    let stakedAt : u64 = receipt.stakedAt;
    let now : u64 = clock::timestamp_ms(clock);
    let rarity = receipt.rarity;
    let reward : u64 = 0;//(((now-stakedAt) * (3/2)) / 86400) * 1000000;
    if(rarity == utf8(b"Common")){
      reward = (((now-stakedAt) * (vault.common_dpr)) / 86400) * 1000000;
    }else if(rarity == utf8(b"Rare")){
      reward = (((now-stakedAt) * (vault.rare_dpr)) / 86400) * 1000000;
    }else if(rarity == utf8(b"Epic")){
      reward = (((now-stakedAt) * (vault.epic_dpr)) / 86400) * 1000000;
    }else if(rarity == utf8(b"Legendary")){
      reward = (((now-stakedAt) * (vault.legendary_dpr)) / 86400) * 1000000;
    };
    let rewards_coins = coin::take(rewards, reward - receipt.withdrawn_amount, ctx);
    transfer::public_transfer(rewards_coins, tx_context::sender(ctx));
    vault.withdrawn_rewards = vault.withdrawn_rewards + (reward - receipt.withdrawn_amount);
    receipt.withdrawn_amount = reward;
  }

  public entry fun unstake<T,N: key + store>(vault: &mut HominidsVault<T,N>,receipt: StakeReceipt,ctx: &mut TxContext){
    let StakeReceipt { id , nft_id,rarity:_, stakedAt:_,withdrawn_amount:_ } = receipt;
    let nft_address_name = address::to_bytes(nft_id);
    let nft = ofield::remove<vector<u8>, N>(
        &mut vault.id,
        nft_address_name,
    );
    transfer::public_transfer(nft,tx_context::sender(ctx));
    object::delete(id);
    vault.staked_hominids = vault.staked_hominids - 1;
  }

  public entry fun rotate_owner<T,N: key + store>(vault: &mut HominidsVault<T,N>,ctx: &mut TxContext) {
        assert!(vault.owner == tx_context::sender(ctx), EAdminOnly);
        vault.owner = tx_context::sender(ctx);
  }

  public entry fun update_dprs<T,N: key + store>(vault: &mut HominidsVault<T,N>,
   common_dpr: u64,
   rare_dpr: u64,
   epic_dpr: u64,
   legendary_dpr: u64,
   ctx: &mut TxContext) {
        assert!(vault.owner == tx_context::sender(ctx), EAdminOnly);
        vault.common_dpr = common_dpr;
        vault.rare_dpr = rare_dpr;
        vault.epic_dpr = epic_dpr;
        vault.legendary_dpr = legendary_dpr;
  }
  
   
   #[test_only]
    struct NFT has key, store{
      id: UID,
      name: vector<u8>,
      description: vector<u8>,
      image: vector<u8>
    }
  #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(STAKING{},ctx);
    }
   #[test_only]
    public entry fun mintNFT(name: vector<u8>,description: vector<u8>,image: vector<u8>,ctx: &mut TxContext){
        transfer::transfer(NFT {id:object::new(ctx),name,description,image},tx_context::sender(ctx))
    }
     #[test_only]
    public fun staked_hominids<T,N: key + store>(nft: &HominidsVault<T,N>): u64 {
        nft.staked_hominids
    }
 #[test_only]
    public fun get_receipt<T,N: key + store>(nft: &HominidsVault<T,N>): u64 {
        nft.staked_hominids
    }
}

/*
#[test_only]
  module sui::staking_test {
    use sui::test_scenario as ts;
    //use sui::transfer;
    //use std::string;
    use sui::clock::{Self, Clock};
    use staking::staking::{Self,HominidsVault,StakeReceipt,AdminCap,NFT};
    use sui::coin;
    use sui::sui::SUI;
    #[test]
    fun mint_stake() {
        let addr1 = @0xA;
        //let addr2 = @0xB;
        // create the NFT
        let scenario = ts::begin(addr1);
        {
            staking::init_for_testing(ts::ctx(&mut scenario));
        };

        ts::next_tx(&mut scenario, addr1);
        {
            let cap = ts::take_from_sender<AdminCap>(&mut scenario);
            staking::create_vault<SUI,NFT>(&cap,ts::ctx(&mut scenario));
            ts::return_to_sender(&mut scenario,cap);
        };

        ts::next_tx(&mut scenario, addr1);
        {
            staking::mintNFT(b"test", b"a test", b"https://www.sui.io", ts::ctx(&mut scenario));
        };
        
        ts::next_tx(&mut scenario, addr1);
        {
           let ctx = ts::ctx(&mut scenario); 
           let sui = coin::mint_for_testing<SUI>(100000000000, ctx);
           let vault = ts::take_shared<HominidsVault<SUI,NFT>>(&mut scenario);
           staking::deposit_rewards(&mut vault,sui,ts::ctx(&mut scenario));
           ts::return_shared(vault);
           clock::create_for_testing(ts::ctx(&mut scenario));
        };

        // stake nft
        ts::next_tx(&mut scenario, addr1);
        {
        
            let nft = ts::take_from_sender<NFT>(&mut scenario);
            let vault = ts::take_shared<HominidsVault<SUI,NFT>>(&mut scenario);
            let clock = ts::take_shared<Clock>(&mut scenario);
            clock::increment_for_testing(&mut clock,0);
            let ctx = ts::ctx(&mut scenario);
            staking::stake<SUI,NFT>(&mut vault,nft,&clock,ctx);
            assert!(staking::staked_hominids(&vault) == 1, 1);
            assert!(!ts::has_most_recent_for_sender<NFT>(&mut scenario), 0);
            ts::return_shared(vault);
            ts::return_shared(clock);
            //ts::return_to_sender(&mut scenario,nft);
        };
        
        ts::next_tx(&mut scenario, addr1);
        {
            
            let vault = ts::take_shared<HominidsVault<SUI,NFT>>(&mut scenario);
            let receipt = ts::take_from_sender<StakeReceipt>(&mut scenario);
            let clock = ts::take_shared<Clock>(&mut scenario);
            let ctx = ts::ctx(&mut scenario);

            //clock::increment_for_testing(&mut clock,86400/48);
            //staking::claim_rewards<SUI,NFT>(&mut vault,&mut receipt,&clock,ctx);
            clock::increment_for_testing(&mut clock,86400/24);
            staking::claim_rewards<SUI,NFT>(&mut vault,&mut receipt,&clock,ctx);
            clock::increment_for_testing(&mut clock,86400/12);
            staking::claim_rewards<SUI,NFT>(&mut vault,&mut receipt,&clock,ctx);
            clock::increment_for_testing(&mut clock,86400/6);
            staking::claim_rewards<SUI,NFT>(&mut vault,&mut receipt,&clock,ctx);
            clock::increment_for_testing(&mut clock,86400/1);
            staking::claim_rewards<SUI,NFT>(&mut vault,&mut receipt,&clock,ctx);
            //let coins = ts::take_from_sender<coin::Coin<SUI>>(&mut scenario);
            //assert!(ts::has_most_recent_for_sender<coin::Coin<SUI>>(&mut scenario), 0);
            //assert!(coin::value<SUI>(&coins) == 5, 1);

            ts::return_to_sender(&mut scenario,receipt);
            //ts::return_to_sender(&mut scenario,coins);
            ts::return_shared(vault);
            ts::return_shared(clock);
            //devnet_nft::burn(nft);
        };

        // unstake nft
        ts::next_tx(&mut scenario, addr1);
        {
            let vault = ts::take_shared<HominidsVault<SUI,NFT>>(&mut scenario);
            let receipt = ts::take_from_sender<StakeReceipt>(&mut scenario);
            let ctx = ts::ctx(&mut scenario);            
            staking::unstake(&mut vault,receipt,ctx);
            assert!(staking::staked_hominids(&vault) == 0, 1);
            ts::return_shared(vault);
        };
        
        ts::end(scenario);
    }
  }*/
  