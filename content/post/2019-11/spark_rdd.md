---
title: "Spark rdd算子调优"
date: 2019-11-05T17:44:57+08:00
draft: false
tags: ["Spark","rdd"]
tags_weight: 66
categories: ["Spark"]
keywords: ["Spark","rdd"]
summary: "rdd 算子调优方法"
---
### **前言**
在跑spark任务的时候，发现随着用户量的一个陡增，任务执行的时间突然长了起来，是时候该优化一下性能了~

#### **几个调优建议**
1. 对于同一份数据，只应该创建一个RDD，不能创建多个RDD来代表同一份数据
2. 应该尽量复用一个RDD，这样可以尽可能地减少RDD的数量，从而尽可能减少算子执行的次数。
3. 对多次使用的RDD进行持久化
      使用cache()方法 或  persist()方法
4. 能避免则尽可能避免使用reduceByKey、join、distinct、repartition等会进行 shuffle的算子，尽量使用map类的非shuffle算子
5. 尽量使用可以map-side预聚合的算子。
6. 使用高性能算子，如：
    - 使用reduceByKey/aggregateByKey替代groupByKey
    - 使用mapPartitions替代普通map
    - 使用foreachPartitions替代foreach
    - 使用filter之后进行coalesce操作
    - 使用repartitionAndSortWithinPartitions替代repartition与sort类操作

#### **发生数据倾斜调优**
##### **数据倾斜原理**
   - 在进行shuffle的时候，必须将各个节点上相同的key拉取到某个节点上的一个task来进行处理，比如按照key进行 聚合或join等操作。此时如果某个key对应的数据量特别大的话，就会发生数据倾斜
   - 比如大部分key对应10条数据，但是个别key却对应了100万 条数据，那么大部分task可能就只会分配到10条数据，然后1秒钟就运行完了；但是个别task可能分配到了100万数据，要运行一两个小时。因此，整 个Spark作业的运行进度是由运行时间最长的那个task决定的。

##### **调优方案**
   - 通过Hive来进行数据预处理， 把数据倾斜的发生提前到了Hive ETL中，避免Spark程序发生数据倾斜；
   - 如果导致倾斜的key就少数几个，则可以考虑过滤这几个key；
   - 提高shuffle操作的并行度， 在对RDD执行shuffle算子时，给shuffle算子传入一个参数，比如 reduceByKey(1000)，该参数就设置了这个shuffle算子执行时shuffle read task的数量；
   - 两阶段聚合（即局部聚合+全局聚合），性能提升较大
        - 原理：将原本相同的key通过附加随机前缀的方式，变成多个不同的key，就可以让原本被一个task处理的数据分散到多个task上去做局部聚合，进而解决单个task处理数据量过多的问题。接着去除掉随机前缀，再次进行全局聚合，就可以得到最终的结果。

