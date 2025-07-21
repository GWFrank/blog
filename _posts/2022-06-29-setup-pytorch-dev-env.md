---
title: "筆記 - 使用 conda 和 pip 建立 GPU 加速的 Pytorch 開發環境"
categories: [筆記, 開發]
tags: [pytorch]
---

## 事前準備

確認有裝 Nvidia 的 GPU，且已經安裝好驅動程式。Linux 上必須安裝來自 Nvidia 的專有驅動， `nouveau` 目前還不支援 CUDA API。

接著要裝 miniconda 來管理虛擬環境，前往[官網](https://docs.conda.io/en/latest/miniconda.html)下載安裝程式並執行。安裝後記得在終端機跑

```shell
conda init <shell name>
```

才會把 conda 的幾個資料夾加進 `$PATH`。最後重新開機或登入來確保環境變數有重載。

## 建立虛擬環境，安裝 Pytorch

首先建立名為 `ml-dev` 的 python 環境

```shell
conda create -n ml-dev python
```

這裡可以將 `ml-dev` 換成任何你喜歡的名字，也可以將 `python` 改成 `python=3.9` 之類的來指定 python 版本。

接著啟動 `ml-dev` 環境

```shell
conda activate ml-dev
```

現在你的 shell 的最左邊應該會出現 `(ml-dev)` 的字樣，表示你在這個環境中。

再來安裝 `cudatoolkit`

```shell
conda install cudatoolkit=<ver>
```

這裡要把 `<ver>` 換成目前 pytorch 支援的 CUDA 版本，請參考[官網](https://pytorch.org/get-started/locally/)。撰文時支援的有 11.3 ，所以就是

```shell
conda install cudatoolkit=11.3
```

最後我們用 pip 來安裝 pytorch 系列套件，正確的指令一樣要看[官網](https://pytorch.org/get-started/locally/)。撰文時 CUDA 11.3 用的指令是

```shell
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113
```

## （Optional）安裝其他常用的套件

Jupyter notebook 和一些可選的相依套件

```shell
pip install jupyter jupyterlab ipywidgets jupyter-server-proxy 
```

常用的工具

```shell
pip install pandas scikit-learn matplotlib tqdm
```

## 確認安裝成功

從終端機開啟互動模式的 python 跑

```python
>>> import torch
>>> torch.rand(5, 3)
tensor([[0.7419, 0.3134, 0.5156],
        [0.5850, 0.1292, 0.2272],
        [0.7379, 0.3957, 0.3188],
        [0.2656, 0.8373, 0.0506],
        [0.9171, 0.2297, 0.4550]])
>>> torch.cuda.is_available()
True
```

## 所以上面到底在做什麼？

簡單解釋一下上面到底做了甚麼事

- conda 是一個套件及環境管理工具，他可以管理 python 的各種套件，也可以管理在開發 python 程式時經常使用的一些系統端的套件，如 cudatoolkit, cudnn, qt
- pip 也是一個套件管理工具，但是他只能管理 python 的套件
- Nvidia GPU 驅動會提供某個版本的 CUDA Driver API，然後我們安裝的 cudatoolkit 會提供某個版本的 CUDA Runtime。跑起來的話需要 CUDA Driver API version >= CUDA Runtime version >= GPU hardware supported version

使用 pip 而非 conda 來管理 python 套件以下幾個優缺點

- pip 有的套件比較多，版本通常比較新
- 因為 pip 不會管你環境裡非 python 的套件版本，所以你必須自己注意，或是使用 conda 這類環境管理工具

另外盡量不要混用 pip 和 conda 來管理同一個環境內的 python 套件，很可能會弄得一團糟。理想情況是只用 conda 來管理所有套件，或是用 conda 裝好非 python 的 requirement 之後，只用 pip。
