# refresh

#### 介绍

这是鸿蒙的一个加载刷新功能的插件，不需要修改源代码的UI结构！它可以用在任意列表或其他组件上面，通过修改自己按属性达到刷新效果，也可以自定义刷新UI

#### 软件架构

无入侵，更丝滑！
通过滑动组件的方式达到刷新加载的效果

#### 安装教程

`ohpm install @free/refresh`

#### 使用说明

简单例子

```
    // 实例化
    private refresh: RefreshUtils = new RefreshUtils()
    
    // 构建UI
    RelativeContainer() {
      // 加载刷新的UI
      refreshView.builder(this.refresh)
      List({ space: 5, scroller: this.refresh.scroller }) {
        LazyForEach(this.refresh.data, (data: Object) => {
          ListItem() {
            this.itemBuilderParam(data)
          }.padding(10).backgroundColor(0xFFFFFF)
        }, (item: RefreshModel, index: number) => index.toString())
      }
      .refresh(this.refresh)

      if (this.refresh.length == 0) {
        normalView.builder(undefined)
      }
    }.height('90%').clip(true)
```

1、引入工具类

```
import { PageFace, RefreshUtils } from '../RefreshUtils'
```

2、创建对象，并设置刷新加载的方法(RefreshModel 泛型可传如自定义model 也可以不传)
刷新加载方法均配置分页能力

```
  refresh: RefreshUtils<RefreshModel> = new RefreshUtils<RefreshModel>()

  this.refresh.upData = this.upData
  this.refresh.downData = this.downData

  upData(page?: PageFace | undefined): Promise<boolean | Array<RefreshModel>> {
    return new Promise<boolean | Array<RefreshModel>>((res, rej) => {
      setTimeout(() => {
        res([new RefreshModel()])
      }, 2000)
    })
  }

  downData(page?: PageFace | undefined): Promise<boolean | Array<RefreshModel>> {
    return new Promise<boolean | Array<RefreshModel>>((res, rej) => {
      setTimeout(() => {
        res([new RefreshModel])
      }, 2000)
    })
  }

```

3、添加刷新能力

```
List()
  .offset({ x: 0, y: this.refresh.offsetY })
  .onTouch((e) => this.refresh.onTouch(e))
  .enabled(this.refresh.state < 4)
```

4、可以定义一个扩展方法

```
@Extend(List)
function refresh(refresh: RefreshUtils) {
  .offset({ x: 0, y: refresh.offsetY })
  .onTouch((e) => refresh.onTouch(e))
  .enabled(refresh.state < 4)
}

List()
    .refresh(this.refresh)
```

5、把刷新加载的UI添加到界面

`refreshView.builder(this.refresh)`

6、设置默认图

```
if (this.refresh.length == 0) {
  normalView.builder(undefined)
}
```

7、直接复制全部代码 根据自己的需求修改配置

```
import { PageFace, RefreshUtils } from '../RefreshUtils'
import { normalView, refreshView } from './RefreshBuilder'

// List可以为任意组件
@Extend(List)
function refresh(refresh: RefreshUtils) {
  .offset({ x: 0, y: refresh.offsetY }) // 滑动的位置
  .onTouch((e) => refresh.onTouch(e)) // 滑动手势
  .enabled(refresh.state < 4) // 禁止在刷新或加载的过程中继续滑动
}

export class RefreshModel {
  title: string = "RefreshModel"
}

@Component
export struct RefreshComponent {
  refresh: RefreshUtils<RefreshModel> = new RefreshUtils<RefreshModel>()

  @Builder
  itemBuilder(data: RefreshModel) {
    Text(data.title)
  }

  aboutToAppear(): void {
    this.refresh.upData = this.upData
    this.refresh.downData = this.downData
  }

  upData(page?: PageFace | undefined): Promise<boolean | Array<RefreshModel>> {
    return new Promise<boolean | Array<RefreshModel>>((res, rej) => {
      setTimeout(() => {
        res([new RefreshModel()])
      }, 2000)
    })
  }

  downData(page?: PageFace | undefined): Promise<boolean | Array<RefreshModel>> {
    return new Promise<boolean | Array<RefreshModel>>((res, rej) => {
      setTimeout(() => {
        res([new RefreshModel])
      }, 2000)
    })
  }

  build() {
    RelativeContainer() {
      // 加载刷新的UI
      refreshView.builder(this.refresh)
      List({ space: 5, scroller: this.refresh.scroller }) {
        LazyForEach(this.refresh.data, (data: RefreshModel) => {
          ListItem() {
            this.itemBuilder(data)
          }.padding(10).backgroundColor(0xFFFFFF)
        }, (item: RefreshModel, index: number) => index.toString())
      }
      .width('100%')
      .height('100%')
      .backgroundColor(0xEEEEEE)
      .padding({ top: 5 })
      .cachedCount(3)
      .refresh(this.refresh)

      if (this.refresh.length == 0) {
        normalView.builder(undefined)
      }
    }.height('90%').clip(true)
  }
}
```

#### 参与贡献

1. Fork 本仓库
2. 新建 Feat_xxx 分支
3. 提交代码
4. 新建 Pull Request

#### 特技

1. 使用 Readme\_XXX.md 来支持不同的语言，例如 Readme\_en.md, Readme\_zh.md
2. Gitee 官方博客 [blog.gitee.com](https://blog.gitee.com)
3. 你可以 [https://gitee.com/explore](https://gitee.com/explore) 这个地址来了解 Gitee 上的优秀开源项目
4. [GVP](https://gitee.com/gvp) 全称是 Gitee 最有价值开源项目，是综合评定出的优秀开源项目
5. Gitee 官方提供的使用手册 [https://gitee.com/help](https://gitee.com/help)
6. Gitee 封面人物是一档用来展示 Gitee 会员风采的栏目 [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
