#!/bin/bash

# 로그 파일이 저장되어 있는 디렉토리
log_dir="/var/log"

# 새로운 로그 파일을 저장할 디렉토리
collected_log_dir="./collected_logs"

# 디렉토리가 존재하지 않으면 생성
if [ ! -d "$collected_log_dir" ]; then
  mkdir "$collected_log_dir"
fi

# 로그 파일을 collected_log_dir 디렉토리로 복사
sudo cp -R "$log_dir"/*.log "$collected_log_dir"

# 복사가 완료되었음을 알림
echo "로그 파일 수집이 완료되었습니다."

