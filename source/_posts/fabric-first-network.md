---
title: 搭建Fabric First Network
date: 2019-07-17 11:37:57
tags: ['区块链', 'Fabric']
---


本文是[Building Your First Network](https://hyperledger-fabric.readthedocs.io/en/release-1.4/build_network.html)的笔记和实践记录，基于Fabric 1.4，commit id：9dce73。

前提：
1. 安装了Docker、Go等环境。
1. 已经下载了fabric仓库，完成`make all`。

## 下载fabric-samples和事前工作

有2种方式，方式1：一键下载和编译。

```
curl -sSL http://bit.ly/2ysbOFE | bash -s
```

方式2：手动clone，放到GOPATH下，然后执行脚本，构建和拉去一些镜像，为搭建网络做准备。方式2只不过是把方式1的工作，手动做掉了。

```
git clone https://github.com/hyperledger/fabric-samples.git
cd fabric-samples
sh scripts/bootstrap.sh
```

参考资料：https://hyperledger-fabric.readthedocs.io/en/release-1.4/install.html。

## 快速启动你的第一个Fabric网络

这一节的目的是用几分钟的时间启动一个网络，并且启动一个网络需要做哪些工作。

### 启动

`fabric-samples`下有多个示例，本次要使用的是`first-network`：

```
➜  fabric-samples git:(release-1.4) ll | grep ^d
drwxr-xr-x 5 centos centos  193 7月  12 08:21 balance-transfer
drwxr-xr-x 4 centos centos  273 7月  12 08:21 basic-network
drwxrwxr-x 2 centos centos  175 1月   9 2019 bin
drwxr-xr-x 8 centos centos  113 7月  12 08:21 chaincode
drwxr-xr-x 3 centos centos  139 7月  12 08:21 chaincode-docker-devmode
drwxr-xr-x 3 centos centos   44 7月  12 06:47 commercial-paper
drwxrwxr-x 2 centos centos   64 1月   9 2019 config
drwxr-xr-x 2 centos centos   59 7月  12 08:21 docs
drwxr-xr-x 5 centos centos  110 7月  12 08:21 fabcar
drwxr-xr-x 7 centos centos 4.0K 7月  17 03:14 first-network
drwxr-xr-x 4 centos centos   55 7月  12 08:21 high-throughput
drwxr-xr-x 4 centos centos   55 7月  12 08:21 interest_rate_swaps
drwxr-xr-x 4 centos centos   67 7月  17 03:46 scripts
```

进入`first-network`然后执行`./byfn.sh up`，启动操作会持续两三分钟，`byfn`是Building Your First Network的缩写。

启动过程实际做了这些事：

第一阶段：生成配置文件

1. 使用加密工具`cryptogen`生成证书
1. 使用工具`configtxgen`生成orderer节点的创世块
1. 使用工具`configtxgen`生成配置channel的交易`channel.tx`
1. 使用工具`configtxgen`生成Org1的MSP的anchor peer
1. 使用工具`configtxgen`生成Org2的MSP的anchor peer

第二阶段：创建容器，启动服务，部署和实例化chaincode

1. 启动容器，包含客户端(cli)、peer、orderer等，每个org有2个peer，peer0和peer1
1. 创建channel
1. peer加入channel
1. 在channel上更新Org1和Org2 MSP的anchor peer
1. 在ogr1好org2的peer0上安装chaincode
1. 在channel中，在peer0.org2上实例化chaincode，1个channel上只需示例化1次
1. 在channel中，Invoke刚实例化的chaincode
1. 在peer1.org2上安装chaincode，并查询


```
$ cd first-network
➜  first-network git:(release-1.4) ./byfn.sh up
Starting for channel 'mychannel' with CLI timeout of '10' seconds and CLI delay of '3' seconds
Continue? [Y/n] y
proceeding ...
LOCAL_VERSION=1.4.0
DOCKER_IMAGE_VERSION=1.4.0
/home/centos/go/src/github.com/hyperledger/fabric-samples/bin/cryptogen

##########################################################
##### Generate certificates using cryptogen tool #########
##########################################################
+ cryptogen generate --config=./crypto-config.yaml
org1.example.com
org2.example.com
+ res=0
+ set +x

/home/centos/go/src/github.com/hyperledger/fabric-samples/bin/configtxgen
##########################################################
#########  Generating Orderer Genesis block ##############
##########################################################
CONSENSUS_TYPE=solo
+ '[' solo == solo ']'
+ configtxgen -profile TwoOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
2019-07-17 06:34:26.973 UTC [common.tools.configtxgen] main -> INFO 001 Loading configuration
2019-07-17 06:34:27.088 UTC [common.tools.configtxgen.localconfig] completeInitialization -> INFO 002 orderer type: solo
2019-07-17 06:34:27.088 UTC [common.tools.configtxgen.localconfig] Load -> INFO 003 Loaded configuration: /home/centos/go/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
2019-07-17 06:34:27.186 UTC [common.tools.configtxgen.localconfig] completeInitialization -> INFO 004 orderer type: solo
2019-07-17 06:34:27.186 UTC [common.tools.configtxgen.localconfig] LoadTopLevel -> INFO 005 Loaded configuration: /home/centos/go/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
2019-07-17 06:34:27.188 UTC [common.tools.configtxgen] doOutputBlock -> INFO 006 Generating genesis block
2019-07-17 06:34:27.189 UTC [common.tools.configtxgen] doOutputBlock -> INFO 007 Writing genesis block
+ res=0
+ set +x

#################################################################
### Generating channel configuration transaction 'channel.tx' ###
#################################################################
+ configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel
2019-07-17 06:34:27.228 UTC [common.tools.configtxgen] main -> INFO 001 Loading configuration
2019-07-17 06:34:27.315 UTC [common.tools.configtxgen.localconfig] Load -> INFO 002 Loaded configuration: /home/centos/go/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
2019-07-17 06:34:27.422 UTC [common.tools.configtxgen.localconfig] completeInitialization -> INFO 003 orderer type: solo
2019-07-17 06:34:27.422 UTC [common.tools.configtxgen.localconfig] LoadTopLevel -> INFO 004 Loaded configuration: /home/centos/go/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
2019-07-17 06:34:27.422 UTC [common.tools.configtxgen] doOutputChannelCreateTx -> INFO 005 Generating new channel configtx
2019-07-17 06:34:27.425 UTC [common.tools.configtxgen] doOutputChannelCreateTx -> INFO 006 Writing new channel tx
+ res=0
+ set +x

#################################################################
#######    Generating anchor peer update for Org1MSP   ##########
#################################################################
+ configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
2019-07-17 06:34:27.477 UTC [common.tools.configtxgen] main -> INFO 001 Loading configuration
2019-07-17 06:34:27.559 UTC [common.tools.configtxgen.localconfig] Load -> INFO 002 Loaded configuration: /home/centos/go/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
2019-07-17 06:34:27.649 UTC [common.tools.configtxgen.localconfig] completeInitialization -> INFO 003 orderer type: solo
2019-07-17 06:34:27.649 UTC [common.tools.configtxgen.localconfig] LoadTopLevel -> INFO 004 Loaded configuration: /home/centos/go/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
2019-07-17 06:34:27.649 UTC [common.tools.configtxgen] doOutputAnchorPeersUpdate -> INFO 005 Generating anchor peer update
2019-07-17 06:34:27.649 UTC [common.tools.configtxgen] doOutputAnchorPeersUpdate -> INFO 006 Writing anchor peer update
+ res=0
+ set +x

#################################################################
#######    Generating anchor peer update for Org2MSP   ##########
#################################################################
+ configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP
2019-07-17 06:34:27.689 UTC [common.tools.configtxgen] main -> INFO 001 Loading configuration
2019-07-17 06:34:27.773 UTC [common.tools.configtxgen.localconfig] Load -> INFO 002 Loaded configuration: /home/centos/go/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
2019-07-17 06:34:27.886 UTC [common.tools.configtxgen.localconfig] completeInitialization -> INFO 003 orderer type: solo
2019-07-17 06:34:27.886 UTC [common.tools.configtxgen.localconfig] LoadTopLevel -> INFO 004 Loaded configuration: /home/centos/go/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
2019-07-17 06:34:27.886 UTC [common.tools.configtxgen] doOutputAnchorPeersUpdate -> INFO 005 Generating anchor peer update
2019-07-17 06:34:27.886 UTC [common.tools.configtxgen] doOutputAnchorPeersUpdate -> INFO 006 Writing anchor peer update
+ res=0
+ set +x

Creating network "net_byfn" with the default driver
Creating volume "net_orderer.example.com" with default driver
Creating volume "net_peer0.org1.example.com" with default driver
Creating volume "net_peer1.org1.example.com" with default driver
Creating volume "net_peer0.org2.example.com" with default driver
Creating volume "net_peer1.org2.example.com" with default driver
Creating orderer.example.com    ... done
Creating peer0.org2.example.com ... done
Creating peer1.org2.example.com ... done
Creating peer0.org1.example.com ... done
Creating peer1.org1.example.com ... done
Creating cli                    ... done
CONTAINER ID        IMAGE                                                                                                          COMMAND                  CREATED                  STATUS                      PORTS                      NAMES
8c2ccb5ee443        hyperledger/fabric-tools:latest                                                                                "/bin/bash"              Less than a second ago   Up Less than a second                                  cli
5af5a3fb3bb7        hyperledger/fabric-peer:latest                                                                                 "peer node start"        2 seconds ago            Up Less than a second       0.0.0.0:8051->8051/tcp     peer1.org1.example.com
396b363bb6f5        hyperledger/fabric-peer:latest                                                                                 "peer node start"        2 seconds ago            Up Less than a second       0.0.0.0:7051->7051/tcp     peer0.org1.example.com
94be2011d20f        hyperledger/fabric-orderer:latest                                                                              "orderer"                2 seconds ago            Up Less than a second       0.0.0.0:7050->7050/tcp     orderer.example.com
da8c17df215d        hyperledger/fabric-peer:latest                                                                                 "peer node start"        2 seconds ago            Up Less than a second       0.0.0.0:9051->9051/tcp     peer0.org2.example.com
fcd30620e876        hyperledger/fabric-peer:latest                                                                                 "peer node start"        2 seconds ago            Up Less than a second       0.0.0.0:10051->10051/tcp   peer1.org2.example.com
10510312db61        dc535406-4013-4141-be9e-e472c1cf24a1-simple-5e32b897538246406863e63956e4c561246725b6fbf114a1fedff16775cf782d   "tail -f /dev/null"      22 hours ago             Exited (137) 22 hours ago                              dc535406-4013-4141-be9e-e472c1cf24a1-simple
21a3b8dc137a        hyperledger/fabric-buildenv:amd64-latest                                                                       "/bin/bash"              22 hours ago             Exited (0) 22 hours ago                                musing_swartz
48407948b7d7        hyperledger/fabric-buildenv                                                                                    "/bin/bash"              22 hours ago             Exited (130) 22 hours ago                              affectionate_curie
358f0c0de3e1        92b20cd39f98                                                                                                   "/bin/bash"              23 hours ago             Exited (130) 22 hours ago                              festive_clarke
de5938eccc11        92b20cd39f98                                                                                                   "./scripts/check_dep…"   23 hours ago             Exited (127) 23 hours ago                              quizzical_einstein
324b27de3a34        92b20cd39f98                                                                                                   "/bin/bash"              23 hours ago             Exited (0) 23 hours ago                                amazing_booth
26a53801f203        92b20cd39f98                                                                                                   "./scripts/check_dep…"   23 hours ago             Exited (127) 23 hours ago                              jolly_saha
94a33ddda70a        92b20cd39f98                                                                                                   "./scripts/golinter.…"   23 hours ago             Exited (0) 23 hours ago                                peaceful_allen
6a0c7fded448        92b20cd39f98                                                                                                   "./scripts/golinter.…"   23 hours ago             Created                                                recursing_beaver
233496b4065c        92b20cd39f98                                                                                                   "/bin/bash"              23 hours ago             Exited (0) 23 hours ago                                wizardly_shockley
f0a255a96610        92b20cd39f98                                                                                                   "/bin/bash"              23 hours ago             Exited (0) 23 hours ago                                jolly_ganguly
664416bc4fee        965663acb7cf                                                                                                   "/bin/sh -c 'apt-get…"   24 hours ago             Exited (100) 24 hours ago                              nostalgic_chaplygin
51cf784ef4e1        ba82c6de-50fb-4ffd-989d-0dcf54e14e3b-simple-9961bcae6dad48592af2e9f1c1df3c96b568f9394ec82b2f351e79fa51a4f786   "tail -f /dev/null"      47 hours ago             Exited (137) 47 hours ago                              ba82c6de-50fb-4ffd-989d-0dcf54e14e3b-simple
b7642b085ac1        14669948-7a23-4b3b-aa14-8b0622986e03-simple-f8a7b2e1352d04d884580725c2be9b642dd29df7e3e095a4a9403ac789dde2ac   "tail -f /dev/null"      2 days ago               Exited (137) 2 days ago                                14669948-7a23-4b3b-aa14-8b0622986e03-simple

 ____    _____      _      ____    _____
/ ___|  |_   _|    / \    |  _ \  |_   _|
\___ \    | |     / _ \   | |_) |   | |
 ___) |   | |    / ___ \  |  _ <    | |
|____/    |_|   /_/   \_\ |_| \_\   |_|

Build your first network (BYFN) end-to-end test

Channel name : mychannel
Creating channel...
+ peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
+ res=0
+ set +x
2019-07-17 06:34:32.113 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2019-07-17 06:34:32.190 UTC [cli.common] readBlock -> INFO 002 Received block: 0
===================== Channel 'mychannel' created =====================

Having all peers join the channel...
+ peer channel join -b mychannel.block
+ res=0
+ set +x
2019-07-17 06:34:32.272 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2019-07-17 06:34:32.338 UTC [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
===================== peer0.org1 joined channel 'mychannel' =====================

+ peer channel join -b mychannel.block
+ res=0
+ set +x
2019-07-17 06:34:35.449 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2019-07-17 06:34:35.536 UTC [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
===================== peer1.org1 joined channel 'mychannel' =====================

+ peer channel join -b mychannel.block
+ res=0
+ set +x
2019-07-17 06:34:38.617 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2019-07-17 06:34:38.673 UTC [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
===================== peer0.org2 joined channel 'mychannel' =====================

+ peer channel join -b mychannel.block
+ res=0
+ set +x
2019-07-17 06:34:41.755 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2019-07-17 06:34:41.837 UTC [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
===================== peer1.org2 joined channel 'mychannel' =====================

Updating anchor peers for org1...
+ peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
+ res=0
+ set +x
2019-07-17 06:34:44.930 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2019-07-17 06:34:44.951 UTC [channelCmd] update -> INFO 002 Successfully submitted channel update
===================== Anchor peers updated for org 'Org1MSP' on channel 'mychannel' =====================

Updating anchor peers for org2...
+ peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
+ res=0
+ set +x
2019-07-17 06:34:48.037 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2019-07-17 06:34:48.059 UTC [channelCmd] update -> INFO 002 Successfully submitted channel update
===================== Anchor peers updated for org 'Org2MSP' on channel 'mychannel' =====================

Installing chaincode on peer0.org1...
+ peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02/go/
+ res=0
+ set +x
2019-07-17 06:34:51.167 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
2019-07-17 06:34:51.167 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
2019-07-17 06:34:51.462 UTC [chaincodeCmd] install -> INFO 003 Installed remotely response:<status:200 payload:"OK" >
===================== Chaincode is installed on peer0.org1 =====================

Install chaincode on peer0.org2...
+ peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02/go/
+ res=0
+ set +x
2019-07-17 06:34:51.542 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
2019-07-17 06:34:51.542 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
2019-07-17 06:34:51.817 UTC [chaincodeCmd] install -> INFO 003 Installed remotely response:<status:200 payload:"OK" >
===================== Chaincode is installed on peer0.org2 =====================

Instantiating chaincode on peer0.org2...
+ peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc -l golang -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P 'AND ('\''Org1MSP.peer'\'','\''Org2MSP.peer'\'')'
+ res=0
+ set +x
2019-07-17 06:34:51.910 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
2019-07-17 06:34:51.910 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
===================== Chaincode is instantiated on peer0.org2 on channel 'mychannel' =====================

Querying chaincode on peer0.org1...
===================== Querying on peer0.org1 on channel 'mychannel'... =====================
+ peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
Attempting to Query peer0.org1 ...3 secs
+ res=0
+ set +x

100
===================== Query successful on peer0.org1 on channel 'mychannel' =====================
Sending invoke transaction on peer0.org1 peer0.org2...
+ peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'
+ res=0
+ set +x
2019-07-17 06:35:27.719 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
===================== Invoke transaction successful on peer0.org1 peer0.org2 on channel 'mychannel' =====================

Installing chaincode on peer1.org2...
+ peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02/go/
+ res=0
+ set +x
2019-07-17 06:35:27.809 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
2019-07-17 06:35:27.809 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
2019-07-17 06:35:28.060 UTC [chaincodeCmd] install -> INFO 003 Installed remotely response:<status:200 payload:"OK" >
===================== Chaincode is installed on peer1.org2 =====================

Querying chaincode on peer1.org2...
===================== Querying on peer1.org2 on channel 'mychannel'... =====================
+ peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
Attempting to Query peer1.org2 ...3 secs
+ res=0
+ set +x

90
===================== Query successful on peer1.org2 on channel 'mychannel' =====================

========= All GOOD, BYFN execution completed ===========


 _____   _   _   ____
| ____| | \ | | |  _ \
|  _|   |  \| | | | | |
| |___  | |\  | | |_| |
|_____| |_| \_| |____/
```


使用docker查看起来的服务：

```
➜  first-network git:(release-1.4) docker ps
CONTAINER ID        IMAGE                                                                                                  COMMAND                  CREATED             STATUS              PORTS                      NAMES
fe690a4f3e9f        dev-peer1.org2.example.com-mycc-1.0-26c2ef32838554aac4f7ad6f100aca865e87959c9a126e86d764c8d01f8346ab   "chaincode -peer.add…"   2 hours ago         Up 2 hours                                     dev-peer1.org2.example.com-mycc-1.0
03a5f82384a0        dev-peer0.org1.example.com-mycc-1.0-384f11f484b9302df90b453200cfb25174305fce8f53f4e94d45ee3b6cab0ce9   "chaincode -peer.add…"   2 hours ago         Up 2 hours                                     dev-peer0.org1.example.com-mycc-1.0
a737b47e9de6        dev-peer0.org2.example.com-mycc-1.0-15b571b3ce849066b7ec74497da3b27e54e0df1345daff3951b94245ce09c42b   "chaincode -peer.add…"   2 hours ago         Up 2 hours                                     dev-peer0.org2.example.com-mycc-1.0
8c2ccb5ee443        hyperledger/fabric-tools:latest                                                                        "/bin/bash"              2 hours ago         Up 2 hours                                     cli
5af5a3fb3bb7        hyperledger/fabric-peer:latest                                                                         "peer node start"        2 hours ago         Up 2 hours          0.0.0.0:8051->8051/tcp     peer1.org1.example.com
396b363bb6f5        hyperledger/fabric-peer:latest                                                                         "peer node start"        2 hours ago         Up 2 hours          0.0.0.0:7051->7051/tcp     peer0.org1.example.com
94be2011d20f        hyperledger/fabric-orderer:latest                                                                      "orderer"                2 hours ago         Up 2 hours          0.0.0.0:7050->7050/tcp     orderer.example.com
da8c17df215d        hyperledger/fabric-peer:latest                                                                         "peer node start"        2 hours ago         Up 2 hours          0.0.0.0:9051->9051/tcp     peer0.org2.example.com
fcd30620e876        hyperledger/fabric-peer:latest                                                                         "peer node start"        2 hours ago         Up 2 hours          0.0.0.0:10051->10051/tcp   peer1.org2.example.com
```

### 关闭

关闭`first-network`：

1. 依次停止channel、客户端、orderer、peer
2. 删除cli、orderer、peer、netowrk
3. 删除docker镜像

```
➜  first-network git:(release-1.4) ./byfn.sh down
Stopping for channel 'mychannel' with CLI timeout of '10' seconds and CLI delay of '3' seconds
Continue? [Y/n] y
proceeding ...
WARNING: The BYFN_CA1_PRIVATE_KEY variable is not set. Defaulting to a blank string.
WARNING: The BYFN_CA2_PRIVATE_KEY variable is not set. Defaulting to a blank string.
Stopping cli                    ... done
Stopping orderer.example.com    ... done
Stopping peer1.org1.example.com ... done
Stopping peer0.org1.example.com ... done
Stopping peer0.org2.example.com ... done
Stopping peer1.org2.example.com ... done
Removing cli                    ... done
Removing orderer.example.com    ... done
Removing peer1.org1.example.com ... done
Removing peer0.org1.example.com ... done
Removing peer0.org2.example.com ... done
Removing peer1.org2.example.com ... done
Removing network net_byfn
Removing volume net_orderer.example.com
Removing volume net_peer0.org1.example.com
Removing volume net_peer1.org1.example.com
Removing volume net_peer0.org2.example.com
Removing volume net_peer1.org2.example.com
Removing volume net_orderer2.example.com
WARNING: Volume net_orderer2.example.com not found.
Removing volume net_orderer3.example.com
WARNING: Volume net_orderer3.example.com not found.
Removing volume net_orderer4.example.com
WARNING: Volume net_orderer4.example.com not found.
Removing volume net_orderer5.example.com
WARNING: Volume net_orderer5.example.com not found.
Removing volume net_peer0.org3.example.com
WARNING: Volume net_peer0.org3.example.com not found.
Removing volume net_peer1.org3.example.com
WARNING: Volume net_peer1.org3.example.com not found.
05c281ff186c
f3ccbe5e2b80
7f0144ca0eae
Untagged: dev-peer1.org2.example.com-mycc-1.0-26c2ef32838554aac4f7ad6f100aca865e87959c9a126e86d764c8d01f8346ab:latest
Deleted: sha256:9425c8298cafe082ed22c5968d431a6098d53ef2318fb5d286efb96b4bc44915
Deleted: sha256:9005a0d9f52947d9256aa4766d4c26a9bab98f229aab7f2598da05789fc977ef
Deleted: sha256:98602d24729b179952f685f8f83f1effaf3733e7f93354a9d31b15f711bc0fac
Deleted: sha256:fe2b67155487d7e001c8a0b2ef100bb710b1b816897bc9d2a80029f4c7bd0b54
Untagged: dev-peer0.org1.example.com-mycc-1.0-384f11f484b9302df90b453200cfb25174305fce8f53f4e94d45ee3b6cab0ce9:latest
Deleted: sha256:0759f367d73c68e71b6077ebd46611d43a8d9c1c9ebc398b838010268b175d65
Deleted: sha256:2d56a884d5514a4467471cf06b42c0cfa492a80a239d48f79fa48273982d81b7
Deleted: sha256:614c6a2a164cc8afbb7f348fdf6d048834dc0cb2a94a22638b8d4dcd72eaeb14
Deleted: sha256:9a39bc364e8d141bdab60a80946e4af10513cb070c34e4bda1b1cbbf88f9dca3
Untagged: dev-peer0.org2.example.com-mycc-1.0-15b571b3ce849066b7ec74497da3b27e54e0df1345daff3951b94245ce09c42b:latest
Deleted: sha256:63a4ecd2677f62197f547b1cef9041e3f3ad5c929b1dcd139610b106862a92b5
Deleted: sha256:6a30b775f40f687d0ed98fe9d5fdd2da60ce22753b066db599e4308303f16c13
Deleted: sha256:d94c0213bc68b7ee8dfa942c82c07cf8d8b3e7a4d68cf5ca79d372557e5f6567
Deleted: sha256:c720d5e3b8c3b5690da0b10588517592ca11d94b3427cf75e88be0e000352ec9
```

## 启动自定义网络


### 利用byfn启动自定义网络

`./byfn.sh`不止`up`和`down`2个命令，还有其他命令，以及更多的参数，比如restart, generate和upgrade。

在上一节，使用了完全默认的参数，启动了网络，这是完全傻瓜式的。基于对fabric的掌握，还可以设置更多的参数，比如使用参数可以指定channel名称，而不是使用默认的`mychannel`，可以设置超时时间，使用指定docker编排文件创建各容器，指定chaincode的语言是Go还是Java等，还有更多的参数自己探索吧，设置一些参数重新启动网络。


```
➜  first-network git:(release-1.4) ./byfn.sh help
Usage:
  byfn.sh <mode> [-c <channel name>] [-t <timeout>] [-d <delay>] [-f <docker-compose-file>] [-s <dbtype>] [-l <language>] [-o <consensus-type>] [-i <imagetag>] [-a] [-n] [-v]
    <mode> - one of 'up', 'down', 'restart', 'generate' or 'upgrade'
      - 'up' - bring up the network with docker-compose up
      - 'down' - clear the network with docker-compose down
      - 'restart' - restart the network
      - 'generate' - generate required certificates and genesis block
      - 'upgrade'  - upgrade the network from version 1.3.x to 1.4.0
    -c <channel name> - channel name to use (defaults to "mychannel")
    -t <timeout> - CLI timeout duration in seconds (defaults to 10)
    -d <delay> - delay duration in seconds (defaults to 3)
    -f <docker-compose-file> - specify which docker-compose file use (defaults to docker-compose-cli.yaml)
    -s <dbtype> - the database backend to use: goleveldb (default) or couchdb
    -l <language> - the chaincode language: golang (default) or node
    -o <consensus-type> - the consensus-type of the ordering service: solo (default), kafka, or etcdraft
    -i <imagetag> - the tag to be used to launch the network (defaults to "latest")
    -a - launch certificate authorities (no certificate authorities are launched by default)
    -n - do not deploy chaincode (abstore chaincode is deployed by default)
    -v - verbose mode
  byfn.sh -h (print this message)

Typically, one would first generate the required certificates and
genesis block, then bring up the network. e.g.:

	byfn.sh generate -c mychannel
	byfn.sh up -c mychannel -s couchdb
        byfn.sh up -c mychannel -s couchdb -i 1.4.0
	byfn.sh up -l node
	byfn.sh down -c mychannel
        byfn.sh upgrade -c mychannel

Taking all defaults:
	byfn.sh generate
	byfn.sh up
	byfn.sh down
```

### 利用容器编排自定义网络

byfn中启动的各容器，其实都docker compose编排而成，这一节我们探索一下这些容器的编排，从容器层面，自定义fabric网络。

> docker compose是定义和启动多个Docker容器应用的工具。如果你不了解docker compose，有必要先学习一下[docker compose快速入门](https://yeasy.gitbooks.io/docker_practice/compose/)。

