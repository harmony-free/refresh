import { PageFace, RefreshUtils } from "../RefreshUtils";
import { NormalInfo, NormalInfoFace, normalView, refreshView } from "./RefreshBuilder";

// List可以为任意组件
@Extend(List)
function refresh(refresh: RefreshUtils) {
  .offset({ x: 0, y: refresh.offsetY }) // 滑动的位置
  .onTouch((e) => refresh.onTouch(e)) // 滑动手势
  .enabled(refresh.state < 4) // 禁止在刷新或加载的过程中继续滑动
}

@Component
export struct RefreshList{
  @BuilderParam headerBuilderParam: () => void;
  @BuilderParam footerBuilderParam: () => void;
  @BuilderParam itemBuilderParam: (data: object ,index:number) => void;
  @BuilderParam refreshViewParam: (refresh: RefreshUtils) => void = this.refreshView;
  @BuilderParam normalViewParam: () => void = this.normalView;
  refresh: RefreshUtils = new RefreshUtils()
  normalInfo:NormalInfoFace = new NormalInfo();
  space:number = 0;
  initialIndex:number = 0;
  cachedCount:number = 3;


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
      List({ space: this.space,initialIndex:this.initialIndex, scroller: this.refresh.scroller }) {
        if (this.headerBuilderParam != undefined){
          this.headerBuilderParam()
        }
        LazyForEach(this.refresh.data, (data: object,index: number) => {
          ListItem() {
            this.itemBuilderParam(data,index)
          }
        }, (item: object, index: number) => index.toString())
        if (this.footerBuilderParam!=undefined){
          this.footerBuilderParam()
        }
      }
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