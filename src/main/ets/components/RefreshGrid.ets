import { PageFace, RefreshUtils } from "../RefreshUtils";
import { NormalInfo, NormalInfoFace, normalView, refreshView } from "./RefreshBuilder";

// List可以为任意组件
@Extend(Grid)
function refresh(refresh: RefreshUtils) {
  .offset({ x: 0, y: refresh.offsetY }) // 滑动的位置
  .onTouch((e) => refresh.onTouch(e)) // 滑动手势
  .enabled(refresh.state < 4) // 禁止在刷新或加载的过程中继续滑动
}

@Component
export struct RefreshGrid{
  @BuilderParam headerBuilderParam: () => void;
  @BuilderParam footerBuilderParam: () => void;
  @BuilderParam itemBuilderParam: (data: object ,index:number) => void;
  @BuilderParam refreshViewParam: (refresh: RefreshUtils) => void = this.refreshView;
  @BuilderParam normalViewParam: () => void = this.normalView;
  refresh: RefreshUtils = new RefreshUtils()
  columnsTemplate:string = '1fr 1fr 1fr 1fr 1fr'
  cachedCount:number = 5;
  gap:number = 0;
  normalInfo:NormalInfoFace = new NormalInfo;

  @Builder refreshView(refresh: RefreshUtils){
    // 加载刷新的UI
    refreshView.builder(this.refresh)
  }

  @Builder normalView(){
    // 加载刷新的UI
    normalView.builder(this.normalInfo)
  }

  build() {
    RelativeContainer() {
      this.refreshViewParam(this.refresh)
      Grid(this.refresh.scroller) {
        if (this.headerBuilderParam != undefined){
          this.headerBuilderParam()
        }
        LazyForEach(this.refresh.data, (data: object,index: number) => {
          GridItem() {
            this.itemBuilderParam(data,index)
          }
        }, (item: object, index: number) => index.toString())
        if (this.footerBuilderParam!=undefined){
          this.footerBuilderParam()
        }
      }
      .scrollBar(BarState.Off)
      .columnsTemplate(this.columnsTemplate)
      .columnsGap(this.gap)
      .rowsGap(this.gap)
      .width('100%')
      .height('100%')
      .cachedCount(this.cachedCount)
      .refresh(this.refresh)

      if (this.refresh.length == 0 && this.headerBuilderParam == undefined && this.footerBuilderParam == undefined) {
        this.normalViewParam()
      }
    }.clip(true)
  }
}