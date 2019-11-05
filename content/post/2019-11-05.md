---
title: "JVM GC算法初探"
date: 2019-11-05T16:03:20+08:00
draft: false
tags: ["Java","GC","Heap","JVM"]
tags_weight: 66
categories: ["Java"]
keywords: [ "JVM", "GC","Java"]
summary: "jvm垃圾回收算法了解"
---

#### 年轻代，老年代，永久代（Metaspace ）存放什么对象？
* heap包含年轻代和老年代，永久代是另一块内存；
* 年轻代用来存放新近创建的对象，对象更新速度快，在短时间内产生大量的“死亡对象”
* 老年代是从年轻代Survivor 区域中熬过来的对象或者大对象，fullgc时清理；
* 永久代存放class信息、常量、静态变量等数据，fullgc时清理；

#### CMS和G1收集器(算法)的区别？
* CMS（Concurrent Mark and Sweep）是以牺牲吞吐量为代价来获得最短停顿时间的垃圾回收器，主要适用于对响应时间的侧重性大于吞吐量的场景。仅针对老年代（Tenured Generation）的回收。
    1. 为求达到该目标主要是因为以下两个原因：
    
        i.  没有采取compact操作，而是简单的mark and sweep，同时维护了一个free list来管理内存空间，所以也产生了大量的内存碎片。
        
        ii. mark and sweep分为多个阶段，其中大部分的阶段的GC线程是和用户线程并发执行，默认的GC线程数为物理CPU核心数的1/4。
    2. gc参数
  ```
  -XX:+UseConcMarkSweepGC - 启用CMS，同时-XX:+UseParNewGC会被自动打开
  -XX:CMSInitiatingOccupancyFraction - 设置第一次启动CMS的阈值，默认是68%
  -XX:+UseCMSInitiatingOccupancyOnly - 只是用设定的回收阈值，如果不指定，JVM仅在第一次使用设定值，后续则自动调整
  -XX:+CMSPermGenSweepingEnabled - 回收perm区
  -XX:+CMSConcurrentMTEnabled 默认为true。
  -XX:+UseCMSCompactAtFullCollection 默认为true。
  -XX:+CMSFullGCsBeforeCompaction 默认是0
  -XX:+CMSParallelRemarkEnabled 默认为ture
  -XX:+CMSScavengeBeforeRemark 强制remark之前开始一次minor GC默认为false
  ```
* G1收集器（或者垃圾优先收集器）的设计初衷是为了尽量缩短处理超大堆时产生的停顿。在回收的时候将对象从一个小堆区复制到另一个小堆区，这意味着G1在回收垃圾的时候同时完成了堆的部分内存压缩，相对于CMS的优势而言就是内存碎片的产生率大大降低。
  1. gc参数
  ```
  -XX:+UseG1GC 启用G1垃圾收集器
  -XX:MaxGCPauseMillis=n 指定期望的最大停顿时间
  -XX:G1HeapRegionSize=n 设置的 G1 区域的大小，值是 2 的幂
  -XX:ParallelGCThreads=n 设置 STW 工作线程数的值。将 n 的值设置为逻辑处理器的数量
  -XX:ConcGCThreads=n 设置并行标记的线程数。将 n 设置为并行垃圾回收线程数 
  -XX:InitiatingHeapOccupancyPercent=45 设置触发标记周期的 Java 堆占用率阈值。默认占用率是整个 Java 堆的 45%
  -XX:G1ReservePercent=n 设置堆内存保留为假天花板的总量
  ```