# mbp 外接显示器开启HiDPI

- 首先，下载一个脚本

```bash
curl -o ~/enable-HiDPI.sh https://raw.githubusercontent.com/syscl/Enable-HiDPI-OSX/master/enable-HiDPI.sh

> chmod +x ~/enable-HiDPI.sh

# 回车

> ~/enable-HiDPI.sh

# 选择要调整的显示器
#开盖时运行脚本 第二个是外接显示器的信息，盒盖情况下就只有外接显示器的信息

# 回车，然后会提示你输入分辨率。例:我需要它渲染3440X1440的HiDPI，就直接输入

> 5880X2880        //希望渲染的实际分辨率的两倍

# 回车再输入

> 3440X1440        //希望渲染的实际分辨率
```

- 重启后发现并没有生效（笑，其实这个脚本不是很好用）

fix...