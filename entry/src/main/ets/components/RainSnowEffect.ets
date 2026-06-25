// ============================================================
// RainSnowEffect — 雨雪粒子动画组件
// 全屏 Canvas 绘制，props 驱动自动启停
// ============================================================

interface Particle {
  x: number;
  y: number;
  speed: number;
  length: number;
  opacity: number;
  drift: number;
  size: number;
  swing: number;
}

@Component
export struct RainSnowEffect {
  @Prop @Watch('onPropChanged') particleType: string = 'none';
  @Prop density: number = 1;

  private particles: Particle[] = [];
  private canvasW: number = 360;
  private canvasH: number = 800;
  private timerId: number = -1;
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D();

  onPropChanged(): void {
    this.restartAnimation();
  }

  aboutToDisappear(): void {
    this.stopAnimation();
  }

  restartAnimation(): void {
    this.stopAnimation();
    if (this.particleType === 'none') { return; }
    this.initParticles();
    this.timerId = setInterval((): void => { this.tick(); }, 33);
  }

  stopAnimation(): void {
    if (this.timerId > 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.particles = [];
    this.clearCanvas();
  }

  private clearCanvas(): void {
    let w: number = this.canvasW > 0 ? this.canvasW : 360;
    let h: number = this.canvasH > 0 ? this.canvasH : 800;
    this.ctx.clearRect(0, 0, w, h);
  }

  private initParticles(): void {
    let count: number = 0;
    if (this.particleType === 'rain') {
      count = this.density >= 2 ? 160 : 90;
    } else if (this.particleType === 'snow') {
      count = this.density >= 2 ? 100 : 55;
    }
    let w: number = this.canvasW > 0 ? this.canvasW : 360;
    let h: number = this.canvasH > 0 ? this.canvasH : 800;
    let pts: Particle[] = [];
    for (let i: number = 0; i < count; i++) {
      pts.push(this.createParticle(w, h, true));
    }
    this.particles = pts;
  }

  private createParticle(w: number, h: number, randomY: boolean): Particle {
    if (this.particleType === 'snow') {
      return {
        x: Math.random() * w,
        y: randomY ? Math.random() * h : -10,
        speed: 0.4 + Math.random() * 0.8,
        length: 0,
        opacity: 0.3 + Math.random() * 0.4,
        drift: (Math.random() - 0.5) * 0.5,
        size: 2 + Math.random() * 4,
        swing: Math.random() * Math.PI * 2
      };
    }
    return {
      x: Math.random() * w,
      y: randomY ? Math.random() * h : -20,
      speed: 4 + Math.random() * 6,
      length: 8 + Math.random() * 14,
      opacity: 0.15 + Math.random() * 0.25,
      drift: 0,
      size: 1.5,
      swing: 0
    };
  }

  private tick(): void {
    let w: number = this.canvasW > 0 ? this.canvasW : 360;
    let h: number = this.canvasH > 0 ? this.canvasH : 800;
    let updated: Particle[] = [];
    for (let i = 0; i < this.particles.length; i++) {
      let p: Particle = this.particles[i];
      if (this.particleType === 'snow') {
        p.y += p.speed;
        p.x += p.drift + Math.sin(p.swing + p.y * 0.01) * 0.5;
        p.swing += 0.02;
        if (p.y > h + 10) {
          updated.push(this.createParticle(w, h, false));
        } else { updated.push(p); }
      } else {
        p.y += p.speed;
        p.x -= 0.8;
        if (p.y > h + 10 || p.x < -20) {
          updated.push(this.createParticle(w, h, false));
        } else { updated.push(p); }
      }
    }
    this.particles = updated;
    this.drawCanvas(w, h);
  }

  private drawCanvas(w: number, h: number): void {
    let ctx: CanvasRenderingContext2D = this.ctx;
    ctx.clearRect(0, 0, w, h);
    if (this.particleType === 'snow') {
      for (let i = 0; i < this.particles.length; i++) {
        let p: Particle = this.particles[i];
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.fillStyle = 'rgba(255,255,255,' + p.opacity.toFixed(2) + ')';
        ctx.fill();
      }
    } else {
      ctx.lineWidth = 1.5;
      for (let i = 0; i < this.particles.length; i++) {
        let p: Particle = this.particles[i];
        ctx.beginPath();
        ctx.moveTo(p.x, p.y);
        ctx.lineTo(p.x + 4, p.y - p.length);
        ctx.strokeStyle = 'rgba(180,210,240,' + p.opacity.toFixed(2) + ')';
        ctx.stroke();
      }
    }
  }

  build() {
    Canvas(this.ctx)
      .width('100%').height('100%')
      .hitTestBehavior(HitTestMode.None)
      .onAreaChange((_: Area, newArea: Area): void => {
        let newW: number = newArea.width as number;
        let newH: number = newArea.height as number;
        if (newW > 0 && newH > 0) {
          this.canvasW = newW;
          this.canvasH = newH;
          if (this.particleType !== 'none') {
            this.restartAnimation();
          }
        }
      })
  }
}
