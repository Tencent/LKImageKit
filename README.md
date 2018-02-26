# LKImageKit
## 简介
LKImageKit是一个高性能的图片框架，包括了图片控件，图片下载、内存缓存、磁盘缓存、图片解码、图片处理等一系列能力。合理的架构和线程模型，并特别针对不同场景进行优化，能充分发挥硬件的性能。

## introduction
LKImageKit is a high-performance image framework, including a series of capabilities such as image views, image downloader, memory caches, disk caches, image decoders, image processors. Reasonable architecture and threading model, and especially for different scenarios to optimize, give full play to the hardware performance

同时，该框架具有高度的扩展性。在此框架下，开发者可以自定义图片框架中的任何一个部分，比如：自定义图片显示逻辑、自定义缓存、自定义下载组件、自定义解码器、自定义图片处理算法等等。

The framework has a high degree of scalability. In this framework, developers can customize any part of the picture frame, such as: custom picture display logic, custom cache, custom downloader, custom decoders, Custom image processing algorithms and more.

![](https://github.com/Tencent/LKImageKit/blob/master/FastImageLoad.gif) 

## 主要特性：

-	支持取消

-	支持请求合并

-	支持渐进式加载

-	支持优先级

-	支持先加载小图再加载大图

-	支持预加载、预解码

-	线程安全

-	调度、解码、加载、处理使用独立线程、且有并发控制

-	高度模块化，可由开发者自定义各部分模块

## 	Main features:

-	Support canceled

-	Support for the request of the merger

-	Support for progressive loading

-	Support priority

-	Support the first load the thumbnail and then load the big picture

-	Support for preloading, pre-decoding

-	Thread safety

-	Scheduling, decoding, loading, dealing with the use of independent threads, and concurrency control

-	A high degree of modularity, developers can customize each part of the module

## 模块：

### 加载模块

-	网络文件加载（带文件缓存）

-	本地文件加载

-	相册加载

-	Bundle加载

### 解码模块

-	ImageIO

系统内置解码模块，支持PNG、JPG、GIF，支持渐进式解码

### 缓存模块

-	LRU、FIFO双队列缓存

-	MapTable自动缓存

## Module:

### Loader:

-	Network file loading (with file cache)

-	Local file loading

-	Album file loading

-	Bundle file loading

### Decoder:

-	ImageIO

  System built-in decoding module, support for PNG, JPG, GIF, support for progressive decoding

### Cache:

-	LRU, FIFO dual queue cache

-	MapTable automatically cache
