---
title: "筆記 - 網路 Overview"
categories: [筆記, 整理]
---

## 總之，網路是怎麼運作的？

<!--more-->

先從他的目標開始，也就是讓各個裝置能互相傳遞資料。要讓兩台電腦溝通，最 naive 的想法可能是規範某種物理接口和對應的線材，接線就能用了。但當裝置數量增加，每次都在兩台電腦間連著一條線不太實際，不如設計一個電腦是專門負責轉發這些資料，然後把所有裝置想辦法連到他就好了。

Switch (aka 交換器)就是在做這件事情，他會連接許多電腦形成 LAN (Local Area Network)。這個 LAN 裡面的電腦要把封包丟給其他電腦的時候，就會丟給 switch ， switch 會看封包上寫的目的地 (接收端 MAC Address) ，根據他存的一張實體 port 和 MAC address 對應的表來轉傳。這個處理資料的層級又被稱為 Link Layer，也會被稱為 Layer 2 。而 Layer 1 則是 Physical Layer ，也就是網路線、 WiFi 的無線電波的東東。

## IP之類的東西又是出現在哪裡？

這個就是 Network Layer ，也就是 Layer 3 主要負責的了。這裡用來辨別裝置的東西是 IP Address ，也就是長的像是 `140.112.30.26` 的一串數字。負責把封包轉傳到正確的 LAN 的機器叫做 router (aka 路由器)，找到一條由 `src` 往 `dst` 傳遞封包的路徑的這件事情就叫做route。

一台電腦通常同時會有很多的程式、服務在跑，而區別程式則是在 Transmission Layer ，也就是 Layer 4 做的。這裡是用不同的 "port" 來分，例如 `http` 通常是在 port 80 、 `https` 通常在 port 443。

Layer 5 是 Application Layer，有些比較細的分法 (像是 OSI Model) 會再細分。這裡的東西就比較跟應用相關，像是網頁的 `http` 、傳檔案的 `ftp` 、電子郵件的 `smtp` 、域名系統 `dns`。
