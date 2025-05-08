# Basics

Very basic examples to illustrate the nuts and bolts of programming in Sui.

* Object: a heavily commented example of a custom object.
* Sandwich: example of object exchange logic--combining ham and bread objects to produce a sandwich.
* Lock: example of a shared object which can be accessed if someone has a key.

* sui client call --package 0xc85e4a399ecd39f8fa6118a0442f4001dc59d30f --module homi --function mint --gas-budget 30000 --args 0x0f91e998345c376d62f85e57769afe296816d7de 50000 0x6554db1edfa48e339ffdf410da4493c524e9f732    

* sui client publish --gas-budget 30000 --with-unpublished-dependencies --skip-dependency-verification

* sui client call --gas-budget 30000 --package 0xc10ccf54f096e1aca19efa768872b5650a5c258a --module staking --function create_vault  --args 0 

* sui client call --package 0x099cfbaeee11b48fb329867741bdb8cd74099917f64bb240708ec459b3ace9a9 --module staking  --function create_vault  --args 0xad3bd4884b6397e91d173d329ab33b58177f6e3a8ddd8b422b26425689d987de --type-args 0xa31f630ddeadc0c8b31d7397d08c6dcd9d3daebd9e088a02b9849ae0cf70227::homi::HOMI 0x1e7ebbdd57d9b0ef862def22b735b919ead9e7efc7204ecdcf1833b30fa56878::staking::NFT  --gas-budget 10000000

* sui client call --package 0x5c9f54089910099fbc0b9b8fb2aeedb8c3f8c66c0a32282f48815de30aaeef2e --module staking  --function rotate_owner --type-args 0x2::sui::SUI 0xa31f630ddeadc0c8b31d7397d08c6dcd9d3daebd9e088a02b9849ae0cf70227::homi::HOMI --args 0x30485ec983c318d6f033c752db01f667b5a72c797087752f9ec7ae0310e46e99 --gas-budget 10000000

sui client call --package 0x099cfbaeee11b48fb329867741bdb8cd74099917f64bb240708ec459b3ace9a9 --module staking  --function deposit_rewards --type-args 0xa31f630ddeadc0c8b31d7397d08c6dcd9d3daebd9e088a02b9849ae0cf70227::homi::HOMI 0x1e7ebbdd57d9b0ef862def22b735b919ead9e7efc7204ecdcf1833b30fa56878::staking::NFT --args 0x79a180d1687941094c4048781077920c1a5212473e0c7a033834c32f0e3ae0df 0x98072184d10027229ba02c1414a194c3670fd6ff3c7beef029b6a42293dc72e6 --gas-budget 10000000

 sui client call --package 0x099cfbaeee11b48fb329867741bdb8cd74099917f64bb240708ec459b3ace9a9 --module staking  --function add_rarity --type-args 0xa31f630ddeadc0c8b31d7397d08c6dcd9d3daebd9e088a02b9849ae0cf70227::homi::HOMI 0x1e7ebbdd57d9b0ef862def22b735b919ead9e7efc7204ecdcf1833b30fa56878::staking::NFT --args 0x79a180d1687941094c4048781077920c1a5212473e0c7a033834c32f0e3ae0df 0x2f2422fd5e0aa58356c1c1b12894441b24b1b78a76b5a212d67150dc8fc52d2e 3 --gas-budget 10000000

  sui client call --package 0x5c9f54089910099fbc0b9b8fb2aeedb8c3f8c66c0a32282f48815de30aaeef2e --module staking  --function withdraw_rewards --type-args 0xa31f630ddeadc0c8b31d7397d08c6dcd9d3daebd9e088a02b9849ae0cf70227::homi::HOMI 0x1e7ebbdd57d9b0ef862def22b735b919ead9e7efc7204ecdcf1833b30fa56878::staking::NFT --args 0x4ec3e446b11649ad9a045dfe572e50f36f49cb4c1e1a62e0db6c90acc2d80775 3666665761666666 --gas-budget 10000000
