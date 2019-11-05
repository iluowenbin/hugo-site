---
title: "JVM GC原因了解"
date: 2019-11-05T11:03:20+08:00
draft: false
tags: ["Java","GC","Heap","JVM"]
tags_weight: 66
categories: ["Java"]
keywords: [ "JVM", "GC","Java"]
summary: "jvm垃圾回收了解"
---

### **前言**
前阵子写了个bug，线上服务跑了十几天后突然不断gc，cpu嗨到90%，排查问题的过程回顾了下java gc相关的知识。

#### **堆内存介绍**
1. 堆内存分为Eden，Survivor，Tenured/old空间;
2. 从年轻代空间（包括 Eden 和 Survivor 区域）回收内存被称为 Minor GC;
3. 对老年代GC称为Major GC;
4. Major GC的速度一般会比Minor GC慢10倍以上;

#### **触发JVM GC原因及应对策略**
**1. System.gc()方法的调用**
   
   - 建议能不使用此方法就别使用，让虚拟机自己去管理它的内存，可禁止RMI调用System.gc;
    ```shell script
    -XX:+ DisableExplicitGC
    ```

**2. 老年代空间不足**

   - 老年代空间只有在新生代对象转入及创建为大对象、大数组时才会出现不足的现象，当执行Full GC后空间仍然不足，则抛出如下错误;
    ```
    java.lang.OutOfMemoryError: Java heap space
    ```
    - 为避免以上两种状况引起的Full GC，调优时应尽量做到让对象在Minor GC阶段被回收、让对象在新生代多存活一段时间及不要创建过大的对象及数组;

**3. 永生区空间不足**
    
   - JVM规范中运行时数据区域中的方法区，在HotSpot虚拟机中又被习惯称为永生代或者永生区;
   - Permanet Generation中存放的为一些class的信息、常量、静态变量等数据，当系统中要加载的类、反射的类和调用的方法较多时，Permanet Generation可能会被占满，在未配置为采用CMS GC的情况下也会执行Full GC。如果经过Full GC仍然回收不了，那么JVM会抛出如下错误信息:
   ```
    java.lang.OutOfMemoryError: PermGen space
   ```
   - 为避免Perm Gen占满造成Full GC现象，可采用的方法为增大Perm Gen空间或转为使用CMS GC;

**4. CMS GC时出现promotion failed和concurrent mode failure**
    
   - promotion failed是在进行Minor GC时，survivor space放不下、对象只能放入老年代，而此时老年代也放不下造成的;
   - concurrent mode failure是在执行CMS GC的过程中同时有对象要放入老年代，而此时老年代空间不足造成的（有时候“空间不足”是CMS GC时当前的浮动垃圾过多导致暂时性的空间不足触发Full GC）;
   - 增大survivor space、老年代空间或调低触发并发GC的比率可通过设置CMSMaxAbortablePrecleanTime来避免;
    ```
    -XX: CMSMaxAbortablePrecleanTime=5（单位为ms）
    ```

**5. 堆中分配很大的对象**
    
   - 所谓大对象，是指需要大量连续内存空间的java对象，例如很长的数组，此种对象会直接进入老年代，而老年代虽然有很大的剩余空间，但是无法找到足够大的连续空间来分配给当前对象，此种情况就会触发JVM进行Full GC;
   - CMS垃圾收集器提供了一个可配置的参数，即-XX:+UseCMSCompactAtFullCollection开关参数，用于在“享受”完Full GC服务之后额外免费赠送一个碎片整理的过程，内存整理的过程无法并发的，空间碎片问题没有了，但提顿时间不得不变长了;
   - JVM设计者们还提供了另外一个参数 -XX:CMSFullGCsBeforeCompaction,这个参数用于设置在执行多少次不压缩的Full GC后,跟着来一次带压缩的；

**6. 在程序中长期持有了对象的引用，对象年龄达到指定阈值也会进入老年代;**

