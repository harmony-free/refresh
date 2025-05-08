import { BaseDataSource } from './BasicDataSource'
import { Animator, AnimatorOptions, AnimatorResult, promptAction } from '@kit.ArkUI'

export const RefreshCDecorator: ClassDecorator = (target) => {
  console.log("RefreshMDecorator：" + target.toString())
}

export const RefreshMDecorator: MethodDecorator = (target, propertyKey, descriptor) => {
  console.log("RefreshMDecorator：" + propertyKey.toString())
}

export const RefreshPDecorator: PropertyDecorator = (target, propertyKey) => {
  console.log("RefreshPDecorator：" + propertyKey.toString())
}


export interface PageFace {
  page: number
  size: number
  totalCount: number
}

interface RefreshDataFace<T> {
  load?: ((page?: PageFace) => Promise<boolean | Array<T>>)
  data?: Array<T>
  upData?: ((page?: PageFace) => Promise<boolean | Array<T>>)
  downData?: ((page?: PageFace) => Promise<boolean | Array<T>>)
}

@ObservedV2
export class RefreshData<T = object> implements PageFace {
  page: number = 0
  size: number = 20
  data: BaseDataSource<T> = new BaseDataSource<T>();
  totalCount: number = 100
  @Trace length: number = 0
  _pageFace: PageFace | undefined

  get pageFace(): PageFace {
    if (this._pageFace == undefined) {
      this._pageFace = { page: this.page, size: this.size, totalCount: this.totalCount } as PageFace
    }
    return this._pageFace
  }

  constructor(refresh?: RefreshDataFace<T>) {
    this.upData = refresh?.upData
    this.downData = refresh?.downData
    this.data.setData(refresh?.data ?? [])
    this.length = this.data.totalCount()
  }

  request?: (page?: PageFace) => Promise<boolean | Array<T>>
  upData?: (page?: PageFace) => Promise<boolean | Array<T>>
  downData?: (page?: PageFace) => Promise<boolean | Array<T>>

  refresh(): Promise<boolean> {
    this.pageFace.page = 0
    return new Promise((res, rej) => {
      if (this.upData) {
        this.upData(this.pageFace).then((data) => {
          if (data instanceof Array) {
            this.data.setData(data)
            this.length = this.data.totalCount()
            res(true)
          } else {
            res(data ?? false)
          }
        }).catch((err: Error) => {
          promptAction.showToast({ message: err.message })
          res(false)
        })
      } else {
        res(true)
      }
    })
  }

  loading(): Promise<boolean> {
    this.pageFace.page += 1
    return new Promise((res, rej) => {
      if (this.downData) {
        this.downData(this.pageFace).then((data) => {
          if (data instanceof Array) {
            this.data.pushData(...data)
            this.length = this.data.totalCount()
            res(true)
          } else {
            res(data ?? false)
          }
        }).catch((err: Error) => {
          promptAction.showToast({ message: err.message })
          res(false)
        })
      } else {
        res(true)
      }
    })
  }
}


export enum RefreshState {
  normal,
  runAll,
  runLoading,
  runRefresh,
  readLoading,
  readRefresh,
  onLoading,
  onRefresh,
  successLoading,
  failLoading,
  successRefresh,
  failRefresh,
}


@ObservedV2
export class RefreshUtils<T = object> extends RefreshData<T> {
  @Trace scroller: Scroller = new Scroller()
  @Trace state: RefreshState = RefreshState.normal
  @Trace offsetY: number = 0.0
  @Trace refreshTiming: Date = new Date()
  @Trace loadingTiming: Date = new Date()
  upHeight: number = 50
  downHeight: number = -50
  timing: number = 500
  max: number = 0
  eventY: number = 0.0
  @Trace animator: AnimatorUtils = new AnimatorUtils()

  isRefresh() {
    if (this.state == RefreshState.readRefresh ||
      this.state == RefreshState.runRefresh ||
      this.state == RefreshState.successRefresh ||
      this.state == RefreshState.failRefresh ||
      this.state == RefreshState.onRefresh) {
      return true
    } else {
      return false
    }
  }

  isLoading() {
    if (this.state == RefreshState.readLoading ||
      this.state == RefreshState.runLoading ||
      this.state == RefreshState.successLoading ||
      this.state == RefreshState.failLoading ||
      this.state == RefreshState.onLoading) {
      return true
    } else {
      return false
    }
  }


  onTouch(event: TouchEvent) {
    if (event == undefined) {
      return
    }
    if (event.type == TouchType.Move) {
      let offset = this.scroller.currentOffset()
      if ((offset.yOffset <= 0 && this.eventY == 0) && (this.scroller.isAtEnd() && this.eventY == 0)) {
        this.eventY = event.touches[0].y
        animateTo({
          duration: 150,
          delay: 50,
          onFinish: () => {
            this.eventY = event.touches[0].y
          }
        }, () => {
          this.eventY = event.touches[0].y
        })
        this.state = RefreshState.runAll
        this.max = offset.yOffset
        return
      } else {
        if (offset.yOffset <= 0 && this.eventY == 0) {
          this.eventY = event.touches[0].y
          this.state = RefreshState.runRefresh
        }
        if (this.scroller.isAtEnd() && this.eventY == 0) {
          this.eventY = event.touches[0].y
          this.state = RefreshState.runLoading
          this.max = offset.yOffset
        }
      }
      if (this.state == RefreshState.runAll) {
        this.offsetY = (event.touches[0].y - this.eventY) * 0.5
        if (this.offsetY >= 0) {
          this.state = RefreshState.runRefresh
        } else {
          this.state = RefreshState.runLoading
        }
      }


      if (this.state == RefreshState.runRefresh || this.state == RefreshState.readRefresh) {
        this.offsetY = (event.touches[0].y - this.eventY) * 0.5
        if (this.offsetY >= 0) {
          this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
          if (this.offsetY >= this.upHeight) {
            this.state = RefreshState.readRefresh
          } else {
            this.state = RefreshState.runRefresh
          }
        } else {
          this.offsetY = 0
          this.eventY = 0
          this.state = RefreshState.normal
        }
      }

      if (this.state == RefreshState.runLoading || this.state == RefreshState.readLoading) {
        this.offsetY = (event.touches[0].y - this.eventY) * 0.5
        if (this.offsetY <= 0) {
          this.scroller.scrollTo({ xOffset: 0, yOffset: this.max })
          if (this.offsetY <= this.downHeight) {
            this.state = RefreshState.readLoading
          } else {
            this.state = RefreshState.runLoading
          }
        } else {
          this.offsetY = 0
          this.eventY = 0
          this.state = RefreshState.normal
        }
      }

    } else if (event.type == TouchType.Up) {
      if (this.state == RefreshState.readRefresh && this.upData != undefined) {
        this.refreshTiming = new Date()
        this.state = RefreshState.onRefresh
        this.close(this.upHeight).then(() => {
          this.animator.animator.play()
          this.refresh().then((data) => {
            this.state = data ? RefreshState.successRefresh : RefreshState.failRefresh
            this.animator.animator.cancel()
            setTimeout(() => {
              this.close().then(() => {
                this.state = RefreshState.normal
                this.offsetY = 0
              })
            }, this.timing)
          })
        })
      } else if (this.state == RefreshState.readLoading && this.downData != undefined) {
        this.loadingTiming = new Date()
        this.state = RefreshState.onLoading
        this.close(this.downHeight).then(() => {
          this.animator.animator.play()
          this.loading().then((data) => {
            this.state = data ? RefreshState.successLoading : RefreshState.failLoading
            this.animator.animator.cancel()
            setTimeout(() => {
              this.close().then(() => {
                this.state = RefreshState.normal
                this.offsetY = 0
              })
            }, this.timing)
          })
        })
      } else {
        this.close().then(() => {
          this.state = RefreshState.normal
          this.offsetY = 0
        })
      }
    } else {

    }
  }

  async close(y: number = 0): Promise<boolean> {
    return new Promise<boolean>((res) => {
      animateTo({
        duration: 150,
        delay: 50,
        onFinish: () => {
          this.eventY = 0
          res(true)
        }
      }, () => {
        this.offsetY = y
      })
    })
  }
}

@ObservedV2
class AnimatorUtils {
  private options: AnimatorOptions = {
    duration: 1000,
    easing: "linear",
    delay: 0,
    fill: "forwards",
    direction: "normal",
    iterations: -1,
    begin: 0.0,
    end: 1.0
  };
  animator: AnimatorResult = Animator.create(this.options)
  @Trace progress: number = 0.0

  constructor(options: AnimatorOptions | undefined = undefined) {
    if (options != undefined) {
      this.animator.reset(options)
    }
    this.animator.onFrame = (p: number) => {
      this.progress = p
    }
  }
}
