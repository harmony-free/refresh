# refresh

#### Description [中文](README.md)
This is a plugin for the loading and refreshing function of HONONG. There is no need to modify the UI structure of the source code! It can be applied to any list or other components. By modifying according to the attributes, you can achieve the refreshing effect, or you can customize the refreshing UI.

#### Software Architecture 
No invasion, even smoother!
Achieve the refreshing loading effect through the sliding component method.

#### Installation

`ohpm install @free/refresh`

#### Instructions


Simple example

```
    // Instantiation
    private refresh: RefreshUtils = new RefreshUtils()
    
    // building UI
    RelativeContainer() {
      // Loading and refreshing UI
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

1、Introduce utility classes

```
import { PageFace, RefreshUtils } from '../RefreshUtils'
```

2、Create an object and set the method for refreshing and loading (the RefreshModel generic type can be passed with a custom model or not)
The refreshing and loading methods are all configured with pagination capabilities

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

3、Add the refresh capability

```
List()
  .offset({ x: 0, y: this.refresh.offsetY })
  .onTouch((e) => this.refresh.onTouch(e))
  .enabled(this.refresh.state < 4)
```

4、An extension method can be defined.

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

5、Add the refreshed loading UI to the interface

`refreshView.builder(this.refresh)`

6、Set default image

```
if (this.refresh.length == 0) {
  normalView.builder(undefined)
}
```

7、Copy the entire code directly. Modify the configuration according to your own needs.

```
import { PageFace, RefreshUtils } from '../RefreshUtils'
import { normalView, refreshView } from './RefreshBuilder'

// List Can be applied to any component
@Extend(List)
function refresh(refresh: RefreshUtils) {
  .offset({ x: 0, y: refresh.offsetY }) // The sliding position
  .onTouch((e) => refresh.onTouch(e)) // Sliding gesture
  .enabled(refresh.state < 4) // Do not continue to swipe during the process of refreshing or loading.
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
      // Loading and refreshing UI
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

#### Contribution

1.  Fork the repository
2.  Create Feat_xxx branch
3.  Commit your code
4.  Create Pull Request


#### Gitee Feature

1.  You can use Readme\_XXX.md to support different languages, such as Readme\_en.md, Readme\_zh.md
2.  Gitee blog [blog.gitee.com](https://blog.gitee.com)
3.  Explore open source project [https://gitee.com/explore](https://gitee.com/explore)
4.  The most valuable open source project [GVP](https://gitee.com/gvp)
5.  The manual of Gitee [https://gitee.com/help](https://gitee.com/help)
6.  The most popular members  [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
