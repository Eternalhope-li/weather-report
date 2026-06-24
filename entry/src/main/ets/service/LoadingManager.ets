/**
 * 全局Loading管理器
 * 使用AppStorage维护全局状态，支持嵌套计数防冲突
 * 对外只暴露 show() / hide() 两个方法
 */
const LOADING_KEY: string = "globalLoading";

class LoadingManager {
  private counter: number = 0;
  private safetyTimer: number = -1;

  show(): void {
    this.counter++;
    if (this.counter === 1) {
      AppStorage.setOrCreate<boolean>(LOADING_KEY, true);
    }
    this.resetSafetyTimer();
  }

  hide(): void {
    this.counter = Math.max(0, this.counter - 1);
    if (this.counter === 0) {
      AppStorage.setOrCreate<boolean>(LOADING_KEY, false);
      this.clearSafetyTimer();
    }
  }

  reset(): void {
    this.counter = 0;
    AppStorage.setOrCreate<boolean>(LOADING_KEY, false);
    this.clearSafetyTimer();
  }

  private resetSafetyTimer(): void {
    this.clearSafetyTimer();
    this.safetyTimer = setTimeout((): void => {
      if (this.counter > 0) {
        console.warn("LoadingManager safety reset after 30s timeout, counter=" + this.counter);
        this.counter = 0;
        AppStorage.setOrCreate<boolean>(LOADING_KEY, false);
      }
    }, 30000);
  }

  private clearSafetyTimer(): void {
    if (this.safetyTimer > 0) {
      clearTimeout(this.safetyTimer);
      this.safetyTimer = -1;
    }
  }
}

const loadingManager: LoadingManager = new LoadingManager();
export default loadingManager;
