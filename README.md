# iOS-MyReader
简易 PDF 浏览器

## 前言
	
这个 简易PDF 阅读器， 我参考了网上第三方库 [Reader](https://github.com/vfr/Reader) 并对部分 UI 做了调整。 
![mypic2]({{site.url}}/img/postsimgs/2018-03-16-pic2.png) 
![mypic3]({{site.url}}/img/postsimgs/2018-03-16-pic3.png)
![mypic4]({{site.url}}/img/postsimgs/2018-03-16-pic4.png)
![mypic5]({{site.url}}/img/postsimgs/2018-03-16-pic5.png)
 

---
	
## 正文
 
 * Reader 源码的分析和理解
 * PDF 阅读器主要功能
 * 目前应用还存在的一些问题
 * 为什么要研发这款应用
 * 后续功能
 
#### Reader 源码的分析和理解
Reader 第三方库 主要架构如下
![mypic1]({{site.url}}/img/postsimgs/2018-03-16-reader1.png)

**ReaderViewController** 浏览 PDF 每页数据

**ReaderMainPagebar**  用于显示 PDF 每页缩略小图

**ReaderContentView**  用于显示 PDF 每页图片内容

**ReaderDocument** 记录 PDF 数据（总页数，路径，书签等）

![mypic1]({{site.url}}/img/postsimgs/2018-03-16-reader2.png)

**ThumbsViewController**  浏览 PDF 缩略图

**ReaderThumbCache** 把已绘制 PDF 每页图片保存至 NSCache 中

**ReaderThumbRequest** 记录发起生成 PDF 图片请求的相关数据

**ReaderThumbQueue** 线程队列，存储ReaderThumbFetch，ReaderThumbRender 实现多线程读取图片

**ReaderThumbFetch** 继承 NSOperation  读取沙盒中存在的单张 PDF 图片并在主线程中显示

**ReaderThumbRender** 继承 NSOperation 保存 PDF 单张图片至沙盒中

> 我对 Reader 第三库的理解：底层是基于 CoreGraphics 对 PDF 文件进行绘制，
> 用户每次阅读时开启线程 A 读取缓冲在沙盒中的缩略图，成功->显示。失败->开启线程 B 生成图片并保存至沙盒，主线程只显示当前第一张绘制的图片。
> 把保存图片和读取图片这些耗时的操作用多个子线程进去处理，从而优化用户的操作体验。

#### 应用主要功能
* 用浏览大多数 PDF 文件
* 设置书签
* 浏览全部 PDF 缩略图
* 可快速跳转至某一页
* 可在同一个网络内实现 Wifi 上传 PDF 文件，用到了第三方库（GCDWebServer）
* 可调节亮度


#### 目前应用还存在的一些问题
1、现在 PDF 页面的过度方式只能上下 or 左右 一页一页浏览，快速滚动浏览放大功能就会存在问题，目前还没有好的解决方法。

2、调节亮度的弹出层位置有点偏移（用苹果自带的 popupViewController 都有这个问题 iBook 上也是这样）。


#### 为什么要研发这款应用
我一直都有在手机上看 PDF 的习惯，之前用的是百度网盘，主要是同步数据比较方便，但百度网盘每次看的时候时不时会黑屏，几次之后果断决定抛弃。 之后在 App Store 也下了几个应用，有些功能真的好强大，可是自己并不需要那么多功能，而且我还发觉耗电量也是大问题。基于上述原因就萌生了为何不自己研发一个既简单又实用的应用呢？

#### 后续功能
1、添加页面模式，页面过度方式的设置

2、添加夜间模式
	
## 总结
 
一开始分析 Reader 源码的时候我的内心是拒绝，文件也不少，心想只要会用就行了，底层到底是如何实现并不是那么重要。但是仔细考虑之后内心总有疑惑，到底是如何实现快速浏览，如果不搞明白其内实现原理，就没法让自己有所提高。不是有句俗话说的好 “纸上得来终觉，绝知此事要躬行”。