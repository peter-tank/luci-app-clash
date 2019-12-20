#!/bin/sh
LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")
LOG_FILE="/tmp/clash_update.log"
MODELTYPE=$(uci get clash.config.download_core 2>/dev/null)
CORETYPE=$(uci get clash.config.dcore 2>/dev/null)
lang=$(uci get luci.main.lang 2>/dev/null)
if [ -f /tmp/clash.tar.gz ];then
rm -rf /tmp/clash.tar.gz >/dev/null 2>&1
fi
 echo '' >/tmp/clash_update.log 2>/dev/null
 
if [ /usr/share/clash/core_down_complete ];then 
  rm -rf /usr/share/clash/core_down_complete 2>/dev/null
fi

if [ $CORETYPE -eq 2 ];then
if [ -f /usr/share/clash/download_corer_version ];then
rm -rf /usr/share/clash/download_corer_version
fi
	if [ $lang == "zh_cn" ];then
         echo "${LOGTIME} - 正在检查最新版本。。" >$LOG_FILE
	elif [ $lang == "en" ];then
         echo "${LOGTIME} - Checking latest version.." >>$LOG_FILE
        fi
new_clashr_core_version=`wget -qO- "https://github.com/frainzy1477/clashrdev/tags"| grep "/frainzy1477/clashrdev/releases/tag/"| head -n 1| awk -F "/tag/v" '{print $2}'| sed 's/\">//'`

if [ $new_clashr_core_version ]; then
echo $new_clashr_core_version > /usr/share/clash/download_corer_version 2>&1 & >/dev/null
elif [ $new_clashr_core_version =="" ]; then
echo 0 > /usr/share/clash/download_corer_version 2>&1 & >/dev/null
fi
sleep 8
if [ -f /usr/share/clash/download_corer_version ];then
CLASHRVER=$(sed -n 1p /usr/share/clash/download_corer_version 2>/dev/null) 
fi
fi

if [ $CORETYPE -eq 1 ];then
if [ -f /usr/share/clash/download_core_version ];then
rm -rf /usr/share/clash/download_core_version
fi
	if [ $lang == "zh_cn" ];then
         echo "${LOGTIME} - 正在检查最新版本。。" >$LOG_FILE
	elif [ $lang == "en" ];then
         echo "${LOGTIME} - Checking latest version.." >>$LOG_FILE
        fi
new_clashr_core_version=`wget -qO- "https://github.com/frainzy1477/clash_dev/tags"| grep "/frainzy1477/clash_dev/releases/tag/"| head -n 1| awk -F "/tag/v" '{print $2}'| sed 's/\">//'`

if [ $new_clashr_core_version ]; then
echo $new_clashr_core_version > /usr/share/clash/download_core_version 2>&1 & >/dev/null
elif [ $new_clashr_core_version =="" ]; then
echo 0 > /usr/share/clash/download_core_version 2>&1 & >/dev/null
fi
sleep 8
if [ -f /usr/share/clash/download_core_version ];then
CLASHVER=$(sed -n 1p /usr/share/clash/download_core_version 2>/dev/null) 
fi
fi

if [ -f /usr/share/clash/core_version ];then
VER=$(sed -n 1p /usr/share/clash/core_version 2>/dev/null)
else
VER=0
fi

 if [ -f /usr/share/clash/corer_version ];then
VERR=$(sed -n 1p /usr/share/clash/corer_version 2>/dev/null)
else
VERR=0
fi

sleep 2

update(){
		if [ -f /tmp/clash.gz ];then
		rm -rf /tmp/clash.gz >/dev/null 2>&1
		fi
		if [ $lang == "zh_cn" ];then
			 echo "${LOGTIME} - 开始下载 Clash 内核..." >$LOG_FILE
		elif [ $lang == "en" ];then
			 echo "${LOGTIME} - Starting Clash Core download" >>$LOG_FILE
		fi				
	   if [ $CORETYPE -eq 1 ];then
		wget --no-check-certificate  https://github.com/frainzy1477/clash_dev/releases/download/v"$CLASHVER"/clash-"$MODELTYPE"-v"$CLASHVER".gz -O 2>&1 >1 /tmp/clash.gz
	   elif [ $CORETYPE -eq 2 ];then 
		wget --no-check-certificate  https://github.com/frainzy1477/clashrdev/releases/download/v"$CLASHRVER"/clashr-"$MODELTYPE"-v"$CLASHRVER".gz -O 2>&1 >1 /tmp/clash.gz
	   fi
	   
	   if [ "$?" -eq "0" ] && [ "$(ls -l /tmp/clash.gz |awk '{print int($5/1024)}')" -ne 0 ]; then
			if [ $lang == "zh_cn" ];then
			 echo "${LOGTIME} - 开始解压缩文件" >$LOG_FILE
			elif [ $lang == "en" ];then 
			 echo "${LOGTIME} - Beginning to unzip file" >>$LOG_FILE
			fi
		    gunzip /tmp/clash.gz >/dev/null 2>&1\
		    && rm -rf /tmp/clash.gz >/dev/null 2>&1\
		    && chmod 755 /tmp/clash\
		    && chown root:root /tmp/clash 
 
			if [ $lang == "zh_cn" ];then
			   echo "${LOGTIME} - 完成下载内核，正在更新..." >$LOG_FILE
			   elif [ $lang == "en" ];then
			   echo "${LOGTIME} - Successfully downloaded core, updating now..." >$LOG_FILE
			fi
			  
		    if [ $CORETYPE -eq 1 ];then
			  rm -rf /etc/clash/clash >/dev/null 2>&1
			  mv /tmp/clash /etc/clash/clash >/dev/null 2>&1
			 if [ $lang == "zh_cn" ];then
			  rm -rf /usr/share/clash/core_version >/dev/null 2>&1
			  echo $CLASHVER > /usr/share/clash/core_version 2>&1 & >/dev/null			 
			  echo "${LOGTIME} - Clash内核更新成功！" >$LOG_FILE
			 elif [ $lang == "en" ];then
			  rm -rf /usr/share/clash/core_version >/dev/null 2>&1
			  echo $CLASHVER > /usr/share/clash/core_version 2>&1 & >/dev/null			
			  echo "${LOGTIME} - Clash Core Update Successful" >>$LOG_FILE
			 fi
			
		    elif [ $CORETYPE -eq 2 ];then
			  rm -rf /usr/bin/clash >/dev/null 2>&1
			  mv /tmp/clash /usr/bin/clash >/dev/null 2>&1			  
			 if [ $lang == "zh_cn" ];then
			  rm -rf /usr/share/clash/corer_version >/dev/null 2>&1
			  echo $CLASHRVER > /usr/share/clash/corer_version 2>&1 & >/dev/null			 
			  echo "${LOGTIME} - Clashr内核更新成功！" >$LOG_FILE
			 elif [ $lang == "en" ];then
			  rm -rf /usr/share/clash/corer_version >/dev/null 2>&1
			  echo $CLASHRVER > /usr/share/clash/corer_version 2>&1 & >/dev/null			
			  echo "${LOGTIME} - Clashr Core Update Successful" >>$LOG_FILE
			 fi			  
		    fi
		    sleep 2
		    touch /usr/share/clash/core_down_complete >/dev/null 2>&1
		    sleep 2
		    rm -rf /var/run/core_update >/dev/null 2>&1
		    
			
	    else
		  if [ $lang == "zh_cn" ];then
		  echo "${LOGTIME} - 核心程序下载失败，请检查网络或稍后再试！" >$LOG_FILE
		  elif [ $lang == "en" ];then     
		  echo "${LOGTIME} - Core Update Error" >>$LOG_FILE
		  fi
		  rm -rf /tmp/clash.tar.gz >/dev/null 2>&1
		  echo "" > /tmp/clash_update.log >/dev/null 2>&1
	    fi  
		if pidof clash >/dev/null; then
		/etc/init.d/clash restart >/dev/null		
		fi
}

if [ $CORETYPE -eq 1 ] && [ $VER != $CLASHVER ]; then
	    update
elif [ $CORETYPE -eq 2 ] && [ $VERR != $CLASHRVER ]; then
	    update		
else
	 if [ $lang == "zh_cn" ];then
      echo "${LOGTIME} - 在用中是最新的内核！" >$LOG_FILE
	 elif [ $lang == "en" ];then      
       echo "${LOGTIME} - Currently using latest core" >$LOG_FILE
	 fi 
	sleep 2
	touch /usr/share/clash/core_down_complete >/dev/null 2>&1
	sleep 2
	rm -rf /var/run/core_update >/dev/null 2>&1

fi
