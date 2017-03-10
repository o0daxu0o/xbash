#! /bin/bash
#####------------------变量------------------------------#########
readonly rModuleName=main.sh

mDirPathXbashTraget=$(cd `dirname $0`; pwd)
mDirNameXbashTragetConfig=config
mDirPathXbashTragetConfig=${mDirPathXbashTraget}/${mDirNameXbashTragetConfig}
mFileNameXbashTragetConfigBase=config_base
mFilePathXbashTragetConfigBase=${mDirPathXbashTragetConfig}/${mFileNameXbashTragetConfigBase}

#####------------------初始化------------------------------#########
if [ -f $mFilePathXbashTragetConfigBase ];then
	source  $mFilePathXbashTragetConfigBase
	#工具函数
	if [ -f $rFilePathCmdModuleTools ];then
		source  $rFilePathCmdModuleTools
	else
echo -e "\033[1;31m	工具函数初始化失败\n\
模块=$rModuleName\n\
toolsPath=$rFilePathCmdModuleTools\n\
\033[0m"
exit
	fi
else
echo -e "\033[1;31m	全局配置初始化失败\n\
模块=$rModuleName\n\
mFilePathXbashTragetConfigBase=$mFilePathXbashTragetConfigBase\n\
\033[0m"
exit
fi
#####---------------------流程函数---------------------------#########
ftWhoAmI()## #命令权限判定
{
	local ftName=命令权限判定
	local cmdName=$1

	#耦合变量校验
	local valCount=1
	if(( $#!=$valCount ))||[ -z "$cmdName" ]\
				||[ -z "$rCmdsPermissionBase" ]\
				||[ -z "$rCmdsPermissionRoot" ];then
		ftEcho -e "[${XCMD}]的参数错误 \n\
[参数数量def=$valCount]valCount=$# \n\
[命令名] cmdName=$cmdName \n\
[基础权限命令名列表]rCmdsPermissionBase=${rCmdsPermissionBase[@]} \n\
[特殊权限命令名列表]rCmdsPermissionRoot=${rCmdsPermissionRoot[@]} \n\
请查看下面说明:"
		ftReadMe $XCMD
	fi

	for cmd in ${rCmdsPermissionBase[@]}
	do
			if [ "$cmd" = "$cmdName" ]||[ "$XCMD" = "$cmdName" ];then
				commandAuthority=base
			fi
	done

	for cmd in ${rCmdsPermissionRoot[@]}
	do
			if [ "$cmd" = "$cmdName" ]||[ "$XCMD" = "$cmdName" ];then
				commandAuthority=root
			fi
	done
}

ftMain()
{
	local ftName=工具主入口
	while true; do
	case $rBaseShellParameter2 in
	-v | --version )		echo \"Xrnsd extensions to bash\" $rXbashVersion
				break;;
	test)			ftTest "$@"
				break;;
	reboot | shutdown)	ftBoot	$rBaseShellParameter2
				break;;
	clean_data_garbage)	ftCleanDataGarbage
				break;;
	-h| --help | -ft | -ftall)	ftReadMe $rBaseShellParameter3 $rBaseShellParameter2
				break;;
	vvv | -vvv)			ftEcho -b xbash;		echo \"Xrnsd extensions to bash\" $rXbashVersion
				ftEcho -b java;		java -version
				ftEcho -b gcc;		gcc -v
	break;;
	*)
		#权限约束开始
		ftWhoAmI $rBaseShellParameter2
		if [ "$commandAuthority" = "root" ]; then
			if [ `whoami` = "root" ]; then
				while true; do
				case $rBaseShellParameter2 in
					"backup")	${rDirPathCmdsModule}/${rFileNameCmdModuleMS} backup; break;;
					"restore")	${rDirPathCmdsModule}/${rFileNameCmdModuleMS} restore; break;;
				esac
				done
			else
				ftEcho -ex "当前用户权限过低，请转换为root 用户后重新运行"
			fi
		elif [ "$commandAuthority" = "base" ]; then
			if [ `whoami` = $rNameUser ]; then
				while true; do
				case $rBaseShellParameter2 in
					"mtk_flashtool")	ftMtkFlashTool ; break;;
					"restartadb")		ftRestartAdb; break;;
					"pac")			ftCopySprdPacFileList; break;;
					"monkey")		ftKillPhoneAppByPackageName com.android.commands.monkey; break;;
					"systemui")		ftKillPhoneAppByPackageName com.android.systemui; break;;
					"launcher")		ftKillPhoneAppByPackageName com.android.launcher3; break;;
					"bootanim")		ftBootAnimation $rBaseShellParameter3 $rBaseShellParameter2;break;;
					"gjh")			ftGjh;break;;
				esac
				done
			else
				ftEcho -ex "转化普通用户后，再次尝试"
			fi
		#权限约束结束
		elif [ "$commandAuthority" = "null" ]; then
			ftOther $rBaseShellParameter2
		fi
		break;;
	esac
	done
}

ftOther()
{
	while true; do
	case $XCMD in
	"xk")	ftKillPhoneAppByPackageName $rBaseShellParameter2	;break;;
	*)	ftEcho -e "命令[${XCMD}]参数=[$1]错误，请查看命令使用示例";ftReadMe $XCMD; break;;
	esac
	done
}

ftReadMe()
{
	local ftName=工具命令使用说明

	# 凡调用此方法的操作产生的日志都视为无效
	local dirPathLogExpired=`ftLnUtil ${mFilePathLog%/*}`
	local dirPathLogOther=${rDirPathLog}/other
	if [ ! -d "$dirPathLogOther" ];then
		mkdir $dirPathLogOther
	fi
	if [ "$dirPathLogOther" != "$dirPathLogExpired" ]\
		&&[ $mFilePathLog != "/dev/null" ];then
		local dirPathExpired=${dirPathLogOther}/$(basename $dirPathLogExpired)
		if [ -d $dirPathExpired ];then
			mv ${dirPathLogExpired}/* $dirPathExpired
			rm -rf $dirPathLogExpired
		else
			mv $dirPathLogExpired $dirPathExpired
		fi
		export mFilePathLog=${dirPathLogOther}/$(basename $mFilePathLog)
	fi

	while true; do
		case "$1" in
		ft | -ft )
	cat<<EOF
ftCreate7731CSoftwareVersionPathByGitBranchName  ---  生成服务器上传的路径
ftKillPhoneAppByPackageName ---- kill掉包名为packageName的应用
ftJdkVersionTempSwitch           临时切换jdk版本
ftCopySprdPacFileList ---------- 自动复制sprd的pac相关文件
ftBackupOutsByMove               备份out
ftCleanDataGarbage ------------- 快速清空回收站
ftReduceFileList                 精简动画帧文件
ftPushAppByName ---------------- push Apk文件
ftBootAnimation                  生成开关机动画
ftAutoUploadPro ---------------- 上传文件到服务器[低耦合版]
ftLanguageUtils                  语言缩写转换
ftMtkFlashTool ----------------- mtk下载工具
ftRmNormalBin                    清空pac相关资源文件
ftAutoUpload ------------------- 上传文件到固定服务器
ftUpdateHosts ------------------ 更新hosts
ftReNameFile ------------------- 批量重命名
ftRestartAdb                     重启adb sever
ftAutoPacket ------------------- 生成7731c使用的pac
ftYKSwitch                       切换永恒星和康龙配置 sever
ftBoot ------------------------- 延时免密码关机重启
ftGjh                            生成国际化所需的xml文件

EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
		ftall | -ftall )
	cat<<EOF
=========================================================================
方法名 方法说明
	|// 使用格式
	|   说明
	|  方法名 参数1 参数2
例	|  方法名 参数1 参数2
=========================================================================
ftBootAnimation 生成开关机动画
	|
	|// ftBootAnimation [edittype] [path]
	|   直接生成动画包，不做其他操作，不确认资源文件是否有效
	|  ftBootAnimation create path
	|   初始化生成bootanimation2.zip所需要的东东，然后生成动画包
	|  ftBootAnimation new path
	|
ftBoot 延时免密码关机重启
	|
	|// ftBoot 关机/重启 时间/秒
	|   100秒后自动关机/重启
例	|  ftBoot shutdown/shutdown 100
	|
ftReNameFile 批量重命名
	|不指定文件名长度默认为4
	|// ftReNameFile 目录
	|// ftReNameFile 目录 文件名长度
例	|  ftReNameFile /home/xxxx/temp
例	|  ftReNameFile /home/xxxx/temp 5
	|
ftUpdateHosts 更新hosts
	|
	|   使用默认hosts源[https://raw.githubusercontent.com/racaljk/hosts/master/hosts]
	|// ftUpdateHosts 无参
	|   使用自定义hosts源
	|// ftUpdateHosts https://xxxx
例	|  ftUpdateHosts https://raw/hosts/master/hosts
	|
ftPushAppByName push Apk文件
	|
	|// ftPushAppByName [AppName]
	|// ftPushAppByName [filePathApk] [dirPath]
	|   push SystemUI对应的apk到手机中,前提当前bash已初始化android build环境
例	|  ftPushAppByName SystemUI
	|   push自定义apk 到/system/app
例	|  ftPushAppByName /home/xxx/xx.apk /system/app
	|
ftReduceFileList 精简动画帧文件
	|
	|// ftReduceFileList 目录
	|// ftReduceFileList 保留的百分比 目录
	|   另外输入保留比例
例	|  ftReduceFileList /home/xxxx/temp
	|   保留百分之60的文件
例	|  ftReduceFileList 60 /home/xxxx/temp
	|
ftKillPhoneAppByPackageName kill掉包名为packageName的应用
	|
	|// ftKillPhoneAppByPackageName packageName
	|
ftJdkVersionTempSwitch 临时切换jdk版本
	|
	|// ftJdkVersionTempSwitch 版本
	|   ftJdkVersionTempSwitch 1.6/1.7
	|
ftLanguageUtils 语言缩写转换
	|
	|//ftLanguageUtils "语音缩写列表/语言列表"
	|
	|ftLanguageUtils "ar_IL bn_BD my_MM"
	|ftLanguageUtils "阿拉伯语 孟加拉语 缅甸语"
	|
ftAutoUploadPro 上传文件到服务器[低耦合版]
	|
	|//ftAutoUploadPro 上传源文件路径 服务器IP地址 用户名 用户密码 服务器的存放路径
	|ftAutoUploadPro /home/xxx/1.test 192.168.1.188 server 123456 智能机软件/7731c/....
	|
	|
ftAutoUpload 上传文件到固定服务器
	|
	|//ftAutoUpload 上传源文件路径
	|ftAutoUpload /home/xxx/1.test
	|
ftRmNormalBin 清空pac相关资源文件
	|
	|ftRmNormalBin [dir_path_pac_res] #生成7731c使用的pac的目录，和生成所需的文件存放的目录
	|
ftAutoPacket 生成7731c使用的pac
	|
	|ftAutoPacket  #自动打包
	|ftAutoPacket -y #自动打包，上传到188服务器
	|
ftYKSwitch 切换永恒星和康龙配置
	|
	|// ftYKSwitch yhx/kl
	|
==========================================
======= 无参部分
==========================================
	|
ftCopySprdPacFileList 自动复制sprd的pac相关文件
	|
ftBackupOutsByMove 备份out
	|
ftCleanDataGarbage 快速清空回收站
	|
ftMtkFlashTool mtk下载工具
	|
ftRestartAdb 重启adb sever
	|
ftGjh 生成国际化所需的xml文件
	|
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
		a | A | -a |-A)
	ftEcho -s “命令 参数 -h 可查看参数具体说明”
	cat<<EOF
=========================================================================
	命令	--- 参数/命令说明
	|// 使用格式
	|  参数	 ---------------- [参数权限] ----	参数说明
=========================================================================
xb ----- 系统维护
	|// xb ×××××
	|
	|  backup	---------------- [root] ------	备份系统
	|  restore	---------------- [root] ------	还原系统
xc ----- 常规自定义命令和扩展
	|// xc ×××××
	|
	|  pac		--------------------------	自动复制sprd的pac相关文件
	|  test		--------------------------	shell测试
	|  clean_data_garbage	------------------	快速清空回收站
	|  restartadb	--------------------------	重启adb服务
	|  bootanim	--------------------------	制作开关机动画包
	|	|  xc bootanim	[edittype] [path]
	|	|  xc bootanim	 create	动画资源目录	不初始化，直接生成动画包
	|	|  xc bootanim	 new	动画资源目录	初始化后生成动画包
	|
	|  v 		--------------------------	自定义命令版本
	|  help		--------------------------	查看自定义命令说明
	|  vvv		--------------------------	系统环境关键参数查看
	|  gjh		--------------------------	生成国际化所需的xml文件
xk ----- 关闭手机指定进程
	|// xk ×××××
	|
	|  monkey	-----------------------------	关闭monkey
	|  systemui	-----------------------------	关闭systemui
	|  应用包名	-----------------------------	关闭指定app
xl ----- 过滤 android 含有tag的所有等级的log
	|// xl tag
	|
xt ----- 检测shell脚本，语法检测和测试运行
	|// xt 脚本文件名
	|
xle ---- 过滤 android 含有tag的E级log
	|// xle tag
	|
xkd ---- 快速删除海量文件
	|// xkd 文件夹
	|
xbh ---- 根据标签过滤命令历史
	|// xbh 标签
	|
xp ----- 查看文件绝对路径
	|// xp 文件名
	|
==========================================
======= 无参部分
==========================================
	|
xgl ----- 简单查看最近10次git commit
xi ------ 快速初始化模块编译环境
xr ------ 使.bashrc修改生效
.  ------ 进入上一级目录
.. ------ 进入上两级目录
xd ------ mtk下载工具
xu ------ 打开.bashrc
.9 ------ 打开.9工具
xx ------ 休眠
xs ------ 关机
xss ----- 重启

===============	临时命令 ===================
xversion--[无参] / 查看软件版本
xg6572 ----- 下载mtk6572的工程
	|// xg6572 分支名
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
	xc |test | clean_data_garbage|restartadb | help | gjh)ftEcho -g;
cat<<EOF
xc	----- 常规自定义命令和扩展
	|// xc ×××××
	|
	|  pac		--------------------------	自动复制sprd的pac相关文件
	|  test		--------------------------	shell测试
	|  clean_data_garbage	------------------	快速清空回收站
	|  restartadb	--------------------------	重启adb服务
	|  bootanim	--------------------------	制作开关机动画包
	|	|  xc bootanim	[edittype] [path]
	|	|  xc bootanim	 create	动画资源目录	不初始化，直接生成动画包
	|	|  xc bootanim	 new	动画资源目录	初始化后生成动画包
	|
	|  v 		--------------------------	自定义命令版本
	|  help		--------------------------	查看自定义命令说明
	|  vvv		--------------------------	系统环境关键参数查看
	|  gjh		--------------------------	生成国际化所需的xml文件
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
	xb | backup | restore)ftEcho -g;
cat<<EOF
xb	----- 系统维护
	|// xb ×××××
	|
	|  backup	---------------- [root] ------	备份系统
	|  restore	---------------- [root] ------	还原系统
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
xk | monkey | systemui)ftEcho -g;
cat<<EOF
xk	----- 关闭手机指定进程
	|// xk ×××××
	|
	|  monkey	-------------------------------	关闭monkey
	|  systemui	-----------------------------	关闭systemui
	|  应用包名	-----------------------------	关闭指定app
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
	xt)
cat<<EOF
xt ----- 检测shell脚本，语法检测和测试运行
	|// xt 脚本文件名
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
	xh)
cat<<EOF
xh ----- 查看具体命令说明
	|// xh 命令名
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
	*)ftReadMe -a;break;;
	esac
done
}

#####-------------------执行------------------------------#########
ftTiming
ftLog
ftMain $@ 2>&1|tee -a $mFilePathLog
ftTiming
exit
