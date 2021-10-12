---
title: "筆電上使用Linux的幾個工具"
tags: [linux]
---

## TLDR

這篇文章會記錄幾個我在筆電上使用 Linux 時找到的一些工具，這些工具大多是補足一些 Windows 上不須額外設定就有，但 Linux 上需要自己去找的功能。

## 臉部辨識解鎖 - Howdy

[GitHub - boltgolt/howdy: 🛡️ Windows Hello™ style facial authentication for Linux](https://github.com/boltgolt/howdy)

Howdy 是一個提供臉部辨識驗證的工具，可以用在登入、解鎖、`sudo`等等。

### 安裝及設定

安裝步驟請參考 Github repo 裡面的 README。在等待安裝時，先用這個指令確定你要用的紅外線鏡頭是哪一個：

```bash
v4l2-ctl --list-devices
```

在輸出裡裝置可能有兩個或四個 `/dev/video*` ，大多數的情況下選擇第一個 (或是第三個，如果有的話) 會是對的。

安裝完成後先用這個指令設定 howdy：

```bash
sudo howdy config
```

在設定檔裡找到 `device_path`，並把它設為剛才找到的路徑。另外一個可以調整的參數是 `dark_threshold`，如果常常無法辨識成功的話，可以先把這個值提高。做好設定後先測試攝影機能不能正確運作：

```bash
sudo howdy test
```

確認能在跳出的視窗中看到自己的臉後，開始為你的使用者加入臉部模型：

```bash
sudo howdy add
```

如果是用 Ubuntu 的話到這裡就可以直接使用 howdy 了。 Arch 和 Manjaro 則需要編輯一些 pam 的設定檔，詳細步驟可以參考這個 [Setup face recognition authentication on ArchLinux and KDE Plasma using howdy · GitHub](https://gist.github.com/pastleo/76597c6ae8f95bb02982fea6df3a3ade)。

### 注意事項

- 非紅外線的鏡頭也是可以使用 howdy ，不過有紅外線鏡頭的話還是用紅外線比較好。

- Gnome keyring 、 kdewallet 在登入時可能沒辦法一起解鎖，不安全的解法是直接把這兩個的密碼拿掉，風險請自行評估。

- 在 SDDM (KDE預設的DM) 用 howdy 滿可能會有問題，我自己是換成用 LightDM 。

- 如同 README 裡作者於最後所說， howdy 並沒有比密碼安全，也不會變得比密碼安全。

## 觸控板手勢 - Touchégg

[Github - JoseExposito/Touchégg](https://github.com/JoseExposito/touchegg)

Touchegg 是一個提供可自訂觸控板手勢的工具，除了直接編輯 xml 檔案，也可以使用他的 GUI app [touche](https://github.com/JoseExposito/touche) 來做設定

### 安裝

直接參考 [README](https://github.com/JoseExposito/touchegg/blob/master/README.md)， Debian/Ubuntu 系的可以直接用官方 PPA ， Arch 系的有 AUR。

PPA:

```shell
sudo add-apt-repository ppa:touchegg/stable
sudo apt update
sudo apt install touchegg
```

Arch 系的安裝完後可能需要手動啟用 touchegg 的 service。

### 注意事項

- Touchegg 現在只能在 X11 上跑， Wayland 使用者可以試試看 [fusuma](https://github.com/iberianpig/fusuma)。
- Touchegg 底層是用 libinput ，所以只要支援 libinput 的就可以用。
