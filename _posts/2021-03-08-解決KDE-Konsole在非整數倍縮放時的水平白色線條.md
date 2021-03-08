---
title: "解決KDE Konsole在非整數倍縮放時的水平白色線條"
tags: [Linux, Kde, Konsole, solutions]
---

## Problem

KDE Konsole 在使用非整數倍縮放(1.25, 1.5 etc.)時，可能會出現如下圖的異常

![konsole_glitch](pics/konsole_glitch.png)

會有水平線條透出背後視窗的顏色

## Solution

「編輯設定檔」&rarr;「外觀」&rarr;「雜項」&rarr;「行間距」，把行間距設為1px(有些會需要更高)

![solution](pics/konsole_glitch_solution.png)