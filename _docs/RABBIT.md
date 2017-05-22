##日志分析

在HA的过程中可以看到较多如下pattern的日志。这个日志的操作是由nova detach volume时调用cinder api调用cinder volume产生的。
从日志中我们可以看到*2017-05-12 18:24:47.348*的时候cinder api到rabbitmq的连接断开了，这可能是由于网络不稳定造成的。
紧接这cinder api开始重连*192.168.35.11:5672*上的rabbitmq服务，并且连接成功。根据代码逻辑，连接成功后cinder api应该等待
刚才调用cinder volume的结果，**可是直到一分钟的超时都没有得到响应**。

由于cinder api没有得到需要的结果，它就将这个错误传递给了nova，于是nova detach出错，而nova detach是**灾难恢复**中的一个步骤，
所以整个恢复过程就失败了。
cinder api log on controller01
```
controller01_api.log:2017-05-12 18:24:47.231 4499 INFO cinder.api.openstack.wsgi [req-cd605658-cb9a-4784-90b2-d1419e073af4 d3f1a19cd5e44dfbb5a37b980d5fa0e3 4dd4c439ed38421f8d332b5067d4e951 - - -] POST http://192.168.35.66:9776/v1/4dd4c439ed38421f8d332b5067d4e951/volumes/d3b80069-13fb-477f-9ab8-22a23fedb462/action
controller01_api.log:2017-05-12 18:24:47.232 4499 DEBUG cinder.api.openstack.wsgi [req-cd605658-cb9a-4784-90b2-d1419e073af4 d3f1a19cd5e44dfbb5a37b980d5fa0e3 4dd4c439ed38421f8d332b5067d4e951 - - -] Action body: {"os-detach": {"attachment_id": "caae62e8-c94d-4903-bacd-ec29978c3157"}} get_method /usr/lib/python2.7/site-packages/cinder/api/openstack/wsgi.py:1010
controller01_api.log:2017-05-12 18:24:47.348 4499 ERROR oslo.messaging._drivers.impl_rabbit [req-cd605658-cb9a-4784-90b2-d1419e073af4 d3f1a19cd5e44dfbb5a37b980d5fa0e3 4dd4c439ed38421f8d332b5067d4e951 - - -] Failed to consume message from queue: [Errno 32] Broken pipe
controller01_api.log:2017-05-12 18:24:47.350 4499 INFO oslo.messaging._drivers.impl_rabbit [req-cd605658-cb9a-4784-90b2-d1419e073af4 d3f1a19cd5e44dfbb5a37b980d5fa0e3 4dd4c439ed38421f8d332b5067d4e951 - - -] Delaying reconnect for 1.0 seconds...
controller01_api.log:2017-05-12 18:24:48.351 4499 INFO oslo.messaging._drivers.impl_rabbit [req-cd605658-cb9a-4784-90b2-d1419e073af4 d3f1a19cd5e44dfbb5a37b980d5fa0e3 4dd4c439ed38421f8d332b5067d4e951 - - -] Connecting to AMQP server on 192.168.35.11:5672
controller01_api.log:2017-05-12 18:24:48.377 4499 INFO oslo.messaging._drivers.impl_rabbit [req-cd605658-cb9a-4784-90b2-d1419e073af4 d3f1a19cd5e44dfbb5a37b980d5fa0e3 4dd4c439ed38421f8d332b5067d4e951 - - -] Connected to AMQP server on 192.168.35.11:5672
controller01_api.log:2017-05-12 18:25:47.349 4499 ERROR cinder.api.middleware.fault [req-cd605658-cb9a-4784-90b2-d1419e073af4 d3f1a19cd5e44dfbb5a37b980d5fa0e3 4dd4c439ed38421f8d332b5067d4e951 - - -] Caught error: Timed out waiting for a reply to message ID 05e7583273454928b8924023f83d0efa.
controller01_api.log:2017-05-12 18:25:47.355 4499 INFO cinder.api.middleware.fault [req-cd605658-cb9a-4784-90b2-d1419e073af4 d3f1a19cd5e44dfbb5a37b980d5fa0e3 4dd4c439ed38421f8d332b5067d4e951 - - -] http://192.168.35.66:9776/v1/4dd4c439ed38421f8d332b5067d4e951/volumes/d3b80069-13fb-477f-9ab8-22a23fedb462/action returned with HTTP 500
controller01_api.log:2017-05-12 18:25:47.357 4499 INFO eventlet.wsgi.server [req-cd605658-cb9a-4784-90b2-d1419e073af4 d3f1a19cd5e44dfbb5a37b980d5fa0e3 4dd4c439ed38421f8d332b5067d4e951 - - -] Traceback (most recent call last):
controller01_api.log:2017-05-12 18:25:47.358 4499 INFO eventlet.wsgi.server [req-cd605658-cb9a-4784-90b2-d1419e073af4 d3f1a19cd5e44dfbb5a37b980d5fa0e3 4dd4c439ed38421f8d332b5067d4e951 - - -] 192.168.35.11 - - [12/May/2017 18:25:47] "POST /v1/4dd4c439ed38421f8d332b5067d4e951/volumes/d3b80069-13fb-477f-9ab8-22a23fedb462/action HTTP/1.1" 500 0 60.166289
```

##问题分析
根据上面的分析, 我这边看到的一个问题在于为什么cinder api已经跟rabbitmq连接成功了，而且cinder volume也成功detach了volume，为什么
cinder api一直没有得到response呢？
Rabbitmq其实提供的是一个队列服务，而高可用配置下的rabbitmq就是每个rabbitmq的节点上都有一份队列的拷贝，
每个给队列发送消息的服务叫生产者，而接受消息的就叫消费者，像这里的cinder api在等待函数返回时所扮演的就是消费者，
而cinder volume就是生产者。在这段日志发生之前消费者（cinder api）连接的是*192.168.35.13:5672*这个rabbitmq服务，
重连之后连接的是*192.168.35.11:5672*上的rabbitmq服务。由于这次连接断开属于非正常断开，rabbitmq节点不知道发生了，连接断开这个事件，
也就是所有cinder volume的消息还是发往了，原先连接*192.168.35.13:5672*的队列，造成消息没有被接受。
那么多久之后rabbitmq会知道这个已经断开的连接不存在了呢？根据地铁环境的配置是60+2*5=70秒，而rpc的超时时间是60秒，所以队列状态没有
及时更新导致，接受消息失败。

##解决方案
**根据上面的分析，我这边给出的一个参数调整是将tcp keep alive的时间减小(原70秒）到60秒以下，或者增加rpc的超时。**
