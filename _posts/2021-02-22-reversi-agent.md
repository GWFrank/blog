---
title: "計概期末專題 - 黑白棋Agent"
categories: [Projects]
tags: [minimax, reversi]
---

## TLDR

今年(109-1)計概單班的期末專題(其實應該只算是一次作業？)是做一個黑白棋Agent，我和隊友用minimax + 神經網路做的evaluation實做，最後在31組中拿下第一名，對所有其他組都有超過0.5的勝率。這篇文章將會稍微紀錄一下開發的過程和一些心得及想法。

<!--more-->

## Initial Plan

在這次project之前我並沒有開發過類似的東西，所以完全是第一次的嘗試。一開始先隨便丟了幾個想法，然後找有沒有人做過類似的東西，找到了[棋類AI(以五子棋為例)](https://reurl.cc/d5j9yV)、[電腦黑白棋](https://reurl.cc/m9j7M1)、[A Genetic Algorithm to Improve an Othello Program](https://reurl.cc/9XYxvn)。這幾個都是用minimax當基底做的，到這裡我們也大概確定接下來會是做minimax，evaluation function先做最簡單的查表，再看看有什麼可以改良的。

## Basic Minimax

### 理論(?)

首先來簡單講一下minimax在做什麼。理想上，minimax會把整個遊戲樹都算好，接著從遊戲樹的底端往上，白方選擇會對白方最有利的位置下棋，黑棋則反之，一路推回去後就知道哪個位置是最佳的策略。但是因為計算時間有限，30秒內要把黑白棋全部都算完近乎不可能，我們必須要設定搜尋深度的上限。當搜尋到了上限的深度時，必須使用一個函數(evaluation function)為目前的盤面打分數來取代繼續往下搜尋。這個分數必須要能很好的反應出佔有優勢的一方，也就是(在我們的實做中)分數越高表示白棋越可能贏，分數越低表示黑棋越可能贏。

### 實做

實做的第一步是刻一個找出合法下棋位置的function，這裡沒有用什麼特別的演算法來做。有測試過使用`set`和`list`紀錄合法位置的速度，最後發現是`list`快一點點，但其實沒有顯著的影響。另外原本是用2d的`list`當作棋盤做搜尋，後面改用1d的可以加快一些(大約多搜一層)。

再來是實際刻Minimax。這部份其實是隊友刻的，照他所述他就是把wikipedia上面的psuedo code翻成python再修改一下而已。Evaluation function這時候是用在前面提到的論文內的一個表，將棋子以那張表加權後相加，計算盤面分數。

## Improvements

最初未經改良的Minimax要在時間限制內完成比賽大概只能搜尋3層而已。用python的`cProfile`工具，抓出搜尋合法位置的`getAvailableSpot()`佔用不少時間，稍加優化後能多搜尋一層。

另一個優化的點是使用Alpha-Beta剪枝，這個剪枝的核心思想是如果「目前這條分支的最佳可能情況」比前面已經得到的「其他分之的最佳情況」還糟的話，就不用繼續搜尋下去。這個優化又讓我們能夠多搜尋一層，搜尋5層時可以10秒完成一場比賽，搜尋6層時壓線在25秒內完成。最後的程式碼大概如下：

```python
def minimax_adj(obs, color, depth, alpha, beta, eval_func):
    if depth == 0:
        return None, eval_func(obs)

    moves = getAvailableSpot(obs, color)
    if color == 1:
        value = -float('inf')
        bestmove = None
        if len(moves) == 0: # no move, proceed to other player
            _ ,newValue = minimax(obs, -color, depth-1, alpha, beta)
            if newValue > value:
                value = newValue
        for move in moves:
            newBoard = makeMove(obs, move, color)
            _ ,newValue = minimax(newBoard, -color, depth-1, alpha, beta)
            if newValue > value:
                value = newValue
                bestmove = move
            alpha = max(alpha, value)
            if beta <= alpha:
                break

    else:
        value = float('inf')
        bestmove = None
        if len(moves) == 0:
            _, newValue = minimax(obs, -color, depth-1, alpha, beta)
            if newValue < value:
                value = newValue
        for move in moves:
            newBoard = makeMove(obs, move, color)
            _, newValue = minimax(newBoard, -color, depth-1, alpha, beta)
            if newValue < value:
                value = newValue
                bestmove = move
            beta = min(beta, value)
            if beta <= alpha:
                break
    return bestmove, value
```

有一個做到一半最後沒有完成的優化是Zobrist hash+查表，因為棋盤有左右、上下、旋轉對稱，有些搜尋可能會重複，利用Zobrist hash建一個棋盤盤面對應走法的hash table。或是利用TA提供的4GB空間放，先行把搜尋深度更深的結果存好，實際運行時先在資料庫中搜尋，搜尋不到時再實際跑minimax。

## A "NEAT" Approach

在這個project的最後一週其實已經都做的差不多了，我們能對minimax做的優化都已經做了，剩下evaluation有努力的空間。我就想到之前看的Youtube頻道[Code Bullet](https://www.youtube.com/c/CodeBullet/featured)裡面，用神經網路+基因演算法做了很多遊戲的agent，經過一點研究後知道他是用[NEAT](https://en.wikipedia.org/wiki/Neuroevolution_of_augmenting_topologies)。既然我們用的是python，那應該有人已經寫好了NEAT相關的套件，於是找到了[neat-python](https://neat-python.readthedocs.io/en/latest/)。再來就是找看看有沒有人做了這個套件的教學，於是找到了[Tech With Tim的這個系列](https://www.youtube.com/watch?v=MMxFDaIOHsE&list=PLzMcBGfZo4-lwGZWXz5Qgta_YNX3_vLS2)。

接下來就是寫一個讓兩個agent對打多場的function。為了提高效率，在這裡我用`multiprocessing`模組達到平行運算，硬體則有系上工作站，單一系統共12個thread。

```python
def matchup_mp(agent1, agent2, rounds=10, process_num=1, balanced=True):
    """multiprocess version of matchup()
    Args:
        agent1
        agent2
        rounds (int): how many rounds of game (each going first)

    Returns:
        tuple: ((agent1.s_depth, agent1_wins), (agent2.s_depth, agent2_wins), draws)
    """

    agent1_w = 0
    agent2_w = 0
    draw = 0

    # agent 1 go first as black
    pool = mp.Pool(process_num)

    args = [(agent1, agent2) for _ in range(rounds)]
    game_results = pool.starmap(playgame, args)

    pool.close()
    pool.join()

    for r in game_results:
        if r > 0:
            agent2_w += 1
        elif r < 0:
            agent1_w += 1
        elif r == 0:
            draw += 1

    # agent 2 go first as black
    if balanced:
        pool = mp.Pool(process_num)

        args = [(agent2, agent1) for _ in range(rounds)]
        game_results = pool.starmap(playgame, args)

        pool.close()
        pool.join()

        for r in game_results:
            if r > 0:
                agent1_w += 1
            elif r < 0:
                agent2_w += 1
            elif r == 0:
                draw += 1

    agent1.win += agent1_w
    agent1.loss += agent2_w
    agent1.draw += draw

    agent2.win += agent2_w
    agent2.loss += agent1_w
    agent2.draw += draw

    return agent1_w/(rounds*2)
```

我們獲得每個神經網路的fitness的方式是讓那個agent和一個target agent對打很多場，用勝率當fitness。神經網路有64個輸入，是棋盤的64個位置，白棋=1、黑棋=-1。神經網路的輸出則是作為evaluation用。在測試fitness的過程中，為了減少每一個generation的時間，神經網路搭配的agent是只搜尋1層的minimax agent。

但在run generation時我們發現一個奇怪的現象，當target agent是隨機下棋的時候，第一個generation就會有勝率高達0.9的神經網路了。受限於可以使用的計算力和時間，我們只有跑200個generation，在這200個generation中，平均的勝率幾乎沒有成長，不管target agent用的是random agent或是我們已經寫好的agent。但是所剩的時間不多，沒辦法再回去看測量fitness的地方有沒有寫錯，只能先把得到的神經網路先拿來跟原本的比看看。

## Results

因為Minimax做出來的agent缺乏隨機性，而且evaluation難以做到完美，考量到其他組可能不會加隨機性，我們決定測試兩種添加隨機的方法。第一種是設定前`n`步完全隨機下，第二種是每一步都有`p`的機率會隨機下。

採用第一種隨機性的agent我們稱之為`BasicMinimaxAgent`，採用第二種的我們稱之為`LittleRandomAgent`。`p`的值是人為評估得到的，考慮每盤棋大約會下32步，我們希望他其中一步隨機走就好，因為這一步可能是開局、中盤或尾盤，如此可以得到`p=0.03`。`n`則只是隨便選的。下面是他們兩個對上`RandomAgent`的成績。

**`BasicMinimaxAgent` (先手, `n=4`) vs `RandomAgent`**

| Depth        | 1     | 2     | 3     | 4     | 5     | 6     |
| ------------ | -----:| -----:| -----:| -----:| -----:| -----:|
| Games        | 5000  | 5000  | 5000  | 5000  | 5000  | 2000  |
| Wins         | 4404  | 4689  | 4841  | 4921  | 4954  | 1993  |
| Win%         | .881  | .938  | .968  | .984  | .991  | .997  |
| Sigma        | .0046 | .0034 | .0025 | .0018 | .0014 | .0013 |
| Win% - Sigma | .876  | .934  | .966  | .982  | .989  | .995  |
| Win% + Sigma | .885  | .941  | .971  | .986  | .992  | .998  |

**`LittleRandomAgent` (先手, `p=0.03`) vs `RandomAgent`**

| Depth        | 1     | 2     | 3     | 4     | 5     | 6     |
| ------------ | -----:| -----:| -----:| -----:| -----:| -----:|
| Games        | 5000  | 5000  | 5000  | 5000  | 5000  | 2000  |
| Wins         | 4446  | 4640  | 4818  | 4889  | 4951  | 1990  |
| Win%         | .889  | .928  | .964  | .978  | .990  | .995  |
| Sigma        | .0044 | .0037 | .0026 | .0021 | .0014 | .0016 |
| Win% - Sigma | .885  | .924  | .961  | .976  | .989  | .993  |
| Win% + Sigma | .894  | .932  | .966  | .980  | .992  | .997  |

兩者勝率差不多，但由於第二種隨機太不穩定，在實力接近時很可能會搞砸最重要的收尾，最終還是選擇第一種隨機。

再來就是看NEAT能帶來多少幫助，`NEATAgent`也添加了第一種隨機性，`n`使用同樣的值。

**`NEATAgent` (先手) vs `RandomAgent`**

| Depth        | 1     | 2     | 3     | 4     | 5     | 6     |
| ------------ | -----:| -----:| -----:| -----:| -----:| -----:|
| Games        | 5000  | 5000  | 5000  | 5000  | 5000  | 2000  |
| Wins         | 4423  | 4659  | 4846  | 4926  | 4969  | 1987  |
| Win%         | .885  | .932  | .969  | .985  | .994  | .994  |
| Sigma        | .0045 | .0036 | .0024 | .0017 | .0011 | .0018 |
| Win% - Sigma | .880  | .928  | .967  | .983  | .993  | .992  |
| Win% + Sigma | .889  | .935  | .972  | .987  | .995  | .995  |

看起來和`BasicMinimaxAgent`無太大差別。

為了從兩個裡選出一個作為代表的agent，讓他們對打10000場輪流先攻，結果如下：

**`NEATAgent` vs `BasicMinimaxAgent`**

| NEAT Wins | Basic Minimax Wins | Draw |
| ---------:| ------------------:| ----:|
| 5002      | 4784               | 214  |

看來NEAT還是稍微好一點，但沒有壓倒性的勝利。

## Conclusion

最後我們繳交的是`NEATAgent`, `n=2`，將`n`降低是因為在和黑白棋遊戲的電腦測試時，發現`n=4`還是會不穩。從最終和全班其他31組的對戰結果看來，這次還算是成功的。在各種先後攻的組合中只有對上其中兩隊且我方先攻時勝率僅0.5x，其他都大於0.7。拿去和三、四種黑白棋遊戲的電腦玩家對打，對上最高難度幾乎都能贏。但是我覺得能加強的地方應該還有很多，用先建好的資料庫+查詢也許可以讓棋力更加強悍。