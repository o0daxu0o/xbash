#android mmi开发环境中bash的简单扩展
![Logo](data/logo.png)
##1.工程结构
####Xrnsd-extensions-to-bash在下面简写为xbash
	cmds
	├── config	-----------------------	工具相关配置
	│		├── bashrc						bashrc通用配置
	│		│		├── config_bashrc_base			bashrc配置
	│		│		└── config_bashrc_base.gone		bashrc部分可忽略配置
	│		│
	│		├── config_base					全局参数
	│		└── config_system_init			android build环境初始化工具的配置文件
	│
	├── data	--------------------------- 工具相关数据
	│		├── logo.png
	│		├── logo.psd
	│		└── user-dirs.dirs				home下默认文件夹配置
	│
	├── log   --------------------------- 运行日志
	│
	├── module	-----------------------	脚本实现文件[具体功能]
	│		│
	│		├── compile.sh					项目编译初始化
	│		├── bashrc						bashrc独立配置
	│		│		├── bashrc_base					为普通用户相关bash配置文件
	│		│		├── bashrc_home					为作者使用的普通用户相关bash配置文件
	│		│		├── bashrc_work_lz				为普通用户相关bash配置文件
	│		│		└── bashrc_root_work_lz			为root相关bash配置文件
	│		├── init							初始化工具
	│		│		├── base.sh				  		初始化工具
	│		│		├── init_xbash.sh			  		环境初始化工具
	│		│		└── init_system.sh		  		android mmi 环境初始化工具
	│		├── packet						packet工具
	│		│		└── pac_7731c.pl			  		sprd的7731c的packet生成工具
	│		├── test							脚本测试工具
	│		│		├── base.sh				  		demo测试,请忽略此文件的修改
	│		│		├── pytools.py			  		脚本语法逻辑校验高亮工具
	│		│		└── pytools.README
	│		├── maintain_system.sh			系统维护
	│		│
	│		└── tools.sh						函数实现
	│
	├── main.sh	-----------------------	主入口
	│
	└── README.md


##2 环境目录[参考]
		/home/xxx/
		├── tools     -------------------  环境相关
		│	    ├───── jdk  ---------------    java jdk
		│	    ├───── sdk  ---------------    android sdk
		│	    └───── sp_flash_tool_v5.1548   全局参数
		├── cmds      -------------------  xbash目录
		└── .bashrc   -------------------  xbash中bashrc_work_lz的软连接

##3.初始化环境

	1 cd Xrnsd-extensions-to-bash
	2 sudo chmod -R a+x main.sh module/ config/
	3 ./init.sh #初始化,下面命令3选1
		├── ./init.sh 	    初始化xbash
		├── ./init.sh -system 初始化system
		└── ./init.sh -all    初始化system,初始化xbash
	
	4 重开一个终端,输入ftReadMe 或 xc -h

##4.其他
	1 已验证环境
		ubuntu12.04 x64
		ubuntu14.04 x64
		ubuntu16.04 x64

	2 xc ,xb 为命令分类，搭配参数时和其余命令一样指向具体功能实现，xc为常用且稳定的实现
	3 在bash直接使用方法,不会记录xbash日志
	4 建议,不要以root权限运行xc clean_data_garbage
	5 建议,不要开启xx[休眠]，这玩意脾气不好
	6 对记录和校验版本包软件和硬件信息相关实现修改，会影响历史备份的使用[导致检测失败]
