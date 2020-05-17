# 在 ArchLinux 上使用 Docker 執行健保卡元件 (`mLNHIICC`)，可用於綜合所得稅申報等服務

這個是基於 [https://github.com/chihchun/personal-income-tax-docker](https://github.com/chihchun/personal-income-tax-docker) 改出來的，但個人偏好讓 docker 只執行最小需要虛擬的部份，使得瀏覽器以及 Linux 讀卡機服務可以留在 ArchLinux 上執行

首先當然得先準備好讀卡機，這邊使用隨便買的多功能 USB 讀卡機

> 以下指令請自行判斷是否需要 `sudo`，無腦複製網路上的 `sudo` 指令來執行是很危險的...

## 在 ArchLinux 上需要安裝好的軟體

* `docker`, `docker-compose`
* 讀卡機服務 `pcscd` (Server protocol is 4:4)
  * 透過 `pacman -S ccid opensc pcsc-tools` 來安裝
  * 啟動讀卡機服務 `systemctl start pcscd`
* `git`, `sudo` 等工具

> 關於讀卡機 ArchLinux wiki 有更詳細的資料: [https://wiki.archlinux.org/index.php/Smartcards](https://wiki.archlinux.org/index.php/Smartcards)

## 在 ArchLinux 上測試一下

```sh
pcsc_scan
```

接著把健保卡插上，應該可以看到 `National Health Insurance Card, Taiwan` 之類的字樣，代表讀卡機與 ArchLinux pcscd 運作正常

## `git clone` 並建置執行健保卡元件 (`mLNHIICC`)

```sh
git clone https://github.com/pastleo/mLNHIICC-docker-archlinux.git
cd mLNHIICC-docker-archlinux
docker-compose up
```

看到以下 output 之後代表服務應該已經啟動：

```
Creating mlnhiicc-docker-archlinux_mlnhiicc_1 ... done
Attaching to mlnhiicc-docker-archlinux_mlnhiicc_1
mlnhiicc_1  | /usr/local/HiPKILocalSignServerApp/HiPKILocalSignServer
mlnhiicc_1  | + /usr/local/share/NHIICC/mLNHIICC
mlnhiicc_1  | + cd /usr/local/HiPKILocalSignServerApp
mlnhiicc_1  | + ./start.sh                                         
mlnhiicc_1  | + tail -f /dev/null                                  
mlnhiicc_1  | Server has started at 127.0.0.1:61161
```

> 其實 `mLNHIICC` 是跑在 `7777` 上，只是這個服務跑起來完全不會喊一聲

## 使 `iccert.nhi.gov.tw` 指向 `127.0.0.1`，並設定為可信任服務

對，很鳥：

```sh
echo "127.0.0.1 iccert.nhi.gov.tw" >> /etc/hosts
```

然後確認一下：

```sh
ping iccert.nhi.gov.tw
```

看到下面的回報代表這個設定沒問題了：

```
64 bytes from localhost (127.0.0.1): icmp_seq=1 ttl=64 time=0.041 ms
```

接著使用瀏覽器打開本機內 docker 跑起來的 `mLNHIICC` 服務：

* [https://iccert.nhi.gov.tw:7777/](https://iccert.nhi.gov.tw:7777/)
* [https://localhost:7777/](https://localhost:7777/)

> 在[健康存摺](https://myhealthbank.nhi.gov.tw/IHKE0002/IHKE0002S01.aspx)會使用 `https://localhost:7777` 來連接 `mLNHIICC` 服務

瀏覽器會說這些網站 SSL 不正常，這是當然的，他跑在本機上；我們得讓瀏覽器信任這個服務，在我這邊的 Chromium 上是 `Advanced` => `Proceed to ... (unsafe)`，接著應該可以看到 `已確認為可信任服務！`

## 檢測健保卡元件是否運作正常

使用剛剛信任 `iccert.nhi.gov.tw` 的瀏覽器打開這個網站：

[https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/webtesting/SampleY.aspx](https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/webtesting/SampleY.aspx)

* 戳一下 `讀取健保卡` 應該可以看到 `讀卡成功：XXX`
* 戳一下 `驗證健保卡` 應該可以看到各種成功，最後 `認證卡片：成功!`

## 接著就可以進行需要使用健保卡的服務

* 健保卡註冊：[https://cloudicweb.nhi.gov.tw/cloudic/system/mlogin.aspx](https://cloudicweb.nhi.gov.tw/cloudic/system/mlogin.aspx)
* 個人綜合所得稅申報：[https://efile.tax.nat.gov.tw/irxw/index.jsp](https://efile.tax.nat.gov.tw/irxw/index.jsp)
* 健保個人資料、欠費查詢：[https://eservice.nhi.gov.tw/Personal1/System/mLogin.aspx](https://eservice.nhi.gov.tw/Personal1/System/mLogin.aspx)
* 健康存摺：[https://myhealthbank.nhi.gov.tw/IHKE0002/IHKE0002S01.aspx](https://myhealthbank.nhi.gov.tw/IHKE0002/IHKE0002S01.aspx)

## 用完之後可以清理一下

* 把 `docker-compose up` 停掉
  * 刪除 container：`docker-compose rm`
  * 刪除 docker image：`docker rmi mlnhiicc`
* 把 `/etc/hosts` 恢復原狀
* 停止 pcscd： `systemctl stop pcscd`

## References

* 健保卡網路服務註冊－環境說明: [https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/mEventesting.htm](https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/mEventesting.htm)
* 財政部電子申報繳稅服務網：[https://tax.nat.gov.tw/alltax.html?id=1](https://tax.nat.gov.tw/alltax.html?id=1)