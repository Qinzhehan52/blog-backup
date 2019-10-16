---
title: daemon守护进程创建
date: 2019-06-24 15:34:55
tags:
---

## php创建守护进程代码

```php
<?php
    // 一次fork  
    $pid = pcntl_fork();
    if ( $pid < 0 ) {
        exit( ' fork error. ' );
    } else if( $pid > 0 ) {
        exit( ' parent process. ' );
    }
    // 将当前子进程提升会会话组组长 这是至关重要的一步 
    if ( ! posix_setsid() ) {
        exit( ' setsid error. ' );
    }
    // 二次fork
    $pid = pcntl_fork();
    if( $pid < 0 ){
        exit( ' fork error. ' );
    } else if( $pid > 0 ) {
        exit( ' parent process. ' );
    }
	
    // 真正的逻辑代码们 下面仅仅写个循环以示例
    for( $i = 1 ; $i <= 100 ; $i++ ){
        sleep( 1 );
        file_put_contents( 'daemon.log', $i, FILE_APPEND );
    }
?>
```

## 两次fork的作用

### 第一次fork

确保当前进程不是 `session leader`,  `session leader` 调用 `setsid` 不会产生新的 `session`，下面是 gnu 对 `setsid` 与 `controlling session` 关系的解释，子进程在调用 `setsid` 之后成为了一个新 `session` 的 `leader` 并且不再与之前的 `controlling session` 关联。

> One of the attributes of a process is its controlling terminal. Child processes created with fork inherit the controlling terminal from their parent process. In this way, all the processes in a session inherit the controlling terminal from the session leader. A session leader that has control of a terminal is called the controlling process of that terminal.

> You generally do not need to worry about the exact mechanism used to allocate a controlling terminal to a session, since it is done for you by the system when you log in.

> **An individual process disconnects from its controlling terminal when it calls setsid to become the leader of a new session.** See Process Group Functions.