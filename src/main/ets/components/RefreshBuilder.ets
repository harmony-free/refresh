import { RefreshState, RefreshUtils } from '../RefreshUtils'
import { DrawableDescriptor } from '@ohos.arkui.drawableDescriptor'
import image from '@ohos.multimedia.image'
import { Size } from '@ohos/hypium'

@Builder
export function refreshBuilder(refresh: RefreshUtils) {
  if (refresh.isRefresh() && refresh.upData != undefined) {
    Row() {
      if (refresh.state == RefreshState.runRefresh) {
        Text("↓").fontSize(25)
      } else if (refresh.state == RefreshState.readRefresh) {
        Text("↑").fontSize(25)
      } else if (refresh.state == RefreshState.onRefresh) {
        Text() {
          SymbolSpan($r('sys.symbol.rays'))
        }.fontSize(25).rotate({ angle: refresh.animator.progress * 360 })
      } else {
        Text() {
          SymbolSpan(refresh.state == RefreshState.successRefresh ? $r('sys.symbol.checkmark') :
          $r('sys.symbol.xmark'))
        }.fontSize(25)
      }
      Column() {
        if (refresh.state == RefreshState.runRefresh) {
          Text("下拉可以刷新").fontSize(14)
        } else if (refresh.state == RefreshState.readRefresh) {
          Text("释放立即刷新").fontSize(14)
        } else if (refresh.state == RefreshState.onRefresh) {
          Text("正在刷新...").fontSize(14)
        } else {
          Text(refresh.state == RefreshState.successRefresh ? "刷新成功！" : "刷新失败！").fontSize(14)
        }
        Text(`上次更新:${refresh.refreshTiming.toLocaleTimeString()}`)
          .fontSize(12)
          .fontColor(0x999999)
          .padding({ top: 3 })
      }.padding({ left: 5 })
    }
    .height(50)
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .position({ top: 0 })
  } else if (refresh.isLoading() && refresh.downData != undefined) {
    Row() {
      if (refresh.state == RefreshState.runLoading) {
        Text("↑").fontSize(25)
      } else if (refresh.state == RefreshState.readLoading) {
        Text("↓").fontSize(25)
      } else if (refresh.state == RefreshState.onLoading) {
        Text() {
          SymbolSpan($r('sys.symbol.rays'))
        }.fontSize(25).rotate({ angle: refresh.animator.progress * 360 })
      } else {
        Text() {
          SymbolSpan(refresh.state == RefreshState.successLoading ? $r('sys.symbol.checkmark') :
          $r('sys.symbol.xmark'))
        }.fontSize(25)
      }
      Column() {
        if (refresh.state == RefreshState.runLoading) {
          Text("上拉可以加载").fontSize(14)
        } else if (refresh.state == RefreshState.readLoading) {
          Text("释放立即加载").fontSize(14)
        } else if (refresh.state == RefreshState.onLoading) {
          Text("正在加载...").fontSize(14)
        } else {
          Text(refresh.state == RefreshState.successLoading ? "加载成功！" : "加载失败！").fontSize(14)
        }
        Text(`上次加载:${refresh.loadingTiming.toLocaleTimeString()}`)
          .fontSize(12)
          .fontColor(0x999999)
          .padding({ top: 3 })
      }.padding({ left: 5 })
    }
    .height(50)
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .position({ bottom: 0 })
  }
}

export interface NormalInfoFace {
  img?: PixelMap | ResourceStr | DrawableDescriptor
  msg?: string
  imgSize?: SizeOptions
  show?: boolean
}

export  class NormalInfo implements NormalInfoFace {
  imgSize?: SizeOptions = {width:150,height:150}
  show?: boolean  = true
  img?: image.PixelMap | ResourceStr | DrawableDescriptor = $r('sys.media.ohos_ic_normal_white_grid_folder')
  msg?: string = '暂无数据'

  constructor(face?:NormalInfoFace) {
    if (face != undefined) {
      this.imgSize = face.imgSize ?? {width:150,height:150}
      this.msg = face.msg ?? '暂无数据'
      this.show = face.show ?? true
      this.img = face.img ?? $r('sys.media.ohos_ic_normal_white_grid_folder')
    }
  }
}

@Builder
export function NormalBuilder(info: NormalInfoFace = new NormalInfo) {
  if (info.show) {
    Column() {
      if (info.img) {
        Image(info.img).size(info.imgSize)
      }
      Text(info.msg).fontSize(20).fontColor(0xCCCCCC).margin({ bottom: 20, top: 10 })
    }.alignRules({
      center: { anchor: '__container__', align: VerticalAlign.Center },
      middle: { anchor: '__container__', align: HorizontalAlign.Center }
    })
    .enabled(false)
  }
}


export const refreshView = wrapBuilder(refreshBuilder)

export const normalView = wrapBuilder<[NormalInfoFace]>(NormalBuilder)