# mbp 外接显示器开启HiDPI

## 1. 首先，打开系统分区权限：

### 查看SIP状态

    在终端中输入csrutil status，就可以看到是enabled还是disabled。

### 关闭SIP

    - 重启MAC，按住cmd+R直到屏幕上出现苹果的标志和进度条，进入Recovery模式；
    
    - 在屏幕最上方的工具栏找到实用工具（左数第3个），打开终端，输入：csrutil disable；
    
    - 关掉终端，重启mac；
    - 重启以后可以在终端中查看状态确认。

### 开启SIP

    与关闭的步骤类似，只是在S2中输入csrutil enable即可。[转自简书 Mac开启关闭SIP（系统完整性保护）](https://www.jianshu.com/p/fe78d2036192)

## 2. 获得显示器的 VendorID 和 ProductID （制造商ID 和 产品ID），在终端运行：

  ```bash
  > ioreg -lw0 | grep IODisplayPrefsKey | grep -o '/[^/]\+"$'
  
  /AppleBacklightDisplay-610-a034"
  /AppleDisplay-30ae-61a4"
  ```

    其中第一行610代表的是mac内置显示器，第二行即我们的外接显示器，VendorID=30ae，ProductID=61a4

## 3. 生成我们需要的配置文件

   使用该网页生成器填写所需信息，生成配置并下载[HiDPI配置生成器](https://comsysto.github.io/Display-Override-PropertyList-File-Parser-and-Generator-with-HiDPI-Support-For-Scaled-Resolutions/)

## 4. 复制配置到系统目录

- OS X 10.11及以上

  ```bash
  DIR=/System/Library/Displays/Contents/Resources/Overrides
  ```

- OS X 10.10及以下

  ```bash
  DIR=/System/Library/Displays/Overrides
  ```

- 把 ${VID} 和 ${PID} 替换成上面获得的VendorID和ProductID

  ```bash
  CONF=${DIR}/DisplayVendorID-${VID}/DisplayProductID-${PID}
  sudo mkdir -p ${DIR}
  sudo cp 配置文件 ${CONF}
  ```

## 5.重启并使用RDM调整分辨率

 [下载RDM](http://avi.alkalay.net/software/RDM/)

 {% asset_img RDM-screenshot.jpg%}
