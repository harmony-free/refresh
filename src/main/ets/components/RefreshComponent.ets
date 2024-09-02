import { PageFace, RefreshState, RefreshUtils } from '../RefreshUtils'
import { NormalInfoFace, normalView, refreshView } from './RefreshBuilder'


export class CaseErrorModel {
  divisionalCaseId: number = 0
  divisionalCaseNo: string = ""
  state: number = 0
  deductionMemo: string = ""
  applyTime: string = ""
  errors: [] = []
  photoClaimReason: number = 0
  canFund: boolean = false
  icDivisionalCaseNo: string = ""
  canPhotoClaim: number = 0
  errorImageList: [] | undefined = undefined
}

@Component
export struct RefreshComponent {
  refresh: RefreshUtils = new RefreshUtils()
  info: NormalInfoFace | undefined
  @BuilderParam itemBuilderParam: <T>(data: T) => void = this.itemBuilder;

  @Builder
  itemBuilder() {
    Text("请根据需求创建item组件")
  }

  //
  // aboutToAppear(): void {
  //   this.refresh.refreshData.upData = this.upData
  // }
  //
  // upData(page?: PageFace | undefined): Promise<boolean | Array<CaseErrorModel>> {
  //   return new Promise<boolean | Array<CaseErrorModel>>((res, rej) => {
  //     res([new CaseErrorModel])
  //   })
  // }

  build() {
    RelativeContainer() {
      refreshView.builder(this.refresh)
      List({ space: 5, scroller: this.refresh.scroller }) {
        LazyForEach(this.refresh.refreshData.data, (data: object) => {
          ListItem() {
            this.itemBuilderParam(data)
          }.padding(10).backgroundColor(0xFFFFFF)
        }, (item: object, index: number) => index.toString())
      }
      .width('100%')
      .height('100%')
      .backgroundColor(0xEEEEEE)
      .padding({ top: 5 })
      .cachedCount(3)
      .edgeEffect(EdgeEffect.None, { alwaysEnabled: true })
      .offset({ x: 0, y: this.refresh.offsetY })
      .onTouch((e) => this.refresh.onTouch(e))

      normalView.builder(this.info ?? { msg: '暂无数据', show: this.refresh.refreshData.length == 0 })
    }.height('90%').clip(true)
  }
}