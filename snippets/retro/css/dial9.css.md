# `retro/css/dial9.css`

## 1. Add wormhole/blackhole visibility and rotation rules

Find this existing block:

```css
div:not(.active) .ring-1 circle {
  fill: none !important;
}
```

Add this immediately after it:

```css
div:not(.active) .ring-1 .wormhole-gif {
  display: none;
}

.ring-1 .blackhole-gif,
.border.black-hole-active .ring-1 .wormhole-gif {
  display: none;
}

.border.black-hole-active .ring-1 .blackhole-gif {
  display: block;
}

.ring-1 .wormhole-gif {
  pointer-events: none;
  animation: wormholeSpin 240s linear infinite;
  transform-box: fill-box;
  transform-origin: center center;
}

.ring-1 .blackhole-gif {
  pointer-events: none;
}
```

## 2. Add the wormhole rotation keyframes

Find the existing `@keyframes spin` block near the bottom of the file.

Add this after it:

```css
@keyframes wormholeSpin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
```

## 3. Hide the center crosshair in idle and active states

What this does:

- removes the yellow `+` from the center of the Stargate
- removes the pulsing red dot while the page is idle without a wormhole
- keeps the wormhole GIF and blackhole GIF behavior unchanged

Find this existing block:

```css
.crosshair {
  display: flex;
```

Change it to:

```css
.crosshair {
  display: none;
```
