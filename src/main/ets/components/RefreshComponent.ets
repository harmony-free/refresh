import { PageFace, RefreshUtils } from '../RefreshUtils'
import { normalView, upView } from './RefreshBuilder'


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
  refresh: RefreshUtils<RefreshModel> = new RefreshUtils<RefreshModel>({ upData: this.upData, downData: this.downData })
  @BuilderParam itemBuilderParam: (data: RefreshModel) => void = this.itemBuilder;
  @BuilderParam upBuilderParam: (refresh: RefreshUtils<RefreshModel>) => void
  @BuilderParam downBuilderParam: (refresh: RefreshUtils<RefreshModel>) => void

  @Builder
  itemBuilder(data: RefreshModel) {
    Text(data.title)
  }

  // aboutToAppear(): void {
  //   this.refresh.upData = this.upData
  //   this.refresh.downData = this.downData
  // }

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
      upView.builder(this.refresh)
      List({ space: 5, scroller: this.refresh.scroller }) {
        LazyForEach(this.refresh.data, (data: RefreshModel) => {
          ListItem() {
            this.itemBuilderParam(data)
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

