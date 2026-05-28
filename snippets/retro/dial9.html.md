# `retro/dial9.html`

Edit only the first gate ring block:

```html
<div class="gate ring-1">
```

## 1. Add the circular clip path

Inside the first `<defs>` block, before:

```html
<radialGradient id="radialGradient"
```

add:

```html
<clipPath id="wormholeClip">
  <circle cx="337" cy="335" r="237" />
</clipPath>
```

## 2. Replace the original wormhole circle line

Find this original line:

```html
<circle cx="337" cy="335" r="237" stroke="var(--color)" fill="url(#radialGradient)" stroke-width="4.96px"/></svg>
```

Replace it with these three lines:

```html
<image class="wormhole-gif" href="images/wormhole.gif" x="29" y="27" width="616" height="616" preserveAspectRatio="xMidYMid slice" clip-path="url(#wormholeClip)"/>
<image class="blackhole-gif" href="images/blackhole.gif" x="29" y="27" width="616" height="616" preserveAspectRatio="xMidYMid slice" clip-path="url(#wormholeClip)"/>
<circle cx="337" cy="335" r="237" stroke="var(--color)" fill="transparent" stroke-width="4.96px"/></svg>
```
